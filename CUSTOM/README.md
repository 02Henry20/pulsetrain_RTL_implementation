# Paper Experiment Flow

The complete supported workflow is:

```bash
bash CUSTOM/run_all.sh
```

The script validates one recorded update trace, replays it through every enabled RTL architecture for every configured device pulse time, synthesizes each architecture once without SAIF, and writes the paper tables under `CUSTOM/results/`.

## 1. Input trace

Put the trace CSV in `CUSTOM/input/` and set `TRACE_CSV` in `CUSTOM/experiment.conf`. One row is one complete weight update. For the default 8 x 8 crossbar the header is exactly:

```text
update_id,bl,x0,x1,x2,x3,x4,x5,x6,x7,d0,d1,d2,d3,d4,d5,d6,d7
```

`update_id` and `bl` are decimal integers. Every X/D value is a normalized unsigned magnitude in `[0,1]`. The converter rejects duplicate IDs, missing or extra lanes, malformed values, `BL=0`, and `BL>MAX_BL`; it never pads or truncates data. `CUSTOM/input/example_trace.csv` is a small variable-BL smoke trace.

## 2. Select architectures

Edit `CUSTOM/architectures.txt`. Each uncommented line is enabled; a line beginning with `#` is disabled. Plain architecture names use a separate, differently seeded LFSR for every X lane and every D lane. The `lfsr*` names use one shared LFSR: X receives the current random word and D receives the same sequence delayed by two accepted candidate positions.

## 3. Configure the experiment

Edit `CUSTOM/experiment.conf` to set:

- trace filename and crossbar dimension;
- compile-time `MAX_BL` and stochastic word width;
- fixed digital clock period (default 10 ns / 100 MHz);
- pulse sweep in integer nanoseconds (default 1, 10, 100, 1,000, 10,000, 100,000 ns);
- output FIFO depth, baseline architecture, deterministic LFSR seed, and synthesis target period.

Runtime `bl` comes from each trace row. `MAX_BL` only sizes RTL storage. LFSRs reset once at simulation start and advance only on accepted candidate positions; a fresh process for every pulse-time point reproduces the same stochastic realization.

## 4. Latency and device timing

The simulation-only device accepts a FIFO output pair only while idle, remains busy for exactly `T_PULSE` simulation time, and then completes that physical pulse. FIFO removal is physical-pulse start, not completion.

For each update:

```text
start = first accepted candidate position
end = max(digital frame/FIFO-drain completion, final physical pulse completion)
latency = end - start
```

Updates do not overlap. Group-mask architectures group runtime frames up to BL 8 and explicitly bypass longer frames; bypass counts are reported.

## 5. Results

Generated files are:

```text
CUSTOM/results/
  summary.md
  summary.csv
  latency.csv
  synthesis.csv
  run_status.csv
  per_update/<architecture>_<pulse>ns.csv
```

The raw per-update CSVs retain IDs, input/output pulse positions, deleted positions, exact nanosecond latency, digital and physical completion, stall/full counters, FIFO occupancy, group-mask bypass, and validation errors.

Synthesis is performed once per architecture using the existing Samsung 28 nm libraries, MCMM scenarios, and constraints. Reported area is post-synthesis standard-cell area, not die area. Estimated fmax is `1000 / (target_period - worst_setup_slack)` and is shown only when setup and transition/capacitance DRC qualify. Hold is a pre-layout advisory. Power and energy are intentionally not part of this experiment.
