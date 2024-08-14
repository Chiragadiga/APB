/* This is the Interface definition which is used to bundle the data signals for easy access
*/
interface apb_if(input bit PCLK);
	logic [`ADDR_WIDTH-1:0] PADDR;
	logic PSELx;
	logic PWRITE;
	logic [`DATA_WIDTH-1:0] PRDATA;
	logic [`DATA_WIDTH-1:0] PWDATA;
	logic PRESETn;
	
	
	clocking cb @(posedge PCLK);
		default input #1 output #1;
		output PSELx , PWRITE, PADDR, PWDATA, PRESETn;
		input PRDATA;
		endclocking :cb
		
	modport dut (
		input PADDR,PSELx,PWRITE,PRESETn,
		input PWDATA,
		output PRDATA);
		
	modport test (
		clocking cb,
		input PCLK);
endinterface: apb_if