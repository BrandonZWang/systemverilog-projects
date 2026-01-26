/*
* Unpacks floating-point numbers and proves extra info.
*/
module fpu_unpack #(
    EXPONENT_WIDTH = 11,
    SIGNIFICAND_WIDTH = 52
) (
    input 
);

localparam int packed_width = SIGN_WIDTH + EXPONENT_WIDTH + SIGNIFICAND_WIDTH; // total bitwidth of fp number
localparam int significand_start = SIGNIFICAND_WIDTH - 1; // pos of first signicand bit
localparam int significand_end = 0; // pos of last signicand bit
localparam int exponent_start = significand_start + EXPONENT_WIDTH; // pos of first exponent bit
localparam int exponent_end = significand_start + 1; // pos of last exponent bit
localparam int sign_pos = exponent_start + 1; // pos of sign bit

    
endmodule