#!/bin/tcsh -f

set FUNCTION_DIR = $cwd
set RUNS_DIR     = "${FUNCTION_DIR}/runs"

# Usage:
# ./clean.csh
# ./clean.csh zero_delete
# ./clean.csh zero_delete TB_TOP

if ($#argv > 2) then
    echo "Usage: $0 [architecture] [testbench]"
    echo ""
    echo "Examples:"
    echo "  $0"
    echo "  $0 zero_delete"
    echo "  $0 zero_delete TB_TOP"
    exit 1
endif

# No arguments: remove all runs
if ($#argv == 0) then
    if (-d "${RUNS_DIR}") then
        rm -rf "${RUNS_DIR}"
        echo "Removed all simulation runs."
    else
        echo "No simulation runs found."
    endif

    rm -f "${FUNCTION_DIR}/.selected_run"
    exit 0
endif

set ARCH = "$argv[1]"
set TARGET = "${RUNS_DIR}/${ARCH}"

# Architecture and testbench provided
if ($#argv == 2) then
    set TOP_MODULE = "$argv[2]"
    set TARGET = "${TARGET}/${TOP_MODULE}"
endif

if (! -d "${TARGET}") then
    echo "Run directory not found:"
    echo "  ${TARGET}"
    exit 1
endif

rm -rf "${TARGET}"
echo "Removed:"
echo "  ${TARGET}"

# Remove empty parent architecture directory
if ($#argv == 2) then
    set ARCH_DIR = "${RUNS_DIR}/${ARCH}"

    if (-d "${ARCH_DIR}") then
        set REMAINING = (`find "${ARCH_DIR}" -mindepth 1 -maxdepth 1`)

        if ($#REMAINING == 0) then
            rmdir "${ARCH_DIR}"
        endif
    endif
endif

# Clear .selected_run if it points to the deleted directory
if (-e "${FUNCTION_DIR}/.selected_run") then
    set RUN_INFO = (`cat "${FUNCTION_DIR}/.selected_run"`)

    if ($#RUN_INFO == 3) then
        set SELECTED_RUN_DIR = "$RUN_INFO[3]"

        if ("${SELECTED_RUN_DIR}" =~ "${TARGET}"*) then
            rm -f "${FUNCTION_DIR}/.selected_run"
        endif
    endif
endif