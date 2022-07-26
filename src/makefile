# Copyright the VHDL Guru

WORKDIR=work

GHDL=ghdl
INCLUDE_OPTS=-i --workdir=$(WORKDIR)
BUILD_OPTS=-m --workdir=$(WORKDIR) -o $(WORKDIR)/build -fsynopsys
ELABORATE_OPTS=-c --workdir=$(WORKDIR)

BUILD_CMD=$(GHDL) $(BUILD_OPTS)

SOURCES:=$(shell find . -name "*.vhd")

all: $(WORKDIR) include
	$(GHDL) $(BUILD_OPTS) CFG_DATAPATH_BEHAVIORAL

datapath: $(WORKDIR) include
	$(GHDL) $(BUILD_OPTS) CFG_DATAPATH_BEHAVIORAL

$(WORKDIR):
	mkdir $(WORKDIR)

include: $(WORKDIR)
	$(GHDL) $(INCLUDE_OPTS) $(SOURCES)

clean:
	$(GHDL) clean --workdir=$(WORKDIR)
	rm -rf $(WORKDIR)
