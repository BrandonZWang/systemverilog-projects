// Set unit to 1ns and precision to 1ps
`timescale 1ns/1ps

// Import opcode enum and alu module
`include "alu.sv"

// DEFINE ALU WIDTH HERE
`define ALU_WIDTH 8

/*
* Transactions specify one "round" of stimuli (inputs) to the DUT.
* Transactions also store DUT outputs for correctness checking.
*/
class alu_transaction #(int WIDTH = 8);
    logic[WIDTH-1:0] in_A;  // First input
    logic[WIDTH-1:0] in_B;  // Second input
    logic            c_in;  // Carry in
    opcode           op;    // Operation

    logic[WIDTH-1:0] out;        // Output
    logic            c_out;      // Carry out
    logic            f_zero;     // Zero flag
    logic            f_negative; // Negative flag
    logic            f_overflow; // Overflow flag
    logic            f_parity;   // Parity flag

    function new(); endfunction

    // Write my own randomize function cuz I don't have a license :/
    function void new_random_inputs();
        in_A = (WIDTH-1)'($urandom);
        in_B = (WIDTH-1)'($urandom);
        c_in = (WIDTH-1)'($urandom);
        op = opcode'($urandom);
    endfunction

    // inputs_to_string() formats the inputs to the DUT
    function string inputs_to_string();
        return $sformatf("A=%0d B=%0d c_in=%1b opcode=%4b", in_A, in_B, c_in, op);
    endfunction

    // result_to_string() formats the full transaction contents including inputs / outputs
    function string result_to_string();
        return $sformatf("A=%0d B=%0d c_in=%1b opcode=%4b out=%0d c_out=%1b f_zero=%1b f_negative=%1b f_overflow=%1b f_parity=%1b",
            in_A, in_B, c_in, op, signed'(out), c_out, f_zero, f_negative, f_overflow, f_parity);
    endfunction
endclass

/*
* Comprehensive randomized testbench for the alu module.
* Command-line arguments to change verbosity, transaction wait time, 
* and number of transactions.
* Uses the alu_transaction object to drive and capture stimuli.
*
* Parameterize the width of the ALU by changing ALU_WIDTH below.
*/
module tb_alu;
    int num_correct; // Number of correct transactions so far
    int num_total; // Number of total transactions so far
    int verbose = 0; // Whether to print verbose logs
    int wait_time = 1; // Wait time in ns between transactions
    int num_transactions = 200; // Total number of transactions

    // DUT with parameterized width
    logic[`ALU_WIDTH-1:0] in_A, in_B, out;
    logic c_in, c_out, f_zero, f_negative, f_overflow, f_parity;
    opcode op;
    alu #(.WIDTH(`ALU_WIDTH)) dut_alu (
        .in_A(in_A), .in_B(in_B), .c_in(c_in), .op(op),

        .out(out), .c_out(c_out), .f_zero(f_zero), .f_negative(f_negative), 
        .f_overflow(f_overflow), .f_parity(f_parity)
    );

    // Setup
    initial begin
        // Set output file for waveform
        $dumpfile("tb_alu.vcd");
        $dumpvars(0, tb_alu);

        // Test for command line arguments
        if($test$plusargs("verbose")) begin
            $display("Verbose logging enabled");
            verbose = 1;
        end
        if ($value$plusargs("wait_time=%0d", wait_time)) begin
            $display("Using custom wait_time = %0d", wait_time);
        end
        if ($value$plusargs("num_transactions=%0d", num_transactions)) begin
            $display("Using custom num_transactions = %0d", num_transactions);
        end
    end

    initial begin
        alu_transaction #(.WIDTH(`ALU_WIDTH)) transaction;
        // All variables to calculate expected outputs
        int in_A_int, in_B_int, expected_out, result;
        bit expected_c_out, expected_f_zero, expected_f_negative;
        bit expected_f_overflow, expected_f_parity;
        logic c_in_bit; // Logic, not bit because bit behavior is weird

        // Initialize transaction tracker
        num_correct = 0;
        num_total = 0;

        $display("T=%0t Starting...", $time);
        // Generate transactions in loop
        for (int i = 0; i < num_transactions; i++) begin
            transaction = new; // Create new transaction
            transaction.new_random_inputs(); // Randomize stimuli
            if (verbose) $display("T=%0t Created transaction %0d/%0d", $time, i+1, num_transactions);
 
            // Calculate expected outputs
            // Cast transaction elements to appropriate types, just in case
            in_A_int = signed'(transaction.in_A);
            in_B_int = signed'(transaction.in_B);
            c_in_bit = logic'(transaction.c_in);

            // Set expected_out based on op
            case (transaction.op)
                PASSTHROUGH     : result = in_A_int;
                ADD             : result = in_A_int + in_B_int;
                ADD_WITH_CIN    : result = in_A_int + in_B_int + c_in_bit;
                SUBTRACT        : result = in_A_int - in_B_int;
                SUB_WITH_CIN    : result = in_A_int - in_B_int - (`ALU_WIDTH)'((c_in_bit) ? 0 : 1); // Weird but works!
                TWOS_COMPLEMENT : result = -1 * in_A_int;
                INCREMENT       : result = in_A_int + 1;
                DECREMENT       : result = in_A_int - 1;
                BIT_AND         : result = in_A_int & in_B_int;
                BIT_OR          : result = in_A_int | in_B_int;
                BIT_XOR         : result = in_A_int ^ in_B_int;
                BIT_NOT         : result = ~in_A_int;
                ASR             : result = in_A_int >>> 1;
                LSR             : result = in_A_int >> 1;
                SHIFT_LEFT      : result = in_A_int << 1;
                // For rotate, don't worry about MSB because expected_out calculation
                ROTATE_LEFT     : result = (in_A_int << 1) + (in_A_int >> (`ALU_WIDTH-1)); 
            endcase
            expected_out = (`ALU_WIDTH)'(result);

            // set expected c_out based on op
            case (transaction.op)
                ADD             : expected_c_out = result >> `ALU_WIDTH; // MSB
                ADD_WITH_CIN    : expected_c_out = result >> `ALU_WIDTH;
                SUBTRACT        : expected_c_out = result >> `ALU_WIDTH;
                SUB_WITH_CIN    : expected_c_out = result >> `ALU_WIDTH;
                TWOS_COMPLEMENT : expected_c_out = result >> `ALU_WIDTH;
                INCREMENT       : expected_c_out = result >> `ALU_WIDTH;
                DECREMENT       : expected_c_out = result >> `ALU_WIDTH;
                ASR             : expected_c_out = in_A_int[0]; // Rotated bit off
                LSR             : expected_c_out = in_A_int[0];
                SHIFT_LEFT      : expected_c_out = in_A_int[`ALU_WIDTH-1];
                default         : expected_c_out = 0; // 0 for all others
            endcase

            // Flag calculation
            expected_f_zero = (expected_out == 0);
            expected_f_negative = (expected_out < 0);
            // A and B have same sign + A and out have different signs
            expected_f_overflow = ((in_A_int<0)==(in_B_int<0)) && ((in_A_int<0)!=(expected_out<0));
            expected_f_parity = ^expected_out;

            // Drive inputs to DUT
            in_A = transaction.in_A;
            in_B = transaction.in_B;
            c_in = transaction.c_in;
            op = transaction.op;
            if (verbose) $display("T=%0t Sent transaction %s", $time, transaction.inputs_to_string());

            #(wait_time); // Wait for wait_time ns until next transaction

            // Capture outputs from DUT
            transaction.out = out;
            transaction.c_out = c_out;
            transaction.f_zero = f_zero;
            transaction.f_negative = f_negative;
            transaction.f_overflow = f_overflow;
            transaction.f_parity = f_parity;

            // Check that all outputs match expected values
            if (signed'(transaction.out) == expected_out && transaction.c_out == expected_c_out
                && transaction.f_zero == expected_f_zero && transaction.f_negative == expected_f_negative
                && transaction.f_overflow == expected_f_overflow && transaction.f_parity == expected_f_parity) begin
                if (verbose) $display("T=%0t Passed %s", $time, transaction.result_to_string());
                num_correct += 1;
            end
            else begin // Fail if they don't match
                $display("T=%0t FAILED %s\n    EXPECTED out=%0d c_out=%1b f_zero=%1b f_negative=%1b f_overflow=%1b f_parity=%1b", 
                    $time, transaction.result_to_string(), expected_out, expected_c_out,
                    expected_f_zero,expected_f_negative, expected_f_overflow, expected_f_parity);
            end

            num_total += 1; // Increment transaction counter
        end

        // Print final result
        $display("T=%0t FINAL: %0d/%0d correct", $time, num_correct, num_total);
    end
endmodule