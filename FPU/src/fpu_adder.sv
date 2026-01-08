/*
Module that adds two FPU numbers, returning the result as a double-wide significand.
*/
module fpu_adder #(
    k = 64, // Total width
    w = 11, // Width of exponent
    t = 52  // Width of significand
) (
    input logic[k-1:0] a, // Input a
    input logic[k-1:0] b,

    output logic[k-1:0] out,
    output logic overflow, otherflags // TODO
);
    logic a_sign;
    logic[w-1:0] a_exponent;
    logic[w-1:0] a_significiand;
    logic b_sign;
    logic[w-1:0] b_exponent;
    logic[w-1:0] a_significiand;

    logic a_is_greater;
    logic[w-1:0] large_exponent;
    logic[t-1:0] large_significand;
    logic[w-1:0] small_exponent;
    logic[t-1:0] small_significand;

    logic[w-1:0] shift_amount;
    logic[t+2:0] add_result;

    always_comb begin
        a_sign = a[k-1];
        a_exponent = a[w+t-1:t]; // aka k-2:t
        a_significand = a[t-1:0];
        b_sign = b[k-1];
        b_exponent = b[w+t-1:t];
        b_significand = b[t-1:0];
        
        a_is_greater = (a_exponent > b_exponent);
        large_exponent = (a_is_greater) ? a_exponent : b_exponent;
        large_significand = (a_is_greater) ? a_significand : b_significand;
        small_exponent = (a_is_greater) ? b_exponent : a_exponent;
        small_significand  = (a_is_greater) ? b_significand : a_significand;

        shift_amount = large_exponent - small_exponent;
        // One bit on the left to capture overflow, 2 on the right for guard and round
        add_result = {1'b0, large_significand, 2'b0} + (small_significand >> shift_amount);
        out_significand = add_result[t+2:0];
        overflow = add_result[t-1];
        guard = add_result[1];
        round = add_result[0];
        // Reduction OR of bits that were shifted off (if there are any)
        sticky = |small_significand[((shift_amount-3 > 0) ? shift_amount-3 : 0):0];

        out_exponent = small_exponent;
    end
     
endmodule










