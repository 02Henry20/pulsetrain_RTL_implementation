#!/usr/bin/env python3
"""Extract simulation and Design Compiler metrics into summary tables."""

import argparse
import csv
import math
import re
import sys
from collections import OrderedDict
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Tuple


FLOAT_PATTERN = r"[-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?"


def parse_args() -> argparse.Namespace:
    script_dir = Path(__file__).resolve().parent
    parser = argparse.ArgumentParser(
        description="Summarize architecture simulation and synthesis runs."
    )
    parser.add_argument(
        "--project-root",
        type=Path,
        default=script_dir.parent,
        help="Repository root (default: parent of CUSTOM).",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=script_dir / "results",
        help="Directory for summary.csv and summary.md.",
    )
    return parser.parse_args()


def read_text(path: Path) -> str:
    if not path.is_file():
        return ""
    return path.read_text(encoding="utf-8", errors="replace")


def as_float(value: Any) -> Optional[float]:
    if value is None:
        return None
    try:
        number = float(str(value).strip())
    except (TypeError, ValueError):
        return None
    return number if math.isfinite(number) else None


def as_int(value: Any) -> Optional[int]:
    number = as_float(value)
    return int(number) if number is not None else None


def search_float(text: str, label: str) -> Optional[float]:
    match = re.search(
        rf"(?mi)^\s*{re.escape(label)}\s*:\s*({FLOAT_PATTERN})\b", text
    )
    return as_float(match.group(1)) if match else None


def search_int(text: str, label: str) -> Optional[int]:
    value = search_float(text, label)
    return int(value) if value is not None else None


def load_run_status(path: Path) -> OrderedDict:
    records = OrderedDict()
    if not path.is_file():
        return records
    with path.open(newline="", encoding="utf-8") as handle:
        for row in csv.DictReader(handle):
            architecture = row.get("architecture", "").strip()
            testbench = row.get("testbench", "").strip()
            if architecture and testbench:
                records[(architecture, testbench)] = row
    return records


def discover_runs(
    project_root: Path,
    status_records: OrderedDict,
) -> List[Tuple[str, str]]:
    runs = OrderedDict(
        (key, None) for key in status_records
    )
    for base in (
        project_root / "SYN_topo" / "runs",
        project_root / "SIM" / "FUNCTION" / "runs",
    ):
        if not base.is_dir():
            continue
        for architecture_dir in sorted(path for path in base.iterdir() if path.is_dir()):
            for run_dir in sorted(path for path in architecture_dir.iterdir() if path.is_dir()):
                runs.setdefault((architecture_dir.name, run_dir.name), None)
    return list(runs)


def parse_simulation_metrics(run_dir: Path) -> Dict[str, Any]:
    metrics_path = run_dir / "architecture_metrics.csv"
    simulation_log = read_text(run_dir / "simulation.log")
    metrics: Dict[str, Any] = {}

    if metrics_path.is_file():
        with metrics_path.open(newline="", encoding="utf-8") as handle:
            row = next(csv.DictReader(handle), None)
        if row:
            integer_fields = (
                "samples",
                "sets",
                "cycles",
                "end_to_end_latency_cycles",
                "input_stall_cycles",
                "buffer_full_cycles",
                "output_pairs",
                "x_output_pulses",
                "d_output_pulses",
                "output_toggles",
                "expected_events",
                "golden_errors",
                "errors",
            )
            for field in integer_fields:
                metrics[field] = as_int(row.get(field))

    if metrics and metrics.get("errors") == 0 and "RESULT: PASS" in simulation_log:
        metrics["simulation_status"] = "PASS"
    elif metrics_path.is_file() or simulation_log:
        metrics["simulation_status"] = "FAIL"
    else:
        metrics["simulation_status"] = "MISSING"

    sets = metrics.get("sets")
    latency_cycles = metrics.get("end_to_end_latency_cycles")
    if sets and latency_cycles is not None:
        metrics["average_set_latency_cycles"] = latency_cycles / sets
        metrics["output_pairs_per_set"] = (metrics.get("output_pairs") or 0) / sets

    return metrics


