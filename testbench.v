`timescale 1ns / 1ps

module tb;

    reg clk, rst;
    reg signed [63:0] istream_msg;
    reg istream_val;
    wire istream_rdy;
    wire signed [31:0] ostream_msg;
    wire ostream_val;
    reg ostream_rdy;

    imul_main dut (
        .clk(clk),
        .rst(rst),
        .istream_msg(istream_msg),
        .istream_val(istream_val),
        .istream_rdy(istream_rdy),
        .ostream_msg(ostream_msg),
        .ostream_val(ostream_val),
        .ostream_rdy(ostream_rdy)
    );

    always #5 clk = ~clk;

    task send_and_check;
        input signed [63:0] msg;
        input signed [31:0] expected;
        input [8*15-1:0] label;
        begin
            istream_msg = msg;
            istream_val = 1'b1;
            
            wait (istream_rdy == 1'b1);
            @(posedge clk);
            istream_val = 1'b0;

            wait (ostream_val == 1'b1);
            if (ostream_msg === expected)
                $display("PASS | %s | Got: %0d", label, ostream_msg);
            else
                $display("FAIL | %s | Got: %0d | Exp: %0d", label, ostream_msg, expected);

            ostream_rdy = 1'b1;
            @(posedge clk);
            ostream_rdy = 1'b0;
            #20;
        end
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb);
        
        clk = 0; rst = 1;
        istream_msg = 0; istream_val = 0; ostream_rdy = 0;
        #20; rst = 0; #10;

        send_and_check({32'd3,   32'd10},       32'd30,          "3 * 10       ");
        send_and_check({-32'd5,  32'd6},        -32'd30,         "-5 * 6       ");
        send_and_check({32'd7,   -32'd4},       -32'd28,         "7 * -4       ");
        send_and_check({-32'd8,  -32'd9},       32'd72,          "-8 * -9      ");
        send_and_check({32'd0,   32'd15},       32'd0,           "0 * 15       ");
        send_and_check({32'd1,   -32'd99},      -32'd99,         "1 * -99      ");
        send_and_check({32'd255, 32'd255},      32'd65025,       "255 * 255    ");
        send_and_check({32'd3,   32'h80000000}, -32'd2147483648, "3 * 2^31     ");

        $finish;
    end

endmodule