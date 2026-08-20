# Per-input LFSR architecture family

The existing `lfsr*` architecture IDs retain the shared-LFSR implementation.
Each companion has its own `RTL/architectures/<id>/TOP.v` wrapper and matching
simulation filelist. These wrappers select `ARCH_TOP.USE_SHARED_LFSR=0`, which
instantiates one LFSR for every X lane and every D lane. All X/D instances use
different nonzero reset seeds.

| Shared architecture | Per-input architecture |
| --- | --- |
| `lfsr` | `lfsr_per_input` |
| `lfsr_group_mask` | `lfsr_per_input_group_mask` |
| `lfsr_sort` | `lfsr_per_input_sort` |
| `lfsr_sort_group_mask` | `lfsr_per_input_sort_group_mask` |
| `lfsr_sort_zero_delete` | `lfsr_per_input_sort_zero_delete` |
| `lfsr_sort_zero_delete_group_mask` | `lfsr_per_input_sort_zero_delete_group_mask` |
| `lfsr_sort_zero_delete_standard_group_mask` | `lfsr_per_input_sort_zero_delete_standard_group_mask` |
| `lfsr_zero_delete` | `lfsr_per_input_zero_delete` |
| `lfsr_zero_delete_group_mask` | `lfsr_per_input_zero_delete_group_mask` |

Run one architecture directly with, for example:

```bash
cd SIM/FUNCTION
./execute_function.csh lfsr_per_input TB_TOP_LFSR_PER_INPUT

cd ../../SYN_topo
./run_synthesis lfsr_per_input TB_TOP_LFSR_PER_INPUT
```

Run every architecture enabled in `CUSTOM/architectures.txt` with:

```bash
bash CUSTOM/run_all.sh
```
