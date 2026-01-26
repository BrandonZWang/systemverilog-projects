/*
* Repacks unpacked floating-point numbers.
*/
module fpu_pack #(
    EXPONENT_WIDTH = 11,
    SIGNIFICAND_WIDTH = 52
) (
    // Unpacked input
    input logic sign,
    input logic[EXPONENT_WIDTH-1:0] exponent,
    input logic[SIGNIFICAND_WIDTH:0] significand // with implied bit

    // Packed output
    output logic[packed_width:0] packed_fp,
);

    localparam int packed_width = 1 + EXPONENT_WIDTH + SIGNIFICAND_WIDTH; // total bitwidth of fp number

    always_comb begin : pack_logic
        packed_fp = {sign, exponent, significand[SIGNIFICAND_WIDTH-1:0]}
    end

endmodule