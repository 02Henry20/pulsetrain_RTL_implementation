#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/experiment.conf"
ARCH_FILE="${SCRIPT_DIR}/architectures.txt"
RESULT_DIR="${SCRIPT_DIR}/results"
PER_UPDATE_DIR="${RESULT_DIR}/per_update"
LOG_DIR="${SCRIPT_DIR}/logs"
WORK_DIR="${SCRIPT_DIR}/work"
STATUS_FILE="${WORK_DIR}/run_status.csv"
PYTHON_BIN="${PYTHON_BIN:-python3}"

status() { printf '%-5s %s\n' "$1" "$2"; }
record_status() {
    printf '%s,%s,%s,%s,%s\n' "$1" "$2" "$3" "$4" "$5" >> "${STATUS_FILE}"
}

if [[ ! -f "${CONFIG_FILE}" ]]; then
    status FAIL "missing ${CONFIG_FILE}"
    exit 1
fi
# shellcheck source=/dev/null
source "${CONFIG_FILE}"

required_positive=(CROSSBAR_DIMENSION MAX_BL STOCHASTIC_VALUE_WIDTH OUTPUT_BUFFER_DEPTH DIGITAL_CLOCK_NS SYNTH_TARGET_PERIOD_NS)
for name in "${required_positive[@]}"; do
    value="${!name:-}"
    if [[ ! "${value}" =~ ^[0-9]+([.][0-9]+)?$ ]] || [[ "${value}" == "0" ]]; then
        status FAIL "${name} must be positive in experiment.conf"
        exit 1
    fi
