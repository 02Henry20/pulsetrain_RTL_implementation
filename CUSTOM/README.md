# Paper Experiment Flow

Run the supported experiment from the repository root:

```bash
bash CUSTOM/run_all.sh
```

The flow validates every selected AIHWKIT pulse trace, builds explicit input/architecture jobs from JSON manifests, compiles each requested replay testbench once per input configuration, reuses that executable for the input's device-pulse sweep, dumps SAIF switching activity from that same replay, and optionally synthesizes each job. After mapping, Design Compiler annotates the SAIF onto the netlist for power/energy. Combined tables are written under `CUSTOM/results/` and copied to `CUSTOM/reports/`.

## Methodology

System-latency simulations replay realized binary stochastic pulse trains recorded from AIHWKIT. The stochastic pulse-generation hardware is bypassed during trace replay because it sustains one candidate pulse position per digital cycle and is not the throughput bottleneck. Every architecture therefore receives exactly the same stochastic realization.

The complete LFSR and pulse-generation circuitry remains in the synthesized architecture and is included in area and timing characterization. Replay changes only the source selected ahead of the shared SORT / ZERO DELETE / GROUP MASK / OUTPUT BUFFER pipeline.

Keep the two timing configurations separate:

- System latency: `DIGITAL_CLOCK_NS=10`, so `Tclk = 10 ns = 100 MHz`.
- Synthesis characterization: `SYNTH_TARGET_PERIOD_NS=3` by default.

The 3 ns synthesis target does not change the 100 MHz latency experiment.

## Raw binary trace format

Add each trace to `CUSTOM/inputs.json`. Its `file` points to a CSV with one row per realized stochastic pulse position. The required columns are:

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

Non-square AIHWKIT tiles are supported through metadata. If `x_size` or `d_size` is smaller than the fixed RTL dimension, inactive lanes are zero-padded. Active lanes are never truncated. Without metadata, the CSV lane counts define the physical X and D sizes. See `CUSTOM/input/rtl_trace_data8_1e-04.csv` for a variable-BL example.

## Replay handshake and latency

`SIM/TESTBENCH/TB_REPLAY.sv` elaborates `TOP` with `RAW_REPLAY_MODE=1` and drives `X_RAW_PULSES_IN` and `D_RAW_PULSES_IN`. It advances `pulse_index` only on `INPUT_VALID && READY_IN`; raw X, raw D, `INPUT_VALID`, and `INPUT_BL` remain stable under backpressure. Optional `+SAIF_FILE=` dumps switching activity over that same replay window, after reset and through analog wait.

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

All architecture wrappers default to `RAW_REPLAY_MODE=0`. `SYN_topo/run_synthesis` also forces this value to zero and propagates `SYNTH_TARGET_PERIOD_NS` into every active MCMM `create_clock` constraint. The synthesis run directory stays labeled `no_saif` because SAIF is never used during `compile_ultra`.

With `RAW_REPLAY_MODE=0`, the elaborated hardware contains the normal LFSR and pulse-comparator source:

```text
normalized X/D values -> LFSR + pulse generation -> preprocessing -> output buffer
```

A precompile hierarchy report is generated for every synthesis run, and the driver fails if it cannot find both LFSR and pulse-generator hierarchy. Synthesis is performed once per selected `(input configuration, architecture)` pair. SAIF is **not** used during `compile_ultra`, so area and Fmax stay independent of activity. After mapping, Design Compiler temporarily recreates `MAIN_CLOCK` at `DIGITAL_CLOCK_NS` (100 MHz), annotates each replay SAIF onto the mapped netlist, and reports power.

This is activity-based power for the replayed preprocessing/output path, plus leakage for the complete mapped design. It is not a measured full-source dynamic-power result: the testbench uses `RAW_REPLAY_MODE=1`, while synthesis retains `RAW_REPLAY_MODE=0`, so the LFSR and pulse-comparator source has no matching replay activity. Unannotated nets deliberately default to zero toggle rather than an invented activity rate. A future full-source dynamic-power experiment therefore requires traces of the original normalized X/D values, not only their realized binary pulses.

Average power over the SAIF window is `P`. Total replay-window energy is `P × t_SAIF`. Energy/input-pulse divides that energy by the total number of asserted X and D pulse bits in the input trace; it does not divide by pulse positions or crossbar coincidences. Each power point has its own PASS/FAIL status and diagnostic. A failed power point does not discard valid area/Fmax reports, but it does make the overall experiment exit nonzero. Reports stay isolated when inputs use different dimensions or `MAX_BL` values.

