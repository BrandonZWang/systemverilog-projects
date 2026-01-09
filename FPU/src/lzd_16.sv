/*
Module that detects
*/
module lzd_16 (
    input logic[15:0] number,

    output logic[3:0] num_zeros, // 0-15
    output logic all_zeros
);

    logic[7:0] num_0_sub; // Packed arrays of submodule outputs
    logic[3:0] all_0_sub; 

    // Distributes bits of num_0_sub and all_0_sub across module instances
    lzd_4 lzd_4_array[3:0] (
        .number(number),
        .num_zeros(num_0_sub),
        .all_zeros(all_0_sub)
    );

    always_comb begin
        num_zeros[3] = all_0_sub[0] & all_0_sub[1] & (~all_0_sub[2] | ~all_0_sub[3]);
        num_zeros[2] = all_0_sub[0] & (~all_0_sub[1] | (all_0_sub[2] & ~all_0_sub[3]));

        // Pull last 2 bits of num_zeros from one of the submodules
        // Hopefully generates a mux
        if (num_zeros[3]) begin
            if (num_zeros[2]) num_zeros[1:0] = num_0_sub[7:6];
            else num_zeros[1:0] = num_0_sub[5:4];
        end
        else begin
            if (num_zeros[2]) num_zeros[1:0] = num_0_sub[3:2];
            else num_zeros[1:0] = num_0_sub[1:0];
        end
    end
     
endmodule