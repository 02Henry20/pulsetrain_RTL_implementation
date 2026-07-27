# Architecture Experiment Automation

`run_all.sh` runs the complete activity-aware flow for every enabled architecture:

1. Remove old simulation, synthesis, and custom log data only for enabled architectures.
2. Run `SIM/FUNCTION/execute_function.csh`, which compiles, simulates, and creates SAIF activity.
3. Confirm the testbench reported `RESULT: PASS`, zero metric errors, and a nonempty SAIF file.
4. Run `SYN_topo/run_synthesis <architecture> <testbench>` using that SAIF activity.
5. Extract a compact cross-architecture summary.

Run from the repository root:

```bash
bash CUSTOM/run_all.sh
```

Edit `architectures.txt` to select architectures. A line beginning with `#` is disabled. Simulation runs, synthesis runs, logs, and status rows belonging to disabled architectures are preserved. The old `--keep-old` option is still accepted for command compatibility, but preserving disabled runs is now the default behavior.

The terminal shows only stage-level `RUN`, `PASS`, `WARN`, and `FAIL` messages plus the final table. `PASS` means synthesis completed with clean final setup, hold, transition, and capacitance checks. `WARN` means synthesis completed and produced all required reports, but the final QoR report contains violations. `FAIL` means a stage failed or required log/report data is missing or unreadable. Full tool output is retained in `CUSTOM/logs` and in each native run directory.

Generated tables:

- `CUSTOM/results/summary.md`: readable report with overview, timing/area, and activity tables.
- `CUSTOM/results/summary.csv`: complete machine-readable metric table.
- `CUSTOM/results/run_status.csv`: stage status and log location for every requested architecture.

The parser can also be rerun without simulation or synthesis:

```bash
python3 CUSTOM/extract_results.py
```

The reported maximum frequency is an estimate from the limiting constrained timing group: `1000 / (target period - setup slack)` MHz. Energy per set is total reported SAIF-based power multiplied by average set duration at the functional-simulation clock, keeping the power and activity time bases consistent.
