#!/usr/bin/env python3
"""Validate the paper CSV trace and convert it to a compact replay format."""

from __future__ import annotations

import argparse
import csv
import math
import statistics
from decimal import Decimal, InvalidOperation
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("input_csv", type=Path)
    parser.add_argument("output_trace", type=Path)
    parser.add_argument("stats_csv", type=Path)
    parser.add_argument("--dimension", type=int, required=True)
    parser.add_argument("--max-bl", type=int, required=True)
    parser.add_argument("--value-width", type=int, required=True)
    return parser.parse_args()


def parse_probability(text: str, row_number: int, column: str) -> Decimal:
    try:
        value = Decimal(text.strip())
    except (InvalidOperation, AttributeError) as exc:
        raise ValueError(f"row {row_number}: {column} is not a number: {text!r}") from exc
    if not value.is_finite() or value < 0 or value > 1:
        raise ValueError(f"row {row_number}: {column}={text!r} is outside [0,1]")
    return value


def quantize(value: Decimal, width: int) -> int:
    maximum = (1 << width) - 1
    return int((value * maximum).to_integral_value(rounding="ROUND_HALF_UP"))


def pack(values: list[int], width: int) -> int:
    packed = 0
    for lane, value in enumerate(values):
        packed |= value << (lane * width)
    return packed


def main() -> int:
    args = parse_args()
    if args.dimension <= 0:
        raise SystemExit("ERROR: --dimension must be positive")
    if args.max_bl <= 0:
        raise SystemExit("ERROR: --max-bl must be positive")
    if args.value_width <= 0 or args.value_width > 32:
        raise SystemExit("ERROR: --value-width must be in 1..32")
    if not args.input_csv.is_file():
        raise SystemExit(f"ERROR: trace CSV not found: {args.input_csv}")

    expected = (
        ["update_id", "bl"]
        + [f"x{i}" for i in range(args.dimension)]
        + [f"d{i}" for i in range(args.dimension)]
    )
    records: list[tuple[int, int, int, int]] = []
    seen_ids: set[int] = set()

    try:
        with args.input_csv.open(newline="", encoding="utf-8-sig") as handle:
            reader = csv.reader(handle)
            try:
                header = [item.strip() for item in next(reader)]
            except StopIteration as exc:
                raise ValueError("trace is empty") from exc
            if header != expected:
                raise ValueError(
                    "header mismatch; expected exactly:\n" + ",".join(expected)
                )

            for row_number, row in enumerate(reader, start=2):
                if not row or all(not item.strip() for item in row):
                    continue
                if len(row) != len(expected):
                    raise ValueError(
                        f"row {row_number}: expected {len(expected)} columns, got {len(row)}"
                    )
                try:
                    update_id = int(row[0].strip(), 10)
                    bl = int(row[1].strip(), 10)
                except ValueError as exc:
                    raise ValueError(
                        f"row {row_number}: update_id and bl must be decimal integers"
                    ) from exc
                if update_id in seen_ids:
                    raise ValueError(f"row {row_number}: duplicate update_id {update_id}")
                if bl <= 0 or bl > args.max_bl:
                    raise ValueError(
                        f"row {row_number}: BL {bl} is outside 1..{args.max_bl}"
                    )
                seen_ids.add(update_id)

                x_decimal = [
                    parse_probability(row[2 + i], row_number, f"x{i}")
                    for i in range(args.dimension)
                ]
                d_decimal = [
                    parse_probability(
                        row[2 + args.dimension + i], row_number, f"d{i}"
                    )
                    for i in range(args.dimension)
                ]
                x_words = [quantize(value, args.value_width) for value in x_decimal]
                d_words = [quantize(value, args.value_width) for value in d_decimal]
                records.append(
                    (update_id, bl, pack(x_words, args.value_width), pack(d_words, args.value_width))
                )
    except (OSError, ValueError) as exc:
        raise SystemExit(f"ERROR: {exc}") from exc

    if not records:
        raise SystemExit("ERROR: trace contains no update records")

    args.output_trace.parent.mkdir(parents=True, exist_ok=True)
    vector_hex_width = math.ceil(args.dimension * args.value_width / 4)
    with args.output_trace.open("w", encoding="ascii", newline="\n") as handle:
        handle.write(
            f"{len(records)} {args.dimension} {args.value_width} {args.max_bl}\n"
        )
        for update_id, bl, x_packed, d_packed in records:
            handle.write(
                f"{update_id} {bl} {x_packed:0{vector_hex_width}x} "
                f"{d_packed:0{vector_hex_width}x}\n"
            )

    bl_values = [record[1] for record in records]
    stats = {
        "trace_filename": args.input_csv.name,
        "updates": len(records),
        "dimension": args.dimension,
        "max_bl": args.max_bl,
        "min_bl": min(bl_values),
        "mean_bl": statistics.fmean(bl_values),
        "median_bl": statistics.median(bl_values),
        "max_observed_bl": max(bl_values),
    }
    args.stats_csv.parent.mkdir(parents=True, exist_ok=True)
    with args.stats_csv.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.writer(handle, lineterminator="\n")
        writer.writerow(["metric", "value"])
        writer.writerows(stats.items())

    print(
        "Trace: "
        f"{len(records)} updates, dimension={args.dimension}, "
        f"BL min/mean/median/max={min(bl_values)}/"
        f"{statistics.fmean(bl_values):.3f}/"
        f"{statistics.median(bl_values):.3f}/{max(bl_values)}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
