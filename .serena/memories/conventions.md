# Conventions

- Each experiment ID needs: a filelist `SIM/FUNCTION/filelists/<id>.f`, a `TOP` wrapper source, and `SIM/TESTBENCH/TB_TOP_<ID_UPPER>.v`.
- Testbench wrapper defines `ARCHITECTURE_NAME` exactly equal to the lowercase experiment ID. Group-mask variants also define/undefine `GROUP_MASK_ARCHITECTURE`.
- Keep existing `lfsr*` wrappers at `USE_SHARED_LFSR=1`. Per-input companions use `USE_SHARED_LFSR=0` and otherwise mirror the feature flags.
- `ENABLE_D_GROUP_MASK=1` selects sorted-specialized grouping when sorting is enabled; value 2 forces generic/standard grouping.
- Filelists explicitly include all common modules and end with exactly one architecture wrapper defining module `TOP`.
- Current TB checks the live accepted pre-FIFO stream or group-update equivalence; generated `.expected` files are not consumed by `TB_ARCHITECTURE_BODY.vh`.
