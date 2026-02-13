module main(
    input clk,
    input rst,

    input wire signed [63 : 0] istream_msg,
    input wire istream_val,
    output wire istream_rdy,

    output wire [31 : 0] ostream_msg,
    output wire [31 : 0] ostream_val,
    input wire [31 : 0] ostream_rdy
);

    wire b_lsb, state_done, r_en;
    wire a_mux_sel, b_mux_sel, r_mux_sel, add_mux_sel;

    control_init ctrl (
        .clk(clk),
        .rst(rst),
        .b_lsb(b_lsb),
        .istream_rdy(istream_rdy),
        .istream_val(istream_val),
        .ostream_rdy(ostream_rdy),
        .ostream_val(ostream_val),
        .a_mux_sel(a_mux_sel),
        .b_mux_sel(b_mux_sel),
        .r_mux_sel(r_mux_sel),
        .add_mux_sel(add_mux_sel),
        .r_en(r_en),
        .state_done(state_done)
    );

    datapath data (
        .clk(clk),
        .rst(rst),
        .istream_msg(istream_msg),
        .ostream_msg(ostream_msg),
        .state_done(state_done),
        .a_mux_sel(a_mux_sel),
        .b_mux_sel(b_mux_sel),
        .r_mux_sel(r_mux_sel),
        .add_mux_sel(add_mux_sel),
        .r_en(r_en),
        .state_done(state_done),
        .b_lsb(b_lsb)
    );

endmodule