/*
* Unpacks floating-point numbers and proves extra info.
*/
module fpu_unpack #(
    EXPONENT_WIDTH = 11,
    SIGNIFICAND_WIDTH = 52
) (
    input logic[packed_width:0] packed_fp,

    output logic sign,
    output logic[EXPONENT_WIDTH:0] exponent,
    output logic[SIGNIFICAND_WIDTH:0] significand
);

    localparam int packed_width = SIGN_WIDTH + EXPONENT_WIDTH + SIGNIFICAND_WIDTH; // total bitwidth of fp number
    localparam int significand_start = SIGNIFICAND_WIDTH - 1; // pos of first significand bit
    localparam int significand_end = 0; // pos of last significand bit
    localparam int exponent_start = significand_start + EXPONENT_WIDTH; // pos of first exponent bit
    localparam int exponent_end = significand_start + 1; // pos of last exponent bit
    localparam int sign_pos = exponent_start + 1; // pos of sign bit

    always_comb begin : unpack_logic
        sign = packed_fp[sign_pos];
        exponent = packed_fp[exponent_start:exponent_end];
        significand = packed_fp[significand_start:significand_end];
    end

endmodule