def parse_qor(text: str) -> Dict[str, Any]:
    records: List[Dict[str, Any]] = []
    scenario = ""
    current: Optional[Dict[str, Any]] = None
    labels = {
        "Critical Path Length": "critical_path_ns",
        "Critical Path Slack": "setup_slack_ns",
        "Critical Path Clk Period": "target_period_ns",
        "Total Negative Slack": "total_negative_slack_ns",
        "No. of Violating Paths": "violating_paths",
        "Worst Hold Violation": "hold_slack_ns",
        "No. of Hold Violations": "hold_violating_paths",
    }

    for line in text.splitlines():
        scenario_match = re.match(r"\s*Scenario '([^']+)'", line)
        if scenario_match:
            scenario = scenario_match.group(1)
            continue

        group_match = re.match(r"\s*Timing Path Group (?:'([^']+)'|(\(none\)))", line)
        if group_match:
            if current:
                records.append(current)
            current = {
                "scenario": scenario,
                "path_group": group_match.group(1) or group_match.group(2),
            }
            continue

        if current is None:
            continue

        for label, field in labels.items():
            value_match = re.match(
                rf"\s*{re.escape(label)}:\s*({FLOAT_PATTERN})\b", line
            )
            if value_match:
                current[field] = as_float(value_match.group(1))
                break

    if current:
        records.append(current)

    constrained = [
        record
        for record in records
        if record.get("target_period_ns") is not None
        and record.get("setup_slack_ns") is not None
    ]
    result: Dict[str, Any] = {}

    if constrained:
        for record in constrained:
            record["required_period_ns"] = (
                record["target_period_ns"] - record["setup_slack_ns"]
            )
        limiting = max(constrained, key=lambda item: item["required_period_ns"])
        required_period = limiting["required_period_ns"]
        result.update(
            {
                "timing_scenario": limiting["scenario"],
                "limiting_path_group": limiting["path_group"],
                "target_period_ns": limiting["target_period_ns"],
                "worst_setup_slack_ns": min(
                    record["setup_slack_ns"] for record in constrained
                ),
                "estimated_min_period_ns": required_period,
                "estimated_max_frequency_mhz": (
                    1000.0 / required_period if required_period > 0 else None
                ),
                "critical_path_ns": max(
                    record.get("critical_path_ns", 0.0) for record in constrained
                ),
                "setup_violating_paths": int(
                    max(record.get("violating_paths", 0.0) for record in constrained)
                ),
            }
        )

    hold_values = [
        record["hold_slack_ns"]
        for record in records
        if record.get("hold_slack_ns") is not None
    ]
    if hold_values:
        result["worst_hold_slack_ns"] = min(hold_values)

    hold_path_values = [
        record["hold_violating_paths"]
        for record in records
        if record.get("hold_violating_paths") is not None
    ]
    if hold_path_values:
        result["hold_violating_paths"] = int(max(hold_path_values))

    design_hold_match = re.search(
        rf"(?m)^\s*Design \(Hold\).*?WNS:\s*({FLOAT_PATTERN}).*?"
        rf"Number of Violating Paths:\s*({FLOAT_PATTERN})\s*$",
        text,
    )
    if design_hold_match:
        design_hold_wns = as_float(design_hold_match.group(1)) or 0.0
        design_hold_paths = int(as_float(design_hold_match.group(2)) or 0)
        result["worst_hold_slack_ns"] = (
            -abs(design_hold_wns) if design_hold_paths else 0.0
        )
        result["hold_violating_paths"] = design_hold_paths

    result["nets_with_violations"] = search_int(text, "Nets With Violations")
    result["max_transition_violations"] = search_int(
        text, "Max Trans Violations"
    )
    result["max_capacitance_violations"] = search_int(
        text, "Max Cap Violations"
    )

    result["compile_wall_time_s"] = search_float(text, "Overall Compile Wall Clock Time")
    return result


def parse_area(text: str) -> Dict[str, Any]:
    return {
        "cell_count": search_int(text, "Number of cells"),
        "combinational_cell_count": search_int(text, "Number of combinational cells"),
        "sequential_cell_count": search_int(text, "Number of sequential cells"),
        "combinational_area_um2": search_float(text, "Combinational area"),
        "sequential_area_um2": search_float(text, "Noncombinational area"),
        "total_cell_area_um2": search_float(text, "Total cell area"),
    }


