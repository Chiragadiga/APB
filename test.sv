/* This is the main test program where objects from the classes module are instantiated.
	The main procedure contains of object construction and value passing to the DUT ( through Interface


*/


`timescale 1ns/1ps

`define DEBUG 0 
`define ADDR_WIDTH 10
`define DATA_WIDTH 08



program main(apb_if apbif);  // Create an object of scenario and send all objects in its txn_arr queue 
		 
	 	logic PCLK;
		logic [`DATA_WIDTH-1:0]rd_data[10];
		logic [8]numtx=0;
   
	scenario sc;
	driver drv;
	tx_item item; 
	
	initial begin // main procedure
	   
	item = new();
	item.vif = apbif ;
	apbif.PWRITE=1;
	drv = new(item);
	sc = new(drv,item);
	
	for(int i=0; i<10; i++) begin

		item.vif.PADDR = top.uut.mem_array[i];
		
		item.vif.PWDATA=top.uut.mem_array[i+1];
		item.t=WR;
		if(top.verbosity==0)begin
		$display("the type of txn is : %0d",item.t);
		end
		sc.txn_arr.push_back(item);
		sc.send(drv);
	
		item.t=RD;
			
			if(top.verbosity>=1)begin
			$display("the type of txn is : %0d",item.t);
			end
		sc.txn_arr.push_back(item);
		sc.send(drv);
		
		
		//drv.write_mem(item);
		//drv.read_mem(item,rd_data[i]);
	numtx=numtx+1;
		
	end 
	
	if(top.verbosity>0) begin $display("the number of tx is : %0d", numtx); end
	
   end 
   
  
endprogram: main  
