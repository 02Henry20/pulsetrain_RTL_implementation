#!/usr/bin/env python3
"""Aggregate multi-input replay latency, synthesis, and SAIF energy reports."""

import argparse
import csv
import json
import math
import re
import statistics
from pathlib import Path


FLOAT = r"[-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?"


def args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--plan", type=Path, required=True)
    parser.add_argument("--per-update-dir", type=Path, required=True)
    parser.add_argument("--synth-root", type=Path, required=True)
    parser.add_argument("--work-dir", type=Path, required=True)
    parser.add_argument("--run-status", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument("--clock-ns", type=float, required=True)
    parser.add_argument("--seed", required=True)
    parser.add_argument("--target-period-ns", type=float, required=True)
    return parser.parse_args()


def percentile(values, fraction):
    ordered = sorted(values)
    if len(ordered) == 1:
        return ordered[0]
    point = (len(ordered) - 1) * fraction
    lower = math.floor(point)
    upper = math.ceil(point)
    if lower == upper:
        return ordered[lower]
    return ordered[lower] + (ordered[upper] - ordered[lower]) * (point - lower)


def fmt(value, digits=3):
    if value is None or value == "":
        return ""
    if isinstance(value, float):
        return f"{value:.{digits}f}"
    return str(value)


def read_key_values(path):
    if not path.is_file():
        return {}
    try:
        with path.open(newline="", encoding="utf-8") as handle:
            rows = list(csv.DictReader(handle))
        if not rows or any(
            not isinstance(row, dict) or "metric" not in row or "value" not in row
            for row in rows
        ):
            return {}
        metrics = [row["metric"] for row in rows]
        if any(metric in (None, "") for metric in metrics) or len(set(metrics)) != len(metrics):
            return {}
        return {row["metric"]: row["value"] for row in rows}
    except (OSError, csv.Error, UnicodeError):
        return {}


def read_status(path):
    if not path.is_file():
        return {}
    try:
        with path.open(newline="", encoding="utf-8") as handle:
            rows = list(csv.DictReader(handle))
        statuses = {}
        for row in rows:
            key = (
                row["stage"], row.get("input_id", ""), row["architecture"],
                row["pulse_time_ns"],
            )
            if key in statuses or row["status"] not in {"PASS", "FAIL", "SKIP"}:
                return {}
            statuses[key] = row["status"]
        return statuses
    except (OSError, csv.Error, KeyError, TypeError, UnicodeError):
        return {}


def failed_simulation_result():
    return {
        "simulation_status": "FAIL", "updates": 0, "errors": 1,
        "group_mask_bypass_updates": 0,
    }


def parse_simulation(path):
    if not path.is_file():
        return failed_simulation_result()
    try:
        with path.open(newline="", encoding="utf-8") as handle:
            rows = list(csv.DictReader(handle))
        if not rows:
            return failed_simulation_result()
        bl = [float(row["input_bl"]) for row in rows]
        output = [float(row["output_pulse_positions"]) for row in rows]
        latency = [float(row["latency_ns"]) for row in rows]
        errors = sum(int(row["errors"]) for row in rows)
        bypass = sum(int(row["group_mask_bypass"]) for row in rows)
    except (OSError, csv.Error, KeyError, TypeError, ValueError):
        return failed_simulation_result()
    numeric_values = bl + output + latency
    if (
        not all(math.isfinite(value) for value in numeric_values)
        or any(value <= 0 for value in bl)
        or any(value < 0 for value in output + latency)
        or errors < 0
        or bypass < 0
    ):
        return failed_simulation_result()
    mean_bl = statistics.mean(bl)
    mean_output = statistics.mean(output)
    return {
        "simulation_status": "PASS" if errors == 0 else "FAIL",
        "updates": len(rows),
        "mean_input_bl": mean_bl,
        "mean_output_pulse_positions": mean_output,
        "pulse_position_reduction": 1.0 - mean_output / mean_bl,
        "mean_latency_ns": statistics.mean(latency),
        "median_latency_ns": statistics.median(latency),
        "std_latency_ns": statistics.pstdev(latency),
        "p95_latency_ns": percentile(latency, 0.95),
        "errors": errors,
        "group_mask_bypass_updates": bypass,
    }


def first_number(text, label):
    match = re.search(rf"{re.escape(label)}\s*:\s*({FLOAT})", text, re.IGNORECASE)
    return float(match.group(1)) if match else None


TIME_UNITS_NS = {
    "fs": 1e-6, "ps": 1e-3, "ns": 1.0, "us": 1e3, "ms": 1e6, "s": 1e9,
}


def parse_saif_duration_ns(path):
    if not path.is_file():
        return None
    timescale_ns = 1.0
    duration = None
    try:
        text = path.read_text(errors="ignore")
    except OSError:
        return None
    match = re.search(
        r"\(TIMESCALE\s+([0-9.]+)\s*([A-Za-z]+)\)", text, re.IGNORECASE
    )
    if match:
        unit_scale = TIME_UNITS_NS.get(match.group(2).lower())
        if unit_scale is None:
            return None
        timescale_ns = float(match.group(1)) * unit_scale
    match = re.search(r"\(DURATION\s+([0-9.+-eE]+)\)", text, re.IGNORECASE)
    if match:
        duration = float(match.group(1))
    if duration is None:
        return None
    return duration * timescale_ns


POWER_UNITS_W = {
    "pw": 1e-12, "nw": 1e-9, "uw": 1e-6, "mw": 1e-3, "w": 1.0, "kw": 1e3,
}


def parse_power_report(path):
    if not path.is_file():
        return {}
    try:
        text = path.read_text(errors="ignore")
    except OSError:
        return {}

    def to_watts(num, unit):
        scale = POWER_UNITS_W.get(unit.lower())
        if scale is None:
            return None
        return float(num) * scale

    def grab(label):
        match = re.search(
            rf"{re.escape(label)}\s*=\s*({FLOAT})\s*([pnumk]?W)",
            text, re.IGNORECASE,
        )
        if not match:
            return None
        return to_watts(match.group(1), match.group(2))

    values = {
        "cell_internal_power_w": grab("Cell Internal Power"),
        "net_switching_power_w": grab("Net Switching Power"),
        "dynamic_power_w": grab("Total Dynamic Power"),
        "leakage_power_w": grab("Cell Leakage Power"),
        "total_power_w": grab("Total Power"),
    }
    if all(value is not None for value in values.values()):
        return values
    match = re.search(
        rf"(?m)^Total\s+({FLOAT})\s*([pnumk]?W)\s+({FLOAT})\s*([pnumk]?W)\s+"
        rf"({FLOAT})\s*([pnumk]?W)\s+({FLOAT})\s*([pnumk]?W)",
        text,
        re.IGNORECASE,
    )
    if not match:
        return values
    internal = to_watts(match.group(1), match.group(2))
    switching = to_watts(match.group(3), match.group(4))
    leakage = to_watts(match.group(5), match.group(6))
    total = to_watts(match.group(7), match.group(8))
    dynamic = None if internal is None or switching is None else internal + switching
    return {
        "cell_internal_power_w": values["cell_internal_power_w"] if values["cell_internal_power_w"] is not None else internal,
        "net_switching_power_w": values["net_switching_power_w"] if values["net_switching_power_w"] is not None else switching,
        "dynamic_power_w": values["dynamic_power_w"] if values["dynamic_power_w"] is not None else dynamic,
        "leakage_power_w": values["leakage_power_w"] if values["leakage_power_w"] is not None else leakage,
        "total_power_w": values["total_power_w"] if values["total_power_w"] is not None else total,
    }


def read_first_row(path):
    if not path.is_file():
        return {}
    try:
        with path.open(newline="", encoding="utf-8") as handle:
            rows = list(csv.DictReader(handle))
        return rows[0] if rows else {}
    except (OSError, csv.Error, UnicodeError, IndexError):
        return {}


def parse_clock_gating(reports):
    values = read_key_values(reports / "clock_gating.summary.csv")
    cells = values.get("clock_gating_cells")
    gated = values.get("gated_registers")
    ungated = values.get("ungated_registers")
    parsed = {
        "clock_gating_cells": None,
        "gated_registers": None,
        "ungated_registers": None,
        "gated_register_percent": None,
    }
    try:
        parsed["clock_gating_cells"] = int(float(cells)) if cells not in (None, "") else None
        parsed["gated_registers"] = int(float(gated)) if gated not in (None, "") else None
        parsed["ungated_registers"] = int(float(ungated)) if ungated not in (None, "") else None
    except (TypeError, ValueError):
        return parsed
    parsed["icg_ref_names"] = values.get("icg_ref_names") or None
    try:
        area = values.get("icg_cell_area")
        parsed["icg_cell_area_um2"] = float(area) if area not in (None, "") else None
    except (TypeError, ValueError):
        parsed["icg_cell_area_um2"] = None
    rng = read_key_values(reports / "rng_clock_gating.summary.csv")
    if rng:
        values.update(rng)
    parsed["rng_registers_total"] = None
    parsed["rng_registers_gated"] = None
    parsed["rng_registers_ungated"] = None
    parsed["rng_gating_percent"] = None
    parsed["rng_icg_cells"] = None
    parsed["rng_icg_ref_names"] = values.get("rng_icg_ref_names") or None
    parsed["rng_clock_gating_status"] = values.get("rng_clock_gating_status") or None
    try:
        for key in (
            "rng_registers_total", "rng_registers_gated",
            "rng_registers_ungated", "rng_icg_cells",
        ):
            raw = values.get(key)
            parsed[key] = int(float(raw)) if raw not in (None, "") else None
        pct = values.get("rng_gating_percent")
        parsed["rng_gating_percent"] = (
            float(pct) if pct not in (None, "") else None
        )
    except (TypeError, ValueError):
        pass
    total = (parsed["gated_registers"] or 0) + (parsed["ungated_registers"] or 0)
    if parsed["gated_registers"] is not None and total > 0:
        parsed["gated_register_percent"] = 100.0 * parsed["gated_registers"] / total
    return parsed


def parse_power_summary(path):
    values = read_key_values(path)
    if not values:
        return {}
    parsed = dict(values)
    for key in (
        "pulse_time_ns", "clock_period_ns", "saif_duration_ns",
        "cell_internal_power_w", "net_switching_power_w", "dynamic_power_w",
        "leakage_power_w", "total_power_w", "annotated_percent",
        "lfsr_registers_total", "lfsr_registers_toggle_nonzero",
        "lfsr_registers_annotated", "lfsr_registers_default_zero",
    ):
        if key in parsed and parsed[key] != "":
            try:
                parsed[key] = float(parsed[key])
            except ValueError:
                parsed[key] = None
        else:
            parsed.setdefault(key, None)
    return parsed


def parse_energy(root, input_id, architecture, pulse, stats):
    failed = {
        "energy_status": "FAIL", "power_mw": None, "leakage_power_mw": None,
        "dynamic_power_mw": None, "tb_energy_nj": None,
        "energy_per_pulse_pj": None, "saif_duration_ns": None,
        "total_pulses": None, "annotated_percent": None,
        "power_error": "missing_power_summary",
        "energy_per_update_nj": None, "internal_power_mw": None,
        "source_fire_count": None, "source_fire_duty": None,
        "saif_clk_cycles": None, "rng_gated_cycles": None,
        "lfsr_registers_total": None, "lfsr_registers_toggle_nonzero": None,
        "lfsr_registers_annotated": None,
    }
    try:
        total_pulses = int(float(stats.get("total_pulses", 0)))
    except (TypeError, ValueError):
        total_pulses = 0
    failed["total_pulses"] = total_pulses
    summary = (
        root / input_id / architecture / "no_saif" / "reports" / "power" /
        f"{pulse}ns.summary.csv"
    )
    values = parse_power_summary(summary)
    if not values:
        return failed
    report_values = parse_power_report(summary.with_name(f"{pulse}ns.power.rpt"))
    for key, value in report_values.items():
        if values.get(key) in (None, "") and value is not None:
            values[key] = value
    total_w = values.get("total_power_w")
    duration_ns = values.get("saif_duration_ns")
    saif_file = values.get("saif_file")
    if duration_ns is None and saif_file:
        duration_ns = parse_saif_duration_ns(Path(saif_file))
    leakage_w = values.get("leakage_power_w")
    dynamic_w = values.get("dynamic_power_w")
    numbers_ok = (
        total_w is not None and math.isfinite(total_w) and total_w > 0 and
        duration_ns is not None and math.isfinite(duration_ns) and duration_ns > 0 and
        total_pulses > 0 and
        dynamic_w is not None and math.isfinite(dynamic_w) and
        leakage_w is not None and math.isfinite(leakage_w)
    )
    if values.get("status") != "PASS":
        failed["power_error"] = values.get("error") or "power_summary_failed"
        return failed
    if not numbers_ok:
        failed["power_error"] = values.get("error") or (
            "invalid_power_duration_or_pulse_count"
        )
        return failed
    energy_j = total_w * duration_ns * 1e-9
    try:
        updates = int(float(stats.get("updates", 0)))
    except (TypeError, ValueError):
        updates = 0
    return {
        "energy_status": "PASS",
        "power_mw": total_w * 1e3,
        "leakage_power_mw": None if leakage_w is None else leakage_w * 1e3,
        "dynamic_power_mw": None if dynamic_w is None else dynamic_w * 1e3,
        "tb_energy_nj": energy_j * 1e9,
        "energy_per_pulse_pj": energy_j * 1e12 / total_pulses,
        "saif_duration_ns": duration_ns,
        "total_pulses": total_pulses,
        "annotated_percent": values.get("annotated_percent"),
        "power_error": "",
        "energy_per_update_nj": None if updates <= 0 else energy_j * 1e9 / updates,
        "internal_power_mw": None if values.get("cell_internal_power_w") is None
            else values.get("cell_internal_power_w") * 1e3,
    }


def slacks(paths):
    found = []
    pattern = re.compile(rf"slack\s*\((MET|VIOLATED)\)\s*({FLOAT})", re.IGNORECASE)
    for path in paths:
        text = path.read_text(errors="ignore")
        found.extend((state.upper(), float(value)) for state, value in pattern.findall(text))
    return found


def parse_synthesis(root, input_id, architecture, target):
    reports = root / input_id / architecture / "no_saif" / "reports"
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
    if total_area is None or not math.isfinite(total_area) or total_area <= 0:
        return {
            "synthesis_status": "FAIL", "setup_status": "NOT_RUN",
            "drc_status": "NOT_RUN", "hold_advisory": "NOT_RUN",
            "target_period_ns": target,
        }

    setup_slacks = slacks(max_files)
    hold_slacks = slacks(min_files)
    worst_setup = min((value for _, value in setup_slacks), default=None)
    worst_hold = min((value for _, value in hold_slacks), default=None)
    setup_violations = sum(
        1 for state, value in setup_slacks if state == "VIOLATED" or value < 0
    )

    drc_violations = 0
    for path in constraint_files:
        for line in path.read_text(errors="ignore").splitlines():
            lowered = line.lower()
            if (
                ("max_transition" in lowered or "max_capacitance" in lowered)
                and "violated" in lowered
            ):
                drc_violations += 1

    setup_status = (
        "UNKNOWN" if worst_setup is None else
        ("PASS" if setup_violations == 0 else "FAIL")
    )
    drc_status = (
        "UNKNOWN" if not constraint_files else
        ("PASS" if drc_violations == 0 else "FAIL")
    )
    hold_status = (
        "UNKNOWN" if worst_hold is None else
        ("PASS" if worst_hold >= 0 else "VIOLATED")
    )
    estimated_period = None if worst_setup is None else target - worst_setup
    qualified = (
        setup_status == "PASS" and drc_status == "PASS" and
        estimated_period and estimated_period > 0
    )
    fmax = 1000.0 / estimated_period if qualified else None
    gating = parse_clock_gating(reports)
    rng_total = gating.get("rng_registers_total")
    rng_gated = gating.get("rng_registers_gated")
    rng_ungated = gating.get("rng_registers_ungated")
    gating_ok = (
        gating.get("clock_gating_cells") is not None and
        gating["clock_gating_cells"] > 0 and
        rng_total is not None and rng_total > 0 and
        rng_gated is not None and rng_ungated is not None and
        rng_ungated == 0 and rng_gated == rng_total
    )

    return {
        "synthesis_status": "PASS" if gating_ok else "FAIL",
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
        **gating,
    }


def write_csv(path, rows, fields, digits=3):
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields, lineterminator="\n")
        writer.writeheader()
        for row in rows:
            writer.writerow(
                {field: fmt(row.get(field), digits) for field in fields}
            )