def parse_power(text: str) -> Dict[str, Any]:
    candidates: List[Dict[str, Any]] = []
    # Python 3.6 rejects re.split patterns that can match an empty string.
    for section in re.split(r"\n\s*Report\s*:\s*power\b", text):
        scenario_match = re.search(r"(?m)^Scenario\(s\):\s*(.+?)\s*$", section)
        top_match = re.search(
            rf"(?m)^TOP\s+({FLOAT_PATTERN})\s+({FLOAT_PATTERN})\s+"
            rf"({FLOAT_PATTERN})\s+({FLOAT_PATTERN})\s+100\.0\s*$",
            section,
        )
        if not top_match:
            continue
        switching, internal, leakage, total = map(as_float, top_match.groups())
        candidates.append(
            {
                "power_scenario": (
                    scenario_match.group(1).strip() if scenario_match else ""
                ),
                "switching_power_mw": switching,
                "internal_power_mw": internal,
                "leakage_power_uw": leakage,
                "total_power_mw": total,
            }
        )

    if not candidates:
        return {}
    return max(candidates, key=lambda item: item["total_power_mw"] or -math.inf)


def synthesis_status(run_dir: Path) -> str:
    reports_dir = run_dir / "reports"
    log_text = read_text(run_dir / "logs" / "all.log")
    required = (
        reports_dir / "TOP.mapped.qor.rpt",
        reports_dir / "TOP.mapped.area.rpt",
        reports_dir / "TOP.mapped.power.rpt",
        reports_dir / "TOP.mapped.timing.rpt",
        reports_dir / "TOP.check_design.rpt",
        reports_dir / "TOP.check_timing",
    )
    if not log_text and not any(path.exists() for path in required):
        return "MISSING"
    if re.search(r"(?m)^(?:Error:|RM-Error:|Fatal:)", log_text):
        return "FAIL"
    if not all(path.is_file() and path.stat().st_size > 0 for path in required):
        return "FAIL"

    for check_report in required[-2:]:
        if re.search(
            r"(?m)^(?:Error:|RM-Error:|Fatal:)", read_text(check_report)
        ):
            return "FAIL"

    qor = parse_qor(read_text(reports_dir / "TOP.mapped.qor.rpt"))
    required_qor_fields = (
        "setup_violating_paths",
        "hold_violating_paths",
        "nets_with_violations",
        "max_transition_violations",
        "max_capacitance_violations",
        "worst_setup_slack_ns",
        "worst_hold_slack_ns",
    )
    if any(qor.get(field) is None for field in required_qor_fields):
        return "FAIL"

    # Pre-layout hold is reported as an advisory; CTS/routing determines final hold.
    violation_fields = (
        "setup_violating_paths",
        "nets_with_violations",
        "max_transition_violations",
        "max_capacitance_violations",
    )
    if any(qor[field] > 0 for field in violation_fields):
        return "VIOLATIONS"
    if qor["worst_setup_slack_ns"] < 0:
        return "VIOLATIONS"
    return "PASS"


def parse_clock_period_ns(project_root: Path) -> Optional[float]:
    body = read_text(project_root / "SIM" / "TESTBENCH" / "TB_ARCHITECTURE_BODY.vh")
    match = re.search(r"parameter\s+integer\s+CLOCK_PERIOD\s*=\s*(\d+)", body)
    return as_float(match.group(1)) if match else None


def build_row(
    project_root: Path,
    architecture: str,
    testbench: str,
    recorded_status: Optional[Dict[str, str]],
    simulation_clock_period_ns: Optional[float],
) -> Dict[str, Any]:
    sim_run = project_root / "SIM" / "FUNCTION" / "runs" / architecture / testbench
    synth_run = project_root / "SYN_topo" / "runs" / architecture / testbench
    reports = synth_run / "reports"

    row: Dict[str, Any] = {
        "architecture": architecture,
        "testbench": testbench,
        "simulation_clock_period_ns": simulation_clock_period_ns,
    }
    row.update(parse_simulation_metrics(sim_run))
    row.update(parse_qor(read_text(reports / "TOP.mapped.qor.rpt")))
    row.update(parse_area(read_text(reports / "TOP.mapped.area.rpt")))
    row.update(parse_power(read_text(reports / "TOP.mapped.power.rpt")))
    row["synthesis_status"] = synthesis_status(synth_run)

    if recorded_status:
        if recorded_status.get("simulation_status") in {"FAIL", "SKIPPED"}:
            row["simulation_status"] = recorded_status["simulation_status"]
        if recorded_status.get("synthesis_status") in {"FAIL", "SKIPPED"}:
            row["synthesis_status"] = recorded_status["synthesis_status"]

    average_cycles = row.get("average_set_latency_cycles")
    if average_cycles is not None and simulation_clock_period_ns is not None:
        row["average_set_latency_sim_ns"] = average_cycles * simulation_clock_period_ns

    min_period = row.get("estimated_min_period_ns")
    if average_cycles is not None and min_period is not None:
        row["average_set_latency_at_fmax_ns"] = average_cycles * min_period

    power_mw = row.get("total_power_mw")
    sim_latency_ns = row.get("average_set_latency_sim_ns")
    if power_mw is not None and sim_latency_ns is not None:
        # mW * ns equals pJ. This uses the same time base as the SAIF activity.
        row["estimated_energy_per_set_pj"] = power_mw * sim_latency_ns

    return row


