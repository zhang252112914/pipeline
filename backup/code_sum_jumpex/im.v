
// instruction memory
module im(input  [8:2]  addr,
            output [31:0] dout );

  reg  [31:0] ROM[127:0];

    // added
    initial begin
        $readmemh("./test_code/coe_code/non_data_sim6.dat", ROM);
    end

  assign dout = ROM[addr]; // word aligned
endmodule  
