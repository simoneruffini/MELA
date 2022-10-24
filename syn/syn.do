set fp [open "./compile_syn.f" r]
set files_to_analyze [read $fp]
puts "\n############## Analyzing VHDL files ##############\n"
foreach line [split $files_to_analyze "\n"] {
    puts "--> analyzing: $line"
    analyze -library work -format vhdl "$line"
}
exit
puts "\n##########  SIMULATION ENDS  ##########\n"
set dump_file [open "rf_dmem.dump" w]
//set dump_file [open "rf_dmem.dump" a]
//puts $dump_file ""
//puts $dump_file [clock format [clock seconds] -format {%D %T}]
puts "REGISTER FILE MEMORY DUMP"
set reg_val [examine sim:/tb_cpu/U_CPU/U_DATAPATH/U_RF/registers]
puts $reg_val
puts $dump_file "REGISTER FILE MEMORY DUMP"
puts $dump_file $reg_val 
puts $dump_file ""
puts "DATA MEMORY DUMP"
set dmem_val [examine sim:/tb_cpu/U_DMEM/mem]
puts $dmem_val
puts $dump_file "DATA MEMORY DUMP"
puts $dump_file $dmem_val
//puts $dump_file ""
exit
