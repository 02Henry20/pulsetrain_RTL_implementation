#!/usr/bin/env python3
"""Validate JSON experiment manifests and emit a normalized execution plan."""

import argparse
import json
import re
from pathlib import Path


ID_PATTERN = re.compile(r"[a-z0-9_]+")
PULSE_SOURCES = {"independent_lfsr", "shared_lfsr", "external", "unknown"}
RNG_FAMILIES = {"independent_lfsr", "shared_lfsr"}
FEATURE_FLAGS = {
    "sort": "ENABLE_D_SORT",
    "zero_delete": "ENABLE_ZERO_DELETE",
    "group_mask": "ENABLE_D_GROUP_MASK",
}


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--architectures", type=Path, required=True)
    parser.add_argument("--inputs", type=Path, required=True)
    parser.add_argument("--custom-dir", type=Path, required=True)
    parser.add_argument("--project-root", type=Path, required=True)
    parser.add_argument("--default-pulse-times", nargs="+", type=int, required=True)
    parser.add_argument("--plan-output", type=Path, required=True)
    parser.add_argument("--inputs-tsv", type=Path, required=True)
    parser.add_argument("--jobs-tsv", type=Path, required=True)
    return parser.parse_args()


def load_manifest(path, collection_name):
    try:
        data = json.loads(path.read_text(encoding="utf-8-sig"))
    except (OSError, json.JSONDecodeError) as exc:
        raise ValueError(f"cannot read {path}: {exc}") from exc
    if not isinstance(data, dict) or data.get("schema_version") != 1:
        raise ValueError(f"{path}: schema_version must be 1")
    collection = data.get(collection_name)
    if not isinstance(collection, list):
        raise ValueError(f"{path}: {collection_name} must be a JSON array")
    return collection


def require_bool(item, field, context, default=None):
    value = item.get(field, default)
    if not isinstance(value, bool):
        raise ValueError(f"{context}: {field} must be true or false")
    return value


def require_id(value, context):
    if not isinstance(value, str) or not ID_PATTERN.fullmatch(value):
        raise ValueError(f"{context}: id must match [a-z0-9_]+")
    return value


def require_positive_integer(value, field, context):
    if isinstance(value, bool) or not isinstance(value, int) or value <= 0:
        raise ValueError(f"{context}: {field} must be a positive integer")
    return value


def clean_text(value, field, context):
    if not isinstance(value, str) or not value:
        raise ValueError(f"{context}: {field} must be a non-empty string")
    if any(character in value for character in ("\t", "\n", "\r", ",")):
        raise ValueError(
            f"{context}: {field} may not contain commas, tabs, or newlines"
        )
    return value


def resolve_manifest_path(custom_dir, value, field, context, required=True):
    text = clean_text(value, field, context)
    path = Path(text)
    if not path.is_absolute():
        path = custom_dir / path
    path = path.resolve()
    if required and not path.is_file():
        raise ValueError(f"{context}: {field} not found: {path}")
    return path


def validate_pulse_times(values, context):
    if not isinstance(values, list) or not values:
        raise ValueError(f"{context}: pulse_times_ns must be a non-empty array")
    result = [
        require_positive_integer(value, "pulse_times_ns entry", context)
        for value in values
    ]
    if len(set(result)) != len(result):
        raise ValueError(f"{context}: pulse_times_ns contains duplicates")
    if result != sorted(result):
        raise ValueError(f"{context}: pulse_times_ns must be strictly increasing")
    return result


def wrapper_flag(wrapper_text, parameter, context):
    matches = re.findall(
        rf"\.{re.escape(parameter)}\s*\(\s*([01])\s*\)", wrapper_text
    )
    if len(matches) != 1:
        raise ValueError(
            f"{context}: wrapper must set {parameter} exactly once to literal 0 or 1"
        )
    return matches[0] == "1"


def normalize_inputs(raw_inputs, custom_dir, default_pulse_times):
    normalized = {}
    for ordinal, item in enumerate(raw_inputs):
        context = f"inputs[{ordinal}]"
        if not isinstance(item, dict):
            raise ValueError(f"{context}: entry must be an object")
        input_id = require_id(item.get("id"), context)
        if input_id in normalized:
            raise ValueError(f"{context}: duplicate input id {input_id}")
        enabled = require_bool(item, "enabled", context, True)
        trace_path = resolve_manifest_path(
            custom_dir, item.get("file"), "file", context, required=enabled
        )
        metadata_path = None
        if item.get("metadata_file"):
            metadata_path = resolve_manifest_path(
                custom_dir, item["metadata_file"], "metadata_file", context,
                required=enabled,
            )
        dimension = require_positive_integer(
            item.get("crossbar_dimension"), "crossbar_dimension", context
        )
        max_bl = require_positive_integer(item.get("max_bl"), "max_bl", context)
        pulse_source = item.get("pulse_source", "unknown")
        if pulse_source not in PULSE_SOURCES:
            raise ValueError(
                f"{context}: pulse_source must be one of {sorted(PULSE_SOURCES)}"
            )
        pulse_times = validate_pulse_times(
            item.get("pulse_times_ns", default_pulse_times), context
        )
        normalized[input_id] = {
            "id": input_id,
            "enabled": enabled,
            "file": str(trace_path),
            "file_display": str(item["file"]),
            "metadata_file": str(metadata_path) if metadata_path else None,
            "crossbar_dimension": dimension,
            "max_bl": max_bl,
            "pulse_source": pulse_source,
            "pulse_times_ns": pulse_times,
            "description": str(item.get("description", "")),
        }
    if not normalized:
        raise ValueError("inputs manifest contains no inputs")
    return normalized


