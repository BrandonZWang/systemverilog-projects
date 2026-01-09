/*
Module that counts the number of leading zeros in a 4-bit number.
*/
module lzd_4 (
    input logic[3:0] number,

    output logic[1:0] num_zeros,
    output logic all_zeros
);
    always_comb begin
        num_zeros[1] = ~(number[3] | number[2]);
        num_zeros[0] = (~number[3] & number[2]) | (~number[3] & ~number[1]);

        all_zeros = ~(|number); // NOR of all bits in number
    end
endmodule