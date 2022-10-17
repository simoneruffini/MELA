#! /bin/env bash

# Overridable variables
VHDL_SRCS_LIST_FILE="./compile.f"

# Enter in the pwd of the script so the files that it uses work correctly
base_dir=$(dirname $0)
cd $base_dir

# Source this file to be able to run vsim,vcom,vlog etc...
source /software/scripts/init_questa10.7c

# delete work folder
vdel -all
vlib work

echo "#########################################"
echo "####                                 ####"
echo "##            COMPILATION              ##"
echo "####                                 ####"
echo "#########################################"

# First compile VHDL files then if all ok verilog ones
vcom -F $VHDL_SRCS_LIST_FILE -2008

# check if verilog file compilation went ok otherwise exit
if [ $? -ne 0 ]; then  exit; fi

# run simulation if requested 

# if first parameter is empty OR is not empty but not equal to all
# then exit
if [ -z "$1" ] || ([ -n "$1" ] && [ "$1" != "all" ]) ; then exit; fi 

echo "#########################################"
echo "####                                 ####"
echo "##             SIMULATION              ##"
echo "####                                 ####"
echo "#########################################"

# Simulate the acc_tb entity using sim.do tcl script
vsim -onfinish stop -c -sv_seed random -do sim.do tb_CPU
