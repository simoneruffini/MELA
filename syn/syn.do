set fp [open "./compile_syn.f" r]
set files_to_analyze [read $fp]
proc color {foreground text} {
    # tput is a little Unix utility that lets you use the termcap database
    # *much* more easily...
    return [exec tput setaf $foreground]$text[exec tput sgr0]
}

puts [color 1 "\n############## Analyzing VHDL files ##############\n" ]
set not_ok 0
foreach line [split [string trim "$files_to_analyze" "\n"] "\n"] {
    puts [color 1 "--> analyzing: $line"]
    if {[analyze -library work -format vhdl "$line"] == 0} {
        puts [color 3 "--> ERROR analyzing: $line"]
        set not_ok 1
    }
}
if { $not_ok } { exit }
puts [ color 1 "Successfull Compilation!\n" ]


################################################################################################

# design_name and clk_period_ns are variables set from the external

puts [ color 1 "############## ELABORATE CPU ${design_name} ##############" ]

elaborate ${design_name} -update -library WORK

# Set the RC load of internal wires
set_wire_load_model -name 5K_hvratio_1_4

# Create Clock
create_clock -name "CLK" -period $clk_period_ns CLK
# Report the clock to check if it was created
report_clock

# set the fix_hold attribut on CLK clock signal
# The fix_hold attribute informs optimization that hold time violations of the specified clocks should be fixed.
# Fixing a hold violation requires slowing down data signals when possible.
set_fix_hold "CLK"

# set max delay for combinatorial netlist to same of clock
set_max_delay $clk_period_ns -from [all_inputs] -to [all_outputs]

puts [ color 1 "############## COMPILE CPU ${design_name} ##############" ]
compile -map_effort high

# Extract the critical path from the timing report

puts [ color 1 "############## WRITE REPORTS OF ${design_name} ##############" ]

exec mkdir -p reports
report_timing > "./reports/${design_name}_clk_${clk_period_ns}ns_timing.rpt"
report_area   > "./reports/${design_name}_clk_${clk_period_ns}ns_area.rpt"
report_power  > "./reports/${design_name}_clk_${clk_period_ns}ns_power.rpt"

puts [ color 1 "############## SAVE NETLIST OF ${design_name} ##############" ]
# Write NETLIST
exec mkdir -p netlists
write -format verilog -hierarchy -output "./netlists/${design_name}_${clk_period_ns}ns_postsyn.v"
exec mkdir -p design_compiler_sdc
write_sdc "./design_compiler_sdc/${design_name}_${clk_period_ns}ns_postsyn.sdc"
# Clean the library WORK


################################################################################################
exec rm -rf work
exit

