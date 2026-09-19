`timescale 1ns / 1ps

module barrel_shifter (
    input  wire [31:0] data_in,     // 32-bit input operand
    input  wire [4:0]  shamt,       // 5-bit shift amount (0 to 31)
    input  wire [1:0]  shift_type,  // 2'b00: SLL, 2'b01: SRL, 2'b10: SRA
    output wire [31:0] data_out     // 32-bit shifted result
);

    // 1. Sign-extension bit for Arithmetic Right Shift (SRA)
    wire sign_bit = (shift_type == 2'b10) ? data_in[31] : 1'b0;

    // 2. Input bit-reversal: if SLL, reverse the bits to reuse the right shifter
    wire [31:0] stage0_in;
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : gen_reverse_in
            assign stage0_in[i] = (shift_type == 2'b00) ? data_in[31 - i] : data_in[i];
        end
    endgenerate

    // 3. 5-Stage Logarithmic Right-Shift Cascade
    // Stage 0: Shift right by 1
    wire [31:0] stage1_in = shamt[0] ? {{1{sign_bit}}, stage0_in[31:1]} : stage0_in;

    // Stage 1: Shift right by 2
    wire [31:0] stage2_in = shamt[1] ? {{2{sign_bit}}, stage1_in[31:2]} : stage1_in;

    // Stage 2: Shift right by 4
    wire [31:0] stage3_in = shamt[2] ? {{4{sign_bit}}, stage2_in[31:4]} : stage2_in;

    // Stage 3: Shift right by 8
    wire [31:0] stage4_in = shamt[3] ? {{8{sign_bit}}, stage3_in[31:8]} : stage3_in;

    // Stage 4: Shift right by 16
    wire [31:0] stage5_out = shamt[4] ? {{16{sign_bit}}, stage4_in[31:16]} : stage4_in;

    // 4. Output bit-reversal: if SLL, reverse bits back to restore left-shift order
    generate
        for (i = 0; i < 32; i = i + 1) begin : gen_reverse_out
            assign data_out[i] = (shift_type == 2'b00) ? stage5_out[31 - i] : stage5_out[i];
        end
    endgenerate

endmodule