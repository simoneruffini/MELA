puts "\n########## SIMULATION STARTS ##########\n"
run -all 1ms
puts "\n##########  SIMULATION ENDS  ##########\n"
puts "REGISTER FILE MEMORY DUMP"
examine sim:/tb_cpu/U_CPU/U_DATAPATH/U_RF/registers 
puts "DATA MEMORY DUMP"
examine sim:/tb_cpu/U_CPU/U_DMEM/mem
exit
