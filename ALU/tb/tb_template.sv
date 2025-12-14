// Set unit to 1ns and precision to 1ps
`timescale 1ns/1ps

// Import opcode enum and alu module
`include "alu.sv"

// Interface for the alu module. Contains
interface alu_interface #(parameter WIDTH = 8) ();
    logic[WIDTH-1:0] in_A,       // First input
    logic[WIDTH-1:0] in_B,       // Second input
    logic            c_in,       // Carry in
    opcode           op,         // Operation
    
    logic[WIDTH-1:0] out,        // Output
    logic            c_out,      // Carry out
    logic            f_zero,     // Zero flag
    logic            f_negative, // Negative flag
    logic            f_overflow, // Overflow flag
    logic            f_parity    // Parity flag

    modport driver ( // Modport for driver (inputs to drive DUT with)
        input in_A, in_B, c_in, op
    );
    modport monitor ( // Modport for monitor (outputs to send to scoreboard)
        output out, c_out, f_zero, f_negative, f_overflow, f_parity
    );
endinterface

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
* Generators create transactions.
* They create a user-specified number of (usually) random transactions and pass
* them to the driver through a mailbox.
*/
class generator ();
    mailbox driver_mailbox; // Mailbox to send transactions to driver
    int num_transactions; // Number of transactions to generate
    int verbose; // Whether to print verbose logs
    int wait_time; // Delay between transactions

    task run();
        if (verbose) $display("T=%0t [GNTR] Starting...", $time);

        for (int i = 0; i < num_transactions; i++) {
            alu_transaction transaction = new; // Create new transaction
            transaction.randomize(); // Randomize stimuli
            if (verbose) $display("T=%0t [GNTR] Created item %0d/%0d", $time, i+1, num_transactions);
            driver_mailbox.put(transaction); // Send transaction to driver
            #(wait_time);
        }

        if (verbose) $display("T=%0t [GNTR] Finished transaction creation", $time);
    endtask
endclass

/*
* Drivers send transactions to the DUT.
* Upon receiving a transaction through the mailbox, the driver perfoms all the
* setup needed to drive the stimuli to the DUT.
* This driver is simpler because the DUT has no clocked elements.
*/
class driver ();
    virtual alu_interface driver_interface; // Interface to drive transactions through
    mailbox driver_mailbox; // Mailbox to receive transactions from generator
    int verbose; // Whether to print verbose logs

    task run();
        if (verbose) $display("T=%0t [DRVR] Starting...", $time);

        forever begin
            alu_transaction transaction; // Transaction to drive to DUT
            if (verbose) $display("T=%0t [DRVR] Waiting for transaction...", $time);

            driver_mailbox.get(transaction); // Wait for transaction from mailbox
            if (verbose) $display("T=%0t [DRVR] Received transaction %s", $time, transaction.to_string());

            // Drive inputs to interface
            driver_interface.in_A = transaction.in_A;
            driver_interface.in_B = transaction.in_B;
            driver_interface.c_in = transaction.c_in;
            driver_interface.op = transaction.op;

            if (verbose) $display("T=%0t [DRVR] Sent transaction %s", $time, transaction.to_string());
        end
    endtask
endclass

/*
* Monitors receive outputs from the DUT.
* Upon DUT output, the monitor records the outputs in a transaction and sends
* them to the scoreboard via a mailbox.
*/
class alu_monitor ();
    virtual alu_interface monitor_interface; // Interface to capture outputs from
    mailbox scoreboard_mailbox; // Mialbox to send transactions to scoreboard
    int verbose; // Whether to print verbose logs

    task run();
        if (verbose) $display("T=%0t [MNTR] Starting...", $time);

        forever begin
            
        end
    endtask
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
    reg clk;
    reg rst_n;
    int verbose = 0;

    (
        .rst_n (rst_n),
        .clk (clk),
    );

    localparam CLK_PERIOD = 10;
    always #(CLK_PERIOD/2) clk=~clk;

    initial begin
        $dumpfile("tb_alu.vcd");
        $dumpvars(0, tb_alu);

        if($test$plusargs("VERBOSE")) begin
            verbose = 1;
        end
    end

    initial begin
        #1 rst_n<=1'bx;clk<=1'bx;
        #(CLK_PERIOD*3) rst_n<=1;
        #(CLK_PERIOD*3) rst_n<=0;clk<=0;
        repeat(5) @(posedge clk);
        rst_n<=1;
        @(posedge clk);
        repeat(2) @(posedge clk);
        $finish(2);
    end
endmodule