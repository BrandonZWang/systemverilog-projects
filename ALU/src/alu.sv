/*
* Variable width two's complement ALU. Default 8 bits wide.
*/

typedef enum logic[3:0] {
    PASSTHROUGH     = 4'b0000,
    ADD             = 4'b0001,
    ADD_WITH_CIN    = 4'b0010,
    SUBTRACT        = 4'b0011,
    SUB_WITH_CIN    = 4'b0100,
    TWOS_COMPLEMENT = 4'b0101,
    INCREMENT       = 4'b0110,
    DECREMENT       = 4'b0111,
    BIT_AND         = 4'b1000,
    BIT_OR          = 4'b1001,
    BIT_XOR         = 4'b1010,
    BIT_NOT         = 4'b1011,
    ASR             = 4'b1100,
    LSR             = 4'b1101,
    SHIFT_LEFT      = 4'b1110,
    ROTATE          = 4'b1111,
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

    logic[WIDTH : 0] adder_out;

    always_comb begin : output_logic
        logic[WIDTH-1:0] adder_in_A, adder_in_B; // Inputs to adder
        logic adder_in_C; 

        logic[WIDTH:0] adder_out = adder_in_A + adder_in_B + adder_in_C;
        c_out = 0; // default carryout value
        logic[WIDTH:0] result = adder_in_A + adder_in_B + adder_in_C;

        case (op)
            PASSTHROUGH     : result = in_A;
            ADD             : result = in_A + in_B;
            ADD_WITH_CIN    : result = in_A + in_B + c_in;
            SUBTRACT        : result = in_A + ~in_B + 1;
            SUB_WITH_CIN    : result = in_A + ~in_B + c_in;
            TWOS_COMPLEMENT : result = ~in_A + 1;
            INCREMENT       : result = in_A + 1;
            DECREMENT       : result = in_A - 1;
            BIT_AND         : result = in_A & in_B;
            BIT_OR          : result = in_A | in_B;
            BIT_XOR         : result = in_A ^ in_B;
            BIT_NOT         : result = ~in_A;
            ASR             : result = in_A >>> 1;
            LSR             : result = in_A >> 1;
            SHIFT_LEFT      : result = in_A << 1;
            ROTATE_LEFT     : result = {in_A[WIDTH-2 : 0], in_A[WIDTH-1]};
        endcase

        out = result[WIDTH-1:0];
    end

    always_comb begin : output_logic
    end

    always_comb begin : flag_logic
        zero = (out == 0);
        negative = (out[WIDTH-1] == 1);
        overflow = TODO;
        parity = ^out; // XOR reduction operator
    end

endmodule