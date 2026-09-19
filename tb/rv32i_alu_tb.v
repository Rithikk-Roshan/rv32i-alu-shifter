`timescale 1ns / 1ps

module rv32i_alu_tb;

    // Testbench Stimulus Signals
    reg  [31:0] a;
    reg  [31:0] b;
    reg  [3:0]  alu_ctrl;
    wire [31:0] alu_out;
    wire        zero_flag;

    integer error_count = 0;

    // Instantiate Device Under Test (DUT)
    rv32i_alu dut (
        .a         (a),
        .b         (b),
        .alu_ctrl  (alu_ctrl),
        .alu_out   (alu_out),
        .zero_flag (zero_flag)
    );

    // Self-checking task (wider string buffer to avoid truncation)
    task check_alu;
        input [31:0]    exp_out;
        input           exp_zero;
        input [8*32:1]  test_name;
        begin
            #10; // Propagation delay
            if (alu_out !== exp_out || zero_flag !== exp_zero) begin
                $display("[FAIL] %0s | Out: 0x%08h (Exp: 0x%08h) | Zero: %b (Exp: %b)",
                         test_name, alu_out, exp_out, zero_flag, exp_zero);
                error_count = error_count + 1;
            end else begin
                $display("[PASS] %0s | Out: 0x%08h | Zero: %b", test_name, alu_out, zero_flag);
            end
        end
    endtask

    initial begin
        $display("==================================================");
        $display("         STARTING RV32I ALU VERIFICATION          ");
        $display("==================================================");

        // --- 1. ADD & SUB ---
        // ADD normal
        a = 32'd15; b = 32'd27; alu_ctrl = 4'b0000;
        check_alu(32'd42, 1'b0, "ADD 15 + 27");

        // SUB normal
        a = 32'd100; b = 32'd45; alu_ctrl = 4'b0001;
        check_alu(32'd55, 1'b0, "SUB 100 - 45");

        // SUB producing ZERO (checks zero_flag assertion)
        a = 32'hDEAD_BEEF; b = 32'hDEAD_BEEF; alu_ctrl = 4'b0001;
        check_alu(32'h0000_0000, 1'b1, "SUB equal values (Zero Flag)");

        // --- 2. LOGICAL OPERATIONS ---
        // XOR
        a = 32'hFF00_AA55; b = 32'h0F0F_FFFF; alu_ctrl = 4'b0101;
        check_alu(32'hF00F_55AA, 1'b0, "XOR bitwise");

        // OR
        a = 32'hF0F0_0000; b = 32'h0000_0F0F; alu_ctrl = 4'b1000;
        check_alu(32'hF0F0_0F0F, 1'b0, "OR bitwise");

        // AND
        a = 32'hFFFF_0000; b = 32'hAAAA_5555; alu_ctrl = 4'b1001;
        check_alu(32'hAAAA_0000, 1'b0, "AND bitwise");

        // --- 3. COMPARISONS (SLT / SLTU) ---
        // SLT: Both positive (10 < 20 -> true)
        a = 32'd10; b = 32'd20; alu_ctrl = 4'b0011;
        check_alu(32'd1, 1'b0, "SLT pos < pos (True)");

        // SLT: Negative vs Positive (-5 < 5 -> true)
        a = -32'd5; b = 32'd5; alu_ctrl = 4'b0011;
        check_alu(32'd1, 1'b0, "SLT neg < pos (True)");

        // SLT: Signed Overflow Corner Case (+2B < -2B -> false)
        // a = 0x70000000 (+1.87B), b = 0x80000000 (-2.14B)
        a = 32'h7000_0000; b = 32'h8000_0000; alu_ctrl = 4'b0011;
        check_alu(32'd0, 1'b1, "SLT overflow test (False)");

        // SLTU: Unsigned Comparison (0x70000000 < 0x80000000 -> true)
        a = 32'h7000_0000; b = 32'h8000_0000; alu_ctrl = 4'b0100;
        check_alu(32'd1, 1'b0, "SLTU unsigned magnitude (True)");

        // --- 4. SHIFTS VIA BARREL SHIFTER ---
        // SLL
        a = 32'h0000_0001; b = 32'd12; alu_ctrl = 4'b0010;
        check_alu(32'h0000_1000, 1'b0, "SLL by 12");

        // SRL
        a = 32'h8000_0000; b = 32'd4; alu_ctrl = 4'b0110;
        check_alu(32'h0800_0000, 1'b0, "SRL by 4");

        // SRA (arithmetic sign preservation)
        a = 32'h8000_0000; b = 32'd4; alu_ctrl = 4'b0111;
        check_alu(32'hF800_0000, 1'b0, "SRA negative by 4");

        // --- VERDICT ---
        #10;
        $display("==================================================");
        if (error_count == 0)
            $display(">>> ALL 12 ALU TESTS PASSED SUCCESSFULLY! <<<");
        else
            $display(">>> TEST SUITE FAILED WITH %0d ERRORS <<<", error_count);
        $display("==================================================");

        $finish;
    end

endmodule