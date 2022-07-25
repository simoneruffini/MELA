# Copyright the VHDL Guru

WORKDIR=work

GHDL=ghdl
OPTS=-a --workdir=$(WORKDIR)

BUILD_CMD=$(GHDL) $(OPTS)

$(WORKDIR):
	mkdir $(WORKDIR)

comm_pkg: work
	$(BUILD_CMD) COMM_PKG.vhd

fetch: comm_pkg
	$(BUILD_CMD) datapath/fetch/fetch.vhd
decode: comm_pkg
	$(BUILD_CMD) datapath/decode/decode.vhd
exec: comm_pkg
	$(BUILD_CMD) datapath/exec/exec.vhd
memory: comm_pkg
	$(BUILD_CMD) datapath/memory/memory.vhd
writeback: comm_pkg
	$(BUILD_CMD) datapath/writeback/writeback.vhd

datapath: comm_pkg fetch decode exec memory writeback
	$(BUILD_CMD) datapath/datapath.vhd

clean:
	rm -rf $(WORKDIR)