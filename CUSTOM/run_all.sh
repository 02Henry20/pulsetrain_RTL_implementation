#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/experiment.conf"
RESULT_DIR="${SCRIPT_DIR}/results"
PER_UPDATE_DIR="${RESULT_DIR}/per_update"
LOG_DIR="${SCRIPT_DIR}/logs"
WORK_DIR="${SCRIPT_DIR}/work"
STATUS_FILE="${WORK_DIR}/run_status.csv"
PLAN_FILE="${WORK_DIR}/experiment_plan.json"
INPUTS_TSV="${WORK_DIR}/inputs.tsv"
JOBS_TSV="${WORK_DIR}/jobs.tsv"
PYTHON_BIN="${PYTHON_BIN:-python3}"

status() { printf '%-5s %s\n' "$1" "$2"; }

record_status() {
    printf '%s,%s,%s,%s,%s,%s\n' \
        "$1" "$2" "$3" "$4" "$5" "$6" >> "${STATUS_FILE}"
}

power_summary_passes() {
    [[ -s "$1" ]] &&
        awk -F, '
            $1 ~ /^"?status"?$/ {
                gsub(/^"|"$/, "", $2)
                found = 1
                passed = ($2 == "PASS")
                exit
            }
            END { exit !(found && passed) }
        ' "$1"
}

