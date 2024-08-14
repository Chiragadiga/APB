`timescale 1ns/1ps

`define DEBUG 0 
`define ADDR_WIDTH 10
`define DATA_WIDTH 08

module tb();                         
		logic clk;
		bit rst_n;
		logic cs;
		logic wr_rd_n;
		logic [`ADDR_WIDTH-1:0] addr ,addr_in;
		wire  [`DATA_WIDTH-1:0] data_out;
		logic [`DATA_WIDTH-1:0] data_in,data_r;
		logic [`DATA_WIDTH-1:0] wr_data[];
		logic [`DATA_WIDTH-1:0]rd_data[];
	//logic [`DATA_WIDTH-1:0] print_data[];
	//assign data = wr_rd_n?data_in:8'hz;
   
	mem8KB #(.DATA_WIDTH(`DATA_WIDTH), .ADDR_WIDTH(`ADDR_WIDTH)) dut(
	  
	   .clk(clk), 
	   .rst_n(rst_n), 
       .addr(addr), 
       .data_in(data_in),
	   .data_out(data_out),
       .cs(cs), 
       .wr_rd_n(wr_rd_n)); // Here, the .DATA_WIDTH (referring to the DUT)is the outside port while 'DATA_WIDTH is the inside port referring to the testbench signal
   
    initial begin clk=0; forever #5 clk = ~clk; end                                                                            // clock generator
    initial begin  									                                                                          // main procedure
	   addr=0    ;
	   data_in=0 ;
	   wr_rd_n=0 ;
	   rst_n=1;
	   
	end  
   /*  @(posedge clk);          // starting write mem
      write_mem('d15, 'hab_cd);
    @(posedge clk);
      write_mem('d20, 'd22);
    @(posedge clk);
      write_mem('d30, 'd33);
    @(posedge clk)
      write_mem('d40,'d44);
	@(posedge clk);               // starting read_mem
      read_mem ('d30, data_r);
      $display("Read data from address %0d is = %0d", addr, data_r) ;
    @(posedge clk);
      read_mem ('d15, data_r);
      $display("Read data from address %0d is = %0d", addr, data_r) ;
    @(posedge clk);
      read_mem('d20,data_r);
      $display("Read data from address %0d is = %0d", addr, data_r) ;
    @(posedge clk);
      read_mem('d40,data_r);
      $display("Read data from address %0d is = %0d", addr, data_r) ;
	   
	@(posedge clk)	 			// starting atomic read
	  atomic_wr_rd(10,11);
	@(posedge clk)
	  atomic_wr_rd(20,22); */


	//walking_ones();
	
	/* wr_data='{0,11,22,33,44,55,66,77,88,99};
	burst_wr(1,10,wr_data);
	@(posedge clk);
	read_mem (5,data_r);
	burst_rd(1,10,rd_data); */
	
	
	//johnson_ones();
	
	
	initial begin
	
	@(posedge clk);
	rst_n=0;
	@(posedge clk);
	print_mem(32);
	
	rst_n=1;
	  for(int i=0; i<(2**`ADDR_WIDTH); i++) begin // starting writing to all addresses
		@(posedge clk);
		write_mem(i,i);
	
	end
	/* #5;
	@(posedge clk);
	burst_rd(1,40,rd_data);
	burst_rd(41,40,rd_data); */
		@(posedge clk);
	print_mem(32);								// Reading in the format	
  #50;
  $finish;
	   
    end
	
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
	
	task write_mem(bit [`ADDR_WIDTH-1:0] addr_in, bit [`DATA_WIDTH-1:0] dat) ;                                               // writing to address , data
    begin
      addr=addr_in;
      data_in=dat;
      wr_rd_n=1;
      cs=1;
    @(posedge clk);
      cs<=0;
`ifdef DEBUG
      //$display("writing to address %d, data of %h", addr_in, dat) ;
`endif
    end 
  endtask : write_mem

	task automatic read_mem(bit [`ADDR_WIDTH-1:0] addr_in,  ref logic [`DATA_WIDTH-1:0] data_read) ; 		                 // reading from address , data
      begin
	    addr=addr_in;
	    wr_rd_n=0;
	    cs<=1;
		@(posedge clk);
        //data_read = dut.memory[addr]; // data_read= intf
		data_read = data_out;
        // @(posedge clk);
	   	// cs=0;
      
`ifdef DEBUG
      //$display("Reading from memory %0d: data is %0d", addr_in, data_read) ;
`endif
      end
    endtask : read_mem
  
/*     task atomic_wr_rd(bit [`ADDR_WIDTH-1:0] addr_in, logic [`DATA_WIDTH-1:0] dat) ;  					                    // DO a write followed by read - call write_mem() -> read_mem()
	begin 
	write_mem(addr_in,dat);
	@(posedge clk);
	read_mem(addr_in,dat);
	$display("the read data at addr %0d is %0d", addr_in, dat);
	end
	endtask
	
    task walking_ones() ; 																				                    // Write with walking 1's data - using atomic_wr_rd
	begin
	   for(int i=0; i<8; i++) begin
	   
		atomic_wr_rd(i,(1<<i));
		
		if(data!=(1<<i))
		  $display("mismatch");
		else $display("read from address %d:%b", i, data);
		
		end
	end
	endtask

	task burst_wr(bit[`ADDR_WIDTH-1:0] start_addr, int burst_length, logic [`DATA_WIDTH-1:0] data_arr[]);                  // multiple write transactions 
	begin
	
		for(int i=0; i<burst_length; i++) begin
			@(posedge clk);
			write_mem(start_addr+i,data_arr[i]);
			//$display("wrote at address %0d, data of %0d", start_addr+i, data_arr[i]);
		end
		
	end
	endtask 

	task automatic burst_rd(bit [`ADDR_WIDTH-1:0] start_addr, int burst_length, ref logic [`DATA_WIDTH-1:0] data_arr[])  ; // multiple read transactions
	begin
		
		
		for (int i=0; i<burst_length; i++) begin
			data_arr=new[i+1];
			@(posedge clk);
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
			@(posedge clk);
			write_mem(i,pattern);
			@(posedge clk);
			read_mem(i,read_data);
			if( read_data != pattern) $display("error");
			else $display("read from addr %d: %b", dut.addr,dut.data);
			pattern={pattern[6:0], ~pattern[7]};
			end
	end
	endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb);
    end */
endmodule: tb











/*
`define ADDR_WIDTH 10
`define DATA_WIDTH 08

`define DEBUG 0 
`timescale 1ns/1ps

module tb () ;

   logic clk	 				  ;
   logic rst_n	  				  ;
   logic cs		                  ,
   logic wr_rd_n                  ,
   logic [ADDR_WIDTH-1:0] addr	  ,
   wire  [DATA_WIDTH-1:0] data    ,
   logic [DATA_WIDTH-1:0] data_in ,
   
   assign data = wr_rd_n?data_in:8'hz;
   
   mem8KB #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH) dut(
	   .clk(clk)
	   .clk(clk), 
	   .rst_n(rst_n), 
       .addr(addr), 
       .data(data),
       .cs(cs), 
       .wr_rd_n(wr_rd_n));
   
    initial begin clk=0; forever #5 clk = ~clk; end
    initial begin 
	   addr=0    ;
	   data_in=0 ;
	   wr_rd_n=0 ;
	   
	  
		@(posedge clk)
		write_mem('h15, 'hab_cd);
		read_mem ('h15, data);
		$display("Read data = %0d", data);
	   
	   
	
  task write_mem(bit [`ADDR_WIDTH-1:0] addr_in, bit [`DATA_WIDTH-1:0] dat) ;
    begin
      addr=addr_in;
      data=dat;
      wr_rd_n=1;
      cs=1;
      @(posedge clk);
      cs<=0;
`ifdef DEBUG
      $display("writing to address %d, data of %d", addr_in, data_in) ;
`endif
    end 
  endtask : write_mem

  task read_mem(bit [`ADDR_WIDTH-1:0] addr_in, ref bit [`DATA_WIDTH-1:0] dat) ;
    begin
	  addr=addr_in;
	  wr_rd_n=0;
	  cs<=1;
	  @(posedge clk);
	  cs=0;
	  dat=dut.memory[addr];
`ifdef DEBUG
  $display("Some Verbose message") ;
`endif
  endtask : read_mem
  


  /* task atomic_wr_rd(addr, data) ;  // DO a write followed by read - call write_mem() -> read_mem()
  task walking_ones() ; // Write with walking 1's data - using atomic_wr_rd
  task johnson_ones() ; // Write with johnson counter 1's data
  task burst_wr(bit [] start_addr, int burst_length, int data_arr[]) ; // multiple write transactions 
  task burst_rd(bit [] start_addr, int burst_length, ref int data_arr[])  ; // multiple read transactions  */
//endmodule: tb


/*
write_mem('h15, 'hab_cd) ;
read_mem('h15, data ) ;
$display(Read data = %0d", data) ;

*/
