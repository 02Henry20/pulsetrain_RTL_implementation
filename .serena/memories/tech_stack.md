# Tech stack

- RTL: Verilog/SystemVerilog accepted by Synopsys VCS and Design Compiler Topographical.
- Simulation orchestration: tcsh scripts under `SIM/FUNCTION`; FSDB activity converted to SAIF.
- Synthesis orchestration: tcsh `SYN_topo/run_synthesis` plus Tcl reference-methodology setup.
- Batch experiments/reporting: Bash `CUSTOM/run_all.sh`; Python 3 `CUSTOM/extract_results.py`.
- Functional architecture filelists are the single RTL-source selection reused by simulation and synthesis.
