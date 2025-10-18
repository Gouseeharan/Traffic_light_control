`timescale 1ns / 1ps
module traffic_controller (
    input clk,
    input reset,
    input [3:0] emergency,   // 1=emergency active for that road
    output reg [2:0] road1,
    output reg [2:0] road2,
    output reg [2:0] road3,
    output reg [2:0] road4
);
    // Light encoding
    // 001 = GREEN, 010 = YELLOW, 100 = RED

    reg [2:0] state;
    integer timer;

    // FSM States
    parameter S_R1_GREEN  = 3'd0;
    parameter S_R1_YELLOW = 3'd1;
    parameter S_R2_GREEN  = 3'd2;
    parameter S_R2_YELLOW = 3'd3;
    parameter S_R3_GREEN  = 3'd4;
    parameter S_R3_YELLOW = 3'd5;
    parameter S_R4_GREEN  = 3'd6;
    parameter S_R4_YELLOW = 3'd7;

    // Timing
    parameter GREEN_TIME = 5;
    parameter YELLOW_TIME = 2;

    // Sequential: FSM + Timer
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= S_R1_GREEN;
            timer <= GREEN_TIME;
        end 
        else if (|emergency) begin
            // freeze normal cycle during emergency
            state <= state;
            timer <= timer;
        end 
        else begin
            if (timer == 0) begin
                case (state)
                    S_R1_GREEN:  state <= S_R1_YELLOW;
                    S_R1_YELLOW: state <= S_R2_GREEN;
                    S_R2_GREEN:  state <= S_R2_YELLOW;
                    S_R2_YELLOW: state <= S_R3_GREEN;
                    S_R3_GREEN:  state <= S_R3_YELLOW;
                    S_R3_YELLOW: state <= S_R4_GREEN;
                    S_R4_GREEN:  state <= S_R4_YELLOW;
                    S_R4_YELLOW: state <= S_R1_GREEN;
                    default:     state <= S_R1_GREEN;
                endcase

                case (state)
                    S_R1_GREEN, S_R2_GREEN, S_R3_GREEN, S_R4_GREEN: timer <= GREEN_TIME;
                    S_R1_YELLOW, S_R2_YELLOW, S_R3_YELLOW, S_R4_YELLOW: timer <= YELLOW_TIME;
                    default: timer <= GREEN_TIME;
                endcase
            end else begin
                timer <= timer - 1;
            end
        end
    end

    // Output Logic
    always @(*) begin
        // Default all RED
        road1 = 3'b100;
        road2 = 3'b100;
        road3 = 3'b100;
        road4 = 3'b100;

        // Emergency active
        if (|emergency) begin
            if (emergency[0]) road1 = 3'b001;
            if (emergency[1]) road2 = 3'b001;
            if (emergency[2]) road3 = 3'b001;
            if (emergency[3]) road4 = 3'b001;
        end
        else begin
            case (state)
                S_R1_GREEN:  road1 = 3'b001;
                S_R1_YELLOW: road1 = 3'b010;
                S_R2_GREEN:  road2 = 3'b001;
                S_R2_YELLOW: road2 = 3'b010;
                S_R3_GREEN:  road3 = 3'b001;
                S_R3_YELLOW: road3 = 3'b010;
                S_R4_GREEN:  road4 = 3'b001;
                S_R4_YELLOW: road4 = 3'b010;
            endcase
        end
    end
endmodule