def normalize_architectures(raw_architectures, project_root):
    normalized = {}
    for ordinal, item in enumerate(raw_architectures):
        context = f"architectures[{ordinal}]"
        if not isinstance(item, dict):
            raise ValueError(f"{context}: entry must be an object")
        arch_id = require_id(item.get("id"), context)
        if arch_id in normalized:
            raise ValueError(f"{context}: duplicate architecture id {arch_id}")
        enabled = require_bool(item, "enabled", context, True)
        run_testbench = require_bool(item, "run_testbench", context, True)
        run_synthesis = require_bool(item, "run_synthesis", context, True)
        baseline = require_bool(item, "baseline", context, False)
        allow_mismatch = require_bool(item, "allow_source_mismatch", context, False)
        rng_family = item.get("rng_family")
        if rng_family not in RNG_FAMILIES:
            raise ValueError(
                f"{context}: rng_family must be one of {sorted(RNG_FAMILIES)}"
            )
        input_ids = item.get("input_ids")
        if not isinstance(input_ids, list) or any(not isinstance(v, str) for v in input_ids):
            raise ValueError(f"{context}: input_ids must be an array of input ids")
        if len(set(input_ids)) != len(input_ids):
            raise ValueError(f"{context}: input_ids contains duplicates")
        if "*" in input_ids and input_ids != ["*"]:
            raise ValueError(f"{context}: wildcard * must be the only input_ids entry")

        features = item.get("features", {})
        if not isinstance(features, dict):
            raise ValueError(f"{context}: features must be an object")
        unknown_features = sorted(set(features) - set(FEATURE_FLAGS))
        if unknown_features:
            raise ValueError(
                f"{context}: unknown feature keys: {', '.join(unknown_features)}"
            )
        feature_values = {
            feature: require_bool(features, feature, context, False)
            for feature in ("sort", "zero_delete", "group_mask")
        }

        wrapper = project_root / "RTL" / "architectures" / arch_id / "TOP.v"
        filelist = project_root / "SIM" / "FUNCTION" / "filelists" / f"{arch_id}.f"
        if enabled and not wrapper.is_file():
            raise ValueError(f"{context}: wrapper not found: {wrapper}")
        if enabled and (run_testbench or run_synthesis) and not filelist.is_file():
            raise ValueError(f"{context}: RTL file list not found: {filelist}")
        if baseline and any(feature_values.values()):
            raise ValueError(
                f"{context}: baseline architecture may not enable preprocessing features"
            )
        if enabled:
            try:
                wrapper_text = wrapper.read_text(encoding="utf-8-sig")
            except OSError as exc:
                raise ValueError(f"{context}: cannot read wrapper {wrapper}: {exc}") from exc
            expected_shared = rng_family == "shared_lfsr"
            actual_shared = wrapper_flag(wrapper_text, "USE_SHARED_LFSR", context)
            if actual_shared != expected_shared:
                raise ValueError(
                    f"{context}: rng_family disagrees with wrapper USE_SHARED_LFSR"
                )
            for feature, parameter in FEATURE_FLAGS.items():
                if wrapper_flag(wrapper_text, parameter, context) != feature_values[feature]:
                    raise ValueError(
                        f"{context}: feature {feature} disagrees with wrapper {parameter}"
                    )

        normalized[arch_id] = {
            "id": arch_id,
            "enabled": enabled,
            "input_ids": input_ids,
            "run_testbench": run_testbench,
            "run_synthesis": run_synthesis,
            "baseline": baseline,
            "allow_source_mismatch": allow_mismatch,
            "rng_family": rng_family,
            "features": feature_values,
        }
    if not normalized:
        raise ValueError("architectures manifest contains no architectures")
    return normalized