def markdown_table(fields, labels, rows):
    lines = [
        "| " + " | ".join(labels) + " |",
        "| " + " | ".join(["---"] * len(fields)) + " |",
    ]
    for row in rows:
        cells = []
        for field in fields:
            value = row.get(field)
            if field in {
                "relative_latency_saving", "pulse_position_reduction",
                "normalized_area_vs_baseline",
            } and isinstance(value, float):
                cells.append(
                    f"{100.0 * value:.2f}%"
                    if field != "normalized_area_vs_baseline" else f"{value:.3f}x"
                )
            else:
                cells.append(fmt(value))
        lines.append("| " + " | ".join(cells) + " |")
    return lines


def job_common(job):
    return {
        "input_id": job["input_id"],
        "input_file": job["input_file_display"],
        "pulse_source": job["pulse_source"],
        "crossbar_dimension": job["crossbar_dimension"],
        "max_bl": job["max_bl"],
        "architecture": job["architecture"],
        "rng_family": job["rng_family"],
    }


def main():
    options = args()
    options.output_dir.mkdir(parents=True, exist_ok=True)
    try:
        plan = json.loads(options.plan.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise SystemExit(f"ERROR: cannot read experiment plan: {exc}") from exc
    if plan.get("schema_version") != 1:
        raise SystemExit("ERROR: unsupported experiment plan schema")

    inputs = plan.get("inputs", [])
    jobs = plan.get("jobs", [])
    statuses = read_status(options.run_status)
    trace_stats = {
        item["id"]: read_key_values(
            options.work_dir / item["id"] / "trace_stats.csv"
        )
        for item in inputs
    }

    synth_rows = []
    for job in jobs:
        if not job["run_synthesis"]:
            continue
        row = parse_synthesis(
            options.synth_root, job["input_id"], job["architecture"],
            options.target_period_ns,
        )
        row.update(job_common(job))
        synth_rows.append(row)

    baseline_area = {
        (job["input_id"]): next(
            (
                row.get("total_cell_area_um2") for row in synth_rows
                if row["input_id"] == job["input_id"]
                and row["architecture"] == job["architecture"]
                and row["synthesis_status"] == "PASS"
            ),
            None,
        )
        for job in jobs if job["run_synthesis"] and job["baseline"]
    }
    for row in synth_rows:
        area = row.get("total_cell_area_um2")
        base = baseline_area.get(row["input_id"])
        row["normalized_area_vs_baseline"] = area / base if area and base else None

    latency_rows = []
    for job in jobs:
        if not job["run_testbench"]:
            continue
        for pulse in job["pulse_times_ns"]:
            row = parse_simulation(
                options.per_update_dir / job["input_id"] /
                f"{job['architecture']}_{pulse}ns.csv"
            )
            row.update(job_common(job))
            row["pulse_time_ns"] = pulse
            if statuses.get(
                ("simulation", job["input_id"], job["architecture"], str(pulse))
            ) != "PASS":
                row["simulation_status"] = "FAIL"
            latency_rows.append(row)

    baseline_latency = {
        (row["input_id"], row["pulse_time_ns"]): row.get("mean_latency_ns")
        for row in latency_rows
        if row["simulation_status"] == "PASS" and any(
            job["input_id"] == row["input_id"]
            and job["architecture"] == row["architecture"]
            and job["baseline"]
            for job in jobs
        )
    }
    for row in latency_rows:
        base = baseline_latency.get((row["input_id"], row["pulse_time_ns"]))
        mean = row.get("mean_latency_ns")
        row["relative_latency_saving"] = 1.0 - mean / base if base and mean else None
        row["speedup"] = base / mean if base and mean else None

    energy_rows = []
    for job in jobs:
        if not (job["run_testbench"] and job["run_synthesis"]):
            continue
        stats = trace_stats.get(job["input_id"], {})
        for pulse in job["pulse_times_ns"]:
            row = parse_energy(
                options.synth_root, job["input_id"], job["architecture"],
                pulse, stats,
            )
            rng = read_first_row(
                options.per_update_dir / job["input_id"] /
                f"{job['architecture']}_{pulse}ns.rng.csv"
            )
            for key in (
                "saif_clk_cycles", "source_fire_count", "source_fire_duty",
                "rng_gated_cycles", "rng_active_cycles", "lfsr_advances",
                "lfsr_seq_errors", "shared_delay_errors",
            ):
                value = rng.get(key)
                if value not in (None, ""):
                    try:
                        row[key] = float(value) if "." in str(value) else int(value)
                    except ValueError:
                        row[key] = value
            cov = parse_power_summary(
                options.synth_root / job["input_id"] / job["architecture"] /
                "no_saif" / "reports" / "power" / f"{pulse}ns.rng_coverage.csv"
            )
            row["lfsr_registers_total"] = cov.get("lfsr_registers_total")
            row["lfsr_registers_annotated"] = cov.get("lfsr_registers_annotated")
            row["lfsr_registers_toggle_nonzero"] = cov.get("lfsr_registers_toggle_nonzero")
            row["lfsr_registers_default_zero"] = cov.get("lfsr_registers_default_zero")
            row.update(job_common(job))
            row["pulse_time_ns"] = pulse
            seq_err = rng.get("lfsr_seq_errors")
            delay_err = rng.get("shared_delay_errors")
            advances = rng.get("lfsr_advances")
            fires = rng.get("source_fire_count")
            rng_failed = (
                not rng or seq_err not in (None, "", "0", 0) or
                delay_err not in (None, "", "0", 0) or
                (advances not in (None, "") and fires not in (None, "") and
                 str(advances) != str(fires))
            )
            total_lfsr = row.get("lfsr_registers_total")
            annotated_lfsr = row.get("lfsr_registers_annotated")
            if annotated_lfsr in (None, ""):
                annotated_lfsr = row.get("lfsr_registers_toggle_nonzero")
            try:
                lfsr_unannotated = (
                    total_lfsr is not None and float(total_lfsr) > 0 and
                    (annotated_lfsr is None or float(annotated_lfsr) == 0)
                )
            except (TypeError, ValueError):
                lfsr_unannotated = False
            synth_status = statuses.get(
                ("synthesis", job["input_id"], job["architecture"], "")
            )
            power_status = statuses.get(
                ("power", job["input_id"], job["architecture"], str(pulse))
            )
            if statuses.get(
                ("simulation", job["input_id"], job["architecture"], str(pulse))
            ) != "PASS":
                row["energy_status"] = "FAIL"
                if not row.get("power_error"):
                    row["power_error"] = "simulation_stage_failed"
            elif synth_status != "PASS":
                row["energy_status"] = "FAIL"
                if not row.get("power_error"):
                    row["power_error"] = "synthesis_stage_failed"
            elif power_status == "FAIL":
                row["energy_status"] = "FAIL"
                if not row.get("power_error"):
                    row["power_error"] = "power_stage_failed"
            elif power_status == "SKIP":
                row["energy_status"] = "FAIL"
                if not row.get("power_error"):
                    row["power_error"] = "power_stage_skipped"
            elif power_status == "PASS":
                pass
            elif rng_failed:
                row["energy_status"] = "FAIL"
                if not row.get("power_error"):
                    row["power_error"] = "rng_sequence_or_stats_failed"
            elif lfsr_unannotated:
                row["energy_status"] = "FAIL"
                if not row.get("power_error"):
                    row["power_error"] = "lfsr_activity_unannotated"
            energy_rows.append(row)

    synth_by_job = {
        (row["input_id"], row["architecture"]): row for row in synth_rows
    }
    energy_by_job = {
        (row["input_id"], row["architecture"], row["pulse_time_ns"]): row
        for row in energy_rows
    }
    summary_rows = []
    for row in latency_rows:
        summary_row = dict(row)
        synth_row = synth_by_job.get((row["input_id"], row["architecture"]), {})
        summary_row.update({
            key: value for key, value in synth_row.items()
            if key not in summary_row
        })
        energy_row = energy_by_job.get(
            (row["input_id"], row["architecture"], row["pulse_time_ns"]), {}
        )
        summary_row.update({
            key: value for key, value in energy_row.items()
            if key not in summary_row
        })
        summary_rows.append(summary_row)

    common_fields = [
        "input_id", "input_file", "pulse_source", "crossbar_dimension", "max_bl",
        "architecture", "rng_family",
    ]
    latency_fields = common_fields + [
        "pulse_time_ns", "updates", "mean_input_bl",
        "mean_output_pulse_positions", "pulse_position_reduction",
        "mean_latency_ns", "median_latency_ns", "std_latency_ns",
        "p95_latency_ns", "relative_latency_saving", "speedup",
        "simulation_status", "errors", "group_mask_bypass_updates",
    ]
    synth_metric_fields = [
        "total_cell_area_um2", "normalized_area_vs_baseline", "cell_count",
        "combinational_area_um2", "sequential_area_um2", "target_period_ns",
        "worst_setup_slack_ns", "setup_violation_count",
        "estimated_min_period_ns", "estimated_fmax_mhz", "setup_status",
        "drc_status", "drc_violation_count", "worst_hold_slack_ns",
        "hold_advisory", "synthesis_status",
        "clock_gating_cells", "gated_registers", "ungated_registers",
        "gated_register_percent", "icg_cell_area_um2", "icg_ref_names",
        "rng_registers_total", "rng_registers_gated", "rng_registers_ungated",
        "rng_gating_percent", "rng_icg_cells", "rng_icg_ref_names",
        "rng_clock_gating_status",
    ]
    synth_fields = common_fields + synth_metric_fields
    energy_metric_fields = [
        "pulse_time_ns", "power_mw", "dynamic_power_mw", "leakage_power_mw",
        "tb_energy_nj", "energy_per_update_nj", "energy_per_pulse_pj",
        "total_pulses", "internal_power_mw", "saif_duration_ns",
        "source_fire_count", "source_fire_duty", "saif_clk_cycles",
        "rng_gated_cycles", "lfsr_advances", "lfsr_seq_errors",
        "shared_delay_errors", "lfsr_registers_total",
        "lfsr_registers_annotated", "lfsr_registers_toggle_nonzero",
        "lfsr_registers_default_zero",
        "annotated_percent", "power_error", "energy_status",
    ]
    energy_fields = common_fields + energy_metric_fields
    write_csv(options.output_dir / "latency.csv", latency_rows, latency_fields)
    write_csv(options.output_dir / "synthesis.csv", synth_rows, synth_fields)
    write_csv(options.output_dir / "energy.csv", energy_rows, energy_fields, digits=6)
    write_csv(
        options.output_dir / "summary.csv", summary_rows,
        latency_fields + synth_metric_fields + [
            field for field in energy_metric_fields if field not in latency_fields
        ],
    )

    input_report_rows = []
    for item in inputs:
        stats = trace_stats.get(item["id"], {})
        input_report_rows.append({
            "id": item["id"],
            "file": item["file_display"],
            "source": item["pulse_source"],
            "dimension": item["crossbar_dimension"],
            "max_bl": item["max_bl"],
            "updates": stats.get("updates", ""),
            "observed_bl": (
                f"{stats.get('min_bl', '?')}/{float(stats['mean_bl']):.3f}/"
                f"{stats.get('median_bl', '?')}/{stats.get('max_observed_bl', '?')}"
                if stats.get("mean_bl") else ""
            ),
            "pulse_times": ", ".join(str(value) for value in item["pulse_times_ns"]),
        })

    job_report_rows = [{
        "input_id": job["input_id"],
        "architecture": job["architecture"],
        "rng_family": job["rng_family"],
        "testbench": "yes" if job["run_testbench"] else "no",
        "synthesis": "yes" if job["run_synthesis"] else "no",
        "baseline": "yes" if job["baseline"] else "no",
    } for job in jobs]

    failed = any(
        statuses.get(("trace", item["id"], "", "")) != "PASS" for item in inputs
    )
    failed |= any(row["simulation_status"] != "PASS" for row in latency_rows)
    failed |= any(row["synthesis_status"] != "PASS" for row in synth_rows)
    failed |= any(row["energy_status"] != "PASS" for row in energy_rows)
    execution_rows = []
    for stage in ("trace", "compile", "simulation", "synthesis", "power"):
        if stage == "synthesis":
            values = [row["synthesis_status"] for row in synth_rows]
        elif stage == "power":
            values = [row["energy_status"] for row in energy_rows]
        else:
            values = [value for key, value in statuses.items() if key[0] == stage]
        if values:
            execution_rows.append({
                "stage": stage,
                "pass": values.count("PASS"),
                "fail": values.count("FAIL"),
                "skip": values.count("SKIP"),
            })

    report = [
        "# Experiment Summary", "", "## Global Configuration", "",
        f"- Overall result: **{'FAIL' if failed else 'PASS'}**",
        f"- Digital clock: {options.clock_ns:g} ns ({1000.0 / options.clock_ns:g} MHz)",
        f"- LFSR seed: `{options.seed}`",
        f"- Synthesis target: {options.target_period_ns:g} ns",
        "", "## Execution Status", "",
        *markdown_table(
            ["stage", "pass", "fail", "skip"],
            ["Stage", "PASS", "FAIL", "SKIP"],
            execution_rows,
        ),
        "", "## Inputs", "",
        *markdown_table(
            ["id", "file", "source", "dimension", "max_bl", "updates", "observed_bl", "pulse_times"],
            ["Input", "File", "Pulse source", "Dimension", "Configured MAX_BL", "Updates", "BL min/mean/median/max", "Pulse times ns"],
            input_report_rows,
        ),
        "", "## Selected Jobs", "",
        *markdown_table(
            ["input_id", "architecture", "rng_family", "testbench", "synthesis", "baseline"],
            ["Input", "Architecture", "RNG family", "Testbench", "Synthesis", "Baseline"],
            job_report_rows,
        ),
        "", "## System Latency", "",
        *markdown_table(
            [
                "input_id", "architecture", "pulse_time_ns", "mean_latency_ns",
                "median_latency_ns", "p95_latency_ns", "std_latency_ns",
                "relative_latency_saving", "mean_output_pulse_positions",
                "pulse_position_reduction",
            ],
            [
                "Input", "Architecture", "T_pulse ns", "Mean ns", "Median ns",
                "P95 ns", "Std ns", "Saving", "Mean BLout", "Reduction",
            ],
            latency_rows,
        ),
        "", "## Energy",
        "",
        "Power is average total digital power over the SAIF window at the 100 MHz digital clock. TB energy is P_avg × SAIF duration and includes analog wait. E_dig/update = TB energy / completed weight updates. Energy/pulse remains for compatibility. RNG duty cycle is source_fire / digital clocks in that same window.",
        "",
        *markdown_table(
            [
                "input_id", "architecture", "pulse_time_ns", "power_mw",
                "energy_per_update_nj", "tb_energy_nj", "energy_per_pulse_pj",
                "source_fire_duty", "lfsr_registers_annotated",
                "lfsr_registers_default_zero", "energy_status", "power_error",
            ],
            [
                "Input", "Architecture", "T_pulse ns", "Power mW",
                "E_dig/update nJ", "TB energy nJ", "Energy/pulse pJ",
                "source_fire duty", "LFSR annotated", "LFSR default-zero",
                "Stage", "Error",
            ],
            energy_rows,
        ),
        "", "## Synthesis", "",
        "Area is post-synthesis standard-cell area after inferred ICG insertion. Fmax is reported only when setup and transition/capacitance DRC qualify. Synthesis PASS requires every mapped RNG/LFSR state FF to be clock-gated; unrelated gated registers are not sufficient.",
        "",
        *markdown_table(
            [
                "input_id", "architecture", "total_cell_area_um2",
                "normalized_area_vs_baseline", "estimated_fmax_mhz",
                "rng_registers_total", "rng_registers_gated",
                "rng_registers_ungated", "rng_icg_cells",
                "target_period_ns", "setup_status", "drc_status",
                "hold_advisory", "synthesis_status",
            ],
            [
                "Input", "Architecture", "Area um2", "Area/base", "Fmax est. MHz",
                "RNG FF", "RNG gated", "RNG ungated", "RNG ICG",
                "Target ns", "Setup", "DRC", "Hold advisory", "Stage",
            ],
            synth_rows,
        ),
        "", "## Validation", "",
        "| Input | Architecture | Pulse ns | Simulation | Updates | Errors | Group-mask bypass updates |",
        "| --- | --- | --- | --- | --- | --- | --- |",
    ]
    report.extend(
        f"| {row['input_id']} | {row['architecture']} | {row['pulse_time_ns']} | "
        f"{row['simulation_status']} | {row['updates']} | {row['errors']} | "
        f"{row['group_mask_bypass_updates']} |"
        for row in latency_rows
    )
    (options.output_dir / "summary.md").write_text(
        "\n".join(report) + "\n", encoding="utf-8"
    )

    print("\nInput              Architecture                     Pulse(ns) Updates   Mean(ns)    P95(ns)   Saving")
    for row in latency_rows:
        saving = row.get("relative_latency_saving")
        print(
            f"{row['input_id']:<18} {row['architecture']:<32} "
            f"{row['pulse_time_ns']:>9} {row['updates']:>7} "
            f"{fmt(row.get('mean_latency_ns')):>10} {fmt(row.get('p95_latency_ns')):>10} "
            f"{(f'{100*saving:.1f}%' if isinstance(saving, float) else '-'):>8}"
        )
    print("\nInput              Architecture                     Area um2   Fmax   RNG tot/gated/ungated  ICG  Stage")
    for row in synth_rows:
        print(
            f"{row['input_id']:<18} {row['architecture']:<32} "
            f"{fmt(row.get('total_cell_area_um2')):>10} "
            f"{fmt(row.get('estimated_fmax_mhz')):>6} "
            f"{fmt(row.get('rng_registers_total')):>4}/"
            f"{fmt(row.get('rng_registers_gated')):>4}/"
            f"{fmt(row.get('rng_registers_ungated')):<4} "
            f"{fmt(row.get('rng_icg_cells')):>4} "
            f"{row['synthesis_status']:>9}"
        )
    print("\nInput              Architecture                     Pulse(ns)  Power(mW)  E/update(nJ)  Duty     Stage  Error")
    for row in energy_rows:
        print(
            f"{row['input_id']:<18} {row['architecture']:<32} "
            f"{row['pulse_time_ns']:>9} "
            f"{fmt(row.get('power_mw'), 4):>10} "
            f"{fmt(row.get('energy_per_update_nj'), 4):>12} "
            f"{fmt(row.get('source_fire_duty'), 6):>8} "
            f"{row['energy_status']:>7}  {row.get('power_error', '')}"
        )

    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
