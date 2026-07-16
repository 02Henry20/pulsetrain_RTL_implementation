#!/bin/tcsh -f

# Usage:
# ./fsdb2saif.csh zero_delete TB_TOP_ZERO_DELETE
# ./fsdb2saif.csh zero_delete TB_TOP_ZERO_DELETE_FULL

if ($#argv != 2) then
    echo "Usage: $0 <architecture> <testbench>"
    exit 1
endif

set SCRIPT_DIR   = `dirname "$0"`
set FUNCTION_DIR = `cd "${SCRIPT_DIR}" && pwd`

set ARCH    = "$argv[1]"
set TB_NAME = "$argv[2]"

set RUN_DIR = "${FUNCTION_DIR}/runs/${ARCH}/${TB_NAME}"

set BASENAME  = "${ARCH}_${TB_NAME}"
set FSDB_FILE = "${RUN_DIR}/${BASENAME}.fsdb"
set VCD_FILE  = "${RUN_DIR}/${BASENAME}.vcd"
set SAIF_FILE = "${RUN_DIR}/${BASENAME}.saif"

if (! -d "${RUN_DIR}") then
    echo "ERROR: Run directory not found:"
    echo "  ${RUN_DIR}"
    exit 1
endif

if (! -e "${FSDB_FILE}") then
    echo "ERROR: FSDB file not found:"
    echo "  ${FSDB_FILE}"
    exit 1
endif

which fsdb2vcd >& /dev/null
if ($status != 0) then
    echo "ERROR: fsdb2vcd is not available."
    exit 1
endif

which vcd2saif >& /dev/null
if ($status != 0) then
    echo "ERROR: vcd2saif is not available."
    exit 1
endif

echo "========================================"
echo "FSDB TO SAIF"
echo "========================================"
echo "Architecture: ${ARCH}"
echo "Testbench   : ${TB_NAME}"
echo "FSDB        : ${FSDB_FILE}"
echo "VCD         : ${VCD_FILE}"
echo "SAIF        : ${SAIF_FILE}"
echo "========================================"

rm -f "${VCD_FILE}"
rm -f "${SAIF_FILE}"

fsdb2vcd "${FSDB_FILE}" -o "${VCD_FILE}"

if ($status != 0 || ! -e "${VCD_FILE}") then
    echo "ERROR: FSDB-to-VCD conversion failed."
    exit 1
endif

vcd2saif \
    -input "${VCD_FILE}" \
    -output "${SAIF_FILE}"

if ($status != 0 || ! -e "${SAIF_FILE}") then
    echo "ERROR: VCD-to-SAIF conversion failed."
    exit 1
endif

echo "SAIF generated:"
echo "  ${SAIF_FILE}"

exit 0