def build_jobs(inputs, architectures):
    jobs = []
    for architecture in architectures.values():
        if not architecture["enabled"]:
            continue
        if not architecture["run_testbench"] and not architecture["run_synthesis"]:
            raise ValueError(
                f"architecture {architecture['id']}: both run_testbench and run_synthesis are false"
            )
        if architecture["input_ids"] == ["*"]:
            selected_ids = [
                key for key, value in inputs.items()
                if value["enabled"] and (
                    value["pulse_source"] not in RNG_FAMILIES
                    or value["pulse_source"] == architecture["rng_family"]
                    or architecture["allow_source_mismatch"]
                )
            ]
        else:
            selected_ids = architecture["input_ids"]
        for input_id in selected_ids:
            if input_id not in inputs:
                raise ValueError(
                    f"architecture {architecture['id']}: unknown input id {input_id}"
                )
            input_item = inputs[input_id]
            if not input_item["enabled"]:
                raise ValueError(
                    f"architecture {architecture['id']}: input {input_id} is disabled"
                )
            source = input_item["pulse_source"]
            if (
                source in RNG_FAMILIES
                and source != architecture["rng_family"]
                and not architecture["allow_source_mismatch"]
            ):
                raise ValueError(
                    f"architecture {architecture['id']}: input {input_id} uses {source}, "
                    f"but architecture uses {architecture['rng_family']}; set "
                    "allow_source_mismatch=true only for intentional raw-replay comparisons"
                )
            jobs.append({
                "input_id": input_id,
                "input_file": input_item["file"],
                "input_file_display": input_item["file_display"],
                "pulse_source": source,
                "crossbar_dimension": input_item["crossbar_dimension"],
                "max_bl": input_item["max_bl"],
                "pulse_times_ns": input_item["pulse_times_ns"],
                "architecture": architecture["id"],
                "rng_family": architecture["rng_family"],
                "run_testbench": architecture["run_testbench"],
                "run_synthesis": architecture["run_synthesis"],
                "baseline": architecture["baseline"],
                "features": architecture["features"],
            })
    if not jobs:
        raise ValueError("configuration selects no (input, architecture) jobs")

    for input_id in sorted({job["input_id"] for job in jobs}):
        for stage in ("run_testbench", "run_synthesis"):
            stage_jobs = [job for job in jobs if job["input_id"] == input_id and job[stage]]
            if not stage_jobs:
                continue
            baselines = [job for job in stage_jobs if job["baseline"]]
            if len(baselines) != 1:
                raise ValueError(
                    f"input {input_id}: {stage} requires exactly one selected baseline; "
                    f"found {len(baselines)}"
                )
    return jobs


def write_tsv(path, rows):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="\n") as handle:
        for row in rows:
            handle.write("\t".join(str(value) for value in row) + "\n")


def main():
    options = parse_args()
    default_pulse_times = [
        require_positive_integer(value, "default pulse time", "command line")
        for value in options.default_pulse_times
    ]
    try:
        raw_inputs = load_manifest(options.inputs, "inputs")
        raw_architectures = load_manifest(options.architectures, "architectures")
        inputs = normalize_inputs(raw_inputs, options.custom_dir.resolve(), default_pulse_times)
        architectures = normalize_architectures(
            raw_architectures, options.project_root.resolve()
        )
        jobs = build_jobs(inputs, architectures)
    except ValueError as exc:
        raise SystemExit(f"ERROR: {exc}") from exc

    selected_input_ids = []
    for job in jobs:
        if job["input_id"] not in selected_input_ids:
            selected_input_ids.append(job["input_id"])
    selected_inputs = [inputs[input_id] for input_id in selected_input_ids]

    plan = {"schema_version": 1, "inputs": selected_inputs, "jobs": jobs}
    options.plan_output.parent.mkdir(parents=True, exist_ok=True)
    options.plan_output.write_text(
        json.dumps(plan, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )
    write_tsv(options.inputs_tsv, [
        (
            item["id"], item["file"], item["crossbar_dimension"], item["max_bl"],
            ",".join(str(value) for value in item["pulse_times_ns"]),
        )
        for item in selected_inputs
    ])
    write_tsv(options.jobs_tsv, [
        (
            job["input_id"], job["input_file"], job["crossbar_dimension"],
            job["max_bl"], ",".join(str(value) for value in job["pulse_times_ns"]),
            job["architecture"], int(job["run_testbench"]),
            int(job["run_synthesis"]), int(job["baseline"]), job["rng_family"],
            int(job["features"]["sort"]), int(job["features"]["zero_delete"]),
            int(job["features"]["group_mask"]),
        )
        for job in jobs
    ])
    print(
        f"Plan: {len(selected_inputs)} input(s), {len(jobs)} job(s), "
        f"{sum(job['run_testbench'] for job in jobs)} testbench job(s), "
        f"{sum(job['run_synthesis'] for job in jobs)} synthesis job(s)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
