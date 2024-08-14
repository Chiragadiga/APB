module apb_subordinate # ( parameter ADDR_WIDTH = 10,
	   parameter DATA_WIDTH = 08, 
	   parameter DEPTH    	= 1024
	   )	
	   
    (   input   logic                    PCLK     , 
		input   logic                    PRESETn   ,
		input   logic                    PSELx      ,
		input   logic                    PWRITE , // Write/Read control signal (1: write, 0: read)
		input   logic [ADDR_WIDTH-1:0]   PADDR    , // Address bus
		input 	logic [DATA_WIDTH-1:0]   PWDATA,      // Data bus 
		output	logic [DATA_WIDTH-1:0]   PRDATA
);
		
mem8KB #(.DATA_WIDTH(`DATA_WIDTH), .ADDR_WIDTH(`ADDR_WIDTH)) dut(
	  
	   .clk(PCLK), 
       .addr(PADDR), 
	   .rst_n(PRESETn),
       .data_in(PWDATA),
	   .data_out(PRDATA),
       .cs(PSELx), 
       .wr_rd_n(PWRITE)); // Here, the .DATA_WIDTH (referring to the DUT)is the outside port while 'DATA_WIDTH is the inside port referring to the testbench signal
   
   
 initial begin 
 //assign PDATA = ( ~PWRITE  ) ? PRDATA : PWDATA;
 end
 
 
endmodule

   
   