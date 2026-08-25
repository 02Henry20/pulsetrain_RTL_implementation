#!/usr/bin/env python3
"""Validate realized binary AIHWKIT pulse trains and pack them losslessly."""

import argparse
import csv
import math
import re
import statistics
from collections import OrderedDict
from pathlib import Path

OPTIONAL_METADATA = {"x_size", "d_size", "tile_index"}


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("input_csv", type=Path)
    parser.add_argument("output_trace", type=Path)
    parser.add_argument("stats_csv", type=Path)
    parser.add_argument("--dimension", type=int, required=True)
    parser.add_argument("--max-bl", type=int, required=True)
    return parser.parse_args()


def decimal_integer(text, row_number, column):
    try:
        return int(text.strip(), 10)
    except (AttributeError, ValueError) as exc:
        raise ValueError(
            f"row {row_number}: {column} must be a decimal integer"
        ) from exc


def bit_value(text, row_number, column):
    try:
        value = text.strip()
    except AttributeError as exc:
        raise ValueError(
            f"row {row_number}: {column} must be 0 or 1, got {text!r}"
        ) from exc
    if value not in {"0", "1"}:
        raise ValueError(
            f"row {row_number}: {column} must be 0 or 1, got {text!r}"
        )
    return int(value)


def indexed_columns(header, prefix):
    matches = []
    pattern = re.compile(rf"{prefix}([0-9]+)")
    for column in header:
        match = pattern.fullmatch(column)
        if match:
            matches.append((int(match.group(1)), column))
    matches.sort()
    indices = [index for index, _ in matches]
    if not matches or indices != list(range(len(matches))):
        raise ValueError(
            f"{prefix} lane columns must be contiguous from {prefix}0; got {indices}"
        )
    return [column for _, column in matches]


def packed_bits(bits):
    packed = 0
    for lane, value in enumerate(bits):
        packed |= value << lane
    return packed


