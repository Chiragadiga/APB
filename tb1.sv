/*
This module contains all the tasks that the VIP needs. 
Sets the DUT variables of address and data and direction ports for appropriate write and read operations

*/

module test(mem_if memif);
`timescale 1ns/1ps

`define DEBUG 0 
`define ADDR_WIDTH 10
`define DATA_WIDTH 08

  localparam MEM_SIZE = 1 << `ADDR_WIDTH;
  
  logic [7:0] mem[MEM_SIZE];
  logic [7:0] temp_data_arr[];
  logic [7:0] temp_data;
  static int i;
	
	task write_mem(bit [`ADDR_WIDTH-1:0] addr_in, bit [`DATA_WIDTH-1:0] dat) ;                                               // writing to address , data
      begin
      memif.addr=addr_in;
      memif.data_in=dat;
      memif.wr_rd_n=1;
      memif.cs=1;
    @(posedge memif.clk);
      memif.cs<=0;
`ifdef DEBUG
		if(top.verbosity==2) begin
      $display("WRITE to address %d, data of %d", addr_in, dat) ; end
`endif
      end 
    endtask : write_mem

	task automatic read_mem(bit [`ADDR_WIDTH-1:0] addr_in,  ref logic [`DATA_WIDTH-1:0] data_read) ; 		                 // reading from address , data
      begin
	    memif.addr=addr_in;
	    memif.wr_rd_n=0;
	    memif.cs<=1;
		@(posedge memif.clk);
        //data_read = dut.memory[addr]; // data_read= intf
		data_read = memif.data;
        // @(posedge clk);
	   	// cs=0;
      
`ifdef DEBUG if(top.verbosity==2) begin
      $display("READ from address %0d: data is %0d", addr_in, data_read) ;
	  end
`endif
      end
    endtask : read_mem
	
	
	 // Task to print memory in a formatted way
    task print_mem(int width=8) ;
	string ret,formatted_data;
	  logic[`DATA_WIDTH-1:0] temp_data;
	  logic[`DATA_WIDTH-1:0] temp_data_arr[];
	  temp_data_arr= new[width];
	  $display (" ADDR\t\tDATA");
	  $display("------\t\t------");
	  for(int i=0; i<(2**`ADDR_WIDTH); i+= width) 
	     begin 
		  for(int j=0; j<width; j++)
		     begin
			  read_mem(j+i,temp_data); // TODO: Make it a backdoor access
			  if(temp_data >=0 && temp_data <='hf)
				formatted_data=$sformatf("0%0h",temp_data);
			  else formatted_data=$sformatf("%0h",temp_data);
			  ret= $sformatf("%s %s", ret, formatted_data);
			  temp_data_arr[j]=temp_data;
		     end
			 $display (" %4h\t\t%s", i, ret);
			 
			 ret=(""); // TODO: No need
	     end
	endtask
	
	
	task atomic_wr_rd(bit [`ADDR_WIDTH-1:0] addr_in, logic [`DATA_WIDTH-1:0] dat) ;  					                    // DO a write followed by read - call write_mem() -> read_mem()
	begin 
	write_mem(addr_in,dat);
	@(posedge memif.clk);
	read_mem(addr_in,dat);
	if(top.verbosity!=0) begin
	$display("the read data at addr %0d is %0d", addr_in, dat);
	end
	end
	endtask
	
    task walking_ones() ; 																				                    // Write with walking 1's data - using atomic_wr_rd
	begin
	   for(int i=0; i<8; i++) begin
	   
		atomic_wr_rd(i,(1<<i));
		
		if(memif.data!=(1<<i))
		  $display("mismatch");
		else $display("read from address %d:%b", i, memif.data);
		
		end
	end
	endtask

	task burst_wr(bit[`ADDR_WIDTH-1:0] start_addr, int burst_length, logic [`DATA_WIDTH-1:0] data_arr[]);                  // multiple write transactions 
	begin
	
		for(int i=0; i<burst_length; i++) begin
			@(posedge memif.clk);
			write_mem(start_addr+i,data_arr[i]);
			//$display("wrote at address %0d, data of %0d", start_addr+i, data_arr[i]);
		end
		
	end
	endtask 

	task automatic burst_rd(bit [`ADDR_WIDTH-1:0] start_addr, int burst_length, ref logic [`DATA_WIDTH-1:0] data_arr[])  ; // multiple read transactions
	begin
		
		
		for (int i=0; i<burst_length; i++) begin
			data_arr=new[i+1];
			@(posedge memif.clk);
			read_mem(start_addr+i,data_arr[i]);
	$display("read at address %0d, data of %0d", start_addr+i, data_arr[i]);
		end
	end
	endtask

	task johnson_ones() ; 																						           // Write with johnson counter 1's data
	
	int i;
	logic[7:0] pattern, read_data;
	begin
		pattern = 8'b0000_0000;
		for(i=0;i<16;i++) begin
			@(posedge memif.clk);
			write_mem(i,pattern);
			@(posedge memif.clk);
			read_mem(i,read_data);
			if( read_data != pattern) $display("error");
			else $display("read from addr %d: %b", top.dut.addr,top.dut.data);
			pattern={pattern[6:0], ~pattern[7]};
			end
	end
	endtask

endmodule : test

/*
package mypkg ;
  task read_mem ; 
  endtask
endpackage: mypkg


import mypkg::* ;

mypkg::read_mem() ; 
read_mem() ;
*/