CSV_FIELDS = (
    "architecture",
    "testbench",
    "simulation_status",
    "synthesis_status",
    "samples",
    "sets",
    "cycles",
    "end_to_end_latency_cycles",
    "average_set_latency_cycles",
    "simulation_clock_period_ns",
    "average_set_latency_sim_ns",
    "average_set_latency_at_fmax_ns",
    "target_period_ns",
    "worst_setup_slack_ns",
    "estimated_min_period_ns",
    "estimated_max_frequency_mhz",
    "critical_path_ns",
    "limiting_path_group",
    "timing_scenario",
    "setup_violating_paths",
    "worst_hold_slack_ns",
    "hold_violating_paths",
    "nets_with_violations",
    "max_transition_violations",
    "max_capacitance_violations",
    "cell_count",
    "combinational_cell_count",
    "sequential_cell_count",
    "combinational_area_um2",
    "sequential_area_um2",
    "total_cell_area_um2",
    "switching_power_mw",
    "internal_power_mw",
    "leakage_power_uw",
    "total_power_mw",
    "power_scenario",
    "estimated_energy_per_set_pj",
    "input_stall_cycles",
    "buffer_full_cycles",
    "output_pairs",
    "output_pairs_per_set",
    "x_output_pulses",
    "d_output_pulses",
    "output_toggles",
    "expected_events",
    "golden_errors",
    "errors",
    "compile_wall_time_s",
)


def csv_value(value: Any) -> Any:
    if isinstance(value, float):
        return f"{value:.6f}"
    return "" if value is None else value


def write_csv(path: Path, rows: Iterable[Dict[str, Any]]) -> None:
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=CSV_FIELDS, extrasaction="ignore")
        writer.writeheader()
        for row in rows:
            writer.writerow({field: csv_value(row.get(field)) for field in CSV_FIELDS})


def display(value: Any, digits: int = 2) -> str:
    if value is None or value == "":
        return "-"
    if isinstance(value, float):
        return f"{value:.{digits}f}"
    return str(value)


def markdown_table(headers: List[str], rows: List[List[str]]) -> str:
    lines = [
        "| " + " | ".join(headers) + " |",
        "| " + " | ".join("---" for _ in headers) + " |",
    ]
    lines.extend("| " + " | ".join(row) + " |" for row in rows)
    return "\n".join(lines)


