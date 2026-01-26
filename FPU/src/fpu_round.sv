/*
* Rounds floating-point numbers according to rounding direction.
*/
module fpu_round #(
    EXPONENT_WIDTH = 11,
    SIGNIFICAND_WIDTH = 52,

    ROUND_TIES_TO_EVEN = 1,
    ROUND_TOWARDS_POSITIVE = 0,
    ROUND_TOWARDS_NEGATIVE = 0,
    ROUND_TOWARDS_ZERO = 0,
) (
    // Unrounded input
    input logic in_sign,
    input logic[EXPONENT_WIDTH-1:0] in_exponent,
    input logic[SIGNIFICAND_WIDTH:0] in_significand, // with implied bit
    input logic guard,
    input logic round,
    input logic sticky,

    // Rounded output
    input logic out_sign,
    input logic[EXPONENT_WIDTH-1:0] out_exponent,
    input logic[SIGNIFICAND_WIDTH:0] out_significand // with implied bit
);


    
endmodule