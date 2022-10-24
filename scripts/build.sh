#! /bin/env bash

# Overridable variables
VHDL_SRCS_LIST_FILE="./compile_sim.f"

# Enter in the pwd of the script so the files that it uses work correctly
base_dir=$(dirname $0)
cd $base_dir

# if first parameter is `syn` then do synthesis
# then exit
if  [ "$1" = "syn" ] ; then 

    # Source this file to be able to run design compiler
    source "/software/scripts/init_synopsys_64.11"

    echo "#########################################"
    echo "####                                 ####"
    echo "##             SYNTHESIS               ##"
    echo "####                                 ####"
    echo "#########################################"
    # go in syn folder
    cd ../syn

    # create work dir for library work
    mkdir -p work

    # design compiler shell with XG suport and tcl 
    # https://www.edaboard.com/threads/whats-the-main-difference-between-dc_shell-dc_shell-t-dc_shell-xg-t.67023/
    dc_shell-xg-t -no_log -f syn.do
    exit $?
fi 

# Source this file to be able to run vsim,vcom,vlog etc...
source "/software/scripts/init_questa10.7c"

# outputs of comilation go into sim folder
cd ../sim

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
if [ $? -ne 0 ] ; then  exit; fi

# run simulation if requested 

# if first parameter is empty exit normally 
if [ -z "$1" ] ; then exit 0; fi

# if first parapeter is 'sim` do simulation 
# then exit
if [ "$1" = "sim" ] ; then 

    echo "#########################################"
    echo "####                                 ####"
    echo "##             SIMULATION              ##"
    echo "####                                 ####"
    echo "#########################################"

    # Simulate the tb_CPU entity using sim.do tcl script
    vsim -onfinish stop -c -sv_seed random -do sim.do tb_CPU
    exit $?
fi

