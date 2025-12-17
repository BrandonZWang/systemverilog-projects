// Set unit to 1ns and precision to 1ps
`timescale 1ns/1ps

// Import opcode enum and alu module
`include "alu.sv"

/*
* Transactions specify one "round" of stimuli (inputs) to the DUT.
* They are created by the generator, passed to the driver, then driven to the DUT.
* Transactions also store DUT outputs for correctness checking.
*/
class alu_transaction #(parameter int WIDTH = 8);
    rand logic[WIDTH-1:0] in_A,  // First input
    rand logic[WIDTH-1:0] in_B,  // Second input
    rand logic            c_in,  // Carry in
    rand opcode           op,    // Operation

    logic[WIDTH-1:0] out,        // Output
    logic            c_out,      // Carry out
    logic            f_zero,     // Zero flag
    logic            f_negative, // Negative flag
    logic            f_overflow, // Overflow flag
    logic            f_parity    // Parity flag

    function new(); endfunction

    function string to_string();
        return $sformatf("A=%0d B=%0d c_in=%0d opcode=%4b");
    endfunction
endclass

/*
* Scoreboards check DUT outputs for correctness.
* Upon receiving 
*/
class alu_scoreboard;
    mailbox scoreboard_mailbox;
    int num_correct;
    int num_total;

    task run();
        $display("T=%0t [SCBD] Starting ...", $time);
        num_total = 0;
        num_correct = 0;

        forever begin
            // TODO
        end
    endtask

    function print_final_result();
        $display("T=%0t [SCBD] FINAL: %0d/%0d correct", $time, num_correct, num_total);
    endfunction
endclass

module tb_alu;
    int ALU_WIDTH = 8; // bit width of DUT

    int num_correct; // number of correct transactions so far
    int num_total; // number of total transactions so far
    int verbose = 0; // Whether to print verbose logs
    int wait_time = 5; // wait time in ns between transactions
    int num_transactions = 20; // total number of transactions

    alu #(WIDTH = ALU_WIDTH) dut_alu (
        .in_A, .in_B, .c_in, .op,

        .out, .c_out, .f_zero, .f_negative, .f_overflow, .f_parity
    );

    initial begin
        $dumpfile("tb_alu.vcd");
        $dumpvars(0, tb_alu);

        if($test$plusargs("verbose")) begin
            $display("Verbose logging enabled", alu_width);
            verbose = 1;
        end
        if ($value$plusargs("wait_time=%d", wait_time)) begin
            $display("Using custom wait_time = %0d", wait_time);
        end
        if ($value$plusargs("num_transactions=%d", num_transactions)) begin
            $display("Using custom num_transactions = %0d", num_transactions);
        end
        
        num_correct = 0;
        num_total = 0;
    end

    initial begin
        $display("T=%0t Starting...", $time);

        for (int i = 0; i < num_transactions; i++) {
            alu_transaction transaction = new; // Create new transaction
            transaction.randomize(); // Randomize stimuli
            if (verbose) $display("T=%0t Created transaction %0d/%0d", $time, i+1, num_transactions);

            int expected_out;
            bit expected_c_out, expected_f_zero, expected_f_negative;
            bit expected_f_overflow, expected_f_parity;

            int in_A = signed'(transaction.in_A);
            int in_B = signed'(transaction.in_B);
            bit c_in = bit'(transaction.c_in);
            opcode op = transaction.op;

            // set expected_out based on op
            int result;
            case (op)
                PASSTHROUGH     : result = in_A;
                ADD             : result = in_A + in_B;
                ADD_WITH_CIN    : result = in_A + in_B + c_in;
                SUBTRACT        : result = in_A - in_B;
                SUB_WITH_CIN    : result = in_A - in_B - ~c_in;
                TWOS_COMPLEMENT : result = -1 * tx.in_A;
                INCREMENT       : result = in_A + 1;
                DECREMENT       : result = in_A - 1;
                BIT_AND         : result = in_A & in_B;
                BIT_OR          : result = in_A | in_B;
                BIT_XOR         : result = in_A ^ in_B;
                BIT_NOT         : result = ~in_A;
                ASR             : result = in_A >>> 1;
                LSR             : result = in_A >> 1;
                SHIFT_LEFT      : result = in_A << 1;
                ROTATE_LEFT     : result = in_A >> 1 + (in_A % 2) << (ALU_WIDTH-1);
            endcase
            expected_c_out = (ALU_WIDTH)'(result);

            // set expected c_out based on op
            case (op)
                ADD             : expected_c_out = (in_A + in_B) >> ALU_WIDTH;
                ADD_WITH_CIN    : expected_c_out = (in_A + in_B + c_in) >> ALU_WIDTH;
                SUBTRACT        : result = in_A - in_B;
                SUB_WITH_CIN    : result = in_A - in_B - ~c_in;
                TWOS_COMPLEMENT : result = -1 * tx.in_A;
                INCREMENT       : result = in_A + 1;
                DECREMENT       : result = in_A - 1;
                ASR             : expected_c_out = in_A[0];
                LSR             : expected_c_out = in_A[0];
                SHIFT_LEFT      : expected_c_out = in_A[ALU_WIDTH-1];
                default         : expected_c_out = 0;
            endcase

            expected_f_zero = (expected_out == 0);
            expected_f_negative = (expected_out < 0);
            expected_f_overflow = (expected_out == 0);

            // Drive inputs to interface
            dut_alu.in_A = transaction.in_A;
            dut_alu.in_B = transaction.in_B;
            dut_alu.c_in = transaction.c_in;
            dut_alu.op = transaction.op;

            if (verbose) $display("T=%0t Sent transaction %s", $time, tx.to_string());

            transaction.out = dut_alu.out;
            transaction.c_out = dut_alu.c_out;
            transaction.f_zero = dut_alu.f_zero;
            transaction.f_negative = dut_alu.f_negative;
            transaction.f_overflow = dut_alu.f_overflow;
            transaction.f_parity = dut_alu.f_parity;

            #(wait_time);
        }

        $display("T=%0t FINAL: %0d/%0d correct", $time, num_correct, num_total);
    end
endmodule