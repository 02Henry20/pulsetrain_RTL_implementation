# Suggested commands

- Full supported paper experiment: `bash CUSTOM/run_all.sh`
- Validate/pack a raw binary trace: `python3 CUSTOM/prepare_trace.py <input.csv> <trace.replay> <stats.csv> --dimension <N> --max-bl <BL>`
- Compile one replay architecture from `SIM/FUNCTION`: `vcs -full64 -sverilog -timescale=1ns/1ps -top TB_REPLAY -f filelists/<architecture>.f ../TESTBENCH/TB_REPLAY.sv ...`
- Synthesize one complete hardware architecture without SAIF: `cd SYN_topo && ./run_synthesis <architecture>`
- Enabled architecture IDs are the canonical lowercase names in `CUSTOM/architectures.txt`; do not use historical `lfsr_per_input*` aliases.
