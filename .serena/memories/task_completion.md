# Task completion

- Confirm every enabled ID in `CUSTOM/architectures.txt` has `RTL/architectures/<id>/TOP.v` and `SIM/FUNCTION/filelists/<id>.f`.
- Validate raw traces with `python3 CUSTOM/prepare_trace.py <csv> <replay> <stats> --dimension <N> --max-bl <BL>`; malformed BL, indices, binary lanes, dimensions, and metadata must fail.
- Syntax-check `CUSTOM/run_all.sh` with `bash -n`.
- Functional RTL changes: compile `TB_REPLAY.sv` once per relevant architecture and run at least `T_PULSE=1,10,100` ns with the 10 ns clock; require `RESULT: PASS`, exact BL consumption, stall stability, baseline identity, zero-delete legality, and coincidence preservation.
- Synthesis-affecting changes: run `SYN_topo/run_synthesis <architecture>`; require the precompile hierarchy report to contain LFSR and pulse-generator logic, constraints to use the configured target period, and no synthesis error markers.
- Cross-architecture changes: run `bash CUSTOM/run_all.sh`; inspect `CUSTOM/results/run_status.csv`, `summary.md`, latency CSVs, and synthesis CSVs.
- Run `graphify update .` after meaningful changes when the filesystem supports Graphify path handling.