def main():
    args = parse_args()
    if args.dimension <= 0:
        raise SystemExit("ERROR: --dimension must be positive")
    if args.max_bl <= 0:
        raise SystemExit("ERROR: --max-bl must be positive")
    if not args.input_csv.is_file():
        raise SystemExit(f"ERROR: trace CSV not found: {args.input_csv}")

    updates = OrderedDict()
    previous_update_id = None
    closed_updates = set()
    x_pulse_count = 0
    d_pulse_count = 0

    try:
        with args.input_csv.open(newline="", encoding="utf-8-sig") as handle:
            reader = csv.DictReader(handle)
            if reader.fieldnames is None:
                raise ValueError("trace is empty")
            header = [column.strip() for column in reader.fieldnames]
            if header[:3] != ["update_id", "bl", "pulse_index"]:
                raise ValueError(
                    "the first three columns must be update_id,bl,pulse_index"
                )
            if len(set(header)) != len(header):
                raise ValueError("trace header contains duplicate column names")

            x_columns = indexed_columns(header, "x")
            d_columns = indexed_columns(header, "d")
            if len(x_columns) > args.dimension or len(d_columns) > args.dimension:
                raise ValueError(
                    "active X/D lane columns exceed --dimension; truncation is forbidden"
                )
            allowed = {
                "update_id", "bl", "pulse_index", *OPTIONAL_METADATA,
                *x_columns, *d_columns,
            }
            unexpected = [column for column in header if column not in allowed]
            if unexpected:
                raise ValueError(f"unexpected trace columns: {', '.join(unexpected)}")

            reader.fieldnames = header
            for row_number, row in enumerate(reader, start=2):
                if row is None or all(not (value or "").strip() for value in row.values()):
                    continue
                if None in row:
                    raise ValueError(f"row {row_number}: too many CSV fields")

                update_id = decimal_integer(row["update_id"], row_number, "update_id")
                bl = decimal_integer(row["bl"], row_number, "bl")
                pulse_index = decimal_integer(row["pulse_index"], row_number, "pulse_index")
                if bl <= 0 or bl > args.max_bl:
                    raise ValueError(
                        f"row {row_number}: BL {bl} is outside 1..{args.max_bl}"
                    )

                x_size = (
                    decimal_integer(row["x_size"], row_number, "x_size")
                    if "x_size" in header else len(x_columns)
                )
                d_size = (
                    decimal_integer(row["d_size"], row_number, "d_size")
                    if "d_size" in header else len(d_columns)
                )
                if "tile_index" in header:
                    tile_index = decimal_integer(
                        row["tile_index"], row_number, "tile_index"
                    )
                    if tile_index < 0:
                        raise ValueError(
                            f"row {row_number}: tile_index must be non-negative"
                        )
                else:
                    tile_index = -1
                if not 0 < x_size <= args.dimension:
                    raise ValueError(
                        f"row {row_number}: x_size {x_size} is outside 1..{args.dimension}"
                    )
                if not 0 < d_size <= args.dimension:
                    raise ValueError(
                        f"row {row_number}: d_size {d_size} is outside 1..{args.dimension}"
                    )
                if x_size > len(x_columns) or d_size > len(d_columns):
                    raise ValueError(
                        f"row {row_number}: declared active size exceeds available lanes"
                    )
                x_bits = [bit_value(row[column], row_number, column) for column in x_columns]
                d_bits = [bit_value(row[column], row_number, column) for column in d_columns]
                if any(x_bits[x_size:]):
                    raise ValueError(
                        f"row {row_number}: X lane beyond x_size={x_size} is active"
                    )
                if any(d_bits[d_size:]):
                    raise ValueError(
                        f"row {row_number}: D lane beyond d_size={d_size} is active"
                    )
                x_pulse_count += sum(x_bits[:x_size])
                d_pulse_count += sum(d_bits[:d_size])
                x_bits.extend([0] * (args.dimension - len(x_bits)))
                d_bits.extend([0] * (args.dimension - len(d_bits)))

                if update_id != previous_update_id:
                    if update_id in closed_updates:
                        raise ValueError(
                            f"row {row_number}: update_id {update_id} is not contiguous"
                        )
                    if previous_update_id is not None:
                        closed_updates.add(previous_update_id)
                    previous_update_id = update_id
                    updates[update_id] = {
                        "bl": bl, "x_size": x_size, "d_size": d_size,
                        "tile_index": tile_index, "rows": [],
                    }

                update = updates[update_id]
                if (
                    update["bl"] != bl
                    or update["x_size"] != x_size
                    or update["d_size"] != d_size
                    or update["tile_index"] != tile_index
                ):
                    raise ValueError(
                        f"row {row_number}: BL or tile metadata changed within update {update_id}"
                    )
                rows = update["rows"]
                assert isinstance(rows, list)
                if pulse_index != len(rows):
                    raise ValueError(
                        f"row {row_number}: update {update_id} pulse_index is "
                        f"{pulse_index}, expected {len(rows)}"
                    )
                rows.append((packed_bits(x_bits), packed_bits(d_bits)))

        if not updates:
            raise ValueError("trace contains no pulse positions")
        for update_id, update in updates.items():
            rows = update["rows"]
            assert isinstance(rows, list)
            bl = int(update["bl"])
            if len(rows) != bl:
                raise ValueError(
                    f"update {update_id}: found {len(rows)} positions, expected BL={bl}"
                )
    except (OSError, ValueError) as exc:
        raise SystemExit(f"ERROR: {exc}") from exc

    args.output_trace.parent.mkdir(parents=True, exist_ok=True)
    vector_hex_width = math.ceil(args.dimension / 4)
    total_positions = sum(int(update["bl"]) for update in updates.values())
    with args.output_trace.open("w", encoding="ascii", newline="\n") as handle:
        handle.write(
            f"{len(updates)} {total_positions} {args.dimension} {args.max_bl}\n"
        )
        for update_id, update in updates.items():
            rows = update["rows"]
            assert isinstance(rows, list)
            for pulse_index, (x_packed, d_packed) in enumerate(rows):
                handle.write(
                    f"{update_id} {update['bl']} {pulse_index} "
                    f"{update['x_size']} {update['d_size']} {update['tile_index']} "
                    f"{x_packed:0{vector_hex_width}x} "
                    f"{d_packed:0{vector_hex_width}x}\n"
                )

    bl_values = [int(update["bl"]) for update in updates.values()]
    x_sizes = [int(update["x_size"]) for update in updates.values()]
    d_sizes = [int(update["d_size"]) for update in updates.values()]
    stats = {
        "trace_filename": args.input_csv.name,
        "updates": len(updates),
        "pulse_positions": total_positions,
        "x_pulses": x_pulse_count,
        "d_pulses": d_pulse_count,
        "total_pulses": x_pulse_count + d_pulse_count,
        "dimension": args.dimension,
        "max_bl": args.max_bl,
        "min_bl": min(bl_values),
        "mean_bl": statistics.mean(bl_values),
        "median_bl": statistics.median(bl_values),
        "max_observed_bl": max(bl_values),
        "min_x_size": min(x_sizes),
        "max_x_size": max(x_sizes),
        "min_d_size": min(d_sizes),
        "max_d_size": max(d_sizes),
    }
    args.stats_csv.parent.mkdir(parents=True, exist_ok=True)
    with args.stats_csv.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.writer(handle, lineterminator="\n")
        writer.writerow(["metric", "value"])
        writer.writerows(stats.items())

    print(
        "Trace: "
        f"{len(updates)} updates, {total_positions} realized pulse positions, "
        f"dimension={args.dimension}, BL min/mean/median/max="
        f"{min(bl_values)}/{statistics.mean(bl_values):.3f}/"
        f"{statistics.median(bl_values):.3f}/{max(bl_values)}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())