resolve_custom_path() {
    if [[ "$1" == /* ]]; then
        printf '%s\n' "$1"
    else
        printf '%s/%s\n' "${SCRIPT_DIR}" "$1"
    fi
}

if [[ ! -f "${CONFIG_FILE}" ]]; then
    status FAIL "missing ${CONFIG_FILE}"
    exit 1
fi

# shellcheck source=/dev/null
source "${CONFIG_FILE}"

required_positive_integer=(
    STOCHASTIC_VALUE_WIDTH
    OUTPUT_BUFFER_DEPTH
    DIGITAL_CLOCK_NS
)

for name in "${required_positive_integer[@]}"; do
    value="${!name:-}"
    if [[ ! "${value}" =~ ^[1-9][0-9]*$ ]]; then
        status FAIL "${name} must be a positive integer in experiment.conf"
        exit 1
    fi
done

if [[ ! "${SYNTH_TARGET_PERIOD_NS:-}" =~ ^[0-9]+([.][0-9]+)?$ ]] ||
   [[ "${SYNTH_TARGET_PERIOD_NS:-}" =~ ^0+([.]0+)?$ ]]; then
    status FAIL "SYNTH_TARGET_PERIOD_NS must be positive in experiment.conf"
    exit 1
fi

if (( STOCHASTIC_VALUE_WIDTH > 32 )); then
    status FAIL "STOCHASTIC_VALUE_WIDTH must be in 1..32"
    exit 1
fi

if [[ ! "${LFSR_SEED:-}" =~ ^[1-9][0-9]*$ ]]; then
    status FAIL "LFSR_SEED must be a positive decimal integer"
    exit 1
fi
max_lfsr_seed=$(( (1 << STOCHASTIC_VALUE_WIDTH) - 1 ))
if (( ${#LFSR_SEED} > 10 )) || (( LFSR_SEED > max_lfsr_seed )); then
    status FAIL "LFSR_SEED must fit STOCHASTIC_VALUE_WIDTH without truncation"
    exit 1
fi

if ! declare -p DEFAULT_PULSE_TIMES_NS >/dev/null 2>&1 ||
   [[ "$(declare -p DEFAULT_PULSE_TIMES_NS)" != "declare -a"* ]] ||
   [[ ${#DEFAULT_PULSE_TIMES_NS[@]} -eq 0 ]]; then
    status FAIL "DEFAULT_PULSE_TIMES_NS must contain at least one value"
    exit 1
fi
for pulse in "${DEFAULT_PULSE_TIMES_NS[@]}"; do
    if [[ ! "${pulse}" =~ ^[1-9][0-9]*$ ]]; then
        status FAIL "default pulse times must be positive integer nanoseconds"
        exit 1
    fi
done

INPUTS_JSON_PATH="$(resolve_custom_path "${INPUTS_JSON:-inputs.json}")"
ARCHITECTURES_JSON_PATH="$(resolve_custom_path "${ARCHITECTURES_JSON:-architectures.json}")"
if [[ ! -f "${INPUTS_JSON_PATH}" || ! -f "${ARCHITECTURES_JSON_PATH}" ]]; then
    status FAIL "missing inputs or architectures JSON manifest"
    exit 1
fi

# Validate the complete plan before deleting any previous results.
PLAN_STAGE="$(mktemp -d "${TMPDIR:-/tmp}/ss28-plan.XXXXXX")"
trap 'rm -rf -- "${PLAN_STAGE}"' EXIT
status RUN "validating JSON experiment manifests"
if ! "${PYTHON_BIN}" "${SCRIPT_DIR}/build_experiment_plan.py" \
    --architectures "${ARCHITECTURES_JSON_PATH}" \
    --inputs "${INPUTS_JSON_PATH}" \
    --custom-dir "${SCRIPT_DIR}" \
    --project-root "${PROJECT_ROOT}" \
    --default-pulse-times "${DEFAULT_PULSE_TIMES_NS[@]}" \
    --plan-output "${PLAN_STAGE}/experiment_plan.json" \
    --inputs-tsv "${PLAN_STAGE}/inputs.tsv" \
    --jobs-tsv "${PLAN_STAGE}/jobs.tsv"; then
    status FAIL "experiment manifest validation failed"
    exit 1
fi
status PASS "experiment manifests validated"

rm -rf "${RESULT_DIR}" "${LOG_DIR}" "${WORK_DIR}"
rm -rf "${PROJECT_ROOT}/SIM/FUNCTION/runs" "${PROJECT_ROOT}/SYN_topo/runs"
mkdir -p "${PER_UPDATE_DIR}" "${LOG_DIR}" "${WORK_DIR}"
cp "${PLAN_STAGE}/experiment_plan.json" "${PLAN_FILE}"
cp "${PLAN_STAGE}/inputs.tsv" "${INPUTS_TSV}"
cp "${PLAN_STAGE}/jobs.tsv" "${JOBS_TSV}"

printf 'stage,input_id,architecture,pulse_time_ns,status,log\n' > "${STATUS_FILE}"
overall_failed=0
declare -A INPUT_VALID

# Convert every selected input once. All architecture jobs for that input reuse it.
while IFS=$'\t' read -r input_id trace_path dimension max_bl pulse_csv; do
    input_work="${WORK_DIR}/${input_id}"
    mkdir -p "${input_work}"
    status RUN "validate ${input_id}: $(basename "${trace_path}")"
    if "${PYTHON_BIN}" "${SCRIPT_DIR}/prepare_trace.py" \
        "${trace_path}" \
        "${input_work}/trace.replay" \
        "${input_work}/trace_stats.csv" \
        --dimension "${dimension}" \
        --max-bl "${max_bl}"; then
        status PASS "trace ${input_id} validated"
        record_status trace "${input_id}" "" "" PASS "${input_work}/trace_stats.csv"
        INPUT_VALID["${input_id}"]=1
    else
        status FAIL "trace ${input_id} validation failed"
        record_status trace "${input_id}" "" "" FAIL "${trace_path}"
        INPUT_VALID["${input_id}"]=0
        overall_failed=1
    fi
done < "${INPUTS_TSV}"

while IFS=$'\t' read -r \
    input_id trace_path dimension max_bl pulse_csv arch run_testbench \
    run_synthesis baseline rng_family expect_sort expect_zero_delete \
    expect_group_mask; do

    input_work="${WORK_DIR}/${input_id}"
    if [[ "${INPUT_VALID[${input_id}]:-0}" -ne 1 ]]; then
        if [[ "${run_testbench}" -eq 1 ]]; then
            IFS=',' read -r -a pulse_times <<< "${pulse_csv}"
            record_status compile "${input_id}" "${arch}" "" SKIP ""
            for pulse in "${pulse_times[@]}"; do
                record_status simulation "${input_id}" "${arch}" "${pulse}" SKIP ""
            done
        fi
        if [[ "${run_synthesis}" -eq 1 ]]; then
            record_status synthesis "${input_id}" "${arch}" "" SKIP ""
        fi
        if [[ "${run_testbench}" -eq 1 && "${run_synthesis}" -eq 1 ]]; then
            for pulse in "${pulse_times[@]}"; do
                record_status power "${input_id}" "${arch}" "${pulse}" SKIP ""
            done
        fi
        continue
    fi

    expect_baseline=0
    if [[ "${expect_sort}" -eq 0 && "${expect_zero_delete}" -eq 0 &&
          "${expect_group_mask}" -eq 0 ]]; then
        expect_baseline=1
    fi

    power_saif_list=""
    if [[ "${run_testbench}" -eq 1 ]]; then
        sim_dir="${input_work}/simulation/${arch}"
        compile_log="${LOG_DIR}/${input_id}/simulation/${arch}_compile.log"
        mkdir -p "${sim_dir}" "$(dirname "${compile_log}")" \
            "${PER_UPDATE_DIR}/${input_id}"
        status RUN "compile ${input_id}/${arch}"
        if command -v vcs >/dev/null 2>&1 && (
            cd "${PROJECT_ROOT}/SIM/FUNCTION" &&
            vcs -full64 -sverilog -timescale=1ns/1ps -top TB_REPLAY \
                -f "filelists/${arch}.f" \
                "../TESTBENCH/TB_REPLAY.sv" \
                "-pvalue+TB_REPLAY.CROSSBAR_DIMENSION=${dimension}" \
                "-pvalue+TB_REPLAY.MAX_BL=${max_bl}" \
                "-pvalue+TB_REPLAY.STOCHASTIC_VALUE_WIDTH=${STOCHASTIC_VALUE_WIDTH}" \
                "-pvalue+TB_REPLAY.OUTPUT_BUFFER_DEPTH=${OUTPUT_BUFFER_DEPTH}" \
                "-pvalue+TB_REPLAY.DIGITAL_CLOCK_NS=${DIGITAL_CLOCK_NS}" \
                "-pvalue+TB_REPLAY.LFSR_SEED=${LFSR_SEED}" \
                -debug_access+r \
                -o "${sim_dir}/simv"
        ) >"${compile_log}" 2>&1; then
            status PASS "compile ${input_id}/${arch}"
            record_status compile "${input_id}" "${arch}" "" PASS "${compile_log}"
            compile_ok=1
        else
            status FAIL "compile ${input_id}/${arch}; see ${compile_log}"
            record_status compile "${input_id}" "${arch}" "" FAIL "${compile_log}"
            compile_ok=0
            overall_failed=1
        fi

        IFS=',' read -r -a pulse_times <<< "${pulse_csv}"
        for pulse in "${pulse_times[@]}"; do
            sim_log="${LOG_DIR}/${input_id}/simulation/${arch}_${pulse}ns.log"
            result_csv="${PER_UPDATE_DIR}/${input_id}/${arch}_${pulse}ns.csv"
            saif_dump="${sim_dir}/tb.saif"
            saif_file="${sim_dir}/${pulse}ns.saif"
            status RUN "simulate ${input_id}/${arch} at ${pulse} ns"
            rm -f "${saif_dump}"
            if [[ ${compile_ok} -eq 1 ]] &&
               (
                   cd "${sim_dir}" &&
                   ./simv \
                    "+TRACE_FILE=${input_work}/trace.replay" \
                    "+RESULT_FILE=${result_csv}" \
                    "+T_PULSE_NS=${pulse}" \
                    "+ARCHITECTURE=${arch}" \
                    "+EXPECT_SORT=${expect_sort}" \
                    "+EXPECT_ZERO_DELETE=${expect_zero_delete}" \
                    "+EXPECT_BASELINE=${expect_baseline}" \
                    "+SAIF_FILE=tb.saif"
               ) >"${sim_log}" 2>&1 &&
               grep -q '^RESULT: PASS' "${sim_log}" &&
               [[ -s "${saif_dump}" ]] &&
               mv -f "${saif_dump}" "${saif_file}"; then
                status PASS "simulate ${input_id}/${arch} at ${pulse} ns"
                record_status simulation "${input_id}" "${arch}" "${pulse}" PASS "${sim_log}"
                if [[ -n "${power_saif_list}" ]]; then
                    power_saif_list+=";"
                fi
                power_saif_list+="${pulse}=${saif_file}"
            else
                status FAIL "simulate ${input_id}/${arch} at ${pulse} ns; see ${sim_log}"
                record_status simulation "${input_id}" "${arch}" "${pulse}" FAIL "${sim_log}"
                overall_failed=1
            fi
        done
    fi

    if [[ "${run_synthesis}" -eq 1 ]]; then
        synth_log="${LOG_DIR}/${input_id}/synthesis/${arch}.log"
        mkdir -p "$(dirname "${synth_log}")"
        status RUN "synthesize ${input_id}/${arch} (post-map SAIF power)"
        synth_rc=127
        if command -v dc_shell >/dev/null 2>&1; then
            (
                cd "${PROJECT_ROOT}/SYN_topo" &&
                env \
                    CROSSBAR_DIMENSION="${dimension}" \
                    MAX_BL="${max_bl}" \
                    STOCHASTIC_VALUE_WIDTH="${STOCHASTIC_VALUE_WIDTH}" \
                    OUTPUT_BUFFER_DEPTH="${OUTPUT_BUFFER_DEPTH}" \
                    LFSR_SEED="${LFSR_SEED}" \
                    RAW_REPLAY_MODE=0 \
                    SYNTH_TARGET_PERIOD_NS="${SYNTH_TARGET_PERIOD_NS}" \
                    DIGITAL_CLOCK_NS="${DIGITAL_CLOCK_NS}" \
                    POWER_SAIF_LIST="${power_saif_list}" \
                    SAIF_INSTANCE="TB_REPLAY/dut" \
                    ./run_synthesis "${arch}" "${input_id}"
            ) >"${synth_log}" 2>&1
            synth_rc=$?
        else
            printf 'ERROR: dc_shell not found\n' > "${synth_log}"
        fi

        synth_ok=0
        if [[ ${synth_rc} -eq 0 || ${synth_rc} -eq 2 ]]; then
            status PASS "synthesize ${input_id}/${arch}"
            record_status synthesis "${input_id}" "${arch}" "" PASS "${synth_log}"
            synth_ok=1
        else
            status FAIL "synthesize ${input_id}/${arch}; see ${synth_log}"
            record_status synthesis "${input_id}" "${arch}" "" FAIL "${synth_log}"
            overall_failed=1
        fi

        if [[ "${run_testbench}" -eq 1 ]]; then
            IFS=',' read -r -a pulse_times <<< "${pulse_csv}"
            power_dir="${PROJECT_ROOT}/SYN_topo/runs/${input_id}/${arch}/no_saif/reports/power"
            for pulse in "${pulse_times[@]}"; do
                saif_file="${input_work}/simulation/${arch}/${pulse}ns.saif"
                power_summary="${power_dir}/${pulse}ns.summary.csv"
                if [[ ! -s "${saif_file}" || ${synth_ok} -ne 1 ]]; then
                    status SKIP "power ${input_id}/${arch} at ${pulse} ns (dependency failed)"
                    record_status power "${input_id}" "${arch}" "${pulse}" SKIP "${power_summary}"
                elif power_summary_passes "${power_summary}"; then
                    status PASS "power ${input_id}/${arch} at ${pulse} ns"
                    record_status power "${input_id}" "${arch}" "${pulse}" PASS "${power_summary}"
                else
                    status FAIL "power ${input_id}/${arch} at ${pulse} ns; see ${power_summary}"
                    record_status power "${input_id}" "${arch}" "${pulse}" FAIL "${power_summary}"
                    overall_failed=1
                fi
            done
        fi
    fi
done < "${JOBS_TSV}"

cp "${STATUS_FILE}" "${RESULT_DIR}/run_status.csv"
status RUN "aggregate multi-input CSV and Markdown results"
if "${PYTHON_BIN}" "${SCRIPT_DIR}/extract_results.py" \
    --plan "${PLAN_FILE}" \
    --per-update-dir "${PER_UPDATE_DIR}" \
    --synth-root "${PROJECT_ROOT}/SYN_topo/runs" \
    --work-dir "${WORK_DIR}" \
    --run-status "${STATUS_FILE}" \
    --output-dir "${RESULT_DIR}" \
    --clock-ns "${DIGITAL_CLOCK_NS}" \
    --seed "${LFSR_SEED}" \
    --target-period-ns "${SYNTH_TARGET_PERIOD_NS}"; then
    status PASS "results generated"
else
    status FAIL "one or more requested stages failed"
    overall_failed=1
fi

REPORT_DIR="${SCRIPT_DIR}/reports"
mkdir -p "${REPORT_DIR}"
cp -f "${RESULT_DIR}/summary.md" "${RESULT_DIR}/summary.csv" \
    "${RESULT_DIR}/latency.csv" "${RESULT_DIR}/synthesis.csv" \
    "${RESULT_DIR}/energy.csv" "${REPORT_DIR}/" 2>/dev/null || true

printf '\nPlan: %s\nReport: %s\nLatency CSV: %s\nSynthesis CSV: %s\nEnergy CSV: %s\nSummary CSV: %s\nReports: %s\n' \
    "${PLAN_FILE}" \
    "${RESULT_DIR}/summary.md" \
    "${RESULT_DIR}/latency.csv" \
    "${RESULT_DIR}/synthesis.csv" \
    "${RESULT_DIR}/energy.csv" \
    "${RESULT_DIR}/summary.csv" \
    "${REPORT_DIR}"

exit "${overall_failed}"
