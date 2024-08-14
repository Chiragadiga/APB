`timescale 1ns/1ps

`define DEBUG 0 
`define ADDR_WIDTH 10
`define DATA_WIDTH 08
`define DEPTH 1024

	class arr;
		rand bit [`DATA_WIDTH] memarr1 [`DEPTH];
		bit [`DATA_WIDTH] memarr2 [`DEPTH];
	endclass
	
module test1(apb_if apbif);                         
		logic 	 	PCLK;
		bit 		PRESETn;
		logic 		PSELx;
		logic 		PWRITE;
		logic [`ADDR_WIDTH-1:0] PADDR ,addr_in;
		wire  [`DATA_WIDTH-1:0] PRDATA;
		logic [`DATA_WIDTH-1:0] PWDATA;
		logic [`DATA_WIDTH-1:0] wr_data[];
		logic [`DATA_WIDTH-1:0]rd_data[];
	//logic [`DATA_WIDTH-1:0] print_data[];
	//assign PDATA = PWRITE?PWDATA:PRDATA;
   
	apb_subordinate #(.DATA_WIDTH(`DATA_WIDTH), .ADDR_WIDTH(`ADDR_WIDTH) ) dut(
	  
	   .PCLK(PCLK), 
	   .PRESETn(PRESETn), 
       .PADDR(PADDR), 
       .PRDATA(PRDATA),
	   .PWDATA(PWDATA),
       .PSELx(PSELx), 
       .PWRITE(PWRITE)); // Here, the .DATA_WIDTH (referring to the DUT)is the outside port while 'DATA_WIDTH is the inside port referring to the testbench signal
   
	arr a1;
	initial begin
	a1=new();
	a1.randomize();
	//$display("array=%p",a1.memarr1);
	end
   
   initial begin PCLK=0; forever #5 PCLK=~PCLK; end
   initial begin
   PADDR=0;
   PWDATA=0;
   PWRITE=0;
   PRESETn=1;
   end
   
   initial begin
   
   @(posedge PCLK);
   PRESETn=0;
   @(posedge PCLK);
   print_mem(32);
   PRESETn=1;
   
	for(int i=0; i<(`DEPTH); i++) 
	begin // starting writing to all addresses
		@(posedge PCLK);
		write_mem(i,a1.memarr1[i]);
	end
	
	   @(posedge PCLK);
	   
	   
	for(int i=0; i<(`DEPTH); i++) 
	begin
	@(posedge PCLK);
	read_mem(i,a1.memarr2[i]);
	end
	
	if(a1.memarr1 == a1.memarr2)
	$display("after checking the arrays are equal");
	else $display("there is an issue");
	
	   	print_mem(32);		// Reading in the format	
		#50;
	$finish;
	end

   


   
   
	task write_mem(bit [`ADDR_WIDTH-1:0] addr_in, bit [`DATA_WIDTH-1:0] dat) ;                                               // writing to address , data
    begin
      PADDR=addr_in;
      PWDATA=dat;
      PWRITE=1;
      PSELx=1;
    @(posedge PCLK);
      PWRITE<=0;
`ifdef DEBUG
      //$display("writing to address %d, data of %h", addr_in, dat) ;
`endif
    end 
  endtask : write_mem
  
  
	task automatic read_mem(bit [`ADDR_WIDTH-1:0] addr_in, ref bit [`DATA_WIDTH-1:0] data_read) ; 		                 // reading from address , data
      begin
	    PADDR=addr_in;
	    PWRITE=0;
	    PSELx<=1;
		@(posedge PCLK);
        //data_read = dut.memory[addr]; // data_read= intf
		data_read = PRDATA;
        // @(posedge clk);
	   	// cs=0;
      
`ifdef DEBUG
      //$display("Reading from memory %0d: data is %0d", addr_in, data_read) ;
`endif
      end
    endtask : read_mem
   
   
   
   
    task print_mem(int width=8) ;
	string ret,formatted_data;
	  bit[`DATA_WIDTH-1:0] temp_data;
	  bit[`DATA_WIDTH-1:0] temp_data_arr[];
	  temp_data_arr= new[width];
	  $display (" ADDR\t\tDATA");
	  $display("------\t\t------");
	  for(int i=0; i<(2**`ADDR_WIDTH); i+= width) 
	     begin 
		  for(int j=0; j<width; j++)
		     begin
			  read_mem(j+i,temp_data);
			  if(temp_data >=0 && temp_data <='hf)
				formatted_data=$sformatf("0%0h",temp_data);
			  else formatted_data=$sformatf("%0h",temp_data);
			  ret= $sformatf("%s %s", ret, formatted_data);
			  temp_data_arr[j]=temp_data;
			
		
		     end
			 $display (" %4h\t\t%s", i, ret);
			 
			 ret=("");
	     end
	endtask
   
   
   
   
   
   
   
   
   
   
   
   endmodule
   
   
   