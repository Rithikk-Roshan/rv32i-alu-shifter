`timescale 1ns / 1ps

module barrel_shifter_tb;

    // 1. Testbench Signals (reg drives DUT inputs, wire monitors DUT outputs)
    reg  [31:0] data_in;
    reg  [4:0]  shamt;
    reg  [1:0]  shift_type;
    wire [31:0] data_out;

    integer error_count = 0;

    // 2. Instantiate Device Under Test (DUT)
    barrel_shifter uut (
        .data_in    (data_in),
        .shamt      (shamt),
        .shift_type (shift_type),
        .data_out   (data_out)
    );

    // 3. Verification Task: Applies inputs and checks expected outputs
    task check_result;
        input [31:0] expected;
        input [8*16:1] test_name;
        begin
            #10; // Wait 10ns for combinational propagation
            if (data_out !== expected) begin
                $display("[FAIL] %s: Expected 0x%h, Got 0x%h", test_name, expected, data_out);
                error_count = error_count + 1;
            end else begin
                $display("[PASS] %s: Output = 0x%h", test_name, data_out);
            end
        end
    endtask

    // 4. Test Stimulus Sequence
    initial begin
        $display("--- Starting Barrel Shifter Verification ---");

        // Test Case 1: SLL by 0 (Identity Check)
        data_in = 32'hA5A5_5A5A; shamt = 5'd0; shift_type = 2'b00;
        check_result(32'hA5A5_5A5A, "SLL by 0");

        // Test Case 2: SLL by 4
        data_in = 32'h0000_000F; shamt = 5'd4; shift_type = 2'b00;
        check_result(32'h0000_00F0, "SLL by 4");

        // Test Case 3: SLL by 31 (MSB shift)
        data_in = 32'h0000_0001; shamt = 5'd31; shift_type = 2'b00;
        check_result(32'h8000_0000, "SLL by 31");

        // Test Case 4: SRL by 4 (Zero Extension)
        data_in = 32'hF000_0000; shamt = 5'd4; shift_type = 2'b01;
        check_result(32'h0F00_0000, "SRL by 4");

        // Test Case 5: SRA by 4 (Negative Number Sign Extension)
        data_in = 32'h8000_0000; shamt = 5'd4; shift_type = 2'b10;
        check_result(32'hF800_0000, "SRA Negative by 4");

        // Test Case 6: SRA by 4 (Positive Number Zero Fill)
        data_in = 32'h7000_0000; shamt = 5'd4; shift_type = 2'b10;
        check_result(32'h0700_0000, "SRA Positive by 4");

        // Test Case 7: SRA by 31 (All sign bits)
        data_in = 32'h8000_0000; shamt = 5'd31; shift_type = 2'b10;
        check_result(32'hFFFF_FFFF, "SRA Negative by 31");

        // Summary Verdict
        #10;
        if (error_count == 0)
            $display("\n>>> ALL TESTS PASSED SUCCESSFULLY! <<<\n");
        else
            $display("\n>>> TEST SUITE COMPLETED WITH %0d ERRORS <<<\n", error_count);

        $finish;
    end

endmodule