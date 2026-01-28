module control_unit(
    input clk,
    input rst,
    input b_lsb,
    input istream_val,
    input ostream_rdy,
    output reg istream_rdy,
    output reg ostream_val,
    output reg b_mux_sel,
    output reg a_mux_sel,
    output reg r_mux_sel,
    output reg add_mux_sel,
    output reg r_en,
    output reg state_done
);

    //s1,s2,s3 - FSM states
    //s1:idle, s2:calc, s3:done

    parameter s1 = 2'd1, s2 = 2'd2, s3 = 2'd3;
    reg [1 : 0] state;
    reg [1 : 0] next_state;
    reg [4 : 0] counter;

    always @(posedge clk) begin
        if(rst) begin
            state <= s1;
            counter <= 5'b0;
        end

        else begin
            state <= next_state;
            if(state == s2) counter <= counter + 1;
        end
    end

    always @(*) begin
        b_mux_sel = 1'b1;
        a_mux_sel = 1'b1;
        r_mux_sel = 1'b0;
        state_done = 1'b0;
        next_state = state;
        add_mux_sel = 1'b0;
        r_en = 1'b0;
        istream_rdy = 1'b0;
        ostream_val = 1'b0;

        case(state)
        s1: begin
                istream_rdy = 1'b1;
                if(istream_val) begin
                    b_mux_sel = 1'b0;
                    a_mux_sel = 1'b0;
                    r_mux_sel = 1'b0;
                    r_en = 1'b1;
                    next_state = s2;
                end
            end

        s2: begin
                b_mux_sel = 1'b1;
                a_mux_sel = 1'b1;
                r_mux_sel = 1'b1;

                if(counter == 5'd31) begin
                    next_state = s3;
                end

                if(b_lsb) begin
                    add_mux_sel = 1'b1;
                    r_en = 1'b1;
                end

            end

        s3: begin

                state_done = 1'b1; 
                ostream_val = 1'b1;
                if(ostream_rdy) begin
                    next_state = s1;
                end
            end
        endcase
    end

endmodule