/* This module contains the classes that create this testbench structure.
	These classes when applicable plug into the tasks definition over at tb1.sv
	
	The concept of Virtual interface is learned here
*/

typedef enum { RD, WR } tx_type;


  class tx_item ;
  
    virtual apb_if vif;
    int st_time, en_time ;
    tx_type t          ; // RD or WR
	
endclass: tx_item 

	
	
class driver;
	tx_item obj;
	virtual apb_if.test vif;
	
	
	function new(tx_item obj);
		this.obj=obj;
	endfunction
    
    task write_mem(tx_item obj) ; // Reuse basic write w/o any modifications                               // writing to address , data
		top.tst.write_mem(obj.vif.PADDR, obj.vif.PWDATA);
	endtask : write_mem

	task automatic read_mem(tx_item obj,  ref bit [`DATA_WIDTH-1:0] data_read) ; 		                 // reading from address , data  
		top.tst.read_mem(obj.vif.PADDR,data_read);
    endtask : read_mem
endclass: driver


class scenario ;
	driver drv;
	tx_item obj;
	tx_item txn_arr[$] ;
	function new(driver drv, tx_item obj);
		this.drv=drv;
		this.obj=obj;
	endfunction
	bit [`DATA_WIDTH-1:0] data_read;
  
   tx_item obj = txn_arr.pop_front();
  
	task send (driver drv);
		begin
        case(obj.t)
	      RD: drv.read_mem(obj, data_read);
	      WR: drv.write_mem(obj);
	      
	    endcase
        end
     endtask:send
endclass: scenario
