###########################################################
###
###
###   File: makefile
###   Author: Chirag Adiga
###   Description: Makefile to compile, run ...
###
###   Usage: 
###       help:    This message ... 
### 	  ana:     Analyze files
###       elab:    Elaborate files (3-step flow)
###       comp:    Compiles verilog code and generates simv (2 step flow)
###	  run :    Runs the simv executable
###       clean:  ucli.key
###       clean_all: Cleans all VCS files (csrc, simv*)
###       deep_clean: *vpd, *daidir
###
##########################################################

TOP   = main

RTL = ./apb_wrapper.sv ./memory_reader.sv ./mem8KB.sv
SVTB = ./top.sv ./tb_wrapper.sv ./classes.sv ./test.sv  ./interface.sv 
MEMBANK = ./mem4kbanks.sv ./banktb.sv

help:
	@echo ""
	@echo "Usage:"
	@echo "  help      : This message"
	@echo "  comp      : Compiles verilog code and generates simv"
	@echo "  run       : Runs the simv executable"
	@echo "  clean     : Cleans intermediate files .. "
	@echo "  clean_all : Cleans all VCS files .. csrc, simv*"
	@echo ""


ana: ana_rtl ana_tb

ana_tb:
	vlogan -sverilog dummy.sv top.sv

ana_rtl:
	vlogan -sverilog mem8KB.sv 

elab:
	vcs -sverilog ${TOP}

comp_tb:
	vcs -sverilog -R -full64 tb.sv mem8KB.sv -debug_access+r -o outputb.simv
# 	vcs -l vcs.log -R -sverilog -debug_all -full64 $(SVTB) $(RTL)


comp_bank:
	vcs  -sverilog -full64 $(MEMBANK) -debug_access+r -o membank.simv

comp_top:
	vcs  -sverilog -full64  $(SVTB) $(RTL) -debug_access+r -o wrapoutputop.simv
 

run_tb:
	./outputb.simv 

run_top:
	./outputop.simv +VERB=${V}
 
run_banks:
	./membank.simv 

all: comp run

clean:
	\rm -rf simv* csrc* *.tmp *.vpd *.key log *.h temp *.log .vcs* *.txt DVE* *.old *.dat *.fsdb

clean_all:
	rm -rf *.mem *.pl *.tcl  
