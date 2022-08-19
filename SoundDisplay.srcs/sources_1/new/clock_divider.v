`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.10.2020 10:39:02
// Design Name: 
// Module Name: clock_divider
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


module clock_divider(
    input CLK, [31:0]m,
    output reg desired_CLK = 0
    );
    
    reg [31:0]counter = 0;
    
    always @ (posedge CLK) begin
        counter <= (counter == m) ? 0 : counter + 1;
        desired_CLK <= (counter == 0) ? ~desired_CLK : desired_CLK;
    end
endmodule
