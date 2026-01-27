/*
* Rounds floating-point numbers according to rounding attributes.
*/
module fpu_round #(
    EXPONENT_WIDTH = 11,
    SIGNIFICAND_WIDTH = 52,

    // 4.3.1 Rounding-direction attributes to nearest 
    ROUND_TIES_TO_EVEN = 1,
    ROUND_TIES_TO_AWAY = 0,

    // 4.3.2 Directed rounding attributes
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

    // bits for 
    logic round_up;
    logic round_down;
    logic no_round;
    logic 

    // Generate logic based on rounding direction attributes, so that no
    // unnessesary logic is generated.
    generate : round_up_logic
        if (ROUND_TOWARDS_POSITIVE == 1) begin : round_positive
            assign round_up = 1;
            assign round_down = 0;
            assign no_round = 
        end
        else if (ROUND_TOWARDS_NEGATIVE == 1) begin : round_negative
            assign rou
        end
        else if (ROUND_TOWARDS_ZERO == 1) begin : round_zero
            
        end
        else begin : round_nearest
        end
    endgenerate

    generate : round_down_logic
        if (ROUND_TOWARDS_POSITIVE == 1) begin : round_positive
            assign round_up = 1;
            assign round_down = 0;
            assign no_round = 
        end
        else if (ROUND_TOWARDS_NEGATIVE == 1) begin : round_negative
            assign rou
        end
        else if (ROUND_TOWARDS_ZERO == 1) begin : round_zero
            
        end
        else begin : round_nearest
        end
    endgenerate

    generate : final_mux
        if (ROUND_TOWARDS_POSITIVE == 1) begin : round_positive
            assign round_up = 1;
            assign round_down = 0;
            assign no_round = 
        end
        else if (ROUND_TOWARDS_NEGATIVE == 1) begin : round_negative
            assign rou
        end
        else if (ROUND_TOWARDS_ZERO == 1) begin : round_zero
            
        end
        else begin : round_nearest
        end
    endgenerate
    
endmodule