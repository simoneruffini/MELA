###################################################################

# Created by write_sdc on Thu Oct 27 17:16:48 2022

###################################################################
set sdc_version 1.9

set_units -time ns -resistance MOhm -capacitance fF -voltage V -current mA
set_wire_load_model -name 5K_hvratio_1_4 -library NangateOpenCellLibrary
create_clock [get_ports CLK]  -period 1  -waveform {0 0.5}
set_max_delay 1  -from [list [get_ports CLK] [get_ports RST_AN] [get_ports {IMEM_DOUT[31]}]    \
[get_ports {IMEM_DOUT[30]}] [get_ports {IMEM_DOUT[29]}] [get_ports             \
{IMEM_DOUT[28]}] [get_ports {IMEM_DOUT[27]}] [get_ports {IMEM_DOUT[26]}]       \
[get_ports {IMEM_DOUT[25]}] [get_ports {IMEM_DOUT[24]}] [get_ports             \
{IMEM_DOUT[23]}] [get_ports {IMEM_DOUT[22]}] [get_ports {IMEM_DOUT[21]}]       \
[get_ports {IMEM_DOUT[20]}] [get_ports {IMEM_DOUT[19]}] [get_ports             \
{IMEM_DOUT[18]}] [get_ports {IMEM_DOUT[17]}] [get_ports {IMEM_DOUT[16]}]       \
[get_ports {IMEM_DOUT[15]}] [get_ports {IMEM_DOUT[14]}] [get_ports             \
{IMEM_DOUT[13]}] [get_ports {IMEM_DOUT[12]}] [get_ports {IMEM_DOUT[11]}]       \
[get_ports {IMEM_DOUT[10]}] [get_ports {IMEM_DOUT[9]}] [get_ports              \
{IMEM_DOUT[8]}] [get_ports {IMEM_DOUT[7]}] [get_ports {IMEM_DOUT[6]}]          \
[get_ports {IMEM_DOUT[5]}] [get_ports {IMEM_DOUT[4]}] [get_ports               \
{IMEM_DOUT[3]}] [get_ports {IMEM_DOUT[2]}] [get_ports {IMEM_DOUT[1]}]          \
[get_ports {IMEM_DOUT[0]}] [get_ports {DMEM_DOUT[31]}] [get_ports              \
{DMEM_DOUT[30]}] [get_ports {DMEM_DOUT[29]}] [get_ports {DMEM_DOUT[28]}]       \
[get_ports {DMEM_DOUT[27]}] [get_ports {DMEM_DOUT[26]}] [get_ports             \
{DMEM_DOUT[25]}] [get_ports {DMEM_DOUT[24]}] [get_ports {DMEM_DOUT[23]}]       \
[get_ports {DMEM_DOUT[22]}] [get_ports {DMEM_DOUT[21]}] [get_ports             \
{DMEM_DOUT[20]}] [get_ports {DMEM_DOUT[19]}] [get_ports {DMEM_DOUT[18]}]       \
[get_ports {DMEM_DOUT[17]}] [get_ports {DMEM_DOUT[16]}] [get_ports             \
{DMEM_DOUT[15]}] [get_ports {DMEM_DOUT[14]}] [get_ports {DMEM_DOUT[13]}]       \
[get_ports {DMEM_DOUT[12]}] [get_ports {DMEM_DOUT[11]}] [get_ports             \
{DMEM_DOUT[10]}] [get_ports {DMEM_DOUT[9]}] [get_ports {DMEM_DOUT[8]}]         \
[get_ports {DMEM_DOUT[7]}] [get_ports {DMEM_DOUT[6]}] [get_ports               \
{DMEM_DOUT[5]}] [get_ports {DMEM_DOUT[4]}] [get_ports {DMEM_DOUT[3]}]          \
[get_ports {DMEM_DOUT[2]}] [get_ports {DMEM_DOUT[1]}] [get_ports               \
{DMEM_DOUT[0]}]]  -to [list [get_ports {IMEM_ADDR[31]}] [get_ports {IMEM_ADDR[30]}] [get_ports  \
{IMEM_ADDR[29]}] [get_ports {IMEM_ADDR[28]}] [get_ports {IMEM_ADDR[27]}]       \
[get_ports {IMEM_ADDR[26]}] [get_ports {IMEM_ADDR[25]}] [get_ports             \
{IMEM_ADDR[24]}] [get_ports {IMEM_ADDR[23]}] [get_ports {IMEM_ADDR[22]}]       \
[get_ports {IMEM_ADDR[21]}] [get_ports {IMEM_ADDR[20]}] [get_ports             \
{IMEM_ADDR[19]}] [get_ports {IMEM_ADDR[18]}] [get_ports {IMEM_ADDR[17]}]       \
[get_ports {IMEM_ADDR[16]}] [get_ports {IMEM_ADDR[15]}] [get_ports             \
{IMEM_ADDR[14]}] [get_ports {IMEM_ADDR[13]}] [get_ports {IMEM_ADDR[12]}]       \
[get_ports {IMEM_ADDR[11]}] [get_ports {IMEM_ADDR[10]}] [get_ports             \
{IMEM_ADDR[9]}] [get_ports {IMEM_ADDR[8]}] [get_ports {IMEM_ADDR[7]}]          \
[get_ports {IMEM_ADDR[6]}] [get_ports {IMEM_ADDR[5]}] [get_ports               \
{IMEM_ADDR[4]}] [get_ports {IMEM_ADDR[3]}] [get_ports {IMEM_ADDR[2]}]          \
[get_ports {IMEM_ADDR[1]}] [get_ports {IMEM_ADDR[0]}] [get_ports               \
{DMEM_RWADDR[31]}] [get_ports {DMEM_RWADDR[30]}] [get_ports {DMEM_RWADDR[29]}] \
[get_ports {DMEM_RWADDR[28]}] [get_ports {DMEM_RWADDR[27]}] [get_ports         \
{DMEM_RWADDR[26]}] [get_ports {DMEM_RWADDR[25]}] [get_ports {DMEM_RWADDR[24]}] \
[get_ports {DMEM_RWADDR[23]}] [get_ports {DMEM_RWADDR[22]}] [get_ports         \
{DMEM_RWADDR[21]}] [get_ports {DMEM_RWADDR[20]}] [get_ports {DMEM_RWADDR[19]}] \
[get_ports {DMEM_RWADDR[18]}] [get_ports {DMEM_RWADDR[17]}] [get_ports         \
{DMEM_RWADDR[16]}] [get_ports {DMEM_RWADDR[15]}] [get_ports {DMEM_RWADDR[14]}] \
[get_ports {DMEM_RWADDR[13]}] [get_ports {DMEM_RWADDR[12]}] [get_ports         \
{DMEM_RWADDR[11]}] [get_ports {DMEM_RWADDR[10]}] [get_ports {DMEM_RWADDR[9]}]  \
[get_ports {DMEM_RWADDR[8]}] [get_ports {DMEM_RWADDR[7]}] [get_ports           \
{DMEM_RWADDR[6]}] [get_ports {DMEM_RWADDR[5]}] [get_ports {DMEM_RWADDR[4]}]    \
[get_ports {DMEM_RWADDR[3]}] [get_ports {DMEM_RWADDR[2]}] [get_ports           \
{DMEM_RWADDR[1]}] [get_ports {DMEM_RWADDR[0]}] [get_ports DMEM_WEN] [get_ports \
{DMEM_DIN[31]}] [get_ports {DMEM_DIN[30]}] [get_ports {DMEM_DIN[29]}]          \
[get_ports {DMEM_DIN[28]}] [get_ports {DMEM_DIN[27]}] [get_ports               \
{DMEM_DIN[26]}] [get_ports {DMEM_DIN[25]}] [get_ports {DMEM_DIN[24]}]          \
[get_ports {DMEM_DIN[23]}] [get_ports {DMEM_DIN[22]}] [get_ports               \
{DMEM_DIN[21]}] [get_ports {DMEM_DIN[20]}] [get_ports {DMEM_DIN[19]}]          \
[get_ports {DMEM_DIN[18]}] [get_ports {DMEM_DIN[17]}] [get_ports               \
{DMEM_DIN[16]}] [get_ports {DMEM_DIN[15]}] [get_ports {DMEM_DIN[14]}]          \
[get_ports {DMEM_DIN[13]}] [get_ports {DMEM_DIN[12]}] [get_ports               \
{DMEM_DIN[11]}] [get_ports {DMEM_DIN[10]}] [get_ports {DMEM_DIN[9]}]           \
[get_ports {DMEM_DIN[8]}] [get_ports {DMEM_DIN[7]}] [get_ports {DMEM_DIN[6]}]  \
[get_ports {DMEM_DIN[5]}] [get_ports {DMEM_DIN[4]}] [get_ports {DMEM_DIN[3]}]  \
[get_ports {DMEM_DIN[2]}] [get_ports {DMEM_DIN[1]}] [get_ports {DMEM_DIN[0]}]]
