onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_cpu/clk
add wave -noupdate -color Coral /tb_cpu/rst_an
add wave -noupdate -expand -group pipeline -color Gold /tb_cpu/U_CPU/dbg_fetch
add wave -noupdate -expand -group pipeline -color {Medium Slate Blue} /tb_cpu/U_CPU/dbg_decode
add wave -noupdate -expand -group pipeline -color {Orange Red} /tb_cpu/U_CPU/dbg_execute
add wave -noupdate -expand -group pipeline -color Cyan /tb_cpu/U_CPU/dbg_memory
add wave -noupdate -expand -group pipeline -color Orange /tb_cpu/U_CPU/dbg_writeback
add wave -noupdate -group PC -expand -group PC_MUX /tb_cpu/U_CPU/U_DATAPATH/is_0_m
add wave -noupdate -group PC -expand -group PC_MUX /tb_cpu/U_CPU/U_DATAPATH/npc_sel_f
add wave -noupdate -group PC -color Blue /tb_cpu/U_CPU/U_DATAPATH/pc_f
add wave -noupdate -group PC /tb_cpu/U_CPU/U_DATAPATH/npc_f
add wave -noupdate -group PC /tb_cpu/U_CPU/U_DATAPATH/pc_pls_4_f
add wave -noupdate -group PC /tb_cpu/U_CPU/U_DATAPATH/pc_init
add wave -noupdate /tb_cpu/U_CPU/U_DATAPATH/INSTR_CU
add wave -noupdate -color {Violet Red} /tb_cpu/U_CPU/ctrl_word
add wave -noupdate -color {Green Yellow} /tb_cpu/U_CPU/U_HU/HZRD_SIG
add wave -noupdate -group RF -label RF -childformat {{/tb_cpu/U_CPU/U_DATAPATH/U_RF/registers(9) -radix decimal} {/tb_cpu/U_CPU/U_DATAPATH/U_RF/registers(10) -radix decimal} {/tb_cpu/U_CPU/U_DATAPATH/U_RF/registers(11) -radix decimal}} -subitemconfig {/tb_cpu/U_CPU/U_DATAPATH/U_RF/registers(9) {-height 26 -radix decimal} /tb_cpu/U_CPU/U_DATAPATH/U_RF/registers(10) {-height 26 -radix decimal} /tb_cpu/U_CPU/U_DATAPATH/U_RF/registers(11) {-height 26 -radix decimal}} /tb_cpu/U_CPU/U_DATAPATH/U_RF/registers
add wave -noupdate -group RF /tb_cpu/U_CPU/U_DATAPATH/U_RF/ENABLE
add wave -noupdate -group RF -radix unsigned /tb_cpu/U_CPU/U_DATAPATH/U_RF/ADD_RD1
add wave -noupdate -group RF /tb_cpu/U_CPU/U_DATAPATH/U_RF/OUT1
add wave -noupdate -group RF -radix unsigned /tb_cpu/U_CPU/U_DATAPATH/U_RF/ADD_RD2
add wave -noupdate -group RF /tb_cpu/U_CPU/U_DATAPATH/U_RF/OUT2
add wave -noupdate -group RF -color Wheat /tb_cpu/U_CPU/U_DATAPATH/U_RF/WR
add wave -noupdate -group RF -color Wheat /tb_cpu/U_CPU/U_DATAPATH/U_RF/DATAIN
add wave -noupdate -group RF -color Wheat -radix unsigned /tb_cpu/U_CPU/U_DATAPATH/U_RF/ADD_WR
add wave -noupdate -group IMEM /tb_cpu/U_CPU/U_IMEM/mem
add wave -noupdate -group IMEM /tb_cpu/U_CPU/U_IMEM/RADDR
add wave -noupdate -group IMEM /tb_cpu/U_CPU/U_IMEM/truncated_raddr
add wave -noupdate -group IMEM /tb_cpu/U_CPU/U_IMEM/DOUT
add wave -noupdate -group FETCH_DECODE /tb_cpu/U_CPU/U_DATAPATH/U_PC_PLS_4_REG_FD/reg_mem
add wave -noupdate -group FETCH_DECODE /tb_cpu/U_CPU/U_DATAPATH/U_INSTR_REG_FD/reg_mem
add wave -noupdate -group DECODE_EXECUTE -radix decimal /tb_cpu/U_CPU/U_DATAPATH/imm_i_type_d
add wave -noupdate -group DECODE_EXECUTE -radix decimal /tb_cpu/U_CPU/U_DATAPATH/imm_j_type_d
add wave -noupdate -group DECODE_EXECUTE -radix decimal /tb_cpu/U_CPU/U_DATAPATH/imm_i_type_ext_d
add wave -noupdate -group DECODE_EXECUTE -radix decimal /tb_cpu/U_CPU/U_DATAPATH/imm_j_type_ext_d
add wave -noupdate -group DECODE_EXECUTE /tb_cpu/U_CPU/U_DATAPATH/U_PC_PLS_4_REG_DE/reg_mem
add wave -noupdate -group DECODE_EXECUTE /tb_cpu/U_CPU/U_DATAPATH/U_RF_DOUT1_REG_DE/reg_mem
add wave -noupdate -group DECODE_EXECUTE /tb_cpu/U_CPU/U_DATAPATH/U_RF_DOUT2_REG_DE/reg_mem
add wave -noupdate -group DECODE_EXECUTE /tb_cpu/U_CPU/U_DATAPATH/U_IMM_REG_DE/reg_mem
add wave -noupdate -group DECODE_EXECUTE /tb_cpu/U_CPU/U_DATAPATH/U_RS2_REG_DE/reg_mem
add wave -noupdate -group DECODE_EXECUTE /tb_cpu/U_CPU/U_DATAPATH/U_RS3_REG_DE/reg_mem
add wave -noupdate -group EXECUTE_MEMORY /tb_cpu/U_CPU/U_DATAPATH/U_ALU_OUT_REG_EM/reg_mem
add wave -noupdate -group EXECUTE_MEMORY /tb_cpu/U_CPU/U_DATAPATH/U_DMEM_DOUT_REG_EM/reg_mem
add wave -noupdate -group EXECUTE_MEMORY /tb_cpu/U_CPU/U_DATAPATH/U_RF_WADDR_REG_EM/reg_mem
add wave -noupdate -group EXECUTE_MEMORY /tb_cpu/U_CPU/U_DATAPATH/U_IS_0_REG_EM/reg_mem
add wave -noupdate -group MEMORY_WRITEBACK /tb_cpu/U_CPU/U_DATAPATH/U_ALU_OUT_REG_MWB/reg_mem
add wave -noupdate -group MEMORY_WRITEBACK /tb_cpu/U_CPU/U_DATAPATH/U_DMEM_DOUT_REG_MWB/reg_mem
add wave -noupdate -group MEMORY_WRITEBACK /tb_cpu/U_CPU/U_DATAPATH/U_RF_WADDR_REG_MWB/reg_mem
add wave -noupdate -group WRITEBACK /tb_cpu/U_CPU/U_DATAPATH/rf_din_wb
add wave -noupdate -expand -group ALU /tb_cpu/U_CPU/U_DATAPATH/U_ALU/A
add wave -noupdate -expand -group ALU /tb_cpu/U_CPU/U_DATAPATH/U_ALU/B
add wave -noupdate -expand -group ALU /tb_cpu/U_CPU/U_DATAPATH/U_ALU/RES
add wave -noupdate -expand -group ALU /tb_cpu/U_CPU/U_DATAPATH/U_ALU/FUNC
add wave -noupdate -group DMEM /tb_cpu/U_CPU/U_DMEM/mem
add wave -noupdate -group DMEM /tb_cpu/U_CPU/U_DMEM/WEN
add wave -noupdate -group DMEM /tb_cpu/U_CPU/U_DMEM/DIN
add wave -noupdate -group DMEM /tb_cpu/U_CPU/U_DMEM/RWADDR
add wave -noupdate -group DMEM /tb_cpu/U_CPU/U_DMEM/DOUT
add wave -noupdate -expand -group HU -expand /tb_cpu/U_CPU/U_HU/DP_SIG
add wave -noupdate -expand -group HU /tb_cpu/U_CPU/U_HU/flush_pipeline_branch
add wave -noupdate -expand -group HU /tb_cpu/U_CPU/U_HU/dbg_instr_opcode_m
add wave -noupdate -group CU /tb_cpu/U_CPU/U_CU/HZRD_SIG
add wave -noupdate -group CU /tb_cpu/U_CPU/U_CU/control_word
add wave -noupdate -group CU -expand -group fetch_time /tb_cpu/U_CPU/U_CU/decode_sig
add wave -noupdate -group CU -expand -group fetch_time /tb_cpu/U_CPU/U_CU/execute_sig
add wave -noupdate -group CU -expand -group fetch_time /tb_cpu/U_CPU/U_CU/memory_sig
add wave -noupdate -group CU -expand -group fetch_time /tb_cpu/U_CPU/U_CU/writeback_sig
add wave -noupdate -group CU -group decode_time /tb_cpu/U_CPU/U_CU/decode_sig_d1
add wave -noupdate -group CU -group decode_time /tb_cpu/U_CPU/U_CU/execute_sig_d1
add wave -noupdate -group CU -group decode_time /tb_cpu/U_CPU/U_CU/memory_sig_d1
add wave -noupdate -group CU -group decode_time /tb_cpu/U_CPU/U_CU/writeback_sig_d1
add wave -noupdate -group CU -group execute_time /tb_cpu/U_CPU/U_CU/execute_sig_d2
add wave -noupdate -group CU -group execute_time /tb_cpu/U_CPU/U_CU/memory_sig_d2
add wave -noupdate -group CU -group execute_time /tb_cpu/U_CPU/U_CU/writeback_sig_d2
add wave -noupdate -group CU -group memory_time /tb_cpu/U_CPU/U_CU/memory_sig_d3
add wave -noupdate -group CU -group memory_time /tb_cpu/U_CPU/U_CU/writeback_sig_d3
add wave -noupdate -group CU /tb_cpu/U_CPU/U_CU/writeback_sig_d4
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {51102970 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 349
configure wave -valuecolwidth 149
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {69417460 ps} {80556980 ps}
