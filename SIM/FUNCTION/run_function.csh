#!/bin/tcsh -f

# Usage:
# ./run_function.csh zero_delete
# ./run_function.csh zero_delete_x_sort TB_TOP

if ($#argv < 1 || $#argv > 2) then
    echo "Usage: $0 <architecture> [testbench]"
    echo ""
    echo "Examples:"
    echo "  $0 zero_delete"
    echo "  $0 zero_delete_x_sort TB_TOP"
    exit 1
endif

set ARCH       = "$argv[1]"
set ARCH_UPPER = `echo "${ARCH}" | tr '[:lower:]' '[:upper:]'`
set TOP_MODULE = "TB_TOP_${ARCH_UPPER}"

if ($#argv == 2) then
    set TOP_MODULE = "$argv[2]"
endif

# Resolve paths from the script location instead of assuming the current directory.
set SCRIPT_DIR   = `dirname "$0"`
set FUNCTION_DIR = `cd "${SCRIPT_DIR}" && pwd`

set RTL_DIR = "${FUNCTION_DIR}/../../RTL"
set TB_DIR  = "${FUNCTION_DIR}/../TESTBENCH"

set ARCH_FILELIST = "${FUNCTION_DIR}/filelists/${ARCH}.f"
set TB_FILE       = "${TB_DIR}/${TOP_MODULE}.v"
set RUN_DIR       = "${FUNCTION_DIR}/runs/${ARCH}/${TOP_MODULE}"

# The testbench must instantiate the synthesizable TOP module as:
#
#   TOP ... dut (...);
#
# This instance name is used for DUT-only FSDB/SAIF activity.
set DUT_INSTANCE = "dut"

set ACTIVITY_BASENAME = "${ARCH}_${TOP_MODULE}"
set FSDB_FILE         = "${ACTIVITY_BASENAME}.fsdb"

# ---------------------------------------------------------
# Check requested architecture and testbench
# ---------------------------------------------------------

if (! -e "${ARCH_FILELIST}") then
    echo "Architecture file list not found:"
    echo "  ${ARCH_FILELIST}"
    exit 1
endif

if (! -e "${TB_FILE}") then
    echo "Testbench not found:"
    echo "  ${TB_FILE}"
    exit 1
endif

echo "Architecture : ${ARCH}"
echo "Testbench    : ${TOP_MODULE}"
echo "DUT instance : ${DUT_INSTANCE}"
echo "Output       : ${RUN_DIR}"

# ---------------------------------------------------------
# Recreate run directory
# ---------------------------------------------------------

if (-d "${RUN_DIR}") then
    rm -rf "${RUN_DIR}"
endif

mkdir -p "${RUN_DIR}"

# ---------------------------------------------------------
# Save selected run
# ---------------------------------------------------------

echo "${ARCH} ${TOP_MODULE} ${RUN_DIR}" >! \
    "${FUNCTION_DIR}/.selected_run"

# Store activity metadata for conversion and synthesis scripts.
echo "${ARCH} ${TOP_MODULE} ${DUT_INSTANCE} ${ACTIVITY_BASENAME}" >! \
    "${RUN_DIR}/activity.info"

# ---------------------------------------------------------
# Convert architecture file list to absolute paths
# ---------------------------------------------------------

awk -v base="${FUNCTION_DIR}" \
    '/^[[:space:]]*($|#)/ {print; next} \
     /^\// {print; next} \
     {print base "/" $0}' \
    "${ARCH_FILELIST}" \
    >! "${RUN_DIR}/filenames.f"

# Add selected testbench
echo "${TB_FILE}" >> "${RUN_DIR}/filenames.f"

# ---------------------------------------------------------
# Generate DUT-only FSDB commands
# ---------------------------------------------------------

cat >! "${RUN_DIR}/fsdb_auto.tcl" << EOF
call {\$fsdbDumpfile ("${FSDB_FILE}")};
call {\$fsdbDumpvars (0, ${TOP_MODULE}.${DUT_INSTANCE}, "+mda")};
run
exit
EOF

# ---------------------------------------------------------
# Compile
# ---------------------------------------------------------

cd "${RUN_DIR}"

vcs \
-full64 \
-debug_access+all \
-kdb \
-lca \
-cm line+tgl+assert+branch+cond+fsm \
+define+function_sim \
+define+mem_sim \
+incdir+${RTL_DIR}/common \
+incdir+${RTL_DIR}/architectures/${ARCH} \
+incdir+${TB_DIR} \
+incdir+${FUNCTION_DIR}/../../REF \
+incdir+/data/S28/library/ln28lpp_sc_9t_base_rvt_c130_V1.00c_pkg/FE-Common_sec190802_0203/MODEL \
+incdir+/data/S28/library/ln28lpp_gpio_1p8v_V1.00a_pkg/FE-Common_sec190321_0300/MODEL \
+incdir+/tools/Synopsys/DesignCompiler/syn/M-2016.12-SP5/dw/sim_ver \
+v2k \
+libext+.v \
-y /tools/Synopsys/DesignCompiler/syn/M-2016.12-SP5/dw/sim_ver \
-f filenames.f \
-top "${TOP_MODULE}" \
-o simv \
-l compile.log \
-override_timescale=1ns/10ps

set COMPILE_STATUS = $status

cd "${FUNCTION_DIR}"

if (${COMPILE_STATUS} != 0) then
    echo "Compilation failed."
    echo "See: ${RUN_DIR}/compile.log"
    exit ${COMPILE_STATUS}
endif

echo "Compilation finished."
echo "Results stored in: ${RUN_DIR}"
echo "Expected FSDB: ${RUN_DIR}/${FSDB_FILE}"
