# Task completion

- Confirm every enabled architecture has a source wrapper, filelist, and derived TB top.
- Functional RTL changes: run `./execute_function.csh <id> TB_TOP_<ID_UPPER>`; require compile success, `RESULT: PASS`, zero metric/golden errors, and nonempty SAIF when synthesis activity is needed.
- Cross-architecture changes: run `bash CUSTOM/run_all.sh` or `bash CUSTOM/run_lfsr_families.sh`; inspect `CUSTOM/results/run_status.csv`.
- Synthesis-affecting changes: run matching `SYN_topo/run_synthesis`; require expected reports/results and no synthesis error markers.
- Run `serena memories check` after durable memory changes.
