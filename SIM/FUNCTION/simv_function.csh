#!/bin/tcsh -f

set FUNCTION_DIR = $cwd
set SELECTED_FILE = "${FUNCTION_DIR}/.selected_run"

if (! -e "${SELECTED_FILE}") then
    echo "No selected architecture/testbench found."
    echo "Run ./run_function.csh first."
    exit 1
endif

set RUN_INFO = (`cat "${SELECTED_FILE}"`)

if ($#RUN_INFO != 3) then
    echo "Invalid .selected_run file."
    exit 1
endif

set ARCH       = "$RUN_INFO[1]"
set TOP_MODULE = "$RUN_INFO[2]"
set RUN_DIR    = "$RUN_INFO[3]"

if (! -x "${RUN_DIR}/simv") then
    echo "Simulation executable not found:"
    echo "  ${RUN_DIR}/simv"
    exit 1
endif

echo "Architecture : ${ARCH}"
echo "Testbench    : ${TOP_MODULE}"
echo "Run directory: ${RUN_DIR}"

cd "${RUN_DIR}"

./simv \
-ucli \
-i fsdb_auto.tcl \
-l simulation.log

set SIM_STATUS = $status

cd "${FUNCTION_DIR}"

if (${SIM_STATUS} != 0) then
    echo "Simulation failed."
    echo "See: ${RUN_DIR}/simulation.log"
    exit ${SIM_STATUS}
endif

echo "Simulation finished."
echo "Results stored in: ${RUN_DIR}"