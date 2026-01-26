/*
* Unpacks floating-point numbers and proves extra info.
* Note: Output significand contains the implied MSB so is SIGNIFICAND_WIDTH + 1 bits wide.
*/
module fpu_unpack #(
    EXPONENT_WIDTH = 11,
    SIGNIFICAND_WIDTH = 52
) (
    // Packed input
    input logic[packed_width:0] packed_fp,

    // Unpacked output
    output logic sign,
    output logic[EXPONENT_WIDTH-1:0] exponent,
    output logic[SIGNIFICAND_WIDTH:0] significand // with implied bit

    // Extra information
    output logic is_zero,
    output logic is_inf,
    output logic is_nan,
    output logic is_subnormal
);

    localparam int packed_width = SIGN_WIDTH + EXPONENT_WIDTH + SIGNIFICAND_WIDTH; // total bitwidth of fp number
    localparam int significand_start = SIGNIFICAND_WIDTH - 1; // pos of first significand bit
    localparam int significand_end = 0; // pos of last significand bit
    localparam int exponent_start = significand_start + EXPONENT_WIDTH; // pos of first exponent bit
    localparam int exponent_end = significand_start + 1; // pos of last exponent bit
    localparam int sign_pos = exponent_start + 1; // pos of sign bit

    logic[EXPONENT_WIDTH-1:0] max_exponent;
    logic[SIGNIFICAND_WIDTH-1:0] significand_raw;
    logic significand_implied_bit;

    always_comb begin : unpack_logic
        // unpacking
        sign = packed_fp[sign_pos];
        exponent = packed_fp[exponent_start:exponent_end];
        significand_raw = packed_fp[significand_start:significand_end];
        // Subnormal if exponent = 0 and significand != 0
        significand_implied_bit = is_subnormal ? 0 : 1;
        significand = {significand_implied_bit, significand_raw};

        // flags
        max_exponent = {EXPONENT_WIDTH{1'b1}}; // all 1's
        is_zero = (exponent == 0 && significand_raw == 0);
        is_subnormal = (exponent == 0 && significand_raw != 0);
        is_inf = (exponent == max_exponent && significand_raw == 0);
        is_nan = (exponent == max_exponent && significand_raw != 0);
    end

endmodule