done
if [[ ${#PULSE_TIMES_NS[@]} -eq 0 ]]; then
    status FAIL "PULSE_TIMES_NS must contain at least one value"
    exit 1
fi
for pulse in "${PULSE_TIMES_NS[@]}"; do
    if [[ ! "${pulse}" =~ ^[1-9][0-9]*$ ]]; then
        status FAIL "pulse times must be positive integer nanoseconds"
        exit 1
    fi
done

mapfile -t ARCHITECTURES < <(
    sed -e 's/[[:space:]]*#.*$//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' "${ARCH_FILE}" |
        awk 'NF {print}'
)
if [[ ${#ARCHITECTURES[@]} -eq 0 ]]; then
    status FAIL "no architectures enabled in ${ARCH_FILE}"
    exit 1
fi
if [[ ! " ${ARCHITECTURES[*]} " =~ " ${BASELINE_ARCHITECTURE} " ]]; then
    status FAIL "baseline architecture ${BASELINE_ARCHITECTURE} is not enabled"
    exit 1
fi

TRACE_PATH="${TRACE_CSV}"
if [[ "${TRACE_PATH}" != /* ]]; then
    TRACE_PATH="${SCRIPT_DIR}/${TRACE_PATH}"
fi

for arch in "${ARCHITECTURES[@]}"; do
    filelist="${PROJECT_ROOT}/SIM/FUNCTION/filelists/${arch}.f"
    wrapper="${PROJECT_ROOT}/RTL/architectures/${arch}/TOP.v"
    if [[ ! "${arch}" =~ ^[a-z0-9_]+$ ]] || [[ ! -f "${wrapper}" ]] || [[ ! -f "${filelist}" ]]; then
        status FAIL "invalid architecture entry: ${arch}"
        exit 1
    fi
    if [[ $(grep -Fxc "../../RTL/architectures/${arch}/TOP.v" "${filelist}") -ne 1 ]]; then
        status FAIL "${filelist} must reference exactly its own TOP.v"
        exit 1
    fi
done

rm -rf "${RESULT_DIR}" "${LOG_DIR}" "${WORK_DIR}"
rm -rf "${PROJECT_ROOT}/SIM/FUNCTION/runs" "${PROJECT_ROOT}/SYN_topo/runs"
mkdir -p "${PER_UPDATE_DIR}" "${LOG_DIR}/simulation" "${LOG_DIR}/synthesis" "${WORK_DIR}/simulation"
printf 'stage,architecture,pulse_time_ns,status,log\n' > "${STATUS_FILE}"

status RUN "validating and converting $(basename "${TRACE_PATH}")"
if ! "${PYTHON_BIN}" "${SCRIPT_DIR}/prepare_trace.py" \
    "${TRACE_PATH}" "${WORK_DIR}/trace.replay" "${WORK_DIR}/trace_stats.csv" \
    --dimension "${CROSSBAR_DIMENSION}" --max-bl "${MAX_BL}" \
    --value-width "${STOCHASTIC_VALUE_WIDTH}"; then
    status FAIL "trace validation failed"
    exit 1
fi
status PASS "trace validated"

overall_failed=0
for arch in "${ARCHITECTURES[@]}"; do
    sim_dir="${WORK_DIR}/simulation/${arch}"
    compile_log="${LOG_DIR}/simulation/${arch}_compile.log"
    mkdir -p "${sim_dir}"
    status RUN "compile ${arch}"
    if command -v vcs >/dev/null 2>&1 && (
        cd "${PROJECT_ROOT}/SIM/FUNCTION" &&
        vcs -full64 -sverilog -timescale=1ns/1ps -top TB_REPLAY \
            -f "filelists/${arch}.f" "../TESTBENCH/TB_REPLAY.sv" \
            "-pvalue+TB_REPLAY.CROSSBAR_DIMENSION=${CROSSBAR_DIMENSION}" \
            "-pvalue+TB_REPLAY.MAX_BL=${MAX_BL}" \
            "-pvalue+TB_REPLAY.STOCHASTIC_VALUE_WIDTH=${STOCHASTIC_VALUE_WIDTH}" \
            "-pvalue+TB_REPLAY.OUTPUT_BUFFER_DEPTH=${OUTPUT_BUFFER_DEPTH}" \
            "-pvalue+TB_REPLAY.DIGITAL_CLOCK_NS=${DIGITAL_CLOCK_NS}" \
            "-pvalue+TB_REPLAY.LFSR_SEED=${LFSR_SEED}" \
            -o "${sim_dir}/simv"
    ) >"${compile_log}" 2>&1; then
        status PASS "compile ${arch}"
        record_status compile "${arch}" "" PASS "${compile_log}"
        compile_ok=1
    else
        status FAIL "compile ${arch}; see ${compile_log}"
        record_status compile "${arch}" "" FAIL "${compile_log}"
        compile_ok=0
        overall_failed=1
    fi

    for pulse in "${PULSE_TIMES_NS[@]}"; do
        sim_log="${LOG_DIR}/simulation/${arch}_${pulse}ns.log"
        result_csv="${PER_UPDATE_DIR}/${arch}_${pulse}ns.csv"
        status RUN "simulate ${arch} at ${pulse} ns"
        if [[ ${compile_ok} -eq 1 ]] && \
            "${sim_dir}/simv" \
                "+TRACE_FILE=${WORK_DIR}/trace.replay" \
                "+RESULT_FILE=${result_csv}" \
                "+T_PULSE_NS=${pulse}" \
                "+ARCHITECTURE=${arch}" >"${sim_log}" 2>&1 && \
            grep -q '^RESULT: PASS' "${sim_log}"; then
            status PASS "simulate ${arch} at ${pulse} ns"
            record_status simulation "${arch}" "${pulse}" PASS "${sim_log}"
        else
            status FAIL "simulate ${arch} at ${pulse} ns; see ${sim_log}"
            record_status simulation "${arch}" "${pulse}" FAIL "${sim_log}"
            overall_failed=1
        fi
    done

    synth_log="${LOG_DIR}/synthesis/${arch}.log"
    status RUN "synthesize ${arch} (no SAIF)"
    if command -v dc_shell >/dev/null 2>&1 && (
        cd "${PROJECT_ROOT}/SYN_topo" &&
        env CROSSBAR_DIMENSION="${CROSSBAR_DIMENSION}" MAX_BL="${MAX_BL}" \
            STOCHASTIC_VALUE_WIDTH="${STOCHASTIC_VALUE_WIDTH}" \
            OUTPUT_BUFFER_DEPTH="${OUTPUT_BUFFER_DEPTH}" \
            ./run_synthesis "${arch}"
    ) >"${synth_log}" 2>&1; then
        status PASS "synthesize ${arch}"
        record_status synthesis "${arch}" "" PASS "${synth_log}"
    else
        status FAIL "synthesize ${arch}; see ${synth_log}"
        record_status synthesis "${arch}" "" FAIL "${synth_log}"
        overall_failed=1
    fi
done

cp "${STATUS_FILE}" "${RESULT_DIR}/run_status.csv"
status RUN "aggregate CSV and Markdown results"
if "${PYTHON_BIN}" "${SCRIPT_DIR}/extract_results.py" \
    --architectures "${ARCHITECTURES[@]}" \
    --pulse-times "${PULSE_TIMES_NS[@]}" \
    --baseline "${BASELINE_ARCHITECTURE}" \
    --per-update-dir "${PER_UPDATE_DIR}" \
    --synth-root "${PROJECT_ROOT}/SYN_topo/runs" \
    --trace-stats "${WORK_DIR}/trace_stats.csv" \
    --run-status "${STATUS_FILE}" --output-dir "${RESULT_DIR}" \
    --trace "$(basename "${TRACE_PATH}")" --dimension "${CROSSBAR_DIMENSION}" \
    --max-bl "${MAX_BL}" --clock-ns "${DIGITAL_CLOCK_NS}" \
    --seed "${LFSR_SEED}" --target-period-ns "${SYNTH_TARGET_PERIOD_NS}"; then
    status PASS "results generated"
else
    status FAIL "one or more simulation/synthesis stages failed"
    overall_failed=1
fi

printf '\nReport: %s\nLatency CSV: %s\nSynthesis CSV: %s\nSummary CSV: %s\n' \
    "${RESULT_DIR}/summary.md" "${RESULT_DIR}/latency.csv" \
    "${RESULT_DIR}/synthesis.csv" "${RESULT_DIR}/summary.csv"
exit "${overall_failed}"
