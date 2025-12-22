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
    ROTATE_LEFT     = 4'b1111  // Rotate A left by 1
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
    output logic            f_parity    // Parity flag
);

    // // Wires for adder operations and bitwise operations
    // logic[WIDTH:0] adder_out; // Note extra width for carry bit
    // logic[WIDTH-1:0] adder_in_A, adder_in_B;
    // logic adder_in_C;
    // logic[WIDTH-1:0] bitop_out;
    // logic bitop_c_out;
    // // Determines whether ALU uses output from adder or bitwise ops
    // logic use_adder_result;

    logic[WIDTH:0] in_A_zeroext; // Zero extend A
    // logic[WIDTH:0] in_B_zeroext; // Zero extend B
    logic[WIDTH:0] in_A_signext; // Sign extend A
    logic[WIDTH:0] in_B_signext; // Sign extend B
    logic[WIDTH:0] result;

    always_comb begin : output_logic
        in_A_zeroext = {1'b0, in_A}; // Zero extend A
        // in_B_zeroext = {1'b0, in_B}; // Zero extend B
        in_A_signext = {in_A[WIDTH-1], in_A}; // Sign extend A
        in_B_signext = {in_B[WIDTH-1], in_B}; // Sign extend B
        // set outputs based on bitwise operations
        // MSB of result = carryout, rest of result = output
        case (op)
            PASSTHROUGH     : result = in_A_zeroext;
            ADD             : result = in_A_signext + in_B_signext;
            ADD_WITH_CIN    : result = in_A_signext + in_B_signext + c_in;
            SUBTRACT        : result = in_A_signext + ~in_B_signext + 1;
            SUB_WITH_CIN    : result = in_A_signext + ~in_B_signext + c_in;
            TWOS_COMPLEMENT : result = ~in_A_signext + 1;
            INCREMENT       : result = in_A_signext + 1;
            DECREMENT       : result = in_A_signext - 1;
            BIT_AND         : result = {1'b0, in_A & in_B};
            BIT_OR          : result = {1'b0, in_A | in_B};
            BIT_XOR         : result = {1'b0, in_A ^ in_B};
            BIT_NOT         : result = {1'b0, ~in_A};
            // For shifts, set the carryout = bit that was shifted off.
            ASR             : result = {in_A_signext[0], in_A_signext[WIDTH:1]}; // fill sign
            LSR             : result = {in_A_zeroext[0], in_A_zeroext[WIDTH:1]}; // fill zero
            SHIFT_LEFT      : result = {in_A, 1'b0}; // pad zero on end
            ROTATE_LEFT     : result = {1'b0, in_A[WIDTH-2:0], in_A[WIDTH-1]};
        endcase

        out = result[WIDTH-1:0];
        c_out = result[WIDTH];

        // use_adder_result = (op == ADD) || (op == ADD_WITH_CIN)
        // || (op == SUBTRACT) || (op == SUB_WITH_CIN) || (op == TWOS_COMPLEMENT)
        // || (op == INCREMENT) || (op == DECREMENT);
        // // Default value for adder operations
        // adder_out = adder_in_A + adder_in_B + adder_in_C;
        // adder_in_A = in_A;
        // adder_in_B = in_B;
        // adder_in_C = c_in;
        // case (op) // Set adder_out based on arithmetic operations
        //     ADD             : adder_in_C = 0; // in_A + in_B
        //     // ADD_WITH_CIN    : ; // in_A + in_B + c_in
        //     SUBTRACT        : begin
        //         adder_in_B = ~in_B; adder_in_C = 1; // in_A + ~in_B + 1
        //     end
        //     SUB_WITH_CIN    : begin
        //         adder_in_B = ~in_B; // in_A + ~in_B + c_in
        //     end
        //     TWOS_COMPLEMENT : begin
        //         adder_in_A = ~in_A; adder_in_B = 0; adder_in_C = 1; // ~in_A + 1
        //     end
        //     INCREMENT       : begin
        //         adder_in_B = 0; adder_in_C = 1; // in_A + 1
        //     end
        //     DECREMENT       : begin
        //         adder_in_B = -1; adder_in_C = 0; // in_A - 1
        //     end
        // endcase

        // // Default values for bitwise operation output and carry out
        // bitop_out = 0;
        // bitop_c_out = 0;
        // case (op) // set outputs based on bitwise operations
        //     PASSTHROUGH : bitop_out = in_A;
        //     BIT_AND     : bitop_out = in_A & in_B;
        //     BIT_OR      : bitop_out = in_A | in_B;
        //     BIT_XOR     : bitop_out = in_A ^ in_B;
        //     BIT_NOT     : bitop_out = ~in_A;
        //     // For shift operations, carry out = bit that was shifted off
        //     ASR         : begin
        //         bitop_out = in_A >>> 1;
        //         bitop_c_out = in_A[0];
        //     end
        //     LSR         : begin
        //         bitop_out = in_A >> 1;
        //         bitop_c_out = in_A[0];
        //     end
        //     SHIFT_LEFT  : begin
        //         bitop_out = in_A << 1;
        //         bitop_c_out = in_A[WIDTH-1];
        //     end
        //     ROTATE_LEFT : bitop_out = {in_A[WIDTH-2 : 0], in_A[WIDTH-1]};
        // endcase

        // // Determine whether to use adder or bitwise outputs
        // out = use_adder_result ? adder_out[WIDTH-1:0] : bitop_out;
        // c_out = use_adder_result ? adder_out[WIDTH] : bitop_c_out;
    end

    always_comb begin : flag_logic
        f_zero = out == 0;
        f_negative = out[WIDTH-1] == 1;
        // A and B have the same sign, A and out have different signs
        f_overflow = (in_A[WIDTH-1] == in_B[WIDTH-1]) 
            && (in_A[WIDTH-1] != out[WIDTH-1]);
        f_parity = ^out; // XOR reduction operator
    end

endmodule