`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.10.2020 09:49:06
// Design Name: 
// Module Name: sample_clock_divider
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sample_clock_divider(
    input CLK,
    output reg desired_CLK = 0
    );
    
    reg [11:0] counter = 0;
    
    always @ (posedge CLK) begin
        counter <= (counter == 2499) ? 0 : counter + 1;
        desired_CLK <= (counter == 0) ? ~desired_CLK : desired_CLK;
    end
    
endmodule
