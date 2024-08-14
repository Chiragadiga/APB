/*
This module reads the values in a memory file and stores it into its memory 
additionally it stores the values in the file into addr-data pairs in an associative array
*/



module memory_reader #(parameter file_name)();

    reg [127:0] mem_array [0:256];  // Temporary memory array to hold the read data
    bit [127:0] associative_array [bit[32:0]]; // Associative array to store address and data chunks
    integer i;
	bit[32] datamem, addrmem;

    // Read memory initialization file
    initial begin
        $readmemh(file_name, mem_array);  // Read the file into the temporary memory array

        // Transfer values to the associative array
		
       /*  for (i = 0; i < 256; i+=2) begin
		//$display ("the values read are %4h",mem_array[i]);
		
		datamem= mem_array[i+1];
		addrmem=mem_array[i];
		 associative_array = '{"addrmem" : datamem};		 // Assume 32-bit address and 96-bit data
		
            //associative_array[mem_array[i][127:96]] = mem_array[i][95:0]; // Assume 32-bit address and 96-bit data
			if(associative_array.exists("addrmem"))
            $display("Address: %h, Data: %h", addrmem , datamem);
			else $display("there is some issue");
    end */
	
	
    end    
endmodule

