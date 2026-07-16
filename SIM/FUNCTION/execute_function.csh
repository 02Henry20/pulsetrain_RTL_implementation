#!/bin/tcsh -f

# Usage:
# ./execute_function.csh zero_delete
# ./execute_function.csh zero_delete TB_TOP_ZERO_DELETE_FULL

if ($#argv < 1 || $#argv > 2) then
    echo "Usage: $0 <architecture> [testbench]"
    echo ""
    echo "Examples:"
    echo "  $0 zero_delete"
    echo "  $0 zero_delete TB_TOP_ZERO_DELETE_FULL"
    exit 1
endif

set SCRIPT_DIR   = `dirname "$0"`
set FUNCTION_DIR = `cd "${SCRIPT_DIR}" && pwd`

set ARCH       = "$argv[1]"
set ARCH_UPPER = `echo "${ARCH}" | tr '[:lower:]' '[:upper:]'`

if ($#argv == 2) then
    set TB_NAME         = "$argv[2]"
    set TB_WAS_PROVIDED = 1
else
    set TB_NAME         = "TB_TOP_${ARCH_UPPER}"
    set TB_WAS_PROVIDED = 0
endif

echo "========================================"
echo "FUNCTIONAL SIMULATION"
echo "========================================"
echo "Architecture: ${ARCH}"
echo "Testbench   : ${TB_NAME}"
echo "========================================"

echo ""
echo "[1/4] Cleaning previous run..."

if (${TB_WAS_PROVIDED} == 1) then
    "${FUNCTION_DIR}/clean.csh" "${ARCH}" "${TB_NAME}"
else
    "${FUNCTION_DIR}/clean.csh" "${ARCH}"
endif

if ($status != 0) then
    echo "No previous run found. Continuing."
endif

echo ""
echo "[2/4] Compiling..."

if (${TB_WAS_PROVIDED} == 1) then
    "${FUNCTION_DIR}/run_function.csh" "${ARCH}" "${TB_NAME}"
else
    "${FUNCTION_DIR}/run_function.csh" "${ARCH}"
endif

if ($status != 0) then
    echo "Compilation failed."
    exit 1
endif

echo ""
echo "[3/4] Running simulation..."

"${FUNCTION_DIR}/simv_function.csh"

if ($status != 0) then
    echo "Simulation failed."
    exit 1
endif

echo ""
echo "[4/4] Generating SAIF..."

"${FUNCTION_DIR}/fsdb2saif.csh" "${ARCH}" "${TB_NAME}"

if ($status != 0) then
    echo "SAIF generation failed."
    exit 1
endif

echo ""
echo "========================================"
echo "COMPLETED SUCCESSFULLY"
echo "========================================"
echo "Architecture: ${ARCH}"
echo "Testbench   : ${TB_NAME}"
echo "Run path    : ${FUNCTION_DIR}/runs/${ARCH}/${TB_NAME}"
echo "========================================"

exit 0
