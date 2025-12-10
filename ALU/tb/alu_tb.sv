// Set unit to 1ns and precision to 1ps
`timescale 1ns/1ps

// 
`include "alu.sv"

interface alu_interface #(parameter WIDTH = 8) ();
    logic[WIDTH-1:0]  in_A,      // First input
    logic[WIDTH-1:0]  in_B,      // Second input
    logic             c_in,      // Carry in
    opcode            op,        // Operation
    
    logic[WIDTH-1:0] out,        // Output
    logic            c_out,      // Carry out
    logic            f_zero,     // Zero flag
    logic            f_negative, // Negative flag
    logic            f_overflow, // Overflow flag
    logic            f_parity    // Parity flag
endinterface

class alu_transaction;
    rand logic[WIDTH-1:0]  in_A, // First input
    rand logic[WIDTH-1:0]  in_B, // Second input
    rand logic             c_in, // Carry in
    rand opcode            op,   // Operation
endclass

class alu_generator ();
endclass

module alu_driver ();
endmodule

module alu_monitor ();
endmodule

class alu_scoreboard;
    mailbox scoreboard_mailbox;
    int num_correct;
    int num_total;

    task run();
        $display("T=%0t [Monitor] Starting ...", $time);
        num_total = 0;
        num_correct = 0;

        forever begin
    endtask
endclass