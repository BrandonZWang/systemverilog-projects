/*
* Variable width two's complement ALU. Default 8 bits wide.
*/

typedef enum logic[3:0] {
    PASSTHROUGH     = 4'b0000, // Passthrough
    ADD             = 4'b0001, // Add
    ADD_WITH_CIN    = 4'b0010, // Add with carry in
    SUBTRACT        = 4'b0011, // Subtract
    SUB_WITH_CIN    = 4'b0100, // Subtract with carry (see README)
    TWOS_COMPLEMENT = 4'b0101, // Two's complement of A
    INCREMENT       = 4'b0110, // Increment A
    DECREMENT       = 4'b0111, // Decrement A
    BIT_AND         = 4'b1000, // Bitwise AND
    BIT_OR          = 4'b1001, // Bitwise OR
    BIT_XOR         = 4'b1010, // Bitwise XOR
    BIT_NOT         = 4'b1011, // Bitwise NOT of A
    ASR             = 4'b1100, // Arithmetic shift A right by 1
    LSR             = 4'b1101, // Logical shift A right by 1
    SHIFT_LEFT      = 4'b1110, // Shift A left by 1
    ROTATE          = 4'b1111, // Rotate A left by 1
} opcode;

module alu #(parameter WIDTH = 8) (
    input logic[WIDTH-1:0]  in_A,       // First input
    input logic[WIDTH-1:0]  in_B,       // Second input
    input logic             c_in,       // Carry in
    input opcode            op,         // Operation (opcode enum above)
    
    output logic[WIDTH-1:0] out,        // Output
    output logic            c_out,      // Carry out
    output logic            f_zero,     // Zero flag
    output logic            f_negative, // Negative flag
    output logic            f_overflow, // Overflow flag
    output logic            f_parity,   // Parity flag
);

    // Output wires for adder operations and bitwise operations
    logic[WIDTH:0] adder_out; // Note extra width for carry bit
    logic[WIDTH-1:0] bitop_out;
    logic bitop_c_out;
    // Determines whether ALU uses output from adder or bitwise ops
    logic use_adder_result = (op == ADD) || (op == ADD_WITH_CIN)
        || (op == SUBTRACT) || (op == SUB_WITH_CIN) || (op = TWOS_COMPLEMENT)
        || (op == INCREMENT) || (op == DECREMENT);

    always_comb begin : output_logic
        // Default value for adder operation output
        adder_out = 0;
        case (op) // Set adder_out based on arithmetic operations
            ADD             : adder_out = in_A + in_B;
            ADD_WITH_CIN    : adder_out = in_A + in_B + c_in;
            SUBTRACT        : adder_out = in_A + ~in_B + 1;
            SUB_WITH_CIN    : adder_out = in_A + ~in_B + c_in;
            TWOS_COMPLEMENT : adder_out = ~in_A + 1;
            INCREMENT       : adder_out = in_A + 1;
            DECREMENT       : adder_out = in_A - 1;
        endcase

        // Default values for bitwise operation output and carry out
        bitop_out = 0;
        bitop_c_out = 0;
        case (op) // set outputs based on bitwise operations
            PASSTHROUGH : bitop_out = in_A;
            BIT_AND     : bitop_out = in_A & in_B;
            BIT_OR      : bitop_out = in_A | in_B;
            BIT_XOR     : bitop_out = in_A ^ in_B;
            BIT_NOT     : bitop_out = ~in_A;
            // For shift operations, carry out = bit that was shifted off
            ASR         : begin
                bitop_out = in_A >>> 1;
                bitop_c_out = in_A[0];
            end
            LSR         : begin
                bitop_out = in_A >> 1;
                bitop_c_out = in_A[0];
            end
            SHIFT_LEFT  : begin
                bitop_out = in_A << 1;
                bitop_c_out = in_A[WIDTH-1];
            end
            ROTATE_LEFT : bitop_out = {in_A[WIDTH-2 : 0], in_A[WIDTH-1]};
        endcase

        // Determine whether to use adder or bitwise outputs
        out = use_adder_result ? adder_out[WIDTH-1:0] : bitop_out;
        c_out = use_adder_result ? adder_out[WIDTH] : bitop_c_out;
    end

    always_comb begin : flag_logic
        zero = (out == 0);
        negative = (out[WIDTH-1] == 1);
        overflow = 0;
        if (
            (
                // Case 1: MSB changes when adding two numbers with the same sign.
                in_A[WIDTH] == in_B[WIDTH] // Same sign
                && out[WIDTH] != in_A[WIDTH] // MSB changes
                && ( // Opcode was an add
                    op == ADD
                    || op == ADD_WITH_CIN
                )
            )
            || (
                // Case 2: MSB changes when subtracting two numbers with different signs.
                in_A[WIDTH] != in_B[WIDTH] // Different signs
                && out[WIDTH] != in_A[WIDTH] // MSB changes
                && ( // Opcode was a sub
                    op == SUBTRACT
                    || op == SUB_WITH_CIN
                )
            )
        ) begin
            overflow = 1;
        end
        parity = ^out; // XOR reduction operator
    end

endmodule