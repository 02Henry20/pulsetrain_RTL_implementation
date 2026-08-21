# Paper Experiment Flow

Run the supported experiment from the repository root:

```bash
bash CUSTOM/run_all.sh
```

The flow validates one recorded AIHWKIT pulse trace, compiles each enabled replay testbench once, reuses that executable for every configured device pulse time, synthesizes each architecture once without SAIF, and writes the paper tables under `CUSTOM/results/`.

## Methodology

System-latency simulations replay realized binary stochastic pulse trains recorded from AIHWKIT. The stochastic pulse-generation hardware is bypassed during trace replay because it sustains one candidate pulse position per digital cycle and is not the throughput bottleneck. Every architecture therefore receives exactly the same stochastic realization.

The complete LFSR and pulse-generation circuitry remains in the synthesized architecture and is included in area and timing characterization. Replay changes only the source selected ahead of the shared SORT / ZERO DELETE / GROUP MASK / OUTPUT BUFFER pipeline.

Keep the two timing configurations separate:

- System latency: `DIGITAL_CLOCK_NS=10`, so `Tclk = 10 ns = 100 MHz`.
- Synthesis characterization: `SYNTH_TARGET_PERIOD_NS=3` by default.

The 3 ns synthesis target does not change the 100 MHz latency experiment.

## Raw binary trace format

Set `TRACE_CSV` in `CUSTOM/experiment.conf` to a CSV with one row per realized stochastic pulse position. The required columns are:

```text
update_id,bl,pulse_index,x0,...,xN,d0,...,dN
```

The X and D lane columns must start at zero and be contiguous. Optional metadata columns are `x_size`, `d_size`, and `tile_index`; if present, they apply to every row of that update.

For a four-lane trace:

```csv
update_id,bl,pulse_index,x0,x1,x2,x3,d0,d1,d2,d3
0,3,0,1,0,0,1,0,1,0,0
0,3,1,0,0,0,0,1,1,0,0
0,3,2,1,1,0,0,0,0,1,0
1,2,0,0,1,0,0,1,0,0,1
1,2,1,1,0,0,0,0,0,1,0
```

Rules enforced by `CUSTOM/prepare_trace.py`:

- `bl` is runtime BL and must be in `1..MAX_BL`.
- Each update has exactly BL rows with `pulse_index` equal to `0..BL-1`.
- Every X/D lane value is the integer `0` or `1`.
- Update rows are contiguous and metadata is constant within an update.
- Active X/D dimensions may not exceed `CROSSBAR_DIMENSION`.
- Unexpected columns, duplicate or missing indices, malformed values, truncation, and active lanes beyond declared sizes fail loudly.

Conversion is lossless: lane vectors are packed into hex for Verilog replay without quantization, probability inference, stochastic regeneration, reordering, or position deletion.

Non-square AIHWKIT tiles are supported through metadata. If `x_size` or `d_size` is smaller than the fixed RTL dimension, inactive lanes are zero-padded. Active lanes are never truncated. Without metadata, the CSV lane counts define the physical X and D sizes. See `CUSTOM/input/example_trace.csv` for a variable-BL example.

## Replay handshake and latency

`TB_REPLAY.sv` elaborates `TOP` with `RAW_REPLAY_MODE=1` and drives `X_RAW_PULSES_IN` and `D_RAW_PULSES_IN`. It advances `pulse_index` only on `INPUT_VALID && READY_IN`; raw X, raw D, `INPUT_VALID`, and `INPUT_BL` remain stable under backpressure.

For each serial update:

```text
start_time = acceptance of the first raw candidate position
digital_completion = preprocessing and output-buffer completion
physical_completion = exact end of the last device pulse
latency = max(digital_completion, physical_completion) - start_time
```

The simulation-only device accepts an output pair only while idle. Its availability is scheduled deterministically around exact 10 ns clock boundaries while its physical completion timestamp remains `acceptance_time + T_PULSE`.

The testbench checks accepted/preprocessed position counts, stalled-input stability, blocked-output stability, X/Z values, baseline stream identity, sort behavior, zero-delete legality, and downstream coincidence-matrix preservation.

## Synthesis mode

All architecture wrappers default to `RAW_REPLAY_MODE=0`. `SYN_topo/run_synthesis` also forces this value to zero and propagates `SYNTH_TARGET_PERIOD_NS` into every active MCMM `create_clock` constraint.

With `RAW_REPLAY_MODE=0`, the elaborated hardware contains the normal LFSR and pulse-comparator source:

```text
normalized X/D values -> LFSR + pulse generation -> preprocessing -> output buffer
```

A precompile hierarchy report is generated for every synthesis run, and the driver fails if it cannot find both LFSR and pulse-generator hierarchy. Synthesis is performed once per architecture with no SAIF or energy flow.

## Architectures

`CUSTOM/architectures.txt` is the source of truth. The supported set has two genuinely different RNG families, each combined with the supported preprocessing variants:

- Plain names (`baseline`, `sort`, `zero_delete`, and group-mask combinations) use independent per-input LFSRs.
- `lfsr*` names use one shared LFSR, with D receiving the sequence two accepted positions behind X.

Legacy `lfsr_per_input*` aliases are not supported because they duplicated the canonical plain-name family. RNG-only architecture differences are intentionally invisible in raw-replay latency but remain visible in synthesis area and timing.

Every enabled architecture must have both `RTL/architectures/<architecture>/TOP.v` and `SIM/FUNCTION/filelists/<architecture>.f`.

## Configuration and results

`CUSTOM/experiment.conf` selects the trace, RTL dimension and `MAX_BL`, stochastic word width, output-buffer depth, 10 ns latency clock, device pulse sweep, baseline architecture, LFSR seed, and synthesis target period.

Generated outputs are:

```text
CUSTOM/results/
  summary.md
  summary.csv
  latency.csv
  synthesis.csv
  run_status.csv
  per_update/<architecture>_<pulse>ns.csv
```

Latency summaries include update count, input BL, output pulse positions, reduction, mean/median/std/P95 latency, savings, speedup, and validation status. Synthesis summaries include total/combinational/sequential cell area, normalized area, cell count, target period, setup slack and violations, estimated minimum period and Fmax, setup/DRC status, and advisory hold data. Power and energy are intentionally excluded.
