module data_path(
    input wire signed [63 : 0] istream_msg, //input stream message
    input clk,
    input rst,
    input state_done,
    input b_mux_sel,
    input a_mux_sel,
    input r_mux_sel,
    input add_mux_sel,
    input r_en,
    output b_lsb, //lsb : left significant bit
    output wire signed [31 : 0] ostream_msg
); 

    wire signed [31 : 0] b_mux_out, b_rs_out; //rs : right shift
    wire signed [31 : 0] a_mux_out, a_ls_out; //ls : left shift
    wire signed [31 : 0] r_mux1_out, r_mux2_out, partial_sum;
    wire signed [31 : 0] a = istream_msg[63 : 32];
    wire signed [31 : 0] b = istream_msg[31 : 0];
    reg  signed [31 : 0] b_reg, a_reg, r_reg;
    

    assign b_mux_out  = (b_mux_sel) ? b_rs_out : b;
    assign a_mux_out  = (a_mux_sel) ? a_ls_out : a;
    assign r_mux1_out = (r_mux_sel) ? r_mux2_out : 32'b0;
    assign r_mux2_out  = (add_mux_sel) ? partial_sum : r_reg;

    always @(posedge clk) begin
        b_reg <= b_mux_out;
        a_reg <= a_mux_out;
        if (r_en) begin
            r_reg <= r_mux1_out;
        end
    end

    assign b_rs_out = (!state_done) ? (b_reg >> 1) : b_reg;
    assign a_ls_out = (!state_done) ? (a_reg << 1) : a_reg;

    assign b_lsb = b_reg[0];
    assign ostream_msg = r_reg;
    assign partial_sum = a_reg + r_reg;

endmodule