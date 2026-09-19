`timescale 1ns / 1ps

module rv32i_alu (
    input  wire [31:0] a,          // Operand A (from rs1 or PC)
    input  wire [31:0] b,          // Operand B (from rs2 or immediate)
    input  wire [3:0]  alu_ctrl,   // 4-bit ALU control code
    output reg  [31:0] alu_out,    // 32-bit ALU computation result
    output wire        zero_flag   // High if alu_out is zero (used for BEQ/BNE)
);

    // 1. Shared Adder/Subtractor Unit
    // When alu_ctrl == 4'b0001 (SUB), invert B and set carry_in to 1
    wire        is_sub       = (alu_ctrl == 4'b0001)|| (alu_ctrl == 4'b0011);
    wire [31:0] b_invert     = is_sub ? ~b : b;
    wire [31:0] sum_result   = a + b_invert + is_sub;

    // 2. Set Less Than (SLT / SLTU) Logic
    // Signed comparison: check sign bits first to prevent 2's complement overflow errors
    wire slt_result  = (a[31] != b[31]) ? a[31] : sum_result[31];
    wire sltu_result = (a < b);

    // 3. Instantiate the Logarithmic Barrel Shifter
    wire [31:0] shift_result;
    wire [1:0]  shift_type;

    // Map alu_ctrl to shifter modes:
    // 4'b0010 (SLL) -> 2'b00
    // 4'b0110 (SRL) -> 2'b01
    // 4'b0111 (SRA) -> 2'b10
    assign shift_type = (alu_ctrl == 4'b0010) ? 2'b00 :
                        (alu_ctrl == 4'b0110) ? 2'b01 : 2'b10;

    barrel_shifter u_barrel_shifter (
        .data_in    (a),
        .shamt      (b[4:0]),
        .shift_type (shift_type),
        .data_out   (shift_result)
    );

    // 4. Output Multiplexer
    always @(*) begin
        case (alu_ctrl)
            4'b0000: alu_out = sum_result;                  // ADD
            4'b0001: alu_out = sum_result;                  // SUB
            4'b0010: alu_out = shift_result;                // SLL
            4'b0011: alu_out = {31'b0, slt_result};         // SLT
            4'b0100: alu_out = {31'b0, sltu_result};        // SLTU
            4'b0101: alu_out = a ^ b;                       // XOR
            4'b0110: alu_out = shift_result;                // SRL
            4'b0111: alu_out = shift_result;                // SRA
            4'b1000: alu_out = a | b;                       // OR
            4'b1001: alu_out = a & b;                       // AND
            default: alu_out = 32'h0000_0000;
        endcase
    end

    // 5. Zero Flag Generation
    assign zero_flag = (alu_out == 32'h0000_0000);

endmodule