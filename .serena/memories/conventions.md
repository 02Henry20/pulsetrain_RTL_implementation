# Conventions

- Each enabled experiment ID needs `RTL/architectures/<id>/TOP.v` and `SIM/FUNCTION/filelists/<id>.f`; `CUSTOM/architectures.txt` is the source of truth.
- All architecture wrappers expose `RAW_REPLAY_MODE` with default 0 plus raw X/D pulse inputs, and pass them to the single common `ARCH_TOP`.
- Plain architecture IDs use `USE_SHARED_LFSR=0` (independent per-input RNG). `lfsr*` IDs use `USE_SHARED_LFSR=1` (shared RNG). Do not add duplicate `lfsr_per_input*` aliases.
- `ENABLE_D_GROUP_MASK=1` selects sorted-specialized grouping when sorting is enabled.
- Filelists explicitly include required common modules and end with exactly one architecture wrapper defining module `TOP`.
- The active latency testbench is `SIM/TESTBENCH/TB_REPLAY.sv`; it replays realized binary pulse positions and uses architecture expectation plusargs for transform validation.
- Latency uses 10 ns / 100 MHz. Synthesis uses `RAW_REPLAY_MODE=0` and the separately configured target period.
