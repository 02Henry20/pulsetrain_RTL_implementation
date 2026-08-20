#!/usr/bin/env python3
"""Aggregate replay latency and no-SAIF synthesis reports."""

from __future__ import annotations

import argparse
import csv
import math
import re
import statistics
from pathlib import Path


FLOAT = r"[-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?"


def args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--architectures", nargs="+", required=True)
    parser.add_argument("--pulse-times", nargs="+", type=int, required=True)
    parser.add_argument("--baseline", required=True)
    parser.add_argument("--per-update-dir", type=Path, required=True)
    parser.add_argument("--synth-root", type=Path, required=True)
    parser.add_argument("--trace-stats", type=Path, required=True)
    parser.add_argument("--run-status", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument("--trace", required=True)
    parser.add_argument("--dimension", type=int, required=True)
    parser.add_argument("--max-bl", type=int, required=True)
    parser.add_argument("--clock-ns", type=float, required=True)
    parser.add_argument("--seed", required=True)
    parser.add_argument("--target-period-ns", type=float, required=True)
    return parser.parse_args()


def percentile(values: list[float], fraction: float) -> float:
    ordered = sorted(values)
    if len(ordered) == 1:
        return ordered[0]
    point = (len(ordered) - 1) * fraction
    lower = math.floor(point)
    upper = math.ceil(point)
    if lower == upper:
        return ordered[lower]
    return ordered[lower] + (ordered[upper] - ordered[lower]) * (point - lower)


def fmt(value: object, digits: int = 3) -> str:
    if value is None or value == "":
        return ""
    if isinstance(value, float):
        return f"{value:.{digits}f}"
    return str(value)


def read_key_values(path: Path) -> dict[str, str]:
    with path.open(newline="", encoding="utf-8") as handle:
        rows = csv.DictReader(handle)
        return {row["metric"]: row["value"] for row in rows}


def read_status(path: Path) -> dict[tuple[str, str, str], str]:
    if not path.is_file():
        return {}
    with path.open(newline="", encoding="utf-8") as handle:
        return {
            (row["stage"], row["architecture"], row["pulse_time_ns"]): row["status"]
            for row in csv.DictReader(handle)
        }


def parse_simulation(path: Path) -> dict[str, object]:
    if not path.is_file():
        return {"simulation_status": "FAIL", "updates": 0, "errors": 1}
    with path.open(newline="", encoding="utf-8") as handle:
        rows = list(csv.DictReader(handle))
    if not rows:
        return {"simulation_status": "FAIL", "updates": 0, "errors": 1}

    bl = [float(row["input_bl"]) for row in rows]
    output = [float(row["output_pulse_positions"]) for row in rows]
    latency = [float(row["latency_ns"]) for row in rows]
    errors = sum(int(row["errors"]) for row in rows)
    bypass = sum(int(row["group_mask_bypass"]) for row in rows)
    mean_bl = statistics.fmean(bl)
    mean_output = statistics.fmean(output)
    return {
        "simulation_status": "PASS" if errors == 0 else "FAIL",
        "updates": len(rows),
        "mean_input_bl": mean_bl,
        "mean_output_pulse_positions": mean_output,
        "pulse_position_reduction": 1.0 - mean_output / mean_bl,
        "mean_latency_ns": statistics.fmean(latency),
        "median_latency_ns": statistics.median(latency),
        "std_latency_ns": statistics.pstdev(latency),
        "p95_latency_ns": percentile(latency, 0.95),
        "errors": errors,
        "group_mask_bypass_updates": bypass,
    }


def first_number(text: str, label: str) -> float | None:
    match = re.search(rf"{re.escape(label)}\s*:\s*({FLOAT})", text, re.IGNORECASE)
    return float(match.group(1)) if match else None


def slacks(paths: list[Path]) -> list[tuple[str, float]]:
    found: list[tuple[str, float]] = []
    pattern = re.compile(rf"slack\s*\((MET|VIOLATED)\)\s*({FLOAT})", re.IGNORECASE)
    for path in paths:
        text = path.read_text(errors="ignore")
        found.extend((state.upper(), float(value)) for state, value in pattern.findall(text))
    return found


def parse_synthesis(root: Path, architecture: str, target: float) -> dict[str, object]:
    reports = root / architecture / "no_saif" / "reports"
    area_files = list(reports.glob("*mapped.area.rpt")) if reports.is_dir() else []
    max_files = list(reports.glob("*.timing_max.rpt"))
    min_files = list(reports.glob("*.timing_min.rpt"))
    constraint_files = list(reports.glob("*.constraints.rpt"))
    if not area_files:
        return {
            "synthesis_status": "FAIL", "setup_status": "NOT_RUN",
            "drc_status": "NOT_RUN", "hold_advisory": "NOT_RUN",
            "target_period_ns": target,
        }

    area_text = "\n".join(path.read_text(errors="ignore") for path in area_files)
    total_area = first_number(area_text, "Total cell area")
    cell_count = first_number(area_text, "Number of cells")
    comb_area = first_number(area_text, "Combinational area")
    seq_area = first_number(area_text, "Noncombinational area")

    setup_slacks = slacks(max_files)
    hold_slacks = slacks(min_files)
    worst_setup = min((value for _, value in setup_slacks), default=None)
    worst_hold = min((value for _, value in hold_slacks), default=None)
    setup_violations = sum(1 for state, value in setup_slacks if state == "VIOLATED" or value < 0)

    drc_violations = 0
    for path in constraint_files:
        for line in path.read_text(errors="ignore").splitlines():
            lowered = line.lower()
            if ("max_transition" in lowered or "max_capacitance" in lowered) and "violated" in lowered:
                drc_violations += 1

    setup_status = "UNKNOWN" if worst_setup is None else ("PASS" if setup_violations == 0 else "FAIL")
    drc_status = "UNKNOWN" if not constraint_files else ("PASS" if drc_violations == 0 else "FAIL")
    hold_status = "UNKNOWN" if worst_hold is None else ("PASS" if worst_hold >= 0 else "VIOLATED")
    estimated_period = None if worst_setup is None else target - worst_setup
    qualified = setup_status == "PASS" and drc_status == "PASS" and estimated_period and estimated_period > 0
    fmax = 1000.0 / estimated_period if qualified else None

    return {
        "synthesis_status": "PASS",
        "total_cell_area_um2": total_area,
        "cell_count": int(cell_count) if cell_count is not None else None,
        "combinational_area_um2": comb_area,
        "sequential_area_um2": seq_area,
        "target_period_ns": target,
        "worst_setup_slack_ns": worst_setup,
        "setup_violation_count": setup_violations,
        "estimated_min_period_ns": estimated_period,
        "estimated_fmax_mhz": fmax,
        "setup_status": setup_status,
        "drc_status": drc_status,
        "drc_violation_count": drc_violations,
        "worst_hold_slack_ns": worst_hold,
        "hold_advisory": hold_status,
    }


def write_csv(path: Path, rows: list[dict[str, object]], fields: list[str]) -> None:
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields, lineterminator="\n")
        writer.writeheader()
        for row in rows:
            writer.writerow({field: fmt(row.get(field)) for field in fields})


