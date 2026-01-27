module control_unit(
    input clk,
    input rst,
    input istream_val,
    input b_lsb,
    output istream_rdy,
    output r_en,
    output ostream_val,
    output ostream_rdy,
    output b_mux_sel,
    output a_mux_sel,
    output r_mux_sel,
    output add_mux_sel
);
    parameter s1 = 2'd1, s2 = 2'd2, s3 = 2'd3;
    reg [1 : 0] state;
    reg [4 : 0] counter;

    data_path instance (
        .clk(clk),
        .rst(rst),
        .r_en(r_en),
        .b_mux_sel(b_mux_sel),
        .a_mux_sel(a_mux_sel),
        .r_mux_sel(r_mux_sel),
        .add_mux_sel(add_mux_sel),
        .b_lsb(b_lsb)
    );

    integer k;
    always @(rst) state = s1;
    always @(posedge clk) begin
        case(state)
        s1: case(istream_val)
            1'b0: state = s1;
            1'b1: begin
                    if(istream_rdy) state = s2;
                    else state = s1;
                  end
        
        s2: if(counter == 5'd0) begin
                b_mux_sel = 1'b0;
                a_mux_sel = 1'b0;
                r_mux_sel = 1'b0;
            end

            else if(counter == 5'd31) state = s3;

            else begin
                for(k = 0; k < 32; k = k+1) begin
                    if(b_lsb) add_mux_sel = 1'b1;
                    else add_mux_sel = 1'b0;
                end
            end

        s3: begin
                ostream_val = 1'b1;
                if(ostream_rdy) begin
                    state = s1;
                    istream_rdy = 1'b1
                end
                else state = s3;
            end
    end


endmodule