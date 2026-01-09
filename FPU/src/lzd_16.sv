/*
Module that detects
*/
module lzd_16 (
    input logic[15:0] number,

    output logic[3:0] num_zeros,
    output logic all_zeros
);

    logic[7:0] num_0_zub; // Packed arrays of submodule outputs
    logic[3:0] all_0_zub; 

    lzd_4 lzd_4_array[3:0] (
        .number(number),
        .num_zeros(num_0_zub),
        .all_zeros(all_0_zub)
    );

    always_comb begin
        num_zeros[3] = all_0_zub[0] & all_0_zub[1] & (~all_0_zub[2] | ~all_0_zub[3]);
        num_zeros[2] = all_0_zub[0] & (~all_0_zub[1] | (all_0_zub[2] & ~all_0_zub[3]));

        // Hopefully generates a mux
        if (num_zeros[3]) begin
            if (num_zeros[2]) num_zeros[1:0] = num_0_zub[7:6];
            else num_zeros[1:0] = num_0_zub[5:4];
        end
        else begin
            if (num_zeros[2]) num_zeros[1:0] = num_0_zub[3:2];
            else num_zeros[1:0] = num_0_zub[1:0];
        end
    end
     
endmodule