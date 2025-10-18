`timescale 1ns / 1ps
module tb_traffic_controller;
    reg clk, reset;
    reg [3:0] emergency;  // {road4, road3, road2, road1}
    wire [2:0] road1, road2, road3, road4;

    // Instantiate DUT
    traffic_controller uut (
        .clk(clk),
        .reset(reset),
        .emergency(emergency),
        .road1(road1),
        .road2(road2),
        .road3(road3),
        .road4(road4)
    );

    // Clock
    always #5 clk = ~clk; // 10 ns period

    initial begin
        clk = 0;
        reset = 1;
        emergency = 4'b0000;
        #10 reset = 0;

        $display("Time\tE4E3E2E1\tRoad1\tRoad2\tRoad3\tRoad4");
        $monitor("%0t\t%b%b%b%b\t%b\t%b\t%b\t%b",
                 $time, emergency[3], emergency[2], emergency[1], emergency[0],
                 road1, road2, road3, road4);

        // Normal operation
        #80;

        // Single emergencies
        emergency = 4'b0001; // Road1 emergency
        #40;
        emergency = 4'b0010; // Road2 emergency
        #40;

        // Multiple emergencies
        emergency = 4'b0110; // Road2 + Road3 emergency
        #40;
        emergency = 4'b1111; // All emergencies active
        #40;

        // Clear emergency
        emergency = 4'b0000;
        #100;

        $finish;
    end
endmodule
