# SS28_SCRIPT core

- SystemVerilog architecture-experiment repository for stochastic X/D pulse generation and preprocessing.
- Source flow: `RTL/common` reusable datapath; `RTL/architectures` thin `TOP` wrappers; `SIM/FUNCTION/filelists/<architecture>.f` compile selection; `SIM/TESTBENCH/TB_TOP_<ARCH>.v` experiment tops; `SYN_topo/run_synthesis` consumes the same filelist; `CUSTOM` automates simulation → SAIF → synthesis → reports.
- `ARCH_TOP` selects shared-vs-per-input LFSR behavior with `USE_SHARED_LFSR`: 1 is one shared LFSR (D delayed two accepted cycles); 0 is independently seeded LFSRs for every X and D lane in the current RTL.
- Existing `lfsr*` IDs remain the shared family. Companion `lfsr_per_input*` IDs compile `TOP_PER_INPUT_LFSR.v` beside each shared wrapper.
- Simulation/synthesis run directories are generated artifacts, not architecture source.
- Tooling/build details: `mem:tech_stack`. Commands: `mem:suggested_commands`. Naming/flag rules: `mem:conventions`. Completion checks: `mem:task_completion`.
