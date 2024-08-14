if [file exists "work"] {vdel -all}
vlib work

vlog +define+DATA_WIDTH=8 apb_wrapper.sv
vlog +define+ADDR_WIDTH=10 apb_wrapper.sv

vlog top.sv apb_wrapper.sv tb_wrapper.sv classes.sv test.sv tb.sv interface.sv mem8KB.sv memory_reader.sv   
vsim -c work.tb
run -all
