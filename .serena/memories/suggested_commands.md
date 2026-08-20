# Suggested commands

- One functional run:
  `cd SIM/FUNCTION && ./execute_function.csh <architecture> TB_TOP_<ARCHITECTURE_UPPER>`
- Matching activity-aware synthesis:
  `cd SYN_topo && ./run_synthesis <architecture> TB_TOP_<ARCHITECTURE_UPPER>`
- Enabled default CUSTOM matrix:
  `bash CUSTOM/run_all.sh`
- Full shared/per-input LFSR comparison matrix:
  `bash CUSTOM/run_lfsr_families.sh`
- Parse existing run data only:
  `python3 CUSTOM/extract_results.py`
- Architecture IDs are lowercase snake_case; uppercase the whole ID for the default TB module/file name.