def markdown_table(fields: list[str], labels: list[str], rows: list[dict[str, object]]) -> list[str]:
    lines = ["| " + " | ".join(labels) + " |", "| " + " | ".join(["---"] * len(fields)) + " |"]
    for row in rows:
        cells: list[str] = []
        for field in fields:
            value = row.get(field)
            if field in {"relative_latency_saving", "pulse_position_reduction", "normalized_area_vs_baseline"} and isinstance(value, float):
                cells.append(f"{100.0 * value:.2f}%" if field != "normalized_area_vs_baseline" else f"{value:.3f}x")
            else:
                cells.append(fmt(value))
        lines.append("| " + " | ".join(cells) + " |")
    return lines


def main() -> int:
    options = args()
    options.output_dir.mkdir(parents=True, exist_ok=True)
    trace_stats = read_key_values(options.trace_stats)
    statuses = read_status(options.run_status)

    synth_rows = [parse_synthesis(options.synth_root, arch, options.target_period_ns) | {"architecture": arch} for arch in options.architectures]
    baseline_area = next((row.get("total_cell_area_um2") for row in synth_rows if row["architecture"] == options.baseline), None)
    for row in synth_rows:
        area = row.get("total_cell_area_um2")
        row["normalized_area_vs_baseline"] = area / baseline_area if area and baseline_area else None

    latency_rows: list[dict[str, object]] = []
    for arch in options.architectures:
        for pulse in options.pulse_times:
            row = parse_simulation(options.per_update_dir / f"{arch}_{pulse}ns.csv")
            row.update({"architecture": arch, "pulse_time_ns": pulse})
            if statuses.get(("simulation", arch, str(pulse))) != "PASS":
                row["simulation_status"] = "FAIL"
            latency_rows.append(row)

    baseline_latency = {
        row["pulse_time_ns"]: row.get("mean_latency_ns")
        for row in latency_rows if row["architecture"] == options.baseline
    }
    for row in latency_rows:
        base = baseline_latency.get(row["pulse_time_ns"])
        mean = row.get("mean_latency_ns")
        row["relative_latency_saving"] = 1.0 - mean / base if base and mean else None
        row["speedup"] = base / mean if base and mean else None

    synth_by_arch = {row["architecture"]: row for row in synth_rows}
    summary_rows = [row | synth_by_arch[row["architecture"]] for row in latency_rows]

    latency_fields = [
        "architecture", "pulse_time_ns", "updates", "mean_input_bl",
        "mean_output_pulse_positions", "pulse_position_reduction",
        "mean_latency_ns", "median_latency_ns", "std_latency_ns",
        "p95_latency_ns", "relative_latency_saving", "speedup",
        "simulation_status", "errors", "group_mask_bypass_updates",
    ]
    synth_fields = [
        "architecture", "total_cell_area_um2", "normalized_area_vs_baseline",
        "cell_count", "combinational_area_um2", "sequential_area_um2",
        "target_period_ns", "worst_setup_slack_ns", "setup_violation_count",
        "estimated_min_period_ns", "estimated_fmax_mhz", "setup_status",
        "drc_status", "drc_violation_count", "worst_hold_slack_ns",
        "hold_advisory", "synthesis_status",
    ]
    write_csv(options.output_dir / "latency.csv", latency_rows, latency_fields)
    write_csv(options.output_dir / "synthesis.csv", synth_rows, synth_fields)
    write_csv(options.output_dir / "summary.csv", summary_rows, latency_fields + synth_fields[1:])

    latency_md_fields = [
        "architecture", "pulse_time_ns", "mean_latency_ns", "median_latency_ns",
        "p95_latency_ns", "std_latency_ns", "relative_latency_saving",
        "mean_output_pulse_positions", "pulse_position_reduction",
    ]
    synth_md_fields = [
        "architecture", "total_cell_area_um2", "normalized_area_vs_baseline",
        "estimated_fmax_mhz", "target_period_ns", "setup_status",
        "drc_status", "hold_advisory",
    ]
    report = [
        "# Experiment Summary", "", "## Experiment Configuration", "",
        f"- Trace: `{options.trace}`",
        f"- Recorded updates: {trace_stats['updates']}",
        f"- Crossbar dimension: {options.dimension}",
        f"- MAX_BL: {options.max_bl}",
        f"- Digital clock: {fmt(options.clock_ns)} ns ({1000.0 / options.clock_ns:.3f} MHz)",
        f"- Pulse-time sweep: {', '.join(str(v) + ' ns' for v in options.pulse_times)}",
        f"- Baseline architecture: `{options.baseline}`",
        f"- LFSR seed: `{options.seed}`", "",
        f"Input BL min/mean/median/max: {trace_stats['min_bl']} / {float(trace_stats['mean_bl']):.3f} / {float(trace_stats['median_bl']):.3f} / {trace_stats['max_observed_bl']}",
        "", "## System Latency", "",
        *markdown_table(latency_md_fields,
            ["Architecture", "T_pulse ns", "Mean ns", "Median ns", "P95 ns", "Std ns", "Saving", "Mean BLout", "Reduction"], latency_rows),
        "", "## Synthesis", "",
        "Area is post-synthesis standard-cell area. Fmax is reported only when setup and transition/capacitance DRC qualify.", "",
        *markdown_table(synth_md_fields,
            ["Architecture", "Area um2", "Area/base", "Fmax est. MHz", "Target ns", "Setup", "DRC", "Hold advisory"], synth_rows),
        "", "## Validation", "",
        "| Architecture | Pulse ns | Simulation | Updates | Errors | Group-mask bypass updates |",
        "| --- | --- | --- | --- | --- | --- |",
    ]
    report.extend(
        f"| {row['architecture']} | {row['pulse_time_ns']} | {row['simulation_status']} | {row['updates']} | {row['errors']} | {row['group_mask_bypass_updates']} |"
        for row in latency_rows
    )
    (options.output_dir / "summary.md").write_text("\n".join(report) + "\n", encoding="utf-8")

    print("\nArchitecture                     Pulse(ns) Updates   Mean(ns)    P95(ns)   Saving   Mean BLout")
    for row in latency_rows:
        saving = row.get("relative_latency_saving")
        print(f"{row['architecture']:<32} {row['pulse_time_ns']:>9} {row['updates']:>7} "
              f"{fmt(row.get('mean_latency_ns')):>10} {fmt(row.get('p95_latency_ns')):>10} "
              f"{(f'{100*saving:.1f}%' if isinstance(saving, float) else '-'):>8} "
              f"{fmt(row.get('mean_output_pulse_positions')):>10}")
    print("\nArchitecture                     Area um2   Fmax est MHz   Setup       DRC")
    for row in synth_rows:
        print(f"{row['architecture']:<32} {fmt(row.get('total_cell_area_um2')):>10} "
              f"{fmt(row.get('estimated_fmax_mhz')):>14} {row['setup_status']:>9} {row['drc_status']:>9}")

    failed = any(row["simulation_status"] != "PASS" for row in latency_rows)
    failed |= any(statuses.get(("synthesis", arch, "")) != "PASS" for arch in options.architectures)
    failed |= any(row.get("synthesis_status") != "PASS" for row in synth_rows)
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
