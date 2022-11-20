#!/usr/bin/env bash

# Overridable variables
VHDL_SRCS_LIST_FILE="./compile_sim.f"

# Enter in the pwd of the script so the files that it uses work correctly
base_dir=$(dirname $0)
cd $base_dir

usage(){
    echo " Usage: $(basename $0) {sim|syn [design_name] [clk_period_ns]|-h|--help}"
}
help(){
    usage
    echo
    echo " $(basename $0) script compiles, simulates and synthesized the design in src folder"
    echo ""
    echo " $(basename $0)"
    echo "   This will compile the design with vcom using ./sim/compile_sim.f order list"
    echo ""
    echo " $(basename $0) sim "
    echo "   This will simulate the design using the tcl script found in ./sim/compile_sim.do"
    echo
    echo " $(basename $0) syn CFG_CPU_STRUCT 1.2"
    echo "   This will synthesize the configuration CFG_CPU_STUCT with a clk period of 1.2 ns"
    echo "   using the tcl script find in ./syn/compile_syn.do"
    echo "   NOTE: design_name and clk_period_ns variables are required and must be valid"
    echo
    echo " $(basename $0) -h|--help"
    echo "   Will display this message"
}

if [ "$1" = "-h" ] || [ "$1" = "--help" ] ; then help; exit; fi

# if first parameter is `syn` then do synthesis
# then exit
if  [ "$1" = "syn" ] ; then 
    if [ -z "$2" ] || [ -z "$3" ] ; then
        usage
        echo "ERROR: missing deisng_name/config_name and/or clk_period_ns parameters"
        exit 1
    fi

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
    dc_shell-xg-t -no_log  -f syn.do -x "set design_name $2; set clk_period_ns $3" | tee design_compiler.log
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

