/* This is the main RTL of the Project APB VIP. 
   This module contains the logic of storing data in memory.
   the memory is expandable and the read operation and write operation must have a posedge clk before starting.
*/

// TO DO : 4 memory banks && APB Wrapper separately. then use available APB driver with that APB wrapped DUT then develop own VIPs
// Reusability and change the glue logic to incorporate 

module mem8KB 
	# ( parameter ADDR_WIDTH = 10,
	   parameter DATA_WIDTH = 08, 
	   parameter DEPTH    	= 1024
	   )	
	   
    (   input   logic                    clk     , 
		input   logic                    rst_n   ,
		input   logic                    cs      ,
		input   logic                    wr_rd_n , // Write/Read control signal (1: write, 0: read)
		input   logic [ADDR_WIDTH-1:0]   addr    , // Address bus
		output  logic [DATA_WIDTH-1:0]	 data_out,
		input   logic [DATA_WIDTH-1:0]   data_in      // Data bus 
);

  // Define the memory array with a depth of 1024
  reg [7:0] memory [DEPTH];
  

  // Write logic
  always @(posedge clk) begin
	if (!rst_n) begin 
		for(int i=0;i<(2**`ADDR_WIDTH);i++) begin
			memory[i]<=0;
		end
	end
	
    else if(cs & wr_rd_n & rst_n) begin
      memory[addr] <= data_in; // Write data to memory
      end
    end

  // Read logic
  always @(posedge clk) begin
	
	if(!wr_rd_n) begin
      data_out <= memory[addr]; // Read data from memory
    end
  end

  //assign data = ( ~wr_rd_n  ) ? data_out : 8'bz;

  // Tri-state buffer control for bidirectional data bus
  //assign data = (cs & wr_rd_n ) ? 8'bz :data_out;

endmodule