def write_markdown(path: Path, rows: List[Dict[str, Any]]) -> None:
    overview = []
    timing_area = []
    activity = []
    for row in rows:
        overview.append(
            [
                row["architecture"],
                display(row.get("simulation_status")),
                display(row.get("synthesis_status")),
                display(row.get("estimated_max_frequency_mhz")),
                display(row.get("total_cell_area_um2")),
                display(row.get("total_power_mw"), 4),
                display(row.get("average_set_latency_cycles")),
                display(row.get("estimated_energy_per_set_pj")),
            ]
        )
        timing_area.append(
            [
                row["architecture"],
                display(row.get("target_period_ns")),
                display(row.get("worst_setup_slack_ns")),
                display(row.get("estimated_min_period_ns")),
                display(row.get("worst_hold_slack_ns")),
                display(row.get("setup_violating_paths"), 0),
                display(row.get("hold_violating_paths"), 0),
                display(row.get("nets_with_violations"), 0),
                display(row.get("limiting_path_group")),
                display(row.get("cell_count"), 0),
                display(row.get("total_cell_area_um2")),
            ]
        )
        activity.append(
            [
                row["architecture"],
                display(row.get("sets"), 0),
                display(row.get("cycles"), 0),
                display(row.get("average_set_latency_cycles")),
                display(row.get("average_set_latency_sim_ns")),
                display(row.get("average_set_latency_at_fmax_ns")),
                display(row.get("output_pairs_per_set")),
                display(row.get("expected_events"), 0),
                display(row.get("golden_errors"), 0),
                display(row.get("total_power_mw"), 4),
            ]
        )

    generated = datetime.now().astimezone().isoformat(timespec="seconds")
    sections = [
        "# Architecture Summary",
        "",
        f"Generated: `{generated}`",
        "",
        "The maximum frequency is estimated from the limiting constrained path as "
        "`1000 / (target period - setup slack)` MHz. Energy per set uses the reported "
        "SAIF-based total power and functional-simulation time base.",
        "A synthesis status of `VIOLATIONS` means Design Compiler completed and all "
        "reports exist, but setup, transition, or capacitance checks are not clean. "
        "Pre-layout hold results remain visible as advisories for the later CTS/routing flow.",
        "",
        "## Overview",
        "",
        markdown_table(
            [
                "Architecture",
                "SIM",
                "SYN",
                "Fmax MHz",
                "Cell area um^2",
                "Power mW",
                "Cycles/set",
                "Energy pJ/set",
            ],
            overview,
        ),
        "",
        "## Timing And Area",
        "",
        markdown_table(
            [
                "Architecture",
                "Target ns",
                "Setup slack ns",
                "Estimated min ns",
                "Hold slack ns",
                "Setup viol.",
                "Hold viol.",
                "DRC nets",
                "Limiting group",
                "Cells",
                "Cell area um^2",
            ],
            timing_area,
        ),
        "",
        "## Simulation And Activity",
        "",
        markdown_table(
            [
                "Architecture",
                "Sets",
                "Total cycles",
                "Cycles/set",
                "Latency at SIM ns",
                "Latency at Fmax ns",
                "Pairs/set",
                "Golden events",
                "Golden errors",
                "Power mW",
            ],
            activity,
        ),
        "",
        "The full metric set, scenarios, and raw precision are available in `summary.csv`.",
        "",
    ]
    path.write_text("\n".join(sections), encoding="utf-8")


def print_terminal_table(rows: List[Dict[str, Any]]) -> None:
    headers = (
        "Architecture",
        "SIM",
        "SYN",
        "Fmax MHz",
        "Area um^2",
        "Power mW",
        "Cycles/set",
    )
    table_rows = [
        (
            row["architecture"],
            display(row.get("simulation_status")),
            display(row.get("synthesis_status")),
            display(row.get("estimated_max_frequency_mhz")),
            display(row.get("total_cell_area_um2")),
            display(row.get("total_power_mw"), 4),
            display(row.get("average_set_latency_cycles")),
        )
        for row in rows
    ]
    widths = [len(header) for header in headers]
    for table_row in table_rows:
        for index, value in enumerate(table_row):
            widths[index] = max(widths[index], len(value))

    def format_row(values: Iterable[str]) -> str:
        return "  ".join(
            value.ljust(widths[index]) for index, value in enumerate(values)
        )

    print(format_row(headers))
    print(format_row(tuple("-" * width for width in widths)))
    for table_row in table_rows:
        print(format_row(table_row))


def main() -> int:
    args = parse_args()
    project_root = args.project_root.resolve()
    output_dir = args.output_dir.resolve()
    status_path = output_dir / "run_status.csv"

    if not (project_root / "SYN_topo").is_dir() or not (
        project_root / "SIM" / "FUNCTION"
    ).is_dir():
        print(f"ERROR: Invalid project root: {project_root}", file=sys.stderr)
        return 2

    output_dir.mkdir(parents=True, exist_ok=True)
    status_records = load_run_status(status_path)
    run_keys = discover_runs(project_root, status_records)
    simulation_clock_period_ns = parse_clock_period_ns(project_root)
    rows = [
        build_row(
            project_root,
            architecture,
            testbench,
            status_records.get((architecture, testbench)),
            simulation_clock_period_ns,
        )
        for architecture, testbench in run_keys
    ]

    write_csv(output_dir / "summary.csv", rows)
    write_markdown(output_dir / "summary.md", rows)

    if rows:
        print_terminal_table(rows)
    else:
        print("No simulation or synthesis runs were found.")
    print(f"Summary written to: {output_dir / 'summary.md'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
