# SS28_SCRIPT core

- SystemVerilog architecture-experiment repository for stochastic X/D pulse generation and preprocessing.
- Active paper flow: `CUSTOM/run_all.sh` reads `CUSTOM/architectures.txt` and `CUSTOM/experiment.conf`, losslessly converts realized binary AIHWKIT pulse positions, compiles `SIM/TESTBENCH/TB_REPLAY.sv` once per architecture, reuses each executable across the device-pulse sweep, synthesizes once without SAIF, and aggregates results.
- Latency mode is fixed at `DIGITAL_CLOCK_NS=10` (100 MHz). `RAW_REPLAY_MODE=1` bypasses stochastic generation and drives raw X/D pulse vectors directly into the shared preprocessing pipeline.
- Synthesis forces `RAW_REPLAY_MODE=0`, retaining LFSR and pulse-comparator hardware. `SYNTH_TARGET_PERIOD_NS` defaults to 3 ns and is propagated into all active MCMM `create_clock` constraints.
- `ARCH_TOP.USE_SHARED_LFSR=0` is the canonical plain-name family with independent X/D lane LFSRs. `USE_SHARED_LFSR=1` is the canonical `lfsr*` shared-RNG family with D delayed two accepted positions.
- `CUSTOM/architectures.txt` is the supported architecture source of truth. Legacy `lfsr_per_input*` aliases and old `TB_TOP_*` probability/SAIF infrastructure are obsolete.
- Simulation/synthesis run directories are generated artifacts, not architecture source.
- Tooling/build details: `mem:tech_stack`. Commands: `mem:suggested_commands`. Naming/flag rules: `mem:conventions`. Completion checks: `mem:task_completion`.
