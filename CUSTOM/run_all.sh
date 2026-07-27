#!/usr/bin/env bash

set -uo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
SIM_DIR="${PROJECT_ROOT}/SIM/FUNCTION"
SYNTH_DIR="${PROJECT_ROOT}/SYN_topo"
RTL_ARCH_DIR="${PROJECT_ROOT}/RTL/architectures"
TB_DIR="${PROJECT_ROOT}/SIM/TESTBENCH"
CONFIG_FILE="${ARCHITECTURE_CONFIG:-${SCRIPT_DIR}/architectures.txt}"
LOG_DIR="${SCRIPT_DIR}/logs"
RESULT_DIR="${SCRIPT_DIR}/results"
STATUS_FILE="${RESULT_DIR}/run_status.csv"
PYTHON_BIN="${PYTHON_BIN:-python3}"

usage() {
    cat <<'EOF'
Usage: bash CUSTOM/run_all.sh [--keep-old]

Runs functional simulation, SAIF generation, and synthesis for every enabled
entry in CUSTOM/architectures.txt. Raw tool output is stored under CUSTOM/logs.

Options:
  --keep-old  Deprecated compatibility option; disabled runs are always kept.
  -h, --help  Show this help.
EOF
}

while (($# > 0)); do
    case "$1" in
        --keep-old)
            # Disabled architecture data is preserved by default.
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            printf 'ERROR: Unknown option: %s\n' "$1" >&2
            usage >&2
            exit 2
            ;;
    esac
    shift
done

if [[ ! -d "${RTL_ARCH_DIR}" || ! -f "${SIM_DIR}/execute_function.csh" ||
      ! -f "${SYNTH_DIR}/run_synthesis" ]]; then
    printf 'ERROR: Project layout is not valid below %s\n' "${PROJECT_ROOT}" >&2
    exit 2
fi

if [[ ! -f "${CONFIG_FILE}" ]]; then
    printf 'ERROR: Architecture configuration not found: %s\n' "${CONFIG_FILE}" >&2
    exit 2
fi

missing_tools=()
for tool in tcsh vcs fsdb2vcd vcd2saif dc_shell "${PYTHON_BIN}"; do
    if ! command -v "${tool}" >/dev/null 2>&1; then
        missing_tools+=("${tool}")
    fi
done

if ((${#missing_tools[@]} > 0)); then
    printf 'ERROR: Required tools are not available: %s\n' "${missing_tools[*]}" >&2
    printf 'Load the Synopsys environment, then run this script again.\n' >&2
    exit 2
fi

declare -a ARCHITECTURES=()
declare -A SEEN_ARCHITECTURES=()

while IFS= read -r raw_line || [[ -n "${raw_line}" ]]; do
    line="${raw_line%%#*}"
    read -r architecture _ <<<"${line}"
    [[ -z "${architecture:-}" ]] && continue

    if [[ ! "${architecture}" =~ ^[a-z0-9_]+$ ]]; then
        printf 'ERROR: Invalid architecture name in %s: %s\n' \
            "${CONFIG_FILE}" "${architecture}" >&2
        exit 2
    fi

    if [[ -n "${SEEN_ARCHITECTURES[${architecture}]:-}" ]]; then
        printf 'ERROR: Duplicate architecture in %s: %s\n' \
            "${CONFIG_FILE}" "${architecture}" >&2
        exit 2
    fi

    SEEN_ARCHITECTURES["${architecture}"]=1
    ARCHITECTURES+=("${architecture}")
done < "${CONFIG_FILE}"

if ((${#ARCHITECTURES[@]} == 0)); then
    printf 'ERROR: No architectures are enabled in %s\n' "${CONFIG_FILE}" >&2
    exit 2
fi

for architecture in "${ARCHITECTURES[@]}"; do
    architecture_upper="${architecture^^}"
    testbench="TB_TOP_${architecture_upper}"

    if [[ ! -d "${RTL_ARCH_DIR}/${architecture}" ]]; then
        printf 'ERROR: RTL architecture directory is missing: %s\n' \
            "${RTL_ARCH_DIR}/${architecture}" >&2
        exit 2
    fi
    if [[ ! -f "${SIM_DIR}/filelists/${architecture}.f" ]]; then
        printf 'ERROR: Simulation file list is missing: %s\n' \
            "${SIM_DIR}/filelists/${architecture}.f" >&2
        exit 2
    fi
    if [[ ! -f "${TB_DIR}/${testbench}.v" ]]; then
        printf 'ERROR: Testbench is missing: %s\n' \
            "${TB_DIR}/${testbench}.v" >&2
        exit 2
    fi
done

safe_remove_tree() {
    local target="$1"
    if [[ -z "${target}" || "${target}" == "${PROJECT_ROOT}" ||
          "${target}" != "${PROJECT_ROOT}"/* ]]; then
        printf 'ERROR: Refusing to remove unsafe path: %s\n' "${target}" >&2
        exit 2
    fi
    rm -rf -- "${target}"
}

clean_selected_results() {
    local architecture
    local architecture_upper
    local testbench

    printf '[CLEAN] Removing previous data for %d enabled architectures\n' \
        "${#ARCHITECTURES[@]}"

    for architecture in "${ARCHITECTURES[@]}"; do
        architecture_upper="${architecture^^}"
        testbench="TB_TOP_${architecture_upper}"

        # Remove only the run pair that will be regenerated below.
        safe_remove_tree "${SIM_DIR}/runs/${architecture}/${testbench}"
        safe_remove_tree "${SYNTH_DIR}/runs/${architecture}/${testbench}"
        rm -f -- \
            "${LOG_DIR}/${architecture}.simulation.log" \
            "${LOG_DIR}/${architecture}.synthesis.log"
    done
}

prepare_status_file() {
    local temporary_status="${STATUS_FILE}.tmp"
    local status_line
    local status_architecture

    printf '%s\n' \
        'architecture,testbench,simulation_status,synthesis_status,simulation_log,synthesis_log' \
        > "${temporary_status}"

    if [[ -f "${STATUS_FILE}" ]]; then
        while IFS= read -r status_line || [[ -n "${status_line}" ]]; do
            status_architecture="${status_line%%,*}"
            [[ -z "${status_architecture}" || "${status_architecture}" == "architecture" ]] && continue

            # Keep status rows for architectures excluded from this invocation.
            if [[ -z "${SEEN_ARCHITECTURES[${status_architecture}]:-}" ]]; then
                printf '%s\n' "${status_line}" >> "${temporary_status}"
            fi
        done < "${STATUS_FILE}"
    fi

    mv -- "${temporary_status}" "${STATUS_FILE}"
}

mkdir -p -- "${LOG_DIR}" "${RESULT_DIR}"
clean_selected_results
prepare_status_file

simulation_passed() {
    local architecture="$1"
    local testbench="$2"
    local run_dir="${SIM_DIR}/runs/${architecture}/${testbench}"
    local metrics_file="${run_dir}/architecture_metrics.csv"
    local simulation_log="${run_dir}/simulation.log"
    local saif_file="${run_dir}/${architecture}_${testbench}.saif"

    [[ -s "${metrics_file}" && -s "${simulation_log}" && -s "${saif_file}" ]] || return 1
    grep -q '^RESULT: PASS' "${simulation_log}" || return 1
    ! grep -q '^RESULT: FAIL' "${simulation_log}" || return 1

    awk -F, '
        NR == 2 {
            gsub(/\r/, "", $NF)
            found = 1
            status = (($NF + 0) == 0) ? 0 : 1
        }
        END {
            if (!found) exit 1
            exit status
        }
    ' "${metrics_file}"
}

synthesis_artifacts_valid() {
    local architecture="$1"
    local testbench="$2"
    local run_dir="${SYNTH_DIR}/runs/${architecture}/${testbench}"
    local reports_dir="${run_dir}/reports"
    local synthesis_log="${run_dir}/logs/all.log"
    local required_report

    [[ -s "${synthesis_log}" ]] || return 1
    ! grep -qE '^(Error:|RM-Error:|Fatal:)' "${synthesis_log}" || return 1

    for required_report in \
        TOP.mapped.qor.rpt \
        TOP.mapped.area.rpt \
        TOP.mapped.power.rpt \
        TOP.mapped.timing.rpt \
        TOP.check_design.rpt \
        TOP.check_timing; do
        [[ -s "${reports_dir}/${required_report}" ]] || return 1
    done

    ! grep -qE '^(Error:|RM-Error:|Fatal:)' \
        "${reports_dir}/TOP.check_design.rpt" \
        "${reports_dir}/TOP.check_timing"
}

synthesis_reports_clean() {
    local architecture="$1"
    local testbench="$2"
    local qor_report="${SYNTH_DIR}/runs/${architecture}/${testbench}/reports/TOP.mapped.qor.rpt"

    awk '
        /Critical Path Slack:/ {
            setup_slack_seen = 1
            if (($NF + 0) < 0) violations = 1
        }
        /No\. of Violating Paths:/ {
            setup_seen = 1
            if (($NF + 0) > 0) violations = 1
        }
        /Worst Hold Violation:/ {
            hold_slack_seen = 1
        }
        /No\. of Hold Violations:/ {
            hold_seen = 1
        }
        /Nets With Violations:/ {
            design_rule_seen = 1
            if (($NF + 0) > 0) violations = 1
        }
        /Max Trans Violations:/ {
            if (($NF + 0) > 0) violations = 1
        }
        /Max Cap Violations:/ {
            if (($NF + 0) > 0) violations = 1
        }
        END {
            if (!setup_slack_seen || !setup_seen || !hold_slack_seen ||
                !hold_seen || !design_rule_seen) exit 2
            exit violations ? 1 : 0
        }
    ' "${qor_report}"
}

synthesis_violation_summary() {
    local architecture="$1"
    local testbench="$2"
    local qor_report="${SYNTH_DIR}/runs/${architecture}/${testbench}/reports/TOP.mapped.qor.rpt"

    awk '
        /Critical Path Slack:/ && $NF != "uninit" {
            slack = $NF + 0
            if (!slack_seen || slack < worst_slack) worst_slack = slack
            slack_seen = 1
        }
        /No\. of Violating Paths:/ {
            value = $NF + 0
            if (value > setup_paths) setup_paths = value
        }
        /Nets With Violations:/ {
            value = $NF + 0
            if (value > drc_nets) drc_nets = value
        }
        /Max Trans Violations:/ {
            value = $NF + 0
            if (value > transition_nets) transition_nets = value
        }
        /Max Cap Violations:/ {
            value = $NF + 0
            if (value > capacitance_nets) capacitance_nets = value
        }
        END {
            if (!slack_seen) {
                printf "setup_paths=%d, worst_setup=unknown, DRC_nets=%d, max_transition=%d, max_capacitance=%d",
                    setup_paths, drc_nets, transition_nets, capacitance_nets
            } else {
                printf "setup_paths=%d, worst_setup=%.3fns, DRC_nets=%d, max_transition=%d, max_capacitance=%d",
                    setup_paths, worst_slack, drc_nets, transition_nets, capacitance_nets
            }
        }
    ' "${qor_report}"
}

total=${#ARCHITECTURES[@]}
synthesis_completed=0
report_clean=0
report_violations=0
failed=0
index=0

printf '[INFO ] Enabled architectures: %d\n' "${total}"

for architecture in "${ARCHITECTURES[@]}"; do
    ((index += 1))
    architecture_upper="${architecture^^}"
    testbench="TB_TOP_${architecture_upper}"
    simulation_log_rel="CUSTOM/logs/${architecture}.simulation.log"
    synthesis_log_rel="CUSTOM/logs/${architecture}.synthesis.log"
    simulation_log="${PROJECT_ROOT}/${simulation_log_rel}"
    synthesis_log="${PROJECT_ROOT}/${synthesis_log_rel}"
    simulation_status="FAIL"
    synthesis_status="SKIPPED"

    printf '[RUN  ] [%02d/%02d] %-38s simulation\n' \
        "${index}" "${total}" "${architecture}"
    start_seconds=${SECONDS}

    if (cd -- "${SIM_DIR}" && \
        ./execute_function.csh "${architecture}" "${testbench}") \
        > "${simulation_log}" 2>&1 && \
       simulation_passed "${architecture}" "${testbench}"; then
        simulation_status="PASS"
        printf '[PASS ] [%02d/%02d] %-38s simulation (%ds)\n' \
            "${index}" "${total}" "${architecture}" "$((SECONDS - start_seconds))"
    else
        ((failed += 1))
        printf '[FAIL ] [%02d/%02d] %-38s simulation; see %s\n' \
            "${index}" "${total}" "${architecture}" "${simulation_log_rel}"
        printf '%s,%s,%s,%s,%s,%s\n' \
            "${architecture}" "${testbench}" "${simulation_status}" \
            "${synthesis_status}" "${simulation_log_rel}" "${synthesis_log_rel}" \
            >> "${STATUS_FILE}"
        continue
    fi

    printf '[RUN  ] [%02d/%02d] %-38s synthesis\n' \
        "${index}" "${total}" "${architecture}"
    start_seconds=${SECONDS}

    if (cd -- "${SYNTH_DIR}" && \
        ./run_synthesis "${architecture}" "${testbench}") \
        > "${synthesis_log}" 2>&1 && \
       synthesis_artifacts_valid "${architecture}" "${testbench}"; then
        ((synthesis_completed += 1))
        if synthesis_reports_clean "${architecture}" "${testbench}"; then
            synthesis_status="PASS"
            ((report_clean += 1))
            printf '[PASS ] [%02d/%02d] %-38s synthesis and QoR (%ds)\n' \
                "${index}" "${total}" "${architecture}" "$((SECONDS - start_seconds))"
        else
            report_check_status=$?
            if ((report_check_status == 1)); then
                synthesis_status="VIOLATIONS"
                ((report_violations += 1))
                violation_summary="$(synthesis_violation_summary "${architecture}" "${testbench}")"
                printf '[WARN ] [%02d/%02d] %-38s synthesis complete; %s (%ds)\n' \
                    "${index}" "${total}" "${architecture}" "${violation_summary}" \
                    "$((SECONDS - start_seconds))"
            else
                synthesis_status="FAIL"
                ((failed += 1))
                printf '[FAIL ] [%02d/%02d] %-38s QoR report incomplete; see %s\n' \
                    "${index}" "${total}" "${architecture}" \
                    "SYN_topo/runs/${architecture}/${testbench}/reports/TOP.mapped.qor.rpt"
            fi
        fi
    else
        synthesis_status="FAIL"
        ((failed += 1))
        printf '[FAIL ] [%02d/%02d] %-38s synthesis; see %s\n' \
            "${index}" "${total}" "${architecture}" "${synthesis_log_rel}"
    fi

    printf '%s,%s,%s,%s,%s,%s\n' \
        "${architecture}" "${testbench}" "${simulation_status}" \
        "${synthesis_status}" "${simulation_log_rel}" "${synthesis_log_rel}" \
        >> "${STATUS_FILE}"
done

printf '[INFO ] Extracting summary tables\n'
if ! "${PYTHON_BIN}" "${SCRIPT_DIR}/extract_results.py" \
    --project-root "${PROJECT_ROOT}" --output-dir "${RESULT_DIR}"; then
    ((failed += 1))
    printf '[FAIL ] Summary extraction failed\n' >&2
fi

printf '\n[DONE ] Synthesis completed: %d/%d; report-clean: %d/%d\n' \
    "${synthesis_completed}" "${total}" "${report_clean}" "${total}"
printf '[DONE ] QoR violations: %d; failed stages: %d\n' \
    "${report_violations}" "${failed}"
printf '[DONE ] Summary: CUSTOM/results/summary.md\n'
printf '[DONE ] CSV:     CUSTOM/results/summary.csv\n'

if ((failed > 0 || report_violations > 0)); then
    exit 1
fi

exit 0
