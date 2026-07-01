#!/bin/tcsh -f

# Usage:
# ./execute_function.csh zero_delete
# ./execute_function.csh zero_delete TB_TOP_ZERO_DELETE

if ($#argv < 1 || $#argv > 2) then
    echo "Usage: $0 <architecture> [testbench]"
    echo ""
    echo "Examples:"
    echo "  $0 zero_delete"
    echo "  $0 zero_delete TB_TOP_ZERO_DELETE"
    exit 1
endif

set ARCH         = "$argv[1]"
set FUNCTION_DIR = $cwd

if ($#argv == 2) then
    set TB_NAME = "$argv[2]"
endif

echo "========================================"
echo "Architecture: ${ARCH}"

if ($#argv == 2) then
    echo "Testbench:   ${TB_NAME}"
endif

echo "========================================"

echo ""
echo "[1/3] Cleaning previous run..."

if ($#argv == 2) then
    "${FUNCTION_DIR}/clean.csh" "${ARCH}" "${TB_NAME}"
else
    "${FUNCTION_DIR}/clean.csh" "${ARCH}"
endif

# A missing previous run should not prevent execution.
if ($status != 0) then
    echo "No previous run found. Continuing."
endif

echo ""
echo "[2/3] Compiling..."

if ($#argv == 2) then
    "${FUNCTION_DIR}/run_function.csh" "${ARCH}" "${TB_NAME}"
else
    "${FUNCTION_DIR}/run_function.csh" "${ARCH}"
endif

if ($status != 0) then
    echo "Compilation failed."
    exit 1
endif

echo ""
echo "[3/3] Running simulation..."

"${FUNCTION_DIR}/simv_function.csh"

if ($status != 0) then
    echo "Simulation failed."
    exit 1
endif

echo ""
echo "========================================"
echo "Completed successfully: ${ARCH}"

if ($#argv == 2) then
    echo "Testbench: ${TB_NAME}"
endif

echo "========================================"