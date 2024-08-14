`timescale 1ns/1ps

`define DEBUG 0 
`define ADDR_WIDTH 10
`define DATA_WIDTH 08

module top;
	bit PCLK;
	int verbosity;

apb_if apbif(PCLK);	
main maine(apbif); // test program


 memory_reader  #(.file_name("memory_file_3.mem")) uut();
 

apb_subordinate #(.DATA_WIDTH(`DATA_WIDTH), .ADDR_WIDTH(`ADDR_WIDTH)) dut(
	  
	   .PCLK(apbif.PCLK), 
       .PADDR(apbif.PADDR), 
       .PWDATA(apbif.PWDATA),
	   .PRDATA(apbif.PRDATA),
       .PSELx(apbif.PSELx),
	   .PRESETn(apbif.PRESETn),
       .PWRITE(apbif.PWRITE)); // Here, the .DATA_WIDTH (referring to the DUT)is the outside port while 'DATA_WIDTH is the inside port referring to the testbench signal
   test1 tst(apbif);
   initial begin
     forever #5 PCLK=~PCLK;
	    end

	 initial begin // main procedure

	
	if($value$plusargs("VERB=%d", verbosity)) begin
	   $display("Got verbosity=%0d", verbosity) ;
	 end else begin
	    verbosity=0 ;
	   $display("Using default verbosity of %9d", verbosity) ;
	   end 
	 end
 endmodule