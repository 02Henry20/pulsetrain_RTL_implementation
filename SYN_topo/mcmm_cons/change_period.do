#!/bin/tcsh

set n = 1

set x = $argv[$n]

sed -i 's/-period \([0-9]\{1\}\) /-period '$x' /g' *.tcl
sed -i 's/-period \([0-9]\{2\}\) /-period '$x' /g' *.tcl
sed -i 's/-period \([0-9]\{3\}\) /-period '$x' /g' *.tcl
sed -i 's/-period \([0-9]\{4\}\) /-period '$x' /g' *.tcl
sed -i 's/-period \([0-9]\{5\}\) /-period '$x' /g' *.tcl
sed -i 's/-period \([0-9]\{6\}\) /-period '$x' /g' *.tcl

sed -i 's/-period \([0-9]\{1\}\).\([0-9]\{1\}\) /-period '$x' /g' *.tcl
sed -i 's/-period \([0-9]\{2\}\).\([0-9]\{1\}\) /-period '$x' /g' *.tcl
sed -i 's/-period \([0-9]\{3\}\).\([0-9]\{1\}\) /-period '$x' /g' *.tcl
sed -i 's/-period \([0-9]\{4\}\).\([0-9]\{1\}\) /-period '$x' /g' *.tcl
sed -i 's/-period \([0-9]\{5\}\).\([0-9]\{1\}\) /-period '$x' /g' *.tcl
sed -i 's/-period \([0-9]\{6\}\).\([0-9]\{1\}\) /-period '$x' /g' *.tcl


