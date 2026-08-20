#!/usr/bin/env python3
"""Generate deterministic normalized X/D vectors for architecture experiments."""

from pathlib import Path
import random

DIMENSION = 8
VALUE_WIDTH = 16
MAX_CODE = (1 << VALUE_WIDTH) - 1
OUTPUT = Path(__file__).with_name("x_d_training_pairs.hex")


def quantize(value: float) -> int:
    return max(0, min(MAX_CODE, round(value * MAX_CODE)))


def pack_pair(x_values: list[int], d_values: list[int]) -> int:
    x_word = sum(value << (VALUE_WIDTH * lane)
                 for lane, value in enumerate(x_values))
    d_word = sum(value << (VALUE_WIDTH * lane)
                 for lane, value in enumerate(d_values))
    return (x_word << (DIMENSION * VALUE_WIDTH)) | d_word


def edge_pair(index: int) -> tuple[list[int], list[int]]:
    lane = index % DIMENSION
    other = (index * 3 + 1) % DIMENSION
    mode = index % 16
    zero = [0] * DIMENSION
    one = [MAX_CODE] * DIMENSION

    if mode == 0:
        return zero[:], zero[:]
    if mode == 1:
        return one[:], one[:]
    if mode == 2:
        return zero[:], one[:]
    if mode == 3:
        return one[:], zero[:]
    if mode == 4:
        x, d = zero[:], zero[:]
        x[lane], d[other] = MAX_CODE, MAX_CODE
        return x, d
    if mode == 5:
        x = [MAX_CODE if i % 2 == 0 else 0 for i in range(DIMENSION)]
        d = [MAX_CODE if i % 2 == 1 else 0 for i in range(DIMENSION)]
        return x, d
    if mode == 6:
        return [1] * DIMENSION, [MAX_CODE - 1] * DIMENSION
    if mode == 7:
        return [MAX_CODE - 1] * DIMENSION, [1] * DIMENSION
    if mode == 8:
        levels = [0, 1, quantize(0.01), quantize(0.25),
                  quantize(0.5), quantize(0.75), MAX_CODE - 1, MAX_CODE]
        return levels[:], list(reversed(levels))
    if mode == 9:
        pattern = [quantize(0.2), quantize(0.8)] * 4
        return pattern[:], pattern[:]
    if mode == 10:
        x, d = zero[:], [quantize(0.5)] * DIMENSION
        x[lane] = quantize(0.5)
        return x, d
    if mode == 11:
        x, d = [quantize(0.5)] * DIMENSION, zero[:]
        d[lane] = quantize(0.5)
        return x, d
    if mode == 12:
        return [quantize((i + 1) / DIMENSION) for i in range(DIMENSION)], one[:]
    if mode == 13:
        return one[:], [quantize((i + 1) / DIMENSION) for i in range(DIMENSION)]
    if mode == 14:
        repeated_d = [0, 0, quantize(0.85), quantize(0.85),
                      0, 0, quantize(0.15), quantize(0.15)]
        x = [MAX_CODE if i == lane or i == other else 0
             for i in range(DIMENSION)]
        return x, repeated_d

    x = [quantize(((index + i * 5) % 17) / 16) for i in range(DIMENSION)]
    d = [quantize(((index * 3 + i * 7) % 17) / 16)
         for i in range(DIMENSION)]
    return x, d


def generate_pairs() -> list[tuple[list[int], list[int]]]:
    rng = random.Random(0x5EED2026)
    pairs: list[tuple[list[int], list[int]]] = []

    # 0-255: exact boundaries, zeros, ones, sparse lanes, and repeated D forms.
    for index in range(256):
        pairs.append(edge_pair(index))

    # 256-767: early training, broad high-variance probability distribution.
    for index in range(512):
        x = [quantize(rng.betavariate(0.65, 0.65))
             for _ in range(DIMENSION)]
        d = [quantize(rng.betavariate(0.70, 0.70))
             for _ in range(DIMENSION)]
        if index % 64 == 0:
            x = [MAX_CODE] * DIMENSION
        if index % 64 == 1:
            d = [0] * DIMENSION
        pairs.append((x, d))

    # 768-1279: mid training, correlated values and recurring D prototypes.
    d_prototypes = [
        [0.85, 0.15, 0.85, 0.15, 0.65, 0.35, 0.65, 0.35],
        [0.10, 0.90, 0.10, 0.90, 0.25, 0.75, 0.25, 0.75],
        [0.70, 0.70, 0.20, 0.20, 0.70, 0.70, 0.20, 0.20],
        [0.05, 0.05, 0.95, 0.95, 0.50, 0.50, 0.50, 0.50],
    ]
    for index in range(512):
        progress = index / 511
        prototype = d_prototypes[(index // 8) % len(d_prototypes)]
        d = [quantize(value + rng.uniform(-0.035, 0.035))
             for value in prototype]
        x = [quantize((1.0 - progress) * rng.random() +
                      progress * (0.2 + 0.6 * prototype[lane]))
             for lane in range(DIMENSION)]
        pairs.append((x, d))

    # 1280-1791: late training, sparse low-amplitude updates with rare spikes.
    for index in range(512):
        x = []
        d = []
        for lane in range(DIMENSION):
            x_value = 0.0 if rng.random() < 0.72 else 0.22 * rng.random() ** 3
            d_value = 0.0 if rng.random() < 0.78 else 0.18 * rng.random() ** 3
            if (index + lane * 11) % 127 == 0:
                x_value = 1.0
            if (index + lane * 7) % 131 == 0:
                d_value = 1.0
            x.append(quantize(x_value))
            d.append(quantize(d_value))
        if index % 32 == 31:
            x = [0] * DIMENSION
            d = [0] * DIMENSION
        pairs.append((x, d))

    # 1792-2047: convergence and stress frames with stable/repeated patterns.
    templates = [
        ([0.0] * 8, [0.0] * 8),
        ([1.0] * 8, [1.0] * 8),
        ([1.0, 0.0] * 4, [0.0, 1.0] * 4),
        ([0.5] * 8, [0.5] * 8),
        ([0.01, 0.99] * 4, [0.99, 0.01] * 4),
        ([0.9, 0.9, 0.1, 0.1] * 2, [0.8, 0.2, 0.8, 0.2] * 2),
        ([0.0, 0.0, 1.0, 1.0] * 2, [0.75, 0.75, 0.25, 0.25] * 2),
        ([1 / 65535, 65534 / 65535] * 4,
         [65534 / 65535, 1 / 65535] * 4),
    ]
    for index in range(256):
        x_template, d_template = templates[(index // 8) % len(templates)]
        pairs.append(([quantize(value) for value in x_template],
                      [quantize(value) for value in d_template]))

    assert len(pairs) == 2048
    return pairs


def main() -> None:
    pairs = generate_pairs()
    hex_digits = (2 * DIMENSION * VALUE_WIDTH) // 4
    lines = [f"{pack_pair(x, d):0{hex_digits}x}" for x, d in pairs]
    OUTPUT.write_text("\n".join(lines) + "\n", encoding="ascii")
    print(f"Wrote {len(lines)} pairs to {OUTPUT}")


if __name__ == "__main__":
    main()