## JSON experiment manifests

`CUSTOM/inputs.json` owns trace-specific configuration. Each entry supports:

```json
{
  "id": "shared_example",
  "enabled": true,
  "file": "input/shared_example.csv",
  "metadata_file": "input/metadata/shared_example.updates.csv",
  "crossbar_dimension": 64,
  "max_bl": 32,
  "pulse_source": "shared_lfsr",
  "pulse_times_ns": [10, 100, 1000],
  "description": "optional human-readable note"
}
```

`pulse_times_ns` is optional and falls back to `DEFAULT_PULSE_TIMES_NS` in `experiment.conf`; values must be unique and strictly increasing. `metadata_file` and `description` are informational; the binary pulse CSV remains the simulation source. Supported `pulse_source` values are `independent_lfsr`, `shared_lfsr`, `external`, and `unknown`.

`CUSTOM/architectures.json` owns job selection and checker metadata. Each entry supports:

```json
{
  "id": "lfsr_zero_delete",
  "enabled": true,
  "input_ids": ["shared_example"],
  "run_testbench": true,
  "run_synthesis": true,
  "baseline": false,
  "rng_family": "shared_lfsr",
  "features": {"sort": false, "zero_delete": true, "group_mask": false}
}
```

Use `input_ids: ["*"]` to select every enabled compatible input. By default, a trace tagged `independent_lfsr` may only be assigned to an independent architecture, and a `shared_lfsr` trace may only be assigned to a shared architecture. For a deliberate cross-family raw-replay comparison, set `allow_source_mismatch: true` on that architecture entry.

Every input and requested stage must select exactly one entry with `baseline: true`; this makes latency savings and normalized area unambiguous. The supported architecture set has two genuinely different RNG families, each combined with the supported preprocessing variants:

- Plain names (`baseline`, `sort`, `zero_delete`, and group-mask combinations) use independent per-input LFSRs.
- `lfsr*` names use one shared LFSR, with D receiving the sequence two accepted positions behind X.

Legacy `lfsr_per_input*` aliases are not supported because they duplicated the canonical plain-name family. RNG-only architecture differences are intentionally invisible in raw-replay latency but remain visible in synthesis area and timing. Shared-LFSR traces can now be explicitly paired with the canonical `lfsr*` architectures through the manifests.

Every enabled architecture must have both `RTL/architectures/<architecture>/TOP.v` and `SIM/FUNCTION/filelists/<architecture>.f`.

## Global configuration and results

`CUSTOM/experiment.conf` now contains only global defaults: manifest paths, stochastic word width, output-buffer depth, digital clock, default pulse sweep, LFSR seed, and synthesis target period. Trace path, dimension, `MAX_BL`, pulse source, and optional pulse-time overrides belong to `inputs.json`; architecture/input selection and stage switches belong to `architectures.json`.

Specify `LFSR_SEED` as a positive decimal integer (for example, `44257` for `16'hACE1`), because the VCS launcher re-evaluates `-pvalue` arguments and cannot safely carry an HDL apostrophe literal.

The driver validates both manifests and writes the normalized plan to `CUSTOM/work/experiment_plan.json` before running. It also cross-checks every enabled manifest entry against the literal feature and RNG flags in its RTL wrapper. Input-specific work, logs, per-update results, and synthesis reports are separated by input ID, so different dimensions and `MAX_BL` configurations cannot overwrite one another.

Generated outputs are:

```text
CUSTOM/results/
  summary.md
  summary.csv
  latency.csv
  synthesis.csv
  energy.csv
  run_status.csv
  per_update/<input_id>/<architecture>_<pulse>ns.csv
```

The same summary, latency, synthesis, and energy tables are copied to `CUSTOM/reports/`.

Latency summaries include input ID and configuration, update count, input BL, output pulse positions, reduction, mean/median/std/P95 latency, per-input baseline savings, speedup, and validation status. Synthesis summaries include input ID and configuration, total/combinational/sequential cell area, area normalized to that input's baseline, cell count, target period, setup slack and violations, estimated minimum period and Fmax, setup/DRC status, and advisory hold data. Energy summaries include average power over the replay SAIF window, replay-window energy, energy per asserted input pulse bit, SAIF duration, annotation coverage when the Synopsys report exposes it, a diagnostic field, and per-point status. `run_status.csv` records power separately from synthesis, so a power-analysis failure cannot masquerade as a synthesis failure or a successful experiment. Savings and normalized area remain blank if the corresponding baseline failed, preventing invalid comparisons.
