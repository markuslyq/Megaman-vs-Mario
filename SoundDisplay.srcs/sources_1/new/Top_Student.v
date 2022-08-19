`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//
//  LAB SESSION DAY (Delete where applicable):  WEDNESDAY A.M
//
//  STUDENT A NAME: Markus Lim Yi Qin
//  STUDENT A MATRICULATION NUMBER: A0221167M
//
//  STUDENT B NAME: Mohamad Adam Bin Mohamad Yazid
//  STUDENT B MATRICULATION NUMBER: A0218240R
//
//////////////////////////////////////////////////////////////////////////////////


module Top_Student (
    input  J_MIC3_Pin3, // Connect from this signal to Audio_Capture.v
    input  JB_MIC3_Pin3, 
    input  CLK100MHZ, btnC,
    input  [15:0] sw,
    output J_MIC3_Pin1,   // Connect to this signal from Audio_Capture.v
    output JB_MIC3_Pin1,
    output J_MIC3_Pin4,   // Connect to this signal from Audio_Capture.v
    output JB_MIC3_Pin4,
    output reg [15:0] led = 0,
    output [7:0] JC,
    output reg [3:0] AN = 0,
    output reg [7:0] seg = 0
    );
    
    wire sample_CLK, clk6p25m, debounce_clk, CentreButton, RightButton, f_begin, sending_p, sample_p, clock_762hz, clock_10hz; 
    wire [11:0] mic_in;
    wire [11:0] mic_in2;
    reg [15:0] oled_data;
    reg [11:0] max;
    reg [11:0] max2;
    reg [11:0] counter; 
    wire [12:0] pixel_index;
    wire [5:0] y;
    wire [6:0] x;
    wire [1:0] display_border;
    wire [1:0] display_scheme;
    wire [1:0] display_mode;
    reg [4:0] led_count;
    reg [4:0] led_count2;
    reg seg_refresher = 0;
    reg [15:0] outer_laser_colour;
    reg [15:0] mid_laser_colour;
    reg [15:0] inner_laser_colour;
    reg [6:0] laser_end;
    reg [1:0] laser_colour = 0;
    reg [18:0] virus_clock = 0;
    reg [6:0] virus_counter = 0;
    reg [6:0] burst_counter = 0;
    reg dead = 0;
    reg gameStart = 0;
    reg finalGameStart = 0;
    reg [23:0] gameover_counter = 0;
    reg [3:0] virus_death_counter = 0;
    reg [22:0] winCounter = 0;
    reg [18:0] mario_health_clock = 0;
    reg [6:0] mario_health_counter = 0;
    reg [18:0] megaman_health_clock = 0;
    reg [6:0] megaman_health_counter = 0;
    reg marioWin = 0;
    reg megamanWin = 0;

    //animation clocks
    reg [26:0] animation_count;
    reg slow_animation;
    reg med_animation;
    reg fast_animation;
    wire [15:0] animation_data;
    reg [2:0] frame_count;
    wire animation_CLK; 
    
    sample_clock_divider sample_clock (CLK100MHZ, sample_CLK);
    oled_clock_divider oled_clock(CLK100MHZ, clk6p25m);
    debouncing_clock_divider CLK50KHZ(CLK100MHZ, debounce_clk);
    clock_divider CLK762HZ (CLK100MHZ, 65616, clock_762hz);
    clock_divider CLK10HZ (CLK100MHZ, 4999999, clock_10hz);
    
    
    
    Audio_Capture(CLK100MHZ, sample_CLK, J_MIC3_Pin3, J_MIC3_Pin1, J_MIC3_Pin4, mic_in);
    
    //audio capture for second mic
    Audio_Capture(CLK100MHZ, sample_CLK, JB_MIC3_Pin3, JB_MIC3_Pin1, JB_MIC3_Pin4, mic_in2);
    
    single_pulse_output CENTRE(btnC, debounce_clk, CentreButton);
    //single_pulse_output RIGHT(btnR, debounce_clk, RightButton);
    Oled_Display display(.clk(clk6p25m), .reset(CentreButton), .frame_begin(f_begin), .sending_pixels(sending_p),
      .sample_pixel(sample_p), .pixel_index(pixel_index), .pixel_data(oled_data), .cs(JC[0]), .sdin(JC[1]), .sclk(JC[3]), .d_cn(JC[4]), .resn(JC[5]), .vccen(JC[6]),
      .pmoden(JC[7]));
      
    //SW2 => 1 pixel border, 
    //SW3 => 3 pixel border,
    //default => no border 
    assign display_border = sw[2] ? 2'b01 : sw[3] ? 2'b10 : 2'b00;
    //SW4 => Scheme 1
    //SW5 => Scheme 2
    //default => default scheme
    assign display_scheme = sw[4] ? 2'b01 : sw[5] ? 2'b10 : 2'b00;
    //SW1 => volume bar appears
    //default => no volume bar
    //SW11 => Mario
    assign display_mode = sw[1] ? 2'b01: sw[11] ? 2'b10: 2'b00;
    //display vol_display(clock_10hz, display_border, display_scheme, display_mode, p_index, volume, oled_data)
    assign x = pixel_index%96;
    assign y = pixel_index/96;
    

    always @ (posedge sample_CLK) begin
        //freeze
        if(sw[15] == 0)
            counter <= counter + 1;
        if ( max < mic_in && counter != 4000 && sw[0] == 1)
        begin
            max <= mic_in;
           
        end
        if ( max2 < mic_in2 && counter != 4000 && sw[0] == 1)
        begin
            max2 <= mic_in2;
           
        end
        if (counter == 2000)
        begin
            //without peak algorithm
            if (sw[0] == 0)
            begin
                max <= mic_in;
                max2 <= mic_in2;
            end
            //separating the 12 bit max into 16 different variable
            if (max < 2176)
            begin 
                led_count <= 4'b0;
                led <= 16'd0;
            end
            else if ( max >= 2176 && max < 2296)
            begin
                led_count <= 5'd1;
                led <= 16'b0000000000000001;
            end
            else if ( max >= 2296 && max < 2416)
            begin
                led_count <= 5'd2;
                led <= 16'b0000000000000011;
            end
            else if ( max >= 2416 && max < 2536)
            begin
                led_count <= 5'd3;
                led <= 16'b0000000000000111;
            end
            else if ( max >= 2536 && max < 2656)
            begin
                led_count <= 5'd4;
                led <= 16'b0000000000001111;
            end                        
            else if ( max >= 2656 && max < 2776)
            begin
                led_count <= 5'd5;
                led <= 16'b0000000000011111;
            end
            else if ( max >= 2776 && max < 2896)
            begin
                led_count <= 5'd6;
                led <= 16'b0000000000111111;
            end
            else if ( max >= 2896 && max < 3016)
            begin
                led_count <= 5'd7;
                led <= 16'b0000000001111111;
            end
            else if ( max >= 3016 && max < 3136)
            begin
                led_count <= 5'd8;
                led <= 16'b0000000011111111;
            end                    
            else if ( max >= 3136 && max < 3256)
            begin
                led_count <= 5'd9;
                led <= 16'b0000000111111111;
            end
            else if ( max >= 3256 && max < 3376)
            begin
                led_count <= 5'd10;
                led <= 16'b0000001111111111;
            end
            else if ( max >= 3376 && max < 3496)
            begin
                led_count <= 5'd11;
                led <= 16'b0000011111111111;
            end
            else if ( max >= 3496 && max < 3616)
            begin
                led_count <= 5'd12;
                led <= 16'b0000111111111111;
            end                                
            else if ( max >= 3616 && max < 3736)
            begin
                led_count <= 5'd13;
                led <= 16'b0001111111111111;
            end
            else if ( max >= 3736 && max < 3856)
            begin
                led_count <= 5'd14;
                led <= 16'b0011111111111111;
            end
            else if ( max >= 3856 && max < 3976)
            begin
                led_count <= 5'd15;
                led <= 16'b0111111111111111;
            end
            else if ( max >= 3976 && max < 4096)
            begin
                led_count <= 5'd16;
                led <= 16'b1111111111111111;
            end
            //max2
            if (max2 < 2176)
            begin 
                led_count2 <= 4'b0;
            end
            else if ( max2 >= 2176 && max2 < 2296)
            begin
                led_count2 <= 5'd1;
            end
            else if ( max2 >= 2296 && max2 < 2416)
            begin
                led_count2 <= 5'd2;
            end
            else if ( max2 >= 2416 && max2 < 2536)
            begin
                led_count2 <= 5'd3;
            end
            else if ( max2 >= 2536 && max2 < 2656)
            begin
                led_count2 <= 5'd4;
            end                        
            else if ( max2 >= 2656 && max2 < 2776)
            begin
                led_count2 <= 5'd5;
            end
            else if ( max2 >= 2776 && max2 < 2896)
            begin
                led_count2 <= 5'd6;
            end
            else if ( max2 >= 2896 && max2 < 3016)
            begin
                led_count2 <= 5'd7;
            end
            else if ( max2 >= 3016 && max2 < 3136)
            begin
                led_count2 <= 5'd8;
            end                    
            else if ( max2 >= 3136 && max2 < 3256)
            begin
                led_count2 <= 5'd9;
            end
            else if ( max2 >= 3256 && max2 < 3376)
            begin
                led_count2 <= 5'd10;
            end
            else if ( max2 >= 3376 && max2 < 3496)
            begin
                led_count2 <= 5'd11;
            end
            else if ( max2 >= 3496 && max2 < 3616)
            begin
                led_count2 <= 5'd12;
            end                                
            else if ( max2 >= 3616 && max2 < 3736)
            begin
                led_count2 <= 5'd13;
            end
            else if ( max2 >= 3736 && max2 < 3856)
            begin
                led_count2 <= 5'd14;
            end
            else if ( max2 >= 3856 && max2 < 3976)
            begin
                led_count2 <= 5'd15;
            end
            else if ( max2 >= 3976 && max2 < 4096)
            begin
                led_count2 <= 5'd16;
            end

            if (sw[0] == 1)
            begin
                max2 <= 0;                                                                       
                max <= 0;
            end
            counter <= 0;
        end
    end
    
    //7-segment display
    always @ (posedge clock_762hz) begin
        seg_refresher <= seg_refresher + 1;
        case (seg_refresher)
            0: 
            begin
                AN <= 4'b1110;
                case(led_count%10)
                    4'd0: seg <= 8'b11000000;
                    4'd1: seg <= 8'b11111001;
                    4'd2: seg <= 8'b10100100;
                    4'd3: seg <= 8'b10110000;
                    4'd4: seg <= 8'b10011001;
                    4'd5: seg <= 8'b10010010;
                    4'd6: seg <= 8'b10000010;
                    4'd7: seg <= 8'b11111000;
                    4'd8: seg <= 8'b10000000;
                    4'd9: seg <= 8'b10010000;
                endcase
            end
            1:
            begin
                if(led_count/10 != 0)
                begin
                    AN <= 4'b1101;
                    seg <= 8'b11111001;
                end
                else
                    AN <= 4'b1111;
            end   
        endcase
    end
  
    always @ (posedge CLK100MHZ) begin
        animation_count <= animation_count + 1;
        slow_animation = animation_count[25];
        med_animation = animation_count[23];
        fast_animation = animation_count[21];
    end

    assign animation_CLK = (led_count > 10) ? fast_animation : (led_count > 5) ? med_animation : (led_count > 0) ? slow_animation: 0;
   
    always @ (posedge animation_CLK) begin
        frame_count <= frame_count == 6 ? 2'd0 : frame_count + 1;
    end

    always @ (posedge clk6p25m)
    begin
    //Menu
    if(sw[12] == 0 && sw[11] == 0 && sw[10] == 1)
    begin
    if ( y == 12 && x == 42 ) begin oled_data <= 16'h0841; end
    if ( y == 12 && x == 43 ) begin oled_data <= 16'h8430; end
    if ( y == 12 && x == 44 ) begin oled_data <= 16'hB596; end
    if ( y == 12 && x == 45 ) begin oled_data <= 16'h4228; end
    if ( y == 12 && x == 47 ) begin oled_data <= 16'h39E7; end
    if ( y == 12 && x == 48 ) begin oled_data <= 16'hAD55; end
    if ( y == 12 && x == 49 ) begin oled_data <= 16'hB596; end
    if ( y == 12 && x == 50 ) begin oled_data <= 16'h528A; end
    if ( y == 12 && x == 53 ) begin oled_data <= 16'h18C3; end
    if ( y == 12 && x == 54 ) begin oled_data <= 16'hAD55; end
    if ( y == 12 && x == 55 ) begin oled_data <= 16'hBDD7; end
    if ( y == 12 && x == 56 ) begin oled_data <= 16'hBDF7; end
    if ( y == 12 && x == 57 ) begin oled_data <= 16'hB5B6; end
    if ( y == 12 && x == 58 ) begin oled_data <= 16'hBDF7; end
    if ( y == 12 && x == 59 ) begin oled_data <= 16'hA534; end
    if ( y == 12 && x == 60 ) begin oled_data <= 16'h3186; end
    if ( y == 12 && x == 61 ) begin oled_data <= 16'h0841; end
    if ( y == 12 && x == 62 ) begin oled_data <= 16'h94B2; end
    if ( y == 12 && x == 63 ) begin oled_data <= 16'hBDF7; end
    if ( y == 12 && x >= 64 && x <= 65 ) begin oled_data <= 16'hBDD7; end
    if ( y == 12 && x == 66 ) begin oled_data <= 16'hB5B6; end
    if ( y == 12 && x == 67 ) begin oled_data <= 16'hBDD7; end
    if ( y == 12 && x == 68 ) begin oled_data <= 16'h630C; end
    if ( y == 12 && x == 70 ) begin oled_data <= 16'h0841; end
    if ( y == 12 && x == 71 ) begin oled_data <= 16'h4228; end
    if ( y == 12 && x == 72 ) begin oled_data <= 16'h9492; end
    if ( y == 12 && x == 73 ) begin oled_data <= 16'hB596; end
    if ( y == 12 && x == 74 ) begin oled_data <= 16'hBDF7; end
    if ( y == 12 && x == 75 ) begin oled_data <= 16'h8C71; end
    if ( y == 12 && x == 76 ) begin oled_data <= 16'h39C7; end
    if ( y == 12 && x == 78 ) begin oled_data <= 16'h0861; end
    if ( y == 12 && x == 79 ) begin oled_data <= 16'h39E7; end
    if ( y == 12 && x == 80 ) begin oled_data <= 16'h9CD3; end
    if ( y == 12 && x == 81 ) begin oled_data <= 16'hBDD7; end
    if ( y == 12 && x == 82 ) begin oled_data <= 16'hB596; end
    if ( y == 12 && x == 83 ) begin oled_data <= 16'h9492; end
    if ( y == 12 && x == 84 ) begin oled_data <= 16'h4A49; end
    if ( y == 12 && x == 85 ) begin oled_data <= 16'h0861; end
    if ( y == 13 && x == 10 ) begin oled_data <= 16'h5ACB; end
    if ( y == 13 && x == 11 ) begin oled_data <= 16'hCE79; end
    if ( y == 13 && x == 12 ) begin oled_data <= 16'hD69A; end
    if ( y == 13 && x == 13 ) begin oled_data <= 16'hAD55; end
    if ( y == 13 && x == 14 ) begin oled_data <= 16'hA514; end
    if ( y == 13 && x == 15 ) begin oled_data <= 16'hBDD7; end
    if ( y == 13 && x == 16 ) begin oled_data <= 16'hDEDB; end
    if ( y == 13 && x == 17 ) begin oled_data <= 16'h8C51; end
    if ( y == 13 && x == 18 ) begin oled_data <= 16'h2945; end
    if ( y == 13 && x == 19 ) begin oled_data <= 16'hD69A; end
    if ( y == 13 && x == 20 ) begin oled_data <= 16'hDEDB; end
    if ( y == 13 && x >= 21 && x <= 22 ) begin oled_data <= 16'h9CF3; end
    if ( y == 13 && x == 23 ) begin oled_data <= 16'h9CD3; end
    if ( y == 13 && x == 24 ) begin oled_data <= 16'hE73C; end
    if ( y == 13 && x == 25 ) begin oled_data <= 16'hCE59; end
    if ( y == 13 && x == 26 ) begin oled_data <= 16'h2104; end
    if ( y == 13 && x == 29 ) begin oled_data <= 16'hB596; end
    if ( y == 13 && x == 30 ) begin oled_data <= 16'hEF7D; end
    if ( y == 13 && x == 31 ) begin oled_data <= 16'hD6BA; end
    if ( y == 13 && x == 32 ) begin oled_data <= 16'h18C3; end
    if ( y == 13 && x == 35 ) begin oled_data <= 16'h9492; end
    if ( y == 13 && x == 36 ) begin oled_data <= 16'hE71C; end
    if ( y == 13 && x == 37 ) begin oled_data <= 16'hBDF7; end
    if ( y == 13 && x == 38 ) begin oled_data <= 16'hA534; end
    if ( y == 13 && x == 39 ) begin oled_data <= 16'hA514; end
    if ( y == 13 && x >= 40 && x <= 41 ) begin oled_data <= 16'hCE59; end
    if ( y == 13 && x == 42 ) begin oled_data <= 16'h31A6; end
    if ( y == 13 && x == 43 ) begin oled_data <= 16'h94B2; end
    if ( y == 13 && x == 44 ) begin oled_data <= 16'hEF5D; end
    if ( y == 13 && x == 45 ) begin oled_data <= 16'h528A; end
    if ( y == 13 && x == 46 ) begin oled_data <= 16'h31A6; end
    if ( y == 13 && x == 47 ) begin oled_data <= 16'hA534; end
    if ( y == 13 && x == 48 ) begin oled_data <= 16'hE71C; end
    if ( y == 13 && x == 49 ) begin oled_data <= 16'h9492; end
    if ( y == 13 && x == 50 ) begin oled_data <= 16'h2124; end
    if ( y == 13 && x == 52 ) begin oled_data <= 16'h0841; end
    if ( y == 13 && x == 53 ) begin oled_data <= 16'h18E3; end
    if ( y == 13 && x == 54 ) begin oled_data <= 16'hD6BA; end
    if ( y == 13 && x == 55 ) begin oled_data <= 16'hD69A; end
    if ( y == 13 && x == 56 ) begin oled_data <= 16'h7BCF; end
    if ( y == 13 && x == 57 ) begin oled_data <= 16'h7BEF; end
    if ( y == 13 && x == 58 ) begin oled_data <= 16'h8430; end
    if ( y == 13 && x == 59 ) begin oled_data <= 16'hE73C; end
    if ( y == 13 && x == 60 ) begin oled_data <= 16'hBDF7; end
    if ( y == 13 && x == 61 ) begin oled_data <= 16'h18C3; end
    if ( y == 13 && x == 62 ) begin oled_data <= 16'h9CF3; end
    if ( y == 13 && x == 63 ) begin oled_data <= 16'hE71C; end
    if ( y == 13 && x == 64 ) begin oled_data <= 16'h8C51; end
    if ( y == 13 && x == 65 ) begin oled_data <= 16'h7BCF; end
    if ( y == 13 && x == 66 ) begin oled_data <= 16'h7BEF; end
    if ( y == 13 && x == 67 ) begin oled_data <= 16'hC638; end
    if ( y == 13 && x == 68 ) begin oled_data <= 16'hE71C; end
    if ( y == 13 && x == 69 ) begin oled_data <= 16'h39E7; end
    if ( y == 13 && x == 70 ) begin oled_data <= 16'h52AA; end
    if ( y == 13 && x == 71 ) begin oled_data <= 16'hCE79; end
    if ( y == 13 && x == 72 ) begin oled_data <= 16'hD6BA; end
    if ( y == 13 && x >= 73 && x <= 74 ) begin oled_data <= 16'hA514; end
    if ( y == 13 && x == 75 ) begin oled_data <= 16'hDEDB; end
    if ( y == 13 && x == 76 ) begin oled_data <= 16'hE71C; end
    if ( y == 13 && x == 77 ) begin oled_data <= 16'h52AA; end
    if ( y == 13 && x == 78 ) begin oled_data <= 16'h18E3; end
    if ( y == 13 && x == 79 ) begin oled_data <= 16'hBDF7; end
    if ( y == 13 && x == 80 ) begin oled_data <= 16'hCE59; end
    if ( y == 13 && x == 81 ) begin oled_data <= 16'h8410; end
    if ( y == 13 && x == 82 ) begin oled_data <= 16'h8C51; end
    if ( y == 13 && x == 83 ) begin oled_data <= 16'hC618; end
    if ( y == 13 && x == 84 ) begin oled_data <= 16'hCE79; end
    if ( y == 13 && x == 85 ) begin oled_data <= 16'h4228; end
    if ( y == 13 && x == 86 ) begin oled_data <= 16'h0841; end
    if ( y == 14 && x == 9 ) begin oled_data <= 16'h0861; end
    if ( y == 14 && x == 10 ) begin oled_data <= 16'hAD75; end
    if ( y == 14 && x == 11 ) begin oled_data <= 16'hDEDB; end
    if ( y == 14 && x == 12 ) begin oled_data <= 16'h630C; end
    if ( y == 14 && x == 15 ) begin oled_data <= 16'h0861; end
    if ( y == 14 && x >= 16 && x <= 17 ) begin oled_data <= 16'h6B4D; end
    if ( y == 14 && x == 18 ) begin oled_data <= 16'h18C3; end
    if ( y == 14 && x == 19 ) begin oled_data <= 16'hD6BA; end
    if ( y == 14 && x == 20 ) begin oled_data <= 16'hAD75; end
    if ( y == 14 && x == 21 ) begin oled_data <= 16'h0861; end
    if ( y == 14 && x == 24 ) begin oled_data <= 16'hAD55; end
    if ( y == 14 && x == 25 ) begin oled_data <= 16'hDEDB; end
    if ( y == 14 && x == 26 ) begin oled_data <= 16'h31A6; end
    if ( y == 14 && x == 28 ) begin oled_data <= 16'h4A49; end
    if ( y == 14 && x == 29 ) begin oled_data <= 16'hDEFB; end
    if ( y == 14 && x == 30 ) begin oled_data <= 16'hC618; end
    if ( y == 14 && x == 31 ) begin oled_data <= 16'hEF7D; end
    if ( y == 14 && x == 32 ) begin oled_data <= 16'h738E; end
    if ( y == 14 && x == 33 ) begin oled_data <= 16'h0841; end
    if ( y == 14 && x == 34 ) begin oled_data <= 16'h4228; end
    if ( y == 14 && x == 35 ) begin oled_data <= 16'hE71C; end
    if ( y == 14 && x == 36 ) begin oled_data <= 16'hB5B6; end
    if ( y == 14 && x == 37 ) begin oled_data <= 16'h2124; end
    if ( y == 14 && x == 40 ) begin oled_data <= 16'h2124; end
    if ( y == 14 && x == 41 ) begin oled_data <= 16'h8430; end
    if ( y == 14 && x == 42 ) begin oled_data <= 16'h2965; end
    if ( y == 14 && x == 43 ) begin oled_data <= 16'h9492; end
    if ( y == 14 && x == 44 ) begin oled_data <= 16'hEF7D; end
    if ( y == 14 && x == 45 ) begin oled_data <= 16'h8C71; end
    if ( y == 14 && x == 46 ) begin oled_data <= 16'hBDD7; end
    if ( y == 14 && x == 47 ) begin oled_data <= 16'hDEDB; end
    if ( y == 14 && x == 48 ) begin oled_data <= 16'h6B6D; end
    if ( y == 14 && x == 49 ) begin oled_data <= 16'h18C3; end
    if ( y == 14 && x == 53 ) begin oled_data <= 16'h2124; end
    if ( y == 14 && x == 54 ) begin oled_data <= 16'hD69A; end
    if ( y == 14 && x == 55 ) begin oled_data <= 16'hC618; end
    if ( y == 14 && x == 56 ) begin oled_data <= 16'h18C3; end
    if ( y == 14 && x == 57 ) begin oled_data <= 16'h0861; end
    if ( y == 14 && x == 58 ) begin oled_data <= 16'h2104; end
    if ( y == 14 && x == 59 ) begin oled_data <= 16'hC638; end
    if ( y == 14 && x == 60 ) begin oled_data <= 16'hCE59; end
    if ( y == 14 && x == 61 ) begin oled_data <= 16'h18C3; end
    if ( y == 14 && x == 62 ) begin oled_data <= 16'h94B2; end
    if ( y == 14 && x == 63 ) begin oled_data <= 16'hE73C; end
    if ( y == 14 && x == 64 ) begin oled_data <= 16'h18E3; end
    if ( y == 14 && x == 67 ) begin oled_data <= 16'h5AEB; end
    if ( y == 14 && x == 68 ) begin oled_data <= 16'hF79E; end
    if ( y == 14 && x == 69 ) begin oled_data <= 16'h7BEF; end
    if ( y == 14 && x == 70 ) begin oled_data <= 16'hB596; end
    if ( y == 14 && x == 71 ) begin oled_data <= 16'hDEDB; end
    if ( y == 14 && x == 72 ) begin oled_data <= 16'h4A69; end
    if ( y == 14 && x == 75 ) begin oled_data <= 16'h39E7; end
    if ( y == 14 && x == 76 ) begin oled_data <= 16'hDEFB; end
    if ( y == 14 && x == 77 ) begin oled_data <= 16'hC618; end
    if ( y == 14 && x == 78 ) begin oled_data <= 16'h4A49; end
    if ( y == 14 && x == 79 ) begin oled_data <= 16'hE71C; end
    if ( y == 14 && x == 80 ) begin oled_data <= 16'hAD75; end
    if ( y == 14 && x == 81 ) begin oled_data <= 16'h31A6; end
    if ( y == 14 && x >= 82 && x <= 83 ) begin oled_data <= 16'h2104; end
    if ( y == 14 && x == 84 ) begin oled_data <= 16'h52AA; end
    if ( y == 15 && x == 9 ) begin oled_data <= 16'h18C3; end
    if ( y == 15 && x == 10 ) begin oled_data <= 16'hD6BA; end
    if ( y == 15 && x == 11 ) begin oled_data <= 16'hC618; end
    if ( y == 15 && x == 16 ) begin oled_data <= 16'h0841; end
    if ( y == 15 && x == 18 ) begin oled_data <= 16'h18C3; end
    if ( y == 15 && x == 19 ) begin oled_data <= 16'hD69A; end
    if ( y == 15 && x == 20 ) begin oled_data <= 16'hEF7D; end
    if ( y == 15 && x == 21 ) begin oled_data <= 16'hAD75; end
    if ( y == 15 && x == 22 ) begin oled_data <= 16'hB596; end
    if ( y == 15 && x == 23 ) begin oled_data <= 16'hB5B6; end
    if ( y == 15 && x == 24 ) begin oled_data <= 16'hDEFB; end
    if ( y == 15 && x == 25 ) begin oled_data <= 16'hC618; end
    if ( y == 15 && x == 26 ) begin oled_data <= 16'h2104; end
    if ( y == 15 && x == 27 ) begin oled_data <= 16'h0861; end
    if ( y == 15 && x == 28 ) begin oled_data <= 16'hA534; end
    if ( y == 15 && x == 29 ) begin oled_data <= 16'hCE59; end
    if ( y == 15 && x == 30 ) begin oled_data <= 16'h39C7; end
    if ( y == 15 && x == 31 ) begin oled_data <= 16'hCE79; end
    if ( y == 15 && x == 32 ) begin oled_data <= 16'hCE59; end
    if ( y == 15 && x == 34 ) begin oled_data <= 16'h738E; end
    if ( y == 15 && x == 35 ) begin oled_data <= 16'hF79E; end
    if ( y == 15 && x == 36 ) begin oled_data <= 16'h73AE; end
    if ( y == 15 && x == 41 ) begin oled_data <= 16'h0841; end
    if ( y == 15 && x == 43 ) begin oled_data <= 16'h9492; end
    if ( y == 15 && x == 44 ) begin oled_data <= 16'hFFFF; end
    if ( y == 15 && x == 45 ) begin oled_data <= 16'hE71C; end
    if ( y == 15 && x == 46 ) begin oled_data <= 16'hFFFF; end
    if ( y == 15 && x == 47 ) begin oled_data <= 16'hAD75; end
    if ( y == 15 && x == 48 ) begin oled_data <= 16'h18C3; end
    if ( y == 15 && x == 53 ) begin oled_data <= 16'h2104; end
    if ( y == 15 && x == 54 ) begin oled_data <= 16'hDEDB; end
    if ( y == 15 && x == 55 ) begin oled_data <= 16'hEF7D; end
    if ( y == 15 && x == 56 ) begin oled_data <= 16'hBDF7; end
    if ( y == 15 && x == 57 ) begin oled_data <= 16'hCE59; end
    if ( y == 15 && x == 58 ) begin oled_data <= 16'hC638; end
    if ( y == 15 && x == 59 ) begin oled_data <= 16'hEF7D; end
    if ( y == 15 && x == 60 ) begin oled_data <= 16'h8430; end
    if ( y == 15 && x == 61 ) begin oled_data <= 16'h0861; end
    if ( y == 15 && x == 62 ) begin oled_data <= 16'h9CD3; end
    if ( y == 15 && x == 63 ) begin oled_data <= 16'hF79E; end
    if ( y == 15 && x == 64 ) begin oled_data <= 16'hAD55; end
    if ( y == 15 && x == 65 ) begin oled_data <= 16'h94B2; end
    if ( y == 15 && x == 66 ) begin oled_data <= 16'h9CD3; end
    if ( y == 15 && x == 67 ) begin oled_data <= 16'hCE79; end
    if ( y == 15 && x == 68 ) begin oled_data <= 16'hD69A; end
    if ( y == 15 && x == 69 ) begin oled_data <= 16'h738E; end
    if ( y == 15 && x == 70 ) begin oled_data <= 16'hD6BA; end
    if ( y == 15 && x == 71 ) begin oled_data <= 16'hC638; end
    if ( y == 15 && x == 76 ) begin oled_data <= 16'hAD75; end
    if ( y == 15 && x == 77 ) begin oled_data <= 16'hE73C; end
    if ( y == 15 && x == 78 ) begin oled_data <= 16'h4228; end
    if ( y == 15 && x == 79 ) begin oled_data <= 16'h8410; end
    if ( y == 15 && x == 80 ) begin oled_data <= 16'hDEFB; end
    if ( y == 15 && x == 81 ) begin oled_data <= 16'hD6BA; end
    if ( y == 15 && x == 82 ) begin oled_data <= 16'hD69A; end
    if ( y == 15 && x == 83 ) begin oled_data <= 16'hBDF7; end
    if ( y == 15 && x == 84 ) begin oled_data <= 16'h7BCF; end
    if ( y == 16 && x == 8 ) begin oled_data <= 16'h0841; end
    if ( y == 16 && x >= 10 && x <= 11 ) begin oled_data <= 16'hCE79; end
    if ( y == 16 && x == 12 ) begin oled_data <= 16'h0861; end
    if ( y == 16 && x == 18 ) begin oled_data <= 16'h18C3; end
    if ( y == 16 && x == 19 ) begin oled_data <= 16'hD69A; end
    if ( y == 16 && x == 20 ) begin oled_data <= 16'hD6BA; end
    if ( y == 16 && x == 21 ) begin oled_data <= 16'hAD55; end
    if ( y == 16 && x == 22 ) begin oled_data <= 16'hCE59; end
    if ( y == 16 && x == 23 ) begin oled_data <= 16'hF7BE; end
    if ( y == 16 && x == 24 ) begin oled_data <= 16'hAD75; end
    if ( y == 16 && x == 25 ) begin oled_data <= 16'h39E7; end
    if ( y == 16 && x == 27 ) begin oled_data <= 16'h4228; end
    if ( y == 16 && x == 28 ) begin oled_data <= 16'hE71C; end
    if ( y == 16 && x == 29 ) begin oled_data <= 16'hD69A; end
    if ( y == 16 && x == 30 ) begin oled_data <= 16'h8410; end
    if ( y == 16 && x == 31 ) begin oled_data <= 16'hAD75; end
    if ( y == 16 && x == 32 ) begin oled_data <= 16'hF79E; end
    if ( y == 16 && x == 33 ) begin oled_data <= 16'h6B6D; end
    if ( y == 16 && x == 34 ) begin oled_data <= 16'h632C; end
    if ( y == 16 && x == 35 ) begin oled_data <= 16'hF79E; end
    if ( y == 16 && x == 36 ) begin oled_data <= 16'h7BEF; end
    if ( y == 16 && x == 43 ) begin oled_data <= 16'h94B2; end
    if ( y == 16 && x == 44 ) begin oled_data <= 16'hF7BE; end
    if ( y == 16 && x >= 45 && x <= 46 ) begin oled_data <= 16'hAD75; end
    if ( y == 16 && x == 47 ) begin oled_data <= 16'hF79E; end
    if ( y == 16 && x == 48 ) begin oled_data <= 16'h7BCF; end
    if ( y == 16 && x == 53 ) begin oled_data <= 16'h2124; end
    if ( y == 16 && x == 54 ) begin oled_data <= 16'hD69A; end
    if ( y == 16 && x == 55 ) begin oled_data <= 16'hD6BA; end
    if ( y == 16 && x == 56 ) begin oled_data <= 16'h6B6D; end
    if ( y == 16 && x == 57 ) begin oled_data <= 16'h73AE; end
    if ( y == 16 && x == 58 ) begin oled_data <= 16'h6B6D; end
    if ( y == 16 && x == 59 ) begin oled_data <= 16'hCE79; end
    if ( y == 16 && x == 60 ) begin oled_data <= 16'hDEDB; end
    if ( y == 16 && x == 61 ) begin oled_data <= 16'h2965; end
    if ( y == 16 && x == 62 ) begin oled_data <= 16'hA514; end
    if ( y == 16 && x == 63 ) begin oled_data <= 16'hE73C; end
    if ( y == 16 && x == 64 ) begin oled_data <= 16'hB5B6; end
    if ( y == 16 && x == 65 ) begin oled_data <= 16'hB596; end
    if ( y == 16 && x == 66 ) begin oled_data <= 16'hF7BE; end
    if ( y == 16 && x == 67 ) begin oled_data <= 16'hD69A; end
    if ( y == 16 && x == 68 ) begin oled_data <= 16'h630C; end
    if ( y == 16 && x == 69 ) begin oled_data <= 16'h3186; end
    if ( y == 16 && x == 70 ) begin oled_data <= 16'hD6BA; end
    if ( y == 16 && x == 71 ) begin oled_data <= 16'hC638; end
    if ( y == 16 && x == 76 ) begin oled_data <= 16'hB5B6; end
    if ( y == 16 && x == 77 ) begin oled_data <= 16'hE71C; end
    if ( y == 16 && x == 78 ) begin oled_data <= 16'h3186; end
    if ( y == 16 && x == 79 ) begin oled_data <= 16'h0861; end
    if ( y == 16 && x == 80 ) begin oled_data <= 16'h2945; end
    if ( y == 16 && x == 81 ) begin oled_data <= 16'h52AA; end
    if ( y == 16 && x == 82 ) begin oled_data <= 16'h6B4D; end
    if ( y == 16 && x == 83 ) begin oled_data <= 16'hAD75; end
    if ( y == 16 && x == 84 ) begin oled_data <= 16'hEF7D; end
    if ( y == 16 && x == 85 ) begin oled_data <= 16'h52AA; end
    if ( y == 17 && x == 10 ) begin oled_data <= 16'h9492; end
    if ( y == 17 && x == 11 ) begin oled_data <= 16'hF7BE; end
    if ( y == 17 && x == 12 ) begin oled_data <= 16'h8C71; end
    if ( y == 17 && x == 13 ) begin oled_data <= 16'h2945; end
    if ( y == 17 && x == 14 ) begin oled_data <= 16'h18C3; end
    if ( y == 17 && x == 15 ) begin oled_data <= 16'h4228; end
    if ( y == 17 && x == 16 ) begin oled_data <= 16'h9CD3; end
    if ( y == 17 && x == 17 ) begin oled_data <= 16'h7BCF; end
    if ( y == 17 && x == 18 ) begin oled_data <= 16'h18E3; end
    if ( y == 17 && x == 19 ) begin oled_data <= 16'hCE79; end
    if ( y == 17 && x == 20 ) begin oled_data <= 16'hBDD7; end
    if ( y == 17 && x == 21 ) begin oled_data <= 16'h0841; end
    if ( y == 17 && x == 22 ) begin oled_data <= 16'h2945; end
    if ( y == 17 && x == 23 ) begin oled_data <= 16'hCE59; end
    if ( y == 17 && x == 24 ) begin oled_data <= 16'hDEDB; end
    if ( y == 17 && x == 25 ) begin oled_data <= 16'h3186; end
    if ( y == 17 && x == 26 ) begin oled_data <= 16'h0861; end
    if ( y == 17 && x == 27 ) begin oled_data <= 16'h94B2; end
    if ( y == 17 && x == 28 ) begin oled_data <= 16'hEF5D; end
    if ( y == 17 && x >= 29 && x <= 30 ) begin oled_data <= 16'hB596; end
    if ( y == 17 && x == 31 ) begin oled_data <= 16'hBDD7; end
    if ( y == 17 && x == 32 ) begin oled_data <= 16'hE73C; end
    if ( y == 17 && x == 33 ) begin oled_data <= 16'hCE59; end
    if ( y == 17 && x == 34 ) begin oled_data <= 16'h4228; end
    if ( y == 17 && x == 35 ) begin oled_data <= 16'hD69A; end
    if ( y == 17 && x == 36 ) begin oled_data <= 16'hDEFB; end
    if ( y == 17 && x == 37 ) begin oled_data <= 16'h5ACB; end
    if ( y == 17 && x == 38 ) begin oled_data <= 16'h18C3; end
    if ( y == 17 && x == 39 ) begin oled_data <= 16'h2965; end
    if ( y == 17 && x == 40 ) begin oled_data <= 16'h630C; end
    if ( y == 17 && x == 41 ) begin oled_data <= 16'hB5B6; end
    if ( y == 17 && x == 42 ) begin oled_data <= 16'h3186; end
    if ( y == 17 && x == 43 ) begin oled_data <= 16'h9492; end
    if ( y == 17 && x == 44 ) begin oled_data <= 16'hEF7D; end
    if ( y == 17 && x == 45 ) begin oled_data <= 16'h4A69; end
    if ( y == 17 && x == 46 ) begin oled_data <= 16'h18E3; end
    if ( y == 17 && x == 47 ) begin oled_data <= 16'hB5B6; end
    if ( y == 17 && x == 48 ) begin oled_data <= 16'hF79E; end
    if ( y == 17 && x == 49 ) begin oled_data <= 16'h632C; end
    if ( y == 17 && x == 53 ) begin oled_data <= 16'h2104; end
    if ( y == 17 && x == 54 ) begin oled_data <= 16'hDEDB; end
    if ( y == 17 && x == 55 ) begin oled_data <= 16'hD69A; end
    if ( y == 17 && x == 56 ) begin oled_data <= 16'h2945; end
    if ( y == 17 && x == 57 ) begin oled_data <= 16'h18C3; end
    if ( y == 17 && x == 58 ) begin oled_data <= 16'h2104; end
    if ( y == 17 && x == 59 ) begin oled_data <= 16'h9CD3; end
    if ( y == 17 && x == 60 ) begin oled_data <= 16'hEF5D; end
    if ( y == 17 && x == 61 ) begin oled_data <= 16'h4228; end
    if ( y == 17 && x == 62 ) begin oled_data <= 16'h9CF3; end
    if ( y == 17 && x == 63 ) begin oled_data <= 16'hDEFB; end
    if ( y == 17 && x == 64 ) begin oled_data <= 16'h2124; end
    if ( y == 17 && x == 66 ) begin oled_data <= 16'h9CF3; end
    if ( y == 17 && x == 67 ) begin oled_data <= 16'hEF5D; end
    if ( y == 17 && x == 68 ) begin oled_data <= 16'h52AA; end
    if ( y == 17 && x == 70 ) begin oled_data <= 16'h94B2; end
    if ( y == 17 && x == 71 ) begin oled_data <= 16'hF79E; end
    if ( y == 17 && x == 72 ) begin oled_data <= 16'h7BEF; end
    if ( y == 17 && x == 73 ) begin oled_data <= 16'h2124; end
    if ( y == 17 && x == 74 ) begin oled_data <= 16'h2104; end
    if ( y == 17 && x == 75 ) begin oled_data <= 16'h8410; end
    if ( y == 17 && x == 76 ) begin oled_data <= 16'hE73C; end
    if ( y == 17 && x == 77 ) begin oled_data <= 16'hA514; end
    if ( y == 17 && x == 78 ) begin oled_data <= 16'h39C7; end
    if ( y == 17 && x == 79 ) begin oled_data <= 16'h9492; end
    if ( y == 17 && x == 80 ) begin oled_data <= 16'h5ACB; end
    if ( y == 17 && x == 81 ) begin oled_data <= 16'h2945; end
    if ( y == 17 && x == 82 ) begin oled_data <= 16'h2104; end
    if ( y == 17 && x == 83 ) begin oled_data <= 16'h9492; end
    if ( y == 17 && x == 84 ) begin oled_data <= 16'hEF7D; end
    if ( y == 17 && x == 85 ) begin oled_data <= 16'h630C; end
    if ( y == 18 && x == 10 ) begin oled_data <= 16'h2104; end
    if ( y == 18 && x == 11 ) begin oled_data <= 16'hA514; end
    if ( y == 18 && x == 12 ) begin oled_data <= 16'hE71C; end
    if ( y == 18 && x == 13 ) begin oled_data <= 16'hD69A; end
    if ( y == 18 && x == 14 ) begin oled_data <= 16'hCE79; end
    if ( y == 18 && x == 15 ) begin oled_data <= 16'hD6BA; end
    if ( y == 18 && x == 16 ) begin oled_data <= 16'hC638; end
    if ( y == 18 && x == 17 ) begin oled_data <= 16'h73AE; end
    if ( y == 18 && x == 18 ) begin oled_data <= 16'h31A6; end
    if ( y == 18 && x == 19 ) begin oled_data <= 16'hDEDB; end
    if ( y == 18 && x == 20 ) begin oled_data <= 16'hBDD7; end
    if ( y == 18 && x == 21 ) begin oled_data <= 16'h0841; end
    if ( y == 18 && x == 23 ) begin oled_data <= 16'h6B4D; end
    if ( y == 18 && x == 24 ) begin oled_data <= 16'hEF5D; end
    if ( y == 18 && x == 25 ) begin oled_data <= 16'hBDD7; end
    if ( y == 18 && x == 26 ) begin oled_data <= 16'h5ACB; end
    if ( y == 18 && x == 27 ) begin oled_data <= 16'hDEDB; end
    if ( y == 18 && x == 28 ) begin oled_data <= 16'h9CD3; end
    if ( y == 18 && x == 31 ) begin oled_data <= 16'h0841; end
    if ( y == 18 && x == 32 ) begin oled_data <= 16'h9CD3; end
    if ( y == 18 && x == 33 ) begin oled_data <= 16'hF7BE; end
    if ( y == 18 && x == 34 ) begin oled_data <= 16'h73AE; end
    if ( y == 18 && x == 35 ) begin oled_data <= 16'h4A49; end
    if ( y == 18 && x == 36 ) begin oled_data <= 16'hD69A; end
    if ( y == 18 && x == 37 ) begin oled_data <= 16'hDEFB; end
    if ( y == 18 && x == 38 ) begin oled_data <= 16'hD6BA; end
    if ( y == 18 && x == 39 ) begin oled_data <= 16'hCE79; end
    if ( y == 18 && x == 40 ) begin oled_data <= 16'hDEDB; end
    if ( y == 18 && x == 41 ) begin oled_data <= 16'hA534; end
    if ( y == 18 && x == 42 ) begin oled_data <= 16'h4228; end
    if ( y == 18 && x == 43 ) begin oled_data <= 16'h9CF3; end
    if ( y == 18 && x == 44 ) begin oled_data <= 16'hEF5D; end
    if ( y == 18 && x == 45 ) begin oled_data <= 16'h52AA; end
    if ( y == 18 && x == 47 ) begin oled_data <= 16'h39C7; end
    if ( y == 18 && x == 48 ) begin oled_data <= 16'hD6BA; end
    if ( y == 18 && x == 49 ) begin oled_data <= 16'hDEFB; end
    if ( y == 18 && x == 50 ) begin oled_data <= 16'h528A; end
    if ( y == 18 && x == 53 ) begin oled_data <= 16'h2965; end
    if ( y == 18 && x == 54 ) begin oled_data <= 16'hD69A; end
    if ( y == 18 && x == 55 ) begin oled_data <= 16'hEF5D; end
    if ( y == 18 && x == 56 ) begin oled_data <= 16'hD6BA; end
    if ( y == 18 && x == 57 ) begin oled_data <= 16'hCE59; end
    if ( y == 18 && x == 58 ) begin oled_data <= 16'hD69A; end
    if ( y == 18 && x == 59 ) begin oled_data <= 16'hDEFB; end
    if ( y == 18 && x == 60 ) begin oled_data <= 16'hC638; end
    if ( y == 18 && x == 61 ) begin oled_data <= 16'h31A6; end
    if ( y == 18 && x == 62 ) begin oled_data <= 16'h9CF3; end
    if ( y == 18 && x == 63 ) begin oled_data <= 16'hE73C; end
    if ( y == 18 && x == 64 ) begin oled_data <= 16'h39C7; end
    if ( y == 18 && x == 66 ) begin oled_data <= 16'h3186; end
    if ( y == 18 && x == 67 ) begin oled_data <= 16'hDEDB; end
    if ( y == 18 && x == 68 ) begin oled_data <= 16'hD69A; end
    if ( y == 18 && x == 69 ) begin oled_data <= 16'h4228; end
    if ( y == 18 && x == 70 ) begin oled_data <= 16'h18C3; end
    if ( y == 18 && x == 71 ) begin oled_data <= 16'hA514; end
    if ( y == 18 && x == 72 ) begin oled_data <= 16'hDEFB; end
    if ( y == 18 && x >= 73 && x <= 74 ) begin oled_data <= 16'hD6BA; end
    if ( y == 18 && x == 75 ) begin oled_data <= 16'hDEDB; end
    if ( y == 18 && x == 76 ) begin oled_data <= 16'hAD55; end
    if ( y == 18 && x == 77 ) begin oled_data <= 16'h39E7; end
    if ( y == 18 && x == 78 ) begin oled_data <= 16'h39C7; end
    if ( y == 18 && x == 79 ) begin oled_data <= 16'hBDD7; end
    if ( y == 18 && x == 80 ) begin oled_data <= 16'hE71C; end
    if ( y == 18 && x == 81 ) begin oled_data <= 16'hD6BA; end
    if ( y == 18 && x == 82 ) begin oled_data <= 16'hCE79; end
    if ( y == 18 && x == 83 ) begin oled_data <= 16'hDEDB; end
    if ( y == 18 && x == 84 ) begin oled_data <= 16'hB596; end
    if ( y == 18 && x == 85 ) begin oled_data <= 16'h2965; end
    if ( y == 19 && x == 11 ) begin oled_data <= 16'h0861; end
    if ( y == 19 && x == 12 ) begin oled_data <= 16'h4A69; end
    if ( y == 19 && x == 13 ) begin oled_data <= 16'h7BCF; end
    if ( y == 19 && x == 14 ) begin oled_data <= 16'h8410; end
    if ( y == 19 && x == 15 ) begin oled_data <= 16'h630C; end
    if ( y == 19 && x == 16 ) begin oled_data <= 16'h2124; end
    if ( y == 19 && x == 18 ) begin oled_data <= 16'h18C3; end
    if ( y == 19 && x == 19 ) begin oled_data <= 16'h6B4D; end
    if ( y == 19 && x == 20 ) begin oled_data <= 16'h73AE; end
    if ( y == 19 && x == 21 ) begin oled_data <= 16'h2945; end
    if ( y == 19 && x == 23 ) begin oled_data <= 16'h18C3; end
    if ( y == 19 && x == 24 ) begin oled_data <= 16'h7BCF; end
    if ( y == 19 && x == 25 ) begin oled_data <= 16'h73AE; end
    if ( y == 19 && x == 26 ) begin oled_data <= 16'h6B6D; end
    if ( y == 19 && x == 27 ) begin oled_data <= 16'h7BEF; end
    if ( y == 19 && x == 28 ) begin oled_data <= 16'h5AEB; end
    if ( y == 19 && x == 30 ) begin oled_data <= 16'h0841; end
    if ( y == 19 && x == 32 ) begin oled_data <= 16'h4208; end
    if ( y == 19 && x == 33 ) begin oled_data <= 16'h7BEF; end
    if ( y == 19 && x == 34 ) begin oled_data <= 16'h6B4D; end
    if ( y == 19 && x == 36 ) begin oled_data <= 16'h2124; end
    if ( y == 19 && x == 37 ) begin oled_data <= 16'h5ACB; end
    if ( y == 19 && x == 38 ) begin oled_data <= 16'h7BEF; end
    if ( y == 19 && x == 39 ) begin oled_data <= 16'h738E; end
    if ( y == 19 && x == 40 ) begin oled_data <= 16'h4A69; end
    if ( y == 19 && x == 41 ) begin oled_data <= 16'h18C3; end
    if ( y == 19 && x == 43 ) begin oled_data <= 16'h4A69; end
    if ( y == 19 && x == 44 ) begin oled_data <= 16'h7BEF; end
    if ( y == 19 && x == 45 ) begin oled_data <= 16'h528A; end
    if ( y == 19 && x == 47 ) begin oled_data <= 16'h0861; end
    if ( y == 19 && x == 48 ) begin oled_data <= 16'h5AEB; end
    if ( y == 19 && x == 49 ) begin oled_data <= 16'h8430; end
    if ( y == 19 && x == 50 ) begin oled_data <= 16'h52AA; end
    if ( y == 19 && x == 51 ) begin oled_data <= 16'h0841; end
    if ( y == 19 && x == 53 ) begin oled_data <= 16'h18C3; end
    if ( y == 19 && x == 54 ) begin oled_data <= 16'h738E; end
    if ( y == 19 && x == 55 ) begin oled_data <= 16'h8410; end
    if ( y == 19 && x == 56 ) begin oled_data <= 16'h7BCF; end
    if ( y == 19 && x == 57 ) begin oled_data <= 16'h7BEF; end
    if ( y == 19 && x == 58 ) begin oled_data <= 16'h8410; end
    if ( y == 19 && x == 59 ) begin oled_data <= 16'h6B4D; end
    if ( y == 19 && x == 60 ) begin oled_data <= 16'h3186; end
    if ( y == 19 && x == 62 ) begin oled_data <= 16'h52AA; end
    if ( y == 19 && x == 63 ) begin oled_data <= 16'h7BCF; end
    if ( y == 19 && x == 64 ) begin oled_data <= 16'h39E7; end
    if ( y == 19 && x == 67 ) begin oled_data <= 16'h630C; end
    if ( y == 19 && x == 68 ) begin oled_data <= 16'h8410; end
    if ( y == 19 && x == 69 ) begin oled_data <= 16'h528A; end
    if ( y == 19 && x == 70 ) begin oled_data <= 16'h0841; end
    if ( y == 19 && x == 72 ) begin oled_data <= 16'h528A; end
    if ( y == 19 && x == 73 ) begin oled_data <= 16'h73AE; end
    if ( y == 19 && x == 74 ) begin oled_data <= 16'h7BCF; end
    if ( y == 19 && x == 75 ) begin oled_data <= 16'h5AEB; end
    if ( y == 19 && x == 76 ) begin oled_data <= 16'h2965; end
    if ( y == 19 && x == 80 ) begin oled_data <= 16'h4A49; end
    if ( y == 19 && x == 81 ) begin oled_data <= 16'h738E; end
    if ( y == 19 && x == 82 ) begin oled_data <= 16'h7BEF; end
    if ( y == 19 && x == 83 ) begin oled_data <= 16'h630C; end
    if ( y == 19 && x == 84 ) begin oled_data <= 16'h2124; end
    if ( y == 20 && x == 10 ) begin oled_data <= 16'h0841; end
    if ( y == 20 && x == 17 ) begin oled_data <= 16'h0841; end
    if ( y == 20 && x == 47 ) begin oled_data <= 16'h0841; end
    if ( y == 20 && x == 86 ) begin oled_data <= 16'h0841; end
    if ( y == 21 && x == 12 ) begin oled_data <= 16'h0841; end
    if ( y == 21 && x == 25 ) begin oled_data <= 16'h0841; end
    if ( y == 21 && x == 38 ) begin oled_data <= 16'h0841; end
    if ( y == 21 && x == 53 ) begin oled_data <= 16'h0841; end
    if ( y == 21 && x == 72 ) begin oled_data <= 16'h0841; end
    if ( y == 22 && x == 24 ) begin oled_data <= 16'h0841; end
    if ( y == 22 && x == 43 ) begin oled_data <= 16'h0841; end
    if ( y == 22 && x == 62 ) begin oled_data <= 16'h0841; end
    if ( y == 23 && x == 11 ) begin oled_data <= 16'h0841; end
    if ( y == 23 && x == 38 ) begin oled_data <= 16'h0841; end
    if ( y == 23 && x == 60 ) begin oled_data <= 16'h0841; end
    if ( y == 32 && x == 24 ) begin oled_data <= 16'h18C3; end
    if ( y == 32 && x == 25 ) begin oled_data <= 16'h5AEB; end
    if ( y == 32 && x == 26 ) begin oled_data <= 16'h6B4D; end
    if ( y == 32 && x == 27 ) begin oled_data <= 16'h4A49; end
    if ( y == 32 && x == 28 ) begin oled_data <= 16'h2965; end
    if ( y == 32 && x == 29 ) begin oled_data <= 16'h4A49; end
    if ( y == 32 && x == 31 ) begin oled_data <= 16'h5AEB; end
    if ( y == 32 && x == 32 ) begin oled_data <= 16'h4208; end
    if ( y == 32 && x == 33 ) begin oled_data <= 16'h2104; end
    if ( y == 32 && x == 34 ) begin oled_data <= 16'h5AEB; end
    if ( y == 32 && x == 36 ) begin oled_data <= 16'h18C3; end
    if ( y == 32 && x == 37 ) begin oled_data <= 16'h5AEB; end
    if ( y == 32 && x == 38 ) begin oled_data <= 16'h0841; end
    if ( y == 32 && x == 41 ) begin oled_data <= 16'h5AEB; end
    if ( y == 32 && x == 42 ) begin oled_data <= 16'h2104; end
    if ( y == 32 && x == 49 ) begin oled_data <= 16'h630C; end
    if ( y == 32 && x == 50 ) begin oled_data <= 16'h39C7; end
    if ( y == 32 && x == 52 ) begin oled_data <= 16'h4228; end
    if ( y == 32 && x == 53 ) begin oled_data <= 16'h5AEB; end
    if ( y == 32 && x == 54 ) begin oled_data <= 16'h0841; end
    if ( y == 32 && x == 56 ) begin oled_data <= 16'h5AEB; end
    if ( y == 32 && x == 57 ) begin oled_data <= 16'h18E3; end
    if ( y == 32 && x == 59 ) begin oled_data <= 16'h3186; end
    if ( y == 32 && x == 60 ) begin oled_data <= 16'h6B6D; end
    if ( y == 32 && x == 61 ) begin oled_data <= 16'h5AEB; end
    if ( y == 32 && x == 62 ) begin oled_data <= 16'h632C; end
    if ( y == 32 && x == 63 ) begin oled_data <= 16'h18C3; end
    if ( y == 32 && x == 64 ) begin oled_data <= 16'h4A69; end
    if ( y == 32 && x == 65 ) begin oled_data <= 16'h4228; end
    if ( y == 32 && x == 67 ) begin oled_data <= 16'h4A69; end
    if ( y == 32 && x == 68 ) begin oled_data <= 16'h738E; end
    if ( y == 32 && x == 69 ) begin oled_data <= 16'h4A49; end
    if ( y == 33 && x == 24 ) begin oled_data <= 16'h5AEB; end
    if ( y == 33 && x == 25 ) begin oled_data <= 16'hBDD7; end
    if ( y == 33 && x >= 26 && x <= 27 ) begin oled_data <= 16'h8C51; end
    if ( y == 33 && x == 28 ) begin oled_data <= 16'h6B4D; end
    if ( y == 33 && x == 29 ) begin oled_data <= 16'hC618; end
    if ( y == 33 && x == 30 ) begin oled_data <= 16'h4228; end
    if ( y == 33 && x == 31 ) begin oled_data <= 16'hC618; end
    if ( y == 33 && x == 32 ) begin oled_data <= 16'hBDD7; end
    if ( y == 33 && x == 33 ) begin oled_data <= 16'h52AA; end
    if ( y == 33 && x == 34 ) begin oled_data <= 16'hAD75; end
    if ( y == 33 && x == 35 ) begin oled_data <= 16'h2124; end
    if ( y == 33 && x == 36 ) begin oled_data <= 16'h73AE; end
    if ( y == 33 && x == 37 ) begin oled_data <= 16'hC638; end
    if ( y == 33 && x == 38 ) begin oled_data <= 16'h2945; end
    if ( y == 33 && x == 40 ) begin oled_data <= 16'h4A49; end
    if ( y == 33 && x == 41 ) begin oled_data <= 16'hCE59; end
    if ( y == 33 && x == 42 ) begin oled_data <= 16'h5AEB; end
    if ( y == 33 && x == 45 ) begin oled_data <= 16'h4228; end
    if ( y == 33 && x == 46 ) begin oled_data <= 16'h4A69; end
    if ( y == 33 && x == 48 ) begin oled_data <= 16'h2124; end
    if ( y == 33 && x == 49 ) begin oled_data <= 16'hD6BA; end
    if ( y == 33 && x == 50 ) begin oled_data <= 16'h9CF3; end
    if ( y == 33 && x == 51 ) begin oled_data <= 16'h2945; end
    if ( y == 33 && x == 52 ) begin oled_data <= 16'hBDD7; end
    if ( y == 33 && x == 53 ) begin oled_data <= 16'hC638; end
    if ( y == 33 && x == 55 ) begin oled_data <= 16'h528A; end
    if ( y == 33 && x == 56 ) begin oled_data <= 16'hD69A; end
    if ( y == 33 && x == 57 ) begin oled_data <= 16'h8C71; end
    if ( y == 33 && x == 59 ) begin oled_data <= 16'h632C; end
    if ( y == 33 && x == 60 ) begin oled_data <= 16'hB5B6; end
    if ( y == 33 && x == 61 ) begin oled_data <= 16'h738E; end
    if ( y == 33 && x >= 62 && x <= 64 ) begin oled_data <= 16'h94B2; end
    if ( y == 33 && x == 65 ) begin oled_data <= 16'h8C71; end
    if ( y == 33 && x == 66 ) begin oled_data <= 16'h7BCF; end
    if ( y == 33 && x == 67 ) begin oled_data <= 16'hAD75; end
    if ( y == 33 && x == 68 ) begin oled_data <= 16'h738E; end
    if ( y == 33 && x == 69 ) begin oled_data <= 16'hAD75; end
    if ( y == 33 && x == 70 ) begin oled_data <= 16'h7BCF; end
    if ( y == 34 && x == 24 ) begin oled_data <= 16'h2965; end
    if ( y == 34 && x >= 25 && x <= 26 ) begin oled_data <= 16'hAD55; end
    if ( y == 34 && x == 27 ) begin oled_data <= 16'hA514; end
    if ( y == 34 && x == 28 ) begin oled_data <= 16'h39C7; end
    if ( y == 34 && x == 29 ) begin oled_data <= 16'hB5B6; end
    if ( y == 34 && x == 30 ) begin oled_data <= 16'hA514; end
    if ( y == 34 && x == 31 ) begin oled_data <= 16'hB596; end
    if ( y == 34 && x == 32 ) begin oled_data <= 16'hBDD7; end
    if ( y == 34 && x == 33 ) begin oled_data <= 16'hAD75; end
    if ( y == 34 && x == 34 ) begin oled_data <= 16'h9492; end
    if ( y == 34 && x == 36 ) begin oled_data <= 16'h2945; end
    if ( y == 34 && x == 37 ) begin oled_data <= 16'hCE79; end
    if ( y == 34 && x == 38 ) begin oled_data <= 16'h2945; end
    if ( y == 34 && x == 40 ) begin oled_data <= 16'h0861; end
    if ( y == 34 && x == 41 ) begin oled_data <= 16'hBDD7; end
    if ( y == 34 && x == 42 ) begin oled_data <= 16'h4208; end
    if ( y == 34 && x == 43 ) begin oled_data <= 16'h0841; end
    if ( y == 34 && x == 45 ) begin oled_data <= 16'h2124; end
    if ( y == 34 && x == 46 ) begin oled_data <= 16'h528A; end
    if ( y == 34 && x == 48 ) begin oled_data <= 16'h2104; end
    if ( y == 34 && x == 49 ) begin oled_data <= 16'hBDF7; end
    if ( y == 34 && x == 50 ) begin oled_data <= 16'hCE59; end
    if ( y == 34 && x == 51 ) begin oled_data <= 16'h9492; end
    if ( y == 34 && x == 52 ) begin oled_data <= 16'hC618; end
    if ( y == 34 && x == 53 ) begin oled_data <= 16'hD69A; end
    if ( y == 34 && x == 54 ) begin oled_data <= 16'h2945; end
    if ( y == 34 && x == 55 ) begin oled_data <= 16'h94B2; end
    if ( y == 34 && x == 56 ) begin oled_data <= 16'hA534; end
    if ( y == 34 && x == 57 ) begin oled_data <= 16'hBDF7; end
    if ( y == 34 && x == 58 ) begin oled_data <= 16'h2965; end
    if ( y == 34 && x == 59 ) begin oled_data <= 16'h6B4D; end
    if ( y == 34 && x == 60 ) begin oled_data <= 16'hCE79; end
    if ( y == 34 && x == 61 ) begin oled_data <= 16'hAD55; end
    if ( y == 34 && x == 62 ) begin oled_data <= 16'hBDD7; end
    if ( y == 34 && x == 63 ) begin oled_data <= 16'h8410; end
    if ( y == 34 && x == 64 ) begin oled_data <= 16'h94B2; end
    if ( y == 34 && x == 65 ) begin oled_data <= 16'h9CF3; end
    if ( y == 34 && x == 66 ) begin oled_data <= 16'hB5B6; end
    if ( y == 34 && x == 67 ) begin oled_data <= 16'h630C; end
    if ( y == 34 && x == 69 ) begin oled_data <= 16'h5AEB; end
    if ( y == 34 && x == 70 ) begin oled_data <= 16'hC618; end
    if ( y == 34 && x == 71 ) begin oled_data <= 16'h18C3; end
    if ( y == 35 && x == 24 ) begin oled_data <= 16'h528A; end
    if ( y == 35 && x == 25 ) begin oled_data <= 16'h52AA; end
    if ( y == 35 && x == 26 ) begin oled_data <= 16'h4A69; end
    if ( y == 35 && x == 27 ) begin oled_data <= 16'hBDD7; end
    if ( y == 35 && x == 28 ) begin oled_data <= 16'h632C; end
    if ( y == 35 && x == 29 ) begin oled_data <= 16'h630C; end
    if ( y == 35 && x == 30 ) begin oled_data <= 16'hE73C; end
    if ( y == 35 && x == 31 ) begin oled_data <= 16'h6B6D; end
    if ( y == 35 && x == 32 ) begin oled_data <= 16'h9CF3; end
    if ( y == 35 && x == 33 ) begin oled_data <= 16'hD6BA; end
    if ( y == 35 && x == 34 ) begin oled_data <= 16'h4A49; end
    if ( y == 35 && x == 36 ) begin oled_data <= 16'h3186; end
    if ( y == 35 && x == 37 ) begin oled_data <= 16'hC618; end
    if ( y == 35 && x == 38 ) begin oled_data <= 16'h3186; end
    if ( y == 35 && x == 40 ) begin oled_data <= 16'h0861; end
    if ( y == 35 && x == 41 ) begin oled_data <= 16'hB5B6; end
    if ( y == 35 && x == 42 ) begin oled_data <= 16'h528A; end
    if ( y == 35 && x == 45 ) begin oled_data <= 16'h2945; end
    if ( y == 35 && x == 46 ) begin oled_data <= 16'h39C7; end
    if ( y == 35 && x == 48 ) begin oled_data <= 16'h2124; end
    if ( y == 35 && x == 49 ) begin oled_data <= 16'hB5B6; end
    if ( y == 35 && x == 50 ) begin oled_data <= 16'h7BCF; end
    if ( y == 35 && x == 51 ) begin oled_data <= 16'hD69A; end
    if ( y == 35 && x == 52 ) begin oled_data <= 16'h9492; end
    if ( y == 35 && x == 53 ) begin oled_data <= 16'hC618; end
    if ( y == 35 && x == 54 ) begin oled_data <= 16'h6B4D; end
    if ( y == 35 && x == 55 ) begin oled_data <= 16'hB5B6; end
    if ( y == 35 && x == 56 ) begin oled_data <= 16'h8C71; end
    if ( y == 35 && x == 57 ) begin oled_data <= 16'hC618; end
    if ( y == 35 && x == 58 ) begin oled_data <= 16'h8410; end
    if ( y == 35 && x == 59 ) begin oled_data <= 16'h630C; end
    if ( y == 35 && x == 60 ) begin oled_data <= 16'hB596; end
    if ( y == 35 && x == 61 ) begin oled_data <= 16'h4208; end
    if ( y == 35 && x == 62 ) begin oled_data <= 16'hC638; end
    if ( y == 35 && x == 63 ) begin oled_data <= 16'h4208; end
    if ( y == 35 && x == 64 ) begin oled_data <= 16'h94B2; end
    if ( y == 35 && x >= 65 && x <= 66 ) begin oled_data <= 16'h9CF3; end
    if ( y == 35 && x == 67 ) begin oled_data <= 16'h8C71; end
    if ( y == 35 && x == 68 ) begin oled_data <= 16'h31A6; end
    if ( y == 35 && x == 69 ) begin oled_data <= 16'h8C51; end
    if ( y == 35 && x == 70 ) begin oled_data <= 16'h9CF3; end
    if ( y == 35 && x == 71 ) begin oled_data <= 16'h0861; end
    if ( y == 36 && x == 24 ) begin oled_data <= 16'h39E7; end
    if ( y == 36 && x == 25 ) begin oled_data <= 16'h9CD3; end
    if ( y == 36 && x == 26 ) begin oled_data <= 16'hA534; end
    if ( y == 36 && x == 27 ) begin oled_data <= 16'h8C51; end
    if ( y == 36 && x == 28 ) begin oled_data <= 16'h2124; end
    if ( y == 36 && x == 29 ) begin oled_data <= 16'h2965; end
    if ( y == 36 && x == 30 ) begin oled_data <= 16'hA534; end
    if ( y == 36 && x == 31 ) begin oled_data <= 16'h31A6; end
    if ( y == 36 && x == 32 ) begin oled_data <= 16'h52AA; end
    if ( y == 36 && x == 33 ) begin oled_data <= 16'h94B2; end
    if ( y == 36 && x == 34 ) begin oled_data <= 16'h18C3; end
    if ( y == 36 && x == 36 ) begin oled_data <= 16'h18E3; end
    if ( y == 36 && x == 37 ) begin oled_data <= 16'h9CD3; end
    if ( y == 36 && x == 38 ) begin oled_data <= 16'h3186; end
    if ( y == 36 && x == 40 ) begin oled_data <= 16'h0861; end
    if ( y == 36 && x == 41 ) begin oled_data <= 16'h8430; end
    if ( y == 36 && x == 42 ) begin oled_data <= 16'h528A; end
    if ( y == 36 && x == 45 ) begin oled_data <= 16'h4228; end
    if ( y == 36 && x == 46 ) begin oled_data <= 16'h73AE; end
    if ( y == 36 && x == 49 ) begin oled_data <= 16'h94B2; end
    if ( y == 36 && x == 50 ) begin oled_data <= 16'h39E7; end
    if ( y == 36 && x == 51 ) begin oled_data <= 16'h632C; end
    if ( y == 36 && x == 52 ) begin oled_data <= 16'h4A69; end
    if ( y == 36 && x == 53 ) begin oled_data <= 16'h9CF3; end
    if ( y == 36 && x == 54 ) begin oled_data <= 16'h8430; end
    if ( y == 36 && x == 55 ) begin oled_data <= 16'h7BEF; end
    if ( y == 36 && x == 57 ) begin oled_data <= 16'h39E7; end
    if ( y == 36 && x == 58 ) begin oled_data <= 16'h9CF3; end
    if ( y == 36 && x == 59 ) begin oled_data <= 16'h632C; end
    if ( y == 36 && x == 60 ) begin oled_data <= 16'h9492; end
    if ( y == 36 && x == 62 ) begin oled_data <= 16'h6B4D; end
    if ( y == 36 && x == 63 ) begin oled_data <= 16'h8C51; end
    if ( y == 36 && x == 64 ) begin oled_data <= 16'h73AE; end
    if ( y == 36 && x == 65 ) begin oled_data <= 16'h8430; end
    if ( y == 36 && x == 67 ) begin oled_data <= 16'h8C71; end
    if ( y == 36 && x == 68 ) begin oled_data <= 16'hAD75; end
    if ( y == 36 && x == 69 ) begin oled_data <= 16'h8430; end
    if ( y == 36 && x == 70 ) begin oled_data <= 16'h39E7; end
    if ( y == 37 && x == 26 ) begin oled_data <= 16'h0861; end
    if ( y == 37 && x == 29 ) begin oled_data <= 16'h0841; end
    if ( y == 37 && x == 31 ) begin oled_data <= 16'h0841; end
    if ( y == 37 && x == 36 ) begin oled_data <= 16'h0841; end
    if ( y == 37 && x == 37 ) begin oled_data <= 16'h0861; end
    if ( y == 37 && x >= 41 && x <= 42 ) begin oled_data <= 16'h0841; end
    if ( y == 37 && x == 47 ) begin oled_data <= 16'h0841; end
    if ( y == 37 && x == 49 ) begin oled_data <= 16'h0841; end
    if ( y == 37 && x == 55 ) begin oled_data <= 16'h0841; end
    if ( y == 37 && x == 58 ) begin oled_data <= 16'h0861; end
    if ( y == 37 && x == 63 ) begin oled_data <= 16'h0841; end
    if ( y == 37 && x == 65 ) begin oled_data <= 16'h0861; end
    if ( y == 37 && x == 68 ) begin oled_data <= 16'h0861; end
    if ( y == 38 && x == 51 ) begin oled_data <= 16'h0841; end
    if ( y == 38 && x == 57 ) begin oled_data <= 16'h0841; end
    if ( y == 38 && x == 69 ) begin oled_data <= 16'h0841; end
    if ( y == 40 && x == 60 ) begin oled_data <= 16'h0841; end
    if ( y == 41 && x == 31 ) begin oled_data <= 16'h0841; end
    if ( y == 41 && x == 54 ) begin oled_data <= 16'h0861; end
    if ( y == 41 && x == 63 ) begin oled_data <= 16'h0841; end
    if ( y == 42 && x == 17 ) begin oled_data <= 16'h0841; end
    if ( y == 42 && x == 47 ) begin oled_data <= 16'h0861; end
    if ( y == 42 && x == 61 ) begin oled_data <= 16'h0841; end
    if ( y == 42 && x == 70 ) begin oled_data <= 16'h0841; end
    if ( y == 42 && x == 74 ) begin oled_data <= 16'h0841; end
    if ( y == 43 && x == 20 ) begin oled_data <= 16'h0841; end
    if ( y == 43 && x == 60 ) begin oled_data <= 16'h0841; end
    if ( y == 43 && x == 72 ) begin oled_data <= 16'h0841; end
    if ( y == 44 && x == 17 ) begin oled_data <= 16'h18E3; end
    if ( y == 44 && x == 18 ) begin oled_data <= 16'h8430; end
    if ( y == 44 && x == 19 ) begin oled_data <= 16'h9CD3; end
    if ( y == 44 && x == 20 ) begin oled_data <= 16'h7BEF; end
    if ( y == 44 && x == 21 ) begin oled_data <= 16'h4A49; end
    if ( y == 44 && x == 22 ) begin oled_data <= 16'h9492; end
    if ( y == 44 && x == 23 ) begin oled_data <= 16'h2945; end
    if ( y == 44 && x == 24 ) begin oled_data <= 16'h6B6D; end
    if ( y == 44 && x == 25 ) begin oled_data <= 16'h8C71; end
    if ( y == 44 && x == 26 ) begin oled_data <= 16'h2124; end
    if ( y == 44 && x == 27 ) begin oled_data <= 16'h8C51; end
    if ( y == 44 && x == 28 ) begin oled_data <= 16'h39C7; end
    if ( y == 44 && x == 29 ) begin oled_data <= 16'h18E3; end
    if ( y == 44 && x == 30 ) begin oled_data <= 16'h9492; end
    if ( y == 44 && x == 31 ) begin oled_data <= 16'h2965; end
    if ( y == 44 && x == 33 ) begin oled_data <= 16'h4208; end
    if ( y == 44 && x == 34 ) begin oled_data <= 16'h8C71; end
    if ( y == 44 && x == 35 ) begin oled_data <= 16'h8430; end
    if ( y == 44 && x == 36 ) begin oled_data <= 16'h2124; end
    if ( y == 44 && x == 39 ) begin oled_data <= 16'h0841; end
    if ( y == 44 && x == 42 ) begin oled_data <= 16'h8C51; end
    if ( y == 44 && x == 43 ) begin oled_data <= 16'h7BCF; end
    if ( y == 44 && x == 44 ) begin oled_data <= 16'h0841; end
    if ( y == 44 && x == 45 ) begin oled_data <= 16'h4A49; end
    if ( y == 44 && x == 46 ) begin oled_data <= 16'h9CF3; end
    if ( y == 44 && x == 47 ) begin oled_data <= 16'h4A69; end
    if ( y == 44 && x == 48 ) begin oled_data <= 16'h9CD3; end
    if ( y == 44 && x >= 49 && x <= 50 ) begin oled_data <= 16'h9CF3; end
    if ( y == 44 && x == 51 ) begin oled_data <= 16'h6B4D; end
    if ( y == 44 && x == 52 ) begin oled_data <= 16'h18E3; end
    if ( y == 44 && x == 53 ) begin oled_data <= 16'h7BEF; end
    if ( y == 44 && x == 54 ) begin oled_data <= 16'h94B2; end
    if ( y == 44 && x == 55 ) begin oled_data <= 16'h8C51; end
    if ( y == 44 && x == 56 ) begin oled_data <= 16'h3186; end
    if ( y == 44 && x == 58 ) begin oled_data <= 16'h39C7; end
    if ( y == 44 && x == 59 ) begin oled_data <= 16'h94B2; end
    if ( y == 44 && x == 60 ) begin oled_data <= 16'h2945; end
    if ( y == 44 && x == 62 ) begin oled_data <= 16'h6B4D; end
    if ( y == 44 && x == 63 ) begin oled_data <= 16'h8C71; end
    if ( y == 44 && x == 64 ) begin oled_data <= 16'h0861; end
    if ( y == 44 && x == 65 ) begin oled_data <= 16'h4208; end
    if ( y == 44 && x == 66 ) begin oled_data <= 16'h9CD3; end
    if ( y == 44 && x == 67 ) begin oled_data <= 16'h4208; end
    if ( y == 44 && x == 69 ) begin oled_data <= 16'h73AE; end
    if ( y == 44 && x == 70 ) begin oled_data <= 16'h8430; end
    if ( y == 44 && x == 71 ) begin oled_data <= 16'h0861; end
    if ( y == 44 && x == 73 ) begin oled_data <= 16'h9492; end
    if ( y == 44 && x == 74 ) begin oled_data <= 16'h52AA; end
    if ( y == 44 && x == 76 ) begin oled_data <= 16'h8430; end
    if ( y == 44 && x == 77 ) begin oled_data <= 16'h39E7; end
    if ( y == 45 && x == 17 ) begin oled_data <= 16'h4208; end
    if ( y == 45 && x == 18 ) begin oled_data <= 16'hB5B6; end
    if ( y == 45 && x == 19 ) begin oled_data <= 16'h8430; end
    if ( y == 45 && x == 20 ) begin oled_data <= 16'h7BEF; end
    if ( y == 45 && x == 21 ) begin oled_data <= 16'h528A; end
    if ( y == 45 && x == 22 ) begin oled_data <= 16'hB5B6; end
    if ( y == 45 && x == 23 ) begin oled_data <= 16'h6B6D; end
    if ( y == 45 && x == 24 ) begin oled_data <= 16'hAD75; end
    if ( y == 45 && x == 25 ) begin oled_data <= 16'hD69A; end
    if ( y == 45 && x == 26 ) begin oled_data <= 16'h6B4D; end
    if ( y == 45 && x == 27 ) begin oled_data <= 16'hB5B6; end
    if ( y == 45 && x == 28 ) begin oled_data <= 16'h39E7; end
    if ( y == 45 && x == 29 ) begin oled_data <= 16'h3186; end
    if ( y == 45 && x == 30 ) begin oled_data <= 16'hC618; end
    if ( y == 45 && x == 31 ) begin oled_data <= 16'h5AEB; end
    if ( y == 45 && x == 32 ) begin oled_data <= 16'h0861; end
    if ( y == 45 && x == 33 ) begin oled_data <= 16'h7BCF; end
    if ( y == 45 && x == 34 ) begin oled_data <= 16'h632C; end
    if ( y == 45 && x == 35 ) begin oled_data <= 16'hB596; end
    if ( y == 45 && x == 36 ) begin oled_data <= 16'h8C51; end
    if ( y == 45 && x == 38 ) begin oled_data <= 16'h2104; end
    if ( y == 45 && x == 39 ) begin oled_data <= 16'h8430; end
    if ( y == 45 && x == 41 ) begin oled_data <= 16'h0841; end
    if ( y == 45 && x == 42 ) begin oled_data <= 16'hB596; end
    if ( y == 45 && x == 43 ) begin oled_data <= 16'hDEFB; end
    if ( y == 45 && x == 44 ) begin oled_data <= 16'h4228; end
    if ( y == 45 && x == 45 ) begin oled_data <= 16'hA534; end
    if ( y == 45 && x == 46 ) begin oled_data <= 16'hE73C; end
    if ( y == 45 && x == 47 ) begin oled_data <= 16'h6B4D; end
    if ( y == 45 && x == 48 ) begin oled_data <= 16'hCE79; end
    if ( y == 45 && x == 49 ) begin oled_data <= 16'h94B2; end
    if ( y == 45 && x == 50 ) begin oled_data <= 16'h7BEF; end
    if ( y == 45 && x == 51 ) begin oled_data <= 16'h31A6; end
    if ( y == 45 && x == 52 ) begin oled_data <= 16'h9492; end
    if ( y == 45 && x == 53 ) begin oled_data <= 16'hA514; end
    if ( y == 45 && x == 54 ) begin oled_data <= 16'h4228; end
    if ( y == 45 && x == 55 ) begin oled_data <= 16'h632C; end
    if ( y == 45 && x == 56 ) begin oled_data <= 16'h4A69; end
    if ( y == 45 && x == 58 ) begin oled_data <= 16'h7BEF; end
    if ( y == 45 && x == 59 ) begin oled_data <= 16'hDEDB; end
    if ( y == 45 && x == 60 ) begin oled_data <= 16'h8C51; end
    if ( y == 45 && x == 62 ) begin oled_data <= 16'h8C51; end
    if ( y == 45 && x == 63 ) begin oled_data <= 16'hE73C; end
    if ( y == 45 && x == 64 ) begin oled_data <= 16'h630C; end
    if ( y == 45 && x == 65 ) begin oled_data <= 16'h7BCF; end
    if ( y == 45 && x == 66 ) begin oled_data <= 16'hEF5D; end
    if ( y == 45 && x == 67 ) begin oled_data <= 16'h632C; end
    if ( y == 45 && x == 69 ) begin oled_data <= 16'hB596; end
    if ( y == 45 && x == 70 ) begin oled_data <= 16'hD69A; end
    if ( y == 45 && x == 71 ) begin oled_data <= 16'h4208; end
    if ( y == 45 && x == 72 ) begin oled_data <= 16'h2104; end
    if ( y == 45 && x == 73 ) begin oled_data <= 16'hCE59; end
    if ( y == 45 && x == 74 ) begin oled_data <= 16'hCE79; end
    if ( y == 45 && x == 75 ) begin oled_data <= 16'h4A49; end
    if ( y == 45 && x == 76 ) begin oled_data <= 16'hA514; end
    if ( y == 45 && x == 77 ) begin oled_data <= 16'h738E; end
    if ( y == 46 && x == 17 ) begin oled_data <= 16'h18C3; end
    if ( y == 46 && x == 18 ) begin oled_data <= 16'h6B4D; end
    if ( y == 46 && x == 19 ) begin oled_data <= 16'h8C71; end
    if ( y == 46 && x == 20 ) begin oled_data <= 16'hBDD7; end
    if ( y == 46 && x == 21 ) begin oled_data <= 16'h5ACB; end
    if ( y == 46 && x == 22 ) begin oled_data <= 16'h7BCF; end
    if ( y == 46 && x == 23 ) begin oled_data <= 16'hC638; end
    if ( y == 46 && x == 24 ) begin oled_data <= 16'hAD75; end
    if ( y == 46 && x == 25 ) begin oled_data <= 16'hAD55; end
    if ( y == 46 && x == 26 ) begin oled_data <= 16'hBDF7; end
    if ( y == 46 && x == 27 ) begin oled_data <= 16'h9CF3; end
    if ( y == 46 && x == 28 ) begin oled_data <= 16'h0861; end
    if ( y == 46 && x == 30 ) begin oled_data <= 16'hB596; end
    if ( y == 46 && x == 31 ) begin oled_data <= 16'h5ACB; end
    if ( y == 46 && x == 33 ) begin oled_data <= 16'h4208; end
    if ( y == 46 && x == 34 ) begin oled_data <= 16'h8C71; end
    if ( y == 46 && x == 35 ) begin oled_data <= 16'hB5B6; end
    if ( y == 46 && x == 36 ) begin oled_data <= 16'h4A69; end
    if ( y == 46 && x == 39 ) begin oled_data <= 16'h3186; end
    if ( y == 46 && x == 40 ) begin oled_data <= 16'h0841; end
    if ( y == 46 && x == 42 ) begin oled_data <= 16'hAD55; end
    if ( y == 46 && x == 43 ) begin oled_data <= 16'hAD75; end
    if ( y == 46 && x == 44 ) begin oled_data <= 16'hCE59; end
    if ( y == 46 && x == 45 ) begin oled_data <= 16'hAD75; end
    if ( y == 46 && x == 46 ) begin oled_data <= 16'hD69A; end
    if ( y == 46 && x == 47 ) begin oled_data <= 16'h6B6D; end
    if ( y == 46 && x == 48 ) begin oled_data <= 16'hCE79; end
    if ( y == 46 && x == 49 ) begin oled_data <= 16'h9492; end
    if ( y == 46 && x == 50 ) begin oled_data <= 16'h73AE; end
    if ( y == 46 && x == 52 ) begin oled_data <= 16'hA514; end
    if ( y == 46 && x == 53 ) begin oled_data <= 16'h738E; end
    if ( y == 46 && x == 54 ) begin oled_data <= 16'h52AA; end
    if ( y == 46 && x == 55 ) begin oled_data <= 16'hA534; end
    if ( y == 46 && x == 56 ) begin oled_data <= 16'h8C71; end
    if ( y == 46 && x == 57 ) begin oled_data <= 16'h3186; end
    if ( y == 46 && x == 58 ) begin oled_data <= 16'hBDD7; end
    if ( y == 46 && x == 59 ) begin oled_data <= 16'hA514; end
    if ( y == 46 && x == 60 ) begin oled_data <= 16'hD69A; end
    if ( y == 46 && x == 61 ) begin oled_data <= 16'h2124; end
    if ( y == 46 && x == 62 ) begin oled_data <= 16'h8C51; end
    if ( y == 46 && x == 63 ) begin oled_data <= 16'hBDD7; end
    if ( y == 46 && x == 64 ) begin oled_data <= 16'hCE59; end
    if ( y == 46 && x == 65 ) begin oled_data <= 16'hA534; end
    if ( y == 46 && x == 66 ) begin oled_data <= 16'hCE59; end
    if ( y == 46 && x == 67 ) begin oled_data <= 16'h630C; end
    if ( y == 46 && x == 68 ) begin oled_data <= 16'h6B4D; end
    if ( y == 46 && x == 69 ) begin oled_data <= 16'hB596; end
    if ( y == 46 && x == 70 ) begin oled_data <= 16'hAD55; end
    if ( y == 46 && x == 71 ) begin oled_data <= 16'h9CF3; end
    if ( y == 46 && x == 72 ) begin oled_data <= 16'h18E3; end
    if ( y == 46 && x == 73 ) begin oled_data <= 16'hB5B6; end
    if ( y == 46 && x == 74 ) begin oled_data <= 16'h9492; end
    if ( y == 46 && x == 75 ) begin oled_data <= 16'hC638; end
    if ( y == 46 && x == 76 ) begin oled_data <= 16'hBDD7; end
    if ( y == 46 && x == 77 ) begin oled_data <= 16'h6B6D; end
    if ( y == 46 && x == 78 ) begin oled_data <= 16'h0841; end
    if ( y == 47 && x == 17 ) begin oled_data <= 16'h4A69; end
    if ( y == 47 && x == 18 ) begin oled_data <= 16'h8410; end
    if ( y == 47 && x == 19 ) begin oled_data <= 16'h738E; end
    if ( y == 47 && x == 20 ) begin oled_data <= 16'hA514; end
    if ( y == 47 && x == 21 ) begin oled_data <= 16'h7BCF; end
    if ( y == 47 && x == 22 ) begin oled_data <= 16'h2965; end
    if ( y == 47 && x == 23 ) begin oled_data <= 16'hD69A; end
    if ( y == 47 && x == 24 ) begin oled_data <= 16'h8430; end
    if ( y == 47 && x == 25 ) begin oled_data <= 16'h52AA; end
    if ( y == 47 && x == 26 ) begin oled_data <= 16'hDEDB; end
    if ( y == 47 && x == 27 ) begin oled_data <= 16'h52AA; end
    if ( y == 47 && x == 28 ) begin oled_data <= 16'h0841; end
    if ( y == 47 && x == 29 ) begin oled_data <= 16'h0861; end
    if ( y == 47 && x == 30 ) begin oled_data <= 16'hAD75; end
    if ( y == 47 && x == 31 ) begin oled_data <= 16'h630C; end
    if ( y == 47 && x == 32 ) begin oled_data <= 16'h2945; end
    if ( y == 47 && x == 33 ) begin oled_data <= 16'hAD75; end
    if ( y == 47 && x == 34 ) begin oled_data <= 16'hC618; end
    if ( y == 47 && x == 35 ) begin oled_data <= 16'h8C51; end
    if ( y == 47 && x == 36 ) begin oled_data <= 16'h5ACB; end
    if ( y == 47 && x == 37 ) begin oled_data <= 16'h0841; end
    if ( y == 47 && x == 38 ) begin oled_data <= 16'h2965; end
    if ( y == 47 && x == 39 ) begin oled_data <= 16'h738E; end
    if ( y == 47 && x == 42 ) begin oled_data <= 16'hA534; end
    if ( y == 47 && x == 43 ) begin oled_data <= 16'h7BEF; end
    if ( y == 47 && x == 44 ) begin oled_data <= 16'hB596; end
    if ( y == 47 && x == 45 ) begin oled_data <= 16'h7BCF; end
    if ( y == 47 && x == 46 ) begin oled_data <= 16'hC638; end
    if ( y == 47 && x == 47 ) begin oled_data <= 16'h6B6D; end
    if ( y == 47 && x == 48 ) begin oled_data <= 16'hC638; end
    if ( y == 47 && x == 49 ) begin oled_data <= 16'h7BEF; end
    if ( y == 47 && x == 50 ) begin oled_data <= 16'h630C; end
    if ( y == 47 && x == 51 ) begin oled_data <= 16'h4A69; end
    if ( y == 47 && x == 52 ) begin oled_data <= 16'h7BCF; end
    if ( y == 47 && x == 53 ) begin oled_data <= 16'hBDD7; end
    if ( y == 47 && x == 54 ) begin oled_data <= 16'h6B6D; end
    if ( y == 47 && x == 55 ) begin oled_data <= 16'hA534; end
    if ( y == 47 && x == 56 ) begin oled_data <= 16'hAD55; end
    if ( y == 47 && x == 57 ) begin oled_data <= 16'h7BEF; end
    if ( y == 47 && x == 58 ) begin oled_data <= 16'hA514; end
    if ( y == 47 && x == 59 ) begin oled_data <= 16'h528A; end
    if ( y == 47 && x == 60 ) begin oled_data <= 16'hB596; end
    if ( y == 47 && x == 61 ) begin oled_data <= 16'h8C51; end
    if ( y == 47 && x == 62 ) begin oled_data <= 16'h7BEF; end
    if ( y == 47 && x == 63 ) begin oled_data <= 16'h8C51; end
    if ( y == 47 && x == 64 ) begin oled_data <= 16'hAD55; end
    if ( y == 47 && x == 65 ) begin oled_data <= 16'h73AE; end
    if ( y == 47 && x == 66 ) begin oled_data <= 16'hAD55; end
    if ( y == 47 && x == 67 ) begin oled_data <= 16'h7BEF; end
    if ( y == 47 && x == 68 ) begin oled_data <= 16'h9CF3; end
    if ( y == 47 && x == 69 ) begin oled_data <= 16'h8C51; end
    if ( y == 47 && x == 70 ) begin oled_data <= 16'h73AE; end
    if ( y == 47 && x == 71 ) begin oled_data <= 16'hCE59; end
    if ( y == 47 && x == 72 ) begin oled_data <= 16'h52AA; end
    if ( y == 47 && x == 73 ) begin oled_data <= 16'hB596; end
    if ( y == 47 && x == 74 ) begin oled_data <= 16'h39C7; end
    if ( y == 47 && x == 75 ) begin oled_data <= 16'h6B6D; end
    if ( y == 47 && x == 76 ) begin oled_data <= 16'hE71C; end
    if ( y == 47 && x == 77 ) begin oled_data <= 16'h738E; end
    if ( y == 48 && x == 17 ) begin oled_data <= 16'h2104; end
    if ( y == 48 && x == 18 ) begin oled_data <= 16'h5AEB; end
    if ( y == 48 && x == 19 ) begin oled_data <= 16'h73AE; end
    if ( y == 48 && x == 20 ) begin oled_data <= 16'h630C; end
    if ( y == 48 && x == 21 ) begin oled_data <= 16'h2104; end
    if ( y == 48 && x == 22 ) begin oled_data <= 16'h0841; end
    if ( y == 48 && x == 23 ) begin oled_data <= 16'h5ACB; end
    if ( y == 48 && x == 24 ) begin oled_data <= 16'h31A6; end
    if ( y == 48 && x == 25 ) begin oled_data <= 16'h18E3; end
    if ( y == 48 && x == 26 ) begin oled_data <= 16'h632C; end
    if ( y == 48 && x == 27 ) begin oled_data <= 16'h2104; end
    if ( y == 48 && x == 29 ) begin oled_data <= 16'h0841; end
    if ( y == 48 && x == 30 ) begin oled_data <= 16'h5ACB; end
    if ( y == 48 && x == 31 ) begin oled_data <= 16'h39E7; end
    if ( y == 48 && x == 32 ) begin oled_data <= 16'h18E3; end
    if ( y == 48 && x == 33 ) begin oled_data <= 16'h738E; end
    if ( y == 48 && x >= 34 && x <= 35 ) begin oled_data <= 16'h7BCF; end
    if ( y == 48 && x == 36 ) begin oled_data <= 16'h6B4D; end
    if ( y == 48 && x == 39 ) begin oled_data <= 16'h632C; end
    if ( y == 48 && x == 40 ) begin oled_data <= 16'h18C3; end
    if ( y == 48 && x == 42 ) begin oled_data <= 16'h528A; end
    if ( y == 48 && x == 43 ) begin oled_data <= 16'h39C7; end
    if ( y == 48 && x == 44 ) begin oled_data <= 16'h2945; end
    if ( y == 48 && x == 45 ) begin oled_data <= 16'h18E3; end
    if ( y == 48 && x == 46 ) begin oled_data <= 16'h632C; end
    if ( y == 48 && x == 47 ) begin oled_data <= 16'h4208; end
    if ( y == 48 && x == 48 ) begin oled_data <= 16'h6B4D; end
    if ( y == 48 && x == 49 ) begin oled_data <= 16'h7BCF; end
    if ( y == 48 && x == 50 ) begin oled_data <= 16'h7BEF; end
    if ( y == 48 && x == 51 ) begin oled_data <= 16'h6B6D; end
    if ( y == 48 && x == 52 ) begin oled_data <= 16'h2104; end
    if ( y == 48 && x == 53 ) begin oled_data <= 16'h528A; end
    if ( y == 48 && x == 54 ) begin oled_data <= 16'h73AE; end
    if ( y == 48 && x == 55 ) begin oled_data <= 16'h6B6D; end
    if ( y == 48 && x == 56 ) begin oled_data <= 16'h4208; end
    if ( y == 48 && x == 57 ) begin oled_data <= 16'h4A69; end
    if ( y == 48 && x == 58 ) begin oled_data <= 16'h39E7; end
    if ( y == 48 && x == 59 ) begin oled_data <= 16'h0841; end
    if ( y == 48 && x == 60 ) begin oled_data <= 16'h39C7; end
    if ( y == 48 && x == 61 ) begin oled_data <= 16'h6B6D; end
    if ( y == 48 && x == 62 ) begin oled_data <= 16'h4A49; end
    if ( y == 48 && x == 63 ) begin oled_data <= 16'h528A; end
    if ( y == 48 && x == 64 ) begin oled_data <= 16'h2124; end
    if ( y == 48 && x == 65 ) begin oled_data <= 16'h18E3; end
    if ( y == 48 && x == 66 ) begin oled_data <= 16'h528A; end
    if ( y == 48 && x == 67 ) begin oled_data <= 16'h52AA; end
    if ( y == 48 && x == 68 ) begin oled_data <= 16'h5AEB; end
    if ( y == 48 && x == 69 ) begin oled_data <= 16'h18E3; end
    if ( y == 48 && x == 70 ) begin oled_data <= 16'h0861; end
    if ( y == 48 && x >= 71 && x <= 73 ) begin oled_data <= 16'h5ACB; end
    if ( y == 48 && x == 74 ) begin oled_data <= 16'h2965; end
    if ( y == 48 && x == 75 ) begin oled_data <= 16'h0841; end
    if ( y == 48 && x == 76 ) begin oled_data <= 16'h5ACB; end
    if ( y == 48 && x == 77 ) begin oled_data <= 16'h39C7; end
    if ( y == 48 && x == 78 ) begin oled_data <= 16'h0841; end
    if ( y == 49 && x == 23 ) begin oled_data <= 16'h0841; end
    if ( y == 49 && x == 61 ) begin oled_data <= 16'h0841; end
    if ( y == 49 && x == 68 ) begin oled_data <= 16'h0841; end
    if ( y == 50 && x == 38 ) begin oled_data <= 16'h0841; end
    if ( y == 50 && x == 59 ) begin oled_data <= 16'h0841; end
    if ( y == 51 && x == 19 ) begin oled_data <= 16'h0841; end
    if ( y == 51 && x == 46 ) begin oled_data <= 16'h0841; end
    if ( y == 51 && x == 57 ) begin oled_data <= 16'h0841; end
    if ( y == 51 && x == 67 ) begin oled_data <= 16'h0861; end
    if ( y == 51 && x == 73 ) begin oled_data <= 16'h0841; end
    if ( y == 52 && x == 32 ) begin oled_data <= 16'h0841; end
    if ( y == 52 && x == 48 ) begin oled_data <= 16'h0841; end
    if ( y == 52 && x == 51 ) begin oled_data <= 16'h0841; end
    if ( y == 53 && x == 51 ) begin oled_data <= 16'h0841; end
    if ( y == 53 && x == 71 ) begin oled_data <= 16'h0841; end
    if ( y == 54 && x == 69 ) begin oled_data <= 16'h0841; end
    end
    
    //Mega-man
    else if(sw[12] == 1 && sw[11] == 0 && sw[10] == 1)
    begin
    oled_data <= 16'h0000;
    //background
    if ( y == 0 && x == 0) begin oled_data <= 16'h2104; end
    if ( y == 0 && x == 1) begin oled_data <= 16'h18E3; end
    if ( y == 0 && x == 10) begin oled_data <= 16'h2124; end
    if ( y == 0 && x == 11) begin oled_data <= 16'h0861; end
    if ( y == 0 && x >= 12 && x <= 13) begin oled_data <= 16'h0841; end
    if ( y == 0 && x == 48) begin oled_data <= 16'h0841; end
    if ( y == 0 && x == 52) begin oled_data <= 16'h0861; end
    if ( y == 0 && x == 53) begin oled_data <= 16'h0841; end
    if ( y == 0 && x == 55) begin oled_data <= 16'h0861; end
    if ( y == 0 && x == 56) begin oled_data <= 16'h0841; end
    if ( y == 0 && x == 66) begin oled_data <= 16'h0841; end
    if ( y == 0 && x == 74) begin oled_data <= 16'h0841; end
    if ( y == 0 && x == 82) begin oled_data <= 16'h0861; end
    if ( y == 0 && x == 93) begin oled_data <= 16'h0840; end
    if ( y == 0 && x == 94) begin oled_data <= 16'h0841; end
    if ( y == 0 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 1 && x == 10) begin oled_data <= 16'h2124; end
    if ( y == 1 && x >= 11 && x <= 13) begin oled_data <= 16'h0861; end
    if ( y == 1 && x == 14) begin oled_data <= 16'h0841; end
    if ( y == 1 && x == 22) begin oled_data <= 16'h0841; end
    if ( y == 1 && x == 23) begin oled_data <= 16'h2945; end
    if ( y == 1 && x == 36) begin oled_data <= 16'h0841; end
    if ( y == 1 && x == 39) begin oled_data <= 16'h0841; end
    if ( y == 1 && x == 52) begin oled_data <= 16'h2965; end
    if ( y == 1 && x >= 56 && x <= 57) begin oled_data <= 16'h0841; end
    if ( y == 1 && x == 66) begin oled_data <= 16'h0841; end
    if ( y == 1 && x == 69) begin oled_data <= 16'h0841; end
    if ( y == 1 && x == 75) begin oled_data <= 16'h0861; end
    if ( y == 1 && x == 88) begin oled_data <= 16'h0861; end
    if ( y == 1 && x >= 92 && x <= 93) begin oled_data <= 16'h0841; end
    if ( y == 1 && x == 94) begin oled_data <= 16'h0861; end
    if ( y == 1 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 2 && x == 12) begin oled_data <= 16'h18E3; end
    if ( y == 2 && x == 13) begin oled_data <= 16'h0841; end
    if ( y == 2 && x == 17) begin oled_data <= 16'h2104; end
    if ( y == 2 && x == 30) begin oled_data <= 16'h0841; end
    if ( y == 2 && x == 36) begin oled_data <= 16'h0841; end
    if ( y == 2 && x == 37) begin oled_data <= 16'h0840; end
    if ( y == 2 && x == 70) begin oled_data <= 16'h2945; end
    if ( y == 2 && x == 71) begin oled_data <= 16'h18C3; end
    if ( y == 2 && x == 81) begin oled_data <= 16'h2965; end
    if ( y == 2 && x == 91) begin oled_data <= 16'h0841; end
    if ( y == 2 && x == 94) begin oled_data <= 16'h0841; end
    if ( y == 2 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 3 && x == 8) begin oled_data <= 16'h0841; end
    if ( y == 3 && x == 12) begin oled_data <= 16'h0841; end
    if ( y == 3 && x == 36) begin oled_data <= 16'h18E3; end
    if ( y == 3 && x == 37) begin oled_data <= 16'h2104; end
    if ( y == 3 && x == 39) begin oled_data <= 16'h2124; end
    if ( y == 3 && x == 40) begin oled_data <= 16'h1903; end
    if ( y == 3 && x == 56) begin oled_data <= 16'h0861; end
    if ( y == 3 && x == 70) begin oled_data <= 16'h18C3; end
    if ( y == 3 && x == 71) begin oled_data <= 16'h0841; end
    if ( y == 3 && x == 76) begin oled_data <= 16'h0841; end
    if ( y == 3 && x == 80) begin oled_data <= 16'h0861; end
    if ( y == 3 && x == 81) begin oled_data <= 16'h2104; end
    if ( y == 3 && x >= 92 && x <= 93) begin oled_data <= 16'h0861; end
    if ( y == 3 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 4 && x == 2) begin oled_data <= 16'h0841; end
    if ( y == 4 && x == 36) begin oled_data <= 16'h0861; end
    if ( y == 4 && x == 46) begin oled_data <= 16'h0861; end
    if ( y == 4 && x == 50) begin oled_data <= 16'h0841; end
    if ( y == 4 && x == 93) begin oled_data <= 16'h0841; end
    if ( y == 4 && x == 94) begin oled_data <= 16'h31A6; end
    if ( y == 4 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 5 && x == 4) begin oled_data <= 16'h0861; end
    if ( y == 5 && x == 35) begin oled_data <= 16'h18C3; end
    if ( y == 5 && x == 36) begin oled_data <= 16'h0861; end
    if ( y == 5 && x == 40) begin oled_data <= 16'h0840; end
    if ( y == 5 && x == 41) begin oled_data <= 16'h0841; end
    if ( y == 5 && x == 42) begin oled_data <= 16'h0840; end
    if ( y == 5 && x == 43) begin oled_data <= 16'h0820; end
    if ( y == 5 && x == 63) begin oled_data <= 16'h0841; end
    if ( y == 5 && x == 93) begin oled_data <= 16'h0861; end
    if ( y == 5 && x == 94) begin oled_data <= 16'h18C3; end
    if ( y == 5 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 6 && x >= 16 && x <= 17) begin oled_data <= 16'h0841; end
    if ( y == 6 && x == 22) begin oled_data <= 16'h0841; end
    if ( y == 6 && x == 25) begin oled_data <= 16'h0841; end
    if ( y == 6 && x == 35) begin oled_data <= 16'h2985; end
    if ( y == 6 && x == 36) begin oled_data <= 16'h0861; end
    if ( y == 6 && x == 40) begin oled_data <= 16'h0861; end
    if ( y == 6 && x == 41) begin oled_data <= 16'h0840; end
    if ( y == 6 && x >= 42 && x <= 43) begin oled_data <= 16'h0841; end
    if ( y == 6 && x == 44) begin oled_data <= 16'h18E3; end
    if ( y == 6 && x == 45) begin oled_data <= 16'h0841; end
    if ( y == 6 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 7 && x == 18) begin oled_data <= 16'h0861; end
    if ( y == 7 && x == 40) begin oled_data <= 16'h0840; end
    if ( y == 7 && x == 41) begin oled_data <= 16'h18E3; end
    if ( y == 7 && x == 44) begin oled_data <= 16'h2945; end
    if ( y == 7 && x == 45) begin oled_data <= 16'h0841; end
    if ( y == 7 && x == 66) begin oled_data <= 16'h0841; end
    if ( y == 7 && x == 82) begin oled_data <= 16'h0841; end
    if ( y == 7 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 8 && x >= 16 && x <= 17) begin oled_data <= 16'h0841; end
    if ( y == 8 && x == 39) begin oled_data <= 16'h0840; end
    if ( y == 8 && x == 41) begin oled_data <= 16'h2124; end
    if ( y == 8 && x == 45) begin oled_data <= 16'h2103; end
    if ( y == 8 && x == 80) begin oled_data <= 16'h0841; end
    if ( y == 8 && x == 91) begin oled_data <= 16'h2104; end
    if ( y == 8 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 9 && x == 1) begin oled_data <= 16'h0841; end
    if ( y == 9 && x == 3) begin oled_data <= 16'h0841; end
    if ( y == 9 && x == 9) begin oled_data <= 16'h31A6; end
    if ( y == 9 && x == 10) begin oled_data <= 16'h0841; end
    if ( y == 9 && x == 13) begin oled_data <= 16'h0861; end
    if ( y == 9 && x == 21) begin oled_data <= 16'h0841; end
    if ( y == 9 && x == 42) begin oled_data <= 16'h0841; end
    if ( y == 9 && x == 45) begin oled_data <= 16'h2944; end
    if ( y == 9 && x == 46) begin oled_data <= 16'h0841; end
    if ( y == 9 && x == 49) begin oled_data <= 16'h0841; end
    if ( y == 9 && x == 73) begin oled_data <= 16'h0841; end
    if ( y == 9 && x == 91) begin oled_data <= 16'h2124; end
    if ( y == 9 && x == 94) begin oled_data <= 16'h0861; end
    if ( y == 9 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 10 && x == 9) begin oled_data <= 16'h0841; end
    if ( y == 10 && x == 19) begin oled_data <= 16'h0861; end
    if ( y == 10 && x == 44) begin oled_data <= 16'h0861; end
    if ( y == 10 && x == 46) begin oled_data <= 16'h2124; end
    if ( y == 10 && x == 47) begin oled_data <= 16'h0841; end
    if ( y == 10 && x == 50) begin oled_data <= 16'h2104; end
    if ( y == 10 && x == 51) begin oled_data <= 16'h18C3; end
    if ( y == 10 && x == 57) begin oled_data <= 16'h39C7; end
    if ( y == 10 && x == 58) begin oled_data <= 16'h0841; end
    if ( y == 10 && x == 61) begin oled_data <= 16'h0841; end
    if ( y == 10 && x >= 76 && x <= 77) begin oled_data <= 16'h0861; end
    if ( y == 10 && x == 86) begin oled_data <= 16'h0841; end
    if ( y == 10 && x == 87) begin oled_data <= 16'h2965; end
    if ( y == 10 && x == 88) begin oled_data <= 16'h0861; end
    if ( y == 10 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 11 && x == 34) begin oled_data <= 16'h0841; end
    if ( y == 11 && x == 44) begin oled_data <= 16'h0841; end
    if ( y == 11 && x == 46) begin oled_data <= 16'h2104; end
    if ( y == 11 && x == 47) begin oled_data <= 16'h0841; end
    if ( y == 11 && x == 50) begin oled_data <= 16'h18E3; end
    if ( y == 11 && x == 57) begin oled_data <= 16'h0841; end
    if ( y == 11 && x == 63) begin oled_data <= 16'h0861; end
    if ( y == 11 && x >= 76 && x <= 77) begin oled_data <= 16'h2124; end
    if ( y == 11 && x == 82) begin oled_data <= 16'h0861; end
    if ( y == 11 && x == 86) begin oled_data <= 16'h0841; end
    if ( y == 11 && x == 87) begin oled_data <= 16'h2124; end
    if ( y == 11 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 12 && x == 5) begin oled_data <= 16'h0861; end
    if ( y == 12 && x == 19) begin oled_data <= 16'h2145; end
    if ( y == 12 && x == 38) begin oled_data <= 16'h0841; end
    if ( y == 12 && x == 83) begin oled_data <= 16'h2986; end
    if ( y == 12 && x == 84) begin oled_data <= 16'h0861; end
    if ( y == 12 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 13 && x == 7) begin oled_data <= 16'h0841; end
    if ( y == 13 && x == 30) begin oled_data <= 16'h0841; end
    if ( y == 13 && x == 82) begin oled_data <= 16'h0861; end
    if ( y == 13 && x == 83) begin oled_data <= 16'h18E3; end
    if ( y == 13 && x == 94) begin oled_data <= 16'h0861; end
    if ( y == 13 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 14 && x == 1) begin oled_data <= 16'h0841; end
    if ( y == 14 && x == 4) begin oled_data <= 16'h0841; end
    if ( y == 14 && x == 24) begin oled_data <= 16'h0841; end
    if ( y == 14 && x == 25) begin oled_data <= 16'h0861; end
    if ( y == 14 && x == 30) begin oled_data <= 16'h2945; end
    if ( y == 14 && x == 53) begin oled_data <= 16'h0841; end
    if ( y == 14 && x == 68) begin oled_data <= 16'h0841; end
    if ( y == 14 && x == 80) begin oled_data <= 16'h0841; end
    if ( y == 14 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 15 && x == 1) begin oled_data <= 16'h0841; end
    if ( y == 15 && x == 2) begin oled_data <= 16'h2124; end
    if ( y == 15 && x == 3) begin oled_data <= 16'h18E3; end
    if ( y == 15 && x == 24) begin oled_data <= 16'h18C3; end
    if ( y == 15 && x == 25) begin oled_data <= 16'h2945; end
    if ( y == 15 && x >= 46 && x <= 47) begin oled_data <= 16'h0840; end
    if ( y == 15 && x == 52) begin oled_data <= 16'h2965; end
    if ( y == 15 && x == 61) begin oled_data <= 16'h31A6; end
    if ( y == 15 && x == 68) begin oled_data <= 16'h0841; end
    if ( y == 15 && x == 70) begin oled_data <= 16'h0841; end
    if ( y == 15 && x == 73) begin oled_data <= 16'h0861; end
    if ( y == 15 && x == 74) begin oled_data <= 16'h0841; end
    if ( y == 15 && x == 79) begin oled_data <= 16'h0841; end
    if ( y == 15 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 16 && x == 2) begin oled_data <= 16'h39E8; end
    if ( y == 16 && x == 3) begin oled_data <= 16'h2965; end
    if ( y == 16 && x == 7) begin oled_data <= 16'h0841; end
    if ( y == 16 && x == 20) begin oled_data <= 16'h0861; end
    if ( y == 16 && x == 24) begin oled_data <= 16'h0841; end
    if ( y == 16 && x == 38) begin oled_data <= 16'h0841; end
    if ( y == 16 && x == 46) begin oled_data <= 16'h2103; end
    if ( y == 16 && x == 47) begin oled_data <= 16'h2924; end
    if ( y == 16 && x == 61) begin oled_data <= 16'h0862; end
    if ( y == 16 && x == 69) begin oled_data <= 16'h0861; end
    if ( y == 16 && x == 70) begin oled_data <= 16'h0841; end
    if ( y == 16 && x == 73) begin oled_data <= 16'h2104; end
    if ( y == 16 && x == 74) begin oled_data <= 16'h0861; end
    if ( y == 16 && x == 82) begin oled_data <= 16'h18C3; end
    if ( y == 16 && x == 83) begin oled_data <= 16'h0841; end
    if ( y == 16 && x == 87) begin oled_data <= 16'h0861; end
    if ( y == 16 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 17 && x == 2) begin oled_data <= 16'h0861; end
    if ( y == 17 && x >= 3 && x <= 4) begin oled_data <= 16'h0841; end
    if ( y == 17 && x == 7) begin oled_data <= 16'h0841; end
    if ( y == 17 && x == 8) begin oled_data <= 16'h0861; end
    if ( y == 17 && x == 19) begin oled_data <= 16'h0861; end
    if ( y == 17 && x == 28) begin oled_data <= 16'h0841; end
    if ( y == 17 && x >= 36 && x <= 37) begin oled_data <= 16'h0840; end
    if ( y == 17 && x == 38) begin oled_data <= 16'h0861; end
    if ( y == 17 && x == 39) begin oled_data <= 16'h2104; end
    if ( y == 17 && x == 40) begin oled_data <= 16'h0841; end
    if ( y == 17 && x == 43) begin oled_data <= 16'h0861; end
    if ( y == 17 && x >= 46 && x <= 47) begin oled_data <= 16'h0861; end
    if ( y == 17 && x == 51) begin oled_data <= 16'h0840; end
    if ( y == 17 && x == 60) begin oled_data <= 16'h18E3; end
    if ( y == 17 && x == 73) begin oled_data <= 16'h2965; end
    if ( y == 17 && x == 81) begin oled_data <= 16'h0841; end
    if ( y == 17 && x == 82) begin oled_data <= 16'h2965; end
    if ( y == 17 && x == 88) begin oled_data <= 16'h2124; end
    if ( y == 17 && x == 94) begin oled_data <= 16'h39C7; end
    if ( y == 17 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 18 && x == 0) begin oled_data <= 16'h0841; end
    if ( y == 18 && x == 3) begin oled_data <= 16'h0841; end
    if ( y == 18 && x == 5) begin oled_data <= 16'h0841; end
    if ( y == 18 && x == 7) begin oled_data <= 16'h0841; end
    if ( y == 18 && x == 15) begin oled_data <= 16'h0841; end
    if ( y == 18 && x == 36) begin oled_data <= 16'h0861; end
    if ( y == 18 && x == 37) begin oled_data <= 16'h0841; end
    if ( y == 18 && x == 38) begin oled_data <= 16'h0861; end
    if ( y == 18 && x == 39) begin oled_data <= 16'h2945; end
    if ( y == 18 && x == 40) begin oled_data <= 16'h0861; end
    if ( y == 18 && x == 44) begin oled_data <= 16'h2124; end
    if ( y == 18 && x >= 45 && x <= 46) begin oled_data <= 16'h0840; end
    if ( y == 18 && x == 51) begin oled_data <= 16'h3185; end
    if ( y == 18 && x == 52) begin oled_data <= 16'h18C2; end
    if ( y == 18 && x == 60) begin oled_data <= 16'h2124; end
    if ( y == 18 && x == 81) begin oled_data <= 16'h0841; end
    if ( y == 18 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 19 && x == 7) begin oled_data <= 16'h0861; end
    if ( y == 19 && x == 8) begin oled_data <= 16'h0841; end
    if ( y == 19 && x == 16) begin oled_data <= 16'h18E3; end
    if ( y == 19 && x == 21) begin oled_data <= 16'h0861; end
    if ( y == 19 && x == 35) begin oled_data <= 16'h0861; end
    if ( y == 19 && x == 37) begin oled_data <= 16'h0841; end
    if ( y == 19 && x == 38) begin oled_data <= 16'h0861; end
    if ( y == 19 && x == 43) begin oled_data <= 16'h0841; end
    if ( y == 19 && x == 45) begin oled_data <= 16'h0841; end
    if ( y == 19 && x == 49) begin oled_data <= 16'h0840; end
    if ( y == 19 && x == 50) begin oled_data <= 16'h18C2; end
    if ( y == 19 && x == 51) begin oled_data <= 16'hA512; end
    if ( y == 19 && x == 52) begin oled_data <= 16'h736C; end
    if ( y == 19 && x == 54) begin oled_data <= 16'h0841; end
    if ( y == 19 && x == 79) begin oled_data <= 16'h0861; end
    if ( y == 19 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 20 && x == 3) begin oled_data <= 16'h0841; end
    if ( y == 20 && x == 15) begin oled_data <= 16'h0881; end
    if ( y == 20 && x == 16) begin oled_data <= 16'h18C3; end
    if ( y == 20 && x == 20) begin oled_data <= 16'h0841; end
    if ( y == 20 && x == 21) begin oled_data <= 16'h0840; end
    if ( y == 20 && x >= 35 && x <= 36) begin oled_data <= 16'h0840; end
    if ( y == 20 && x == 38) begin oled_data <= 16'h0861; end
    if ( y == 20 && x == 39) begin oled_data <= 16'h0840; end
    if ( y == 20 && x == 51) begin oled_data <= 16'h39A5; end
    if ( y == 20 && x == 55) begin oled_data <= 16'h0861; end
    if ( y == 20 && x == 71) begin oled_data <= 16'h0841; end
    if ( y == 20 && x == 75) begin oled_data <= 16'h0841; end
    if ( y == 20 && x >= 78 && x <= 79) begin oled_data <= 16'h0841; end
    if ( y == 20 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 21 && x == 27) begin oled_data <= 16'h0861; end
    if ( y == 21 && x == 34) begin oled_data <= 16'h0841; end
    if ( y == 21 && x == 35) begin oled_data <= 16'h0840; end
    if ( y == 21 && x == 36) begin oled_data <= 16'h0841; end
    if ( y == 21 && x == 37) begin oled_data <= 16'h2965; end
    if ( y == 21 && x == 38) begin oled_data <= 16'h0841; end
    if ( y == 21 && x == 51) begin oled_data <= 16'h0840; end
    if ( y == 21 && x == 54) begin oled_data <= 16'h3186; end
    if ( y == 21 && x == 55) begin oled_data <= 16'h0861; end
    if ( y == 21 && x == 64) begin oled_data <= 16'h0841; end
    if ( y == 21 && x == 66) begin oled_data <= 16'h0841; end
    if ( y == 21 && x == 67) begin oled_data <= 16'h39C7; end
    if ( y == 21 && x == 68) begin oled_data <= 16'h0861; end
    if ( y == 21 && x == 78) begin oled_data <= 16'h0861; end
    if ( y == 21 && x == 80) begin oled_data <= 16'h0841; end
    if ( y == 21 && x == 89) begin oled_data <= 16'h0861; end
    if ( y == 21 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 22 && x == 6) begin oled_data <= 16'h0861; end
    if ( y == 22 && x == 27) begin oled_data <= 16'h0841; end
    if ( y == 22 && x == 28) begin oled_data <= 16'h0861; end
    if ( y == 22 && x == 34) begin oled_data <= 16'h0841; end
    if ( y == 22 && x == 36) begin oled_data <= 16'h0841; end
    if ( y == 22 && x == 37) begin oled_data <= 16'h18E3; end
    if ( y == 22 && x == 49) begin oled_data <= 16'h0841; end
    if ( y == 22 && x >= 66 && x <= 68) begin oled_data <= 16'h0841; end
    if ( y == 22 && x == 77) begin oled_data <= 16'h0841; end
    if ( y == 22 && x == 79) begin oled_data <= 16'h3186; end
    if ( y == 22 && x == 80) begin oled_data <= 16'h0841; end
    if ( y == 22 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 23 && x == 17) begin oled_data <= 16'h0840; end
    if ( y == 23 && x == 21) begin oled_data <= 16'h0841; end
    if ( y == 23 && x == 22) begin oled_data <= 16'h0820; end
    if ( y == 23 && x == 24) begin oled_data <= 16'h0841; end
    if ( y == 23 && x == 35) begin oled_data <= 16'h0861; end
    if ( y == 23 && x == 78) begin oled_data <= 16'h0861; end
    if ( y == 23 && x == 79) begin oled_data <= 16'h18E3; end
    if ( y == 23 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 24 && x == 16) begin oled_data <= 16'h0861; end
    if ( y == 24 && x == 21) begin oled_data <= 16'h2103; end
    if ( y == 24 && x == 28) begin oled_data <= 16'h0841; end
    if ( y == 24 && x == 29) begin oled_data <= 16'h3185; end
    if ( y == 24 && x == 39) begin oled_data <= 16'h0861; end
    if ( y == 24 && x == 42) begin oled_data <= 16'h0861; end
    if ( y == 24 && x == 43) begin oled_data <= 16'h18A2; end
    if ( y == 24 && x == 44) begin oled_data <= 16'h0840; end
    if ( y == 24 && x == 58) begin oled_data <= 16'h0841; end
    if ( y == 24 && x == 63) begin oled_data <= 16'h0841; end
    if ( y == 24 && x == 80) begin oled_data <= 16'h0841; end
    if ( y == 24 && x == 82) begin oled_data <= 16'h0841; end
    if ( y == 24 && x >= 89 && x <= 90) begin oled_data <= 16'h0861; end
    if ( y == 24 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 25 && x == 14) begin oled_data <= 16'h0861; end
    if ( y == 25 && x == 40) begin oled_data <= 16'h0841; end
    if ( y == 25 && x == 43) begin oled_data <= 16'h2945; end
    if ( y == 25 && x == 44) begin oled_data <= 16'h0840; end
    if ( y == 25 && x == 72) begin oled_data <= 16'h0841; end
    if ( y == 25 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 26 && x == 13) begin oled_data <= 16'h2945; end
    if ( y == 26 && x == 22) begin oled_data <= 16'h0841; end
    if ( y == 26 && x == 23) begin oled_data <= 16'h2944; end
    if ( y == 26 && x == 27) begin oled_data <= 16'h0841; end
    if ( y == 26 && x >= 38 && x <= 40) begin oled_data <= 16'h0841; end
    if ( y == 26 && x >= 41 && x <= 42) begin oled_data <= 16'h0820; end
    if ( y == 26 && x == 44) begin oled_data <= 16'h0840; end
    if ( y == 26 && x == 64) begin oled_data <= 16'h0841; end
    if ( y == 26 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 27 && x == 7) begin oled_data <= 16'h0841; end
    if ( y == 27 && x == 27) begin oled_data <= 16'h0840; end
    if ( y == 27 && x == 38) begin oled_data <= 16'h0841; end
    if ( y == 27 && x == 39) begin oled_data <= 16'h3185; end
    if ( y == 27 && x == 41) begin oled_data <= 16'h0861; end
    if ( y == 27 && x == 71) begin oled_data <= 16'h31A6; end
    if ( y == 27 && x >= 86 && x <= 87) begin oled_data <= 16'h0841; end
    if ( y == 27 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 28 && x == 11) begin oled_data <= 16'h0841; end
    if ( y == 28 && x == 26) begin oled_data <= 16'h0861; end
    if ( y == 28 && x == 39) begin oled_data <= 16'h0841; end
    if ( y == 28 && x == 40) begin oled_data <= 16'h0840; end
    if ( y == 28 && x == 41) begin oled_data <= 16'h2103; end
    if ( y == 28 && x == 71) begin oled_data <= 16'h0861; end
    if ( y == 28 && x == 91) begin oled_data <= 16'h0841; end
    if ( y == 28 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 29 && x == 15) begin oled_data <= 16'h18C3; end
    if ( y == 29 && x == 16) begin oled_data <= 16'h2124; end
    if ( y == 29 && x == 18) begin oled_data <= 16'h0861; end
    if ( y == 29 && x == 24) begin oled_data <= 16'h0820; end
    if ( y == 29 && x == 25) begin oled_data <= 16'h0840; end
    if ( y == 29 && x == 26) begin oled_data <= 16'h62EA; end
    if ( y == 29 && x == 27) begin oled_data <= 16'h83CE; end
    if ( y == 29 && x == 29) begin oled_data <= 16'h0840; end
    if ( y == 29 && x == 30) begin oled_data <= 16'h0820; end
    if ( y == 29 && x == 31) begin oled_data <= 16'h0861; end
    if ( y == 29 && x == 41) begin oled_data <= 16'h2103; end
    if ( y == 29 && x == 43) begin oled_data <= 16'h0840; end
    if ( y == 29 && x == 52) begin oled_data <= 16'h0861; end
    if ( y == 29 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 30 && x == 6) begin oled_data <= 16'h0841; end
    if ( y == 30 && x == 16) begin oled_data <= 16'h18E3; end
    if ( y == 30 && x == 17) begin oled_data <= 16'h0821; end
    if ( y == 30 && x == 25) begin oled_data <= 16'h0840; end
    if ( y == 30 && x == 26) begin oled_data <= 16'h5AAA; end
    if ( y == 30 && x == 27) begin oled_data <= 16'h7B8D; end
    if ( y == 30 && x == 29) begin oled_data <= 16'h0820; end
    if ( y == 30 && x == 30) begin oled_data <= 16'h0821; end
    if ( y == 30 && x == 32) begin oled_data <= 16'h0841; end
    if ( y == 30 && x == 50) begin oled_data <= 16'h0861; end
    if ( y == 30 && x == 68) begin oled_data <= 16'h0841; end
    if ( y == 30 && x == 88) begin oled_data <= 16'h2945; end
    if ( y == 30 && x == 89) begin oled_data <= 16'h18C3; end
    if ( y == 30 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 31 && x == 12) begin oled_data <= 16'h0841; end
    if ( y == 31 && x == 26) begin oled_data <= 16'h0841; end
    if ( y == 31 && x == 30) begin oled_data <= 16'h0841; end
    if ( y == 31 && x == 31) begin oled_data <= 16'h3186; end
    if ( y == 31 && x == 37) begin oled_data <= 16'h0841; end
    if ( y == 31 && x == 51) begin oled_data <= 16'h31A6; end
    if ( y == 31 && x == 59) begin oled_data <= 16'h0861; end
    if ( y == 31 && x == 73) begin oled_data <= 16'h3186; end
    if ( y == 31 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 32 && x == 12) begin oled_data <= 16'h0841; end
    if ( y == 32 && x == 22) begin oled_data <= 16'h0841; end
    if ( y == 32 && x >= 29 && x <= 30) begin oled_data <= 16'h0841; end
    if ( y == 32 && x == 31) begin oled_data <= 16'h0840; end
    if ( y == 32 && x == 32) begin oled_data <= 16'h0841; end
    if ( y == 32 && x == 39) begin oled_data <= 16'h0861; end
    if ( y == 32 && x == 55) begin oled_data <= 16'h31A6; end
    if ( y == 32 && x == 56) begin oled_data <= 16'h0841; end
    if ( y == 32 && x == 73) begin oled_data <= 16'h18E3; end
    if ( y == 32 && x == 74) begin oled_data <= 16'h0841; end
    if ( y == 32 && x >= 87 && x <= 88) begin oled_data <= 16'h0841; end
    if ( y == 32 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 33 && x == 10) begin oled_data <= 16'h2124; end
    if ( y == 33 && x == 11) begin oled_data <= 16'h2104; end
    if ( y == 33 && x == 19) begin oled_data <= 16'h0861; end
    if ( y == 33 && x == 20) begin oled_data <= 16'h31A6; end
    if ( y == 33 && x == 33) begin oled_data <= 16'h2965; end
    if ( y == 33 && x == 55) begin oled_data <= 16'h18C3; end
    if ( y == 33 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 34 && x == 25) begin oled_data <= 16'h0861; end
    if ( y == 34 && x == 26) begin oled_data <= 16'h18C3; end
    if ( y == 34 && x == 27) begin oled_data <= 16'h0841; end
    if ( y == 34 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 35 && x == 25) begin oled_data <= 16'h18C3; end
    if ( y == 35 && x == 26) begin oled_data <= 16'h2945; end
    if ( y == 35 && x == 29) begin oled_data <= 16'h0841; end
    if ( y == 35 && x == 42) begin oled_data <= 16'h0841; end
    if ( y == 35 && x == 47) begin oled_data <= 16'h0861; end
    if ( y == 35 && x >= 83 && x <= 84) begin oled_data <= 16'h0841; end
    if ( y == 35 && x == 87) begin oled_data <= 16'h0841; end
    if ( y == 35 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 36 && x == 3) begin oled_data <= 16'h3186; end
    if ( y == 36 && x == 4) begin oled_data <= 16'h18E3; end
    if ( y == 36 && x >= 21 && x <= 23) begin oled_data <= 16'h0841; end
    if ( y == 36 && x == 41) begin oled_data <= 16'h0841; end
    if ( y == 36 && x == 63) begin oled_data <= 16'h39C7; end
    if ( y == 36 && x == 83) begin oled_data <= 16'h0861; end
    if ( y == 36 && x == 84) begin oled_data <= 16'h0841; end
    if ( y == 36 && x == 85) begin oled_data <= 16'h0861; end
    if ( y == 36 && x == 94) begin oled_data <= 16'h0841; end
    if ( y == 36 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 37 && x >= 2 && x <= 3) begin oled_data <= 16'h0861; end
    if ( y == 37 && x == 22) begin oled_data <= 16'h3186; end
    if ( y == 37 && x == 23) begin oled_data <= 16'h18E3; end
    if ( y == 37 && x == 36) begin oled_data <= 16'h39C7; end
    if ( y == 37 && x == 40) begin oled_data <= 16'h0841; end
    if ( y == 37 && x == 42) begin oled_data <= 16'h0841; end
    if ( y == 37 && x == 44) begin oled_data <= 16'h0841; end
    if ( y == 37 && x == 63) begin oled_data <= 16'h0861; end
    if ( y == 37 && x == 83) begin oled_data <= 16'h0841; end
    if ( y == 37 && x == 84) begin oled_data <= 16'h39E7; end
    if ( y == 37 && x == 85) begin oled_data <= 16'h0861; end
    if ( y == 37 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 38 && x == 6) begin oled_data <= 16'h0841; end
    if ( y == 38 && x >= 13 && x <= 14) begin oled_data <= 16'h0841; end
    if ( y == 38 && x == 22) begin oled_data <= 16'h0861; end
    if ( y == 38 && x == 36) begin oled_data <= 16'h0861; end
    if ( y == 38 && x == 40) begin oled_data <= 16'h0841; end
    if ( y == 38 && x == 83) begin oled_data <= 16'h0841; end
    if ( y == 38 && x == 84) begin oled_data <= 16'h0861; end
    if ( y == 38 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 39 && x == 6) begin oled_data <= 16'h0841; end
    if ( y == 39 && x == 14) begin oled_data <= 16'h0861; end
    if ( y == 39 && x >= 39 && x <= 40) begin oled_data <= 16'h0861; end
    if ( y == 39 && x == 41) begin oled_data <= 16'h0841; end
    if ( y == 39 && x == 42) begin oled_data <= 16'h0840; end
    if ( y == 39 && x == 59) begin oled_data <= 16'h0841; end
    if ( y == 39 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 40 && x == 14) begin oled_data <= 16'h0861; end
    if ( y == 40 && x == 15) begin oled_data <= 16'h0841; end
    if ( y == 40 && x == 26) begin oled_data <= 16'h0861; end
    if ( y == 40 && x == 38) begin oled_data <= 16'h0841; end
    if ( y == 40 && x == 40) begin oled_data <= 16'h0861; end
    if ( y == 40 && x == 53) begin oled_data <= 16'h0841; end
    if ( y == 40 && x == 54) begin oled_data <= 16'h2965; end
    if ( y == 40 && x == 55) begin oled_data <= 16'h0861; end
    if ( y == 40 && x == 63) begin oled_data <= 16'h0841; end
    if ( y == 40 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 41 && x == 13) begin oled_data <= 16'h0841; end
    if ( y == 41 && x == 14) begin oled_data <= 16'h0861; end
    if ( y == 41 && x == 16) begin oled_data <= 16'h18E3; end
    if ( y == 41 && x == 17) begin oled_data <= 16'h2945; end
    if ( y == 41 && x == 19) begin oled_data <= 16'h0841; end
    if ( y == 41 && x == 20) begin oled_data <= 16'h0861; end
    if ( y == 41 && x == 21) begin oled_data <= 16'h0841; end
    if ( y == 41 && x == 25) begin oled_data <= 16'h31A6; end
    if ( y == 41 && x == 26) begin oled_data <= 16'h0861; end
    if ( y == 41 && x == 38) begin oled_data <= 16'h0841; end
    if ( y == 41 && x == 53) begin oled_data <= 16'h0841; end
    if ( y == 41 && x == 54) begin oled_data <= 16'h2104; end
    if ( y == 41 && x == 55) begin oled_data <= 16'h0841; end
    if ( y == 41 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 42 && x >= 13 && x <= 14) begin oled_data <= 16'h0841; end
    if ( y == 42 && x == 19) begin oled_data <= 16'h0841; end
    if ( y == 42 && x == 21) begin oled_data <= 16'h0841; end
    if ( y == 42 && x == 39) begin oled_data <= 16'h0861; end
    if ( y == 42 && x == 48) begin oled_data <= 16'h0861; end
    if ( y == 42 && x == 53) begin oled_data <= 16'h0841; end
    if ( y == 42 && x == 57) begin oled_data <= 16'h0841; end
    if ( y == 42 && x == 81) begin oled_data <= 16'h0841; end
    if ( y == 42 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 43 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 44 && x == 34) begin oled_data <= 16'h0841; end
    if ( y == 44 && x == 44) begin oled_data <= 16'h0841; end
    if ( y == 44 && x == 53) begin oled_data <= 16'h18E3; end
    if ( y == 44 && x == 69) begin oled_data <= 16'h18C3; end
    if ( y == 44 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 45 && x == 53) begin oled_data <= 16'h2965; end
    if ( y == 45 && x == 69) begin oled_data <= 16'h2124; end
    if ( y == 45 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 46 && x == 4) begin oled_data <= 16'h0841; end
    if ( y == 46 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 47 && x == 52) begin oled_data <= 16'h0841; end
    if ( y == 47 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 48 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 49 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 50 && x == 9) begin oled_data <= 16'h0841; end
    if ( y == 50 && x == 17) begin oled_data <= 16'h0841; end
    if ( y == 50 && x == 39) begin oled_data <= 16'h0841; end
    if ( y == 50 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 51 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 52 && x >= 65 && x <= 66) begin oled_data <= 16'h0841; end
    if ( y == 52 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 53 && x == 65) begin oled_data <= 16'h0841; end
    if ( y == 53 && x == 67) begin oled_data <= 16'h0861; end
    if ( y == 53 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 54 && x == 37) begin oled_data <= 16'h0841; end
    if ( y == 54 && x == 38) begin oled_data <= 16'h18E3; end
    if ( y == 54 && x == 39) begin oled_data <= 16'h0841; end
    if ( y == 54 && x == 66) begin oled_data <= 16'h0841; end
    if ( y == 54 && x == 80) begin oled_data <= 16'h0861; end
    if ( y == 54 && x == 86) begin oled_data <= 16'h0861; end
    if ( y == 54 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 55 && x == 23) begin oled_data <= 16'h0861; end
    if ( y == 55 && x == 30) begin oled_data <= 16'h0841; end
    if ( y == 55 && x == 37) begin oled_data <= 16'h0841; end
    if ( y == 55 && x == 38) begin oled_data <= 16'h2965; end
    if ( y == 55 && x == 40) begin oled_data <= 16'h0841; end
    if ( y == 55 && x == 47) begin oled_data <= 16'h0861; end
    if ( y == 55 && x == 48) begin oled_data <= 16'h0841; end
    if ( y == 55 && x == 80) begin oled_data <= 16'h0841; end
    if ( y == 55 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 56 && x == 15) begin oled_data <= 16'h0841; end
    if ( y == 56 && x == 23) begin oled_data <= 16'h0861; end
    if ( y == 56 && x == 79) begin oled_data <= 16'h0861; end
    if ( y == 56 && x == 80) begin oled_data <= 16'h7BEF; end
    if ( y == 56 && x == 81) begin oled_data <= 16'h4A8A; end
    if ( y == 56 && x == 91) begin oled_data <= 16'h0841; end
    if ( y == 56 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 57 && x == 78) begin oled_data <= 16'h0841; end
    if ( y == 57 && x == 79) begin oled_data <= 16'h0881; end
    if ( y == 57 && x == 80) begin oled_data <= 16'h8C71; end
    if ( y == 57 && x == 81) begin oled_data <= 16'h52CA; end
    if ( y == 57 && x == 89) begin oled_data <= 16'h0861; end
    if ( y == 57 && x == 90) begin oled_data <= 16'h2945; end
    if ( y == 57 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 58 && x == 58) begin oled_data <= 16'h2945; end
    if ( y == 58 && x == 59) begin oled_data <= 16'h2104; end
    if ( y == 58 && x == 89) begin oled_data <= 16'h0841; end
    if ( y == 58 && x == 90) begin oled_data <= 16'h2124; end
    if ( y == 58 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 59 && x == 58) begin oled_data <= 16'h0841; end
    if ( y == 59 && x == 80) begin oled_data <= 16'h0841; end
    if ( y == 59 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 60 && x >= 85 && x <= 86) begin oled_data <= 16'h0841; end
    if ( y == 60 && x == 95) begin oled_data <= 16'hF79E; end
    if ( y == 61 && x == 29) begin oled_data <= 16'h0861; end
    if ( y == 61 && x == 95) begin oled_data <= 16'hF79E; end
    if ( x == 95 ) begin oled_data <= 16'h0000; end
    
    //start game
    virus_clock <= virus_clock + 1;
    if(virus_clock == 19'd375000)
    begin
        if (dead == 0 && gameStart == 1)
        begin
            if (virus_counter < 69 && sw[15] == 0)
            begin
                virus_counter <= virus_counter + 1;
            end
            if (virus_counter == 69)
            begin
                dead <= 1; //megaman dead
                gameStart <= 0;
                virus_counter <= 69;
            end
        end
        virus_clock <= 0;
    end
    
    if (dead == 0 && gameStart == 1)
    begin
    //virus image
        if ( y == 28 && x == ( 102 - virus_counter) ) begin oled_data <= 16'h0941; end
        if ( y == 28 && x == ( 103 - virus_counter) ) begin oled_data <= 16'h2204; end
        if ( y == 29 && x == ( 102 - virus_counter) ) begin oled_data <= 16'h0A21; end
        if ( y == 29 && x == ( 103 - virus_counter) ) begin oled_data <= 16'h43E8; end
        if ( y == 30 && x == ( 100 - virus_counter) ) begin oled_data <= 16'h33C6; end
        if ( y == 30 && x == ( 102 - virus_counter) ) begin oled_data <= 16'h01E0; end
        if ( y == 30 && x == ( 103 - virus_counter) ) begin oled_data <= 16'h1B63; end
        if ( y == 30 && x == ( 105 - virus_counter) ) begin oled_data <= 16'h3B27; end
        if ( y == 30 && x == ( 106 - virus_counter) ) begin oled_data <= 16'h19A4; end
        if ( y == 31 && x == ( 97 - virus_counter) ) begin oled_data <= 16'h3286; end
        if ( y == 31 && x == ( 98 - virus_counter) ) begin oled_data <= 16'h544A; end
        if ( y == 31 && x == ( 99 - virus_counter) ) begin oled_data <= 16'h01C0; end
        if ( y == 31 && x == ( 100 - virus_counter) ) begin oled_data <= 16'h02E0; end
        if ( y == 31 && x == ( 101 - virus_counter) ) begin oled_data <= 16'h2504; end
        if ( y == 31 && x == ( 102 - virus_counter) ) begin oled_data <= 16'h1CC3; end
        if ( y == 31 && x == ( 103 - virus_counter) ) begin oled_data <= 16'h2CE4; end
        if ( y == 31 && x == ( 105 - virus_counter) ) begin oled_data <= 16'h2C05; end
        if ( y == 31 && x == ( 106 - virus_counter) ) begin oled_data <= 16'h0140; end
        if ( y == 32 && x == ( 98 - virus_counter) ) begin oled_data <= 16'h01A0; end
        if ( y == 32 && x == ( 99 - virus_counter) ) begin oled_data <= 16'h1C44; end
        if ( y == 32 && x == ( 100 - virus_counter) ) begin oled_data <= 16'h2544; end
        if ( y == 32 && x == ( 101 - virus_counter) ) begin oled_data <= 16'h25A4; end
        if ( y == 32 && x == ( 102 - virus_counter) ) begin oled_data <= 16'h77EE; end
        if ( y == 32 && x == ( 103 - virus_counter) ) begin oled_data <= 16'h6FAD; end
        if ( y == 32 && x == ( 104 - virus_counter) ) begin oled_data <= 16'h2DC5; end
        if ( y == 32 && x == ( 105 - virus_counter) ) begin oled_data <= 16'h1422; end
        if ( y == 32 && x == ( 107 - virus_counter) ) begin oled_data <= 16'h19E3; end
        if ( y == 32 && x == ( 108 - virus_counter) ) begin oled_data <= 16'h4328; end
        if ( y == 33 && x >= ( 97 - virus_counter ) && x <= ( 98 - virus_counter) ) begin oled_data <= 16'h01C0; end
        if ( y == 33 && x == ( 99 - virus_counter) ) begin oled_data <= 16'h03A0; end
        if ( y == 33 && x == ( 100 - virus_counter) ) begin oled_data <= 16'h2DC5; end
        if ( y == 33 && x == ( 101 - virus_counter) ) begin oled_data <= 16'h1562; end
        if ( y == 33 && x == ( 102 - virus_counter) ) begin oled_data <= 16'h67CC; end
        if ( y == 33 && x == ( 103 - virus_counter) ) begin oled_data <= 16'h678C; end
        if ( y == 33 && x == ( 104 - virus_counter) ) begin oled_data <= 16'h25C4; end
        if ( y == 33 && x == ( 105 - virus_counter) ) begin oled_data <= 16'h3DC7; end
        if ( y == 33 && x == ( 106 - virus_counter) ) begin oled_data <= 16'h3446; end
        if ( y == 33 && x == ( 107 - virus_counter) ) begin oled_data <= 16'h2B05; end
        if ( y == 33 && x == ( 108 - virus_counter) ) begin oled_data <= 16'h2A85; end
        if ( y == 34 && x == ( 97 - virus_counter) ) begin oled_data <= 16'h3B67; end
        if ( y == 34 && x == ( 98 - virus_counter) ) begin oled_data <= 16'h2BE5; end
        if ( y == 34 && x == ( 99 - virus_counter) ) begin oled_data <= 16'h2484; end
        if ( y == 34 && x == ( 100 - virus_counter) ) begin oled_data <= 16'h4EC9; end
        if ( y == 34 && x == ( 101 - virus_counter) ) begin oled_data <= 16'h77EE; end
        if ( y == 34 && x >= ( 102 - virus_counter ) && x <= ( 103 - virus_counter) ) begin oled_data <= 16'h1D63; end
        if ( y == 34 && x == ( 104 - virus_counter) ) begin oled_data <= 16'h67EC; end
        if ( y == 34 && x == ( 105 - virus_counter) ) begin oled_data <= 16'h5F4B; end
        if ( y == 34 && x == ( 106 - virus_counter) ) begin oled_data <= 16'h02E0; end
        if ( y == 35 && x == ( 99 - virus_counter) ) begin oled_data <= 16'h0360; end
        if ( y == 35 && x == ( 100 - virus_counter) ) begin oled_data <= 16'h46A8; end
        if ( y == 35 && x == ( 101 - virus_counter) ) begin oled_data <= 16'h3EE7; end
        if ( y == 35 && x == ( 102 - virus_counter) ) begin oled_data <= 16'h3E27; end
        if ( y == 35 && x == ( 103 - virus_counter) ) begin oled_data <= 16'h3606; end
        if ( y == 35 && x == ( 104 - virus_counter) ) begin oled_data <= 16'h2603; end
        if ( y == 35 && x == ( 105 - virus_counter) ) begin oled_data <= 16'h2E05; end
        if ( y == 35 && x == ( 106 - virus_counter) ) begin oled_data <= 16'h2484; end
        if ( y == 36 && x == ( 98 - virus_counter) ) begin oled_data <= 16'h01C0; end
        if ( y == 36 && x == ( 99 - virus_counter) ) begin oled_data <= 16'h3446; end
        if ( y == 36 && x == ( 100 - virus_counter) ) begin oled_data <= 16'h2D65; end
        if ( y == 36 && x == ( 101 - virus_counter) ) begin oled_data <= 16'h1D83; end
        if ( y == 36 && x == ( 102 - virus_counter) ) begin oled_data <= 16'h7FEF; end
        if ( y == 36 && x == ( 103 - virus_counter) ) begin oled_data <= 16'h6F8D; end
        if ( y == 36 && x == ( 104 - virus_counter) ) begin oled_data <= 16'h2DE5; end
        if ( y == 36 && x == ( 105 - virus_counter) ) begin oled_data <= 16'h14C2; end
        if ( y == 36 && x == ( 106 - virus_counter) ) begin oled_data <= 16'h0240; end
        if ( y == 36 && x == ( 107 - virus_counter) ) begin oled_data <= 16'h3386; end
        if ( y == 36 && x == ( 108 - virus_counter) ) begin oled_data <= 16'h4BA9; end
        if ( y == 37 && x == ( 97 - virus_counter) ) begin oled_data <= 16'h4328; end
        if ( y == 37 && x == ( 98 - virus_counter) ) begin oled_data <= 16'h4BA9; end
        if ( y == 37 && x == ( 99 - virus_counter) ) begin oled_data <= 16'h0180; end
        if ( y == 37 && x == ( 100 - virus_counter) ) begin oled_data <= 16'h0240; end
        if ( y == 37 && x == ( 101 - virus_counter) ) begin oled_data <= 16'h2D25; end
        if ( y == 37 && x == ( 102 - virus_counter) ) begin oled_data <= 16'h3566; end
        if ( y == 37 && x == ( 103 - virus_counter) ) begin oled_data <= 16'h3D67; end
        if ( y == 37 && x == ( 104 - virus_counter) ) begin oled_data <= 16'h1402; end
        if ( y == 37 && x == ( 105 - virus_counter) ) begin oled_data <= 16'h2424; end
        if ( y == 37 && x == ( 106 - virus_counter) ) begin oled_data <= 16'h0220; end
        if ( y == 38 && x == ( 97 - virus_counter) ) begin oled_data <= 16'h0961; end
        if ( y == 38 && x == ( 100 - virus_counter) ) begin oled_data <= 16'h2364; end
        if ( y == 38 && x == ( 101 - virus_counter) ) begin oled_data <= 16'h1363; end
        if ( y == 38 && x == ( 102 - virus_counter) ) begin oled_data <= 16'h01A0; end
        if ( y == 38 && x == ( 103 - virus_counter) ) begin oled_data <= 16'h2404; end
        if ( y == 38 && x == ( 104 - virus_counter) ) begin oled_data <= 16'h0160; end
        if ( y == 38 && x == ( 105 - virus_counter) ) begin oled_data <= 16'h1282; end
        if ( y == 38 && x == ( 106 - virus_counter) ) begin oled_data <= 16'h32C6; end
        if ( y == 39 && x == ( 100 - virus_counter) ) begin oled_data <= 16'h2A85; end
        if ( y == 39 && x == ( 101 - virus_counter) ) begin oled_data <= 16'h01C0; end
        if ( y == 39 && x == ( 103 - virus_counter) ) begin oled_data <= 16'h22E4; end
        if ( y == 39 && x == ( 104 - virus_counter) ) begin oled_data <= 16'h2B25; end
        if ( y == 40 && x == ( 103 - virus_counter) ) begin oled_data <= 16'h19C3; end
        if ( y == 40 && x == ( 104 - virus_counter) ) begin oled_data <= 16'h3286; end 
        
        if(led_count == 0) //standing stance
        begin
        if ( y == 20 && x == 15) begin oled_data <= 16'h324C; end
        if ( y == 20 && x == 16) begin oled_data <= 16'h32AF; end
        if ( y == 20 && x == 17) begin oled_data <= 16'h4352; end
        if ( y == 20 && x == 18) begin oled_data <= 16'h5434; end
        if ( y == 20 && x == 19) begin oled_data <= 16'h53F2; end
        if ( y == 20 && x == 20) begin oled_data <= 16'h0946; end
        if ( y == 21 && x == 13) begin oled_data <= 16'h0883; end
        if ( y == 21 && x == 14) begin oled_data <= 16'h29CB; end
        if ( y == 21 && x == 15) begin oled_data <= 16'h19CD; end
        if ( y == 21 && x == 16) begin oled_data <= 16'h11EF; end
        if ( y == 21 && x == 17) begin oled_data <= 16'h22B2; end
        if ( y == 21 && x == 18) begin oled_data <= 16'h3353; end
        if ( y == 21 && x == 19) begin oled_data <= 16'h7559; end
        if ( y == 21 && x == 20) begin oled_data <= 16'h74F5; end
        if ( y == 21 && x == 21) begin oled_data <= 16'h1166; end
        if ( y == 22 && x == 13) begin oled_data <= 16'h29CB; end
        if ( y == 22 && x == 14) begin oled_data <= 16'h198F; end
        if ( y == 22 && x == 15) begin oled_data <= 16'h09D3; end
        if ( y == 22 && x == 16) begin oled_data <= 16'h1AD8; end
        if ( y == 22 && x == 17) begin oled_data <= 16'h239A; end
        if ( y == 22 && x == 18) begin oled_data <= 16'h12F6; end
        if ( y == 22 && x == 19) begin oled_data <= 16'h1292; end
        if ( y == 22 && x == 20) begin oled_data <= 16'h85DC; end
        if ( y == 22 && x == 21) begin oled_data <= 16'h7516; end
        if ( y == 22 && x == 22) begin oled_data <= 16'h08C4; end
        if ( y == 23 && x == 12) begin oled_data <= 16'h08A4; end
        if ( y == 23 && x == 13) begin oled_data <= 16'h21CC; end
        if ( y == 23 && x == 14) begin oled_data <= 16'h19B2; end
        if ( y == 23 && x == 15) begin oled_data <= 16'h11F5; end
        if ( y == 23 && x == 16) begin oled_data <= 16'h0A98; end
        if ( y == 23 && x == 17) begin oled_data <= 16'h133A; end
        if ( y == 23 && x == 18) begin oled_data <= 16'h1B59; end
        if ( y == 23 && x == 19) begin oled_data <= 16'h0232; end
        if ( y == 23 && x == 20) begin oled_data <= 16'h4373; end
        if ( y == 23 && x == 21) begin oled_data <= 16'h9DD9; end
        if ( y == 23 && x == 22) begin oled_data <= 16'h31E9; end
        if ( y == 24 && x == 12) begin oled_data <= 16'h1947; end
        if ( y == 24 && x == 13) begin oled_data <= 16'h21AC; end
        if ( y == 24 && x == 14) begin oled_data <= 16'h19D0; end
        if ( y == 24 && x == 15) begin oled_data <= 16'h2295; end
        if ( y == 24 && x == 16) begin oled_data <= 16'h2B79; end
        if ( y == 24 && x == 17) begin oled_data <= 16'h3C3C; end
        if ( y == 24 && x == 18) begin oled_data <= 16'h33BA; end
        if ( y == 24 && x == 19) begin oled_data <= 16'h11D0; end
        if ( y == 24 && x == 20) begin oled_data <= 16'h4A8F; end
        if ( y == 24 && x == 21) begin oled_data <= 16'h6AEE; end
        if ( y == 25 && x == 12) begin oled_data <= 16'h2968; end
        if ( y == 25 && x == 13) begin oled_data <= 16'h2149; end
        if ( y == 25 && x == 14) begin oled_data <= 16'h29CD; end
        if ( y == 25 && x == 15) begin oled_data <= 16'h5BD6; end
        if ( y == 25 && x == 16) begin oled_data <= 16'h74FB; end
        if ( y == 25 && x == 17) begin oled_data <= 16'h64DB; end
        if ( y == 25 && x == 18) begin oled_data <= 16'h6CFD; end
        if ( y == 25 && x == 19) begin oled_data <= 16'h3AD3; end
        if ( y == 25 && x == 20) begin oled_data <= 16'h62AF; end
        if ( y == 25 && x == 21) begin oled_data <= 16'h93D2; end
        if ( y == 25 && x == 22) begin oled_data <= 16'h41C8; end
        if ( y == 25 && x == 23) begin oled_data <= 16'h18A2; end
        if ( y == 26 && x == 12) begin oled_data <= 16'h3967; end
        if ( y == 26 && x == 13) begin oled_data <= 16'h3126; end
        if ( y == 26 && x == 14) begin oled_data <= 16'h62AC; end
        if ( y == 26 && x == 15) begin oled_data <= 16'h6B4F; end
        if ( y == 26 && x == 16) begin oled_data <= 16'h6350; end
        if ( y == 26 && x == 17) begin oled_data <= 16'h42CF; end
        if ( y == 26 && x == 18) begin oled_data <= 16'h4352; end
        if ( y == 26 && x == 19) begin oled_data <= 16'h6C37; end
        if ( y == 26 && x == 20) begin oled_data <= 16'h41ED; end
        if ( y == 26 && x == 21) begin oled_data <= 16'h5A6D; end
        if ( y == 26 && x == 22) begin oled_data <= 16'h52AC; end
        if ( y == 27 && x == 10) begin oled_data <= 16'h3A6C; end
        if ( y == 27 && x == 12) begin oled_data <= 16'h2128; end
        if ( y == 27 && x == 13) begin oled_data <= 16'h41C9; end
        if ( y == 27 && x == 14) begin oled_data <= 16'h49C8; end
        if ( y == 27 && x == 16) begin oled_data <= 16'h628A; end
        if ( y == 27 && x == 17) begin oled_data <= 16'hAD35; end
        if ( y == 27 && x == 18) begin oled_data <= 16'h9D16; end
        if ( y == 27 && x == 20) begin oled_data <= 16'h5B10; end
        if ( y == 27 && x == 21) begin oled_data <= 16'h39AA; end
        if ( y == 27 && x == 22) begin oled_data <= 16'h52ED; end
        if ( y == 28 && x == 9) begin oled_data <= 16'h21EA; end
        if ( y == 28 && x == 10) begin oled_data <= 16'h098C; end
        if ( y == 28 && x == 11) begin oled_data <= 16'h19EF; end
        if ( y == 28 && x == 12) begin oled_data <= 16'h2231; end
        if ( y == 28 && x == 13) begin oled_data <= 16'h19AD; end
        if ( y == 28 && x == 14) begin oled_data <= 16'h2947; end
        if ( y == 28 && x == 16) begin oled_data <= 16'hB46F; end
        if ( y == 28 && x == 17) begin oled_data <= 16'hD553; end
        if ( y == 28 && x == 18) begin oled_data <= 16'hC533; end
        if ( y == 28 && x == 19) begin oled_data <= 16'h6ACB; end
        if ( y == 28 && x == 20) begin oled_data <= 16'h632E; end
        if ( y == 28 && x == 21) begin oled_data <= 16'h4AAC; end
        if ( y == 28 && x == 22) begin oled_data <= 16'h2145; end
        if ( y == 29 && x == 8) begin oled_data <= 16'h2A6C; end
        if ( y == 29 && x == 9) begin oled_data <= 16'h5455; end
        if ( y == 29 && x == 10) begin oled_data <= 16'h4C17; end
        if ( y == 29 && x == 11) begin oled_data <= 16'h1232; end
        if ( y == 29 && x == 12) begin oled_data <= 16'h3B78; end
        if ( y == 29 && x == 13) begin oled_data <= 16'h2273; end
        if ( y == 29 && x == 14) begin oled_data <= 16'h092A; end
        if ( y == 29 && x == 15) begin oled_data <= 16'h3188; end
        if ( y == 29 && x == 16) begin oled_data <= 16'hC513; end
        if ( y == 29 && x == 17) begin oled_data <= 16'hE5B3; end
        if ( y == 29 && x == 18) begin oled_data <= 16'hD511; end
        if ( y == 29 && x == 19) begin oled_data <= 16'hCD73; end
        if ( y == 29 && x == 20) begin oled_data <= 16'h7B8E; end
        if ( y == 30 && x == 6) begin oled_data <= 16'h1189; end
        if ( y == 30 && x == 7) begin oled_data <= 16'h122D; end
        if ( y == 30 && x == 8) begin oled_data <= 16'h5497; end
        if ( y == 30 && x >= 9 && x <= 10) begin oled_data <= 16'h969F; end
        if ( y == 30 && x == 11) begin oled_data <= 16'h2AF3; end
        if ( y == 30 && x == 12) begin oled_data <= 16'h22D6; end
        if ( y == 30 && x == 13) begin oled_data <= 16'h1A75; end
        if ( y == 30 && x == 14) begin oled_data <= 16'h1213; end
        if ( y == 30 && x == 15) begin oled_data <= 16'h21CE; end
        if ( y == 30 && x == 16) begin oled_data <= 16'h83D1; end
        if ( y == 30 && x == 17) begin oled_data <= 16'hDDD5; end
        if ( y == 30 && x == 18) begin oled_data <= 16'hCCF0; end
        if ( y == 30 && x == 19) begin oled_data <= 16'hDDD3; end
        if ( y == 30 && x == 20) begin oled_data <= 16'h8BEE; end
        if ( y == 30 && x == 23) begin oled_data <= 16'h2144; end
        if ( y == 30 && x == 24) begin oled_data <= 16'h39E6; end
        if ( y == 30 && x == 25) begin oled_data <= 16'h18E3; end
        if ( y == 31 && x == 5) begin oled_data <= 16'h21A9; end
        if ( y == 31 && x == 6) begin oled_data <= 16'h2A91; end
        if ( y == 31 && x == 7) begin oled_data <= 16'h2B35; end
        if ( y == 31 && x == 8) begin oled_data <= 16'h33D6; end
        if ( y == 31 && x == 9) begin oled_data <= 16'h75BC; end
        if ( y == 31 && x == 10) begin oled_data <= 16'h5456; end
        if ( y == 31 && x == 11) begin oled_data <= 16'h11ED; end
        if ( y == 31 && x == 12) begin oled_data <= 16'h09D0; end
        if ( y == 31 && x == 13) begin oled_data <= 16'h01B2; end
        if ( y == 31 && x == 14) begin oled_data <= 16'h2319; end
        if ( y == 31 && x == 15) begin oled_data <= 16'h2AF7; end
        if ( y == 31 && x == 17) begin oled_data <= 16'h9452; end
        if ( y == 31 && x == 18) begin oled_data <= 16'hACB1; end
        if ( y == 31 && x == 19) begin oled_data <= 16'h7B4A; end
        if ( y == 31 && x == 20) begin oled_data <= 16'h18C2; end
        if ( y == 31 && x == 21) begin oled_data <= 16'h0861; end
        if ( y == 31 && x == 22) begin oled_data <= 16'h73EF; end
        if ( y == 31 && x == 23) begin oled_data <= 16'h8450; end
        if ( y == 31 && x == 24) begin oled_data <= 16'hC678; end
        if ( y == 31 && x == 25) begin oled_data <= 16'h73EE; end
        if ( y == 32 && x == 5) begin oled_data <= 16'h21AA; end
        if ( y == 32 && x == 6) begin oled_data <= 16'h11F1; end
        if ( y == 32 && x == 7) begin oled_data <= 16'h2B17; end
        if ( y == 32 && x == 8) begin oled_data <= 16'h2B56; end
        if ( y == 32 && x == 9) begin oled_data <= 16'h1A90; end
        if ( y == 32 && x == 10) begin oled_data <= 16'h2A4D; end
        if ( y == 32 && x == 11) begin oled_data <= 16'h29EB; end
        if ( y == 32 && x == 12) begin oled_data <= 16'h116C; end
        if ( y == 32 && x == 13) begin oled_data <= 16'h11B1; end
        if ( y == 32 && x == 14) begin oled_data <= 16'h2339; end
        if ( y == 32 && x == 15) begin oled_data <= 16'h2BBB; end
        if ( y == 32 && x == 16) begin oled_data <= 16'h3377; end
        if ( y == 32 && x == 18) begin oled_data <= 16'h4AED; end
        if ( y == 32 && x == 19) begin oled_data <= 16'h2165; end
        if ( y == 32 && x == 21) begin oled_data <= 16'h1987; end
        if ( y == 32 && x == 22) begin oled_data <= 16'h8472; end
        if ( y == 32 && x == 23) begin oled_data <= 16'h632D; end
        if ( y == 32 && x == 24) begin oled_data <= 16'hAD96; end
        if ( y == 32 && x == 25) begin oled_data <= 16'hBE17; end
        if ( y == 32 && x == 26) begin oled_data <= 16'h31C6; end
        if ( y == 33 && x == 5) begin oled_data <= 16'h29EB; end
        if ( y == 33 && x == 6) begin oled_data <= 16'h11AF; end
        if ( y == 33 && x == 7) begin oled_data <= 16'h11F2; end
        if ( y == 33 && x == 8) begin oled_data <= 16'h2251; end
        if ( y == 33 && x == 9) begin oled_data <= 16'h8D5A; end
        if ( y == 33 && x == 10) begin oled_data <= 16'hE77F; end
        if ( y == 33 && x == 11) begin oled_data <= 16'h9D16; end
        if ( y == 33 && x == 12) begin oled_data <= 16'h21CC; end
        if ( y == 33 && x == 13) begin oled_data <= 16'h11AF; end
        if ( y == 33 && x == 14) begin oled_data <= 16'h0213; end
        if ( y == 33 && x == 15) begin oled_data <= 16'h12D7; end
        if ( y == 33 && x == 16) begin oled_data <= 16'h1B15; end
        if ( y == 33 && x == 17) begin oled_data <= 16'h2B13; end
        if ( y == 33 && x == 18) begin oled_data <= 16'h859A; end
        if ( y == 33 && x == 19) begin oled_data <= 16'h4B91; end
        if ( y == 33 && x == 20) begin oled_data <= 16'h228F; end
        if ( y == 33 && x == 21) begin oled_data <= 16'h2A6F; end
        if ( y == 33 && x == 23) begin oled_data <= 16'h634E; end
        if ( y == 33 && x == 24) begin oled_data <= 16'h73CF; end
        if ( y == 33 && x == 25) begin oled_data <= 16'hBE38; end
        if ( y == 33 && x == 26) begin oled_data <= 16'h4248; end
        if ( y == 34 && x == 6) begin oled_data <= 16'h2A2D; end
        if ( y == 34 && x == 7) begin oled_data <= 16'h114B; end
        if ( y == 34 && x == 8) begin oled_data <= 16'h5B71; end
        if ( y == 34 && x == 9) begin oled_data <= 16'hEFBF; end
        if ( y == 34 && x == 10) begin oled_data <= 16'hF7BF; end
        if ( y == 34 && x == 11) begin oled_data <= 16'hBE19; end
        if ( y == 34 && x == 12) begin oled_data <= 16'h42EF; end
        if ( y == 34 && x == 13) begin oled_data <= 16'h6CF9; end
        if ( y == 34 && x == 14) begin oled_data <= 16'h651B; end
        if ( y == 34 && x == 15) begin oled_data <= 16'h2314; end
        if ( y == 34 && x == 16) begin oled_data <= 16'h09ED; end
        if ( y == 34 && x == 17) begin oled_data <= 16'h5436; end
        if ( y == 34 && x == 18) begin oled_data <= 16'hA6BF; end
        if ( y == 34 && x == 19) begin oled_data <= 16'h43F7; end
        if ( y == 34 && x == 20) begin oled_data <= 16'h2B59; end
        if ( y == 34 && x == 21) begin oled_data <= 16'h2B17; end
        if ( y == 34 && x == 22) begin oled_data <= 16'h4B13; end
        if ( y == 34 && x == 23) begin oled_data <= 16'hBE3B; end
        if ( y == 34 && x == 24) begin oled_data <= 16'h73D0; end
        if ( y == 34 && x == 25) begin oled_data <= 16'h73CE; end
        if ( y == 34 && x == 26) begin oled_data <= 16'h2144; end
        if ( y == 35 && x == 6) begin oled_data <= 16'h1947; end
        if ( y == 35 && x == 7) begin oled_data <= 16'h29A9; end
        if ( y == 35 && x == 8) begin oled_data <= 16'h8C93; end
        if ( y == 35 && x == 9) begin oled_data <= 16'hF7FF; end
        if ( y == 35 && x == 10) begin oled_data <= 16'hEF9E; end
        if ( y == 35 && x == 11) begin oled_data <= 16'hA598; end
        if ( y == 35 && x == 12) begin oled_data <= 16'h32F0; end
        if ( y == 35 && x == 13) begin oled_data <= 16'h85BD; end
        if ( y == 35 && x == 14) begin oled_data <= 16'h969F; end
        if ( y == 35 && x == 15) begin oled_data <= 16'h5456; end
        if ( y == 35 && x == 16) begin oled_data <= 16'h0169; end
        if ( y == 35 && x == 17) begin oled_data <= 16'h2AAD; end
        if ( y == 35 && x == 18) begin oled_data <= 16'h5435; end
        if ( y == 35 && x == 19) begin oled_data <= 16'h1251; end
        if ( y == 35 && x == 20) begin oled_data <= 16'h1296; end
        if ( y == 35 && x == 21) begin oled_data <= 16'h1254; end
        if ( y == 35 && x == 22) begin oled_data <= 16'h21EE; end
        if ( y == 35 && x == 23) begin oled_data <= 16'h6BD2; end
        if ( y == 35 && x == 24) begin oled_data <= 16'h8431; end
        if ( y == 35 && x == 25) begin oled_data <= 16'h4248; end
        if ( y == 36 && x == 7) begin oled_data <= 16'h08A3; end
        if ( y == 36 && x == 8) begin oled_data <= 16'h638E; end
        if ( y == 36 && x == 9) begin oled_data <= 16'hBE59; end
        if ( y == 36 && x == 10) begin oled_data <= 16'hBE5A; end
        if ( y == 36 && x == 11) begin oled_data <= 16'h4B10; end
        if ( y == 36 && x == 12) begin oled_data <= 16'h1231; end
        if ( y == 36 && x == 13) begin oled_data <= 16'h2336; end
        if ( y == 36 && x == 14) begin oled_data <= 16'h3376; end
        if ( y == 36 && x == 15) begin oled_data <= 16'h1A6F; end
        if ( y == 36 && x == 18) begin oled_data <= 16'h19A9; end
        if ( y == 36 && x == 20) begin oled_data <= 16'h19CE; end
        if ( y == 36 && x == 21) begin oled_data <= 16'h21CE; end
        if ( y == 36 && x == 22) begin oled_data <= 16'h29CB; end
        if ( y == 36 && x == 23) begin oled_data <= 16'h2167; end
        if ( y == 36 && x == 24) begin oled_data <= 16'h0862; end
        if ( y == 37 && x == 8) begin oled_data <= 16'h2186; end
        if ( y == 37 && x == 9) begin oled_data <= 16'h532D; end
        if ( y == 37 && x == 10) begin oled_data <= 16'h4B6F; end
        if ( y == 37 && x == 11) begin oled_data <= 16'h3B52; end
        if ( y == 37 && x == 12) begin oled_data <= 16'h1273; end
        if ( y == 37 && x == 13) begin oled_data <= 16'h2B78; end
        if ( y == 37 && x == 14) begin oled_data <= 16'h1AF4; end
        if ( y == 37 && x == 15) begin oled_data <= 16'h43F5; end
        if ( y == 37 && x == 16) begin oled_data <= 16'h5412; end
        if ( y == 37 && x == 17) begin oled_data <= 16'h19C9; end
        if ( y == 37 && x == 18) begin oled_data <= 16'h0947; end
        if ( y == 37 && x == 19) begin oled_data <= 16'h1989; end
        if ( y == 37 && x == 20) begin oled_data <= 16'h08C6; end
        if ( y == 37 && x == 21) begin oled_data <= 16'h08A5; end
        if ( y == 38 && x == 8) begin oled_data <= 16'h19A8; end
        if ( y == 38 && x == 9) begin oled_data <= 16'h6C74; end
        if ( y == 38 && x == 10) begin oled_data <= 16'h965C; end
        if ( y == 38 && x == 11) begin oled_data <= 16'h85FD; end
        if ( y == 38 && x == 12) begin oled_data <= 16'h1A92; end
        if ( y == 38 && x == 13) begin oled_data <= 16'h0A11; end
        if ( y == 38 && x == 14) begin oled_data <= 16'h3375; end
        if ( y == 38 && x == 15) begin oled_data <= 16'h8E7F; end
        if ( y == 38 && x == 16) begin oled_data <= 16'h9EBF; end
        if ( y == 38 && x == 17) begin oled_data <= 16'h7DBA; end
        if ( y == 38 && x == 18) begin oled_data <= 16'h22D1; end
        if ( y == 38 && x == 19) begin oled_data <= 16'h32F1; end
        if ( y == 39 && x == 7) begin oled_data <= 16'h08A4; end
        if ( y == 39 && x == 8) begin oled_data <= 16'h2A4D; end
        if ( y == 39 && x == 9) begin oled_data <= 16'h2AF1; end
        if ( y == 39 && x >= 10 && x <= 11) begin oled_data <= 16'h75BC; end
        if ( y == 39 && x == 12) begin oled_data <= 16'h22B1; end
        if ( y == 39 && x == 13) begin oled_data <= 16'h2250; end
        if ( y == 39 && x == 14) begin oled_data <= 16'h3B74; end
        if ( y == 39 && x == 15) begin oled_data <= 16'h64FA; end
        if ( y == 39 && x == 16) begin oled_data <= 16'h75DD; end
        if ( y == 39 && x == 17) begin oled_data <= 16'h3C38; end
        if ( y == 39 && x == 18) begin oled_data <= 16'h1B35; end
        if ( y == 39 && x == 19) begin oled_data <= 16'h3354; end
        if ( y == 40 && x == 6) begin oled_data <= 16'h0883; end
        if ( y == 40 && x == 7) begin oled_data <= 16'h322D; end
        if ( y == 40 && x == 8) begin oled_data <= 16'h11F0; end
        if ( y == 40 && x == 9) begin oled_data <= 16'h0A33; end
        if ( y == 40 && x == 10) begin oled_data <= 16'h2335; end
        if ( y == 40 && x == 11) begin oled_data <= 16'h5498; end
        if ( y == 40 && x == 14) begin oled_data <= 16'h2A4D; end
        if ( y == 40 && x == 15) begin oled_data <= 16'h09CE; end
        if ( y == 40 && x == 16) begin oled_data <= 16'h0232; end
        if ( y == 40 && x == 17) begin oled_data <= 16'h0AD6; end
        if ( y == 40 && x == 18) begin oled_data <= 16'h23DA; end
        if ( y == 40 && x == 19) begin oled_data <= 16'h2334; end
        if ( y == 41 && x == 7) begin oled_data <= 16'h19CF; end
        if ( y == 41 && x == 8) begin oled_data <= 16'h0214; end
        if ( y == 41 && x == 9) begin oled_data <= 16'h237A; end
        if ( y == 41 && x == 10) begin oled_data <= 16'h2377; end
        if ( y == 41 && x == 11) begin oled_data <= 16'h1290; end
        if ( y == 41 && x == 14) begin oled_data <= 16'h322D; end
        if ( y == 41 && x == 15) begin oled_data <= 16'h09AF; end
        if ( y == 41 && x == 16) begin oled_data <= 16'h0A76; end
        if ( y == 41 && x == 17) begin oled_data <= 16'h23BC; end
        if ( y == 41 && x == 18) begin oled_data <= 16'h1BDA; end
        if ( y == 41 && x == 19) begin oled_data <= 16'h2B75; end
        if ( y == 42 && x == 5) begin oled_data <= 16'h2168; end
        if ( y == 42 && x == 6) begin oled_data <= 16'h21EF; end
        if ( y == 42 && x == 7) begin oled_data <= 16'h09D2; end
        if ( y == 42 && x == 8) begin oled_data <= 16'h133B; end
        if ( y == 42 && x == 9) begin oled_data <= 16'h1BDC; end
        if ( y == 42 && x == 10) begin oled_data <= 16'h23D9; end
        if ( y == 42 && x == 11) begin oled_data <= 16'h0A50; end
        if ( y == 42 && x == 14) begin oled_data <= 16'h198E; end
        if ( y == 42 && x == 15) begin oled_data <= 16'h09B2; end
        if ( y == 42 && x == 16) begin oled_data <= 16'h0AF9; end
        if ( y == 42 && x == 17) begin oled_data <= 16'h1BDC; end
        if ( y == 42 && x == 18) begin oled_data <= 16'h23B9; end
        if ( y == 42 && x == 19) begin oled_data <= 16'h3354; end
        if ( y == 43 && x == 4) begin oled_data <= 16'h0883; end
        if ( y == 43 && x == 5) begin oled_data <= 16'h322D; end
        if ( y == 43 && x == 6) begin oled_data <= 16'h09B0; end
        if ( y == 43 && x == 7) begin oled_data <= 16'h0A97; end
        if ( y == 43 && x == 8) begin oled_data <= 16'h13DD; end
        if ( y == 43 && x == 9) begin oled_data <= 16'h13DC; end
        if ( y == 43 && x == 10) begin oled_data <= 16'h23D8; end
        if ( y == 43 && x == 14) begin oled_data <= 16'h198F; end
        if ( y == 43 && x == 15) begin oled_data <= 16'h09D4; end
        if ( y == 43 && x == 16) begin oled_data <= 16'h131B; end
        if ( y == 43 && x == 17) begin oled_data <= 16'h137B; end
        if ( y == 43 && x == 18) begin oled_data <= 16'h1B57; end
        if ( y == 43 && x == 19) begin oled_data <= 16'h09ED; end
        if ( y == 44 && x == 4) begin oled_data <= 16'h2168; end
        if ( y == 44 && x == 5) begin oled_data <= 16'h21CD; end
        if ( y == 44 && x == 6) begin oled_data <= 16'h09F3; end
        if ( y == 44 && x == 7) begin oled_data <= 16'h133B; end
        if ( y == 44 && x == 8) begin oled_data <= 16'h0BFE; end
        if ( y == 44 && x == 9) begin oled_data <= 16'h13DC; end
        if ( y == 44 && x == 10) begin oled_data <= 16'h33B6; end
        if ( y == 44 && x == 11) begin oled_data <= 16'h014A; end
        if ( y == 44 && x == 13) begin oled_data <= 16'h29AA; end
        if ( y == 44 && x == 14) begin oled_data <= 16'h196E; end
        if ( y == 44 && x == 15) begin oled_data <= 16'h11D3; end
        if ( y == 44 && x == 16) begin oled_data <= 16'h0257; end
        if ( y == 44 && x == 17) begin oled_data <= 16'h02B8; end
        if ( y == 44 && x == 18) begin oled_data <= 16'h12D5; end
        if ( y == 44 && x == 19) begin oled_data <= 16'h124F; end
        if ( y == 45 && x == 3) begin oled_data <= 16'h29A9; end
        if ( y == 45 && x == 4) begin oled_data <= 16'h29EE; end
        if ( y == 45 && x == 5) begin oled_data <= 16'h016F; end
        if ( y == 45 && x == 6) begin oled_data <= 16'h0235; end
        if ( y == 45 && x == 7) begin oled_data <= 16'h1BBC; end
        if ( y == 45 && x == 8) begin oled_data <= 16'h13DD; end
        if ( y == 45 && x == 9) begin oled_data <= 16'h1BDA; end
        if ( y == 45 && x == 10) begin oled_data <= 16'h2B12; end
        if ( y == 45 && x == 13) begin oled_data <= 16'h29CA; end
        if ( y == 45 && x == 14) begin oled_data <= 16'h114D; end
        if ( y == 45 && x == 15) begin oled_data <= 16'h09B2; end
        if ( y == 45 && x == 16) begin oled_data <= 16'h0A77; end
        if ( y == 45 && x == 17) begin oled_data <= 16'h23BC; end
        if ( y == 45 && x == 18) begin oled_data <= 16'h2399; end
        if ( y == 45 && x == 19) begin oled_data <= 16'h2B34; end
        if ( y == 46 && x == 2) begin oled_data <= 16'h29EB; end
        if ( y == 46 && x == 3) begin oled_data <= 16'h2A2F; end
        if ( y == 46 && x == 4) begin oled_data <= 16'h09B1; end
        if ( y == 46 && x == 5) begin oled_data <= 16'h1277; end
        if ( y == 46 && x == 6) begin oled_data <= 16'h0AB8; end
        if ( y == 46 && x == 7) begin oled_data <= 16'h02F8; end
        if ( y == 46 && x == 8) begin oled_data <= 16'h1BBA; end
        if ( y == 46 && x == 9) begin oled_data <= 16'h2BB7; end
        if ( y == 46 && x == 10) begin oled_data <= 16'h11AA; end
        if ( y == 46 && x == 13) begin oled_data <= 16'h3A2B; end
        if ( y == 46 && x == 14) begin oled_data <= 16'h21CE; end
        if ( y == 46 && x == 15) begin oled_data <= 16'h09D2; end
        if ( y == 46 && x == 16) begin oled_data <= 16'h0A99; end
        if ( y == 46 && x == 17) begin oled_data <= 16'h1B9E; end
        if ( y == 46 && x == 18) begin oled_data <= 16'h13DD; end
        if ( y == 46 && x == 19) begin oled_data <= 16'h2398; end
        if ( y == 46 && x == 20) begin oled_data <= 16'h19EC; end
        if ( y == 47 && x == 1) begin oled_data <= 16'h3A2A; end
        if ( y == 47 && x == 3) begin oled_data <= 16'h11AF; end
        if ( y == 47 && x == 4) begin oled_data <= 16'h1296; end
        if ( y == 47 && x == 5) begin oled_data <= 16'h239C; end
        if ( y == 47 && x == 6) begin oled_data <= 16'h23DC; end
        if ( y == 47 && x == 7) begin oled_data <= 16'h0B18; end
        if ( y == 47 && x == 8) begin oled_data <= 16'h0AB5; end
        if ( y == 47 && x == 9) begin oled_data <= 16'h1A91; end
        if ( y == 47 && x == 13) begin oled_data <= 16'h08A4; end
        if ( y == 47 && x == 14) begin oled_data <= 16'h322D; end
        if ( y == 47 && x == 15) begin oled_data <= 16'h2251; end
        if ( y == 47 && x == 16) begin oled_data <= 16'h0A35; end
        if ( y == 47 && x == 17) begin oled_data <= 16'h131A; end
        if ( y == 47 && x == 18) begin oled_data <= 16'h1BFD; end
        if ( y == 47 && x == 19) begin oled_data <= 16'h23B9; end
        if ( y == 47 && x == 20) begin oled_data <= 16'h2A8F; end
        if ( y == 48 && x == 0) begin oled_data <= 16'h2187; end
        if ( y == 48 && x == 2) begin oled_data <= 16'h114C; end
        if ( y == 48 && x == 3) begin oled_data <= 16'h19F1; end
        if ( y == 48 && x == 4) begin oled_data <= 16'h2358; end
        if ( y == 48 && x == 5) begin oled_data <= 16'h23BB; end
        if ( y == 48 && x == 6) begin oled_data <= 16'h1BDA; end
        if ( y == 48 && x == 7) begin oled_data <= 16'h23D9; end
        if ( y == 48 && x == 8) begin oled_data <= 16'h2335; end
        if ( y == 48 && x == 15) begin oled_data <= 16'h1969; end
        if ( y == 48 && x == 16) begin oled_data <= 16'h222F; end
        if ( y == 48 && x == 17) begin oled_data <= 16'h22B3; end
        if ( y == 48 && x == 18) begin oled_data <= 16'h2377; end
        if ( y == 48 && x == 19) begin oled_data <= 16'h2B96; end
        if ( y == 48 && x == 20) begin oled_data <= 16'h3AF0; end
        if ( y == 49 && x == 0) begin oled_data <= 16'h29A8; end
        if ( y == 49 && x == 1) begin oled_data <= 16'h3A2D; end
        if ( y == 49 && x == 2) begin oled_data <= 16'h2A10; end
        if ( y == 49 && x == 3) begin oled_data <= 16'h2253; end
        if ( y == 49 && x == 4) begin oled_data <= 16'h1B17; end
        if ( y == 49 && x >= 5 && x <= 6) begin oled_data <= 16'h1358; end
        if ( y == 49 && x == 7) begin oled_data <= 16'h1336; end
        if ( y == 49 && x == 8) begin oled_data <= 16'h2B34; end
        if ( y == 49 && x == 17) begin oled_data <= 16'h012A; end
        if ( y == 49 && x == 18) begin oled_data <= 16'h0A51; end
        if ( y == 49 && x == 19) begin oled_data <= 16'h22F3; end
        if ( y == 49 && x == 20) begin oled_data <= 16'h2A6D; end
        
        end
        else if (led_count > 0) //shooting stance
        begin
        if ( y == 20 && x == 10) begin oled_data <= 16'h21AA; end
        if ( y == 20 && x == 11) begin oled_data <= 16'h116A; end
        if ( y == 20 && x == 12) begin oled_data <= 16'h32D0; end
        if ( y == 20 && x == 13) begin oled_data <= 16'h4BF4; end
        if ( y == 20 && x == 14) begin oled_data <= 16'h3B92; end
        if ( y == 20 && x == 15) begin oled_data <= 16'h224B; end
        if ( y == 21 && x == 10) begin oled_data <= 16'h198C; end
        if ( y == 21 && x == 11) begin oled_data <= 16'h11CF; end
        if ( y == 21 && x == 12) begin oled_data <= 16'h1251; end
        if ( y == 21 && x == 13) begin oled_data <= 16'h1AD2; end
        if ( y == 21 && x == 14) begin oled_data <= 16'h4C16; end
        if ( y == 21 && x == 15) begin oled_data <= 16'h85BA; end
        if ( y == 21 && x == 16) begin oled_data <= 16'h5390; end
        if ( y == 22 && x == 8) begin oled_data <= 16'h29AA; end
        if ( y == 22 && x == 9) begin oled_data <= 16'h198D; end
        if ( y == 22 && x == 10) begin oled_data <= 16'h11B3; end
        if ( y == 22 && x == 11) begin oled_data <= 16'h1257; end
        if ( y == 22 && x == 12) begin oled_data <= 16'h239B; end
        if ( y == 22 && x == 13) begin oled_data <= 16'h2399; end
        if ( y == 22 && x == 14) begin oled_data <= 16'h0A73; end
        if ( y == 22 && x == 15) begin oled_data <= 16'h43F7; end
        if ( y == 22 && x == 16) begin oled_data <= 16'h9E7D; end
        if ( y == 22 && x == 17) begin oled_data <= 16'h32AC; end
        if ( y == 23 && x == 8) begin oled_data <= 16'h29CC; end
        if ( y == 23 && x == 9) begin oled_data <= 16'h198F; end
        if ( y == 23 && x == 10) begin oled_data <= 16'h11F5; end
        if ( y == 23 && x == 11) begin oled_data <= 16'h0217; end
        if ( y == 23 && x == 12) begin oled_data <= 16'h0AF9; end
        if ( y == 23 && x == 13) begin oled_data <= 16'h1359; end
        if ( y == 23 && x == 14) begin oled_data <= 16'h12B6; end
        if ( y == 23 && x == 15) begin oled_data <= 16'h1211; end
        if ( y == 23 && x == 16) begin oled_data <= 16'h8519; end
        if ( y == 23 && x == 17) begin oled_data <= 16'h6C12; end
        if ( y == 23 && x == 18) begin oled_data <= 16'h0882; end
        if ( y == 24 && x == 7) begin oled_data <= 16'h2988; end
        if ( y == 24 && x == 8) begin oled_data <= 16'h29AC; end
        if ( y == 24 && x == 9) begin oled_data <= 16'h198E; end
        if ( y == 24 && x == 10) begin oled_data <= 16'h1A33; end
        if ( y == 24 && x == 11) begin oled_data <= 16'h2B39; end
        if ( y == 24 && x == 12) begin oled_data <= 16'h341B; end
        if ( y == 24 && x == 13) begin oled_data <= 16'h447C; end
        if ( y == 24 && x == 14) begin oled_data <= 16'h1A95; end
        if ( y == 24 && x == 15) begin oled_data <= 16'h29F0; end
        if ( y == 24 && x == 16) begin oled_data <= 16'h72EF; end
        if ( y == 24 && x == 17) begin oled_data <= 16'h6229; end
        if ( y == 25 && x == 7) begin oled_data <= 16'h31C8; end
        if ( y == 25 && x == 8) begin oled_data <= 16'h2949; end
        if ( y == 25 && x == 9) begin oled_data <= 16'h214A; end
        if ( y == 25 && x == 10) begin oled_data <= 16'h4313; end
        if ( y == 25 && x == 11) begin oled_data <= 16'h6CBA; end
        if ( y == 25 && x == 12) begin oled_data <= 16'h6CFB; end
        if ( y == 25 && x == 13) begin oled_data <= 16'h6CDB; end
        if ( y == 25 && x == 14) begin oled_data <= 16'h5C3A; end
        if ( y == 25 && x == 15) begin oled_data <= 16'h29AE; end
        if ( y == 25 && x == 16) begin oled_data <= 16'hA414; end
        if ( y == 25 && x == 17) begin oled_data <= 16'h724A; end
        if ( y == 25 && x == 18) begin oled_data <= 16'h28C4; end
        if ( y == 26 && x == 7) begin oled_data <= 16'h39A7; end
        if ( y == 26 && x == 9) begin oled_data <= 16'h51A8; end
        if ( y == 26 && x == 10) begin oled_data <= 16'h6B70; end
        if ( y == 26 && x == 11) begin oled_data <= 16'h5B2F; end
        if ( y == 26 && x == 13) begin oled_data <= 16'h3A8E; end
        if ( y == 26 && x == 14) begin oled_data <= 16'h6437; end
        if ( y == 26 && x == 15) begin oled_data <= 16'h4B13; end
        if ( y == 26 && x == 16) begin oled_data <= 16'h49EC; end
        if ( y == 26 && x == 17) begin oled_data <= 16'h628D; end
        if ( y == 26 && x == 18) begin oled_data <= 16'h3187; end
        if ( y == 27 && x == 7) begin oled_data <= 16'h3166; end
        if ( y == 27 && x == 8) begin oled_data <= 16'h4946; end
        if ( y == 27 && x == 9) begin oled_data <= 16'h59C8; end
        if ( y == 27 && x == 10) begin oled_data <= 16'h3125; end
        if ( y == 27 && x == 11) begin oled_data <= 16'h39A6; end
        if ( y == 27 && x == 13) begin oled_data <= 16'hCDF8; end
        if ( y == 27 && x == 14) begin oled_data <= 16'h5B71; end
        if ( y == 27 && x == 15) begin oled_data <= 16'h5B92; end
        if ( y == 27 && x == 16) begin oled_data <= 16'h39EC; end
        if ( y == 27 && x == 17) begin oled_data <= 16'h528D; end
        if ( y == 27 && x == 18) begin oled_data <= 16'h31A8; end
        if ( y == 28 && x == 7) begin oled_data <= 16'h31C8; end
        if ( y == 28 && x >= 8 && x <= 9) begin oled_data <= 16'h2948; end
        if ( y == 28 && x == 11) begin oled_data <= 16'h72EB; end
        if ( y == 28 && x == 12) begin oled_data <= 16'hD552; end
        if ( y == 28 && x == 13) begin oled_data <= 16'hD593; end
        if ( y == 28 && x == 14) begin oled_data <= 16'h838D; end
        if ( y == 28 && x == 16) begin oled_data <= 16'h4A8C; end
        if ( y == 28 && x == 17) begin oled_data <= 16'h31C9; end
        if ( y == 29 && x == 8) begin oled_data <= 16'h2A4F; end
        if ( y == 29 && x == 9) begin oled_data <= 16'h3290; end
        if ( y == 29 && x == 10) begin oled_data <= 16'h1927; end
        if ( y == 29 && x == 11) begin oled_data <= 16'h83AE; end
        if ( y == 29 && x == 12) begin oled_data <= 16'hEDF4; end
        if ( y == 29 && x == 13) begin oled_data <= 16'hDD30; end
        if ( y == 29 && x == 14) begin oled_data <= 16'hD531; end
        if ( y == 29 && x == 15) begin oled_data <= 16'hACB1; end
        if ( y == 29 && x == 16) begin oled_data <= 16'h4249; end
        if ( y == 29 && x == 18) begin oled_data <= 16'h29A7; end
        if ( y == 29 && x == 19) begin oled_data <= 16'h08C4; end
        if ( y == 30 && x == 6) begin oled_data <= 16'h196A; end
        if ( y == 30 && x == 7) begin oled_data <= 16'h2A70; end
        if ( y == 30 && x == 8) begin oled_data <= 16'h3398; end
        if ( y == 30 && x == 9) begin oled_data <= 16'h22F5; end
        if ( y == 30 && x == 10) begin oled_data <= 16'h19EC; end
        if ( y == 30 && x == 11) begin oled_data <= 16'h4A49; end
        if ( y == 30 && x == 12) begin oled_data <= 16'hDDB4; end
        if ( y == 30 && x == 13) begin oled_data <= 16'hDD30; end
        if ( y == 30 && x == 14) begin oled_data <= 16'hE592; end
        if ( y == 30 && x == 15) begin oled_data <= 16'hBCF0; end
        if ( y == 30 && x == 16) begin oled_data <= 16'h4246; end
        if ( y == 30 && x == 17) begin oled_data <= 16'h534C; end
        if ( y == 30 && x == 19) begin oled_data <= 16'h42EE; end
        if ( y == 30 && x == 20) begin oled_data <= 16'h09AB; end
        if ( y == 30 && x == 24) begin oled_data <= 16'h08C4; end
        if ( y == 31 && x == 6) begin oled_data <= 16'h21CB; end
        if ( y == 31 && x == 7) begin oled_data <= 16'h2A91; end
        if ( y == 31 && x == 8) begin oled_data <= 16'h12B5; end
        if ( y == 31 && x == 9) begin oled_data <= 16'h2B98; end
        if ( y == 31 && x == 10) begin oled_data <= 16'h85BC; end
        if ( y == 31 && x == 11) begin oled_data <= 16'h326C; end
        if ( y == 31 && x == 12) begin oled_data <= 16'h62CB; end
        if ( y == 31 && x == 13) begin oled_data <= 16'hBD13; end
        if ( y == 31 && x == 14) begin oled_data <= 16'h836D; end
        if ( y == 31 && x == 16) begin oled_data <= 16'h29C4; end
        if ( y == 31 && x == 17) begin oled_data <= 16'h19A5; end
        if ( y == 31 && x == 18) begin oled_data <= 16'h2A2C; end
        if ( y == 31 && x == 19) begin oled_data <= 16'h2270; end
        if ( y == 31 && x == 20) begin oled_data <= 16'h2B33; end
        if ( y == 31 && x == 21) begin oled_data <= 16'h2B55; end
        if ( y == 31 && x == 22) begin oled_data <= 16'h3354; end
        if ( y == 31 && x == 23) begin oled_data <= 16'h2A8F; end
        if ( y == 31 && x == 25) begin oled_data <= 16'h2924; end
        if ( y == 32 && x == 6) begin oled_data <= 16'h2168; end
        if ( y == 32 && x == 7) begin oled_data <= 16'h2A2D; end
        if ( y == 32 && x == 8) begin oled_data <= 16'h09CE; end
        if ( y == 32 && x == 9) begin oled_data <= 16'h4418; end
        if ( y == 32 && x == 10) begin oled_data <= 16'h969F; end
        if ( y == 32 && x == 11) begin oled_data <= 16'h861D; end
        if ( y == 32 && x == 12) begin oled_data <= 16'h1A2D; end
        if ( y == 32 && x == 13) begin oled_data <= 16'h2A4F; end
        if ( y == 32 && x == 14) begin oled_data <= 16'h1A2F; end
        if ( y == 32 && x == 16) begin oled_data <= 16'h11C7; end
        if ( y == 32 && x == 17) begin oled_data <= 16'h11C8; end
        if ( y == 32 && x == 18) begin oled_data <= 16'h1210; end
        if ( y == 32 && x == 19) begin oled_data <= 16'h22B5; end
        if ( y == 32 && x == 20) begin oled_data <= 16'h6D7F; end
        if ( y == 32 && x == 21) begin oled_data <= 16'h8E9F; end
        if ( y == 32 && x == 22) begin oled_data <= 16'h4C59; end
        if ( y == 32 && x == 23) begin oled_data <= 16'h1A2E; end
        if ( y == 32 && x == 25) begin oled_data <= 16'h41A5; end
        if ( y == 33 && x == 7) begin oled_data <= 16'h1988; end
        if ( y == 33 && x == 8) begin oled_data <= 16'h2A8F; end
        if ( y == 33 && x == 9) begin oled_data <= 16'h2AD1; end
        if ( y == 33 && x == 10) begin oled_data <= 16'h5498; end
        if ( y == 33 && x == 11) begin oled_data <= 16'h5CFA; end
        if ( y == 33 && x == 12) begin oled_data <= 16'h1A93; end
        if ( y == 33 && x == 13) begin oled_data <= 16'h2B57; end
        if ( y == 33 && x == 14) begin oled_data <= 16'h3399; end
        if ( y == 33 && x == 15) begin oled_data <= 16'h2B35; end
        if ( y == 33 && x == 16) begin oled_data <= 16'h1A2A; end
        if ( y == 33 && x == 17) begin oled_data <= 16'h19C9; end
        if ( y == 33 && x == 18) begin oled_data <= 16'h11B0; end
        if ( y == 33 && x == 19) begin oled_data <= 16'h1234; end
        if ( y == 33 && x == 20) begin oled_data <= 16'h43D9; end
        if ( y == 33 && x == 21) begin oled_data <= 16'h5CBC; end
        if ( y == 33 && x == 22) begin oled_data <= 16'h3356; end
        if ( y == 33 && x == 23) begin oled_data <= 16'h098C; end
        if ( y == 33 && x == 24) begin oled_data <= 16'h2926; end
        if ( y == 33 && x == 25) begin oled_data <= 16'h49E6; end
        if ( y == 34 && x == 8) begin oled_data <= 16'h3ACE; end
        if ( y == 34 && x == 9) begin oled_data <= 16'h5C15; end
        if ( y == 34 && x == 10) begin oled_data <= 16'h2B12; end
        if ( y == 34 && x == 11) begin oled_data <= 16'h1A72; end
        if ( y == 34 && x == 12) begin oled_data <= 16'h0A14; end
        if ( y == 34 && x == 13) begin oled_data <= 16'h1A77; end
        if ( y == 34 && x == 14) begin oled_data <= 16'h1257; end
        if ( y == 34 && x == 15) begin oled_data <= 16'h1A33; end
        if ( y == 34 && x == 16) begin oled_data <= 16'h19CB; end
        if ( y == 34 && x == 17) begin oled_data <= 16'h21CA; end
        if ( y == 34 && x == 18) begin oled_data <= 16'h198D; end
        if ( y == 34 && x == 19) begin oled_data <= 16'h1190; end
        if ( y == 34 && x == 20) begin oled_data <= 16'h0990; end
        if ( y == 34 && x == 21) begin oled_data <= 16'h0970; end
        if ( y == 34 && x == 22) begin oled_data <= 16'h11AF; end
        if ( y == 34 && x == 23) begin oled_data <= 16'h194B; end
        if ( y == 34 && x == 25) begin oled_data <= 16'h41C6; end
        if ( y == 35 && x == 8) begin oled_data <= 16'h19A8; end
        if ( y == 35 && x == 9) begin oled_data <= 16'h53B3; end
        if ( y == 35 && x == 10) begin oled_data <= 16'h5C17; end
        if ( y == 35 && x == 11) begin oled_data <= 16'h1212; end
        if ( y == 35 && x == 12) begin oled_data <= 16'h0194; end
        if ( y == 35 && x == 13) begin oled_data <= 16'h09B6; end
        if ( y == 35 && x == 14) begin oled_data <= 16'h09B4; end
        if ( y == 35 && x == 15) begin oled_data <= 16'h19D1; end
        if ( y == 35 && x == 16) begin oled_data <= 16'h218B; end
        if ( y == 35 && x == 17) begin oled_data <= 16'h29A9; end
        if ( y == 35 && x == 18) begin oled_data <= 16'h29AB; end
        if ( y == 35 && x == 19) begin oled_data <= 16'h218C; end
        if ( y == 35 && x == 20) begin oled_data <= 16'h218E; end
        if ( y == 35 && x == 21) begin oled_data <= 16'h198E; end
        if ( y == 35 && x == 22) begin oled_data <= 16'h218D; end
        if ( y == 35 && x == 23) begin oled_data <= 16'h216A; end
        if ( y == 35 && x == 24) begin oled_data <= 16'h2966; end
        if ( y == 35 && x == 25) begin oled_data <= 16'h39A6; end
        if ( y == 36 && x == 9) begin oled_data <= 16'h21EB; end
        if ( y == 36 && x == 10) begin oled_data <= 16'h19EF; end
        if ( y == 36 && x == 11) begin oled_data <= 16'h11D3; end
        if ( y == 36 && x >= 12 && x <= 13) begin oled_data <= 16'h09B6; end
        if ( y == 36 && x == 14) begin oled_data <= 16'h0971; end
        if ( y == 36 && x == 15) begin oled_data <= 16'h21EE; end
        if ( y == 36 && x == 19) begin oled_data <= 16'h2988; end
        if ( y == 36 && x == 20) begin oled_data <= 16'h29AA; end
        if ( y == 36 && x == 21) begin oled_data <= 16'h298A; end
        if ( y == 36 && x == 22) begin oled_data <= 16'h29A9; end
        if ( y == 36 && x == 23) begin oled_data <= 16'h2988; end
        if ( y == 36 && x == 24) begin oled_data <= 16'h18A3; end
        if ( y == 37 && x == 9) begin oled_data <= 16'h2A2C; end
        if ( y == 37 && x == 10) begin oled_data <= 16'h2230; end
        if ( y == 37 && x == 11) begin oled_data <= 16'h09B1; end
        if ( y == 37 && x >= 12 && x <= 13) begin oled_data <= 16'h1216; end
        if ( y == 37 && x == 14) begin oled_data <= 16'h1A11; end
        if ( y == 37 && x == 15) begin oled_data <= 16'h328F; end
        if ( y == 37 && x == 16) begin oled_data <= 16'h08E5; end
        if ( y == 38 && x == 8) begin oled_data <= 16'h2A2B; end
        if ( y == 38 && x == 9) begin oled_data <= 16'h4BD3; end
        if ( y == 38 && x == 10) begin oled_data <= 16'h85FE; end
        if ( y == 38 && x == 11) begin oled_data <= 16'h4419; end
        if ( y == 38 && x >= 12 && x <= 13) begin oled_data <= 16'h09F3; end
        if ( y == 38 && x == 14) begin oled_data <= 16'h3B97; end
        if ( y == 38 && x == 15) begin oled_data <= 16'h8E3E; end
        if ( y == 38 && x == 16) begin oled_data <= 16'h53D2; end
        if ( y == 38 && x == 17) begin oled_data <= 16'h1166; end
        if ( y == 39 && x == 7) begin oled_data <= 16'h08E5; end
        if ( y == 39 && x == 8) begin oled_data <= 16'h1A2E; end
        if ( y == 39 && x == 9) begin oled_data <= 16'h4C17; end
        if ( y == 39 && x == 10) begin oled_data <= 16'h8E7F; end
        if ( y == 39 && x == 11) begin oled_data <= 16'h7DBD; end
        if ( y == 39 && x == 12) begin oled_data <= 16'h1A30; end
        if ( y == 39 && x == 13) begin oled_data <= 16'h2271; end
        if ( y == 39 && x == 14) begin oled_data <= 16'h64FB; end
        if ( y == 39 && x == 15) begin oled_data <= 16'h7DFE; end
        if ( y == 39 && x == 16) begin oled_data <= 16'h967D; end
        if ( y == 39 && x == 17) begin oled_data <= 16'h4B90; end
        if ( y == 39 && x == 18) begin oled_data <= 16'h1167; end
        if ( y == 40 && x == 7) begin oled_data <= 16'h2A2C; end
        if ( y == 40 && x == 8) begin oled_data <= 16'h01CF; end
        if ( y == 40 && x == 9) begin oled_data <= 16'h12D4; end
        if ( y == 40 && x == 10) begin oled_data <= 16'h2B75; end
        if ( y == 40 && x == 11) begin oled_data <= 16'h43D4; end
        if ( y == 40 && x == 14) begin oled_data <= 16'h43B4; end
        if ( y == 40 && x == 15) begin oled_data <= 16'h6D3B; end
        if ( y == 40 && x == 16) begin oled_data <= 16'h7D7C; end
        if ( y == 40 && x == 17) begin oled_data <= 16'h2AF1; end
        if ( y == 40 && x == 18) begin oled_data <= 16'h1A91; end
        if ( y == 40 && x == 19) begin oled_data <= 16'h2AD0; end
        if ( y == 40 && x == 20) begin oled_data <= 16'h1967; end
        if ( y == 41 && x == 6) begin oled_data <= 16'h31EA; end
        if ( y == 41 && x == 7) begin oled_data <= 16'h19EE; end
        if ( y == 41 && x == 8) begin oled_data <= 16'h12B5; end
        if ( y == 41 && x == 9) begin oled_data <= 16'h2BDA; end
        if ( y == 41 && x == 10) begin oled_data <= 16'h2355; end
        if ( y == 41 && x == 11) begin oled_data <= 16'h124E; end
        if ( y == 41 && x == 15) begin oled_data <= 16'h4373; end
        if ( y == 41 && x == 16) begin oled_data <= 16'h2A71; end
        if ( y == 41 && x == 17) begin oled_data <= 16'h018E; end
        if ( y == 41 && x == 18) begin oled_data <= 16'h2336; end
        if ( y == 41 && x == 19) begin oled_data <= 16'h2B56; end
        if ( y == 41 && x == 20) begin oled_data <= 16'h32F0; end
        if ( y == 41 && x == 21) begin oled_data <= 16'h0926; end
        if ( y == 42 && x == 6) begin oled_data <= 16'h29ED; end
        if ( y == 42 && x == 7) begin oled_data <= 16'h09D0; end
        if ( y == 42 && x == 8) begin oled_data <= 16'h137A; end
        if ( y == 42 && x == 9) begin oled_data <= 16'h13DC; end
        if ( y == 42 && x == 10) begin oled_data <= 16'h2BD8; end
        if ( y == 42 && x == 11) begin oled_data <= 16'h01CC; end
        if ( y == 42 && x == 15) begin oled_data <= 16'h21CA; end
        if ( y == 42 && x == 16) begin oled_data <= 16'h196D; end
        if ( y == 42 && x == 17) begin oled_data <= 16'h09B0; end
        if ( y == 42 && x == 18) begin oled_data <= 16'h12B6; end
        if ( y == 42 && x == 19) begin oled_data <= 16'h2BDA; end
        if ( y == 42 && x == 20) begin oled_data <= 16'h2356; end
        if ( y == 42 && x == 21) begin oled_data <= 16'h1A4E; end
        if ( y == 43 && x == 5) begin oled_data <= 16'h2189; end
        if ( y == 43 && x == 6) begin oled_data <= 16'h198E; end
        if ( y == 43 && x == 7) begin oled_data <= 16'h0A34; end
        if ( y == 43 && x == 8) begin oled_data <= 16'h13BC; end
        if ( y == 43 && x == 9) begin oled_data <= 16'h13DC; end
        if ( y == 43 && x == 10) begin oled_data <= 16'h23B8; end
        if ( y == 43 && x == 11) begin oled_data <= 16'h01AC; end
        if ( y == 43 && x == 14) begin oled_data <= 16'h0862; end
        if ( y == 43 && x == 15) begin oled_data <= 16'h3A4B; end
        if ( y == 43 && x == 16) begin oled_data <= 16'h218C; end
        if ( y == 43 && x == 17) begin oled_data <= 16'h1190; end
        if ( y == 43 && x == 18) begin oled_data <= 16'h0235; end
        if ( y == 43 && x == 19) begin oled_data <= 16'h239B; end
        if ( y == 43 && x == 20) begin oled_data <= 16'h23DA; end
        if ( y == 43 && x == 21) begin oled_data <= 16'h1B34; end
        if ( y == 43 && x == 22) begin oled_data <= 16'h0927; end
        if ( y == 44 && x == 4) begin oled_data <= 16'h08A4; end
        if ( y == 44 && x == 5) begin oled_data <= 16'h29EB; end
        if ( y == 44 && x == 6) begin oled_data <= 16'h118F; end
        if ( y == 44 && x == 7) begin oled_data <= 16'h1AB6; end
        if ( y == 44 && x == 8) begin oled_data <= 16'h13FD; end
        if ( y == 44 && x == 9) begin oled_data <= 16'h13DC; end
        if ( y == 44 && x == 10) begin oled_data <= 16'h2397; end
        if ( y == 44 && x == 11) begin oled_data <= 16'h09AC; end
        if ( y == 44 && x == 15) begin oled_data <= 16'h2167; end
        if ( y == 44 && x == 16) begin oled_data <= 16'h29AC; end
        if ( y == 44 && x == 17) begin oled_data <= 16'h118F; end
        if ( y == 44 && x == 18) begin oled_data <= 16'h01B2; end
        if ( y == 44 && x == 19) begin oled_data <= 16'h1B19; end
        if ( y == 44 && x == 20) begin oled_data <= 16'h1BDC; end
        if ( y == 44 && x == 21) begin oled_data <= 16'h1BB8; end
        if ( y == 45 && x == 3) begin oled_data <= 16'h0863; end
        if ( y == 45 && x == 4) begin oled_data <= 16'h21AA; end
        if ( y == 45 && x == 5) begin oled_data <= 16'h19AC; end
        if ( y == 45 && x == 6) begin oled_data <= 16'h0190; end
        if ( y == 45 && x == 7) begin oled_data <= 16'h0276; end
        if ( y == 45 && x == 8) begin oled_data <= 16'h13DC; end
        if ( y == 45 && x == 9) begin oled_data <= 16'h1BFC; end
        if ( y == 45 && x == 10) begin oled_data <= 16'h1AF4; end
        if ( y == 45 && x == 15) begin oled_data <= 16'h0883; end
        if ( y == 45 && x == 16) begin oled_data <= 16'h29CB; end
        if ( y == 45 && x == 17) begin oled_data <= 16'h198E; end
        if ( y == 45 && x == 18) begin oled_data <= 16'h0990; end
        if ( y == 45 && x == 19) begin oled_data <= 16'h0A55; end
        if ( y == 45 && x == 20) begin oled_data <= 16'h1BDC; end
        if ( y == 45 && x == 21) begin oled_data <= 16'h1BDA; end
        if ( y == 45 && x == 22) begin oled_data <= 16'h22D1; end
        if ( y == 46 && x == 2) begin oled_data <= 16'h08A4; end
        if ( y == 46 && x == 4) begin oled_data <= 16'h19AD; end
        if ( y == 46 && x == 5) begin oled_data <= 16'h09D0; end
        if ( y == 46 && x == 6) begin oled_data <= 16'h12F7; end
        if ( y == 46 && x == 7) begin oled_data <= 16'h0319; end
        if ( y == 46 && x == 8) begin oled_data <= 16'h02B8; end
        if ( y == 46 && x == 9) begin oled_data <= 16'h1B99; end
        if ( y == 46 && x == 10) begin oled_data <= 16'h1A70; end
        if ( y == 46 && x == 16) begin oled_data <= 16'h2189; end
        if ( y == 46 && x == 17) begin oled_data <= 16'h21AC; end
        if ( y == 46 && x == 18) begin oled_data <= 16'h198F; end
        if ( y == 46 && x == 19) begin oled_data <= 16'h09B1; end
        if ( y == 46 && x == 20) begin oled_data <= 16'h0AB6; end
        if ( y == 46 && x == 21) begin oled_data <= 16'h02D6; end
        if ( y == 46 && x == 22) begin oled_data <= 16'h0AB3; end
        if ( y == 46 && x == 23) begin oled_data <= 16'h1A90; end
        if ( y == 46 && x == 24) begin oled_data <= 16'h0927; end
        if ( y == 47 && x == 3) begin oled_data <= 16'h21AC; end
        if ( y == 47 && x == 4) begin oled_data <= 16'h098F; end
        if ( y == 47 && x == 5) begin oled_data <= 16'h1AD6; end
        if ( y == 47 && x == 6) begin oled_data <= 16'h1BDB; end
        if ( y == 47 && x == 7) begin oled_data <= 16'h13FC; end
        if ( y == 47 && x == 8) begin oled_data <= 16'h0B7A; end
        if ( y == 47 && x == 9) begin oled_data <= 16'h0AB5; end
        if ( y == 47 && x == 10) begin oled_data <= 16'h098C; end
        if ( y == 47 && x == 16) begin oled_data <= 16'h29AA; end
        if ( y == 47 && x == 17) begin oled_data <= 16'h216B; end
        if ( y == 47 && x == 18) begin oled_data <= 16'h218E; end
        if ( y == 47 && x == 19) begin oled_data <= 16'h116F; end
        if ( y == 47 && x == 20) begin oled_data <= 16'h0213; end
        if ( y == 47 && x == 21) begin oled_data <= 16'h2379; end
        if ( y == 47 && x == 22) begin oled_data <= 16'h23BA; end
        if ( y == 47 && x == 23) begin oled_data <= 16'h2376; end
        if ( y == 47 && x == 24) begin oled_data <= 16'h2AF0; end
        if ( y == 47 && x == 25) begin oled_data <= 16'h19C9; end
        if ( y == 48 && x == 1) begin oled_data <= 16'h29A9; end
        if ( y == 48 && x == 2) begin oled_data <= 16'h29AC; end
        if ( y == 48 && x == 3) begin oled_data <= 16'h198E; end
        if ( y == 48 && x == 4) begin oled_data <= 16'h0A13; end
        if ( y == 48 && x == 5) begin oled_data <= 16'h237A; end
        if ( y == 48 && x == 6) begin oled_data <= 16'h1BFC; end
        if ( y == 48 && x == 7) begin oled_data <= 16'h13DC; end
        if ( y == 48 && x == 8) begin oled_data <= 16'h1BFC; end
        if ( y == 48 && x == 9) begin oled_data <= 16'h1B37; end
        if ( y == 48 && x == 10) begin oled_data <= 16'h19CC; end
        if ( y == 48 && x == 16) begin oled_data <= 16'h218A; end
        if ( y == 48 && x == 17) begin oled_data <= 16'h218C; end
        if ( y == 48 && x == 18) begin oled_data <= 16'h196D; end
        if ( y == 48 && x == 19) begin oled_data <= 16'h116F; end
        if ( y == 48 && x == 20) begin oled_data <= 16'h1276; end
        if ( y == 48 && x == 21) begin oled_data <= 16'h23BC; end
        if ( y == 48 && x == 22) begin oled_data <= 16'h1BDC; end
        if ( y == 48 && x == 23) begin oled_data <= 16'h23FA; end
        if ( y == 48 && x == 24) begin oled_data <= 16'h2BB7; end
        if ( y == 48 && x == 25) begin oled_data <= 16'h2AF1; end
        if ( y == 49 && x == 1) begin oled_data <= 16'h2147; end
        if ( y == 49 && x == 2) begin oled_data <= 16'h218C; end
        if ( y == 49 && x == 3) begin oled_data <= 16'h116F; end
        if ( y == 49 && x == 4) begin oled_data <= 16'h0A14; end
        if ( y == 49 && x == 5) begin oled_data <= 16'h1339; end
        if ( y == 49 && x == 6) begin oled_data <= 16'h0339; end
        if ( y == 49 && x >= 7 && x <= 8) begin oled_data <= 16'h035A; end
        if ( y == 49 && x == 9) begin oled_data <= 16'h1316; end
        if ( y == 49 && x == 10) begin oled_data <= 16'h19EC; end
        if ( y == 49 && x == 16) begin oled_data <= 16'h216A; end
        if ( y == 49 && x == 17) begin oled_data <= 16'h218C; end
        if ( y == 49 && x == 18) begin oled_data <= 16'h196C; end
        if ( y == 49 && x == 19) begin oled_data <= 16'h118F; end
        if ( y == 49 && x == 20) begin oled_data <= 16'h01F4; end
        if ( y == 49 && x == 21) begin oled_data <= 16'h02D9; end
        if ( y == 49 && x == 22) begin oled_data <= 16'h0339; end
        if ( y == 49 && x == 23) begin oled_data <= 16'h0338; end
        if ( y == 49 && x == 24) begin oled_data <= 16'h0B37; end
        if ( y == 49 && x == 25) begin oled_data <= 16'h0A71; end
        
        //colour of the laser
        if (sw[5] == 0 && sw[4] == 0) 
            begin
                outer_laser_colour <= 16'h049F;
                mid_laser_colour <= 16'h05FF;
                inner_laser_colour <= 16'h8FFF;
            end
        if (sw[5] == 0 && sw[4] == 1)
            begin
                outer_laser_colour <= 16'hF8A2;
                mid_laser_colour <= 16'hFCB2;
                inner_laser_colour <= 16'hFE9A;            
            end
        if (sw[5] == 1 && sw[4] == 0)
            begin
                outer_laser_colour <= 16'h47E3;
                mid_laser_colour <= 16'hAFF3;
                inner_laser_colour <= 16'hCFF8;  
            end
        if (sw[5] == 1 && sw[4] == 1)
            begin
                outer_laser_colour <= 16'hD05F;
                mid_laser_colour <= 16'hECBF;
                inner_laser_colour <= 16'hFEDF;             
            end
        
        
        laser_end <= (40 + (led_count*3));
        //laser animation
        if ( y >= 32 && y <= 37 && x >= 30 && x <= 31) begin oled_data <= outer_laser_colour; end
        if ( y >= 33 && y <= 36 && x == 29) begin oled_data <= outer_laser_colour; end
        if ( y >= 34 && y <= 35 && x == 28) begin oled_data <= outer_laser_colour; end
        if ( y == 32 && x >= 32 && x <= 33) begin oled_data <= outer_laser_colour; end
        if ( y == 37 && x >= 32 && x <= 33) begin oled_data <= outer_laser_colour; end
        if ( y >= 33 && y <= 36 && x >= 32 && x <= 33) begin oled_data <= mid_laser_colour; end
        
        if ( y == 32 && x >= 34 && x <= laser_end) begin oled_data <= outer_laser_colour; end
        if ( y == 33 && x >= 34 && x <= laser_end) begin oled_data <= mid_laser_colour; end 
        if ( y >= 34 && y <= 35 && x >= 34 && x <= laser_end) begin oled_data <= inner_laser_colour; end
        if ( y == 36 && x >= 34 && x <= laser_end) begin oled_data <= mid_laser_colour; end
        if ( y == 37 && x >= 34 && x <= laser_end) begin oled_data <= outer_laser_colour; end
        
        if ( y == 32 && x > laser_end && x <= (laser_end + 4)) begin oled_data <= outer_laser_colour; end
        if ( y >= 33 && y <= 36 && x > laser_end && x <= (laser_end + 2)) begin oled_data <= mid_laser_colour; end
        if ( y >= 33 && y <= 36 && x >= (laser_end + 3) && x <= (laser_end + 6)) begin oled_data <= outer_laser_colour; end
        if ( y == 34 && y == 35 && x == (laser_end + 6)) begin oled_data <= outer_laser_colour; end    
        if ( y == 37 && x > laser_end && x <= (laser_end + 4)) begin oled_data <= outer_laser_colour; end
        
        //burst animation
        if (laser_end >= (90 - virus_counter))
        begin
            virus_counter <= 0;
            virus_death_counter <= virus_death_counter + 1;
        end
        
        
        end
        case (virus_death_counter)
                            4'd0:
                            begin
                                if ( y >= 3 && y <= 7 && x >= 87 && x <= 88) begin oled_data <= 16'hFFFF; end
                                if ( y >= 7 && y <= 12 && x >= 87 && x <= 88) begin oled_data <= 16'hFFFF; end
                                if ( y >= 3 && y <= 4 && x >= 89 && x <= 90) begin oled_data <= 16'hFFFF; end
                                if ( y >= 7 && y <= 8 && x >= 89 && x <= 90) begin oled_data <= 16'h0000; end
                                if ( y >= 11 && y <= 12 && x >= 89 && x <= 90) begin oled_data <= 16'hFFFF; end
                                if ( y >= 3 && y <= 7 && x >= 91 && x <= 92) begin oled_data <= 16'hFFFF; end
                                if ( y >= 7 && y <= 12 && x >= 91 && x <= 92) begin oled_data <= 16'hFFFF; end
                            end
                            4'd1:
                            begin
                                if ( y >= 3 && y <= 7 && x >= 87 && x <= 88) begin oled_data <= 16'h0000; end
                                if ( y >= 7 && y <= 12 && x >= 87 && x <= 88) begin oled_data <= 16'h0000; end
                                if ( y >= 3 && y <= 4 && x >= 89 && x <= 90) begin oled_data <= 16'h0000; end
                                if ( y >= 7 && y <= 8 && x >= 89 && x <= 90) begin oled_data <= 16'h0000; end
                                if ( y >= 11 && y <= 12 && x >= 89 && x <= 90) begin oled_data <= 16'h0000; end
                                if ( y >= 3 && y <= 7 && x >= 91 && x <= 92) begin oled_data <= 16'hFFFF; end
                                if ( y >= 7 && y <= 12 && x >= 91 && x <= 92) begin oled_data <= 16'hFFFF; end
                            end
                            4'd2:
                            begin
                                if ( y >= 3 && y <= 7 && x >= 87 && x <= 88) begin oled_data <= 16'h0000; end
                                if ( y >= 7 && y <= 12 && x >= 87 && x <= 88) begin oled_data <= 16'hFFFF; end
                                if ( y >= 3 && y <= 4 && x >= 89 && x <= 90) begin oled_data <= 16'hFFFF; end
                                if ( y >= 7 && y <= 8 && x >= 89 && x <= 90) begin oled_data <= 16'hFFFF; end
                                if ( y >= 11 && y <= 12 && x >= 89 && x <= 90) begin oled_data <= 16'hFFFF; end
                                if ( y >= 3 && y <= 7 && x >= 91 && x <= 92) begin oled_data <= 16'hFFFF; end
                                if ( y >= 7 && y <= 12 && x >= 91 && x <= 92) begin oled_data <= 16'h0000; end                          
                            end
                            4'd3:
                            begin
                                if ( y >= 3 && y <= 7 && x >= 87 && x <= 88) begin oled_data <= 16'h0000; end
                                if ( y >= 7 && y <= 12 && x >= 87 && x <= 88) begin oled_data <= 16'h0000; end
                                if ( y >= 3 && y <= 4 && x >= 89 && x <= 90) begin oled_data <= 16'hFFFF; end
                                if ( y >= 7 && y <= 8 && x >= 89 && x <= 90) begin oled_data <= 16'hFFFF; end
                                if ( y >= 11 && y <= 12 && x >= 89 && x <= 90) begin oled_data <= 16'hFFFF; end
                                if ( y >= 3 && y <= 7 && x >= 91 && x <= 92) begin oled_data <= 16'hFFFF; end
                                if ( y >= 7 && y <= 12 && x >= 91 && x <= 92) begin oled_data <= 16'hFFFF; end  
                            end
                            4'd4:
                            begin
                                if ( y >= 3 && y <= 7 && x >= 87 && x <= 88) begin oled_data <= 16'hFFFF; end
                                if ( y >= 7 && y <= 12 && x >= 87 && x <= 88) begin oled_data <= 16'h0000; end
                                if ( y >= 3 && y <= 4 && x >= 89 && x <= 90) begin oled_data <= 16'h0000; end
                                if ( y >= 7 && y <= 8 && x >= 89 && x <= 90) begin oled_data <= 16'hFFFF; end
                                if ( y >= 11 && y <= 12 && x >= 89 && x <= 90) begin oled_data <= 16'h0000; end
                                if ( y >= 3 && y <= 7 && x >= 91 && x <= 92) begin oled_data <= 16'hFFFF; end
                                if ( y >= 7 && y <= 12 && x >= 91 && x <= 92) begin oled_data <= 16'hFFFF; end                                                                                       
                            end
                            4'd5:
                            begin
                                if ( y >= 3 && y <= 7 && x >= 87 && x <= 88) begin oled_data <= 16'hFFFF; end
                                if ( y >= 7 && y <= 12 && x >= 87 && x <= 88) begin oled_data <= 16'h0000; end
                                if ( y >= 3 && y <= 4 && x >= 89 && x <= 90) begin oled_data <= 16'hFFFF; end
                                if ( y >= 7 && y <= 8 && x >= 89 && x <= 90) begin oled_data <= 16'hFFFF; end
                                if ( y >= 11 && y <= 12 && x >= 89 && x <= 90) begin oled_data <= 16'hFFFF; end
                                if ( y >= 3 && y <= 7 && x >= 91 && x <= 92) begin oled_data <= 16'h0000; end
                                if ( y >= 7 && y <= 12 && x >= 91 && x <= 92) begin oled_data <= 16'hFFFF; end                                                                                       
                            end
                            4'd6:
                            begin
                                if ( y >= 3 && y <= 7 && x >= 87 && x <= 88) begin oled_data <= 16'hFFFF; end
                                if ( y >= 7 && y <= 12 && x >= 87 && x <= 88) begin oled_data <= 16'hFFFF; end
                                if ( y >= 3 && y <= 4 && x >= 89 && x <= 90) begin oled_data <= 16'hFFFF; end
                                if ( y >= 7 && y <= 8 && x >= 89 && x <= 90) begin oled_data <= 16'hFFFF; end
                                if ( y >= 11 && y <= 12 && x >= 89 && x <= 90) begin oled_data <= 16'hFFFF; end
                                if ( y >= 3 && y <= 7 && x >= 91 && x <= 92) begin oled_data <= 16'h0000; end
                                if ( y >= 7 && y <= 12 && x >= 91 && x <= 92) begin oled_data <= 16'hFFFF; end                                                                                       
                            end
                            4'd7:
                            begin
                                if ( y >= 3 && y <= 7 && x >= 87 && x <= 88) begin oled_data <= 16'h0000; end
                                if ( y >= 7 && y <= 12 && x >= 87 && x <= 88) begin oled_data <= 16'h0000; end
                                if ( y >= 3 && y <= 4 && x >= 89 && x <= 90) begin oled_data <= 16'hFFFF; end
                                if ( y >= 7 && y <= 8 && x >= 89 && x <= 90) begin oled_data <= 16'h0000; end
                                if ( y >= 11 && y <= 12 && x >= 89 && x <= 90) begin oled_data <= 16'h0000; end
                                if ( y >= 3 && y <= 7 && x >= 91 && x <= 92) begin oled_data <= 16'hFFFF; end
                                if ( y >= 7 && y <= 12 && x >= 91 && x <= 92) begin oled_data <= 16'hFFFF; end                                                                                       
                            end
                            4'd8:
                            begin
                                if ( y >= 3 && y <= 7 && x >= 87 && x <= 88) begin oled_data <= 16'hFFFF; end
                                if ( y >= 7 && y <= 12 && x >= 87 && x <= 88) begin oled_data <= 16'hFFFF; end
                                if ( y >= 3 && y <= 4 && x >= 89 && x <= 90) begin oled_data <= 16'hFFFF; end
                                if ( y >= 7 && y <= 8 && x >= 89 && x <= 90) begin oled_data <= 16'hFFFF; end
                                if ( y >= 11 && y <= 12 && x >= 89 && x <= 90) begin oled_data <= 16'hFFFF; end
                                if ( y >= 3 && y <= 7 && x >= 91 && x <= 92) begin oled_data <= 16'hFFFF; end
                                if ( y >= 7 && y <= 12 && x >= 91 && x <= 92) begin oled_data <= 16'hFFFF; end                                                                                       
                            end
                            4'd9:
                            begin
                                if ( y >= 3 && y <= 7 && x >= 87 && x <= 88) begin oled_data <= 16'hFFFF; end
                                if ( y >= 7 && y <= 12 && x >= 87 && x <= 88) begin oled_data <= 16'h0000; end
                                if ( y >= 3 && y <= 4 && x >= 89 && x <= 90) begin oled_data <= 16'hFFFF; end
                                if ( y >= 7 && y <= 8 && x >= 89 && x <= 90) begin oled_data <= 16'hFFFF; end
                                if ( y >= 11 && y <= 12 && x >= 89 && x <= 90) begin oled_data <= 16'h0000; end
                                if ( y >= 3 && y <= 7 && x >= 91 && x <= 92) begin oled_data <= 16'hFFFF; end
                                if ( y >= 7 && y <= 12 && x >= 91 && x <= 92) begin oled_data <= 16'hFFFF; end                                                                                       
                            end
                            4'd10:
                            begin
                                //one
                                if ( y >= 3 && y <= 12 && x >= 83 && x <= 84) begin oled_data <= 16'hFFFF; end
                                //zero
                                if ( y >= 3 && y <= 7 && x >= 87 && x <= 88) begin oled_data <= 16'hFFFF; end
                                if ( y >= 7 && y <= 12 && x >= 87 && x <= 88) begin oled_data <= 16'hFFFF; end
                                if ( y >= 3 && y <= 4 && x >= 89 && x <= 90) begin oled_data <= 16'hFFFF; end
                                if ( y >= 7 && y <= 8 && x >= 89 && x <= 90) begin oled_data <= 16'h0000; end
                                if ( y >= 11 && y <= 12 && x >= 89 && x <= 90) begin oled_data <= 16'hFFFF; end
                                if ( y >= 3 && y <= 7 && x >= 91 && x <= 92) begin oled_data <= 16'hFFFF; end
                                if ( y >= 7 && y <= 12 && x >= 91 && x <= 92) begin oled_data <= 16'hFFFF; end 
                                //game end
                                gameStart <= 0;                                                                                    
                            end            
                        endcase    
        
        end
    else if (dead == 0 && gameStart == 0)
    begin
    winCounter <= winCounter + 1;
    //stage complete image
    if (winCounter == 23'd6250000)
    begin
    if ( y == 17 && x == 45 ) begin oled_data <= 16'h0841; end
    if ( y == 17 && x == 53 ) begin oled_data <= 16'h0841; end
    if ( y == 18 && x == 28 ) begin oled_data <= 16'h0841; end
    if ( y == 19 && x == 37 ) begin oled_data <= 16'h0841; end
    if ( y == 19 && x == 41 ) begin oled_data <= 16'h0841; end
    if ( y == 20 && x == 26 ) begin oled_data <= 16'h0841; end
    if ( y == 20 && x == 47 ) begin oled_data <= 16'h0861; end
    if ( y == 20 && x == 49 ) begin oled_data <= 16'h0841; end
    if ( y == 21 && x == 34 ) begin oled_data <= 16'h18E3; end
    if ( y == 21 && x == 37 ) begin oled_data <= 16'h0861; end
    if ( y == 21 && x == 38 ) begin oled_data <= 16'h18E3; end
    if ( y == 21 && x >= 39 && x <= 41 ) begin oled_data <= 16'h18C3; end
    if ( y == 21 && x == 46 ) begin oled_data <= 16'h18C3; end
    if ( y == 21 && x == 47 ) begin oled_data <= 16'h0841; end
    if ( y == 21 && x == 55 ) begin oled_data <= 16'h18C3; end
    if ( y == 21 && x == 62 ) begin oled_data <= 16'h18E3; end
    if ( y == 21 && x == 65 ) begin oled_data <= 16'h18E3; end
    if ( y == 21 && x == 66 ) begin oled_data <= 16'h18C3; end
    if ( y == 21 && x == 68 ) begin oled_data <= 16'h2104; end
    if ( y == 21 && x == 69 ) begin oled_data <= 16'h18C3; end
    if ( y == 22 && x == 27 ) begin oled_data <= 16'h52AA; end
    if ( y == 22 && x == 28 ) begin oled_data <= 16'h9CF3; end
    if ( y == 22 && x == 29 ) begin oled_data <= 16'hC638; end
    if ( y == 22 && x == 30 ) begin oled_data <= 16'hCE59; end
    if ( y == 22 && x == 31 ) begin oled_data <= 16'hBDD7; end
    if ( y == 22 && x == 32 ) begin oled_data <= 16'h8410; end
    if ( y == 22 && x == 33 ) begin oled_data <= 16'h4208; end
    if ( y == 22 && x == 34 ) begin oled_data <= 16'h8C71; end
    if ( y == 22 && x == 35 ) begin oled_data <= 16'hC638; end
    if ( y == 22 && x >= 36 && x <= 37 ) begin oled_data <= 16'hD6BA; end
    if ( y == 22 && x == 38 ) begin oled_data <= 16'hC618; end
    if ( y == 22 && x == 39 ) begin oled_data <= 16'hD69A; end
    if ( y == 22 && x == 40 ) begin oled_data <= 16'hCE59; end
    if ( y == 22 && x == 41 ) begin oled_data <= 16'hAD75; end
    if ( y == 22 && x == 42 ) begin oled_data <= 16'h2104; end
    if ( y == 22 && x == 44 ) begin oled_data <= 16'h0861; end
    if ( y == 22 && x == 45 ) begin oled_data <= 16'h7BEF; end
    if ( y == 22 && x == 46 ) begin oled_data <= 16'hCE79; end
    if ( y == 22 && x == 47 ) begin oled_data <= 16'hB596; end
    if ( y == 22 && x == 48 ) begin oled_data <= 16'h18E3; end
    if ( y == 22 && x == 52 ) begin oled_data <= 16'h0841; end
    if ( y == 22 && x == 53 ) begin oled_data <= 16'h4A69; end
    if ( y == 22 && x == 54 ) begin oled_data <= 16'h94B2; end
    if ( y == 22 && x == 55 ) begin oled_data <= 16'hC618; end
    if ( y == 22 && x == 56 ) begin oled_data <= 16'hD69A; end
    if ( y == 22 && x == 57 ) begin oled_data <= 16'hB5B6; end
    if ( y == 22 && x == 58 ) begin oled_data <= 16'h8410; end
    if ( y == 22 && x == 59 ) begin oled_data <= 16'h39C7; end
    if ( y == 22 && x == 61 ) begin oled_data <= 16'h2104; end
    if ( y == 22 && x == 62 ) begin oled_data <= 16'hAD75; end
    if ( y == 22 && x == 63 ) begin oled_data <= 16'hD6BA; end
    if ( y == 22 && x == 64 ) begin oled_data <= 16'hD69A; end
    if ( y == 22 && x == 65 ) begin oled_data <= 16'hC618; end
    if ( y == 22 && x == 66 ) begin oled_data <= 16'hCE59; end
    if ( y == 22 && x == 67 ) begin oled_data <= 16'hD69A; end
    if ( y == 22 && x == 68 ) begin oled_data <= 16'hC638; end
    if ( y == 22 && x == 69 ) begin oled_data <= 16'h6B4D; end
    if ( y == 23 && x == 26 ) begin oled_data <= 16'h2104; end
    if ( y == 23 && x == 27 ) begin oled_data <= 16'hC638; end
    if ( y == 23 && x == 28 ) begin oled_data <= 16'hDEDB; end
    if ( y == 23 && x == 29 ) begin oled_data <= 16'h9CD3; end
    if ( y == 23 && x == 30 ) begin oled_data <= 16'h8C51; end
    if ( y == 23 && x == 31 ) begin oled_data <= 16'hAD75; end
    if ( y == 23 && x == 32 ) begin oled_data <= 16'hDEDB; end
    if ( y == 23 && x == 33 ) begin oled_data <= 16'hA534; end
    if ( y == 23 && x == 34 ) begin oled_data <= 16'h630C; end
    if ( y == 23 && x == 35 ) begin oled_data <= 16'h8430; end
    if ( y == 23 && x == 36 ) begin oled_data <= 16'h8C51; end
    if ( y == 23 && x == 37 ) begin oled_data <= 16'hCE79; end
    if ( y == 23 && x == 38 ) begin oled_data <= 16'hFFDF; end
    if ( y == 23 && x == 39 ) begin oled_data <= 16'h9CD3; end
    if ( y == 23 && x == 40 ) begin oled_data <= 16'h8C51; end
    if ( y == 23 && x == 41 ) begin oled_data <= 16'h8410; end
    if ( y == 23 && x == 42 ) begin oled_data <= 16'h18C3; end
    if ( y == 23 && x == 45 ) begin oled_data <= 16'hAD55; end
    if ( y == 23 && x == 46 ) begin oled_data <= 16'hFFFF; end
    if ( y == 23 && x == 47 ) begin oled_data <= 16'hE73C; end
    if ( y == 23 && x == 48 ) begin oled_data <= 16'h4208; end
    if ( y == 23 && x == 51 ) begin oled_data <= 16'h0841; end
    if ( y == 23 && x == 52 ) begin oled_data <= 16'h528A; end
    if ( y == 23 && x == 53 ) begin oled_data <= 16'hD6BA; end
    if ( y == 23 && x == 54 ) begin oled_data <= 16'hDEFB; end
    if ( y == 23 && x == 55 ) begin oled_data <= 16'hA514; end
    if ( y == 23 && x == 56 ) begin oled_data <= 16'h8430; end
    if ( y == 23 && x == 57 ) begin oled_data <= 16'hAD75; end
    if ( y == 23 && x == 58 ) begin oled_data <= 16'hDEFB; end
    if ( y == 23 && x == 59 ) begin oled_data <= 16'hA534; end
    if ( y == 23 && x == 61 ) begin oled_data <= 16'h18C3; end
    if ( y == 23 && x == 62 ) begin oled_data <= 16'hCE59; end
    if ( y == 23 && x == 63 ) begin oled_data <= 16'hEF5D; end
    if ( y == 23 && x == 64 ) begin oled_data <= 16'h94B2; end
    if ( y == 23 && x == 65 ) begin oled_data <= 16'h8C71; end
    if ( y == 23 && x == 66 ) begin oled_data <= 16'h8C51; end
    if ( y == 23 && x == 67 ) begin oled_data <= 16'h8410; end
    if ( y == 23 && x == 68 ) begin oled_data <= 16'h8C71; end
    if ( y == 23 && x == 69 ) begin oled_data <= 16'h5ACB; end
    if ( y == 24 && x == 26 ) begin oled_data <= 16'h2945; end
    if ( y == 24 && x == 27 ) begin oled_data <= 16'hDEDB; end
    if ( y == 24 && x == 28 ) begin oled_data <= 16'hBDF7; end
    if ( y == 24 && x == 29 ) begin oled_data <= 16'h528A; end
    if ( y == 24 && x == 30 ) begin oled_data <= 16'h39E7; end
    if ( y == 24 && x == 31 ) begin oled_data <= 16'h3186; end
    if ( y == 24 && x == 32 ) begin oled_data <= 16'h4228; end
    if ( y == 24 && x == 33 ) begin oled_data <= 16'h4208; end
    if ( y == 24 && x == 34 ) begin oled_data <= 16'h0841; end
    if ( y == 24 && x == 36 ) begin oled_data <= 16'h0861; end
    if ( y == 24 && x == 37 ) begin oled_data <= 16'hB596; end
    if ( y == 24 && x == 38 ) begin oled_data <= 16'hF7BE; end
    if ( y == 24 && x == 39 ) begin oled_data <= 16'h5ACB; end
    if ( y == 24 && x == 44 ) begin oled_data <= 16'h4A69; end
    if ( y == 24 && x == 45 ) begin oled_data <= 16'hDEDB; end
    if ( y == 24 && x == 46 ) begin oled_data <= 16'hBDD7; end
    if ( y == 24 && x == 47 ) begin oled_data <= 16'hF79E; end
    if ( y == 24 && x == 48 ) begin oled_data <= 16'hA534; end
    if ( y == 24 && x == 49 ) begin oled_data <= 16'h0841; end
    if ( y == 24 && x == 51 ) begin oled_data <= 16'h2104; end
    if ( y == 24 && x == 52 ) begin oled_data <= 16'hC618; end
    if ( y == 24 && x == 53 ) begin oled_data <= 16'hDEFB; end
    if ( y == 24 && x == 54 ) begin oled_data <= 16'h5AEB; end
    if ( y == 24 && x == 58 ) begin oled_data <= 16'h4A49; end
    if ( y == 24 && x == 59 ) begin oled_data <= 16'h5AEB; end
    if ( y == 24 && x == 61 ) begin oled_data <= 16'h18C3; end
    if ( y == 24 && x == 62 ) begin oled_data <= 16'hCE59; end
    if ( y == 24 && x == 63 ) begin oled_data <= 16'hEF5D; end
    if ( y == 24 && x == 64 ) begin oled_data <= 16'h738E; end
    if ( y == 24 && x == 65 ) begin oled_data <= 16'h4A49; end
    if ( y == 24 && x == 66 ) begin oled_data <= 16'h4228; end
    if ( y == 24 && x == 67 ) begin oled_data <= 16'h39C7; end
    if ( y == 24 && x == 69 ) begin oled_data <= 16'h0861; end
    if ( y == 25 && x == 27 ) begin oled_data <= 16'h9492; end
    if ( y == 25 && x == 28 ) begin oled_data <= 16'hDEDB; end
    if ( y == 25 && x >= 29 && x <= 30 ) begin oled_data <= 16'hD6BA; end
    if ( y == 25 && x == 31 ) begin oled_data <= 16'hCE59; end
    if ( y == 25 && x == 32 ) begin oled_data <= 16'hAD55; end
    if ( y == 25 && x == 33 ) begin oled_data <= 16'h3186; end
    if ( y == 25 && x == 37 ) begin oled_data <= 16'hB596; end
    if ( y == 25 && x == 38 ) begin oled_data <= 16'hF7BE; end
    if ( y == 25 && x == 39 ) begin oled_data <= 16'h52AA; end
    if ( y == 25 && x == 44 ) begin oled_data <= 16'hA534; end
    if ( y == 25 && x == 45 ) begin oled_data <= 16'hD6BA; end
    if ( y == 25 && x == 46 ) begin oled_data <= 16'h4228; end
    if ( y == 25 && x == 47 ) begin oled_data <= 16'hB596; end
    if ( y == 25 && x == 48 ) begin oled_data <= 16'hE71C; end
    if ( y == 25 && x == 49 ) begin oled_data <= 16'h4228; end
    if ( y == 25 && x == 51 ) begin oled_data <= 16'h31A6; end
    if ( y == 25 && x == 52 ) begin oled_data <= 16'hE71C; end
    if ( y == 25 && x == 53 ) begin oled_data <= 16'hB5B6; end
    if ( y == 25 && x == 56 ) begin oled_data <= 16'h31A6; end
    if ( y == 25 && x >= 57 && x <= 59 ) begin oled_data <= 16'h2945; end
    if ( y == 25 && x == 62 ) begin oled_data <= 16'hD69A; end
    if ( y == 25 && x == 63 ) begin oled_data <= 16'hF7BE; end
    if ( y == 25 && x >= 64 && x <= 65 ) begin oled_data <= 16'hDEFB; end
    if ( y == 25 && x == 66 ) begin oled_data <= 16'hDEDB; end
    if ( y == 25 && x == 67 ) begin oled_data <= 16'hA514; end
    if ( y == 25 && x == 68 ) begin oled_data <= 16'h0861; end
    if ( y == 26 && x == 28 ) begin oled_data <= 16'h31A6; end
    if ( y == 26 && x == 29 ) begin oled_data <= 16'h52AA; end
    if ( y == 26 && x == 30 ) begin oled_data <= 16'h73AE; end
    if ( y == 26 && x == 31 ) begin oled_data <= 16'h9CD3; end
    if ( y == 26 && x == 32 ) begin oled_data <= 16'hEF5D; end
    if ( y == 26 && x == 33 ) begin oled_data <= 16'hA534; end
    if ( y == 26 && x == 37 ) begin oled_data <= 16'hB5B6; end
    if ( y == 26 && x == 38 ) begin oled_data <= 16'hF7BE; end
    if ( y == 26 && x == 39 ) begin oled_data <= 16'h52AA; end
    if ( y == 26 && x == 43 ) begin oled_data <= 16'h4A69; end
    if ( y == 26 && x == 44 ) begin oled_data <= 16'hE71C; end
    if ( y == 26 && x == 45 ) begin oled_data <= 16'hDEFB; end
    if ( y == 26 && x == 46 ) begin oled_data <= 16'h8C71; end
    if ( y == 26 && x == 47 ) begin oled_data <= 16'hBDF7; end
    if ( y == 26 && x == 48 ) begin oled_data <= 16'hFFFF; end
    if ( y == 26 && x == 49 ) begin oled_data <= 16'hA514; end
    if ( y == 26 && x == 50 ) begin oled_data <= 16'h0861; end
    if ( y == 26 && x == 51 ) begin oled_data <= 16'h3186; end
    if ( y == 26 && x == 52 ) begin oled_data <= 16'hE73C; end
    if ( y == 26 && x == 53 ) begin oled_data <= 16'hB5B6; end
    if ( y == 26 && x == 54 ) begin oled_data <= 16'h0861; end
    if ( y == 26 && x == 55 ) begin oled_data <= 16'h0841; end
    if ( y == 26 && x == 56 ) begin oled_data <= 16'h94B2; end
    if ( y == 26 && x == 57 ) begin oled_data <= 16'hD69A; end
    if ( y == 26 && x == 58 ) begin oled_data <= 16'hDEFB; end
    if ( y == 26 && x == 59 ) begin oled_data <= 16'hD6BA; end
    if ( y == 26 && x == 60 ) begin oled_data <= 16'h5AEB; end
    if ( y == 26 && x == 61 ) begin oled_data <= 16'h18E3; end
    if ( y == 26 && x == 62 ) begin oled_data <= 16'hC618; end
    if ( y == 26 && x == 63 ) begin oled_data <= 16'hE73C; end
    if ( y == 26 && x == 64 ) begin oled_data <= 16'h738E; end
    if ( y == 26 && x == 65 ) begin oled_data <= 16'h4228; end
    if ( y == 26 && x >= 66 && x <= 67 ) begin oled_data <= 16'h4A49; end
    if ( y == 27 && x == 26 ) begin oled_data <= 16'h31A6; end
    if ( y == 27 && x == 27 ) begin oled_data <= 16'h73AE; end
    if ( y == 27 && x == 28 ) begin oled_data <= 16'h39E7; end
    if ( y == 27 && x == 29 ) begin oled_data <= 16'h0861; end
    if ( y == 27 && x == 31 ) begin oled_data <= 16'h4A49; end
    if ( y == 27 && x == 32 ) begin oled_data <= 16'hDEFB; end
    if ( y == 27 && x == 33 ) begin oled_data <= 16'hCE59; end
    if ( y == 27 && x == 34 ) begin oled_data <= 16'h0841; end
    if ( y == 27 && x == 37 ) begin oled_data <= 16'hB5B6; end
    if ( y == 27 && x == 38 ) begin oled_data <= 16'hEF5D; end
    if ( y == 27 && x == 39 ) begin oled_data <= 16'h5ACB; end
    if ( y == 27 && x == 43 ) begin oled_data <= 16'hAD55; end
    if ( y == 27 && x == 44 ) begin oled_data <= 16'hE73C; end
    if ( y == 27 && x == 45 ) begin oled_data <= 16'hC618; end
    if ( y == 27 && x == 46 ) begin oled_data <= 16'hBDF7; end
    if ( y == 27 && x == 47 ) begin oled_data <= 16'hC618; end
    if ( y == 27 && x == 48 ) begin oled_data <= 16'hDEFB; end
    if ( y == 27 && x == 49 ) begin oled_data <= 16'hEF7D; end
    if ( y == 27 && x == 50 ) begin oled_data <= 16'h528A; end
    if ( y == 27 && x == 52 ) begin oled_data <= 16'hBDD7; end
    if ( y == 27 && x == 53 ) begin oled_data <= 16'hF7BE; end
    if ( y == 27 && x == 54 ) begin oled_data <= 16'h6B6D; end
    if ( y == 27 && x == 55 ) begin oled_data <= 16'h18C3; end
    if ( y == 27 && x == 56 ) begin oled_data <= 16'h52AA; end
    if ( y == 27 && x == 57 ) begin oled_data <= 16'h7BCF; end
    if ( y == 27 && x == 58 ) begin oled_data <= 16'hAD55; end
    if ( y == 27 && x == 59 ) begin oled_data <= 16'hF79E; end
    if ( y == 27 && x == 60 ) begin oled_data <= 16'h630C; end
    if ( y == 27 && x == 61 ) begin oled_data <= 16'h18E3; end
    if ( y == 27 && x == 62 ) begin oled_data <= 16'hC638; end
    if ( y == 27 && x == 63 ) begin oled_data <= 16'hEF5D; end
    if ( y == 27 && x == 64 ) begin oled_data <= 16'h4A49; end
    if ( y == 28 && x == 26 ) begin oled_data <= 16'h52AA; end
    if ( y == 28 && x == 27 ) begin oled_data <= 16'hDEFB; end
    if ( y == 28 && x == 28 ) begin oled_data <= 16'hD69A; end
    if ( y == 28 && x == 29 ) begin oled_data <= 16'hB5B6; end
    if ( y == 28 && x == 30 ) begin oled_data <= 16'hA534; end
    if ( y == 28 && x == 31 ) begin oled_data <= 16'hCE79; end
    if ( y == 28 && x == 32 ) begin oled_data <= 16'hE71C; end
    if ( y == 28 && x == 33 ) begin oled_data <= 16'h7BEF; end
    if ( y == 28 && x == 34 ) begin oled_data <= 16'h0861; end
    if ( y == 28 && x == 37 ) begin oled_data <= 16'hB596; end
    if ( y == 28 && x == 38 ) begin oled_data <= 16'hEF7D; end
    if ( y == 28 && x == 39 ) begin oled_data <= 16'h52AA; end
    if ( y == 28 && x == 42 ) begin oled_data <= 16'h52AA; end
    if ( y == 28 && x == 43 ) begin oled_data <= 16'hDEFB; end
    if ( y == 28 && x == 44 ) begin oled_data <= 16'hA534; end
    if ( y == 28 && x == 45 ) begin oled_data <= 16'h18E3; end
    if ( y == 28 && x == 47 ) begin oled_data <= 16'h0861; end
    if ( y == 28 && x == 48 ) begin oled_data <= 16'h73AE; end
    if ( y == 28 && x == 49 ) begin oled_data <= 16'hF7BE; end
    if ( y == 28 && x == 50 ) begin oled_data <= 16'hAD75; end
    if ( y == 28 && x == 51 ) begin oled_data <= 16'h0841; end
    if ( y == 28 && x == 52 ) begin oled_data <= 16'h39E7; end
    if ( y == 28 && x == 53 ) begin oled_data <= 16'hC638; end
    if ( y == 28 && x == 54 ) begin oled_data <= 16'hE71C; end
    if ( y == 28 && x == 55 ) begin oled_data <= 16'hC618; end
    if ( y == 28 && x == 56 ) begin oled_data <= 16'hAD55; end
    if ( y == 28 && x == 57 ) begin oled_data <= 16'hA534; end
    if ( y == 28 && x == 58 ) begin oled_data <= 16'hC638; end
    if ( y == 28 && x == 59 ) begin oled_data <= 16'hD69A; end
    if ( y == 28 && x == 60 ) begin oled_data <= 16'h5ACB; end
    if ( y == 28 && x == 61 ) begin oled_data <= 16'h2104; end
    if ( y == 28 && x == 62 ) begin oled_data <= 16'hCE59; end
    if ( y == 28 && x == 63 ) begin oled_data <= 16'hEF7D; end
    if ( y == 28 && x == 64 ) begin oled_data <= 16'hBDD7; end
    if ( y == 28 && x == 65 ) begin oled_data <= 16'hAD55; end
    if ( y == 28 && x == 66 ) begin oled_data <= 16'hBDD7; end
    if ( y == 28 && x == 67 ) begin oled_data <= 16'hAD75; end
    if ( y == 28 && x == 68 ) begin oled_data <= 16'hA534; end
    if ( y == 28 && x == 69 ) begin oled_data <= 16'h6B4D; end
    if ( y == 29 && x == 26 ) begin oled_data <= 16'h0841; end
    if ( y == 29 && x == 27 ) begin oled_data <= 16'h4228; end
    if ( y == 29 && x == 28 ) begin oled_data <= 16'h7BEF; end
    if ( y == 29 && x == 29 ) begin oled_data <= 16'hB596; end
    if ( y == 29 && x == 30 ) begin oled_data <= 16'hAD75; end
    if ( y == 29 && x == 31 ) begin oled_data <= 16'h9CF3; end
    if ( y == 29 && x == 32 ) begin oled_data <= 16'h632C; end
    if ( y == 29 && x == 36 ) begin oled_data <= 16'h0861; end
    if ( y == 29 && x == 37 ) begin oled_data <= 16'h8410; end
    if ( y == 29 && x == 38 ) begin oled_data <= 16'hBDD7; end
    if ( y == 29 && x == 39 ) begin oled_data <= 16'h5ACB; end
    if ( y == 29 && x == 41 ) begin oled_data <= 16'h0841; end
    if ( y == 29 && x == 42 ) begin oled_data <= 16'h6B6D; end
    if ( y == 29 && x == 43 ) begin oled_data <= 16'hAD75; end
    if ( y == 29 && x == 44 ) begin oled_data <= 16'h7BCF; end
    if ( y == 29 && x == 48 ) begin oled_data <= 16'h39E7; end
    if ( y == 29 && x == 49 ) begin oled_data <= 16'hAD55; end
    if ( y == 29 && x == 50 ) begin oled_data <= 16'hB596; end
    if ( y == 29 && x == 51 ) begin oled_data <= 16'h31A6; end
    if ( y == 29 && x == 53 ) begin oled_data <= 16'h31A6; end
    if ( y == 29 && x == 54 ) begin oled_data <= 16'h7BEF; end
    if ( y == 29 && x == 55 ) begin oled_data <= 16'hA534; end
    if ( y == 29 && x == 56 ) begin oled_data <= 16'hB596; end
    if ( y == 29 && x == 57 ) begin oled_data <= 16'hA514; end
    if ( y == 29 && x == 58 ) begin oled_data <= 16'h7BEF; end
    if ( y == 29 && x == 59 ) begin oled_data <= 16'h39E7; end
    if ( y == 29 && x == 61 ) begin oled_data <= 16'h18C3; end
    if ( y == 29 && x == 62 ) begin oled_data <= 16'h9CD3; end
    if ( y == 29 && x == 63 ) begin oled_data <= 16'hB5B6; end
    if ( y == 29 && x == 64 ) begin oled_data <= 16'hB596; end
    if ( y == 29 && x == 65 ) begin oled_data <= 16'hB5B6; end
    if ( y == 29 && x == 66 ) begin oled_data <= 16'hBDF7; end
    if ( y == 29 && x == 67 ) begin oled_data <= 16'hBDD7; end
    if ( y == 29 && x == 68 ) begin oled_data <= 16'hAD75; end
    if ( y == 29 && x == 69 ) begin oled_data <= 16'h7BCF; end
    if ( y == 30 && x == 38 ) begin oled_data <= 16'h0841; end
    if ( y == 30 && x == 43 ) begin oled_data <= 16'h0841; end
    if ( y == 30 && x == 57 ) begin oled_data <= 16'h0841; end
    if ( y == 30 && x == 65 ) begin oled_data <= 16'h0841; end
    if ( y == 30 && x == 68 ) begin oled_data <= 16'h0841; end
    if ( y == 30 && x == 69 ) begin oled_data <= 16'h2104; end
    if ( y == 32 && x == 60 ) begin oled_data <= 16'h0841; end
    if ( y == 33 && x == 21 ) begin oled_data <= 16'h0841; end
    if ( y == 33 && x == 28 ) begin oled_data <= 16'h0841; end
    if ( y == 33 && x == 34 ) begin oled_data <= 16'h0841; end
    if ( y == 33 && x == 44 ) begin oled_data <= 16'h0841; end
    if ( y == 33 && x == 54 ) begin oled_data <= 16'h0841; end
    if ( y == 33 && x == 56 ) begin oled_data <= 16'h0841; end
    if ( y == 34 && x == 9 ) begin oled_data <= 16'h0841; end
    if ( y == 34 && x == 14 ) begin oled_data <= 16'h0861; end
    if ( y == 34 && x >= 15 && x <= 17 ) begin oled_data <= 16'h2124; end
    if ( y == 34 && x == 18 ) begin oled_data <= 16'h0861; end
    if ( y == 34 && x == 24 ) begin oled_data <= 16'h0861; end
    if ( y == 34 && x == 25 ) begin oled_data <= 16'h3186; end
    if ( y == 34 && x == 26 ) begin oled_data <= 16'h2945; end
    if ( y == 34 && x == 27 ) begin oled_data <= 16'h2104; end
    if ( y == 34 && x == 31 ) begin oled_data <= 16'h0841; end
    if ( y == 34 && x == 32 ) begin oled_data <= 16'h2945; end
    if ( y == 34 && x == 33 ) begin oled_data <= 16'h2124; end
    if ( y == 34 && x == 34 ) begin oled_data <= 16'h18C3; end
    if ( y == 34 && x == 39 ) begin oled_data <= 16'h2124; end
    if ( y == 34 && x == 40 ) begin oled_data <= 16'h2104; end
    if ( y == 34 && x == 42 ) begin oled_data <= 16'h0841; end
    if ( y == 34 && x == 43 ) begin oled_data <= 16'h2945; end
    if ( y == 34 && x == 44 ) begin oled_data <= 16'h18C3; end
    if ( y == 34 && x == 45 ) begin oled_data <= 16'h2965; end
    if ( y == 34 && x == 46 ) begin oled_data <= 16'h2945; end
    if ( y == 34 && x >= 47 && x <= 48 ) begin oled_data <= 16'h2124; end
    if ( y == 34 && x == 52 ) begin oled_data <= 16'h2945; end
    if ( y == 34 && x == 53 ) begin oled_data <= 16'h18E3; end
    if ( y == 34 && x == 59 ) begin oled_data <= 16'h0861; end
    if ( y == 34 && x == 60 ) begin oled_data <= 16'h3186; end
    if ( y == 34 && x == 61 ) begin oled_data <= 16'h2124; end
    if ( y == 34 && x == 62 ) begin oled_data <= 16'h2965; end
    if ( y == 34 && x >= 63 && x <= 64 ) begin oled_data <= 16'h2124; end
    if ( y == 34 && x >= 65 && x <= 67 ) begin oled_data <= 16'h2965; end
    if ( y == 34 && x == 68 ) begin oled_data <= 16'h3186; end
    if ( y == 34 && x >= 69 && x <= 70 ) begin oled_data <= 16'h2945; end
    if ( y == 34 && x == 71 ) begin oled_data <= 16'h3186; end
    if ( y == 34 && x == 72 ) begin oled_data <= 16'h2945; end
    if ( y == 34 && x == 73 ) begin oled_data <= 16'h2124; end
    if ( y == 34 && x == 74 ) begin oled_data <= 16'h3186; end
    if ( y == 34 && x >= 75 && x <= 76 ) begin oled_data <= 16'h2945; end
    if ( y == 34 && x == 77 ) begin oled_data <= 16'h2965; end
    if ( y == 34 && x == 78 ) begin oled_data <= 16'h2104; end
    if ( y == 34 && x >= 79 && x <= 80 ) begin oled_data <= 16'h2945; end
    if ( y == 34 && x == 81 ) begin oled_data <= 16'h2965; end
    if ( y == 34 && x == 82 ) begin oled_data <= 16'h2945; end
    if ( y == 34 && x == 83 ) begin oled_data <= 16'h39C7; end
    if ( y == 35 && x == 13 ) begin oled_data <= 16'h3186; end
    if ( y == 35 && x == 14 ) begin oled_data <= 16'h8C71; end
    if ( y == 35 && x == 15 ) begin oled_data <= 16'hBDF7; end
    if ( y == 35 && x == 16 ) begin oled_data <= 16'hD6BA; end
    if ( y == 35 && x == 17 ) begin oled_data <= 16'hD69A; end
    if ( y == 35 && x == 18 ) begin oled_data <= 16'hC638; end
    if ( y == 35 && x == 19 ) begin oled_data <= 16'h6B4D; end
    if ( y == 35 && x == 22 ) begin oled_data <= 16'h18C3; end
    if ( y == 35 && x == 23 ) begin oled_data <= 16'h5AEB; end
    if ( y == 35 && x == 24 ) begin oled_data <= 16'hB5B6; end
    if ( y == 35 && x == 25 ) begin oled_data <= 16'hC638; end
    if ( y == 35 && x == 26 ) begin oled_data <= 16'hDEDB; end
    if ( y == 35 && x == 27 ) begin oled_data <= 16'hCE59; end
    if ( y == 35 && x == 28 ) begin oled_data <= 16'h9CD3; end
    if ( y == 35 && x == 29 ) begin oled_data <= 16'h2965; end
    if ( y == 35 && x == 31 ) begin oled_data <= 16'h2104; end
    if ( y == 35 && x == 32 ) begin oled_data <= 16'hBDD7; end
    if ( y == 35 && x == 33 ) begin oled_data <= 16'hDEFB; end
    if ( y == 35 && x == 34 ) begin oled_data <= 16'hA534; end
    if ( y == 35 && x == 35 ) begin oled_data <= 16'h18C3; end
    if ( y == 35 && x == 38 ) begin oled_data <= 16'h528A; end
    if ( y == 35 && x >= 39 && x <= 40 ) begin oled_data <= 16'hD6BA; end
    if ( y == 35 && x == 41 ) begin oled_data <= 16'h630C; end
    if ( y == 35 && x == 43 ) begin oled_data <= 16'hAD75; end
    if ( y == 35 && x == 44 ) begin oled_data <= 16'hE71C; end
    if ( y == 35 && x >= 45 && x <= 47 ) begin oled_data <= 16'hD6BA; end
    if ( y == 35 && x == 48 ) begin oled_data <= 16'hDEDB; end
    if ( y == 35 && x == 49 ) begin oled_data <= 16'hAD75; end
    if ( y == 35 && x == 50 ) begin oled_data <= 16'h39E7; end
    if ( y == 35 && x == 51 ) begin oled_data <= 16'h39C7; end
    if ( y == 35 && x == 52 ) begin oled_data <= 16'hCE79; end
    if ( y == 35 && x == 53 ) begin oled_data <= 16'hBDD7; end
    if ( y == 35 && x == 54 ) begin oled_data <= 16'h2104; end
    if ( y == 35 && x == 57 ) begin oled_data <= 16'h0841; end
    if ( y == 35 && x == 59 ) begin oled_data <= 16'h2104; end
    if ( y == 35 && x == 60 ) begin oled_data <= 16'hBDF7; end
    if ( y == 35 && x >= 61 && x <= 64 ) begin oled_data <= 16'hD6BA; end
    if ( y == 35 && x == 65 ) begin oled_data <= 16'hCE79; end
    if ( y == 35 && x == 66 ) begin oled_data <= 16'hD6BA; end
    if ( y == 35 && x == 67 ) begin oled_data <= 16'h94B2; end
    if ( y == 35 && x == 68 ) begin oled_data <= 16'hCE59; end
    if ( y == 35 && x == 69 ) begin oled_data <= 16'hD6BA; end
    if ( y == 35 && x >= 70 && x <= 71 ) begin oled_data <= 16'hE71C; end
    if ( y == 35 && x >= 72 && x <= 73 ) begin oled_data <= 16'hDEDB; end
    if ( y == 35 && x == 74 ) begin oled_data <= 16'hD69A; end
    if ( y == 35 && x == 75 ) begin oled_data <= 16'h9492; end
    if ( y == 35 && x == 76 ) begin oled_data <= 16'h7BEF; end
    if ( y == 35 && x >= 77 && x <= 78 ) begin oled_data <= 16'hDEFB; end
    if ( y == 35 && x >= 79 && x <= 81 ) begin oled_data <= 16'hD6BA; end
    if ( y == 35 && x == 82 ) begin oled_data <= 16'hCE79; end
    if ( y == 35 && x == 83 ) begin oled_data <= 16'hB596; end
    if ( y == 35 && x == 84 ) begin oled_data <= 16'h0841; end
    if ( y == 35 && x == 87 ) begin oled_data <= 16'h0841; end
    if ( y == 36 && x == 12 ) begin oled_data <= 16'h2124; end
    if ( y == 36 && x == 13 ) begin oled_data <= 16'hA534; end
    if ( y == 36 && x == 14 ) begin oled_data <= 16'hE73C; end
    if ( y == 36 && x == 15 ) begin oled_data <= 16'hAD75; end
    if ( y == 36 && x == 16 ) begin oled_data <= 16'h7BCF; end
    if ( y == 36 && x == 17 ) begin oled_data <= 16'h6B6D; end
    if ( y == 36 && x == 18 ) begin oled_data <= 16'hB596; end
    if ( y == 36 && x == 19 ) begin oled_data <= 16'hDEFB; end
    if ( y == 36 && x == 20 ) begin oled_data <= 16'h94B2; end
    if ( y == 36 && x == 21 ) begin oled_data <= 16'h18C3; end
    if ( y == 36 && x == 22 ) begin oled_data <= 16'h5ACB; end
    if ( y == 36 && x == 23 ) begin oled_data <= 16'hDEFB; end
    if ( y == 36 && x == 24 ) begin oled_data <= 16'hCE79; end
    if ( y == 36 && x == 25 ) begin oled_data <= 16'h8C71; end
    if ( y == 36 && x == 26 ) begin oled_data <= 16'h6B4D; end
    if ( y == 36 && x == 27 ) begin oled_data <= 16'hAD55; end
    if ( y == 36 && x == 28 ) begin oled_data <= 16'hE71C; end
    if ( y == 36 && x == 29 ) begin oled_data <= 16'hBDF7; end
    if ( y == 36 && x == 30 ) begin oled_data <= 16'h2965; end
    if ( y == 36 && x == 31 ) begin oled_data <= 16'h18E3; end
    if ( y == 36 && x == 32 ) begin oled_data <= 16'hD69A; end
    if ( y == 36 && x == 33 ) begin oled_data <= 16'hF7BE; end
    if ( y == 36 && x == 34 ) begin oled_data <= 16'hE71C; end
    if ( y == 36 && x == 35 ) begin oled_data <= 16'h39E7; end
    if ( y == 36 && x == 38 ) begin oled_data <= 16'hA514; end
    if ( y == 36 && x == 39 ) begin oled_data <= 16'hFFDF; end
    if ( y == 36 && x == 40 ) begin oled_data <= 16'hF79E; end
    if ( y == 36 && x == 41 ) begin oled_data <= 16'h6B6D; end
    if ( y == 36 && x == 42 ) begin oled_data <= 16'h0861; end
    if ( y == 36 && x == 43 ) begin oled_data <= 16'hAD55; end
    if ( y == 36 && x == 44 ) begin oled_data <= 16'hF7BE; end
    if ( y == 36 && x == 45 ) begin oled_data <= 16'h8C51; end
    if ( y == 36 && x == 46 ) begin oled_data <= 16'h6B4D; end
    if ( y == 36 && x == 47 ) begin oled_data <= 16'h738E; end
    if ( y == 36 && x == 48 ) begin oled_data <= 16'h9492; end
    if ( y == 36 && x == 49 ) begin oled_data <= 16'hF79E; end
    if ( y == 36 && x == 50 ) begin oled_data <= 16'h9CD3; end
    if ( y == 36 && x == 51 ) begin oled_data <= 16'h39E7; end
    if ( y == 36 && x == 52 ) begin oled_data <= 16'hE71C; end
    if ( y == 36 && x == 53 ) begin oled_data <= 16'hD69A; end
    if ( y == 36 && x == 54 ) begin oled_data <= 16'h2124; end
    if ( y == 36 && x == 59 ) begin oled_data <= 16'h18C3; end
    if ( y == 36 && x == 60 ) begin oled_data <= 16'hCE79; end
    if ( y == 36 && x == 61 ) begin oled_data <= 16'hEF7D; end
    if ( y == 36 && x == 62 ) begin oled_data <= 16'h7BEF; end
    if ( y == 36 && x >= 63 && x <= 64 ) begin oled_data <= 16'h73AE; end
    if ( y == 36 && x == 65 ) begin oled_data <= 16'h738E; end
    if ( y == 36 && x == 66 ) begin oled_data <= 16'h6B6D; end
    if ( y == 36 && x == 67 ) begin oled_data <= 16'h630C; end
    if ( y == 36 && x == 68 ) begin oled_data <= 16'h6B4D; end
    if ( y == 36 && x == 69 ) begin oled_data <= 16'h738E; end
    if ( y == 36 && x == 70 ) begin oled_data <= 16'h9492; end
    if ( y == 36 && x == 71 ) begin oled_data <= 16'hF7BE; end
    if ( y == 36 && x == 72 ) begin oled_data <= 16'hC638; end
    if ( y == 36 && x >= 73 && x <= 74 ) begin oled_data <= 16'h6B4D; end
    if ( y == 36 && x == 75 ) begin oled_data <= 16'h5AEB; end
    if ( y == 36 && x == 76 ) begin oled_data <= 16'h8C71; end
    if ( y == 36 && x == 77 ) begin oled_data <= 16'hFFDF; end
    if ( y == 36 && x == 78 ) begin oled_data <= 16'hAD75; end
    if ( y == 36 && x == 79 ) begin oled_data <= 16'h6B6D; end
    if ( y == 36 && x >= 80 && x <= 81 ) begin oled_data <= 16'h738E; end
    if ( y == 36 && x == 82 ) begin oled_data <= 16'h6B6D; end
    if ( y == 36 && x == 83 ) begin oled_data <= 16'h6B4D; end
    if ( y == 36 && x == 85 ) begin oled_data <= 16'h0841; end
    if ( y == 37 && x == 12 ) begin oled_data <= 16'h738E; end
    if ( y == 37 && x == 13 ) begin oled_data <= 16'hE73C; end
    if ( y == 37 && x == 14 ) begin oled_data <= 16'h9CF3; end
    if ( y == 37 && x == 15 ) begin oled_data <= 16'h18C3; end
    if ( y == 37 && x >= 19 && x <= 20 ) begin oled_data <= 16'h5AEB; end
    if ( y == 37 && x == 21 ) begin oled_data <= 16'h2124; end
    if ( y == 37 && x == 22 ) begin oled_data <= 16'hBDF7; end
    if ( y == 37 && x == 23 ) begin oled_data <= 16'hE71C; end
    if ( y == 37 && x == 24 ) begin oled_data <= 16'h52AA; end
    if ( y == 37 && x == 25 ) begin oled_data <= 16'h0861; end
    if ( y == 37 && x == 27 ) begin oled_data <= 16'h0861; end
    if ( y == 37 && x == 28 ) begin oled_data <= 16'h8410; end
    if ( y == 37 && x == 29 ) begin oled_data <= 16'hF79E; end
    if ( y == 37 && x == 30 ) begin oled_data <= 16'h9CD3; end
    if ( y == 37 && x == 31 ) begin oled_data <= 16'h18E3; end
    if ( y == 37 && x == 32 ) begin oled_data <= 16'hCE59; end
    if ( y == 37 && x == 33 ) begin oled_data <= 16'hF7BE; end
    if ( y == 37 && x == 34 ) begin oled_data <= 16'hFFDF; end
    if ( y == 37 && x == 35 ) begin oled_data <= 16'hA514; end
    if ( y == 37 && x == 37 ) begin oled_data <= 16'h5AEB; end
    if ( y == 37 && x == 38 ) begin oled_data <= 16'hDEFB; end
    if ( y == 37 && x == 39 ) begin oled_data <= 16'hF79E; end
    if ( y == 37 && x == 40 ) begin oled_data <= 16'hF7BE; end
    if ( y == 37 && x == 41 ) begin oled_data <= 16'h630C; end
    if ( y == 37 && x == 43 ) begin oled_data <= 16'hBDD7; end
    if ( y == 37 && x == 44 ) begin oled_data <= 16'hEF7D; end
    if ( y == 37 && x == 45 ) begin oled_data <= 16'h630C; end
    if ( y == 37 && x == 48 ) begin oled_data <= 16'h528A; end
    if ( y == 37 && x == 49 ) begin oled_data <= 16'hEF5D; end
    if ( y == 37 && x == 50 ) begin oled_data <= 16'hC618; end
    if ( y == 37 && x == 51 ) begin oled_data <= 16'h528A; end
    if ( y == 37 && x == 52 ) begin oled_data <= 16'hE73C; end
    if ( y == 37 && x == 53 ) begin oled_data <= 16'hCE79; end
    if ( y == 37 && x == 54 ) begin oled_data <= 16'h2104; end
    if ( y == 37 && x == 60 ) begin oled_data <= 16'hCE79; end
    if ( y == 37 && x == 61 ) begin oled_data <= 16'hEF5D; end
    if ( y == 37 && x == 62 ) begin oled_data <= 16'h738E; end
    if ( y == 37 && x >= 63 && x <= 64 ) begin oled_data <= 16'h4A69; end
    if ( y == 37 && x == 65 ) begin oled_data <= 16'h4228; end
    if ( y == 37 && x == 66 ) begin oled_data <= 16'h0841; end
    if ( y == 37 && x == 70 ) begin oled_data <= 16'h5ACB; end
    if ( y == 37 && x == 71 ) begin oled_data <= 16'hEF7D; end
    if ( y == 37 && x == 72 ) begin oled_data <= 16'hBDD7; end
    if ( y == 37 && x == 73 ) begin oled_data <= 16'h0861; end
    if ( y == 37 && x == 75 ) begin oled_data <= 16'h0841; end
    if ( y == 37 && x == 76 ) begin oled_data <= 16'h8410; end
    if ( y == 37 && x == 77 ) begin oled_data <= 16'hFFDF; end
    if ( y == 37 && x == 78 ) begin oled_data <= 16'hA534; end
    if ( y == 37 && x >= 79 && x <= 80 ) begin oled_data <= 16'h52AA; end
    if ( y == 37 && x == 81 ) begin oled_data <= 16'h528A; end
    if ( y == 37 && x == 82 ) begin oled_data <= 16'h18C3; end
    if ( y == 37 && x == 83 ) begin oled_data <= 16'h0841; end
    if ( y == 38 && x == 11 ) begin oled_data <= 16'h0861; end
    if ( y == 38 && x == 12 ) begin oled_data <= 16'hA514; end
    if ( y == 38 && x == 13 ) begin oled_data <= 16'hEF5D; end
    if ( y == 38 && x == 14 ) begin oled_data <= 16'h5AEB; end
    if ( y == 38 && x == 20 ) begin oled_data <= 16'h0841; end
    if ( y == 38 && x == 21 ) begin oled_data <= 16'h39E7; end
    if ( y == 38 && x == 22 ) begin oled_data <= 16'hE71C; end
    if ( y == 38 && x == 23 ) begin oled_data <= 16'hBDF7; end
    if ( y == 38 && x == 24 ) begin oled_data <= 16'h2104; end
    if ( y == 38 && x == 28 ) begin oled_data <= 16'h39C7; end
    if ( y == 38 && x == 29 ) begin oled_data <= 16'hE73C; end
    if ( y == 38 && x == 30 ) begin oled_data <= 16'hB5B6; end
    if ( y == 38 && x == 31 ) begin oled_data <= 16'h18E3; end
    if ( y == 38 && x == 32 ) begin oled_data <= 16'hCE59; end
    if ( y == 38 && x == 33 ) begin oled_data <= 16'hD6BA; end
    if ( y == 38 && x == 34 ) begin oled_data <= 16'hBDD7; end
    if ( y == 38 && x == 35 ) begin oled_data <= 16'hEF7D; end
    if ( y == 38 && x == 36 ) begin oled_data <= 16'h630C; end
    if ( y == 38 && x == 37 ) begin oled_data <= 16'hB596; end
    if ( y == 38 && x == 38 ) begin oled_data <= 16'hD69A; end
    if ( y == 38 && x == 39 ) begin oled_data <= 16'hC638; end
    if ( y == 38 && x == 40 ) begin oled_data <= 16'hF79E; end
    if ( y == 38 && x == 41 ) begin oled_data <= 16'h632C; end
    if ( y == 38 && x == 42 ) begin oled_data <= 16'h0861; end
    if ( y == 38 && x == 43 ) begin oled_data <= 16'hB5B6; end
    if ( y == 38 && x == 44 ) begin oled_data <= 16'hF7BE; end
    if ( y == 38 && x == 45 ) begin oled_data <= 16'hD6BA; end
    if ( y == 38 && x == 46 ) begin oled_data <= 16'hCE59; end
    if ( y == 38 && x == 47 ) begin oled_data <= 16'hD69A; end
    if ( y == 38 && x == 48 ) begin oled_data <= 16'hCE79; end
    if ( y == 38 && x == 49 ) begin oled_data <= 16'hD6BA; end
    if ( y == 38 && x == 50 ) begin oled_data <= 16'h7BCF; end
    if ( y == 38 && x == 51 ) begin oled_data <= 16'h39E7; end
    if ( y == 38 && x == 52 ) begin oled_data <= 16'hEF5D; end
    if ( y == 38 && x == 53 ) begin oled_data <= 16'hD6BA; end
    if ( y == 38 && x == 54 ) begin oled_data <= 16'h2124; end
    if ( y == 38 && x == 60 ) begin oled_data <= 16'hD69A; end
    if ( y == 38 && x == 61 ) begin oled_data <= 16'hFFDF; end
    if ( y == 38 && x == 62 ) begin oled_data <= 16'hD6BA; end
    if ( y == 38 && x >= 63 && x <= 64 ) begin oled_data <= 16'hDEDB; end
    if ( y == 38 && x == 65 ) begin oled_data <= 16'h9CD3; end
    if ( y == 38 && x == 70 ) begin oled_data <= 16'h528A; end
    if ( y == 38 && x == 71 ) begin oled_data <= 16'hF79E; end
    if ( y == 38 && x == 72 ) begin oled_data <= 16'hBDF7; end
    if ( y == 38 && x == 73 ) begin oled_data <= 16'h0841; end
    if ( y == 38 && x == 76 ) begin oled_data <= 16'h8C51; end
    if ( y == 38 && x == 77 ) begin oled_data <= 16'hFFFF; end
    if ( y == 38 && x == 78 ) begin oled_data <= 16'hE73C; end
    if ( y == 38 && x == 79 ) begin oled_data <= 16'hD6BA; end
    if ( y == 38 && x == 80 ) begin oled_data <= 16'hDEDB; end
    if ( y == 38 && x == 81 ) begin oled_data <= 16'hB596; end
    if ( y == 38 && x == 82 ) begin oled_data <= 16'h39E7; end
    if ( y == 39 && x == 12 ) begin oled_data <= 16'h8C71; end
    if ( y == 39 && x == 13 ) begin oled_data <= 16'hF7BE; end
    if ( y == 39 && x == 14 ) begin oled_data <= 16'h6B4D; end
    if ( y == 39 && x == 19 ) begin oled_data <= 16'h2104; end
    if ( y == 39 && x == 20 ) begin oled_data <= 16'h0841; end
    if ( y == 39 && x == 21 ) begin oled_data <= 16'h2945; end
    if ( y == 39 && x == 22 ) begin oled_data <= 16'hDEFB; end
    if ( y == 39 && x == 23 ) begin oled_data <= 16'hCE59; end
    if ( y == 39 && x == 24 ) begin oled_data <= 16'h2104; end
    if ( y == 39 && x == 28 ) begin oled_data <= 16'h52AA; end
    if ( y == 39 && x == 29 ) begin oled_data <= 16'hE73C; end
    if ( y == 39 && x == 30 ) begin oled_data <= 16'hAD75; end
    if ( y == 39 && x == 31 ) begin oled_data <= 16'h2104; end
    if ( y == 39 && x == 32 ) begin oled_data <= 16'hCE59; end
    if ( y == 39 && x == 33 ) begin oled_data <= 16'hD69A; end
    if ( y == 39 && x == 34 ) begin oled_data <= 16'h630C; end
    if ( y == 39 && x == 35 ) begin oled_data <= 16'hDEDB; end
    if ( y == 39 && x == 36 ) begin oled_data <= 16'hDEFB; end
    if ( y == 39 && x == 37 ) begin oled_data <= 16'hE71C; end
    if ( y == 39 && x == 38 ) begin oled_data <= 16'h8410; end
    if ( y == 39 && x == 39 ) begin oled_data <= 16'hAD55; end
    if ( y == 39 && x == 40 ) begin oled_data <= 16'hF79E; end
    if ( y == 39 && x == 41 ) begin oled_data <= 16'h6B6D; end
    if ( y == 39 && x == 42 ) begin oled_data <= 16'h0861; end
    if ( y == 39 && x == 43 ) begin oled_data <= 16'hB5B6; end
    if ( y == 39 && x == 44 ) begin oled_data <= 16'hF79E; end
    if ( y == 39 && x == 45 ) begin oled_data <= 16'h8C71; end
    if ( y == 39 && x >= 46 && x <= 48 ) begin oled_data <= 16'h7BCF; end
    if ( y == 39 && x == 49 ) begin oled_data <= 16'h52AA; end
    if ( y == 39 && x == 51 ) begin oled_data <= 16'h2965; end
    if ( y == 39 && x == 52 ) begin oled_data <= 16'hEF7D; end
    if ( y == 39 && x == 53 ) begin oled_data <= 16'hCE79; end
    if ( y == 39 && x == 54 ) begin oled_data <= 16'h18E3; end
    if ( y == 39 && x == 59 ) begin oled_data <= 16'h18C3; end
    if ( y == 39 && x == 60 ) begin oled_data <= 16'hCE79; end
    if ( y == 39 && x == 61 ) begin oled_data <= 16'hE71C; end
    if ( y == 39 && x == 62 ) begin oled_data <= 16'h5ACB; end
    if ( y == 39 && x == 63 ) begin oled_data <= 16'h31A6; end
    if ( y == 39 && x == 64 ) begin oled_data <= 16'h3186; end
    if ( y == 39 && x == 65 ) begin oled_data <= 16'h39E7; end
    if ( y == 39 && x == 66 ) begin oled_data <= 16'h0841; end
    if ( y == 39 && x == 70 ) begin oled_data <= 16'h52AA; end
    if ( y == 39 && x == 71 ) begin oled_data <= 16'hF79E; end
    if ( y == 39 && x == 72 ) begin oled_data <= 16'hB5B6; end
    if ( y == 39 && x == 73 ) begin oled_data <= 16'h18C3; end
    if ( y == 39 && x == 76 ) begin oled_data <= 16'h9492; end
    if ( y == 39 && x == 77 ) begin oled_data <= 16'hF7BE; end
    if ( y == 39 && x == 78 ) begin oled_data <= 16'h9CD3; end
    if ( y == 39 && x == 79 ) begin oled_data <= 16'h31A6; end
    if ( y == 39 && x == 80 ) begin oled_data <= 16'h3186; end
    if ( y == 39 && x == 81 ) begin oled_data <= 16'h39C7; end
    if ( y == 40 && x == 12 ) begin oled_data <= 16'h4208; end
    if ( y == 40 && x == 13 ) begin oled_data <= 16'hE71C; end
    if ( y == 40 && x == 14 ) begin oled_data <= 16'hD6BA; end
    if ( y == 40 && x == 15 ) begin oled_data <= 16'h4228; end
    if ( y == 40 && x == 18 ) begin oled_data <= 16'h4208; end
    if ( y == 40 && x == 19 ) begin oled_data <= 16'h94B2; end
    if ( y == 40 && x == 20 ) begin oled_data <= 16'h738E; end
    if ( y == 40 && x == 21 ) begin oled_data <= 16'h0861; end
    if ( y == 40 && x == 22 ) begin oled_data <= 16'h9CD3; end
    if ( y == 40 && x == 23 ) begin oled_data <= 16'hF79E; end
    if ( y == 40 && x == 24 ) begin oled_data <= 16'h8C51; end
    if ( y == 40 && x == 25 ) begin oled_data <= 16'h18E3; end
    if ( y == 40 && x == 26 ) begin oled_data <= 16'h0861; end
    if ( y == 40 && x == 27 ) begin oled_data <= 16'h4228; end
    if ( y == 40 && x == 28 ) begin oled_data <= 16'hB596; end
    if ( y == 40 && x == 29 ) begin oled_data <= 16'hEF5D; end
    if ( y == 40 && x == 30 ) begin oled_data <= 16'h7BCF; end
    if ( y == 40 && x == 31 ) begin oled_data <= 16'h18C3; end
    if ( y == 40 && x == 32 ) begin oled_data <= 16'hCE59; end
    if ( y == 40 && x == 33 ) begin oled_data <= 16'hD69A; end
    if ( y == 40 && x == 34 ) begin oled_data <= 16'h2945; end
    if ( y == 40 && x == 35 ) begin oled_data <= 16'hA514; end
    if ( y == 40 && x == 36 ) begin oled_data <= 16'hFFDF; end
    if ( y == 40 && x == 37 ) begin oled_data <= 16'hBDD7; end
    if ( y == 40 && x == 38 ) begin oled_data <= 16'h39C7; end
    if ( y == 40 && x == 39 ) begin oled_data <= 16'hA514; end
    if ( y == 40 && x == 40 ) begin oled_data <= 16'hEF7D; end
    if ( y == 40 && x == 41 ) begin oled_data <= 16'h6B4D; end
    if ( y == 40 && x == 43 ) begin oled_data <= 16'hB596; end
    if ( y == 40 && x == 44 ) begin oled_data <= 16'hEF7D; end
    if ( y == 40 && x == 45 ) begin oled_data <= 16'h52AA; end
    if ( y == 40 && x == 51 ) begin oled_data <= 16'h2965; end
    if ( y == 40 && x == 52 ) begin oled_data <= 16'hEF7D; end
    if ( y == 40 && x == 53 ) begin oled_data <= 16'hCE59; end
    if ( y == 40 && x == 54 ) begin oled_data <= 16'h2945; end
    if ( y == 40 && x == 55 ) begin oled_data <= 16'h0861; end
    if ( y == 40 && x == 57 ) begin oled_data <= 16'h0861; end
    if ( y == 40 && x == 59 ) begin oled_data <= 16'h18E3; end
    if ( y == 40 && x == 60 ) begin oled_data <= 16'hCE79; end
    if ( y == 40 && x == 61 ) begin oled_data <= 16'hE73C; end
    if ( y == 40 && x == 62 ) begin oled_data <= 16'h4228; end
    if ( y == 40 && x == 63 ) begin oled_data <= 16'h0861; end
    if ( y == 40 && x >= 64 && x <= 65 ) begin oled_data <= 16'h0841; end
    if ( y == 40 && x == 70 ) begin oled_data <= 16'h5ACB; end
    if ( y == 40 && x == 71 ) begin oled_data <= 16'hEF7D; end
    if ( y == 40 && x == 72 ) begin oled_data <= 16'hBDD7; end
    if ( y == 40 && x == 73 ) begin oled_data <= 16'h0861; end
    if ( y == 40 && x == 76 ) begin oled_data <= 16'h8C71; end
    if ( y == 40 && x == 77 ) begin oled_data <= 16'hFFDF; end
    if ( y == 40 && x == 78 ) begin oled_data <= 16'h8C51; end
    if ( y == 40 && x == 79 ) begin oled_data <= 16'h0861; end
    if ( y == 40 && x >= 80 && x <= 81 ) begin oled_data <= 16'h0841; end
    if ( y == 40 && x == 82 ) begin oled_data <= 16'h0861; end
    if ( y == 41 && x == 12 ) begin oled_data <= 16'h0841; end
    if ( y == 41 && x == 13 ) begin oled_data <= 16'h6B6D; end
    if ( y == 41 && x == 14 ) begin oled_data <= 16'hCE59; end
    if ( y == 41 && x == 15 ) begin oled_data <= 16'hEF5D; end
    if ( y == 41 && x == 16 ) begin oled_data <= 16'hBDF7; end
    if ( y == 41 && x == 17 ) begin oled_data <= 16'hB5B6; end
    if ( y == 41 && x == 18 ) begin oled_data <= 16'hCE79; end
    if ( y == 41 && x == 19 ) begin oled_data <= 16'hCE59; end
    if ( y == 41 && x == 20 ) begin oled_data <= 16'h8C51; end
    if ( y == 41 && x == 22 ) begin oled_data <= 16'h2965; end
    if ( y == 41 && x == 23 ) begin oled_data <= 16'hAD75; end
    if ( y == 41 && x == 24 ) begin oled_data <= 16'hEF5D; end
    if ( y == 41 && x == 25 ) begin oled_data <= 16'hCE79; end
    if ( y == 41 && x == 26 ) begin oled_data <= 16'hBDF7; end
    if ( y == 41 && x == 27 ) begin oled_data <= 16'hCE59; end
    if ( y == 41 && x == 28 ) begin oled_data <= 16'hDEDB; end
    if ( y == 41 && x == 29 ) begin oled_data <= 16'h8C51; end
    if ( y == 41 && x >= 30 && x <= 31 ) begin oled_data <= 16'h18E3; end
    if ( y == 41 && x == 32 ) begin oled_data <= 16'hCE59; end
    if ( y == 41 && x == 33 ) begin oled_data <= 16'hD69A; end
    if ( y == 41 && x == 34 ) begin oled_data <= 16'h2104; end
    if ( y == 41 && x == 35 ) begin oled_data <= 16'h31A6; end
    if ( y == 41 && x == 36 ) begin oled_data <= 16'hC618; end
    if ( y == 41 && x == 37 ) begin oled_data <= 16'h632C; end
    if ( y == 41 && x == 39 ) begin oled_data <= 16'hAD55; end
    if ( y == 41 && x == 40 ) begin oled_data <= 16'hF79E; end
    if ( y == 41 && x == 41 ) begin oled_data <= 16'h6B4D; end
    if ( y == 41 && x == 43 ) begin oled_data <= 16'hB5B6; end
    if ( y == 41 && x == 44 ) begin oled_data <= 16'hEF7D; end
    if ( y == 41 && x == 45 ) begin oled_data <= 16'h5AEB; end
    if ( y == 41 && x == 51 ) begin oled_data <= 16'h31A6; end
    if ( y == 41 && x == 52 ) begin oled_data <= 16'hE71C; end
    if ( y == 41 && x == 53 ) begin oled_data <= 16'hF7BE; end
    if ( y == 41 && x == 54 ) begin oled_data <= 16'hBDD7; end
    if ( y == 41 && x == 55 ) begin oled_data <= 16'hBDF7; end
    if ( y == 41 && x == 56 ) begin oled_data <= 16'hC618; end
    if ( y == 41 && x == 57 ) begin oled_data <= 16'hBDD7; end
    if ( y == 41 && x == 58 ) begin oled_data <= 16'hAD75; end
    if ( y == 41 && x == 59 ) begin oled_data <= 16'h52AA; end
    if ( y == 41 && x == 60 ) begin oled_data <= 16'hCE79; end
    if ( y == 41 && x == 61 ) begin oled_data <= 16'hEF7D; end
    if ( y == 41 && x == 62 ) begin oled_data <= 16'hCE59; end
    if ( y == 41 && x == 63 ) begin oled_data <= 16'hB5B6; end
    if ( y == 41 && x >= 64 && x <= 65 ) begin oled_data <= 16'hBDF7; end
    if ( y == 41 && x == 66 ) begin oled_data <= 16'hB596; end
    if ( y == 41 && x == 67 ) begin oled_data <= 16'h738E; end
    if ( y == 41 && x == 68 ) begin oled_data <= 16'h0841; end
    if ( y == 41 && x == 70 ) begin oled_data <= 16'h5ACB; end
    if ( y == 41 && x == 71 ) begin oled_data <= 16'hE73C; end
    if ( y == 41 && x == 72 ) begin oled_data <= 16'hB5B6; end
    if ( y == 41 && x == 76 ) begin oled_data <= 16'h8C71; end
    if ( y == 41 && x == 77 ) begin oled_data <= 16'hF7BE; end
    if ( y == 41 && x == 78 ) begin oled_data <= 16'hDEDB; end
    if ( y == 41 && x >= 79 && x <= 80 ) begin oled_data <= 16'hBDD7; end
    if ( y == 41 && x == 81 ) begin oled_data <= 16'hBDF7; end
    if ( y == 41 && x == 82 ) begin oled_data <= 16'hB5B6; end
    if ( y == 41 && x == 83 ) begin oled_data <= 16'h9CF3; end
    if ( y == 41 && x == 84 ) begin oled_data <= 16'h18E3; end
    if ( y == 41 && x == 87 ) begin oled_data <= 16'h0841; end
    if ( y == 42 && x == 14 ) begin oled_data <= 16'h39E7; end
    if ( y == 42 && x == 15 ) begin oled_data <= 16'h738E; end
    if ( y == 42 && x == 16 ) begin oled_data <= 16'h9492; end
    if ( y == 42 && x == 17 ) begin oled_data <= 16'h9CD3; end
    if ( y == 42 && x == 18 ) begin oled_data <= 16'h7BCF; end
    if ( y == 42 && x == 19 ) begin oled_data <= 16'h39C7; end
    if ( y == 42 && x == 23 ) begin oled_data <= 16'h18C3; end
    if ( y == 42 && x == 24 ) begin oled_data <= 16'h5ACB; end
    if ( y == 42 && x == 25 ) begin oled_data <= 16'h8C71; end
    if ( y == 42 && x == 26 ) begin oled_data <= 16'h9CF3; end
    if ( y == 42 && x == 27 ) begin oled_data <= 16'h8430; end
    if ( y == 42 && x == 28 ) begin oled_data <= 16'h5ACB; end
    if ( y == 42 && x == 31 ) begin oled_data <= 16'h18E3; end
    if ( y == 42 && x == 32 ) begin oled_data <= 16'h8410; end
    if ( y == 42 && x == 33 ) begin oled_data <= 16'h8C51; end
    if ( y == 42 && x == 34 ) begin oled_data <= 16'h2124; end
    if ( y == 42 && x == 35 ) begin oled_data <= 16'h0841; end
    if ( y == 42 && x == 36 ) begin oled_data <= 16'h4228; end
    if ( y == 42 && x == 38 ) begin oled_data <= 16'h0841; end
    if ( y == 42 && x == 39 ) begin oled_data <= 16'h6B4D; end
    if ( y == 42 && x == 40 ) begin oled_data <= 16'h9CD3; end
    if ( y == 42 && x == 41 ) begin oled_data <= 16'h528A; end
    if ( y == 42 && x == 43 ) begin oled_data <= 16'h738E; end
    if ( y == 42 && x == 44 ) begin oled_data <= 16'h9492; end
    if ( y == 42 && x == 45 ) begin oled_data <= 16'h4A49; end
    if ( y == 42 && x == 51 ) begin oled_data <= 16'h2965; end
    if ( y == 42 && x == 52 ) begin oled_data <= 16'h8C51; end
    if ( y == 42 && x == 53 ) begin oled_data <= 16'h9CD3; end
    if ( y == 42 && x == 54 ) begin oled_data <= 16'h94B2; end
    if ( y == 42 && x >= 55 && x <= 56 ) begin oled_data <= 16'h9CD3; end
    if ( y == 42 && x >= 57 && x <= 58 ) begin oled_data <= 16'h94B2; end
    if ( y == 42 && x == 59 ) begin oled_data <= 16'h528A; end
    if ( y == 42 && x == 60 ) begin oled_data <= 16'h8410; end
    if ( y == 42 && x == 61 ) begin oled_data <= 16'h94B2; end
    if ( y == 42 && x == 62 ) begin oled_data <= 16'h9CD3; end
    if ( y == 42 && x == 63 ) begin oled_data <= 16'h9CF3; end
    if ( y == 42 && x == 64 ) begin oled_data <= 16'h94B2; end
    if ( y == 42 && x == 65 ) begin oled_data <= 16'h9CF3; end
    if ( y == 42 && x == 66 ) begin oled_data <= 16'h9CD3; end
    if ( y == 42 && x == 67 ) begin oled_data <= 16'h6B4D; end
    if ( y == 42 && x == 70 ) begin oled_data <= 16'h39E7; end
    if ( y == 42 && x == 71 ) begin oled_data <= 16'h9CF3; end
    if ( y == 42 && x == 72 ) begin oled_data <= 16'h8C51; end
    if ( y == 42 && x == 76 ) begin oled_data <= 16'h5ACB; end
    if ( y == 42 && x == 77 ) begin oled_data <= 16'h9CF3; end
    if ( y == 42 && x == 78 ) begin oled_data <= 16'h9CD3; end
    if ( y == 42 && x == 79 ) begin oled_data <= 16'h94B2; end
    if ( y == 42 && x >= 80 && x <= 81 ) begin oled_data <= 16'h9CD3; end
    if ( y == 42 && x == 82 ) begin oled_data <= 16'h94B2; end
    if ( y == 42 && x == 83 ) begin oled_data <= 16'h8C51; end
    if ( y == 43 && x == 12 ) begin oled_data <= 16'h0841; end
    if ( y == 43 && x == 22 ) begin oled_data <= 16'h0841; end
    if ( y == 43 && x == 41 ) begin oled_data <= 16'h0841; end
    if ( y == 43 && x == 52 ) begin oled_data <= 16'h0841; end
    if ( y == 43 && x == 61 ) begin oled_data <= 16'h0841; end
    if ( y == 43 && x == 74 ) begin oled_data <= 16'h0841; end
    if ( y == 44 && x == 32 ) begin oled_data <= 16'h0841; end
    if ( y == 45 && x == 20 ) begin oled_data <= 16'h0841; end
    if ( y == 45 && x == 39 ) begin oled_data <= 16'h0841; end
    if ( y == 45 && x == 68 ) begin oled_data <= 16'h0841; end
    if ( y == 46 && x == 32 ) begin oled_data <= 16'h0841; end
    if ( y == 46 && x == 59 ) begin oled_data <= 16'h0841; end
    winCounter <= 23'd6250000;                    
    end      
    end
    else if(dead == 1 && gameStart == 0)
        begin
        //dead image
        if ( y == 20 && x >= 14 && x <= 155 ) begin oled_data <= 16'h0000; end
        if ( y == 21 && x >= 13 && x <= 125 ) begin oled_data <= 16'h0000; end
        if ( y == 22 && x >= 12 && x <= 95 ) begin oled_data <= 16'h0000; end
        if ( y == 23 && x >= 12 && x <= 65 ) begin oled_data <= 16'h0000; end
        if ( y == 24 && x >= 12 && x <= 35 ) begin oled_data <= 16'h0000; end
        if ( y == 25 && x == 6 ) begin oled_data <= 16'h0001; end
        if ( y == 25 && x == 7 ) begin oled_data <= 16'h0022; end
        if ( y == 25 && x >= 8 && x <= 9 ) begin oled_data <= 16'h0001; end
        if ( y == 25 && x >= 11 && x <= 34 ) begin oled_data <= 16'h0000; end
        if ( y == 26 && x == 5 ) begin oled_data <= 16'h0063; end
        if ( y == 26 && x == 6 ) begin oled_data <= 16'h19A9; end
        if ( y == 26 && x == 7 ) begin oled_data <= 16'h2A0C; end
        if ( y == 26 && x == 8 ) begin oled_data <= 16'h3AAE; end
        if ( y == 26 && x == 9 ) begin oled_data <= 16'h4A8D; end
        if ( y == 26 && x == 10 ) begin oled_data <= 16'h4187; end
        if ( y == 26 && x == 11 ) begin oled_data <= 16'h2062; end
        if ( y == 26 && x >= 12 && x <= 32 ) begin oled_data <= 16'h0000; end
        if ( y == 27 && x == 3 ) begin oled_data <= 16'h0001; end
        if ( y == 27 && x == 4 ) begin oled_data <= 16'h1108; end
        if ( y == 27 && x == 5 ) begin oled_data <= 16'h21AC; end
        if ( y == 27 && x == 6 ) begin oled_data <= 16'h2AB1; end
        if ( y == 27 && x == 7 ) begin oled_data <= 16'h32F2; end
        if ( y == 27 && x == 8 ) begin oled_data <= 16'h4353; end
        if ( y == 27 && x == 9 ) begin oled_data <= 16'h428F; end
        if ( y == 27 && x == 10 ) begin oled_data <= 16'h51EA; end
        if ( y == 27 && x == 11 ) begin oled_data <= 16'h59C8; end
        if ( y == 27 && x == 12 ) begin oled_data <= 16'h20E4; end
        if ( y == 27 && x >= 13 && x <= 32 ) begin oled_data <= 16'h0000; end
        if ( y == 28 && x == 3 ) begin oled_data <= 16'h10E7; end
        if ( y == 28 && x == 4 ) begin oled_data <= 16'h2A12; end
        if ( y == 28 && x == 5 ) begin oled_data <= 16'h1214; end
        if ( y == 28 && x == 6 ) begin oled_data <= 16'h22F7; end
        if ( y == 28 && x == 7 ) begin oled_data <= 16'h2B37; end
        if ( y == 28 && x == 8 ) begin oled_data <= 16'h22B5; end
        if ( y == 28 && x == 9 ) begin oled_data <= 16'h198F; end
        if ( y == 28 && x == 10 ) begin oled_data <= 16'h496B; end
        if ( y == 28 && x == 11 ) begin oled_data <= 16'h518A; end
        if ( y == 28 && x == 12 ) begin oled_data <= 16'h41CA; end
        if ( y == 28 && x == 13 ) begin oled_data <= 16'h0884; end
        if ( y == 28 && x >= 14 && x <= 31 ) begin oled_data <= 16'h0000; end
        if ( y == 29 && x == 2 ) begin oled_data <= 16'h0842; end
        if ( y == 29 && x == 3 ) begin oled_data <= 16'h21AC; end
        if ( y == 29 && x == 4 ) begin oled_data <= 16'h11F4; end
        if ( y == 29 && x == 5 ) begin oled_data <= 16'h09F6; end
        if ( y == 29 && x == 6 ) begin oled_data <= 16'h2338; end
        if ( y == 29 && x == 7 ) begin oled_data <= 16'h5C9C; end
        if ( y == 29 && x == 8 ) begin oled_data <= 16'h53F9; end
        if ( y == 29 && x == 9 ) begin oled_data <= 16'h5B55; end
        if ( y == 29 && x == 10 ) begin oled_data <= 16'h5A2D; end
        if ( y == 29 && x == 11 ) begin oled_data <= 16'h4969; end
        if ( y == 29 && x == 12 ) begin oled_data <= 16'h5A8D; end
        if ( y == 29 && x == 13 ) begin oled_data <= 16'h1906; end
        if ( y == 29 && x >= 14 && x <= 31 ) begin oled_data <= 16'h0000; end
        if ( y == 30 && x == 2 ) begin oled_data <= 16'h1906; end
        if ( y == 30 && x == 3 ) begin oled_data <= 16'h29EE; end
        if ( y == 30 && x == 4 ) begin oled_data <= 16'h11D3; end
        if ( y == 30 && x == 5 ) begin oled_data <= 16'h22B7; end
        if ( y == 30 && x == 6 ) begin oled_data <= 16'h6CFD; end
        if ( y == 30 && x == 7 ) begin oled_data <= 16'h4373; end
        if ( y == 30 && x == 8 ) begin oled_data <= 16'h29AA; end
        if ( y == 30 && x == 9 ) begin oled_data <= 16'h49C9; end
        if ( y == 30 && x == 10 ) begin oled_data <= 16'h624A; end
        if ( y == 30 && x == 11 ) begin oled_data <= 16'h51E8; end
        if ( y == 30 && x == 12 ) begin oled_data <= 16'h41E9; end
        if ( y == 30 && x == 13 ) begin oled_data <= 16'h18E4; end
        if ( y == 30 && x == 14 ) begin oled_data <= 16'h0000; end
        if ( y == 30 && x == 15 ) begin oled_data <= 16'h0020; end
        if ( y == 30 && x >= 16 && x <= 31 ) begin oled_data <= 16'h0000; end
        if ( y == 31 && x == 2 ) begin oled_data <= 16'h2147; end
        if ( y == 31 && x == 3 ) begin oled_data <= 16'h29CC; end
        if ( y == 31 && x == 4 ) begin oled_data <= 16'h19AF; end
        if ( y == 31 && x == 5 ) begin oled_data <= 16'h6419; end
        if ( y == 31 && x == 6 ) begin oled_data <= 16'h74B9; end
        if ( y == 31 && x == 7 ) begin oled_data <= 16'h3A6C; end
        if ( y == 31 && x == 8 ) begin oled_data <= 16'h93EE; end
        if ( y == 31 && x == 9 ) begin oled_data <= 16'hA3ED; end
        if ( y == 31 && x == 10 ) begin oled_data <= 16'hB490; end
        if ( y == 31 && x == 11 ) begin oled_data <= 16'hC554; end
        if ( y == 31 && x == 12 ) begin oled_data <= 16'h62AA; end
        if ( y == 31 && x == 13 ) begin oled_data <= 16'h1082; end
        if ( y == 31 && x >= 14 && x <= 15 ) begin oled_data <= 16'h0000; end
        if ( y == 31 && x == 16 ) begin oled_data <= 16'h0020; end
        if ( y == 31 && x == 17 ) begin oled_data <= 16'h2965; end
        if ( y == 31 && x == 18 ) begin oled_data <= 16'h2945; end
        if ( y == 31 && x == 19 ) begin oled_data <= 16'h18C3; end
        if ( y == 31 && x == 20 ) begin oled_data <= 16'h0020; end
        if ( y == 31 && x >= 21 && x <= 31 ) begin oled_data <= 16'h0000; end
        if ( y == 32 && x == 2 ) begin oled_data <= 16'h2146; end
        if ( y == 32 && x == 3 ) begin oled_data <= 16'h31A9; end
        if ( y == 32 && x == 4 ) begin oled_data <= 16'h2128; end
        if ( y == 32 && x == 5 ) begin oled_data <= 16'h3A0B; end
        if ( y == 32 && x == 6 ) begin oled_data <= 16'h634F; end
        if ( y == 32 && x == 7 ) begin oled_data <= 16'h7B8E; end
        if ( y == 32 && x == 8 ) begin oled_data <= 16'hEE15; end
        if ( y == 32 && x == 9 ) begin oled_data <= 16'hF5D2; end
        if ( y == 32 && x == 10 ) begin oled_data <= 16'hBC2D; end
        if ( y == 32 && x == 11 ) begin oled_data <= 16'hA3AC; end
        if ( y == 32 && x == 12 ) begin oled_data <= 16'h9C0F; end
        if ( y == 32 && x == 13 ) begin oled_data <= 16'h1040; end
        if ( y == 32 && x == 14 ) begin oled_data <= 16'h0000; end
        if ( y == 32 && x == 15 ) begin oled_data <= 16'h1082; end
        if ( y == 32 && x == 16 ) begin oled_data <= 16'h39E7; end
        if ( y == 32 && x == 17 ) begin oled_data <= 16'h8C71; end
        if ( y == 32 && x == 18 ) begin oled_data <= 16'hAD75; end
        if ( y == 32 && x == 19 ) begin oled_data <= 16'h8C30; end
        if ( y == 32 && x == 20 ) begin oled_data <= 16'h52AA; end
        if ( y == 32 && x == 21 ) begin oled_data <= 16'h1082; end
        if ( y == 32 && x >= 22 && x <= 31 ) begin oled_data <= 16'h0000; end
        if ( y == 33 && x == 2 ) begin oled_data <= 16'h10C5; end
        if ( y == 33 && x == 3 ) begin oled_data <= 16'h31A8; end
        if ( y == 33 && x == 4 ) begin oled_data <= 16'h3167; end
        if ( y == 33 && x == 5 ) begin oled_data <= 16'h2106; end
        if ( y == 33 && x == 6 ) begin oled_data <= 16'h2147; end
        if ( y == 33 && x == 7 ) begin oled_data <= 16'h7B8F; end
        if ( y == 33 && x == 8 ) begin oled_data <= 16'hEE15; end
        if ( y == 33 && x == 9 ) begin oled_data <= 16'hC42C; end
        if ( y == 33 && x == 10 ) begin oled_data <= 16'h6100; end
        if ( y == 33 && x == 11 ) begin oled_data <= 16'h71E4; end
        if ( y == 33 && x == 12 ) begin oled_data <= 16'h9BED; end
        if ( y == 33 && x == 13 ) begin oled_data <= 16'h1040; end
        if ( y == 33 && x == 14 ) begin oled_data <= 16'h0000; end
        if ( y == 33 && x == 15 ) begin oled_data <= 16'h29C8; end
        if ( y == 33 && x == 16 ) begin oled_data <= 16'h8CD5; end
        if ( y == 33 && x == 17 ) begin oled_data <= 16'h636F; end
        if ( y == 33 && x == 18 ) begin oled_data <= 16'hAD76; end
        if ( y == 33 && x == 19 ) begin oled_data <= 16'hB5B7; end
        if ( y == 33 && x == 20 ) begin oled_data <= 16'h8C72; end
        if ( y == 33 && x == 21 ) begin oled_data <= 16'h39E7; end
        if ( y == 33 && x >= 22 && x <= 29 ) begin oled_data <= 16'h0000; end
        if ( y == 34 && x >= 0 && x <= 1 ) begin oled_data <= 16'h0001; end
        if ( y == 34 && x == 2 ) begin oled_data <= 16'h08C5; end
        if ( y == 34 && x == 3 ) begin oled_data <= 16'h29A9; end
        if ( y == 34 && x == 4 ) begin oled_data <= 16'h3168; end
        if ( y == 34 && x == 5 ) begin oled_data <= 16'h2949; end
        if ( y == 34 && x == 6 ) begin oled_data <= 16'h21CD; end
        if ( y == 34 && x == 7 ) begin oled_data <= 16'h31ED; end
        if ( y == 34 && x == 8 ) begin oled_data <= 16'hA452; end
        if ( y == 34 && x == 9 ) begin oled_data <= 16'hBC4F; end
        if ( y == 34 && x == 10 ) begin oled_data <= 16'h8226; end
        if ( y == 34 && x == 11 ) begin oled_data <= 16'hABAC; end
        if ( y == 34 && x == 12 ) begin oled_data <= 16'h9BEE; end
        if ( y == 34 && x == 13 ) begin oled_data <= 16'h1082; end
        if ( y == 34 && x == 14 ) begin oled_data <= 16'h1108; end
        if ( y == 34 && x == 15 ) begin oled_data <= 16'h2A6F; end
        if ( y == 34 && x == 16 ) begin oled_data <= 16'h1A0E; end
        if ( y == 34 && x == 17 ) begin oled_data <= 16'h2A2D; end
        if ( y == 34 && x == 18 ) begin oled_data <= 16'h5B2E; end
        if ( y == 34 && x == 19 ) begin oled_data <= 16'h8452; end
        if ( y == 34 && x == 20 ) begin oled_data <= 16'hBDD7; end
        if ( y == 34 && x == 21 ) begin oled_data <= 16'h31A6; end
        if ( y == 34 && x >= 22 && x <= 29 ) begin oled_data <= 16'h0000; end
        if ( y == 35 && x == 0 ) begin oled_data <= 16'h08C7; end
        if ( y == 35 && x == 1 ) begin oled_data <= 16'h21EC; end
        if ( y == 35 && x == 2 ) begin oled_data <= 16'h222E; end
        if ( y == 35 && x == 3 ) begin oled_data <= 16'h19ED; end
        if ( y == 35 && x == 4 ) begin oled_data <= 16'h42EF; end
        if ( y == 35 && x == 5 ) begin oled_data <= 16'h3A8F; end
        if ( y == 35 && x == 6 ) begin oled_data <= 16'h2AD3; end
        if ( y == 35 && x == 7 ) begin oled_data <= 16'h2A92; end
        if ( y == 35 && x == 8 ) begin oled_data <= 16'h296A; end
        if ( y == 35 && x == 9 ) begin oled_data <= 16'h730F; end
        if ( y == 35 && x == 10 ) begin oled_data <= 16'h9C53; end
        if ( y == 35 && x == 11 ) begin oled_data <= 16'h8C11; end
        if ( y == 35 && x == 12 ) begin oled_data <= 16'h4A6B; end
        if ( y == 35 && x == 13 ) begin oled_data <= 16'h21C9; end
        if ( y == 35 && x == 14 ) begin oled_data <= 16'h2A4F; end
        if ( y == 35 && x == 15 ) begin oled_data <= 16'h2AD3; end
        if ( y == 35 && x == 16 ) begin oled_data <= 16'h2B77; end
        if ( y == 35 && x == 17 ) begin oled_data <= 16'h1AB3; end
        if ( y == 35 && x == 18 ) begin oled_data <= 16'h19ED; end
        if ( y == 35 && x == 19 ) begin oled_data <= 16'h3A6D; end
        if ( y == 35 && x == 20 ) begin oled_data <= 16'h4AEE; end
        if ( y == 35 && x == 21 ) begin oled_data <= 16'h1106; end
        if ( y == 35 && x >= 22 && x <= 29 ) begin oled_data <= 16'h0000; end
        if ( y == 36 && x == 0 ) begin oled_data <= 16'h2233; end
        if ( y == 36 && x == 1 ) begin oled_data <= 16'h22B5; end
        if ( y == 36 && x == 2 ) begin oled_data <= 16'h2BDA; end
        if ( y == 36 && x == 3 ) begin oled_data <= 16'h1315; end
        if ( y == 36 && x == 4 ) begin oled_data <= 16'h653B; end
        if ( y == 36 && x == 5 ) begin oled_data <= 16'h861E; end
        if ( y == 36 && x == 6 ) begin oled_data <= 16'h2356; end
        if ( y == 36 && x == 7 ) begin oled_data <= 16'h2336; end
        if ( y == 36 && x == 8 ) begin oled_data <= 16'h1212; end
        if ( y == 36 && x == 9 ) begin oled_data <= 16'h1A53; end
        if ( y == 36 && x == 10 ) begin oled_data <= 16'h2B15; end
        if ( y == 36 && x == 11 ) begin oled_data <= 16'h2334; end
        if ( y == 36 && x == 12 ) begin oled_data <= 16'h1AB0; end
        if ( y == 36 && x == 13 ) begin oled_data <= 16'h43D4; end
        if ( y == 36 && x == 14 ) begin oled_data <= 16'h4BF7; end
        if ( y == 36 && x == 15 ) begin oled_data <= 16'h12B5; end
        if ( y == 36 && x == 16 ) begin oled_data <= 16'h23FC; end
        if ( y == 36 && x == 17 ) begin oled_data <= 16'h1BFC; end
        if ( y == 36 && x == 18 ) begin oled_data <= 16'h1316; end
        if ( y == 36 && x == 19 ) begin oled_data <= 16'h01D0; end
        if ( y == 36 && x == 20 ) begin oled_data <= 16'h22B2; end
        if ( y == 36 && x == 21 ) begin oled_data <= 16'h32F1; end
        if ( y == 36 && x == 22 ) begin oled_data <= 16'h1126; end
        if ( y == 36 && x == 23 ) begin oled_data <= 16'h0000; end
        if ( y == 36 && x == 24 ) begin oled_data <= 16'h0021; end
        if ( y == 36 && x >= 25 && x <= 29 ) begin oled_data <= 16'h0000; end
        if ( y == 37 && x == 0 ) begin oled_data <= 16'h2276; end
        if ( y == 37 && x == 1 ) begin oled_data <= 16'h1AB7; end
        if ( y == 37 && x == 2 ) begin oled_data <= 16'h2BDA; end
        if ( y == 37 && x == 3 ) begin oled_data <= 16'h1356; end
        if ( y == 37 && x == 4 ) begin oled_data <= 16'h33D4; end
        if ( y == 37 && x == 5 ) begin oled_data <= 16'h96DF; end
        if ( y == 37 && x == 6 ) begin oled_data <= 16'h4438; end
        if ( y == 37 && x == 7 ) begin oled_data <= 16'h22F5; end
        if ( y == 37 && x == 8 ) begin oled_data <= 16'h1255; end
        if ( y == 37 && x == 9 ) begin oled_data <= 16'h12D8; end
        if ( y == 37 && x == 10 ) begin oled_data <= 16'h241B; end
        if ( y == 37 && x == 11 ) begin oled_data <= 16'h1BB8; end
        if ( y == 37 && x == 12 ) begin oled_data <= 16'h1354; end
        if ( y == 37 && x == 13 ) begin oled_data <= 16'h863F; end
        if ( y == 37 && x == 14 ) begin oled_data <= 16'h4C59; end
        if ( y == 37 && x == 15 ) begin oled_data <= 16'h0212; end
        if ( y == 37 && x == 16 ) begin oled_data <= 16'h13DD; end
        if ( y == 37 && x == 17 ) begin oled_data <= 16'h0BDD; end
        if ( y == 37 && x == 18 ) begin oled_data <= 16'h1BFD; end
        if ( y == 37 && x == 19 ) begin oled_data <= 16'h0B18; end
        if ( y == 37 && x == 20 ) begin oled_data <= 16'h12F7; end
        if ( y == 37 && x == 21 ) begin oled_data <= 16'h3396; end
        if ( y == 37 && x == 22 ) begin oled_data <= 16'h32D0; end
        if ( y == 37 && x == 23 ) begin oled_data <= 16'h0064; end
        if ( y == 37 && x == 24 ) begin oled_data <= 16'h0001; end
        if ( y == 38 && x == 0 ) begin oled_data <= 16'h2A75; end
        if ( y == 38 && x == 1 ) begin oled_data <= 16'h1A32; end
        if ( y == 38 && x == 2 ) begin oled_data <= 16'h2B13; end
        if ( y == 38 && x == 3 ) begin oled_data <= 16'h4373; end
        if ( y == 38 && x == 4 ) begin oled_data <= 16'h328D; end
        if ( y == 38 && x == 5 ) begin oled_data <= 16'h4B71; end
        if ( y == 38 && x == 6 ) begin oled_data <= 16'h32AF; end
        if ( y == 38 && x == 7 ) begin oled_data <= 16'h2A91; end
        if ( y == 38 && x == 8 ) begin oled_data <= 16'h11D1; end
        if ( y == 38 && x == 9 ) begin oled_data <= 16'h09F2; end
        if ( y == 38 && x == 10 ) begin oled_data <= 16'h12D4; end
        if ( y == 38 && x == 11 ) begin oled_data <= 16'h0AF2; end
        if ( y == 38 && x == 12 ) begin oled_data <= 16'h3C56; end
        if ( y == 38 && x == 13 ) begin oled_data <= 16'h96FF; end
        if ( y == 38 && x == 14 ) begin oled_data <= 16'h4BF6; end
        if ( y == 38 && x == 15 ) begin oled_data <= 16'h018F; end
        if ( y == 38 && x == 16 ) begin oled_data <= 16'h0AD8; end
        if ( y == 38 && x == 17 ) begin oled_data <= 16'h1BBE; end
        if ( y == 38 && x == 18 ) begin oled_data <= 16'h13DD; end
        if ( y == 38 && x == 19 ) begin oled_data <= 16'h1BFD; end
        if ( y == 38 && x == 20 ) begin oled_data <= 16'h0296; end
        if ( y == 38 && x == 21 ) begin oled_data <= 16'h0274; end
        if ( y == 38 && x == 22 ) begin oled_data <= 16'h12B3; end
        if ( y == 38 && x == 23 ) begin oled_data <= 16'h09EE; end
        if ( y == 38 && x == 24 ) begin oled_data <= 16'h21AA; end
        if ( y == 38 && x == 25 ) begin oled_data <= 16'h08A4; end
        if ( y == 39 && x == 0 ) begin oled_data <= 16'h29F0; end
        if ( y == 39 && x == 1 ) begin oled_data <= 16'h7458; end
        if ( y == 39 && x == 2 ) begin oled_data <= 16'hCF1F; end
        if ( y == 39 && x == 3 ) begin oled_data <= 16'hDFBF; end
        if ( y == 39 && x == 4 ) begin oled_data <= 16'hC67B; end
        if ( y == 39 && x == 5 ) begin oled_data <= 16'h530D; end
        if ( y == 39 && x == 6 ) begin oled_data <= 16'h2189; end
        if ( y == 39 && x == 7 ) begin oled_data <= 16'h2A0C; end
        if ( y == 39 && x == 8 ) begin oled_data <= 16'h116D; end
        if ( y == 39 && x == 9 ) begin oled_data <= 16'h2271; end
        if ( y == 39 && x == 10 ) begin oled_data <= 16'h6D3B; end
        if ( y == 39 && x == 11 ) begin oled_data <= 16'h54D8; end
        if ( y == 39 && x == 12 ) begin oled_data <= 16'h6DDB; end
        if ( y == 39 && x == 13 ) begin oled_data <= 16'h8EDF; end
        if ( y == 39 && x == 14 ) begin oled_data <= 16'h5416; end
        if ( y == 39 && x == 15 ) begin oled_data <= 16'h018F; end
        if ( y == 39 && x == 16 ) begin oled_data <= 16'h01D3; end
        if ( y == 39 && x == 17 ) begin oled_data <= 16'h0A98; end
        if ( y == 39 && x == 18 ) begin oled_data <= 16'h1BBD; end
        if ( y == 39 && x == 19 ) begin oled_data <= 16'h0B5B; end
        if ( y == 39 && x == 20 ) begin oled_data <= 16'h02D8; end
        if ( y == 39 && x == 21 ) begin oled_data <= 16'h2379; end
        if ( y == 39 && x == 22 ) begin oled_data <= 16'h33B8; end
        if ( y == 39 && x == 23 ) begin oled_data <= 16'h3354; end
        if ( y == 39 && x == 24 ) begin oled_data <= 16'h3AAF; end
        if ( y == 39 && x == 25 ) begin oled_data <= 16'h1106; end
        if ( y == 39 && x == 26 ) begin oled_data <= 16'h0001; end
        if ( y == 40 && x == 0 ) begin oled_data <= 16'h52CD; end
        if ( y == 40 && x == 1 ) begin oled_data <= 16'hD6FD; end
        if ( y == 40 && x == 2 ) begin oled_data <= 16'hE77F; end
        if ( y == 40 && x == 3 ) begin oled_data <= 16'hDF1D; end
        if ( y == 40 && x == 4 ) begin oled_data <= 16'hCE9A; end
        if ( y == 40 && x == 5 ) begin oled_data <= 16'hAD76; end
        if ( y == 40 && x == 6 ) begin oled_data <= 16'h634E; end
        if ( y == 40 && x == 7 ) begin oled_data <= 16'h08E5; end
        if ( y == 40 && x == 8 ) begin oled_data <= 16'h21EC; end
        if ( y == 40 && x == 9 ) begin oled_data <= 16'h6C98; end
        if ( y == 40 && x == 10 ) begin oled_data <= 16'h7D7B; end
        if ( y == 40 && x == 11 ) begin oled_data <= 16'h4456; end
        if ( y == 40 && x == 12 ) begin oled_data <= 16'h7E9E; end
        if ( y == 40 && x == 13 ) begin oled_data <= 16'h7E5E; end
        if ( y == 40 && x == 14 ) begin oled_data <= 16'h4C16; end
        if ( y == 40 && x == 15 ) begin oled_data <= 16'h098E; end
        if ( y == 40 && x == 16 ) begin oled_data <= 16'h11B1; end
        if ( y == 40 && x == 17 ) begin oled_data <= 16'h09B2; end
        if ( y == 40 && x == 18 ) begin oled_data <= 16'h0A36; end
        if ( y == 40 && x == 19 ) begin oled_data <= 16'h0277; end
        if ( y == 40 && x == 20 ) begin oled_data <= 16'h1BBB; end
        if ( y == 40 && x == 21 ) begin oled_data <= 16'h2BFA; end
        if ( y == 40 && x == 22 ) begin oled_data <= 16'h22D2; end
        if ( y == 40 && x == 23 ) begin oled_data <= 16'h11AB; end
        if ( y == 40 && x == 24 ) begin oled_data <= 16'h1169; end
        if ( y == 40 && x == 25 ) begin oled_data <= 16'h1128; end
        if ( y == 40 && x == 26 ) begin oled_data <= 16'h00A5; end
        if ( y == 40 && x == 27 ) begin oled_data <= 16'h0043; end
        if ( y == 40 && x == 28 ) begin oled_data <= 16'h0001; end
        if ( y == 41 && x == 0 ) begin oled_data <= 16'h6B6D; end
        if ( y == 41 && x == 1 ) begin oled_data <= 16'hBDF7; end
        if ( y == 41 && x == 2 ) begin oled_data <= 16'hC618; end
        if ( y == 41 && x == 3 ) begin oled_data <= 16'hB5B6; end
        if ( y == 41 && x == 4 ) begin oled_data <= 16'hAD55; end
        if ( y == 41 && x == 5 ) begin oled_data <= 16'h7BCF; end
        if ( y == 41 && x == 6 ) begin oled_data <= 16'h94B2; end
        if ( y == 41 && x == 7 ) begin oled_data <= 16'h2145; end
        if ( y == 41 && x == 8 ) begin oled_data <= 16'h00A5; end
        if ( y == 41 && x == 9 ) begin oled_data <= 16'h4B51; end
        if ( y == 41 && x == 10 ) begin oled_data <= 16'h122F; end
        if ( y == 41 && x == 11 ) begin oled_data <= 16'h33D6; end
        if ( y == 41 && x == 12 ) begin oled_data <= 16'h8EFF; end
        if ( y == 41 && x == 13 ) begin oled_data <= 16'h6DDD; end
        if ( y == 41 && x == 14 ) begin oled_data <= 16'h4BD6; end
        if ( y == 41 && x == 15 ) begin oled_data <= 16'h118E; end
        if ( y == 41 && x == 16 ) begin oled_data <= 16'h198F; end
        if ( y == 41 && x == 17 ) begin oled_data <= 16'h1990; end
        if ( y == 41 && x == 18 ) begin oled_data <= 16'h0172; end
        if ( y == 41 && x == 19 ) begin oled_data <= 16'h1A96; end
        if ( y == 41 && x == 20 ) begin oled_data <= 16'h2BD9; end
        if ( y == 41 && x == 21 ) begin oled_data <= 16'h0A92; end
        if ( y == 41 && x == 22 ) begin oled_data <= 16'h016B; end
        if ( y == 41 && x == 23 ) begin oled_data <= 16'h0949; end
        if ( y == 41 && x == 24 ) begin oled_data <= 16'h11EE; end
        if ( y == 41 && x == 25 ) begin oled_data <= 16'h22B1; end
        if ( y == 41 && x == 26 ) begin oled_data <= 16'h2AF2; end
        if ( y == 41 && x == 27 ) begin oled_data <= 16'h2A6F; end
        if ( y == 41 && x == 28 ) begin oled_data <= 16'h1127; end
        if ( y == 41 && x == 29 ) begin oled_data <= 16'h0063; end
        if ( y == 42 && x == 0 ) begin oled_data <= 16'h2104; end
        if ( y == 42 && x == 1 ) begin oled_data <= 16'h5AEB; end
        if ( y == 42 && x == 2 ) begin oled_data <= 16'h738E; end
        if ( y == 42 && x == 3 ) begin oled_data <= 16'h73AE; end
        if ( y == 42 && x == 4 ) begin oled_data <= 16'h5AEB; end
        if ( y == 42 && x == 5 ) begin oled_data <= 16'h2945; end
        if ( y == 42 && x == 6 ) begin oled_data <= 16'h0861; end
        if ( y == 42 && x == 7 ) begin oled_data <= 16'h0862; end
        if ( y == 42 && x == 8 ) begin oled_data <= 16'h0001; end
        if ( y == 42 && x == 9 ) begin oled_data <= 16'h198A; end
        if ( y == 42 && x == 10 ) begin oled_data <= 16'h1212; end
        if ( y == 42 && x == 11 ) begin oled_data <= 16'h1B17; end
        if ( y == 42 && x == 12 ) begin oled_data <= 16'h54FD; end
        if ( y == 42 && x == 13 ) begin oled_data <= 16'h549A; end
        if ( y == 42 && x == 14 ) begin oled_data <= 16'h2AB3; end
        if ( y == 42 && x == 15 ) begin oled_data <= 16'h116D; end
        if ( y == 42 && x == 16 ) begin oled_data <= 16'h196C; end
        if ( y == 42 && x == 17 ) begin oled_data <= 16'h196D; end
        if ( y == 42 && x == 18 ) begin oled_data <= 16'h1171; end
        if ( y == 42 && x == 19 ) begin oled_data <= 16'h2253; end
        if ( y == 42 && x == 20 ) begin oled_data <= 16'h1A0E; end
        if ( y == 42 && x >= 21 && x <= 22 ) begin oled_data <= 16'h094A; end
        if ( y == 42 && x == 23 ) begin oled_data <= 16'h09CD; end
        if ( y == 42 && x == 24 ) begin oled_data <= 16'h2398; end
        if ( y == 42 && x == 25 ) begin oled_data <= 16'h1BFB; end
        if ( y == 42 && x == 26 ) begin oled_data <= 16'h13DB; end
        if ( y == 42 && x == 27 ) begin oled_data <= 16'h23B9; end
        if ( y == 42 && x == 28 ) begin oled_data <= 16'h3353; end
        if ( y == 42 && x == 29 ) begin oled_data <= 16'h098B; end
        if ( y == 43 && x == 1 ) begin oled_data <= 16'h1082; end
        if ( y == 43 && x == 2 ) begin oled_data <= 16'h2124; end
        if ( y == 43 && x == 3 ) begin oled_data <= 16'h2945; end
        if ( y == 43 && x == 4 ) begin oled_data <= 16'h18E3; end
        if ( y == 43 && x == 5 ) begin oled_data <= 16'h0020; end
        if ( y == 43 && x >= 6 && x <= 8 ) begin oled_data <= 16'h0000; end
        if ( y == 43 && x == 9 ) begin oled_data <= 16'h21AA; end
        if ( y == 43 && x == 10 ) begin oled_data <= 16'h2233; end
        if ( y == 43 && x == 11 ) begin oled_data <= 16'h1A76; end
        if ( y == 43 && x == 12 ) begin oled_data <= 16'h1275; end
        if ( y == 43 && x == 13 ) begin oled_data <= 16'h1A94; end
        if ( y == 43 && x == 14 ) begin oled_data <= 16'h19F0; end
        if ( y == 43 && x == 15 ) begin oled_data <= 16'h198D; end
        if ( y == 43 && x == 16 ) begin oled_data <= 16'h29AB; end
        if ( y == 43 && x == 17 ) begin oled_data <= 16'h216B; end
        if ( y == 43 && x >= 18 && x <= 19 ) begin oled_data <= 16'h198E; end
        if ( y == 43 && x == 20 ) begin oled_data <= 16'h1128; end
        if ( y == 43 && x == 21 ) begin oled_data <= 16'h1948; end
        if ( y == 43 && x == 22 ) begin oled_data <= 16'h114B; end
        if ( y == 43 && x == 23 ) begin oled_data <= 16'h22B3; end
        if ( y == 43 && x == 24 ) begin oled_data <= 16'h23FC; end
        if ( y == 43 && x >= 25 && x <= 26 ) begin oled_data <= 16'h0BDD; end
        if ( y == 43 && x == 27 ) begin oled_data <= 16'h23DA; end
        if ( y == 43 && x == 28 ) begin oled_data <= 16'h3354; end
        if ( y == 43 && x == 29 ) begin oled_data <= 16'h11CB; end
        if ( y == 44 && x >= 3 && x <= 8 ) begin oled_data <= 16'h0000; end
        if ( y == 44 && x == 9 ) begin oled_data <= 16'h10E6; end
        if ( y == 44 && x == 10 ) begin oled_data <= 16'h2A30; end
        if ( y == 44 && x == 11 ) begin oled_data <= 16'h19F2; end
        if ( y == 44 && x == 12 ) begin oled_data <= 16'h2254; end
        if ( y == 44 && x == 13 ) begin oled_data <= 16'h1A12; end
        if ( y == 44 && x == 14 ) begin oled_data <= 16'h21EE; end
        if ( y == 44 && x == 15 ) begin oled_data <= 16'h29CB; end
        if ( y == 44 && x == 16 ) begin oled_data <= 16'h1907; end
        if ( y == 44 && x == 17 ) begin oled_data <= 16'h31C9; end
        if ( y == 44 && x == 18 ) begin oled_data <= 16'h298A; end
        if ( y == 44 && x == 19 ) begin oled_data <= 16'h1929; end
        if ( y == 44 && x == 20 ) begin oled_data <= 16'h1928; end
        if ( y == 44 && x == 21 ) begin oled_data <= 16'h196B; end
        if ( y == 44 && x == 22 ) begin oled_data <= 16'h19AF; end
        if ( y == 44 && x == 23 ) begin oled_data <= 16'h1A54; end
        if ( y == 44 && x == 24 ) begin oled_data <= 16'h237B; end
        if ( y == 44 && x == 25 ) begin oled_data <= 16'h23DC; end
        if ( y == 44 && x == 26 ) begin oled_data <= 16'h2BB9; end
        if ( y == 44 && x == 27 ) begin oled_data <= 16'h2B34; end
        if ( y == 44 && x == 28 ) begin oled_data <= 16'h3AAE; end
        if ( y == 44 && x == 29 ) begin oled_data <= 16'h1106; end
        if ( y == 45 && x >= 2 && x <= 8 ) begin oled_data <= 16'h0000; end
        if ( y == 45 && x == 9 ) begin oled_data <= 16'h0001; end
        if ( y == 45 && x == 10 ) begin oled_data <= 16'h1929; end
        if ( y == 45 && x == 11 ) begin oled_data <= 16'h29EE; end
        if ( y == 45 && x == 12 ) begin oled_data <= 16'h090C; end
        if ( y == 45 && x == 13 ) begin oled_data <= 16'h196D; end
        if ( y == 45 && x == 14 ) begin oled_data <= 16'h29CB; end
        if ( y == 45 && x == 15 ) begin oled_data <= 16'h08A4; end
        if ( y == 45 && x == 16 ) begin oled_data <= 16'h0001; end
        if ( y == 45 && x == 17 ) begin oled_data <= 16'h18E4; end
        if ( y == 45 && x == 18 ) begin oled_data <= 16'h1905; end
        if ( y == 45 && x == 19 ) begin oled_data <= 16'h2988; end
        if ( y == 45 && x == 20 ) begin oled_data <= 16'h2969; end
        if ( y == 45 && x == 21 ) begin oled_data <= 16'h218B; end
        if ( y == 45 && x == 22 ) begin oled_data <= 16'h198E; end
        if ( y == 45 && x == 23 ) begin oled_data <= 16'h11D1; end
        if ( y == 45 && x == 24 ) begin oled_data <= 16'h1253; end
        if ( y == 45 && x == 25 ) begin oled_data <= 16'h1A93; end
        if ( y == 45 && x == 26 ) begin oled_data <= 16'h11EE; end
        if ( y == 45 && x == 27 ) begin oled_data <= 16'h0949; end
        if ( y == 45 && x == 28 ) begin oled_data <= 16'h0063; end
        if ( y == 45 && x >= 29 && x <= 39 ) begin oled_data <= 16'h0000; end
        if ( y == 46 && x >= 1 && x <= 9 ) begin oled_data <= 16'h0000; end
        if ( y == 46 && x == 10 ) begin oled_data <= 16'h0001; end
        if ( y == 46 && x >= 11 && x <= 13 ) begin oled_data <= 16'h0002; end
        if ( y == 46 && x == 14 ) begin oled_data <= 16'h0001; end
        if ( y == 46 && x >= 15 && x <= 18 ) begin oled_data <= 16'h0000; end
        if ( y == 46 && x == 19 ) begin oled_data <= 16'h2146; end
        if ( y == 46 && x == 20 ) begin oled_data <= 16'h422B; end
        if ( y == 46 && x == 21 ) begin oled_data <= 16'h31EB; end
        if ( y == 46 && x == 22 ) begin oled_data <= 16'h31EC; end
        if ( y == 46 && x == 23 ) begin oled_data <= 16'h218B; end
        if ( y == 46 && x == 24 ) begin oled_data <= 16'h0908; end
        if ( y == 46 && x == 25 ) begin oled_data <= 16'h0064; end
        if ( y == 46 && x == 26 ) begin oled_data <= 16'h0002; end
        if ( y == 46 && x == 27 ) begin oled_data <= 16'h0001; end
        
        gameover_counter <= gameover_counter + 1;
        //game over image 
        if (gameover_counter == 24'd12500000)
        begin
        if ( y == 28 && x == 12 ) begin oled_data <= 16'h0841; end
        if ( y == 28 && x == 13 ) begin oled_data <= 16'h4228; end
        if ( y == 28 && x >= 14 && x <= 16 ) begin oled_data <= 16'h52AA; end
        if ( y == 28 && x == 17 ) begin oled_data <= 16'h5AEB; end
        if ( y == 28 && x == 18 ) begin oled_data <= 16'h2945; end
        if ( y == 28 && x == 21 ) begin oled_data <= 16'h18E3; end
        if ( y == 28 && x == 22 ) begin oled_data <= 16'h528A; end
        if ( y == 28 && x == 23 ) begin oled_data <= 16'h52AA; end
        if ( y == 28 && x == 24 ) begin oled_data <= 16'h39E7; end
        if ( y == 28 && x == 27 ) begin oled_data <= 16'h0841; end
        if ( y == 28 && x == 28 ) begin oled_data <= 16'h52AA; end
        if ( y == 28 && x == 29 ) begin oled_data <= 16'h632C; end
        if ( y == 28 && x == 30 ) begin oled_data <= 16'h18C3; end
        if ( y == 28 && x == 34 ) begin oled_data <= 16'h528A; end
        if ( y == 28 && x == 35 ) begin oled_data <= 16'h4208; end
        if ( y == 28 && x == 36 ) begin oled_data <= 16'h2104; end
        if ( y == 28 && x >= 37 && x <= 38 ) begin oled_data <= 16'h73AE; end
        if ( y == 28 && x == 39 ) begin oled_data <= 16'h7BEF; end
        if ( y == 28 && x >= 40 && x <= 41 ) begin oled_data <= 16'h8410; end
        if ( y == 28 && x == 42 ) begin oled_data <= 16'h7BEF; end
        if ( y == 28 && x == 43 ) begin oled_data <= 16'h8430; end
        if ( y == 28 && x == 44 ) begin oled_data <= 16'h632C; end
        if ( y == 28 && x == 50 ) begin oled_data <= 16'h2965; end
        if ( y == 28 && x >= 51 && x <= 52 ) begin oled_data <= 16'h528A; end
        if ( y == 28 && x >= 53 && x <= 54 ) begin oled_data <= 16'h52AA; end
        if ( y == 28 && x == 55 ) begin oled_data <= 16'h4A49; end
        if ( y == 28 && x == 56 ) begin oled_data <= 16'h0841; end
        if ( y == 28 && x == 58 ) begin oled_data <= 16'h4208; end
        if ( y == 28 && x == 59 ) begin oled_data <= 16'h528A; end
        if ( y == 28 && x == 60 ) begin oled_data <= 16'h18C3; end
        if ( y == 28 && x == 63 ) begin oled_data <= 16'h18E3; end
        if ( y == 28 && x == 64 ) begin oled_data <= 16'h528A; end
        if ( y == 28 && x == 65 ) begin oled_data <= 16'h39E7; end
        if ( y == 28 && x == 66 ) begin oled_data <= 16'h18C3; end
        if ( y == 28 && x >= 67 && x <= 68 ) begin oled_data <= 16'h73AE; end
        if ( y == 28 && x == 69 ) begin oled_data <= 16'h7BEF; end
        if ( y == 28 && x >= 70 && x <= 71 ) begin oled_data <= 16'h8410; end
        if ( y == 28 && x == 72 ) begin oled_data <= 16'h7BEF; end
        if ( y == 28 && x == 73 ) begin oled_data <= 16'h8C51; end
        if ( y == 28 && x == 74 ) begin oled_data <= 16'h5ACB; end
        if ( y == 28 && x == 75 ) begin oled_data <= 16'h2124; end
        if ( y == 28 && x == 76 ) begin oled_data <= 16'h528A; end
        if ( y == 28 && x == 77 ) begin oled_data <= 16'h4A69; end
        if ( y == 28 && x >= 78 && x <= 80 ) begin oled_data <= 16'h52AA; end
        if ( y == 28 && x == 81 ) begin oled_data <= 16'h4A69; end
        if ( y == 29 && x == 11 ) begin oled_data <= 16'h0861; end
        if ( y == 29 && x == 12 ) begin oled_data <= 16'h5ACB; end
        if ( y == 29 && x == 13 ) begin oled_data <= 16'hFFDF; end
        if ( y == 29 && x == 14 ) begin oled_data <= 16'hDEFB; end
        if ( y == 29 && x >= 15 && x <= 16 ) begin oled_data <= 16'hD69A; end
        if ( y == 29 && x == 17 ) begin oled_data <= 16'hE73C; end
        if ( y == 29 && x == 18 ) begin oled_data <= 16'h6B4D; end
        if ( y == 29 && x == 21 ) begin oled_data <= 16'h9CD3; end
        if ( y == 29 && x == 22 ) begin oled_data <= 16'hFFFF; end
        if ( y == 29 && x == 23 ) begin oled_data <= 16'hDEDB; end
        if ( y == 29 && x == 24 ) begin oled_data <= 16'hF79E; end
        if ( y == 29 && x == 25 ) begin oled_data <= 16'h4A49; end
        if ( y == 29 && x == 28 ) begin oled_data <= 16'hEF5D; end
        if ( y == 29 && x == 29 ) begin oled_data <= 16'hFFFF; end
        if ( y == 29 && x == 30 ) begin oled_data <= 16'h8C51; end
        if ( y == 29 && x == 32 ) begin oled_data <= 16'h18C3; end
        if ( y == 29 && x == 33 ) begin oled_data <= 16'h8C71; end
        if ( y == 29 && x == 34 ) begin oled_data <= 16'hFFFF; end
        if ( y == 29 && x == 35 ) begin oled_data <= 16'hE73C; end
        if ( y == 29 && x == 36 ) begin oled_data <= 16'h5ACB; end
        if ( y == 29 && x >= 37 && x <= 38 ) begin oled_data <= 16'hFFFF; end
        if ( y == 29 && x == 39 ) begin oled_data <= 16'hDEDB; end
        if ( y == 29 && x >= 40 && x <= 41 ) begin oled_data <= 16'hD6BA; end
        if ( y == 29 && x == 42 ) begin oled_data <= 16'hD69A; end
        if ( y == 29 && x == 43 ) begin oled_data <= 16'hDEFB; end
        if ( y == 29 && x == 44 ) begin oled_data <= 16'hAD55; end
        if ( y == 29 && x == 49 ) begin oled_data <= 16'h18E3; end
        if ( y == 29 && x == 50 ) begin oled_data <= 16'hBDF7; end
        if ( y == 29 && x == 51 ) begin oled_data <= 16'hFFDF; end
        if ( y == 29 && x == 52 ) begin oled_data <= 16'hCE79; end
        if ( y == 29 && x == 53 ) begin oled_data <= 16'hD69A; end
        if ( y == 29 && x == 54 ) begin oled_data <= 16'hDEFB; end
        if ( y == 29 && x == 55 ) begin oled_data <= 16'hFFFF; end
        if ( y == 29 && x == 56 ) begin oled_data <= 16'h5ACB; end
        if ( y == 29 && x == 58 ) begin oled_data <= 16'hDEFB; end
        if ( y == 29 && x == 59 ) begin oled_data <= 16'hFFFF; end
        if ( y == 29 && x == 60 ) begin oled_data <= 16'h5ACB; end
        if ( y == 29 && x == 63 ) begin oled_data <= 16'h632C; end
        if ( y == 29 && x == 64 ) begin oled_data <= 16'hFFFF; end
        if ( y == 29 && x == 65 ) begin oled_data <= 16'hDEFB; end
        if ( y == 29 && x == 66 ) begin oled_data <= 16'h4208; end
        if ( y == 29 && x >= 67 && x <= 68 ) begin oled_data <= 16'hFFFF; end
        if ( y == 29 && x == 69 ) begin oled_data <= 16'hDEFB; end
        if ( y == 29 && x >= 70 && x <= 71 ) begin oled_data <= 16'hD6BA; end
        if ( y == 29 && x == 72 ) begin oled_data <= 16'hD69A; end
        if ( y == 29 && x == 73 ) begin oled_data <= 16'hE71C; end
        if ( y == 29 && x == 74 ) begin oled_data <= 16'h8C71; end
        if ( y == 29 && x == 75 ) begin oled_data <= 16'h8C51; end
        if ( y == 29 && x == 76 ) begin oled_data <= 16'hFFFF; end
        if ( y == 29 && x == 77 ) begin oled_data <= 16'hF79E; end
        if ( y == 29 && x >= 78 && x <= 79 ) begin oled_data <= 16'hD69A; end
        if ( y == 29 && x == 80 ) begin oled_data <= 16'hD6BA; end
        if ( y == 29 && x == 81 ) begin oled_data <= 16'hFFFF; end
        if ( y == 29 && x == 82 ) begin oled_data <= 16'h7BEF; end
        if ( y == 29 && x == 83 ) begin oled_data <= 16'h0841; end
        if ( y == 30 && x == 11 ) begin oled_data <= 16'h73AE; end
        if ( y == 30 && x == 12 ) begin oled_data <= 16'hFFFF; end
        if ( y == 30 && x == 13 ) begin oled_data <= 16'hD69A; end
        if ( y == 30 && x == 14 ) begin oled_data <= 16'h2124; end
        if ( y == 30 && x == 19 ) begin oled_data <= 16'h0861; end
        if ( y == 30 && x == 20 ) begin oled_data <= 16'hA514; end
        if ( y == 30 && x == 21 ) begin oled_data <= 16'hFFFF; end
        if ( y == 30 && x == 22 ) begin oled_data <= 16'h8C71; end
        if ( y == 30 && x == 23 ) begin oled_data <= 16'h18E3; end
        if ( y == 30 && x == 24 ) begin oled_data <= 16'hDEFB; end
        if ( y == 30 && x == 25 ) begin oled_data <= 16'hFFFF; end
        if ( y == 30 && x == 26 ) begin oled_data <= 16'h528A; end
        if ( y == 30 && x == 28 ) begin oled_data <= 16'hE71C; end
        if ( y == 30 && x >= 29 && x <= 30 ) begin oled_data <= 16'hFFFF; end
        if ( y == 30 && x == 31 ) begin oled_data <= 16'h8C51; end
        if ( y == 30 && x == 32 ) begin oled_data <= 16'h8430; end
        if ( y == 30 && x >= 33 && x <= 34 ) begin oled_data <= 16'hFFFF; end
        if ( y == 30 && x == 35 ) begin oled_data <= 16'hE71C; end
        if ( y == 30 && x == 36 ) begin oled_data <= 16'h52AA; end
        if ( y == 30 && x == 37 ) begin oled_data <= 16'hFFDF; end
        if ( y == 30 && x == 38 ) begin oled_data <= 16'hF79E; end
        if ( y == 30 && x == 39 ) begin oled_data <= 16'h18E3; end
        if ( y == 30 && x == 49 ) begin oled_data <= 16'hB596; end
        if ( y == 30 && x == 50 ) begin oled_data <= 16'hFFFF; end
        if ( y == 30 && x == 51 ) begin oled_data <= 16'h9CF3; end
        if ( y == 30 && x == 54 ) begin oled_data <= 16'h2104; end
        if ( y == 30 && x == 55 ) begin oled_data <= 16'hF79E; end
        if ( y == 30 && x == 56 ) begin oled_data <= 16'hFFFF; end
        if ( y == 30 && x == 57 ) begin oled_data <= 16'h4208; end
        if ( y == 30 && x == 58 ) begin oled_data <= 16'hCE79; end
        if ( y == 30 && x == 59 ) begin oled_data <= 16'hFFFF; end
        if ( y == 30 && x == 60 ) begin oled_data <= 16'h52AA; end
        if ( y == 30 && x == 63 ) begin oled_data <= 16'h630C; end
        if ( y == 30 && x == 64 ) begin oled_data <= 16'hFFFF; end
        if ( y == 30 && x == 65 ) begin oled_data <= 16'hD6BA; end
        if ( y == 30 && x == 66 ) begin oled_data <= 16'h39E7; end
        if ( y == 30 && x == 67 ) begin oled_data <= 16'hF7BE; end
        if ( y == 30 && x == 68 ) begin oled_data <= 16'hFFDF; end
        if ( y == 30 && x == 69 ) begin oled_data <= 16'h2945; end
        if ( y == 30 && x == 75 ) begin oled_data <= 16'h8C51; end
        if ( y == 30 && x == 76 ) begin oled_data <= 16'hFFFF; end
        if ( y == 30 && x == 77 ) begin oled_data <= 16'hB5B6; end
        if ( y == 30 && x == 80 ) begin oled_data <= 16'h0861; end
        if ( y == 30 && x == 81 ) begin oled_data <= 16'hDEDB; end
        if ( y == 30 && x == 82 ) begin oled_data <= 16'hFFFF; end
        if ( y == 30 && x == 83 ) begin oled_data <= 16'h5ACB; end
        if ( y == 31 && x == 10 ) begin oled_data <= 16'h6B4D; end
        if ( y == 31 && x == 11 ) begin oled_data <= 16'hFFFF; end
        if ( y == 31 && x == 12 ) begin oled_data <= 16'hDEFB; end
        if ( y == 31 && x == 16 ) begin oled_data <= 16'h18C3; end
        if ( y == 31 && x == 17 ) begin oled_data <= 16'h2104; end
        if ( y == 31 && x == 19 ) begin oled_data <= 16'h9CD3; end
        if ( y == 31 && x == 20 ) begin oled_data <= 16'hFFFF; end
        if ( y == 31 && x == 21 ) begin oled_data <= 16'hA534; end
        if ( y == 31 && x == 24 ) begin oled_data <= 16'h2945; end
        if ( y == 31 && x == 25 ) begin oled_data <= 16'hF79E; end
        if ( y == 31 && x == 26 ) begin oled_data <= 16'hFFFF; end
        if ( y == 31 && x == 27 ) begin oled_data <= 16'h52AA; end
        if ( y == 31 && x == 28 ) begin oled_data <= 16'hDEDB; end
        if ( y == 31 && x == 29 ) begin oled_data <= 16'hFFFF; end
        if ( y == 31 && x >= 30 && x <= 33 ) begin oled_data <= 16'hFFDF; end
        if ( y == 31 && x == 34 ) begin oled_data <= 16'hFFFF; end
        if ( y == 31 && x == 35 ) begin oled_data <= 16'hE71C; end
        if ( y == 31 && x == 36 ) begin oled_data <= 16'h52AA; end
        if ( y == 31 && x == 37 ) begin oled_data <= 16'hFFFF; end
        if ( y == 31 && x == 38 ) begin oled_data <= 16'hF7BE; end
        if ( y == 31 && x == 39 ) begin oled_data <= 16'h4A49; end
        if ( y == 31 && x == 40 ) begin oled_data <= 16'h2945; end
        if ( y == 31 && x == 41 ) begin oled_data <= 16'h31A6; end
        if ( y == 31 && x == 49 ) begin oled_data <= 16'hAD75; end
        if ( y == 31 && x == 50 ) begin oled_data <= 16'hFFFF; end
        if ( y == 31 && x == 51 ) begin oled_data <= 16'hA514; end
        if ( y == 31 && x == 54 ) begin oled_data <= 16'h2124; end
        if ( y == 31 && x == 55 ) begin oled_data <= 16'hF7BE; end
        if ( y == 31 && x == 56 ) begin oled_data <= 16'hFFFF; end
        if ( y == 31 && x == 57 ) begin oled_data <= 16'h4208; end
        if ( y == 31 && x == 58 ) begin oled_data <= 16'hCE79; end
        if ( y == 31 && x == 59 ) begin oled_data <= 16'hFFFF; end
        if ( y == 31 && x == 60 ) begin oled_data <= 16'h6B4D; end
        if ( y == 31 && x == 63 ) begin oled_data <= 16'h630C; end
        if ( y == 31 && x == 64 ) begin oled_data <= 16'hFFFF; end
        if ( y == 31 && x == 65 ) begin oled_data <= 16'hDEDB; end
        if ( y == 31 && x == 66 ) begin oled_data <= 16'h39E7; end
        if ( y == 31 && x >= 67 && x <= 68 ) begin oled_data <= 16'hFFDF; end
        if ( y == 31 && x == 69 ) begin oled_data <= 16'h528A; end
        if ( y == 31 && x == 70 ) begin oled_data <= 16'h2124; end
        if ( y == 31 && x == 71 ) begin oled_data <= 16'h31A6; end
        if ( y == 31 && x == 72 ) begin oled_data <= 16'h18C3; end
        if ( y == 31 && x == 75 ) begin oled_data <= 16'h8C51; end
        if ( y == 31 && x == 76 ) begin oled_data <= 16'hFFFF; end
        if ( y == 31 && x == 77 ) begin oled_data <= 16'hBDD7; end
        if ( y == 31 && x == 80 ) begin oled_data <= 16'h2124; end
        if ( y == 31 && x == 81 ) begin oled_data <= 16'hDEFB; end
        if ( y == 31 && x == 82 ) begin oled_data <= 16'hFFFF; end
        if ( y == 31 && x == 83 ) begin oled_data <= 16'h5ACB; end
        if ( y == 32 && x == 10 ) begin oled_data <= 16'h6B4D; end
        if ( y == 32 && x == 11 ) begin oled_data <= 16'hFFFF; end
        if ( y == 32 && x == 12 ) begin oled_data <= 16'hDEFB; end
        if ( y == 32 && x == 13 ) begin oled_data <= 16'h0861; end
        if ( y == 32 && x == 15 ) begin oled_data <= 16'hCE79; end
        if ( y == 32 && x == 16 ) begin oled_data <= 16'hFFDF; end
        if ( y == 32 && x == 17 ) begin oled_data <= 16'hFFFF; end
        if ( y == 32 && x == 18 ) begin oled_data <= 16'h6B4D; end
        if ( y == 32 && x == 19 ) begin oled_data <= 16'h8C71; end
        if ( y == 32 && x == 20 ) begin oled_data <= 16'hFFFF; end
        if ( y == 32 && x == 21 ) begin oled_data <= 16'hA514; end
        if ( y == 32 && x == 24 ) begin oled_data <= 16'h2104; end
        if ( y == 32 && x == 25 ) begin oled_data <= 16'hF79E; end
        if ( y == 32 && x == 26 ) begin oled_data <= 16'hFFFF; end
        if ( y == 32 && x == 27 ) begin oled_data <= 16'h5ACB; end
        if ( y == 32 && x == 28 ) begin oled_data <= 16'hDEDB; end
        if ( y == 32 && x >= 29 && x <= 34 ) begin oled_data <= 16'hFFFF; end
        if ( y == 32 && x == 35 ) begin oled_data <= 16'hE71C; end
        if ( y == 32 && x == 36 ) begin oled_data <= 16'h52AA; end
        if ( y == 32 && x >= 37 && x <= 38 ) begin oled_data <= 16'hFFFF; end
        if ( y == 32 && x == 39 ) begin oled_data <= 16'hF79E; end
        if ( y == 32 && x == 40 ) begin oled_data <= 16'hEF7D; end
        if ( y == 32 && x == 41 ) begin oled_data <= 16'hFFFF; end
        if ( y == 32 && x == 42 ) begin oled_data <= 16'h7BCF; end
        if ( y == 32 && x == 49 ) begin oled_data <= 16'hAD75; end
        if ( y == 32 && x == 50 ) begin oled_data <= 16'hFFFF; end
        if ( y == 32 && x == 51 ) begin oled_data <= 16'hA514; end
        if ( y == 32 && x == 54 ) begin oled_data <= 16'h2124; end
        if ( y == 32 && x == 55 ) begin oled_data <= 16'hF7BE; end
        if ( y == 32 && x == 56 ) begin oled_data <= 16'hFFFF; end
        if ( y == 32 && x == 57 ) begin oled_data <= 16'h4208; end
        if ( y == 32 && x == 58 ) begin oled_data <= 16'hD6BA; end
        if ( y == 32 && x >= 59 && x <= 60 ) begin oled_data <= 16'hFFFF; end
        if ( y == 32 && x == 61 ) begin oled_data <= 16'h6B6D; end
        if ( y == 32 && x == 62 ) begin oled_data <= 16'h52AA; end
        if ( y == 32 && x == 63 ) begin oled_data <= 16'hEF7D; end
        if ( y == 32 && x == 64 ) begin oled_data <= 16'hFFFF; end
        if ( y == 32 && x == 65 ) begin oled_data <= 16'hD69A; end
        if ( y == 32 && x == 66 ) begin oled_data <= 16'h39E7; end
        if ( y == 32 && x == 67 ) begin oled_data <= 16'hFFDF; end
        if ( y == 32 && x == 68 ) begin oled_data <= 16'hFFFF; end
        if ( y == 32 && x == 69 ) begin oled_data <= 16'hF79E; end
        if ( y == 32 && x == 70 ) begin oled_data <= 16'hEF5D; end
        if ( y == 32 && x == 71 ) begin oled_data <= 16'hFFFF; end
        if ( y == 32 && x == 72 ) begin oled_data <= 16'h8430; end
        if ( y == 32 && x == 75 ) begin oled_data <= 16'h8C51; end
        if ( y == 32 && x == 76 ) begin oled_data <= 16'hFFFF; end
        if ( y == 32 && x == 77 ) begin oled_data <= 16'hBDD7; end
        if ( y == 32 && x == 79 ) begin oled_data <= 16'h18E3; end
        if ( y == 32 && x == 80 ) begin oled_data <= 16'hE73C; end
        if ( y == 32 && x >= 81 && x <= 82 ) begin oled_data <= 16'hFFFF; end
        if ( y == 32 && x == 83 ) begin oled_data <= 16'h5AEB; end
        if ( y == 33 && x == 10 ) begin oled_data <= 16'h6B6D; end
        if ( y == 33 && x == 11 ) begin oled_data <= 16'hFFFF; end
        if ( y == 33 && x == 12 ) begin oled_data <= 16'hDEDB; end
        if ( y == 33 && x == 13 ) begin oled_data <= 16'h0841; end
        if ( y == 33 && x == 15 ) begin oled_data <= 16'h31A6; end
        if ( y == 33 && x == 16 ) begin oled_data <= 16'hC618; end
        if ( y == 33 && x == 17 ) begin oled_data <= 16'hFFFF; end
        if ( y == 33 && x == 18 ) begin oled_data <= 16'h6B6D; end
        if ( y == 33 && x == 19 ) begin oled_data <= 16'h9492; end
        if ( y == 33 && x == 20 ) begin oled_data <= 16'hFFFF; end
        if ( y == 33 && x == 21 ) begin oled_data <= 16'hEF5D; end
        if ( y == 33 && x == 22 ) begin oled_data <= 16'hCE79; end
        if ( y == 33 && x == 23 ) begin oled_data <= 16'hD69A; end
        if ( y == 33 && x == 24 ) begin oled_data <= 16'hD6BA; end
        if ( y == 33 && x == 25 ) begin oled_data <= 16'hFFDF; end
        if ( y == 33 && x == 26 ) begin oled_data <= 16'hFFFF; end
        if ( y == 33 && x == 27 ) begin oled_data <= 16'h5ACB; end
        if ( y == 33 && x == 28 ) begin oled_data <= 16'hD6BA; end
        if ( y == 33 && x == 29 ) begin oled_data <= 16'hFFFF; end
        if ( y == 33 && x == 30 ) begin oled_data <= 16'h8410; end
        if ( y == 33 && x == 31 ) begin oled_data <= 16'hB596; end
        if ( y == 33 && x == 32 ) begin oled_data <= 16'hBDF7; end
        if ( y == 33 && x == 33 ) begin oled_data <= 16'h6B4D; end
        if ( y == 33 && x == 34 ) begin oled_data <= 16'hFFFF; end
        if ( y == 33 && x == 35 ) begin oled_data <= 16'hE71C; end
        if ( y == 33 && x == 36 ) begin oled_data <= 16'h52AA; end
        if ( y == 33 && x == 37 ) begin oled_data <= 16'hFFFF; end
        if ( y == 33 && x == 38 ) begin oled_data <= 16'hF7BE; end
        if ( y == 33 && x == 39 ) begin oled_data <= 16'h4208; end
        if ( y == 33 && x == 40 ) begin oled_data <= 16'h18E3; end
        if ( y == 33 && x == 41 ) begin oled_data <= 16'h2945; end
        if ( y == 33 && x == 49 ) begin oled_data <= 16'hAD75; end
        if ( y == 33 && x == 50 ) begin oled_data <= 16'hFFFF; end
        if ( y == 33 && x == 51 ) begin oled_data <= 16'hA514; end
        if ( y == 33 && x == 54 ) begin oled_data <= 16'h2945; end
        if ( y == 33 && x == 55 ) begin oled_data <= 16'hF7BE; end
        if ( y == 33 && x == 56 ) begin oled_data <= 16'hFFFF; end
        if ( y == 33 && x == 57 ) begin oled_data <= 16'h39C7; end
        if ( y == 33 && x == 58 ) begin oled_data <= 16'h2965; end
        if ( y == 33 && x == 59 ) begin oled_data <= 16'hE71C; end
        if ( y == 33 && x == 60 ) begin oled_data <= 16'hFFFF; end
        if ( y == 33 && x >= 61 && x <= 62 ) begin oled_data <= 16'hEF5D; end
        if ( y == 33 && x == 63 ) begin oled_data <= 16'hFFFF; end
        if ( y == 33 && x == 64 ) begin oled_data <= 16'hE71C; end
        if ( y == 33 && x == 65 ) begin oled_data <= 16'h18C3; end
        if ( y == 33 && x == 66 ) begin oled_data <= 16'h3186; end
        if ( y == 33 && x == 67 ) begin oled_data <= 16'hFFFF; end
        if ( y == 33 && x == 68 ) begin oled_data <= 16'hFFDF; end
        if ( y == 33 && x == 69 ) begin oled_data <= 16'h4A49; end
        if ( y == 33 && x == 70 ) begin oled_data <= 16'h18C3; end
        if ( y == 33 && x == 71 ) begin oled_data <= 16'h2945; end
        if ( y == 33 && x == 75 ) begin oled_data <= 16'h8C71; end
        if ( y == 33 && x == 76 ) begin oled_data <= 16'hFFFF; end
        if ( y == 33 && x == 77 ) begin oled_data <= 16'hEF7D; end
        if ( y == 33 && x == 78 ) begin oled_data <= 16'hC638; end
        if ( y == 33 && x == 79 ) begin oled_data <= 16'hC618; end
        if ( y == 33 && x == 80 ) begin oled_data <= 16'hFFDF; end
        if ( y == 33 && x == 81 ) begin oled_data <= 16'h5ACB; end
        if ( y == 33 && x == 82 ) begin oled_data <= 16'h39E7; end
        if ( y == 33 && x == 83 ) begin oled_data <= 16'h18E3; end
        if ( y == 34 && x == 10 ) begin oled_data <= 16'h18E3; end
        if ( y == 34 && x == 11 ) begin oled_data <= 16'h8410; end
        if ( y == 34 && x == 12 ) begin oled_data <= 16'hFFDF; end
        if ( y == 34 && x == 13 ) begin oled_data <= 16'hA514; end
        if ( y == 34 && x == 14 ) begin oled_data <= 16'h0861; end
        if ( y == 34 && x == 16 ) begin oled_data <= 16'hA514; end
        if ( y == 34 && x == 17 ) begin oled_data <= 16'hFFFF; end
        if ( y == 34 && x == 18 ) begin oled_data <= 16'h6B4D; end
        if ( y == 34 && x == 19 ) begin oled_data <= 16'h8C71; end
        if ( y == 34 && x == 20 ) begin oled_data <= 16'hFFFF; end
        if ( y == 34 && x == 21 ) begin oled_data <= 16'hC638; end
        if ( y == 34 && x == 22 ) begin oled_data <= 16'h6B6D; end
        if ( y == 34 && x == 23 ) begin oled_data <= 16'h73AE; end
        if ( y == 34 && x == 24 ) begin oled_data <= 16'h8430; end
        if ( y == 34 && x == 25 ) begin oled_data <= 16'hF79E; end
        if ( y == 34 && x == 26 ) begin oled_data <= 16'hFFFF; end
        if ( y == 34 && x == 27 ) begin oled_data <= 16'h52AA; end
        if ( y == 34 && x == 28 ) begin oled_data <= 16'hD69A; end
        if ( y == 34 && x == 29 ) begin oled_data <= 16'hFFFF; end
        if ( y == 34 && x == 30 ) begin oled_data <= 16'h632C; end
        if ( y == 34 && x == 31 ) begin oled_data <= 16'h2124; end
        if ( y == 34 && x == 32 ) begin oled_data <= 16'h3186; end
        if ( y == 34 && x == 33 ) begin oled_data <= 16'h4228; end
        if ( y == 34 && x == 34 ) begin oled_data <= 16'hFFFF; end
        if ( y == 34 && x == 35 ) begin oled_data <= 16'hDEFB; end
        if ( y == 34 && x == 36 ) begin oled_data <= 16'h528A; end
        if ( y == 34 && x == 37 ) begin oled_data <= 16'hFFDF; end
        if ( y == 34 && x == 38 ) begin oled_data <= 16'hF79E; end
        if ( y == 34 && x == 39 ) begin oled_data <= 16'h18E3; end
        if ( y == 34 && x == 49 ) begin oled_data <= 16'hB5B6; end
        if ( y == 34 && x == 50 ) begin oled_data <= 16'hFFFF; end
        if ( y == 34 && x == 51 ) begin oled_data <= 16'h9CD3; end
        if ( y == 34 && x == 54 ) begin oled_data <= 16'h2104; end
        if ( y == 34 && x == 55 ) begin oled_data <= 16'hEF7D; end
        if ( y == 34 && x == 56 ) begin oled_data <= 16'hFFFF; end
        if ( y == 34 && x == 57 ) begin oled_data <= 16'h39E7; end
        if ( y == 34 && x == 59 ) begin oled_data <= 16'h4208; end
        if ( y == 34 && x == 60 ) begin oled_data <= 16'hDEDB; end
        if ( y == 34 && x >= 61 && x <= 62 ) begin oled_data <= 16'hFFFF; end
        if ( y == 34 && x == 63 ) begin oled_data <= 16'hDEDB; end
        if ( y == 34 && x == 64 ) begin oled_data <= 16'h4A49; end
        if ( y == 34 && x == 66 ) begin oled_data <= 16'h2965; end
        if ( y == 34 && x == 67 ) begin oled_data <= 16'hFFDF; end
        if ( y == 34 && x == 68 ) begin oled_data <= 16'hF7BE; end
        if ( y == 34 && x == 69 ) begin oled_data <= 16'h2945; end
        if ( y == 34 && x == 75 ) begin oled_data <= 16'h8C51; end
        if ( y == 34 && x == 76 ) begin oled_data <= 16'hFFFF; end
        if ( y == 34 && x == 77 ) begin oled_data <= 16'hCE59; end
        if ( y == 34 && x == 78 ) begin oled_data <= 16'h8C71; end
        if ( y == 34 && x == 79 ) begin oled_data <= 16'hFFFF; end
        if ( y == 34 && x == 80 ) begin oled_data <= 16'hF7BE; end
        if ( y == 34 && x == 81 ) begin oled_data <= 16'hB5B6; end
        if ( y == 34 && x == 82 ) begin oled_data <= 16'h2124; end
        if ( y == 35 && x == 12 ) begin oled_data <= 16'h8C71; end
        if ( y == 35 && x == 13 ) begin oled_data <= 16'hFFFF; end
        if ( y == 35 && x == 14 ) begin oled_data <= 16'hBDD7; end
        if ( y == 35 && x == 15 ) begin oled_data <= 16'hAD55; end
        if ( y == 35 && x == 16 ) begin oled_data <= 16'hE73C; end
        if ( y == 35 && x == 17 ) begin oled_data <= 16'hFFFF; end
        if ( y == 35 && x == 18 ) begin oled_data <= 16'h738E; end
        if ( y == 35 && x == 19 ) begin oled_data <= 16'h9492; end
        if ( y == 35 && x == 20 ) begin oled_data <= 16'hFFFF; end
        if ( y == 35 && x == 21 ) begin oled_data <= 16'hA534; end
        if ( y == 35 && x == 24 ) begin oled_data <= 16'h2104; end
        if ( y == 35 && x == 25 ) begin oled_data <= 16'hF7BE; end
        if ( y == 35 && x == 26 ) begin oled_data <= 16'hFFFF; end
        if ( y == 35 && x == 27 ) begin oled_data <= 16'h5AEB; end
        if ( y == 35 && x == 28 ) begin oled_data <= 16'hD6BA; end
        if ( y == 35 && x == 29 ) begin oled_data <= 16'hFFFF; end
        if ( y == 35 && x == 30 ) begin oled_data <= 16'h73AE; end
        if ( y == 35 && x == 33 ) begin oled_data <= 16'h52AA; end
        if ( y == 35 && x == 34 ) begin oled_data <= 16'hFFFF; end
        if ( y == 35 && x == 35 ) begin oled_data <= 16'hE73C; end
        if ( y == 35 && x == 36 ) begin oled_data <= 16'h5AEB; end
        if ( y == 35 && x >= 37 && x <= 38 ) begin oled_data <= 16'hFFFF; end
        if ( y == 35 && x == 39 ) begin oled_data <= 16'hBDF7; end
        if ( y == 35 && x == 40 ) begin oled_data <= 16'hAD75; end
        if ( y == 35 && x == 41 ) begin oled_data <= 16'hB596; end
        if ( y == 35 && x == 42 ) begin oled_data <= 16'hAD75; end
        if ( y == 35 && x == 43 ) begin oled_data <= 16'hB5B6; end
        if ( y == 35 && x == 44 ) begin oled_data <= 16'h8C51; end
        if ( y == 35 && x == 49 ) begin oled_data <= 16'h52AA; end
        if ( y == 35 && x == 50 ) begin oled_data <= 16'hCE79; end
        if ( y == 35 && x == 51 ) begin oled_data <= 16'hEF5D; end
        if ( y == 35 && x == 52 ) begin oled_data <= 16'hAD55; end
        if ( y == 35 && x == 53 ) begin oled_data <= 16'hAD75; end
        if ( y == 35 && x == 54 ) begin oled_data <= 16'hBDD7; end
        if ( y == 35 && x == 55 ) begin oled_data <= 16'hFFFF; end
        if ( y == 35 && x == 56 ) begin oled_data <= 16'h8430; end
        if ( y == 35 && x == 60 ) begin oled_data <= 16'h4A69; end
        if ( y == 35 && x == 61 ) begin oled_data <= 16'hD6BA; end
        if ( y == 35 && x == 62 ) begin oled_data <= 16'hDEDB; end
        if ( y == 35 && x == 63 ) begin oled_data <= 16'h528A; end
        if ( y == 35 && x == 66 ) begin oled_data <= 16'h3186; end
        if ( y == 35 && x >= 67 && x <= 68 ) begin oled_data <= 16'hFFFF; end
        if ( y == 35 && x == 69 ) begin oled_data <= 16'hBDF7; end
        if ( y == 35 && x == 70 ) begin oled_data <= 16'hAD75; end
        if ( y == 35 && x == 71 ) begin oled_data <= 16'hB596; end
        if ( y == 35 && x == 72 ) begin oled_data <= 16'hAD75; end
        if ( y == 35 && x == 73 ) begin oled_data <= 16'hBDD7; end
        if ( y == 35 && x == 74 ) begin oled_data <= 16'h738E; end
        if ( y == 35 && x == 75 ) begin oled_data <= 16'h8C51; end
        if ( y == 35 && x == 76 ) begin oled_data <= 16'hFFFF; end
        if ( y == 35 && x == 77 ) begin oled_data <= 16'hBDD7; end
        if ( y == 35 && x == 79 ) begin oled_data <= 16'h8C51; end
        if ( y == 35 && x == 80 ) begin oled_data <= 16'hFFDF; end
        if ( y == 35 && x == 81 ) begin oled_data <= 16'hFFFF; end
        if ( y == 35 && x == 82 ) begin oled_data <= 16'hD6BA; end
        if ( y == 35 && x == 83 ) begin oled_data <= 16'h39C7; end
        if ( y == 36 && x == 12 ) begin oled_data <= 16'h0861; end
        if ( y == 36 && x == 13 ) begin oled_data <= 16'h73AE; end
        if ( y == 36 && x >= 14 && x <= 15 ) begin oled_data <= 16'h8C71; end
        if ( y == 36 && x == 16 ) begin oled_data <= 16'h7BEF; end
        if ( y == 36 && x == 17 ) begin oled_data <= 16'h8430; end
        if ( y == 36 && x == 18 ) begin oled_data <= 16'h31A6; end
        if ( y == 36 && x == 19 ) begin oled_data <= 16'h4228; end
        if ( y == 36 && x == 20 ) begin oled_data <= 16'h8C71; end
        if ( y == 36 && x == 21 ) begin oled_data <= 16'h528A; end
        if ( y == 36 && x == 25 ) begin oled_data <= 16'h73AE; end
        if ( y == 36 && x == 26 ) begin oled_data <= 16'h8410; end
        if ( y == 36 && x == 27 ) begin oled_data <= 16'h2945; end
        if ( y == 36 && x == 28 ) begin oled_data <= 16'h6B4D; end
        if ( y == 36 && x == 29 ) begin oled_data <= 16'h8C51; end
        if ( y == 36 && x == 30 ) begin oled_data <= 16'h39C7; end
        if ( y == 36 && x == 33 ) begin oled_data <= 16'h2124; end
        if ( y == 36 && x == 34 ) begin oled_data <= 16'h8430; end
        if ( y == 36 && x == 35 ) begin oled_data <= 16'h6B6D; end
        if ( y == 36 && x == 36 ) begin oled_data <= 16'h2965; end
        if ( y == 36 && x >= 37 && x <= 38 ) begin oled_data <= 16'h7BEF; end
        if ( y == 36 && x == 39 ) begin oled_data <= 16'h8C51; end
        if ( y == 36 && x >= 40 && x <= 42 ) begin oled_data <= 16'h8C71; end
        if ( y == 36 && x == 43 ) begin oled_data <= 16'h9492; end
        if ( y == 36 && x == 44 ) begin oled_data <= 16'h738E; end
        if ( y == 36 && x == 50 ) begin oled_data <= 16'h31A6; end
        if ( y == 36 && x >= 51 && x <= 52 ) begin oled_data <= 16'h8C51; end
        if ( y == 36 && x == 53 ) begin oled_data <= 16'h8C71; end
        if ( y == 36 && x == 54 ) begin oled_data <= 16'h8C51; end
        if ( y == 36 && x == 55 ) begin oled_data <= 16'h7BCF; end
        if ( y == 36 && x == 61 ) begin oled_data <= 16'h4A49; end
        if ( y == 36 && x == 62 ) begin oled_data <= 16'h4A69; end
        if ( y == 36 && x >= 67 && x <= 68 ) begin oled_data <= 16'h7BEF; end
        if ( y == 36 && x == 69 ) begin oled_data <= 16'h8C51; end
        if ( y == 36 && x >= 70 && x <= 71 ) begin oled_data <= 16'h8C71; end
        if ( y == 36 && x == 72 ) begin oled_data <= 16'h8C51; end
        if ( y == 36 && x == 73 ) begin oled_data <= 16'h94B2; end
        if ( y == 36 && x == 74 ) begin oled_data <= 16'h630C; end
        if ( y == 36 && x == 75 ) begin oled_data <= 16'h39E7; end
        if ( y == 36 && x == 76 ) begin oled_data <= 16'h8C71; end
        if ( y == 36 && x == 77 ) begin oled_data <= 16'h5AEB; end
        if ( y == 36 && x == 79 ) begin oled_data <= 16'h0861; end
        if ( y == 36 && x == 80 ) begin oled_data <= 16'h73AE; end
        if ( y == 36 && x == 81 ) begin oled_data <= 16'h7BCF; end
        if ( y == 36 && x == 82 ) begin oled_data <= 16'h8C71; end
        if ( y == 36 && x == 83 ) begin oled_data <= 16'h31A6; end
        gameover_counter <= 24'd12500000;
        end
        end
        
    end
    
    //Mario
    else if(sw[11] == 1 && sw[12] == 0 && sw[10] == 1) 
    begin
        if (pixel_index / 96 > 61)
            oled_data <= 16'hE303;
        else 
            oled_data <= 16'h553F;     
        case (frame_count)
            0: begin
                //draw clothes
                if (((pixel_index % 96 > 33 && pixel_index % 96 < 44) &&(pixel_index / 96 > 29 && pixel_index / 96 < 32)) || 
                    ((pixel_index % 96 > 31 && pixel_index % 96 < 50) &&(pixel_index / 96 > 31 && pixel_index / 96 < 34)) ||
                    ((pixel_index % 96 > 35 && pixel_index % 96 < 38) &&(pixel_index / 96 > 43 && pixel_index / 96 < 48)) ||
                    ((pixel_index % 96 > 41 && pixel_index % 96 < 44) &&(pixel_index / 96 > 45 && pixel_index / 96 < 48)) ||
                    ((pixel_index % 96 > 35 && pixel_index % 96 < 44) &&(pixel_index / 96 > 47 && pixel_index / 96 < 50)) ||
                    ((pixel_index % 96 > 33 && pixel_index % 96 < 36) &&(pixel_index / 96 > 49 && pixel_index / 96 < 52)) ||
                    ((pixel_index % 96 > 37 && pixel_index % 96 < 42) &&(pixel_index / 96 > 49 && pixel_index / 96 < 52)) ||
                    ((pixel_index % 96 > 43 && pixel_index % 96 < 46) &&(pixel_index / 96 > 49 && pixel_index / 96 < 52)) ||
                    ((pixel_index % 96 > 33 && pixel_index % 96 < 46) &&(pixel_index / 96 > 51 && pixel_index / 96 < 54)) ||
                    ((pixel_index % 96 > 31 && pixel_index % 96 < 48) &&(pixel_index / 96 > 53 && pixel_index / 96 < 56)) ||
                    ((pixel_index % 96 > 31 && pixel_index % 96 < 38) &&(pixel_index / 96 > 55 && pixel_index / 96 < 58)) ||
                    ((pixel_index % 96 > 41 && pixel_index % 96 < 48) &&(pixel_index / 96 > 55 && pixel_index / 96 < 58)))
                    oled_data <= sw[4] == 1 ? 16'h1DE2 : sw[5] == 1 ? 16'hD139 : 16'hE8A0;
                //draw hair, body and legs    
                else if (((pixel_index % 96 > 31 && pixel_index % 96 < 38) &&(pixel_index / 96 > 33 && pixel_index / 96 < 36)) ||
                         ((pixel_index % 96 > 41 && pixel_index % 96 < 44) &&(pixel_index / 96 > 33 && pixel_index / 96 < 38)) ||
                         ((pixel_index % 96 > 29 && pixel_index % 96 < 32) &&(pixel_index / 96 > 35 && pixel_index / 96 < 42)) ||
                        ((pixel_index % 96 > 33 && pixel_index % 96 < 36) &&(pixel_index / 96 > 35 && pixel_index / 96 < 40)) ||
                        ((pixel_index % 96 > 35 && pixel_index % 96 < 38) &&(pixel_index / 96 > 37 && pixel_index / 96 < 40)) ||
                        ((pixel_index % 96 > 31 && pixel_index % 96 < 34) &&(pixel_index / 96 > 39 && pixel_index / 96 < 42)) ||
                        ((pixel_index % 96 > 43 && pixel_index % 96 < 46) &&(pixel_index / 96 > 37 && pixel_index / 96 < 40)) ||
                        ((pixel_index % 96 > 41 && pixel_index % 96 < 50) &&(pixel_index / 96 > 39 && pixel_index / 96 < 42)) ||
                        ((pixel_index % 96 > 31 && pixel_index % 96 < 36) &&(pixel_index / 96 > 43 && pixel_index / 96 < 50)) ||
                        ((pixel_index % 96 > 29 && pixel_index % 96 < 32) &&(pixel_index / 96 > 45 && pixel_index / 96 < 50)) ||
                        ((pixel_index % 96 > 27 && pixel_index % 96 < 30) &&(pixel_index / 96 > 47 && pixel_index / 96 < 50)) ||
                        ((pixel_index % 96 > 31 && pixel_index % 96 < 34) &&(pixel_index / 96 > 49 && pixel_index / 96 < 52)) ||
                        ((pixel_index % 96 > 37 && pixel_index % 96 < 42) &&(pixel_index / 96 > 43 && pixel_index / 96 < 48)) ||
                        ((pixel_index % 96 > 41 && pixel_index % 96 < 44) &&(pixel_index / 96 > 43 && pixel_index / 96 < 46)) ||
                        ((pixel_index % 96 > 43 && pixel_index % 96 < 50) &&(pixel_index / 96 > 45 && pixel_index / 96 < 50)) ||
                        ((pixel_index % 96 > 49 && pixel_index % 96 < 52) &&(pixel_index / 96 > 47 && pixel_index / 96 < 50)) ||
                        ((pixel_index % 96 > 45 && pixel_index % 96 < 48) &&(pixel_index / 96 > 49 && pixel_index / 96 < 52)) ||
                        ((pixel_index % 96 > 29 && pixel_index % 96 < 36) &&(pixel_index / 96 > 57 && pixel_index / 96 < 62)) || 
                        ((pixel_index % 96 > 27 && pixel_index % 96 < 30) &&(pixel_index / 96 > 59 && pixel_index / 96 < 62)) ||
                        ((pixel_index % 96 > 43 && pixel_index % 96 < 50) &&(pixel_index / 96 > 57 && pixel_index / 96 < 62)) ||
                        ((pixel_index % 96 > 49 && pixel_index % 96 < 52) &&(pixel_index / 96 > 59 && pixel_index / 96 < 62)))
                        oled_data <= 16'h7320;
                //draw face and arms
                else if (((pixel_index % 96 > 31 && pixel_index % 96 < 34) &&(pixel_index / 96 > 35 && pixel_index / 96 < 40)) ||
                        ((pixel_index % 96 > 35 && pixel_index % 96 < 38) &&(pixel_index / 96 > 35 && pixel_index / 96 < 38)) ||
                        ((pixel_index % 96 > 37 && pixel_index % 96 < 42) &&(pixel_index / 96 > 33 && pixel_index / 96 < 40)) ||
                        ((pixel_index % 96 > 41 && pixel_index % 96 < 44) &&(pixel_index / 96 > 37 && pixel_index / 96 < 40)) ||
                        ((pixel_index % 96 > 43 && pixel_index % 96 < 46) &&(pixel_index / 96 > 33 && pixel_index / 96 < 38)) ||
                        ((pixel_index % 96 > 45 && pixel_index % 96 < 50) &&(pixel_index / 96 > 35 && pixel_index / 96 < 40)) ||
                        ((pixel_index % 96 > 49 && pixel_index % 96 < 52) &&(pixel_index / 96 > 37 && pixel_index / 96 < 40)) ||
                        ((pixel_index % 96 > 33 && pixel_index % 96 < 42) &&(pixel_index / 96 > 39 && pixel_index / 96 < 44)) ||
                        ((pixel_index % 96 > 41 && pixel_index % 96 < 48) &&(pixel_index / 96 > 41 && pixel_index / 96 < 44)) ||
                        ((pixel_index % 96 > 27 && pixel_index % 96 < 32) &&(pixel_index / 96 > 49 && pixel_index / 96 < 56)) ||
                        ((pixel_index % 96 > 31 && pixel_index % 96 < 34) &&(pixel_index / 96 > 51 && pixel_index / 96 < 54)) ||
                        ((pixel_index % 96 > 35 && pixel_index % 96 < 38) &&(pixel_index / 96 > 49 && pixel_index / 96 < 52)) ||
                        ((pixel_index % 96 > 41 && pixel_index % 96 < 44) &&(pixel_index / 96 > 49 && pixel_index / 96 < 52)) ||
                        ((pixel_index % 96 > 45 && pixel_index % 96 < 48) &&(pixel_index / 96 > 51 && pixel_index / 96 < 54)) ||
                        ((pixel_index % 96 > 47 && pixel_index % 96 < 52) &&(pixel_index / 96 > 49 && pixel_index / 96 < 56)))
                        oled_data <= 16'hFD40;        
            end
            1: begin
            //draw clothes
            if (((pixel_index % 96 > 35 && pixel_index % 96 < 46) &&(pixel_index / 96 > 27 && pixel_index / 96 < 30)) || 
                ((pixel_index % 96 > 33 && pixel_index % 96 < 52) &&(pixel_index / 96 > 29 && pixel_index / 96 < 32)) ||
                ((pixel_index % 96 > 37 && pixel_index % 96 < 40) &&(pixel_index / 96 > 41 && pixel_index / 96 < 44)) ||
                ((pixel_index % 96 > 45 && pixel_index % 96 < 48) &&(pixel_index / 96 > 41 && pixel_index / 96 < 44)) ||
                ((pixel_index % 96 > 39 && pixel_index % 96 < 42) &&(pixel_index / 96 > 43 && pixel_index / 96 < 46)) ||
                ((pixel_index % 96 > 47 && pixel_index % 96 < 50) &&(pixel_index / 96 > 43 && pixel_index / 96 < 46)) ||
                ((pixel_index % 96 > 39 && pixel_index % 96 < 50) &&(pixel_index / 96 > 45 && pixel_index / 96 < 48)) ||
                ((pixel_index % 96 > 31 && pixel_index % 96 < 36) &&(pixel_index / 96 > 47 && pixel_index / 96 < 50)) ||
                ((pixel_index % 96 > 37 && pixel_index % 96 < 42) &&(pixel_index / 96 > 47 && pixel_index / 96 < 50)) ||
                ((pixel_index % 96 > 43 && pixel_index % 96 < 48) &&(pixel_index / 96 > 47 && pixel_index / 96 < 50)) ||
                ((pixel_index % 96 > 49 && pixel_index % 96 < 52) &&(pixel_index / 96 > 47 && pixel_index / 96 < 50)) ||
                ((pixel_index % 96 > 31 && pixel_index % 96 < 52) &&(pixel_index / 96 > 49 && pixel_index / 96 < 52)) ||
                ((pixel_index % 96 > 33 && pixel_index % 96 < 52) &&(pixel_index / 96 > 51 && pixel_index / 96 < 54)) ||
                ((pixel_index % 96 > 31 && pixel_index % 96 < 46) &&(pixel_index / 96 > 53 && pixel_index / 96 < 56)) ||
                ((pixel_index % 96 > 31 && pixel_index % 96 < 40) &&(pixel_index / 96 > 55 && pixel_index / 96 < 58)))
                oled_data <= sw[4] == 1 ? 16'h1DE2 : sw[5] == 1 ? 16'hD139 : 16'hE8A0;
            //draw hair, body and legs    
            else if (((pixel_index % 96 > 33 && pixel_index % 96 < 40) &&(pixel_index / 96 > 31 && pixel_index / 96 < 34)) ||
                    ((pixel_index % 96 > 43 && pixel_index % 96 < 46) &&(pixel_index / 96 > 31 && pixel_index / 96 < 36)) ||
                    ((pixel_index % 96 > 49 && pixel_index % 96 < 56) &&(pixel_index / 96 > 31 && pixel_index / 96 < 36)) ||
                    ((pixel_index % 96 > 53 && pixel_index % 96 < 56) &&(pixel_index / 96 > 35 && pixel_index / 96 < 38)) ||
                    ((pixel_index % 96 > 31 && pixel_index % 96 < 34) &&(pixel_index / 96 > 33 && pixel_index / 96 < 40)) ||
                    ((pixel_index % 96 > 33 && pixel_index % 96 < 36) &&(pixel_index / 96 > 37 && pixel_index / 96 < 40)) ||
                    ((pixel_index % 96 > 35 && pixel_index % 96 < 38) &&(pixel_index / 96 > 33 && pixel_index / 96 < 38)) ||
                    ((pixel_index % 96 > 37 && pixel_index % 96 < 40) &&(pixel_index / 96 > 35 && pixel_index / 96 < 38)) ||
                    ((pixel_index % 96 > 43 && pixel_index % 96 < 54) &&(pixel_index / 96 > 37 && pixel_index / 96 < 40)) ||
                    ((pixel_index % 96 > 45 && pixel_index % 96 < 48) &&(pixel_index / 96 > 35 && pixel_index / 96 < 38)) ||
                    ((pixel_index % 96 > 49 && pixel_index % 96 < 52) &&(pixel_index / 96 > 39 && pixel_index / 96 < 42)) ||
                    ((pixel_index % 96 > 25 && pixel_index % 96 < 28) &&(pixel_index / 96 > 43 && pixel_index / 96 < 46)) ||
                    ((pixel_index % 96 > 27 && pixel_index % 96 < 38) &&(pixel_index / 96 > 41 && pixel_index / 96 < 48)) ||
                    ((pixel_index % 96 > 37 && pixel_index % 96 < 40) &&(pixel_index / 96 > 43 && pixel_index / 96 < 48)) ||
                    ((pixel_index % 96 > 35 && pixel_index % 96 < 38) &&(pixel_index / 96 > 47 && pixel_index / 96 < 50)) ||
                    ((pixel_index % 96 > 39 && pixel_index % 96 < 46) &&(pixel_index / 96 > 41 && pixel_index / 96 < 44)) ||
                    ((pixel_index % 96 > 41 && pixel_index % 96 < 48) &&(pixel_index / 96 > 43 && pixel_index / 96 < 46)) ||
                    ((pixel_index % 96 > 47 && pixel_index % 96 < 50) &&(pixel_index / 96 > 41 && pixel_index / 96 < 44)) || 
                    ((pixel_index % 96 > 53 && pixel_index % 96 < 56) &&(pixel_index / 96 > 43 && pixel_index / 96 < 54)) ||
                    ((pixel_index % 96 > 51 && pixel_index % 96 < 54) &&(pixel_index / 96 > 47 && pixel_index / 96 < 54)) ||
                    ((pixel_index % 96 > 25 && pixel_index % 96 < 28) &&(pixel_index / 96 > 53 && pixel_index / 96 < 58)) ||
                    ((pixel_index % 96 > 27 && pixel_index % 96 < 32) &&(pixel_index / 96 > 51 && pixel_index / 96 < 56)) ||
                    ((pixel_index % 96 > 29 && pixel_index % 96 < 32) &&(pixel_index / 96 > 49 && pixel_index / 96 < 52)) ||
                    ((pixel_index % 96 > 31 && pixel_index % 96 < 34) &&(pixel_index / 96 > 51 && pixel_index / 96 < 54)))
                    oled_data <= 16'h7320;
            //draw face and arms
            else if (((pixel_index % 96 > 49 && pixel_index % 96 < 56) &&(pixel_index / 96 > 25 && pixel_index / 96 < 30)) ||
                    ((pixel_index % 96 > 51 && pixel_index % 96 < 56) &&(pixel_index / 96 > 29 && pixel_index / 96 < 32)) ||
                    ((pixel_index % 96 > 33 && pixel_index % 96 < 36) &&(pixel_index / 96 > 33 && pixel_index / 96 < 38)) ||
                    ((pixel_index % 96 > 37 && pixel_index % 96 < 40) &&(pixel_index / 96 > 33 && pixel_index / 96 < 36)) ||
                    ((pixel_index % 96 > 39 && pixel_index % 96 < 44) &&(pixel_index / 96 > 31 && pixel_index / 96 < 38)) ||
                    ((pixel_index % 96 > 43 && pixel_index % 96 < 46) &&(pixel_index / 96 > 35 && pixel_index / 96 < 38)) ||
                    ((pixel_index % 96 > 45 && pixel_index % 96 < 48) &&(pixel_index / 96 > 31 && pixel_index / 96 < 36)) ||
                    ((pixel_index % 96 > 47 && pixel_index % 96 < 50) &&(pixel_index / 96 > 33 && pixel_index / 96 < 38)) ||
                    ((pixel_index % 96 > 49 && pixel_index % 96 < 54) &&(pixel_index / 96 > 35 && pixel_index / 96 < 38)) ||
                    ((pixel_index % 96 > 35 && pixel_index % 96 < 44) &&(pixel_index / 96 > 37 && pixel_index / 96 < 40)) ||
                    ((pixel_index % 96 > 35 && pixel_index % 96 < 50) &&(pixel_index / 96 > 39 && pixel_index / 96 < 42)) ||
                    ((pixel_index % 96 > 23 && pixel_index % 96 < 28) &&(pixel_index / 96 > 45 && pixel_index / 96 < 50)) ||
                    ((pixel_index % 96 > 25 && pixel_index % 96 < 28) &&(pixel_index / 96 > 49 && pixel_index / 96 < 52)) ||
                    ((pixel_index % 96 > 27 && pixel_index % 96 < 30) &&(pixel_index / 96 > 47 && pixel_index / 96 < 50)) ||
                    ((pixel_index % 96 > 41 && pixel_index % 96 < 44) &&(pixel_index / 96 > 47 && pixel_index / 96 < 50)) ||
                    ((pixel_index % 96 > 47 && pixel_index % 96 < 50) &&(pixel_index / 96 > 47 && pixel_index / 96 < 50)))
                    oled_data <= 16'hFD40;        
            end
            2 : begin
            //draw clothes
                if (((pixel_index % 96 > 35 && pixel_index % 96 < 46) &&(pixel_index / 96 > 19 && pixel_index / 96 < 22)) || 
                    ((pixel_index % 96 > 33 && pixel_index % 96 < 52) &&(pixel_index / 96 > 21 && pixel_index / 96 < 24)) ||
                    ((pixel_index % 96 > 37 && pixel_index % 96 < 40) &&(pixel_index / 96 > 33 && pixel_index / 96 < 36)) ||
                    ((pixel_index % 96 > 45 && pixel_index % 96 < 48) &&(pixel_index / 96 > 33 && pixel_index / 96 < 36)) ||
                    ((pixel_index % 96 > 39 && pixel_index % 96 < 42) &&(pixel_index / 96 > 35 && pixel_index / 96 < 38)) ||
                    ((pixel_index % 96 > 47 && pixel_index % 96 < 50) &&(pixel_index / 96 > 35 && pixel_index / 96 < 38)) ||
                    ((pixel_index % 96 > 39 && pixel_index % 96 < 50) &&(pixel_index / 96 > 37 && pixel_index / 96 < 40)) ||
                    ((pixel_index % 96 > 31 && pixel_index % 96 < 36) &&(pixel_index / 96 > 39 && pixel_index / 96 < 42)) ||
                    ((pixel_index % 96 > 37 && pixel_index % 96 < 42) &&(pixel_index / 96 > 39 && pixel_index / 96 < 42)) ||
                    ((pixel_index % 96 > 43 && pixel_index % 96 < 48) &&(pixel_index / 96 > 39 && pixel_index / 96 < 42)) ||
                    ((pixel_index % 96 > 49 && pixel_index % 96 < 52) &&(pixel_index / 96 > 39 && pixel_index / 96 < 42)) ||
                    ((pixel_index % 96 > 31 && pixel_index % 96 < 52) &&(pixel_index / 96 > 41 && pixel_index / 96 < 44)) ||
                    ((pixel_index % 96 > 33 && pixel_index % 96 < 52) &&(pixel_index / 96 > 43 && pixel_index / 96 < 46)) ||
                    ((pixel_index % 96 > 31 && pixel_index % 96 < 46) &&(pixel_index / 96 > 45 && pixel_index / 96 < 48)) ||
                    ((pixel_index % 96 > 31 && pixel_index % 96 < 40) &&(pixel_index / 96 > 47 && pixel_index / 96 < 50)))
                    oled_data <= sw[4] == 1 ? 16'h1DE2 : sw[5] == 1 ? 16'hD139 : 16'hE8A0;
            //draw hair, body and legs    
                else if (((pixel_index % 96 > 33 && pixel_index % 96 < 40) &&(pixel_index / 96 > 23 && pixel_index / 96 < 26)) ||
                        ((pixel_index % 96 > 43 && pixel_index % 96 < 46) &&(pixel_index / 96 > 23 && pixel_index / 96 < 28)) ||
                        ((pixel_index % 96 > 49 && pixel_index % 96 < 56) &&(pixel_index / 96 > 23 && pixel_index / 96 < 28)) ||
                        ((pixel_index % 96 > 53 && pixel_index % 96 < 56) &&(pixel_index / 96 > 27 && pixel_index / 96 < 30)) ||
                        ((pixel_index % 96 > 31 && pixel_index % 96 < 34) &&(pixel_index / 96 > 25 && pixel_index / 96 < 32)) ||
                        ((pixel_index % 96 > 33 && pixel_index % 96 < 36) &&(pixel_index / 96 > 29 && pixel_index / 96 < 32)) ||
                        ((pixel_index % 96 > 35 && pixel_index % 96 < 38) &&(pixel_index / 96 > 25 && pixel_index / 96 < 30)) ||
                        ((pixel_index % 96 > 37 && pixel_index % 96 < 40) &&(pixel_index / 96 > 27 && pixel_index / 96 < 30)) ||
                        ((pixel_index % 96 > 43 && pixel_index % 96 < 54) &&(pixel_index / 96 > 29 && pixel_index / 96 < 32)) ||
                        ((pixel_index % 96 > 45 && pixel_index % 96 < 48) &&(pixel_index / 96 > 27 && pixel_index / 96 < 30)) ||
                        ((pixel_index % 96 > 49 && pixel_index % 96 < 52) &&(pixel_index / 96 > 31 && pixel_index / 96 < 34)) ||
                        ((pixel_index % 96 > 25 && pixel_index % 96 < 28) &&(pixel_index / 96 > 35 && pixel_index / 96 < 38)) ||
                        ((pixel_index % 96 > 27 && pixel_index % 96 < 38) &&(pixel_index / 96 > 33 && pixel_index / 96 < 40)) ||
                        ((pixel_index % 96 > 37 && pixel_index % 96 < 40) &&(pixel_index / 96 > 35 && pixel_index / 96 < 40)) ||
                        ((pixel_index % 96 > 35 && pixel_index % 96 < 38) &&(pixel_index / 96 > 39 && pixel_index / 96 < 42)) ||
                        ((pixel_index % 96 > 39 && pixel_index % 96 < 46) &&(pixel_index / 96 > 33 && pixel_index / 96 < 36)) ||
                        ((pixel_index % 96 > 41 && pixel_index % 96 < 48) &&(pixel_index / 96 > 35 && pixel_index / 96 < 38)) ||
                        ((pixel_index % 96 > 47 && pixel_index % 96 < 50) &&(pixel_index / 96 > 33 && pixel_index / 96 < 36)) || 
                        ((pixel_index % 96 > 53 && pixel_index % 96 < 56) &&(pixel_index / 96 > 35 && pixel_index / 96 < 46)) ||
                        ((pixel_index % 96 > 51 && pixel_index % 96 < 54) &&(pixel_index / 96 > 39 && pixel_index / 96 < 46)) ||
                        ((pixel_index % 96 > 25 && pixel_index % 96 < 28) &&(pixel_index / 96 > 45 && pixel_index / 96 < 50)) ||
                        ((pixel_index % 96 > 27 && pixel_index % 96 < 32) &&(pixel_index / 96 > 43 && pixel_index / 96 < 48)) ||
                        ((pixel_index % 96 > 29 && pixel_index % 96 < 32) &&(pixel_index / 96 > 41 && pixel_index / 96 < 44)) ||
                        ((pixel_index % 96 > 31 && pixel_index % 96 < 34) &&(pixel_index / 96 > 43 && pixel_index / 96 < 46)))
                        oled_data <= 16'h7320;
            //draw face and arms
                else if (((pixel_index % 96 > 49 && pixel_index % 96 < 56) &&(pixel_index / 96 > 17 && pixel_index / 96 < 22)) ||
                        ((pixel_index % 96 > 51 && pixel_index % 96 < 56) &&(pixel_index / 96 > 21 && pixel_index / 96 < 24)) ||
                        ((pixel_index % 96 > 33 && pixel_index % 96 < 36) &&(pixel_index / 96 > 25 && pixel_index / 96 < 30)) ||
                        ((pixel_index % 96 > 37 && pixel_index % 96 < 40) &&(pixel_index / 96 > 25 && pixel_index / 96 < 28)) ||
                        ((pixel_index % 96 > 39 && pixel_index % 96 < 44) &&(pixel_index / 96 > 23 && pixel_index / 96 < 30)) ||
                        ((pixel_index % 96 > 43 && pixel_index % 96 < 46) &&(pixel_index / 96 > 27 && pixel_index / 96 < 30)) ||
                        ((pixel_index % 96 > 45 && pixel_index % 96 < 48) &&(pixel_index / 96 > 23 && pixel_index / 96 < 28)) ||
                        ((pixel_index % 96 > 47 && pixel_index % 96 < 50) &&(pixel_index / 96 > 25 && pixel_index / 96 < 30)) ||
                        ((pixel_index % 96 > 49 && pixel_index % 96 < 54) &&(pixel_index / 96 > 27 && pixel_index / 96 < 30)) ||
                        ((pixel_index % 96 > 35 && pixel_index % 96 < 44) &&(pixel_index / 96 > 29 && pixel_index / 96 < 32)) ||
                        ((pixel_index % 96 > 35 && pixel_index % 96 < 50) &&(pixel_index / 96 > 31 && pixel_index / 96 < 34)) ||
                        ((pixel_index % 96 > 23 && pixel_index % 96 < 28) &&(pixel_index / 96 > 37 && pixel_index / 96 < 42)) ||
                        ((pixel_index % 96 > 25 && pixel_index % 96 < 28) &&(pixel_index / 96 > 41 && pixel_index / 96 < 44)) ||
                        ((pixel_index % 96 > 27 && pixel_index % 96 < 30) &&(pixel_index / 96 > 39 && pixel_index / 96 < 42)) ||
                        ((pixel_index % 96 > 41 && pixel_index % 96 < 44) &&(pixel_index / 96 > 39 && pixel_index / 96 < 42)) ||
                        ((pixel_index % 96 > 47 && pixel_index % 96 < 50) &&(pixel_index / 96 > 39 && pixel_index / 96 < 42)))
                        oled_data <= 16'hFD40;        
            end
            3 : begin
            //draw clothes
                if (((pixel_index % 96 > 35 && pixel_index % 96 < 46) &&(pixel_index / 96 > 11 && pixel_index / 96 < 14)) || 
                    ((pixel_index % 96 > 33 && pixel_index % 96 < 52) &&(pixel_index / 96 > 13 && pixel_index / 96 < 16)) ||
                    ((pixel_index % 96 > 37 && pixel_index % 96 < 40) &&(pixel_index / 96 > 25 && pixel_index / 96 < 28)) ||
                    ((pixel_index % 96 > 45 && pixel_index % 96 < 48) &&(pixel_index / 96 > 25 && pixel_index / 96 < 28)) ||
                    ((pixel_index % 96 > 39 && pixel_index % 96 < 42) &&(pixel_index / 96 > 27 && pixel_index / 96 < 30)) ||
                    ((pixel_index % 96 > 47 && pixel_index % 96 < 50) &&(pixel_index / 96 > 27 && pixel_index / 96 < 30)) ||
                    ((pixel_index % 96 > 39 && pixel_index % 96 < 50) &&(pixel_index / 96 > 29 && pixel_index / 96 < 32)) ||
                    ((pixel_index % 96 > 31 && pixel_index % 96 < 36) &&(pixel_index / 96 > 31 && pixel_index / 96 < 34)) ||
                    ((pixel_index % 96 > 37 && pixel_index % 96 < 42) &&(pixel_index / 96 > 31 && pixel_index / 96 < 34)) ||
                    ((pixel_index % 96 > 43 && pixel_index % 96 < 48) &&(pixel_index / 96 > 31 && pixel_index / 96 < 34)) ||
                    ((pixel_index % 96 > 49 && pixel_index % 96 < 52) &&(pixel_index / 96 > 31 && pixel_index / 96 < 34)) ||
                    ((pixel_index % 96 > 31 && pixel_index % 96 < 52) &&(pixel_index / 96 > 33 && pixel_index / 96 < 36)) ||
                    ((pixel_index % 96 > 33 && pixel_index % 96 < 52) &&(pixel_index / 96 > 35 && pixel_index / 96 < 38)) ||
                    ((pixel_index % 96 > 31 && pixel_index % 96 < 46) &&(pixel_index / 96 > 37 && pixel_index / 96 < 40)) ||
                    ((pixel_index % 96 > 31 && pixel_index % 96 < 40) &&(pixel_index / 96 > 39 && pixel_index / 96 < 42)))
                    oled_data <= sw[4] == 1 ? 16'h1DE2 : sw[5] == 1 ? 16'hD139 : 16'hE8A0;
            //draw hair, body and legs    
                else if (((pixel_index % 96 > 33 && pixel_index % 96 < 40) &&(pixel_index / 96 > 15 && pixel_index / 96 < 18)) ||
                        ((pixel_index % 96 > 43 && pixel_index % 96 < 46) &&(pixel_index / 96 > 15 && pixel_index / 96 < 20)) ||
                        ((pixel_index % 96 > 49 && pixel_index % 96 < 56) &&(pixel_index / 96 > 15 && pixel_index / 96 < 20)) ||
                        ((pixel_index % 96 > 53 && pixel_index % 96 < 56) &&(pixel_index / 96 > 19 && pixel_index / 96 < 22)) ||
                        ((pixel_index % 96 > 31 && pixel_index % 96 < 34) &&(pixel_index / 96 > 17 && pixel_index / 96 < 24)) ||
                        ((pixel_index % 96 > 33 && pixel_index % 96 < 36) &&(pixel_index / 96 > 21 && pixel_index / 96 < 24)) ||
                        ((pixel_index % 96 > 35 && pixel_index % 96 < 38) &&(pixel_index / 96 > 17 && pixel_index / 96 < 22)) ||
                        ((pixel_index % 96 > 37 && pixel_index % 96 < 40) &&(pixel_index / 96 > 19 && pixel_index / 96 < 22)) ||
                        ((pixel_index % 96 > 43 && pixel_index % 96 < 54) &&(pixel_index / 96 > 21 && pixel_index / 96 < 24)) ||
                        ((pixel_index % 96 > 45 && pixel_index % 96 < 48) &&(pixel_index / 96 > 19 && pixel_index / 96 < 22)) ||
                        ((pixel_index % 96 > 49 && pixel_index % 96 < 52) &&(pixel_index / 96 > 23 && pixel_index / 96 < 26)) ||
                        ((pixel_index % 96 > 25 && pixel_index % 96 < 28) &&(pixel_index / 96 > 27 && pixel_index / 96 < 30)) ||
                        ((pixel_index % 96 > 27 && pixel_index % 96 < 38) &&(pixel_index / 96 > 25 && pixel_index / 96 < 32)) ||
                        ((pixel_index % 96 > 37 && pixel_index % 96 < 40) &&(pixel_index / 96 > 27 && pixel_index / 96 < 32)) ||
                        ((pixel_index % 96 > 35 && pixel_index % 96 < 38) &&(pixel_index / 96 > 31 && pixel_index / 96 < 34)) ||
                        ((pixel_index % 96 > 39 && pixel_index % 96 < 46) &&(pixel_index / 96 > 25 && pixel_index / 96 < 28)) ||
                        ((pixel_index % 96 > 41 && pixel_index % 96 < 48) &&(pixel_index / 96 > 27 && pixel_index / 96 < 30)) ||
                        ((pixel_index % 96 > 47 && pixel_index % 96 < 50) &&(pixel_index / 96 > 25 && pixel_index / 96 < 28)) || 
                        ((pixel_index % 96 > 53 && pixel_index % 96 < 56) &&(pixel_index / 96 > 27 && pixel_index / 96 < 38)) ||
                        ((pixel_index % 96 > 51 && pixel_index % 96 < 54) &&(pixel_index / 96 > 31 && pixel_index / 96 < 38)) ||
                        ((pixel_index % 96 > 25 && pixel_index % 96 < 28) &&(pixel_index / 96 > 37 && pixel_index / 96 < 42)) ||
                        ((pixel_index % 96 > 27 && pixel_index % 96 < 32) &&(pixel_index / 96 > 35 && pixel_index / 96 < 40)) ||
                        ((pixel_index % 96 > 29 && pixel_index % 96 < 32) &&(pixel_index / 96 > 33 && pixel_index / 96 < 36)) ||
                        ((pixel_index % 96 > 31 && pixel_index % 96 < 34) &&(pixel_index / 96 > 35 && pixel_index / 96 < 38)))
                        oled_data <= 16'h7320;
            //draw face and arms
                else if (((pixel_index % 96 > 49 && pixel_index % 96 < 56) &&(pixel_index / 96 > 9 && pixel_index / 96 < 14)) ||
                        ((pixel_index % 96 > 51 && pixel_index % 96 < 56) &&(pixel_index / 96 > 13 && pixel_index / 96 < 16)) ||
                        ((pixel_index % 96 > 33 && pixel_index % 96 < 36) &&(pixel_index / 96 > 17 && pixel_index / 96 < 22)) ||
                        ((pixel_index % 96 > 37 && pixel_index % 96 < 40) &&(pixel_index / 96 > 17 && pixel_index / 96 < 20)) ||
                        ((pixel_index % 96 > 39 && pixel_index % 96 < 44) &&(pixel_index / 96 > 15 && pixel_index / 96 < 22)) ||
                        ((pixel_index % 96 > 43 && pixel_index % 96 < 46) &&(pixel_index / 96 > 19 && pixel_index / 96 < 22)) ||
                        ((pixel_index % 96 > 45 && pixel_index % 96 < 48) &&(pixel_index / 96 > 15 && pixel_index / 96 < 20)) ||
                        ((pixel_index % 96 > 47 && pixel_index % 96 < 50) &&(pixel_index / 96 > 17 && pixel_index / 96 < 22)) ||
                        ((pixel_index % 96 > 49 && pixel_index % 96 < 54) &&(pixel_index / 96 > 19 && pixel_index / 96 < 22)) ||
                        ((pixel_index % 96 > 35 && pixel_index % 96 < 44) &&(pixel_index / 96 > 21 && pixel_index / 96 < 24)) ||
                        ((pixel_index % 96 > 35 && pixel_index % 96 < 50) &&(pixel_index / 96 > 23 && pixel_index / 96 < 26)) ||
                        ((pixel_index % 96 > 23 && pixel_index % 96 < 28) &&(pixel_index / 96 > 29 && pixel_index / 96 < 34)) ||
                        ((pixel_index % 96 > 25 && pixel_index % 96 < 28) &&(pixel_index / 96 > 33 && pixel_index / 96 < 36)) ||
                        ((pixel_index % 96 > 27 && pixel_index % 96 < 30) &&(pixel_index / 96 > 31 && pixel_index / 96 < 34)) ||
                        ((pixel_index % 96 > 41 && pixel_index % 96 < 44) &&(pixel_index / 96 > 31 && pixel_index / 96 < 34)) ||
                        ((pixel_index % 96 > 47 && pixel_index % 96 < 50) &&(pixel_index / 96 > 31 && pixel_index / 96 < 34)))
                        oled_data <= 16'hFD40;        
            
            end
            4 : begin
            //draw clothes
                if (((pixel_index % 96 > 35 && pixel_index % 96 < 46) &&(pixel_index / 96 > 19 && pixel_index / 96 < 22)) || 
                    ((pixel_index % 96 > 33 && pixel_index % 96 < 52) &&(pixel_index / 96 > 21 && pixel_index / 96 < 24)) ||
                    ((pixel_index % 96 > 37 && pixel_index % 96 < 40) &&(pixel_index / 96 > 33 && pixel_index / 96 < 36)) ||
                    ((pixel_index % 96 > 45 && pixel_index % 96 < 48) &&(pixel_index / 96 > 33 && pixel_index / 96 < 36)) ||
                    ((pixel_index % 96 > 39 && pixel_index % 96 < 42) &&(pixel_index / 96 > 35 && pixel_index / 96 < 38)) ||
                    ((pixel_index % 96 > 47 && pixel_index % 96 < 50) &&(pixel_index / 96 > 35 && pixel_index / 96 < 38)) ||
                    ((pixel_index % 96 > 39 && pixel_index % 96 < 50) &&(pixel_index / 96 > 37 && pixel_index / 96 < 40)) ||
                    ((pixel_index % 96 > 31 && pixel_index % 96 < 36) &&(pixel_index / 96 > 39 && pixel_index / 96 < 42)) ||
                    ((pixel_index % 96 > 37 && pixel_index % 96 < 42) &&(pixel_index / 96 > 39 && pixel_index / 96 < 42)) ||
                    ((pixel_index % 96 > 43 && pixel_index % 96 < 48) &&(pixel_index / 96 > 39 && pixel_index / 96 < 42)) ||
                    ((pixel_index % 96 > 49 && pixel_index % 96 < 52) &&(pixel_index / 96 > 39 && pixel_index / 96 < 42)) ||
                    ((pixel_index % 96 > 31 && pixel_index % 96 < 52) &&(pixel_index / 96 > 41 && pixel_index / 96 < 44)) ||
                    ((pixel_index % 96 > 33 && pixel_index % 96 < 52) &&(pixel_index / 96 > 43 && pixel_index / 96 < 46)) ||
                    ((pixel_index % 96 > 31 && pixel_index % 96 < 46) &&(pixel_index / 96 > 45 && pixel_index / 96 < 48)) ||
                    ((pixel_index % 96 > 31 && pixel_index % 96 < 40) &&(pixel_index / 96 > 47 && pixel_index / 96 < 50)))
                    oled_data <= sw[4] == 1 ? 16'h1DE2 : sw[5] == 1 ? 16'hD139 : 16'hE8A0;
            //draw hair, body and legs    
                else if (((pixel_index % 96 > 33 && pixel_index % 96 < 40) &&(pixel_index / 96 > 23 && pixel_index / 96 < 26)) ||
                        ((pixel_index % 96 > 43 && pixel_index % 96 < 46) &&(pixel_index / 96 > 23 && pixel_index / 96 < 28)) ||
                        ((pixel_index % 96 > 49 && pixel_index % 96 < 56) &&(pixel_index / 96 > 23 && pixel_index / 96 < 28)) ||
                        ((pixel_index % 96 > 53 && pixel_index % 96 < 56) &&(pixel_index / 96 > 27 && pixel_index / 96 < 30)) ||
                        ((pixel_index % 96 > 31 && pixel_index % 96 < 34) &&(pixel_index / 96 > 25 && pixel_index / 96 < 32)) ||
                        ((pixel_index % 96 > 33 && pixel_index % 96 < 36) &&(pixel_index / 96 > 29 && pixel_index / 96 < 32)) ||
                        ((pixel_index % 96 > 35 && pixel_index % 96 < 38) &&(pixel_index / 96 > 25 && pixel_index / 96 < 30)) ||
                        ((pixel_index % 96 > 37 && pixel_index % 96 < 40) &&(pixel_index / 96 > 27 && pixel_index / 96 < 30)) ||
                        ((pixel_index % 96 > 43 && pixel_index % 96 < 54) &&(pixel_index / 96 > 29 && pixel_index / 96 < 32)) ||
                        ((pixel_index % 96 > 45 && pixel_index % 96 < 48) &&(pixel_index / 96 > 27 && pixel_index / 96 < 30)) ||
                        ((pixel_index % 96 > 49 && pixel_index % 96 < 52) &&(pixel_index / 96 > 31 && pixel_index / 96 < 34)) ||
                        ((pixel_index % 96 > 25 && pixel_index % 96 < 28) &&(pixel_index / 96 > 35 && pixel_index / 96 < 38)) ||
                        ((pixel_index % 96 > 27 && pixel_index % 96 < 38) &&(pixel_index / 96 > 33 && pixel_index / 96 < 40)) ||
                        ((pixel_index % 96 > 37 && pixel_index % 96 < 40) &&(pixel_index / 96 > 35 && pixel_index / 96 < 40)) ||
                        ((pixel_index % 96 > 35 && pixel_index % 96 < 38) &&(pixel_index / 96 > 39 && pixel_index / 96 < 42)) ||
                        ((pixel_index % 96 > 39 && pixel_index % 96 < 46) &&(pixel_index / 96 > 33 && pixel_index / 96 < 36)) ||
                        ((pixel_index % 96 > 41 && pixel_index % 96 < 48) &&(pixel_index / 96 > 35 && pixel_index / 96 < 38)) ||
                        ((pixel_index % 96 > 47 && pixel_index % 96 < 50) &&(pixel_index / 96 > 33 && pixel_index / 96 < 36)) || 
                        ((pixel_index % 96 > 53 && pixel_index % 96 < 56) &&(pixel_index / 96 > 35 && pixel_index / 96 < 46)) ||
                        ((pixel_index % 96 > 51 && pixel_index % 96 < 54) &&(pixel_index / 96 > 39 && pixel_index / 96 < 46)) ||
                        ((pixel_index % 96 > 25 && pixel_index % 96 < 28) &&(pixel_index / 96 > 45 && pixel_index / 96 < 50)) ||
                        ((pixel_index % 96 > 27 && pixel_index % 96 < 32) &&(pixel_index / 96 > 43 && pixel_index / 96 < 48)) ||
                        ((pixel_index % 96 > 29 && pixel_index % 96 < 32) &&(pixel_index / 96 > 41 && pixel_index / 96 < 44)) ||
                        ((pixel_index % 96 > 31 && pixel_index % 96 < 34) &&(pixel_index / 96 > 43 && pixel_index / 96 < 46)))
                        oled_data <= 16'h7320;
            //draw face and arms
                else if (((pixel_index % 96 > 49 && pixel_index % 96 < 56) &&(pixel_index / 96 > 17 && pixel_index / 96 < 22)) ||
                        ((pixel_index % 96 > 51 && pixel_index % 96 < 56) &&(pixel_index / 96 > 21 && pixel_index / 96 < 24)) ||
                        ((pixel_index % 96 > 33 && pixel_index % 96 < 36) &&(pixel_index / 96 > 25 && pixel_index / 96 < 30)) ||
                        ((pixel_index % 96 > 37 && pixel_index % 96 < 40) &&(pixel_index / 96 > 25 && pixel_index / 96 < 28)) ||
                        ((pixel_index % 96 > 39 && pixel_index % 96 < 44) &&(pixel_index / 96 > 23 && pixel_index / 96 < 30)) ||
                        ((pixel_index % 96 > 43 && pixel_index % 96 < 46) &&(pixel_index / 96 > 27 && pixel_index / 96 < 30)) ||
                        ((pixel_index % 96 > 45 && pixel_index % 96 < 48) &&(pixel_index / 96 > 23 && pixel_index / 96 < 28)) ||
                        ((pixel_index % 96 > 47 && pixel_index % 96 < 50) &&(pixel_index / 96 > 25 && pixel_index / 96 < 30)) ||
                        ((pixel_index % 96 > 49 && pixel_index % 96 < 54) &&(pixel_index / 96 > 27 && pixel_index / 96 < 30)) ||
                        ((pixel_index % 96 > 35 && pixel_index % 96 < 44) &&(pixel_index / 96 > 29 && pixel_index / 96 < 32)) ||
                        ((pixel_index % 96 > 35 && pixel_index % 96 < 50) &&(pixel_index / 96 > 31 && pixel_index / 96 < 34)) ||
                        ((pixel_index % 96 > 23 && pixel_index % 96 < 28) &&(pixel_index / 96 > 37 && pixel_index / 96 < 42)) ||
                        ((pixel_index % 96 > 25 && pixel_index % 96 < 28) &&(pixel_index / 96 > 41 && pixel_index / 96 < 44)) ||
                        ((pixel_index % 96 > 27 && pixel_index % 96 < 30) &&(pixel_index / 96 > 39 && pixel_index / 96 < 42)) ||
                        ((pixel_index % 96 > 41 && pixel_index % 96 < 44) &&(pixel_index / 96 > 39 && pixel_index / 96 < 42)) ||
                        ((pixel_index % 96 > 47 && pixel_index % 96 < 50) &&(pixel_index / 96 > 39 && pixel_index / 96 < 42)))
                        oled_data <= 16'hFD40;        
            end
            5 : begin
            if (((pixel_index % 96 > 35 && pixel_index % 96 < 46) &&(pixel_index / 96 > 27 && pixel_index / 96 < 30)) || 
                ((pixel_index % 96 > 33 && pixel_index % 96 < 52) &&(pixel_index / 96 > 29 && pixel_index / 96 < 32)) ||
                ((pixel_index % 96 > 37 && pixel_index % 96 < 40) &&(pixel_index / 96 > 41 && pixel_index / 96 < 44)) ||
                ((pixel_index % 96 > 45 && pixel_index % 96 < 48) &&(pixel_index / 96 > 41 && pixel_index / 96 < 44)) ||
                ((pixel_index % 96 > 39 && pixel_index % 96 < 42) &&(pixel_index / 96 > 43 && pixel_index / 96 < 46)) ||
                ((pixel_index % 96 > 47 && pixel_index % 96 < 50) &&(pixel_index / 96 > 43 && pixel_index / 96 < 46)) ||
                ((pixel_index % 96 > 39 && pixel_index % 96 < 50) &&(pixel_index / 96 > 45 && pixel_index / 96 < 48)) ||
                ((pixel_index % 96 > 31 && pixel_index % 96 < 36) &&(pixel_index / 96 > 47 && pixel_index / 96 < 50)) ||
                ((pixel_index % 96 > 37 && pixel_index % 96 < 42) &&(pixel_index / 96 > 47 && pixel_index / 96 < 50)) ||
                ((pixel_index % 96 > 43 && pixel_index % 96 < 48) &&(pixel_index / 96 > 47 && pixel_index / 96 < 50)) ||
                ((pixel_index % 96 > 49 && pixel_index % 96 < 52) &&(pixel_index / 96 > 47 && pixel_index / 96 < 50)) ||
                ((pixel_index % 96 > 31 && pixel_index % 96 < 52) &&(pixel_index / 96 > 49 && pixel_index / 96 < 52)) ||
                ((pixel_index % 96 > 33 && pixel_index % 96 < 52) &&(pixel_index / 96 > 51 && pixel_index / 96 < 54)) ||
                ((pixel_index % 96 > 31 && pixel_index % 96 < 46) &&(pixel_index / 96 > 53 && pixel_index / 96 < 56)) ||
                ((pixel_index % 96 > 31 && pixel_index % 96 < 40) &&(pixel_index / 96 > 55 && pixel_index / 96 < 58)))
                oled_data <= sw[4] == 1 ? 16'h1DE2 : sw[5] == 1 ? 16'hD139 : 16'hE8A0;
            //draw hair, body and legs    
            else if (((pixel_index % 96 > 33 && pixel_index % 96 < 40) &&(pixel_index / 96 > 31 && pixel_index / 96 < 34)) ||
                    ((pixel_index % 96 > 43 && pixel_index % 96 < 46) &&(pixel_index / 96 > 31 && pixel_index / 96 < 36)) ||
                    ((pixel_index % 96 > 49 && pixel_index % 96 < 56) &&(pixel_index / 96 > 31 && pixel_index / 96 < 36)) ||
                    ((pixel_index % 96 > 53 && pixel_index % 96 < 56) &&(pixel_index / 96 > 35 && pixel_index / 96 < 38)) ||
                    ((pixel_index % 96 > 31 && pixel_index % 96 < 34) &&(pixel_index / 96 > 33 && pixel_index / 96 < 40)) ||
                    ((pixel_index % 96 > 33 && pixel_index % 96 < 36) &&(pixel_index / 96 > 37 && pixel_index / 96 < 40)) ||
                    ((pixel_index % 96 > 35 && pixel_index % 96 < 38) &&(pixel_index / 96 > 33 && pixel_index / 96 < 38)) ||
                    ((pixel_index % 96 > 37 && pixel_index % 96 < 40) &&(pixel_index / 96 > 35 && pixel_index / 96 < 38)) ||
                    ((pixel_index % 96 > 43 && pixel_index % 96 < 54) &&(pixel_index / 96 > 37 && pixel_index / 96 < 40)) ||
                    ((pixel_index % 96 > 45 && pixel_index % 96 < 48) &&(pixel_index / 96 > 35 && pixel_index / 96 < 38)) ||
                    ((pixel_index % 96 > 49 && pixel_index % 96 < 52) &&(pixel_index / 96 > 39 && pixel_index / 96 < 42)) ||
                    ((pixel_index % 96 > 25 && pixel_index % 96 < 28) &&(pixel_index / 96 > 43 && pixel_index / 96 < 46)) ||
                    ((pixel_index % 96 > 27 && pixel_index % 96 < 38) &&(pixel_index / 96 > 41 && pixel_index / 96 < 48)) ||
                    ((pixel_index % 96 > 37 && pixel_index % 96 < 40) &&(pixel_index / 96 > 43 && pixel_index / 96 < 48)) ||
                    ((pixel_index % 96 > 35 && pixel_index % 96 < 38) &&(pixel_index / 96 > 47 && pixel_index / 96 < 50)) ||
                    ((pixel_index % 96 > 39 && pixel_index % 96 < 46) &&(pixel_index / 96 > 41 && pixel_index / 96 < 44)) ||
                    ((pixel_index % 96 > 41 && pixel_index % 96 < 48) &&(pixel_index / 96 > 43 && pixel_index / 96 < 46)) ||
                    ((pixel_index % 96 > 47 && pixel_index % 96 < 50) &&(pixel_index / 96 > 41 && pixel_index / 96 < 44)) || 
                    ((pixel_index % 96 > 53 && pixel_index % 96 < 56) &&(pixel_index / 96 > 43 && pixel_index / 96 < 54)) ||
                    ((pixel_index % 96 > 51 && pixel_index % 96 < 54) &&(pixel_index / 96 > 47 && pixel_index / 96 < 54)) ||
                    ((pixel_index % 96 > 25 && pixel_index % 96 < 28) &&(pixel_index / 96 > 53 && pixel_index / 96 < 58)) ||
                    ((pixel_index % 96 > 27 && pixel_index % 96 < 32) &&(pixel_index / 96 > 51 && pixel_index / 96 < 56)) ||
                    ((pixel_index % 96 > 29 && pixel_index % 96 < 32) &&(pixel_index / 96 > 49 && pixel_index / 96 < 52)) ||
                    ((pixel_index % 96 > 31 && pixel_index % 96 < 34) &&(pixel_index / 96 > 51 && pixel_index / 96 < 54)))
                    oled_data <= 16'h7320;
            //draw face and arms
            else if (((pixel_index % 96 > 49 && pixel_index % 96 < 56) &&(pixel_index / 96 > 25 && pixel_index / 96 < 30)) ||
                    ((pixel_index % 96 > 51 && pixel_index % 96 < 56) &&(pixel_index / 96 > 29 && pixel_index / 96 < 32)) ||
                    ((pixel_index % 96 > 33 && pixel_index % 96 < 36) &&(pixel_index / 96 > 33 && pixel_index / 96 < 38)) ||
                    ((pixel_index % 96 > 37 && pixel_index % 96 < 40) &&(pixel_index / 96 > 33 && pixel_index / 96 < 36)) ||
                    ((pixel_index % 96 > 39 && pixel_index % 96 < 44) &&(pixel_index / 96 > 31 && pixel_index / 96 < 38)) ||
                    ((pixel_index % 96 > 43 && pixel_index % 96 < 46) &&(pixel_index / 96 > 35 && pixel_index / 96 < 38)) ||
                    ((pixel_index % 96 > 45 && pixel_index % 96 < 48) &&(pixel_index / 96 > 31 && pixel_index / 96 < 36)) ||
                    ((pixel_index % 96 > 47 && pixel_index % 96 < 50) &&(pixel_index / 96 > 33 && pixel_index / 96 < 38)) ||
                    ((pixel_index % 96 > 49 && pixel_index % 96 < 54) &&(pixel_index / 96 > 35 && pixel_index / 96 < 38)) ||
                    ((pixel_index % 96 > 35 && pixel_index % 96 < 44) &&(pixel_index / 96 > 37 && pixel_index / 96 < 40)) ||
                    ((pixel_index % 96 > 35 && pixel_index % 96 < 50) &&(pixel_index / 96 > 39 && pixel_index / 96 < 42)) ||
                    ((pixel_index % 96 > 23 && pixel_index % 96 < 28) &&(pixel_index / 96 > 45 && pixel_index / 96 < 50)) ||
                    ((pixel_index % 96 > 25 && pixel_index % 96 < 28) &&(pixel_index / 96 > 49 && pixel_index / 96 < 52)) ||
                    ((pixel_index % 96 > 27 && pixel_index % 96 < 30) &&(pixel_index / 96 > 47 && pixel_index / 96 < 50)) ||
                    ((pixel_index % 96 > 41 && pixel_index % 96 < 44) &&(pixel_index / 96 > 47 && pixel_index / 96 < 50)) ||
                    ((pixel_index % 96 > 47 && pixel_index % 96 < 50) &&(pixel_index / 96 > 47 && pixel_index / 96 < 50)))
                    oled_data <= 16'hFD40;        
            end
            6 : begin 
                //draw clothes
                if (((pixel_index % 96 > 33 && pixel_index % 96 < 44) &&(pixel_index / 96 > 29 && pixel_index / 96 < 32)) || 
                    ((pixel_index % 96 > 31 && pixel_index % 96 < 50) &&(pixel_index / 96 > 31 && pixel_index / 96 < 34)) ||
                    ((pixel_index % 96 > 35 && pixel_index % 96 < 38) &&(pixel_index / 96 > 43 && pixel_index / 96 < 48)) ||
                    ((pixel_index % 96 > 41 && pixel_index % 96 < 44) &&(pixel_index / 96 > 45 && pixel_index / 96 < 48)) ||
                    ((pixel_index % 96 > 35 && pixel_index % 96 < 44) &&(pixel_index / 96 > 47 && pixel_index / 96 < 50)) ||
                    ((pixel_index % 96 > 33 && pixel_index % 96 < 36) &&(pixel_index / 96 > 49 && pixel_index / 96 < 52)) ||
                    ((pixel_index % 96 > 37 && pixel_index % 96 < 42) &&(pixel_index / 96 > 49 && pixel_index / 96 < 52)) ||
                    ((pixel_index % 96 > 43 && pixel_index % 96 < 46) &&(pixel_index / 96 > 49 && pixel_index / 96 < 52)) ||
                    ((pixel_index % 96 > 33 && pixel_index % 96 < 46) &&(pixel_index / 96 > 51 && pixel_index / 96 < 54)) ||
                    ((pixel_index % 96 > 31 && pixel_index % 96 < 48) &&(pixel_index / 96 > 53 && pixel_index / 96 < 56)) ||
                    ((pixel_index % 96 > 31 && pixel_index % 96 < 38) &&(pixel_index / 96 > 55 && pixel_index / 96 < 58)) ||
                    ((pixel_index % 96 > 41 && pixel_index % 96 < 48) &&(pixel_index / 96 > 55 && pixel_index / 96 < 58)))
                    oled_data <= sw[4] == 1 ? 16'h1DE2 : sw[5] == 1 ? 16'hD139 : 16'hE8A0;
                //draw hair, body and legs    
                else if (((pixel_index % 96 > 31 && pixel_index % 96 < 38) &&(pixel_index / 96 > 33 && pixel_index / 96 < 36)) ||
                         ((pixel_index % 96 > 41 && pixel_index % 96 < 44) &&(pixel_index / 96 > 33 && pixel_index / 96 < 38)) ||
                         ((pixel_index % 96 > 29 && pixel_index % 96 < 32) &&(pixel_index / 96 > 35 && pixel_index / 96 < 42)) ||
                        ((pixel_index % 96 > 33 && pixel_index % 96 < 36) &&(pixel_index / 96 > 35 && pixel_index / 96 < 40)) ||
                        ((pixel_index % 96 > 35 && pixel_index % 96 < 38) &&(pixel_index / 96 > 37 && pixel_index / 96 < 40)) ||
                        ((pixel_index % 96 > 31 && pixel_index % 96 < 34) &&(pixel_index / 96 > 39 && pixel_index / 96 < 42)) ||
                        ((pixel_index % 96 > 43 && pixel_index % 96 < 46) &&(pixel_index / 96 > 37 && pixel_index / 96 < 40)) ||
                        ((pixel_index % 96 > 41 && pixel_index % 96 < 50) &&(pixel_index / 96 > 39 && pixel_index / 96 < 42)) ||
                        ((pixel_index % 96 > 31 && pixel_index % 96 < 36) &&(pixel_index / 96 > 43 && pixel_index / 96 < 50)) ||
                        ((pixel_index % 96 > 29 && pixel_index % 96 < 32) &&(pixel_index / 96 > 45 && pixel_index / 96 < 50)) ||
                        ((pixel_index % 96 > 27 && pixel_index % 96 < 30) &&(pixel_index / 96 > 47 && pixel_index / 96 < 50)) ||
                        ((pixel_index % 96 > 31 && pixel_index % 96 < 34) &&(pixel_index / 96 > 49 && pixel_index / 96 < 52)) ||
                        ((pixel_index % 96 > 37 && pixel_index % 96 < 42) &&(pixel_index / 96 > 43 && pixel_index / 96 < 48)) ||
                        ((pixel_index % 96 > 41 && pixel_index % 96 < 44) &&(pixel_index / 96 > 43 && pixel_index / 96 < 46)) ||
                        ((pixel_index % 96 > 43 && pixel_index % 96 < 50) &&(pixel_index / 96 > 45 && pixel_index / 96 < 50)) ||
                        ((pixel_index % 96 > 49 && pixel_index % 96 < 52) &&(pixel_index / 96 > 47 && pixel_index / 96 < 50)) ||
                        ((pixel_index % 96 > 45 && pixel_index % 96 < 48) &&(pixel_index / 96 > 49 && pixel_index / 96 < 52)) ||
                        ((pixel_index % 96 > 29 && pixel_index % 96 < 36) &&(pixel_index / 96 > 57 && pixel_index / 96 < 62)) || 
                        ((pixel_index % 96 > 27 && pixel_index % 96 < 30) &&(pixel_index / 96 > 59 && pixel_index / 96 < 62)) ||
                        ((pixel_index % 96 > 43 && pixel_index % 96 < 50) &&(pixel_index / 96 > 57 && pixel_index / 96 < 62)) ||
                        ((pixel_index % 96 > 49 && pixel_index % 96 < 52) &&(pixel_index / 96 > 59 && pixel_index / 96 < 62)))
                        oled_data <= 16'h7320;
                //draw face and arms
                else if (((pixel_index % 96 > 31 && pixel_index % 96 < 34) &&(pixel_index / 96 > 35 && pixel_index / 96 < 40)) ||
                        ((pixel_index % 96 > 35 && pixel_index % 96 < 38) &&(pixel_index / 96 > 35 && pixel_index / 96 < 38)) ||
                        ((pixel_index % 96 > 37 && pixel_index % 96 < 42) &&(pixel_index / 96 > 33 && pixel_index / 96 < 40)) ||
                        ((pixel_index % 96 > 41 && pixel_index % 96 < 44) &&(pixel_index / 96 > 37 && pixel_index / 96 < 40)) ||
                        ((pixel_index % 96 > 43 && pixel_index % 96 < 46) &&(pixel_index / 96 > 33 && pixel_index / 96 < 38)) ||
                        ((pixel_index % 96 > 45 && pixel_index % 96 < 50) &&(pixel_index / 96 > 35 && pixel_index / 96 < 40)) ||
                        ((pixel_index % 96 > 49 && pixel_index % 96 < 52) &&(pixel_index / 96 > 37 && pixel_index / 96 < 40)) ||
                        ((pixel_index % 96 > 33 && pixel_index % 96 < 42) &&(pixel_index / 96 > 39 && pixel_index / 96 < 44)) ||
                        ((pixel_index % 96 > 41 && pixel_index % 96 < 48) &&(pixel_index / 96 > 41 && pixel_index / 96 < 44)) ||
                        ((pixel_index % 96 > 27 && pixel_index % 96 < 32) &&(pixel_index / 96 > 49 && pixel_index / 96 < 56)) ||
                        ((pixel_index % 96 > 31 && pixel_index % 96 < 34) &&(pixel_index / 96 > 51 && pixel_index / 96 < 54)) ||
                        ((pixel_index % 96 > 35 && pixel_index % 96 < 38) &&(pixel_index / 96 > 49 && pixel_index / 96 < 52)) ||
                        ((pixel_index % 96 > 41 && pixel_index % 96 < 44) &&(pixel_index / 96 > 49 && pixel_index / 96 < 52)) ||
                        ((pixel_index % 96 > 45 && pixel_index % 96 < 48) &&(pixel_index / 96 > 51 && pixel_index / 96 < 54)) ||
                        ((pixel_index % 96 > 47 && pixel_index % 96 < 52) &&(pixel_index / 96 > 49 && pixel_index / 96 < 56)))
                        oled_data <= 16'hFD40;        
            end
        endcase
        
    end
    
    //Final Boss
    else if(sw[12] == 1 && sw[11] == 1 && sw[10] == 1)
    begin
    if (finalGameStart == 1)
    begin
        oled_data <= 16'h0000;
        //background
        if ( y == 0 && x == 0) begin oled_data <= 16'h2104; end
        if ( y == 0 && x == 1) begin oled_data <= 16'h18E3; end
        if ( y == 0 && x == 10) begin oled_data <= 16'h2124; end
        if ( y == 0 && x == 11) begin oled_data <= 16'h0861; end
        if ( y == 0 && x >= 12 && x <= 13) begin oled_data <= 16'h0841; end
        if ( y == 0 && x == 48) begin oled_data <= 16'h0841; end
        if ( y == 0 && x == 52) begin oled_data <= 16'h0861; end
        if ( y == 0 && x == 53) begin oled_data <= 16'h0841; end
        if ( y == 0 && x == 55) begin oled_data <= 16'h0861; end
        if ( y == 0 && x == 56) begin oled_data <= 16'h0841; end
        if ( y == 0 && x == 66) begin oled_data <= 16'h0841; end
        if ( y == 0 && x == 74) begin oled_data <= 16'h0841; end
        if ( y == 0 && x == 82) begin oled_data <= 16'h0861; end
        if ( y == 0 && x == 93) begin oled_data <= 16'h0840; end
        if ( y == 0 && x == 94) begin oled_data <= 16'h0841; end
        if ( y == 0 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 1 && x == 10) begin oled_data <= 16'h2124; end
        if ( y == 1 && x >= 11 && x <= 13) begin oled_data <= 16'h0861; end
        if ( y == 1 && x == 14) begin oled_data <= 16'h0841; end
        if ( y == 1 && x == 22) begin oled_data <= 16'h0841; end
        if ( y == 1 && x == 23) begin oled_data <= 16'h2945; end
        if ( y == 1 && x == 36) begin oled_data <= 16'h0841; end
        if ( y == 1 && x == 39) begin oled_data <= 16'h0841; end
        if ( y == 1 && x == 52) begin oled_data <= 16'h2965; end
        if ( y == 1 && x >= 56 && x <= 57) begin oled_data <= 16'h0841; end
        if ( y == 1 && x == 66) begin oled_data <= 16'h0841; end
        if ( y == 1 && x == 69) begin oled_data <= 16'h0841; end
        if ( y == 1 && x == 75) begin oled_data <= 16'h0861; end
        if ( y == 1 && x == 88) begin oled_data <= 16'h0861; end
        if ( y == 1 && x >= 92 && x <= 93) begin oled_data <= 16'h0841; end
        if ( y == 1 && x == 94) begin oled_data <= 16'h0861; end
        if ( y == 1 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 2 && x == 12) begin oled_data <= 16'h18E3; end
        if ( y == 2 && x == 13) begin oled_data <= 16'h0841; end
        if ( y == 2 && x == 17) begin oled_data <= 16'h2104; end
        if ( y == 2 && x == 30) begin oled_data <= 16'h0841; end
        if ( y == 2 && x == 36) begin oled_data <= 16'h0841; end
        if ( y == 2 && x == 37) begin oled_data <= 16'h0840; end
        if ( y == 2 && x == 70) begin oled_data <= 16'h2945; end
        if ( y == 2 && x == 71) begin oled_data <= 16'h18C3; end
        if ( y == 2 && x == 81) begin oled_data <= 16'h2965; end
        if ( y == 2 && x == 91) begin oled_data <= 16'h0841; end
        if ( y == 2 && x == 94) begin oled_data <= 16'h0841; end
        if ( y == 2 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 3 && x == 8) begin oled_data <= 16'h0841; end
        if ( y == 3 && x == 12) begin oled_data <= 16'h0841; end
        if ( y == 3 && x == 36) begin oled_data <= 16'h18E3; end
        if ( y == 3 && x == 37) begin oled_data <= 16'h2104; end
        if ( y == 3 && x == 39) begin oled_data <= 16'h2124; end
        if ( y == 3 && x == 40) begin oled_data <= 16'h1903; end
        if ( y == 3 && x == 56) begin oled_data <= 16'h0861; end
        if ( y == 3 && x == 70) begin oled_data <= 16'h18C3; end
        if ( y == 3 && x == 71) begin oled_data <= 16'h0841; end
        if ( y == 3 && x == 76) begin oled_data <= 16'h0841; end
        if ( y == 3 && x == 80) begin oled_data <= 16'h0861; end
        if ( y == 3 && x == 81) begin oled_data <= 16'h2104; end
        if ( y == 3 && x >= 92 && x <= 93) begin oled_data <= 16'h0861; end
        if ( y == 3 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 4 && x == 2) begin oled_data <= 16'h0841; end
        if ( y == 4 && x == 36) begin oled_data <= 16'h0861; end
        if ( y == 4 && x == 46) begin oled_data <= 16'h0861; end
        if ( y == 4 && x == 50) begin oled_data <= 16'h0841; end
        if ( y == 4 && x == 93) begin oled_data <= 16'h0841; end
        if ( y == 4 && x == 94) begin oled_data <= 16'h31A6; end
        if ( y == 4 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 5 && x == 4) begin oled_data <= 16'h0861; end
        if ( y == 5 && x == 35) begin oled_data <= 16'h18C3; end
        if ( y == 5 && x == 36) begin oled_data <= 16'h0861; end
        if ( y == 5 && x == 40) begin oled_data <= 16'h0840; end
        if ( y == 5 && x == 41) begin oled_data <= 16'h0841; end
        if ( y == 5 && x == 42) begin oled_data <= 16'h0840; end
        if ( y == 5 && x == 43) begin oled_data <= 16'h0820; end
        if ( y == 5 && x == 63) begin oled_data <= 16'h0841; end
        if ( y == 5 && x == 93) begin oled_data <= 16'h0861; end
        if ( y == 5 && x == 94) begin oled_data <= 16'h18C3; end
        if ( y == 5 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 6 && x >= 16 && x <= 17) begin oled_data <= 16'h0841; end
        if ( y == 6 && x == 22) begin oled_data <= 16'h0841; end
        if ( y == 6 && x == 25) begin oled_data <= 16'h0841; end
        if ( y == 6 && x == 35) begin oled_data <= 16'h2985; end
        if ( y == 6 && x == 36) begin oled_data <= 16'h0861; end
        if ( y == 6 && x == 40) begin oled_data <= 16'h0861; end
        if ( y == 6 && x == 41) begin oled_data <= 16'h0840; end
        if ( y == 6 && x >= 42 && x <= 43) begin oled_data <= 16'h0841; end
        if ( y == 6 && x == 44) begin oled_data <= 16'h18E3; end
        if ( y == 6 && x == 45) begin oled_data <= 16'h0841; end
        if ( y == 6 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 7 && x == 18) begin oled_data <= 16'h0861; end
        if ( y == 7 && x == 40) begin oled_data <= 16'h0840; end
        if ( y == 7 && x == 41) begin oled_data <= 16'h18E3; end
        if ( y == 7 && x == 44) begin oled_data <= 16'h2945; end
        if ( y == 7 && x == 45) begin oled_data <= 16'h0841; end
        if ( y == 7 && x == 66) begin oled_data <= 16'h0841; end
        if ( y == 7 && x == 82) begin oled_data <= 16'h0841; end
        if ( y == 7 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 8 && x >= 16 && x <= 17) begin oled_data <= 16'h0841; end
        if ( y == 8 && x == 39) begin oled_data <= 16'h0840; end
        if ( y == 8 && x == 41) begin oled_data <= 16'h2124; end
        if ( y == 8 && x == 45) begin oled_data <= 16'h2103; end
        if ( y == 8 && x == 80) begin oled_data <= 16'h0841; end
        if ( y == 8 && x == 91) begin oled_data <= 16'h2104; end
        if ( y == 8 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 9 && x == 1) begin oled_data <= 16'h0841; end
        if ( y == 9 && x == 3) begin oled_data <= 16'h0841; end
        if ( y == 9 && x == 9) begin oled_data <= 16'h31A6; end
        if ( y == 9 && x == 10) begin oled_data <= 16'h0841; end
        if ( y == 9 && x == 13) begin oled_data <= 16'h0861; end
        if ( y == 9 && x == 21) begin oled_data <= 16'h0841; end
        if ( y == 9 && x == 42) begin oled_data <= 16'h0841; end
        if ( y == 9 && x == 45) begin oled_data <= 16'h2944; end
        if ( y == 9 && x == 46) begin oled_data <= 16'h0841; end
        if ( y == 9 && x == 49) begin oled_data <= 16'h0841; end
        if ( y == 9 && x == 73) begin oled_data <= 16'h0841; end
        if ( y == 9 && x == 91) begin oled_data <= 16'h2124; end
        if ( y == 9 && x == 94) begin oled_data <= 16'h0861; end
        if ( y == 9 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 10 && x == 9) begin oled_data <= 16'h0841; end
        if ( y == 10 && x == 19) begin oled_data <= 16'h0861; end
        if ( y == 10 && x == 44) begin oled_data <= 16'h0861; end
        if ( y == 10 && x == 46) begin oled_data <= 16'h2124; end
        if ( y == 10 && x == 47) begin oled_data <= 16'h0841; end
        if ( y == 10 && x == 50) begin oled_data <= 16'h2104; end
        if ( y == 10 && x == 51) begin oled_data <= 16'h18C3; end
        if ( y == 10 && x == 57) begin oled_data <= 16'h39C7; end
        if ( y == 10 && x == 58) begin oled_data <= 16'h0841; end
        if ( y == 10 && x == 61) begin oled_data <= 16'h0841; end
        if ( y == 10 && x >= 76 && x <= 77) begin oled_data <= 16'h0861; end
        if ( y == 10 && x == 86) begin oled_data <= 16'h0841; end
        if ( y == 10 && x == 87) begin oled_data <= 16'h2965; end
        if ( y == 10 && x == 88) begin oled_data <= 16'h0861; end
        if ( y == 10 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 11 && x == 34) begin oled_data <= 16'h0841; end
        if ( y == 11 && x == 44) begin oled_data <= 16'h0841; end
        if ( y == 11 && x == 46) begin oled_data <= 16'h2104; end
        if ( y == 11 && x == 47) begin oled_data <= 16'h0841; end
        if ( y == 11 && x == 50) begin oled_data <= 16'h18E3; end
        if ( y == 11 && x == 57) begin oled_data <= 16'h0841; end
        if ( y == 11 && x == 63) begin oled_data <= 16'h0861; end
        if ( y == 11 && x >= 76 && x <= 77) begin oled_data <= 16'h2124; end
        if ( y == 11 && x == 82) begin oled_data <= 16'h0861; end
        if ( y == 11 && x == 86) begin oled_data <= 16'h0841; end
        if ( y == 11 && x == 87) begin oled_data <= 16'h2124; end
        if ( y == 11 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 12 && x == 5) begin oled_data <= 16'h0861; end
        if ( y == 12 && x == 19) begin oled_data <= 16'h2145; end
        if ( y == 12 && x == 38) begin oled_data <= 16'h0841; end
        if ( y == 12 && x == 83) begin oled_data <= 16'h2986; end
        if ( y == 12 && x == 84) begin oled_data <= 16'h0861; end
        if ( y == 12 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 13 && x == 7) begin oled_data <= 16'h0841; end
        if ( y == 13 && x == 30) begin oled_data <= 16'h0841; end
        if ( y == 13 && x == 82) begin oled_data <= 16'h0861; end
        if ( y == 13 && x == 83) begin oled_data <= 16'h18E3; end
        if ( y == 13 && x == 94) begin oled_data <= 16'h0861; end
        if ( y == 13 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 14 && x == 1) begin oled_data <= 16'h0841; end
        if ( y == 14 && x == 4) begin oled_data <= 16'h0841; end
        if ( y == 14 && x == 24) begin oled_data <= 16'h0841; end
        if ( y == 14 && x == 25) begin oled_data <= 16'h0861; end
        if ( y == 14 && x == 30) begin oled_data <= 16'h2945; end
        if ( y == 14 && x == 53) begin oled_data <= 16'h0841; end
        if ( y == 14 && x == 68) begin oled_data <= 16'h0841; end
        if ( y == 14 && x == 80) begin oled_data <= 16'h0841; end
        if ( y == 14 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 15 && x == 1) begin oled_data <= 16'h0841; end
        if ( y == 15 && x == 2) begin oled_data <= 16'h2124; end
        if ( y == 15 && x == 3) begin oled_data <= 16'h18E3; end
        if ( y == 15 && x == 24) begin oled_data <= 16'h18C3; end
        if ( y == 15 && x == 25) begin oled_data <= 16'h2945; end
        if ( y == 15 && x >= 46 && x <= 47) begin oled_data <= 16'h0840; end
        if ( y == 15 && x == 52) begin oled_data <= 16'h2965; end
        if ( y == 15 && x == 61) begin oled_data <= 16'h31A6; end
        if ( y == 15 && x == 68) begin oled_data <= 16'h0841; end
        if ( y == 15 && x == 70) begin oled_data <= 16'h0841; end
        if ( y == 15 && x == 73) begin oled_data <= 16'h0861; end
        if ( y == 15 && x == 74) begin oled_data <= 16'h0841; end
        if ( y == 15 && x == 79) begin oled_data <= 16'h0841; end
        if ( y == 15 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 16 && x == 2) begin oled_data <= 16'h39E8; end
        if ( y == 16 && x == 3) begin oled_data <= 16'h2965; end
        if ( y == 16 && x == 7) begin oled_data <= 16'h0841; end
        if ( y == 16 && x == 20) begin oled_data <= 16'h0861; end
        if ( y == 16 && x == 24) begin oled_data <= 16'h0841; end
        if ( y == 16 && x == 38) begin oled_data <= 16'h0841; end
        if ( y == 16 && x == 46) begin oled_data <= 16'h2103; end
        if ( y == 16 && x == 47) begin oled_data <= 16'h2924; end
        if ( y == 16 && x == 61) begin oled_data <= 16'h0862; end
        if ( y == 16 && x == 69) begin oled_data <= 16'h0861; end
        if ( y == 16 && x == 70) begin oled_data <= 16'h0841; end
        if ( y == 16 && x == 73) begin oled_data <= 16'h2104; end
        if ( y == 16 && x == 74) begin oled_data <= 16'h0861; end
        if ( y == 16 && x == 82) begin oled_data <= 16'h18C3; end
        if ( y == 16 && x == 83) begin oled_data <= 16'h0841; end
        if ( y == 16 && x == 87) begin oled_data <= 16'h0861; end
        if ( y == 16 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 17 && x == 2) begin oled_data <= 16'h0861; end
        if ( y == 17 && x >= 3 && x <= 4) begin oled_data <= 16'h0841; end
        if ( y == 17 && x == 7) begin oled_data <= 16'h0841; end
        if ( y == 17 && x == 8) begin oled_data <= 16'h0861; end
        if ( y == 17 && x == 19) begin oled_data <= 16'h0861; end
        if ( y == 17 && x == 28) begin oled_data <= 16'h0841; end
        if ( y == 17 && x >= 36 && x <= 37) begin oled_data <= 16'h0840; end
        if ( y == 17 && x == 38) begin oled_data <= 16'h0861; end
        if ( y == 17 && x == 39) begin oled_data <= 16'h2104; end
        if ( y == 17 && x == 40) begin oled_data <= 16'h0841; end
        if ( y == 17 && x == 43) begin oled_data <= 16'h0861; end
        if ( y == 17 && x >= 46 && x <= 47) begin oled_data <= 16'h0861; end
        if ( y == 17 && x == 51) begin oled_data <= 16'h0840; end
        if ( y == 17 && x == 60) begin oled_data <= 16'h18E3; end
        if ( y == 17 && x == 73) begin oled_data <= 16'h2965; end
        if ( y == 17 && x == 81) begin oled_data <= 16'h0841; end
        if ( y == 17 && x == 82) begin oled_data <= 16'h2965; end
        if ( y == 17 && x == 88) begin oled_data <= 16'h2124; end
        if ( y == 17 && x == 94) begin oled_data <= 16'h39C7; end
        if ( y == 17 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 18 && x == 0) begin oled_data <= 16'h0841; end
        if ( y == 18 && x == 3) begin oled_data <= 16'h0841; end
        if ( y == 18 && x == 5) begin oled_data <= 16'h0841; end
        if ( y == 18 && x == 7) begin oled_data <= 16'h0841; end
        if ( y == 18 && x == 15) begin oled_data <= 16'h0841; end
        if ( y == 18 && x == 36) begin oled_data <= 16'h0861; end
        if ( y == 18 && x == 37) begin oled_data <= 16'h0841; end
        if ( y == 18 && x == 38) begin oled_data <= 16'h0861; end
        if ( y == 18 && x == 39) begin oled_data <= 16'h2945; end
        if ( y == 18 && x == 40) begin oled_data <= 16'h0861; end
        if ( y == 18 && x == 44) begin oled_data <= 16'h2124; end
        if ( y == 18 && x >= 45 && x <= 46) begin oled_data <= 16'h0840; end
        if ( y == 18 && x == 51) begin oled_data <= 16'h3185; end
        if ( y == 18 && x == 52) begin oled_data <= 16'h18C2; end
        if ( y == 18 && x == 60) begin oled_data <= 16'h2124; end
        if ( y == 18 && x == 81) begin oled_data <= 16'h0841; end
        if ( y == 18 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 19 && x == 7) begin oled_data <= 16'h0861; end
        if ( y == 19 && x == 8) begin oled_data <= 16'h0841; end
        if ( y == 19 && x == 16) begin oled_data <= 16'h18E3; end
        if ( y == 19 && x == 21) begin oled_data <= 16'h0861; end
        if ( y == 19 && x == 35) begin oled_data <= 16'h0861; end
        if ( y == 19 && x == 37) begin oled_data <= 16'h0841; end
        if ( y == 19 && x == 38) begin oled_data <= 16'h0861; end
        if ( y == 19 && x == 43) begin oled_data <= 16'h0841; end
        if ( y == 19 && x == 45) begin oled_data <= 16'h0841; end
        if ( y == 19 && x == 49) begin oled_data <= 16'h0840; end
        if ( y == 19 && x == 50) begin oled_data <= 16'h18C2; end
        if ( y == 19 && x == 51) begin oled_data <= 16'hA512; end
        if ( y == 19 && x == 52) begin oled_data <= 16'h736C; end
        if ( y == 19 && x == 54) begin oled_data <= 16'h0841; end
        if ( y == 19 && x == 79) begin oled_data <= 16'h0861; end
        if ( y == 19 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 20 && x == 3) begin oled_data <= 16'h0841; end
        if ( y == 20 && x == 15) begin oled_data <= 16'h0881; end
        if ( y == 20 && x == 16) begin oled_data <= 16'h18C3; end
        if ( y == 20 && x == 20) begin oled_data <= 16'h0841; end
        if ( y == 20 && x == 21) begin oled_data <= 16'h0840; end
        if ( y == 20 && x >= 35 && x <= 36) begin oled_data <= 16'h0840; end
        if ( y == 20 && x == 38) begin oled_data <= 16'h0861; end
        if ( y == 20 && x == 39) begin oled_data <= 16'h0840; end
        if ( y == 20 && x == 51) begin oled_data <= 16'h39A5; end
        if ( y == 20 && x == 55) begin oled_data <= 16'h0861; end
        if ( y == 20 && x == 71) begin oled_data <= 16'h0841; end
        if ( y == 20 && x == 75) begin oled_data <= 16'h0841; end
        if ( y == 20 && x >= 78 && x <= 79) begin oled_data <= 16'h0841; end
        if ( y == 20 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 21 && x == 27) begin oled_data <= 16'h0861; end
        if ( y == 21 && x == 34) begin oled_data <= 16'h0841; end
        if ( y == 21 && x == 35) begin oled_data <= 16'h0840; end
        if ( y == 21 && x == 36) begin oled_data <= 16'h0841; end
        if ( y == 21 && x == 37) begin oled_data <= 16'h2965; end
        if ( y == 21 && x == 38) begin oled_data <= 16'h0841; end
        if ( y == 21 && x == 51) begin oled_data <= 16'h0840; end
        if ( y == 21 && x == 54) begin oled_data <= 16'h3186; end
        if ( y == 21 && x == 55) begin oled_data <= 16'h0861; end
        if ( y == 21 && x == 64) begin oled_data <= 16'h0841; end
        if ( y == 21 && x == 66) begin oled_data <= 16'h0841; end
        if ( y == 21 && x == 67) begin oled_data <= 16'h39C7; end
        if ( y == 21 && x == 68) begin oled_data <= 16'h0861; end
        if ( y == 21 && x == 78) begin oled_data <= 16'h0861; end
        if ( y == 21 && x == 80) begin oled_data <= 16'h0841; end
        if ( y == 21 && x == 89) begin oled_data <= 16'h0861; end
        if ( y == 21 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 22 && x == 6) begin oled_data <= 16'h0861; end
        if ( y == 22 && x == 27) begin oled_data <= 16'h0841; end
        if ( y == 22 && x == 28) begin oled_data <= 16'h0861; end
        if ( y == 22 && x == 34) begin oled_data <= 16'h0841; end
        if ( y == 22 && x == 36) begin oled_data <= 16'h0841; end
        if ( y == 22 && x == 37) begin oled_data <= 16'h18E3; end
        if ( y == 22 && x == 49) begin oled_data <= 16'h0841; end
        if ( y == 22 && x >= 66 && x <= 68) begin oled_data <= 16'h0841; end
        if ( y == 22 && x == 77) begin oled_data <= 16'h0841; end
        if ( y == 22 && x == 79) begin oled_data <= 16'h3186; end
        if ( y == 22 && x == 80) begin oled_data <= 16'h0841; end
        if ( y == 22 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 23 && x == 17) begin oled_data <= 16'h0840; end
        if ( y == 23 && x == 21) begin oled_data <= 16'h0841; end
        if ( y == 23 && x == 22) begin oled_data <= 16'h0820; end
        if ( y == 23 && x == 24) begin oled_data <= 16'h0841; end
        if ( y == 23 && x == 35) begin oled_data <= 16'h0861; end
        if ( y == 23 && x == 78) begin oled_data <= 16'h0861; end
        if ( y == 23 && x == 79) begin oled_data <= 16'h18E3; end
        if ( y == 23 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 24 && x == 16) begin oled_data <= 16'h0861; end
        if ( y == 24 && x == 21) begin oled_data <= 16'h2103; end
        if ( y == 24 && x == 28) begin oled_data <= 16'h0841; end
        if ( y == 24 && x == 29) begin oled_data <= 16'h3185; end
        if ( y == 24 && x == 39) begin oled_data <= 16'h0861; end
        if ( y == 24 && x == 42) begin oled_data <= 16'h0861; end
        if ( y == 24 && x == 43) begin oled_data <= 16'h18A2; end
        if ( y == 24 && x == 44) begin oled_data <= 16'h0840; end
        if ( y == 24 && x == 58) begin oled_data <= 16'h0841; end
        if ( y == 24 && x == 63) begin oled_data <= 16'h0841; end
        if ( y == 24 && x == 80) begin oled_data <= 16'h0841; end
        if ( y == 24 && x == 82) begin oled_data <= 16'h0841; end
        if ( y == 24 && x >= 89 && x <= 90) begin oled_data <= 16'h0861; end
        if ( y == 24 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 25 && x == 14) begin oled_data <= 16'h0861; end
        if ( y == 25 && x == 40) begin oled_data <= 16'h0841; end
        if ( y == 25 && x == 43) begin oled_data <= 16'h2945; end
        if ( y == 25 && x == 44) begin oled_data <= 16'h0840; end
        if ( y == 25 && x == 72) begin oled_data <= 16'h0841; end
        if ( y == 25 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 26 && x == 13) begin oled_data <= 16'h2945; end
        if ( y == 26 && x == 22) begin oled_data <= 16'h0841; end
        if ( y == 26 && x == 23) begin oled_data <= 16'h2944; end
        if ( y == 26 && x == 27) begin oled_data <= 16'h0841; end
        if ( y == 26 && x >= 38 && x <= 40) begin oled_data <= 16'h0841; end
        if ( y == 26 && x >= 41 && x <= 42) begin oled_data <= 16'h0820; end
        if ( y == 26 && x == 44) begin oled_data <= 16'h0840; end
        if ( y == 26 && x == 64) begin oled_data <= 16'h0841; end
        if ( y == 26 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 27 && x == 7) begin oled_data <= 16'h0841; end
        if ( y == 27 && x == 27) begin oled_data <= 16'h0840; end
        if ( y == 27 && x == 38) begin oled_data <= 16'h0841; end
        if ( y == 27 && x == 39) begin oled_data <= 16'h3185; end
        if ( y == 27 && x == 41) begin oled_data <= 16'h0861; end
        if ( y == 27 && x == 71) begin oled_data <= 16'h31A6; end
        if ( y == 27 && x >= 86 && x <= 87) begin oled_data <= 16'h0841; end
        if ( y == 27 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 28 && x == 11) begin oled_data <= 16'h0841; end
        if ( y == 28 && x == 26) begin oled_data <= 16'h0861; end
        if ( y == 28 && x == 39) begin oled_data <= 16'h0841; end
        if ( y == 28 && x == 40) begin oled_data <= 16'h0840; end
        if ( y == 28 && x == 41) begin oled_data <= 16'h2103; end
        if ( y == 28 && x == 71) begin oled_data <= 16'h0861; end
        if ( y == 28 && x == 91) begin oled_data <= 16'h0841; end
        if ( y == 28 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 29 && x == 15) begin oled_data <= 16'h18C3; end
        if ( y == 29 && x == 16) begin oled_data <= 16'h2124; end
        if ( y == 29 && x == 18) begin oled_data <= 16'h0861; end
        if ( y == 29 && x == 24) begin oled_data <= 16'h0820; end
        if ( y == 29 && x == 25) begin oled_data <= 16'h0840; end
        if ( y == 29 && x == 26) begin oled_data <= 16'h62EA; end
        if ( y == 29 && x == 27) begin oled_data <= 16'h83CE; end
        if ( y == 29 && x == 29) begin oled_data <= 16'h0840; end
        if ( y == 29 && x == 30) begin oled_data <= 16'h0820; end
        if ( y == 29 && x == 31) begin oled_data <= 16'h0861; end
        if ( y == 29 && x == 41) begin oled_data <= 16'h2103; end
        if ( y == 29 && x == 43) begin oled_data <= 16'h0840; end
        if ( y == 29 && x == 52) begin oled_data <= 16'h0861; end
        if ( y == 29 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 30 && x == 6) begin oled_data <= 16'h0841; end
        if ( y == 30 && x == 16) begin oled_data <= 16'h18E3; end
        if ( y == 30 && x == 17) begin oled_data <= 16'h0821; end
        if ( y == 30 && x == 25) begin oled_data <= 16'h0840; end
        if ( y == 30 && x == 26) begin oled_data <= 16'h5AAA; end
        if ( y == 30 && x == 27) begin oled_data <= 16'h7B8D; end
        if ( y == 30 && x == 29) begin oled_data <= 16'h0820; end
        if ( y == 30 && x == 30) begin oled_data <= 16'h0821; end
        if ( y == 30 && x == 32) begin oled_data <= 16'h0841; end
        if ( y == 30 && x == 50) begin oled_data <= 16'h0861; end
        if ( y == 30 && x == 68) begin oled_data <= 16'h0841; end
        if ( y == 30 && x == 88) begin oled_data <= 16'h2945; end
        if ( y == 30 && x == 89) begin oled_data <= 16'h18C3; end
        if ( y == 30 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 31 && x == 12) begin oled_data <= 16'h0841; end
        if ( y == 31 && x == 26) begin oled_data <= 16'h0841; end
        if ( y == 31 && x == 30) begin oled_data <= 16'h0841; end
        if ( y == 31 && x == 31) begin oled_data <= 16'h3186; end
        if ( y == 31 && x == 37) begin oled_data <= 16'h0841; end
        if ( y == 31 && x == 51) begin oled_data <= 16'h31A6; end
        if ( y == 31 && x == 59) begin oled_data <= 16'h0861; end
        if ( y == 31 && x == 73) begin oled_data <= 16'h3186; end
        if ( y == 31 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 32 && x == 12) begin oled_data <= 16'h0841; end
        if ( y == 32 && x == 22) begin oled_data <= 16'h0841; end
        if ( y == 32 && x >= 29 && x <= 30) begin oled_data <= 16'h0841; end
        if ( y == 32 && x == 31) begin oled_data <= 16'h0840; end
        if ( y == 32 && x == 32) begin oled_data <= 16'h0841; end
        if ( y == 32 && x == 39) begin oled_data <= 16'h0861; end
        if ( y == 32 && x == 55) begin oled_data <= 16'h31A6; end
        if ( y == 32 && x == 56) begin oled_data <= 16'h0841; end
        if ( y == 32 && x == 73) begin oled_data <= 16'h18E3; end
        if ( y == 32 && x == 74) begin oled_data <= 16'h0841; end
        if ( y == 32 && x >= 87 && x <= 88) begin oled_data <= 16'h0841; end
        if ( y == 32 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 33 && x == 10) begin oled_data <= 16'h2124; end
        if ( y == 33 && x == 11) begin oled_data <= 16'h2104; end
        if ( y == 33 && x == 19) begin oled_data <= 16'h0861; end
        if ( y == 33 && x == 20) begin oled_data <= 16'h31A6; end
        if ( y == 33 && x == 33) begin oled_data <= 16'h2965; end
        if ( y == 33 && x == 55) begin oled_data <= 16'h18C3; end
        if ( y == 33 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 34 && x == 25) begin oled_data <= 16'h0861; end
        if ( y == 34 && x == 26) begin oled_data <= 16'h18C3; end
        if ( y == 34 && x == 27) begin oled_data <= 16'h0841; end
        if ( y == 34 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 35 && x == 25) begin oled_data <= 16'h18C3; end
        if ( y == 35 && x == 26) begin oled_data <= 16'h2945; end
        if ( y == 35 && x == 29) begin oled_data <= 16'h0841; end
        if ( y == 35 && x == 42) begin oled_data <= 16'h0841; end
        if ( y == 35 && x == 47) begin oled_data <= 16'h0861; end
        if ( y == 35 && x >= 83 && x <= 84) begin oled_data <= 16'h0841; end
        if ( y == 35 && x == 87) begin oled_data <= 16'h0841; end
        if ( y == 35 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 36 && x == 3) begin oled_data <= 16'h3186; end
        if ( y == 36 && x == 4) begin oled_data <= 16'h18E3; end
        if ( y == 36 && x >= 21 && x <= 23) begin oled_data <= 16'h0841; end
        if ( y == 36 && x == 41) begin oled_data <= 16'h0841; end
        if ( y == 36 && x == 63) begin oled_data <= 16'h39C7; end
        if ( y == 36 && x == 83) begin oled_data <= 16'h0861; end
        if ( y == 36 && x == 84) begin oled_data <= 16'h0841; end
        if ( y == 36 && x == 85) begin oled_data <= 16'h0861; end
        if ( y == 36 && x == 94) begin oled_data <= 16'h0841; end
        if ( y == 36 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 37 && x >= 2 && x <= 3) begin oled_data <= 16'h0861; end
        if ( y == 37 && x == 22) begin oled_data <= 16'h3186; end
        if ( y == 37 && x == 23) begin oled_data <= 16'h18E3; end
        if ( y == 37 && x == 36) begin oled_data <= 16'h39C7; end
        if ( y == 37 && x == 40) begin oled_data <= 16'h0841; end
        if ( y == 37 && x == 42) begin oled_data <= 16'h0841; end
        if ( y == 37 && x == 44) begin oled_data <= 16'h0841; end
        if ( y == 37 && x == 63) begin oled_data <= 16'h0861; end
        if ( y == 37 && x == 83) begin oled_data <= 16'h0841; end
        if ( y == 37 && x == 84) begin oled_data <= 16'h39E7; end
        if ( y == 37 && x == 85) begin oled_data <= 16'h0861; end
        if ( y == 37 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 38 && x == 6) begin oled_data <= 16'h0841; end
        if ( y == 38 && x >= 13 && x <= 14) begin oled_data <= 16'h0841; end
        if ( y == 38 && x == 22) begin oled_data <= 16'h0861; end
        if ( y == 38 && x == 36) begin oled_data <= 16'h0861; end
        if ( y == 38 && x == 40) begin oled_data <= 16'h0841; end
        if ( y == 38 && x == 83) begin oled_data <= 16'h0841; end
        if ( y == 38 && x == 84) begin oled_data <= 16'h0861; end
        if ( y == 38 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 39 && x == 6) begin oled_data <= 16'h0841; end
        if ( y == 39 && x == 14) begin oled_data <= 16'h0861; end
        if ( y == 39 && x >= 39 && x <= 40) begin oled_data <= 16'h0861; end
        if ( y == 39 && x == 41) begin oled_data <= 16'h0841; end
        if ( y == 39 && x == 42) begin oled_data <= 16'h0840; end
        if ( y == 39 && x == 59) begin oled_data <= 16'h0841; end
        if ( y == 39 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 40 && x == 14) begin oled_data <= 16'h0861; end
        if ( y == 40 && x == 15) begin oled_data <= 16'h0841; end
        if ( y == 40 && x == 26) begin oled_data <= 16'h0861; end
        if ( y == 40 && x == 38) begin oled_data <= 16'h0841; end
        if ( y == 40 && x == 40) begin oled_data <= 16'h0861; end
        if ( y == 40 && x == 53) begin oled_data <= 16'h0841; end
        if ( y == 40 && x == 54) begin oled_data <= 16'h2965; end
        if ( y == 40 && x == 55) begin oled_data <= 16'h0861; end
        if ( y == 40 && x == 63) begin oled_data <= 16'h0841; end
        if ( y == 40 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 41 && x == 13) begin oled_data <= 16'h0841; end
        if ( y == 41 && x == 14) begin oled_data <= 16'h0861; end
        if ( y == 41 && x == 16) begin oled_data <= 16'h18E3; end
        if ( y == 41 && x == 17) begin oled_data <= 16'h2945; end
        if ( y == 41 && x == 19) begin oled_data <= 16'h0841; end
        if ( y == 41 && x == 20) begin oled_data <= 16'h0861; end
        if ( y == 41 && x == 21) begin oled_data <= 16'h0841; end
        if ( y == 41 && x == 25) begin oled_data <= 16'h31A6; end
        if ( y == 41 && x == 26) begin oled_data <= 16'h0861; end
        if ( y == 41 && x == 38) begin oled_data <= 16'h0841; end
        if ( y == 41 && x == 53) begin oled_data <= 16'h0841; end
        if ( y == 41 && x == 54) begin oled_data <= 16'h2104; end
        if ( y == 41 && x == 55) begin oled_data <= 16'h0841; end
        if ( y == 41 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 42 && x >= 13 && x <= 14) begin oled_data <= 16'h0841; end
        if ( y == 42 && x == 19) begin oled_data <= 16'h0841; end
        if ( y == 42 && x == 21) begin oled_data <= 16'h0841; end
        if ( y == 42 && x == 39) begin oled_data <= 16'h0861; end
        if ( y == 42 && x == 48) begin oled_data <= 16'h0861; end
        if ( y == 42 && x == 53) begin oled_data <= 16'h0841; end
        if ( y == 42 && x == 57) begin oled_data <= 16'h0841; end
        if ( y == 42 && x == 81) begin oled_data <= 16'h0841; end
        if ( y == 42 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 43 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 44 && x == 34) begin oled_data <= 16'h0841; end
        if ( y == 44 && x == 44) begin oled_data <= 16'h0841; end
        if ( y == 44 && x == 53) begin oled_data <= 16'h18E3; end
        if ( y == 44 && x == 69) begin oled_data <= 16'h18C3; end
        if ( y == 44 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 45 && x == 53) begin oled_data <= 16'h2965; end
        if ( y == 45 && x == 69) begin oled_data <= 16'h2124; end
        if ( y == 45 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 46 && x == 4) begin oled_data <= 16'h0841; end
        if ( y == 46 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 47 && x == 52) begin oled_data <= 16'h0841; end
        if ( y == 47 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 48 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 49 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 50 && x == 9) begin oled_data <= 16'h0841; end
        if ( y == 50 && x == 17) begin oled_data <= 16'h0841; end
        if ( y == 50 && x == 39) begin oled_data <= 16'h0841; end
        if ( y == 50 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 51 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 52 && x >= 65 && x <= 66) begin oled_data <= 16'h0841; end
        if ( y == 52 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 53 && x == 65) begin oled_data <= 16'h0841; end
        if ( y == 53 && x == 67) begin oled_data <= 16'h0861; end
        if ( y == 53 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 54 && x == 37) begin oled_data <= 16'h0841; end
        if ( y == 54 && x == 38) begin oled_data <= 16'h18E3; end
        if ( y == 54 && x == 39) begin oled_data <= 16'h0841; end
        if ( y == 54 && x == 66) begin oled_data <= 16'h0841; end
        if ( y == 54 && x == 80) begin oled_data <= 16'h0861; end
        if ( y == 54 && x == 86) begin oled_data <= 16'h0861; end
        if ( y == 54 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 55 && x == 23) begin oled_data <= 16'h0861; end
        if ( y == 55 && x == 30) begin oled_data <= 16'h0841; end
        if ( y == 55 && x == 37) begin oled_data <= 16'h0841; end
        if ( y == 55 && x == 38) begin oled_data <= 16'h2965; end
        if ( y == 55 && x == 40) begin oled_data <= 16'h0841; end
        if ( y == 55 && x == 47) begin oled_data <= 16'h0861; end
        if ( y == 55 && x == 48) begin oled_data <= 16'h0841; end
        if ( y == 55 && x == 80) begin oled_data <= 16'h0841; end
        if ( y == 55 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 56 && x == 15) begin oled_data <= 16'h0841; end
        if ( y == 56 && x == 23) begin oled_data <= 16'h0861; end
        if ( y == 56 && x == 79) begin oled_data <= 16'h0861; end
        if ( y == 56 && x == 80) begin oled_data <= 16'h7BEF; end
        if ( y == 56 && x == 81) begin oled_data <= 16'h4A8A; end
        if ( y == 56 && x == 91) begin oled_data <= 16'h0841; end
        if ( y == 56 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 57 && x == 78) begin oled_data <= 16'h0841; end
        if ( y == 57 && x == 79) begin oled_data <= 16'h0881; end
        if ( y == 57 && x == 80) begin oled_data <= 16'h8C71; end
        if ( y == 57 && x == 81) begin oled_data <= 16'h52CA; end
        if ( y == 57 && x == 89) begin oled_data <= 16'h0861; end
        if ( y == 57 && x == 90) begin oled_data <= 16'h2945; end
        if ( y == 57 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 58 && x == 58) begin oled_data <= 16'h2945; end
        if ( y == 58 && x == 59) begin oled_data <= 16'h2104; end
        if ( y == 58 && x == 89) begin oled_data <= 16'h0841; end
        if ( y == 58 && x == 90) begin oled_data <= 16'h2124; end
        if ( y == 58 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 59 && x == 58) begin oled_data <= 16'h0841; end
        if ( y == 59 && x == 80) begin oled_data <= 16'h0841; end
        if ( y == 59 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 60 && x >= 85 && x <= 86) begin oled_data <= 16'h0841; end
        if ( y == 60 && x == 95) begin oled_data <= 16'hF79E; end
        if ( y == 61 && x == 29) begin oled_data <= 16'h0861; end
        if ( y == 61 && x == 95) begin oled_data <= 16'hF79E; end
        if ( x == 95 ) begin oled_data <= 16'h0000; end
        //end of background
        
        //health bar
        //mega-man health
        if ( y == 1 ) begin oled_data <= 16'hFFFF; end
        if ( y == 5 ) begin oled_data <= 16'hFFFF; end
        if ( y >= 2 && y <= 4 && x == 0) begin oled_data <= 16'hFFFF; end
        if ( y >= 2 && y <= 4 && x == 95) begin oled_data <= 16'hFFFF; end
        if ( y >= 2 && y <= 4 && x >= 1 && x <= 94) begin oled_data <= 16'h049F; end
        if ( y >= 2 && y <= 4 && x >= (94 - megaman_health_counter) && x <= 94) begin oled_data <= 16'h0000; end
        //mario health
        if ( y == 9 ) begin oled_data <= 16'hFFFF; end
        if ( y == 13 ) begin oled_data <= 16'hFFFF; end
        if ( y >= 10 && y <= 12 && x == 0) begin oled_data <= 16'hFFFF; end
        if ( y >= 10 && y <= 12 && x == 95) begin oled_data <= 16'hFFFF; end
        if ( y >= 10 && y <= 12 && x >= 1 && x <= 94) begin oled_data <= 16'hF980; end
        if ( y >= 10 && y <= 12 && x >= 1 && x <= (1 + mario_health_counter)) begin oled_data <= 16'h0000; end
        
        //megaman image
        if ( y >= 20 && y <= 50 && x >= 0 && x <= 27) begin oled_data <= 16'h0000; end
        if ( y == 20 && x == 15) begin oled_data <= 16'h324C; end
        if ( y == 20 && x == 16) begin oled_data <= 16'h32AF; end
        if ( y == 20 && x == 17) begin oled_data <= 16'h4352; end
        if ( y == 20 && x == 18) begin oled_data <= 16'h5434; end
        if ( y == 20 && x == 19) begin oled_data <= 16'h53F2; end
        if ( y == 20 && x == 20) begin oled_data <= 16'h0946; end
        if ( y == 21 && x == 13) begin oled_data <= 16'h0883; end
        if ( y == 21 && x == 14) begin oled_data <= 16'h29CB; end
        if ( y == 21 && x == 15) begin oled_data <= 16'h19CD; end
        if ( y == 21 && x == 16) begin oled_data <= 16'h11EF; end
        if ( y == 21 && x == 17) begin oled_data <= 16'h22B2; end
        if ( y == 21 && x == 18) begin oled_data <= 16'h3353; end
        if ( y == 21 && x == 19) begin oled_data <= 16'h7559; end
        if ( y == 21 && x == 20) begin oled_data <= 16'h74F5; end
        if ( y == 21 && x == 21) begin oled_data <= 16'h1166; end
        if ( y == 22 && x == 13) begin oled_data <= 16'h29CB; end
        if ( y == 22 && x == 14) begin oled_data <= 16'h198F; end
        if ( y == 22 && x == 15) begin oled_data <= 16'h09D3; end
        if ( y == 22 && x == 16) begin oled_data <= 16'h1AD8; end
        if ( y == 22 && x == 17) begin oled_data <= 16'h239A; end
        if ( y == 22 && x == 18) begin oled_data <= 16'h12F6; end
        if ( y == 22 && x == 19) begin oled_data <= 16'h1292; end
        if ( y == 22 && x == 20) begin oled_data <= 16'h85DC; end
        if ( y == 22 && x == 21) begin oled_data <= 16'h7516; end
        if ( y == 22 && x == 22) begin oled_data <= 16'h08C4; end
        if ( y == 23 && x == 12) begin oled_data <= 16'h08A4; end
        if ( y == 23 && x == 13) begin oled_data <= 16'h21CC; end
        if ( y == 23 && x == 14) begin oled_data <= 16'h19B2; end
        if ( y == 23 && x == 15) begin oled_data <= 16'h11F5; end
        if ( y == 23 && x == 16) begin oled_data <= 16'h0A98; end
        if ( y == 23 && x == 17) begin oled_data <= 16'h133A; end
        if ( y == 23 && x == 18) begin oled_data <= 16'h1B59; end
        if ( y == 23 && x == 19) begin oled_data <= 16'h0232; end
        if ( y == 23 && x == 20) begin oled_data <= 16'h4373; end
        if ( y == 23 && x == 21) begin oled_data <= 16'h9DD9; end
        if ( y == 23 && x == 22) begin oled_data <= 16'h31E9; end
        if ( y == 24 && x == 12) begin oled_data <= 16'h1947; end
        if ( y == 24 && x == 13) begin oled_data <= 16'h21AC; end
        if ( y == 24 && x == 14) begin oled_data <= 16'h19D0; end
        if ( y == 24 && x == 15) begin oled_data <= 16'h2295; end
        if ( y == 24 && x == 16) begin oled_data <= 16'h2B79; end
        if ( y == 24 && x == 17) begin oled_data <= 16'h3C3C; end
        if ( y == 24 && x == 18) begin oled_data <= 16'h33BA; end
        if ( y == 24 && x == 19) begin oled_data <= 16'h11D0; end
        if ( y == 24 && x == 20) begin oled_data <= 16'h4A8F; end
        if ( y == 24 && x == 21) begin oled_data <= 16'h6AEE; end
        if ( y == 25 && x == 12) begin oled_data <= 16'h2968; end
        if ( y == 25 && x == 13) begin oled_data <= 16'h2149; end
        if ( y == 25 && x == 14) begin oled_data <= 16'h29CD; end
        if ( y == 25 && x == 15) begin oled_data <= 16'h5BD6; end
        if ( y == 25 && x == 16) begin oled_data <= 16'h74FB; end
        if ( y == 25 && x == 17) begin oled_data <= 16'h64DB; end
        if ( y == 25 && x == 18) begin oled_data <= 16'h6CFD; end
        if ( y == 25 && x == 19) begin oled_data <= 16'h3AD3; end
        if ( y == 25 && x == 20) begin oled_data <= 16'h62AF; end
        if ( y == 25 && x == 21) begin oled_data <= 16'h93D2; end
        if ( y == 25 && x == 22) begin oled_data <= 16'h41C8; end
        if ( y == 25 && x == 23) begin oled_data <= 16'h18A2; end
        if ( y == 26 && x == 12) begin oled_data <= 16'h3967; end
        if ( y == 26 && x == 13) begin oled_data <= 16'h3126; end
        if ( y == 26 && x == 14) begin oled_data <= 16'h62AC; end
        if ( y == 26 && x == 15) begin oled_data <= 16'h6B4F; end
        if ( y == 26 && x == 16) begin oled_data <= 16'h6350; end
        if ( y == 26 && x == 17) begin oled_data <= 16'h42CF; end
        if ( y == 26 && x == 18) begin oled_data <= 16'h4352; end
        if ( y == 26 && x == 19) begin oled_data <= 16'h6C37; end
        if ( y == 26 && x == 20) begin oled_data <= 16'h41ED; end
        if ( y == 26 && x == 21) begin oled_data <= 16'h5A6D; end
        if ( y == 26 && x == 22) begin oled_data <= 16'h52AC; end
        if ( y == 27 && x == 10) begin oled_data <= 16'h3A6C; end
        if ( y == 27 && x == 12) begin oled_data <= 16'h2128; end
        if ( y == 27 && x == 13) begin oled_data <= 16'h41C9; end
        if ( y == 27 && x == 14) begin oled_data <= 16'h49C8; end
        if ( y == 27 && x == 16) begin oled_data <= 16'h628A; end
        if ( y == 27 && x == 17) begin oled_data <= 16'hAD35; end
        if ( y == 27 && x == 18) begin oled_data <= 16'h9D16; end
        if ( y == 27 && x == 20) begin oled_data <= 16'h5B10; end
        if ( y == 27 && x == 21) begin oled_data <= 16'h39AA; end
        if ( y == 27 && x == 22) begin oled_data <= 16'h52ED; end
        if ( y == 28 && x == 9) begin oled_data <= 16'h21EA; end
        if ( y == 28 && x == 10) begin oled_data <= 16'h098C; end
        if ( y == 28 && x == 11) begin oled_data <= 16'h19EF; end
        if ( y == 28 && x == 12) begin oled_data <= 16'h2231; end
        if ( y == 28 && x == 13) begin oled_data <= 16'h19AD; end
        if ( y == 28 && x == 14) begin oled_data <= 16'h2947; end
        if ( y == 28 && x == 16) begin oled_data <= 16'hB46F; end
        if ( y == 28 && x == 17) begin oled_data <= 16'hD553; end
        if ( y == 28 && x == 18) begin oled_data <= 16'hC533; end
        if ( y == 28 && x == 19) begin oled_data <= 16'h6ACB; end
        if ( y == 28 && x == 20) begin oled_data <= 16'h632E; end
        if ( y == 28 && x == 21) begin oled_data <= 16'h4AAC; end
        if ( y == 28 && x == 22) begin oled_data <= 16'h2145; end
        if ( y == 29 && x == 8) begin oled_data <= 16'h2A6C; end
        if ( y == 29 && x == 9) begin oled_data <= 16'h5455; end
        if ( y == 29 && x == 10) begin oled_data <= 16'h4C17; end
        if ( y == 29 && x == 11) begin oled_data <= 16'h1232; end
        if ( y == 29 && x == 12) begin oled_data <= 16'h3B78; end
        if ( y == 29 && x == 13) begin oled_data <= 16'h2273; end
        if ( y == 29 && x == 14) begin oled_data <= 16'h092A; end
        if ( y == 29 && x == 15) begin oled_data <= 16'h3188; end
        if ( y == 29 && x == 16) begin oled_data <= 16'hC513; end
        if ( y == 29 && x == 17) begin oled_data <= 16'hE5B3; end
        if ( y == 29 && x == 18) begin oled_data <= 16'hD511; end
        if ( y == 29 && x == 19) begin oled_data <= 16'hCD73; end
        if ( y == 29 && x == 20) begin oled_data <= 16'h7B8E; end
        if ( y == 30 && x == 6) begin oled_data <= 16'h1189; end
        if ( y == 30 && x == 7) begin oled_data <= 16'h122D; end
        if ( y == 30 && x == 8) begin oled_data <= 16'h5497; end
        if ( y == 30 && x >= 9 && x <= 10) begin oled_data <= 16'h969F; end
        if ( y == 30 && x == 11) begin oled_data <= 16'h2AF3; end
        if ( y == 30 && x == 12) begin oled_data <= 16'h22D6; end
        if ( y == 30 && x == 13) begin oled_data <= 16'h1A75; end
        if ( y == 30 && x == 14) begin oled_data <= 16'h1213; end
        if ( y == 30 && x == 15) begin oled_data <= 16'h21CE; end
        if ( y == 30 && x == 16) begin oled_data <= 16'h83D1; end
        if ( y == 30 && x == 17) begin oled_data <= 16'hDDD5; end
        if ( y == 30 && x == 18) begin oled_data <= 16'hCCF0; end
        if ( y == 30 && x == 19) begin oled_data <= 16'hDDD3; end
        if ( y == 30 && x == 20) begin oled_data <= 16'h8BEE; end
        if ( y == 30 && x == 23) begin oled_data <= 16'h2144; end
        if ( y == 30 && x == 24) begin oled_data <= 16'h39E6; end
        if ( y == 30 && x == 25) begin oled_data <= 16'h18E3; end
        if ( y == 31 && x == 5) begin oled_data <= 16'h21A9; end
        if ( y == 31 && x == 6) begin oled_data <= 16'h2A91; end
        if ( y == 31 && x == 7) begin oled_data <= 16'h2B35; end
        if ( y == 31 && x == 8) begin oled_data <= 16'h33D6; end
        if ( y == 31 && x == 9) begin oled_data <= 16'h75BC; end
        if ( y == 31 && x == 10) begin oled_data <= 16'h5456; end
        if ( y == 31 && x == 11) begin oled_data <= 16'h11ED; end
        if ( y == 31 && x == 12) begin oled_data <= 16'h09D0; end
        if ( y == 31 && x == 13) begin oled_data <= 16'h01B2; end
        if ( y == 31 && x == 14) begin oled_data <= 16'h2319; end
        if ( y == 31 && x == 15) begin oled_data <= 16'h2AF7; end
        if ( y == 31 && x == 17) begin oled_data <= 16'h9452; end
        if ( y == 31 && x == 18) begin oled_data <= 16'hACB1; end
        if ( y == 31 && x == 19) begin oled_data <= 16'h7B4A; end
        if ( y == 31 && x == 20) begin oled_data <= 16'h18C2; end
        if ( y == 31 && x == 21) begin oled_data <= 16'h0861; end
        if ( y == 31 && x == 22) begin oled_data <= 16'h73EF; end
        if ( y == 31 && x == 23) begin oled_data <= 16'h8450; end
        if ( y == 31 && x == 24) begin oled_data <= 16'hC678; end
        if ( y == 31 && x == 25) begin oled_data <= 16'h73EE; end
        if ( y == 32 && x == 5) begin oled_data <= 16'h21AA; end
        if ( y == 32 && x == 6) begin oled_data <= 16'h11F1; end
        if ( y == 32 && x == 7) begin oled_data <= 16'h2B17; end
        if ( y == 32 && x == 8) begin oled_data <= 16'h2B56; end
        if ( y == 32 && x == 9) begin oled_data <= 16'h1A90; end
        if ( y == 32 && x == 10) begin oled_data <= 16'h2A4D; end
        if ( y == 32 && x == 11) begin oled_data <= 16'h29EB; end
        if ( y == 32 && x == 12) begin oled_data <= 16'h116C; end
        if ( y == 32 && x == 13) begin oled_data <= 16'h11B1; end
        if ( y == 32 && x == 14) begin oled_data <= 16'h2339; end
        if ( y == 32 && x == 15) begin oled_data <= 16'h2BBB; end
        if ( y == 32 && x == 16) begin oled_data <= 16'h3377; end
        if ( y == 32 && x == 18) begin oled_data <= 16'h4AED; end
        if ( y == 32 && x == 19) begin oled_data <= 16'h2165; end
        if ( y == 32 && x == 21) begin oled_data <= 16'h1987; end
        if ( y == 32 && x == 22) begin oled_data <= 16'h8472; end
        if ( y == 32 && x == 23) begin oled_data <= 16'h632D; end
        if ( y == 32 && x == 24) begin oled_data <= 16'hAD96; end
        if ( y == 32 && x == 25) begin oled_data <= 16'hBE17; end
        if ( y == 32 && x == 26) begin oled_data <= 16'h31C6; end
        if ( y == 33 && x == 5) begin oled_data <= 16'h29EB; end
        if ( y == 33 && x == 6) begin oled_data <= 16'h11AF; end
        if ( y == 33 && x == 7) begin oled_data <= 16'h11F2; end
        if ( y == 33 && x == 8) begin oled_data <= 16'h2251; end
        if ( y == 33 && x == 9) begin oled_data <= 16'h8D5A; end
        if ( y == 33 && x == 10) begin oled_data <= 16'hE77F; end
        if ( y == 33 && x == 11) begin oled_data <= 16'h9D16; end
        if ( y == 33 && x == 12) begin oled_data <= 16'h21CC; end
        if ( y == 33 && x == 13) begin oled_data <= 16'h11AF; end
        if ( y == 33 && x == 14) begin oled_data <= 16'h0213; end
        if ( y == 33 && x == 15) begin oled_data <= 16'h12D7; end
        if ( y == 33 && x == 16) begin oled_data <= 16'h1B15; end
        if ( y == 33 && x == 17) begin oled_data <= 16'h2B13; end
        if ( y == 33 && x == 18) begin oled_data <= 16'h859A; end
        if ( y == 33 && x == 19) begin oled_data <= 16'h4B91; end
        if ( y == 33 && x == 20) begin oled_data <= 16'h228F; end
        if ( y == 33 && x == 21) begin oled_data <= 16'h2A6F; end
        if ( y == 33 && x == 23) begin oled_data <= 16'h634E; end
        if ( y == 33 && x == 24) begin oled_data <= 16'h73CF; end
        if ( y == 33 && x == 25) begin oled_data <= 16'hBE38; end
        if ( y == 33 && x == 26) begin oled_data <= 16'h4248; end
        if ( y == 34 && x == 6) begin oled_data <= 16'h2A2D; end
        if ( y == 34 && x == 7) begin oled_data <= 16'h114B; end
        if ( y == 34 && x == 8) begin oled_data <= 16'h5B71; end
        if ( y == 34 && x == 9) begin oled_data <= 16'hEFBF; end
        if ( y == 34 && x == 10) begin oled_data <= 16'hF7BF; end
        if ( y == 34 && x == 11) begin oled_data <= 16'hBE19; end
        if ( y == 34 && x == 12) begin oled_data <= 16'h42EF; end
        if ( y == 34 && x == 13) begin oled_data <= 16'h6CF9; end
        if ( y == 34 && x == 14) begin oled_data <= 16'h651B; end
        if ( y == 34 && x == 15) begin oled_data <= 16'h2314; end
        if ( y == 34 && x == 16) begin oled_data <= 16'h09ED; end
        if ( y == 34 && x == 17) begin oled_data <= 16'h5436; end
        if ( y == 34 && x == 18) begin oled_data <= 16'hA6BF; end
        if ( y == 34 && x == 19) begin oled_data <= 16'h43F7; end
        if ( y == 34 && x == 20) begin oled_data <= 16'h2B59; end
        if ( y == 34 && x == 21) begin oled_data <= 16'h2B17; end
        if ( y == 34 && x == 22) begin oled_data <= 16'h4B13; end
        if ( y == 34 && x == 23) begin oled_data <= 16'hBE3B; end
        if ( y == 34 && x == 24) begin oled_data <= 16'h73D0; end
        if ( y == 34 && x == 25) begin oled_data <= 16'h73CE; end
        if ( y == 34 && x == 26) begin oled_data <= 16'h2144; end
        if ( y == 35 && x == 6) begin oled_data <= 16'h1947; end
        if ( y == 35 && x == 7) begin oled_data <= 16'h29A9; end
        if ( y == 35 && x == 8) begin oled_data <= 16'h8C93; end
        if ( y == 35 && x == 9) begin oled_data <= 16'hF7FF; end
        if ( y == 35 && x == 10) begin oled_data <= 16'hEF9E; end
        if ( y == 35 && x == 11) begin oled_data <= 16'hA598; end
        if ( y == 35 && x == 12) begin oled_data <= 16'h32F0; end
        if ( y == 35 && x == 13) begin oled_data <= 16'h85BD; end
        if ( y == 35 && x == 14) begin oled_data <= 16'h969F; end
        if ( y == 35 && x == 15) begin oled_data <= 16'h5456; end
        if ( y == 35 && x == 16) begin oled_data <= 16'h0169; end
        if ( y == 35 && x == 17) begin oled_data <= 16'h2AAD; end
        if ( y == 35 && x == 18) begin oled_data <= 16'h5435; end
        if ( y == 35 && x == 19) begin oled_data <= 16'h1251; end
        if ( y == 35 && x == 20) begin oled_data <= 16'h1296; end
        if ( y == 35 && x == 21) begin oled_data <= 16'h1254; end
        if ( y == 35 && x == 22) begin oled_data <= 16'h21EE; end
        if ( y == 35 && x == 23) begin oled_data <= 16'h6BD2; end
        if ( y == 35 && x == 24) begin oled_data <= 16'h8431; end
        if ( y == 35 && x == 25) begin oled_data <= 16'h4248; end
        if ( y == 36 && x == 7) begin oled_data <= 16'h08A3; end
        if ( y == 36 && x == 8) begin oled_data <= 16'h638E; end
        if ( y == 36 && x == 9) begin oled_data <= 16'hBE59; end
        if ( y == 36 && x == 10) begin oled_data <= 16'hBE5A; end
        if ( y == 36 && x == 11) begin oled_data <= 16'h4B10; end
        if ( y == 36 && x == 12) begin oled_data <= 16'h1231; end
        if ( y == 36 && x == 13) begin oled_data <= 16'h2336; end
        if ( y == 36 && x == 14) begin oled_data <= 16'h3376; end
        if ( y == 36 && x == 15) begin oled_data <= 16'h1A6F; end
        if ( y == 36 && x == 18) begin oled_data <= 16'h19A9; end
        if ( y == 36 && x == 20) begin oled_data <= 16'h19CE; end
        if ( y == 36 && x == 21) begin oled_data <= 16'h21CE; end
        if ( y == 36 && x == 22) begin oled_data <= 16'h29CB; end
        if ( y == 36 && x == 23) begin oled_data <= 16'h2167; end
        if ( y == 36 && x == 24) begin oled_data <= 16'h0862; end
        if ( y == 37 && x == 8) begin oled_data <= 16'h2186; end
        if ( y == 37 && x == 9) begin oled_data <= 16'h532D; end
        if ( y == 37 && x == 10) begin oled_data <= 16'h4B6F; end
        if ( y == 37 && x == 11) begin oled_data <= 16'h3B52; end
        if ( y == 37 && x == 12) begin oled_data <= 16'h1273; end
        if ( y == 37 && x == 13) begin oled_data <= 16'h2B78; end
        if ( y == 37 && x == 14) begin oled_data <= 16'h1AF4; end
        if ( y == 37 && x == 15) begin oled_data <= 16'h43F5; end
        if ( y == 37 && x == 16) begin oled_data <= 16'h5412; end
        if ( y == 37 && x == 17) begin oled_data <= 16'h19C9; end
        if ( y == 37 && x == 18) begin oled_data <= 16'h0947; end
        if ( y == 37 && x == 19) begin oled_data <= 16'h1989; end
        if ( y == 37 && x == 20) begin oled_data <= 16'h08C6; end
        if ( y == 37 && x == 21) begin oled_data <= 16'h08A5; end
        if ( y == 38 && x == 8) begin oled_data <= 16'h19A8; end
        if ( y == 38 && x == 9) begin oled_data <= 16'h6C74; end
        if ( y == 38 && x == 10) begin oled_data <= 16'h965C; end
        if ( y == 38 && x == 11) begin oled_data <= 16'h85FD; end
        if ( y == 38 && x == 12) begin oled_data <= 16'h1A92; end
        if ( y == 38 && x == 13) begin oled_data <= 16'h0A11; end
        if ( y == 38 && x == 14) begin oled_data <= 16'h3375; end
        if ( y == 38 && x == 15) begin oled_data <= 16'h8E7F; end
        if ( y == 38 && x == 16) begin oled_data <= 16'h9EBF; end
        if ( y == 38 && x == 17) begin oled_data <= 16'h7DBA; end
        if ( y == 38 && x == 18) begin oled_data <= 16'h22D1; end
        if ( y == 38 && x == 19) begin oled_data <= 16'h32F1; end
        if ( y == 39 && x == 7) begin oled_data <= 16'h08A4; end
        if ( y == 39 && x == 8) begin oled_data <= 16'h2A4D; end
        if ( y == 39 && x == 9) begin oled_data <= 16'h2AF1; end
        if ( y == 39 && x >= 10 && x <= 11) begin oled_data <= 16'h75BC; end
        if ( y == 39 && x == 12) begin oled_data <= 16'h22B1; end
        if ( y == 39 && x == 13) begin oled_data <= 16'h2250; end
        if ( y == 39 && x == 14) begin oled_data <= 16'h3B74; end
        if ( y == 39 && x == 15) begin oled_data <= 16'h64FA; end
        if ( y == 39 && x == 16) begin oled_data <= 16'h75DD; end
        if ( y == 39 && x == 17) begin oled_data <= 16'h3C38; end
        if ( y == 39 && x == 18) begin oled_data <= 16'h1B35; end
        if ( y == 39 && x == 19) begin oled_data <= 16'h3354; end
        if ( y == 40 && x == 6) begin oled_data <= 16'h0883; end
        if ( y == 40 && x == 7) begin oled_data <= 16'h322D; end
        if ( y == 40 && x == 8) begin oled_data <= 16'h11F0; end
        if ( y == 40 && x == 9) begin oled_data <= 16'h0A33; end
        if ( y == 40 && x == 10) begin oled_data <= 16'h2335; end
        if ( y == 40 && x == 11) begin oled_data <= 16'h5498; end
        if ( y == 40 && x == 14) begin oled_data <= 16'h2A4D; end
        if ( y == 40 && x == 15) begin oled_data <= 16'h09CE; end
        if ( y == 40 && x == 16) begin oled_data <= 16'h0232; end
        if ( y == 40 && x == 17) begin oled_data <= 16'h0AD6; end
        if ( y == 40 && x == 18) begin oled_data <= 16'h23DA; end
        if ( y == 40 && x == 19) begin oled_data <= 16'h2334; end
        if ( y == 41 && x == 7) begin oled_data <= 16'h19CF; end
        if ( y == 41 && x == 8) begin oled_data <= 16'h0214; end
        if ( y == 41 && x == 9) begin oled_data <= 16'h237A; end
        if ( y == 41 && x == 10) begin oled_data <= 16'h2377; end
        if ( y == 41 && x == 11) begin oled_data <= 16'h1290; end
        if ( y == 41 && x == 14) begin oled_data <= 16'h322D; end
        if ( y == 41 && x == 15) begin oled_data <= 16'h09AF; end
        if ( y == 41 && x == 16) begin oled_data <= 16'h0A76; end
        if ( y == 41 && x == 17) begin oled_data <= 16'h23BC; end
        if ( y == 41 && x == 18) begin oled_data <= 16'h1BDA; end
        if ( y == 41 && x == 19) begin oled_data <= 16'h2B75; end
        if ( y == 42 && x == 5) begin oled_data <= 16'h2168; end
        if ( y == 42 && x == 6) begin oled_data <= 16'h21EF; end
        if ( y == 42 && x == 7) begin oled_data <= 16'h09D2; end
        if ( y == 42 && x == 8) begin oled_data <= 16'h133B; end
        if ( y == 42 && x == 9) begin oled_data <= 16'h1BDC; end
        if ( y == 42 && x == 10) begin oled_data <= 16'h23D9; end
        if ( y == 42 && x == 11) begin oled_data <= 16'h0A50; end
        if ( y == 42 && x == 14) begin oled_data <= 16'h198E; end
        if ( y == 42 && x == 15) begin oled_data <= 16'h09B2; end
        if ( y == 42 && x == 16) begin oled_data <= 16'h0AF9; end
        if ( y == 42 && x == 17) begin oled_data <= 16'h1BDC; end
        if ( y == 42 && x == 18) begin oled_data <= 16'h23B9; end
        if ( y == 42 && x == 19) begin oled_data <= 16'h3354; end
        if ( y == 43 && x == 4) begin oled_data <= 16'h0883; end
        if ( y == 43 && x == 5) begin oled_data <= 16'h322D; end
        if ( y == 43 && x == 6) begin oled_data <= 16'h09B0; end
        if ( y == 43 && x == 7) begin oled_data <= 16'h0A97; end
        if ( y == 43 && x == 8) begin oled_data <= 16'h13DD; end
        if ( y == 43 && x == 9) begin oled_data <= 16'h13DC; end
        if ( y == 43 && x == 10) begin oled_data <= 16'h23D8; end
        if ( y == 43 && x == 14) begin oled_data <= 16'h198F; end
        if ( y == 43 && x == 15) begin oled_data <= 16'h09D4; end
        if ( y == 43 && x == 16) begin oled_data <= 16'h131B; end
        if ( y == 43 && x == 17) begin oled_data <= 16'h137B; end
        if ( y == 43 && x == 18) begin oled_data <= 16'h1B57; end
        if ( y == 43 && x == 19) begin oled_data <= 16'h09ED; end
        if ( y == 44 && x == 4) begin oled_data <= 16'h2168; end
        if ( y == 44 && x == 5) begin oled_data <= 16'h21CD; end
        if ( y == 44 && x == 6) begin oled_data <= 16'h09F3; end
        if ( y == 44 && x == 7) begin oled_data <= 16'h133B; end
        if ( y == 44 && x == 8) begin oled_data <= 16'h0BFE; end
        if ( y == 44 && x == 9) begin oled_data <= 16'h13DC; end
        if ( y == 44 && x == 10) begin oled_data <= 16'h33B6; end
        if ( y == 44 && x == 11) begin oled_data <= 16'h014A; end
        if ( y == 44 && x == 13) begin oled_data <= 16'h29AA; end
        if ( y == 44 && x == 14) begin oled_data <= 16'h196E; end
        if ( y == 44 && x == 15) begin oled_data <= 16'h11D3; end
        if ( y == 44 && x == 16) begin oled_data <= 16'h0257; end
        if ( y == 44 && x == 17) begin oled_data <= 16'h02B8; end
        if ( y == 44 && x == 18) begin oled_data <= 16'h12D5; end
        if ( y == 44 && x == 19) begin oled_data <= 16'h124F; end
        if ( y == 45 && x == 3) begin oled_data <= 16'h29A9; end
        if ( y == 45 && x == 4) begin oled_data <= 16'h29EE; end
        if ( y == 45 && x == 5) begin oled_data <= 16'h016F; end
        if ( y == 45 && x == 6) begin oled_data <= 16'h0235; end
        if ( y == 45 && x == 7) begin oled_data <= 16'h1BBC; end
        if ( y == 45 && x == 8) begin oled_data <= 16'h13DD; end
        if ( y == 45 && x == 9) begin oled_data <= 16'h1BDA; end
        if ( y == 45 && x == 10) begin oled_data <= 16'h2B12; end
        if ( y == 45 && x == 13) begin oled_data <= 16'h29CA; end
        if ( y == 45 && x == 14) begin oled_data <= 16'h114D; end
        if ( y == 45 && x == 15) begin oled_data <= 16'h09B2; end
        if ( y == 45 && x == 16) begin oled_data <= 16'h0A77; end
        if ( y == 45 && x == 17) begin oled_data <= 16'h23BC; end
        if ( y == 45 && x == 18) begin oled_data <= 16'h2399; end
        if ( y == 45 && x == 19) begin oled_data <= 16'h2B34; end
        if ( y == 46 && x == 2) begin oled_data <= 16'h29EB; end
        if ( y == 46 && x == 3) begin oled_data <= 16'h2A2F; end
        if ( y == 46 && x == 4) begin oled_data <= 16'h09B1; end
        if ( y == 46 && x == 5) begin oled_data <= 16'h1277; end
        if ( y == 46 && x == 6) begin oled_data <= 16'h0AB8; end
        if ( y == 46 && x == 7) begin oled_data <= 16'h02F8; end
        if ( y == 46 && x == 8) begin oled_data <= 16'h1BBA; end
        if ( y == 46 && x == 9) begin oled_data <= 16'h2BB7; end
        if ( y == 46 && x == 10) begin oled_data <= 16'h11AA; end
        if ( y == 46 && x == 13) begin oled_data <= 16'h3A2B; end
        if ( y == 46 && x == 14) begin oled_data <= 16'h21CE; end
        if ( y == 46 && x == 15) begin oled_data <= 16'h09D2; end
        if ( y == 46 && x == 16) begin oled_data <= 16'h0A99; end
        if ( y == 46 && x == 17) begin oled_data <= 16'h1B9E; end
        if ( y == 46 && x == 18) begin oled_data <= 16'h13DD; end
        if ( y == 46 && x == 19) begin oled_data <= 16'h2398; end
        if ( y == 46 && x == 20) begin oled_data <= 16'h19EC; end
        if ( y == 47 && x == 1) begin oled_data <= 16'h3A2A; end
        if ( y == 47 && x == 3) begin oled_data <= 16'h11AF; end
        if ( y == 47 && x == 4) begin oled_data <= 16'h1296; end
        if ( y == 47 && x == 5) begin oled_data <= 16'h239C; end
        if ( y == 47 && x == 6) begin oled_data <= 16'h23DC; end
        if ( y == 47 && x == 7) begin oled_data <= 16'h0B18; end
        if ( y == 47 && x == 8) begin oled_data <= 16'h0AB5; end
        if ( y == 47 && x == 9) begin oled_data <= 16'h1A91; end
        if ( y == 47 && x == 13) begin oled_data <= 16'h08A4; end
        if ( y == 47 && x == 14) begin oled_data <= 16'h322D; end
        if ( y == 47 && x == 15) begin oled_data <= 16'h2251; end
        if ( y == 47 && x == 16) begin oled_data <= 16'h0A35; end
        if ( y == 47 && x == 17) begin oled_data <= 16'h131A; end
        if ( y == 47 && x == 18) begin oled_data <= 16'h1BFD; end
        if ( y == 47 && x == 19) begin oled_data <= 16'h23B9; end
        if ( y == 47 && x == 20) begin oled_data <= 16'h2A8F; end
        if ( y == 48 && x == 0) begin oled_data <= 16'h2187; end
        if ( y == 48 && x == 2) begin oled_data <= 16'h114C; end
        if ( y == 48 && x == 3) begin oled_data <= 16'h19F1; end
        if ( y == 48 && x == 4) begin oled_data <= 16'h2358; end
        if ( y == 48 && x == 5) begin oled_data <= 16'h23BB; end
        if ( y == 48 && x == 6) begin oled_data <= 16'h1BDA; end
        if ( y == 48 && x == 7) begin oled_data <= 16'h23D9; end
        if ( y == 48 && x == 8) begin oled_data <= 16'h2335; end
        if ( y == 48 && x == 15) begin oled_data <= 16'h1969; end
        if ( y == 48 && x == 16) begin oled_data <= 16'h222F; end
        if ( y == 48 && x == 17) begin oled_data <= 16'h22B3; end
        if ( y == 48 && x == 18) begin oled_data <= 16'h2377; end
        if ( y == 48 && x == 19) begin oled_data <= 16'h2B96; end
        if ( y == 48 && x == 20) begin oled_data <= 16'h3AF0; end
        if ( y == 49 && x == 0) begin oled_data <= 16'h29A8; end
        if ( y == 49 && x == 1) begin oled_data <= 16'h3A2D; end
        if ( y == 49 && x == 2) begin oled_data <= 16'h2A10; end
        if ( y == 49 && x == 3) begin oled_data <= 16'h2253; end
        if ( y == 49 && x == 4) begin oled_data <= 16'h1B17; end
        if ( y == 49 && x >= 5 && x <= 6) begin oled_data <= 16'h1358; end
        if ( y == 49 && x == 7) begin oled_data <= 16'h1336; end
        if ( y == 49 && x == 8) begin oled_data <= 16'h2B34; end
        if ( y == 49 && x == 17) begin oled_data <= 16'h012A; end
        if ( y == 49 && x == 18) begin oled_data <= 16'h0A51; end
        if ( y == 49 && x == 19) begin oled_data <= 16'h22F3; end
        if ( y == 49 && x == 20) begin oled_data <= 16'h2A6D; end
        
        //mario image
        //draw clothes
        if (((pixel_index % 96 > 78 && pixel_index % 96 < 89) &&(pixel_index / 96 > 18 && pixel_index / 96 < 21)) || 
            ((pixel_index % 96 > 72 && pixel_index % 96 < 91) &&(pixel_index / 96 > 20 && pixel_index / 96 < 23)) ||
            ((pixel_index % 96 > 84 && pixel_index % 96 < 87) &&(pixel_index / 96 > 32 && pixel_index / 96 < 37)) ||
            ((pixel_index % 96 > 78 && pixel_index % 96 < 81) &&(pixel_index / 96 > 34 && pixel_index / 96 < 37)) ||
            ((pixel_index % 96 > 78 && pixel_index % 96 < 87) &&(pixel_index / 96 > 36 && pixel_index / 96 < 39)) ||
            ((pixel_index % 96 > 76 && pixel_index % 96 < 79) &&(pixel_index / 96 > 38 && pixel_index / 96 < 41)) ||
            ((pixel_index % 96 > 80 && pixel_index % 96 < 85) &&(pixel_index / 96 > 38 && pixel_index / 96 < 41)) ||
            ((pixel_index % 96 > 86 && pixel_index % 96 < 89) &&(pixel_index / 96 > 38 && pixel_index / 96 < 41)) ||
            ((pixel_index % 96 > 76 && pixel_index % 96 < 89) &&(pixel_index / 96 > 40 && pixel_index / 96 < 43)) ||
            ((pixel_index % 96 > 74 && pixel_index % 96 < 91) &&(pixel_index / 96 > 42 && pixel_index / 96 < 45)) ||
            ((pixel_index % 96 > 74 && pixel_index % 96 < 81) &&(pixel_index / 96 > 44 && pixel_index / 96 < 47)) ||
            ((pixel_index % 96 > 84 && pixel_index % 96 < 91) &&(pixel_index / 96 > 44 && pixel_index / 96 < 47)))
            oled_data <= 16'hE8A0;
        //draw hair, body and legs    
        else if (((pixel_index % 96 > 78 && pixel_index % 96 < 81) &&(pixel_index / 96 > 22 && pixel_index / 96 < 27)) ||
                 ((pixel_index % 96 > 84 && pixel_index % 96 < 91) &&(pixel_index / 96 > 22 && pixel_index / 96 < 25)) ||
                 ((pixel_index % 96 > 86 && pixel_index % 96 < 89) &&(pixel_index / 96 > 24 && pixel_index / 96 < 29)) ||
                ((pixel_index % 96 > 84 && pixel_index % 96 < 87) &&(pixel_index / 96 > 26 && pixel_index / 96 < 29)) ||
                ((pixel_index % 96 > 90 && pixel_index % 96 < 93) &&(pixel_index / 96 > 24 && pixel_index / 96 < 31)) ||
                ((pixel_index % 96 > 88 && pixel_index % 96 < 91) &&(pixel_index / 96 > 28 && pixel_index / 96 < 31)) ||
                ((pixel_index % 96 > 72 && pixel_index % 96 < 81) &&(pixel_index / 96 > 28 && pixel_index / 96 < 31)) ||
                ((pixel_index % 96 > 76 && pixel_index % 96 < 79) &&(pixel_index / 96 > 26 && pixel_index / 96 < 29)) ||
                ((pixel_index % 96 > 78 && pixel_index % 96 < 85) &&(pixel_index / 96 > 32 && pixel_index / 96 < 35)) ||
                ((pixel_index % 96 > 80 && pixel_index % 96 < 85) &&(pixel_index / 96 > 34 && pixel_index / 96 < 37)) ||
                ((pixel_index % 96 > 86 && pixel_index % 96 < 91) &&(pixel_index / 96 > 32 && pixel_index / 96 < 39)) ||
                ((pixel_index % 96 > 90 && pixel_index % 96 < 93) &&(pixel_index / 96 > 34 && pixel_index / 96 < 39)) ||
                ((pixel_index % 96 > 92 && pixel_index % 96 < 95) &&(pixel_index / 96 > 36 && pixel_index / 96 < 39)) ||
                ((pixel_index % 96 > 88 && pixel_index % 96 < 91) &&(pixel_index / 96 > 38 && pixel_index / 96 < 41)) ||
                ((pixel_index % 96 > 72 && pixel_index % 96 < 79) &&(pixel_index / 96 > 34 && pixel_index / 96 < 39)) ||
                ((pixel_index % 96 > 70 && pixel_index % 96 < 73) &&(pixel_index / 96 > 36 && pixel_index / 96 < 39)) ||
                ((pixel_index % 96 > 74 && pixel_index % 96 < 77) &&(pixel_index / 96 > 38 && pixel_index / 96 < 41)) ||
                ((pixel_index % 96 > 72 && pixel_index % 96 < 79) &&(pixel_index / 96 > 46 && pixel_index / 96 < 51)) || 
                ((pixel_index % 96 > 70 && pixel_index % 96 < 73) &&(pixel_index / 96 > 48 && pixel_index / 96 < 51)) ||
                ((pixel_index % 96 > 86 && pixel_index % 96 < 93) &&(pixel_index / 96 > 46 && pixel_index / 96 < 51)) ||
                ((pixel_index % 96 > 92 && pixel_index % 96 < 95) &&(pixel_index / 96 > 48 && pixel_index / 96 < 51)))
                oled_data <= 16'h7320;
        //draw face and arms
        else if (((pixel_index % 96 > 70 && pixel_index % 96 < 73) &&(pixel_index / 96 > 26 && pixel_index / 96 < 29)) ||
                ((pixel_index % 96 > 72 && pixel_index % 96 < 77) &&(pixel_index / 96 > 24 && pixel_index / 96 < 29)) ||
                ((pixel_index % 96 > 76 && pixel_index % 96 < 79) &&(pixel_index / 96 > 22 && pixel_index / 96 < 27)) ||
                ((pixel_index % 96 > 78 && pixel_index % 96 < 81) &&(pixel_index / 96 > 26 && pixel_index / 96 < 29)) ||
                ((pixel_index % 96 > 80 && pixel_index % 96 < 85) &&(pixel_index / 96 > 22 && pixel_index / 96 < 31)) ||
                ((pixel_index % 96 > 84 && pixel_index % 96 < 87) &&(pixel_index / 96 > 24 && pixel_index / 96 < 27)) ||
                ((pixel_index % 96 > 88 && pixel_index % 96 < 91) &&(pixel_index / 96 > 24 && pixel_index / 96 < 29)) ||
                ((pixel_index % 96 > 84 && pixel_index % 96 < 89) &&(pixel_index / 96 > 28 && pixel_index / 96 < 31)) ||
                ((pixel_index % 96 > 74 && pixel_index % 96 < 89) &&(pixel_index / 96 > 30 && pixel_index / 96 < 33)) ||
                ((pixel_index % 96 > 70 && pixel_index % 96 < 75) &&(pixel_index / 96 > 38 && pixel_index / 96 < 45)) ||
                ((pixel_index % 96 > 74 && pixel_index % 96 < 77) &&(pixel_index / 96 > 40 && pixel_index / 96 < 43)) ||
                ((pixel_index % 96 > 78 && pixel_index % 96 < 81) &&(pixel_index / 96 > 38 && pixel_index / 96 < 41)) ||
                ((pixel_index % 96 > 84 && pixel_index % 96 < 87) &&(pixel_index / 96 > 38 && pixel_index / 96 < 41)) ||
                ((pixel_index % 96 > 88 && pixel_index % 96 < 91) &&(pixel_index / 96 > 40 && pixel_index / 96 < 43)) ||
                ((pixel_index % 96 > 90 && pixel_index % 96 < 95) &&(pixel_index / 96 > 38 && pixel_index / 96 < 45)))
                oled_data <= 16'hFD40;        
                
         
            if(led_count >= led_count2)
                begin
                //megaman shooting stance
                if ( y >= 20 && y <= 50 && x >= 0 && x <= 27) begin oled_data <= 16'h0000; end 
                if ( y == 20 && x == 10) begin oled_data <= 16'h21AA; end
                if ( y == 20 && x == 11) begin oled_data <= 16'h116A; end
                if ( y == 20 && x == 12) begin oled_data <= 16'h32D0; end
                if ( y == 20 && x == 13) begin oled_data <= 16'h4BF4; end
                if ( y == 20 && x == 14) begin oled_data <= 16'h3B92; end
                if ( y == 20 && x == 15) begin oled_data <= 16'h224B; end
                if ( y == 21 && x == 10) begin oled_data <= 16'h198C; end
                if ( y == 21 && x == 11) begin oled_data <= 16'h11CF; end
                if ( y == 21 && x == 12) begin oled_data <= 16'h1251; end
                if ( y == 21 && x == 13) begin oled_data <= 16'h1AD2; end
                if ( y == 21 && x == 14) begin oled_data <= 16'h4C16; end
                if ( y == 21 && x == 15) begin oled_data <= 16'h85BA; end
                if ( y == 21 && x == 16) begin oled_data <= 16'h5390; end
                if ( y == 22 && x == 8) begin oled_data <= 16'h29AA; end
                if ( y == 22 && x == 9) begin oled_data <= 16'h198D; end
                if ( y == 22 && x == 10) begin oled_data <= 16'h11B3; end
                if ( y == 22 && x == 11) begin oled_data <= 16'h1257; end
                if ( y == 22 && x == 12) begin oled_data <= 16'h239B; end
                if ( y == 22 && x == 13) begin oled_data <= 16'h2399; end
                if ( y == 22 && x == 14) begin oled_data <= 16'h0A73; end
                if ( y == 22 && x == 15) begin oled_data <= 16'h43F7; end
                if ( y == 22 && x == 16) begin oled_data <= 16'h9E7D; end
                if ( y == 22 && x == 17) begin oled_data <= 16'h32AC; end
                if ( y == 23 && x == 8) begin oled_data <= 16'h29CC; end
                if ( y == 23 && x == 9) begin oled_data <= 16'h198F; end
                if ( y == 23 && x == 10) begin oled_data <= 16'h11F5; end
                if ( y == 23 && x == 11) begin oled_data <= 16'h0217; end
                if ( y == 23 && x == 12) begin oled_data <= 16'h0AF9; end
                if ( y == 23 && x == 13) begin oled_data <= 16'h1359; end
                if ( y == 23 && x == 14) begin oled_data <= 16'h12B6; end
                if ( y == 23 && x == 15) begin oled_data <= 16'h1211; end
                if ( y == 23 && x == 16) begin oled_data <= 16'h8519; end
                if ( y == 23 && x == 17) begin oled_data <= 16'h6C12; end
                if ( y == 23 && x == 18) begin oled_data <= 16'h0882; end
                if ( y == 24 && x == 7) begin oled_data <= 16'h2988; end
                if ( y == 24 && x == 8) begin oled_data <= 16'h29AC; end
                if ( y == 24 && x == 9) begin oled_data <= 16'h198E; end
                if ( y == 24 && x == 10) begin oled_data <= 16'h1A33; end
                if ( y == 24 && x == 11) begin oled_data <= 16'h2B39; end
                if ( y == 24 && x == 12) begin oled_data <= 16'h341B; end
                if ( y == 24 && x == 13) begin oled_data <= 16'h447C; end
                if ( y == 24 && x == 14) begin oled_data <= 16'h1A95; end
                if ( y == 24 && x == 15) begin oled_data <= 16'h29F0; end
                if ( y == 24 && x == 16) begin oled_data <= 16'h72EF; end
                if ( y == 24 && x == 17) begin oled_data <= 16'h6229; end
                if ( y == 25 && x == 7) begin oled_data <= 16'h31C8; end
                if ( y == 25 && x == 8) begin oled_data <= 16'h2949; end
                if ( y == 25 && x == 9) begin oled_data <= 16'h214A; end
                if ( y == 25 && x == 10) begin oled_data <= 16'h4313; end
                if ( y == 25 && x == 11) begin oled_data <= 16'h6CBA; end
                if ( y == 25 && x == 12) begin oled_data <= 16'h6CFB; end
                if ( y == 25 && x == 13) begin oled_data <= 16'h6CDB; end
                if ( y == 25 && x == 14) begin oled_data <= 16'h5C3A; end
                if ( y == 25 && x == 15) begin oled_data <= 16'h29AE; end
                if ( y == 25 && x == 16) begin oled_data <= 16'hA414; end
                if ( y == 25 && x == 17) begin oled_data <= 16'h724A; end
                if ( y == 25 && x == 18) begin oled_data <= 16'h28C4; end
                if ( y == 26 && x == 7) begin oled_data <= 16'h39A7; end
                if ( y == 26 && x == 9) begin oled_data <= 16'h51A8; end
                if ( y == 26 && x == 10) begin oled_data <= 16'h6B70; end
                if ( y == 26 && x == 11) begin oled_data <= 16'h5B2F; end
                if ( y == 26 && x == 13) begin oled_data <= 16'h3A8E; end
                if ( y == 26 && x == 14) begin oled_data <= 16'h6437; end
                if ( y == 26 && x == 15) begin oled_data <= 16'h4B13; end
                if ( y == 26 && x == 16) begin oled_data <= 16'h49EC; end
                if ( y == 26 && x == 17) begin oled_data <= 16'h628D; end
                if ( y == 26 && x == 18) begin oled_data <= 16'h3187; end
                if ( y == 27 && x == 7) begin oled_data <= 16'h3166; end
                if ( y == 27 && x == 8) begin oled_data <= 16'h4946; end
                if ( y == 27 && x == 9) begin oled_data <= 16'h59C8; end
                if ( y == 27 && x == 10) begin oled_data <= 16'h3125; end
                if ( y == 27 && x == 11) begin oled_data <= 16'h39A6; end
                if ( y == 27 && x == 13) begin oled_data <= 16'hCDF8; end
                if ( y == 27 && x == 14) begin oled_data <= 16'h5B71; end
                if ( y == 27 && x == 15) begin oled_data <= 16'h5B92; end
                if ( y == 27 && x == 16) begin oled_data <= 16'h39EC; end
                if ( y == 27 && x == 17) begin oled_data <= 16'h528D; end
                if ( y == 27 && x == 18) begin oled_data <= 16'h31A8; end
                if ( y == 28 && x == 7) begin oled_data <= 16'h31C8; end
                if ( y == 28 && x >= 8 && x <= 9) begin oled_data <= 16'h2948; end
                if ( y == 28 && x == 11) begin oled_data <= 16'h72EB; end
                if ( y == 28 && x == 12) begin oled_data <= 16'hD552; end
                if ( y == 28 && x == 13) begin oled_data <= 16'hD593; end
                if ( y == 28 && x == 14) begin oled_data <= 16'h838D; end
                if ( y == 28 && x == 16) begin oled_data <= 16'h4A8C; end
                if ( y == 28 && x == 17) begin oled_data <= 16'h31C9; end
                if ( y == 29 && x == 8) begin oled_data <= 16'h2A4F; end
                if ( y == 29 && x == 9) begin oled_data <= 16'h3290; end
                if ( y == 29 && x == 10) begin oled_data <= 16'h1927; end
                if ( y == 29 && x == 11) begin oled_data <= 16'h83AE; end
                if ( y == 29 && x == 12) begin oled_data <= 16'hEDF4; end
                if ( y == 29 && x == 13) begin oled_data <= 16'hDD30; end
                if ( y == 29 && x == 14) begin oled_data <= 16'hD531; end
                if ( y == 29 && x == 15) begin oled_data <= 16'hACB1; end
                if ( y == 29 && x == 16) begin oled_data <= 16'h4249; end
                if ( y == 29 && x == 18) begin oled_data <= 16'h29A7; end
                if ( y == 29 && x == 19) begin oled_data <= 16'h08C4; end
                if ( y == 30 && x == 6) begin oled_data <= 16'h196A; end
                if ( y == 30 && x == 7) begin oled_data <= 16'h2A70; end
                if ( y == 30 && x == 8) begin oled_data <= 16'h3398; end
                if ( y == 30 && x == 9) begin oled_data <= 16'h22F5; end
                if ( y == 30 && x == 10) begin oled_data <= 16'h19EC; end
                if ( y == 30 && x == 11) begin oled_data <= 16'h4A49; end
                if ( y == 30 && x == 12) begin oled_data <= 16'hDDB4; end
                if ( y == 30 && x == 13) begin oled_data <= 16'hDD30; end
                if ( y == 30 && x == 14) begin oled_data <= 16'hE592; end
                if ( y == 30 && x == 15) begin oled_data <= 16'hBCF0; end
                if ( y == 30 && x == 16) begin oled_data <= 16'h4246; end
                if ( y == 30 && x == 17) begin oled_data <= 16'h534C; end
                if ( y == 30 && x == 19) begin oled_data <= 16'h42EE; end
                if ( y == 30 && x == 20) begin oled_data <= 16'h09AB; end
                if ( y == 30 && x == 24) begin oled_data <= 16'h08C4; end
                if ( y == 31 && x == 6) begin oled_data <= 16'h21CB; end
                if ( y == 31 && x == 7) begin oled_data <= 16'h2A91; end
                if ( y == 31 && x == 8) begin oled_data <= 16'h12B5; end
                if ( y == 31 && x == 9) begin oled_data <= 16'h2B98; end
                if ( y == 31 && x == 10) begin oled_data <= 16'h85BC; end
                if ( y == 31 && x == 11) begin oled_data <= 16'h326C; end
                if ( y == 31 && x == 12) begin oled_data <= 16'h62CB; end
                if ( y == 31 && x == 13) begin oled_data <= 16'hBD13; end
                if ( y == 31 && x == 14) begin oled_data <= 16'h836D; end
                if ( y == 31 && x == 16) begin oled_data <= 16'h29C4; end
                if ( y == 31 && x == 17) begin oled_data <= 16'h19A5; end
                if ( y == 31 && x == 18) begin oled_data <= 16'h2A2C; end
                if ( y == 31 && x == 19) begin oled_data <= 16'h2270; end
                if ( y == 31 && x == 20) begin oled_data <= 16'h2B33; end
                if ( y == 31 && x == 21) begin oled_data <= 16'h2B55; end
                if ( y == 31 && x == 22) begin oled_data <= 16'h3354; end
                if ( y == 31 && x == 23) begin oled_data <= 16'h2A8F; end
                if ( y == 31 && x == 25) begin oled_data <= 16'h2924; end
                if ( y == 32 && x == 6) begin oled_data <= 16'h2168; end
                if ( y == 32 && x == 7) begin oled_data <= 16'h2A2D; end
                if ( y == 32 && x == 8) begin oled_data <= 16'h09CE; end
                if ( y == 32 && x == 9) begin oled_data <= 16'h4418; end
                if ( y == 32 && x == 10) begin oled_data <= 16'h969F; end
                if ( y == 32 && x == 11) begin oled_data <= 16'h861D; end
                if ( y == 32 && x == 12) begin oled_data <= 16'h1A2D; end
                if ( y == 32 && x == 13) begin oled_data <= 16'h2A4F; end
                if ( y == 32 && x == 14) begin oled_data <= 16'h1A2F; end
                if ( y == 32 && x == 16) begin oled_data <= 16'h11C7; end
                if ( y == 32 && x == 17) begin oled_data <= 16'h11C8; end
                if ( y == 32 && x == 18) begin oled_data <= 16'h1210; end
                if ( y == 32 && x == 19) begin oled_data <= 16'h22B5; end
                if ( y == 32 && x == 20) begin oled_data <= 16'h6D7F; end
                if ( y == 32 && x == 21) begin oled_data <= 16'h8E9F; end
                if ( y == 32 && x == 22) begin oled_data <= 16'h4C59; end
                if ( y == 32 && x == 23) begin oled_data <= 16'h1A2E; end
                if ( y == 32 && x == 25) begin oled_data <= 16'h41A5; end
                if ( y == 33 && x == 7) begin oled_data <= 16'h1988; end
                if ( y == 33 && x == 8) begin oled_data <= 16'h2A8F; end
                if ( y == 33 && x == 9) begin oled_data <= 16'h2AD1; end
                if ( y == 33 && x == 10) begin oled_data <= 16'h5498; end
                if ( y == 33 && x == 11) begin oled_data <= 16'h5CFA; end
                if ( y == 33 && x == 12) begin oled_data <= 16'h1A93; end
                if ( y == 33 && x == 13) begin oled_data <= 16'h2B57; end
                if ( y == 33 && x == 14) begin oled_data <= 16'h3399; end
                if ( y == 33 && x == 15) begin oled_data <= 16'h2B35; end
                if ( y == 33 && x == 16) begin oled_data <= 16'h1A2A; end
                if ( y == 33 && x == 17) begin oled_data <= 16'h19C9; end
                if ( y == 33 && x == 18) begin oled_data <= 16'h11B0; end
                if ( y == 33 && x == 19) begin oled_data <= 16'h1234; end
                if ( y == 33 && x == 20) begin oled_data <= 16'h43D9; end
                if ( y == 33 && x == 21) begin oled_data <= 16'h5CBC; end
                if ( y == 33 && x == 22) begin oled_data <= 16'h3356; end
                if ( y == 33 && x == 23) begin oled_data <= 16'h098C; end
                if ( y == 33 && x == 24) begin oled_data <= 16'h2926; end
                if ( y == 33 && x == 25) begin oled_data <= 16'h49E6; end
                if ( y == 34 && x == 8) begin oled_data <= 16'h3ACE; end
                if ( y == 34 && x == 9) begin oled_data <= 16'h5C15; end
                if ( y == 34 && x == 10) begin oled_data <= 16'h2B12; end
                if ( y == 34 && x == 11) begin oled_data <= 16'h1A72; end
                if ( y == 34 && x == 12) begin oled_data <= 16'h0A14; end
                if ( y == 34 && x == 13) begin oled_data <= 16'h1A77; end
                if ( y == 34 && x == 14) begin oled_data <= 16'h1257; end
                if ( y == 34 && x == 15) begin oled_data <= 16'h1A33; end
                if ( y == 34 && x == 16) begin oled_data <= 16'h19CB; end
                if ( y == 34 && x == 17) begin oled_data <= 16'h21CA; end
                if ( y == 34 && x == 18) begin oled_data <= 16'h198D; end
                if ( y == 34 && x == 19) begin oled_data <= 16'h1190; end
                if ( y == 34 && x == 20) begin oled_data <= 16'h0990; end
                if ( y == 34 && x == 21) begin oled_data <= 16'h0970; end
                if ( y == 34 && x == 22) begin oled_data <= 16'h11AF; end
                if ( y == 34 && x == 23) begin oled_data <= 16'h194B; end
                if ( y == 34 && x == 25) begin oled_data <= 16'h41C6; end
                if ( y == 35 && x == 8) begin oled_data <= 16'h19A8; end
                if ( y == 35 && x == 9) begin oled_data <= 16'h53B3; end
                if ( y == 35 && x == 10) begin oled_data <= 16'h5C17; end
                if ( y == 35 && x == 11) begin oled_data <= 16'h1212; end
                if ( y == 35 && x == 12) begin oled_data <= 16'h0194; end
                if ( y == 35 && x == 13) begin oled_data <= 16'h09B6; end
                if ( y == 35 && x == 14) begin oled_data <= 16'h09B4; end
                if ( y == 35 && x == 15) begin oled_data <= 16'h19D1; end
                if ( y == 35 && x == 16) begin oled_data <= 16'h218B; end
                if ( y == 35 && x == 17) begin oled_data <= 16'h29A9; end
                if ( y == 35 && x == 18) begin oled_data <= 16'h29AB; end
                if ( y == 35 && x == 19) begin oled_data <= 16'h218C; end
                if ( y == 35 && x == 20) begin oled_data <= 16'h218E; end
                if ( y == 35 && x == 21) begin oled_data <= 16'h198E; end
                if ( y == 35 && x == 22) begin oled_data <= 16'h218D; end
                if ( y == 35 && x == 23) begin oled_data <= 16'h216A; end
                if ( y == 35 && x == 24) begin oled_data <= 16'h2966; end
                if ( y == 35 && x == 25) begin oled_data <= 16'h39A6; end
                if ( y == 36 && x == 9) begin oled_data <= 16'h21EB; end
                if ( y == 36 && x == 10) begin oled_data <= 16'h19EF; end
                if ( y == 36 && x == 11) begin oled_data <= 16'h11D3; end
                if ( y == 36 && x >= 12 && x <= 13) begin oled_data <= 16'h09B6; end
                if ( y == 36 && x == 14) begin oled_data <= 16'h0971; end
                if ( y == 36 && x == 15) begin oled_data <= 16'h21EE; end
                if ( y == 36 && x == 19) begin oled_data <= 16'h2988; end
                if ( y == 36 && x == 20) begin oled_data <= 16'h29AA; end
                if ( y == 36 && x == 21) begin oled_data <= 16'h298A; end
                if ( y == 36 && x == 22) begin oled_data <= 16'h29A9; end
                if ( y == 36 && x == 23) begin oled_data <= 16'h2988; end
                if ( y == 36 && x == 24) begin oled_data <= 16'h18A3; end
                if ( y == 37 && x == 9) begin oled_data <= 16'h2A2C; end
                if ( y == 37 && x == 10) begin oled_data <= 16'h2230; end
                if ( y == 37 && x == 11) begin oled_data <= 16'h09B1; end
                if ( y == 37 && x >= 12 && x <= 13) begin oled_data <= 16'h1216; end
                if ( y == 37 && x == 14) begin oled_data <= 16'h1A11; end
                if ( y == 37 && x == 15) begin oled_data <= 16'h328F; end
                if ( y == 37 && x == 16) begin oled_data <= 16'h08E5; end
                if ( y == 38 && x == 8) begin oled_data <= 16'h2A2B; end
                if ( y == 38 && x == 9) begin oled_data <= 16'h4BD3; end
                if ( y == 38 && x == 10) begin oled_data <= 16'h85FE; end
                if ( y == 38 && x == 11) begin oled_data <= 16'h4419; end
                if ( y == 38 && x >= 12 && x <= 13) begin oled_data <= 16'h09F3; end
                if ( y == 38 && x == 14) begin oled_data <= 16'h3B97; end
                if ( y == 38 && x == 15) begin oled_data <= 16'h8E3E; end
                if ( y == 38 && x == 16) begin oled_data <= 16'h53D2; end
                if ( y == 38 && x == 17) begin oled_data <= 16'h1166; end
                if ( y == 39 && x == 7) begin oled_data <= 16'h08E5; end
                if ( y == 39 && x == 8) begin oled_data <= 16'h1A2E; end
                if ( y == 39 && x == 9) begin oled_data <= 16'h4C17; end
                if ( y == 39 && x == 10) begin oled_data <= 16'h8E7F; end
                if ( y == 39 && x == 11) begin oled_data <= 16'h7DBD; end
                if ( y == 39 && x == 12) begin oled_data <= 16'h1A30; end
                if ( y == 39 && x == 13) begin oled_data <= 16'h2271; end
                if ( y == 39 && x == 14) begin oled_data <= 16'h64FB; end
                if ( y == 39 && x == 15) begin oled_data <= 16'h7DFE; end
                if ( y == 39 && x == 16) begin oled_data <= 16'h967D; end
                if ( y == 39 && x == 17) begin oled_data <= 16'h4B90; end
                if ( y == 39 && x == 18) begin oled_data <= 16'h1167; end
                if ( y == 40 && x == 7) begin oled_data <= 16'h2A2C; end
                if ( y == 40 && x == 8) begin oled_data <= 16'h01CF; end
                if ( y == 40 && x == 9) begin oled_data <= 16'h12D4; end
                if ( y == 40 && x == 10) begin oled_data <= 16'h2B75; end
                if ( y == 40 && x == 11) begin oled_data <= 16'h43D4; end
                if ( y == 40 && x == 14) begin oled_data <= 16'h43B4; end
                if ( y == 40 && x == 15) begin oled_data <= 16'h6D3B; end
                if ( y == 40 && x == 16) begin oled_data <= 16'h7D7C; end
                if ( y == 40 && x == 17) begin oled_data <= 16'h2AF1; end
                if ( y == 40 && x == 18) begin oled_data <= 16'h1A91; end
                if ( y == 40 && x == 19) begin oled_data <= 16'h2AD0; end
                if ( y == 40 && x == 20) begin oled_data <= 16'h1967; end
                if ( y == 41 && x == 6) begin oled_data <= 16'h31EA; end
                if ( y == 41 && x == 7) begin oled_data <= 16'h19EE; end
                if ( y == 41 && x == 8) begin oled_data <= 16'h12B5; end
                if ( y == 41 && x == 9) begin oled_data <= 16'h2BDA; end
                if ( y == 41 && x == 10) begin oled_data <= 16'h2355; end
                if ( y == 41 && x == 11) begin oled_data <= 16'h124E; end
                if ( y == 41 && x == 15) begin oled_data <= 16'h4373; end
                if ( y == 41 && x == 16) begin oled_data <= 16'h2A71; end
                if ( y == 41 && x == 17) begin oled_data <= 16'h018E; end
                if ( y == 41 && x == 18) begin oled_data <= 16'h2336; end
                if ( y == 41 && x == 19) begin oled_data <= 16'h2B56; end
                if ( y == 41 && x == 20) begin oled_data <= 16'h32F0; end
                if ( y == 41 && x == 21) begin oled_data <= 16'h0926; end
                if ( y == 42 && x == 6) begin oled_data <= 16'h29ED; end
                if ( y == 42 && x == 7) begin oled_data <= 16'h09D0; end
                if ( y == 42 && x == 8) begin oled_data <= 16'h137A; end
                if ( y == 42 && x == 9) begin oled_data <= 16'h13DC; end
                if ( y == 42 && x == 10) begin oled_data <= 16'h2BD8; end
                if ( y == 42 && x == 11) begin oled_data <= 16'h01CC; end
                if ( y == 42 && x == 15) begin oled_data <= 16'h21CA; end
                if ( y == 42 && x == 16) begin oled_data <= 16'h196D; end
                if ( y == 42 && x == 17) begin oled_data <= 16'h09B0; end
                if ( y == 42 && x == 18) begin oled_data <= 16'h12B6; end
                if ( y == 42 && x == 19) begin oled_data <= 16'h2BDA; end
                if ( y == 42 && x == 20) begin oled_data <= 16'h2356; end
                if ( y == 42 && x == 21) begin oled_data <= 16'h1A4E; end
                if ( y == 43 && x == 5) begin oled_data <= 16'h2189; end
                if ( y == 43 && x == 6) begin oled_data <= 16'h198E; end
                if ( y == 43 && x == 7) begin oled_data <= 16'h0A34; end
                if ( y == 43 && x == 8) begin oled_data <= 16'h13BC; end
                if ( y == 43 && x == 9) begin oled_data <= 16'h13DC; end
                if ( y == 43 && x == 10) begin oled_data <= 16'h23B8; end
                if ( y == 43 && x == 11) begin oled_data <= 16'h01AC; end
                if ( y == 43 && x == 14) begin oled_data <= 16'h0862; end
                if ( y == 43 && x == 15) begin oled_data <= 16'h3A4B; end
                if ( y == 43 && x == 16) begin oled_data <= 16'h218C; end
                if ( y == 43 && x == 17) begin oled_data <= 16'h1190; end
                if ( y == 43 && x == 18) begin oled_data <= 16'h0235; end
                if ( y == 43 && x == 19) begin oled_data <= 16'h239B; end
                if ( y == 43 && x == 20) begin oled_data <= 16'h23DA; end
                if ( y == 43 && x == 21) begin oled_data <= 16'h1B34; end
                if ( y == 43 && x == 22) begin oled_data <= 16'h0927; end
                if ( y == 44 && x == 4) begin oled_data <= 16'h08A4; end
                if ( y == 44 && x == 5) begin oled_data <= 16'h29EB; end
                if ( y == 44 && x == 6) begin oled_data <= 16'h118F; end
                if ( y == 44 && x == 7) begin oled_data <= 16'h1AB6; end
                if ( y == 44 && x == 8) begin oled_data <= 16'h13FD; end
                if ( y == 44 && x == 9) begin oled_data <= 16'h13DC; end
                if ( y == 44 && x == 10) begin oled_data <= 16'h2397; end
                if ( y == 44 && x == 11) begin oled_data <= 16'h09AC; end
                if ( y == 44 && x == 15) begin oled_data <= 16'h2167; end
                if ( y == 44 && x == 16) begin oled_data <= 16'h29AC; end
                if ( y == 44 && x == 17) begin oled_data <= 16'h118F; end
                if ( y == 44 && x == 18) begin oled_data <= 16'h01B2; end
                if ( y == 44 && x == 19) begin oled_data <= 16'h1B19; end
                if ( y == 44 && x == 20) begin oled_data <= 16'h1BDC; end
                if ( y == 44 && x == 21) begin oled_data <= 16'h1BB8; end
                if ( y == 45 && x == 3) begin oled_data <= 16'h0863; end
                if ( y == 45 && x == 4) begin oled_data <= 16'h21AA; end
                if ( y == 45 && x == 5) begin oled_data <= 16'h19AC; end
                if ( y == 45 && x == 6) begin oled_data <= 16'h0190; end
                if ( y == 45 && x == 7) begin oled_data <= 16'h0276; end
                if ( y == 45 && x == 8) begin oled_data <= 16'h13DC; end
                if ( y == 45 && x == 9) begin oled_data <= 16'h1BFC; end
                if ( y == 45 && x == 10) begin oled_data <= 16'h1AF4; end
                if ( y == 45 && x == 15) begin oled_data <= 16'h0883; end
                if ( y == 45 && x == 16) begin oled_data <= 16'h29CB; end
                if ( y == 45 && x == 17) begin oled_data <= 16'h198E; end
                if ( y == 45 && x == 18) begin oled_data <= 16'h0990; end
                if ( y == 45 && x == 19) begin oled_data <= 16'h0A55; end
                if ( y == 45 && x == 20) begin oled_data <= 16'h1BDC; end
                if ( y == 45 && x == 21) begin oled_data <= 16'h1BDA; end
                if ( y == 45 && x == 22) begin oled_data <= 16'h22D1; end
                if ( y == 46 && x == 2) begin oled_data <= 16'h08A4; end
                if ( y == 46 && x == 4) begin oled_data <= 16'h19AD; end
                if ( y == 46 && x == 5) begin oled_data <= 16'h09D0; end
                if ( y == 46 && x == 6) begin oled_data <= 16'h12F7; end
                if ( y == 46 && x == 7) begin oled_data <= 16'h0319; end
                if ( y == 46 && x == 8) begin oled_data <= 16'h02B8; end
                if ( y == 46 && x == 9) begin oled_data <= 16'h1B99; end
                if ( y == 46 && x == 10) begin oled_data <= 16'h1A70; end
                if ( y == 46 && x == 16) begin oled_data <= 16'h2189; end
                if ( y == 46 && x == 17) begin oled_data <= 16'h21AC; end
                if ( y == 46 && x == 18) begin oled_data <= 16'h198F; end
                if ( y == 46 && x == 19) begin oled_data <= 16'h09B1; end
                if ( y == 46 && x == 20) begin oled_data <= 16'h0AB6; end
                if ( y == 46 && x == 21) begin oled_data <= 16'h02D6; end
                if ( y == 46 && x == 22) begin oled_data <= 16'h0AB3; end
                if ( y == 46 && x == 23) begin oled_data <= 16'h1A90; end
                if ( y == 46 && x == 24) begin oled_data <= 16'h0927; end
                if ( y == 47 && x == 3) begin oled_data <= 16'h21AC; end
                if ( y == 47 && x == 4) begin oled_data <= 16'h098F; end
                if ( y == 47 && x == 5) begin oled_data <= 16'h1AD6; end
                if ( y == 47 && x == 6) begin oled_data <= 16'h1BDB; end
                if ( y == 47 && x == 7) begin oled_data <= 16'h13FC; end
                if ( y == 47 && x == 8) begin oled_data <= 16'h0B7A; end
                if ( y == 47 && x == 9) begin oled_data <= 16'h0AB5; end
                if ( y == 47 && x == 10) begin oled_data <= 16'h098C; end
                if ( y == 47 && x == 16) begin oled_data <= 16'h29AA; end
                if ( y == 47 && x == 17) begin oled_data <= 16'h216B; end
                if ( y == 47 && x == 18) begin oled_data <= 16'h218E; end
                if ( y == 47 && x == 19) begin oled_data <= 16'h116F; end
                if ( y == 47 && x == 20) begin oled_data <= 16'h0213; end
                if ( y == 47 && x == 21) begin oled_data <= 16'h2379; end
                if ( y == 47 && x == 22) begin oled_data <= 16'h23BA; end
                if ( y == 47 && x == 23) begin oled_data <= 16'h2376; end
                if ( y == 47 && x == 24) begin oled_data <= 16'h2AF0; end
                if ( y == 47 && x == 25) begin oled_data <= 16'h19C9; end
                if ( y == 48 && x == 1) begin oled_data <= 16'h29A9; end
                if ( y == 48 && x == 2) begin oled_data <= 16'h29AC; end
                if ( y == 48 && x == 3) begin oled_data <= 16'h198E; end
                if ( y == 48 && x == 4) begin oled_data <= 16'h0A13; end
                if ( y == 48 && x == 5) begin oled_data <= 16'h237A; end
                if ( y == 48 && x == 6) begin oled_data <= 16'h1BFC; end
                if ( y == 48 && x == 7) begin oled_data <= 16'h13DC; end
                if ( y == 48 && x == 8) begin oled_data <= 16'h1BFC; end
                if ( y == 48 && x == 9) begin oled_data <= 16'h1B37; end
                if ( y == 48 && x == 10) begin oled_data <= 16'h19CC; end
                if ( y == 48 && x == 16) begin oled_data <= 16'h218A; end
                if ( y == 48 && x == 17) begin oled_data <= 16'h218C; end
                if ( y == 48 && x == 18) begin oled_data <= 16'h196D; end
                if ( y == 48 && x == 19) begin oled_data <= 16'h116F; end
                if ( y == 48 && x == 20) begin oled_data <= 16'h1276; end
                if ( y == 48 && x == 21) begin oled_data <= 16'h23BC; end
                if ( y == 48 && x == 22) begin oled_data <= 16'h1BDC; end
                if ( y == 48 && x == 23) begin oled_data <= 16'h23FA; end
                if ( y == 48 && x == 24) begin oled_data <= 16'h2BB7; end
                if ( y == 48 && x == 25) begin oled_data <= 16'h2AF1; end
                if ( y == 49 && x == 1) begin oled_data <= 16'h2147; end
                if ( y == 49 && x == 2) begin oled_data <= 16'h218C; end
                if ( y == 49 && x == 3) begin oled_data <= 16'h116F; end
                if ( y == 49 && x == 4) begin oled_data <= 16'h0A14; end
                if ( y == 49 && x == 5) begin oled_data <= 16'h1339; end
                if ( y == 49 && x == 6) begin oled_data <= 16'h0339; end
                if ( y == 49 && x >= 7 && x <= 8) begin oled_data <= 16'h035A; end
                if ( y == 49 && x == 9) begin oled_data <= 16'h1316; end
                if ( y == 49 && x == 10) begin oled_data <= 16'h19EC; end
                if ( y == 49 && x == 16) begin oled_data <= 16'h216A; end
                if ( y == 49 && x == 17) begin oled_data <= 16'h218C; end
                if ( y == 49 && x == 18) begin oled_data <= 16'h196C; end
                if ( y == 49 && x == 19) begin oled_data <= 16'h118F; end
                if ( y == 49 && x == 20) begin oled_data <= 16'h01F4; end
                if ( y == 49 && x == 21) begin oled_data <= 16'h02D9; end
                if ( y == 49 && x == 22) begin oled_data <= 16'h0339; end
                if ( y == 49 && x == 23) begin oled_data <= 16'h0338; end
                if ( y == 49 && x == 24) begin oled_data <= 16'h0B37; end
                if ( y == 49 && x == 25) begin oled_data <= 16'h0A71; end
                end    
                
                //mario shooting stance
                if (led_count <= led_count2)
                begin
                        //draw clothes
                if (((pixel_index % 96 > 78 && pixel_index % 96 < 89) &&(pixel_index / 96 > 18 && pixel_index / 96 < 21)) || 
                    ((pixel_index % 96 > 72 && pixel_index % 96 < 91) &&(pixel_index / 96 > 20 && pixel_index / 96 < 23)) ||
                    ((pixel_index % 96 > 84 && pixel_index % 96 < 87) &&(pixel_index / 96 > 32 && pixel_index / 96 < 37)) ||
                    ((pixel_index % 96 > 78 && pixel_index % 96 < 81) &&(pixel_index / 96 > 34 && pixel_index / 96 < 37)) ||
                    ((pixel_index % 96 > 78 && pixel_index % 96 < 87) &&(pixel_index / 96 > 36 && pixel_index / 96 < 39)) ||
                    ((pixel_index % 96 > 76 && pixel_index % 96 < 79) &&(pixel_index / 96 > 38 && pixel_index / 96 < 41)) ||
                    ((pixel_index % 96 > 80 && pixel_index % 96 < 85) &&(pixel_index / 96 > 38 && pixel_index / 96 < 41)) ||
                    ((pixel_index % 96 > 86 && pixel_index % 96 < 89) &&(pixel_index / 96 > 38 && pixel_index / 96 < 41)) ||
                    ((pixel_index % 96 > 76 && pixel_index % 96 < 89) &&(pixel_index / 96 > 40 && pixel_index / 96 < 43)) ||
                    ((pixel_index % 96 > 74 && pixel_index % 96 < 91) &&(pixel_index / 96 > 42 && pixel_index / 96 < 45)) ||
                    ((pixel_index % 96 > 74 && pixel_index % 96 < 81) &&(pixel_index / 96 > 44 && pixel_index / 96 < 47)) ||
                    ((pixel_index % 96 > 84 && pixel_index % 96 < 91) &&(pixel_index / 96 > 44 && pixel_index / 96 < 47)))
                    oled_data <= 16'hE8A0;
                //draw hair, body and legs    
                else if (((pixel_index % 96 > 78 && pixel_index % 96 < 81) &&(pixel_index / 96 > 22 && pixel_index / 96 < 27)) ||
                         ((pixel_index % 96 > 84 && pixel_index % 96 < 91) &&(pixel_index / 96 > 22 && pixel_index / 96 < 25)) ||
                         ((pixel_index % 96 > 86 && pixel_index % 96 < 89) &&(pixel_index / 96 > 24 && pixel_index / 96 < 29)) ||
                        ((pixel_index % 96 > 84 && pixel_index % 96 < 87) &&(pixel_index / 96 > 26 && pixel_index / 96 < 29)) ||
                        ((pixel_index % 96 > 90 && pixel_index % 96 < 93) &&(pixel_index / 96 > 24 && pixel_index / 96 < 31)) ||
                        ((pixel_index % 96 > 88 && pixel_index % 96 < 91) &&(pixel_index / 96 > 28 && pixel_index / 96 < 31)) ||
                        ((pixel_index % 96 > 72 && pixel_index % 96 < 81) &&(pixel_index / 96 > 28 && pixel_index / 96 < 31)) ||
                        ((pixel_index % 96 > 76 && pixel_index % 96 < 79) &&(pixel_index / 96 > 26 && pixel_index / 96 < 29)) ||
                        ((pixel_index % 96 > 78 && pixel_index % 96 < 85) &&(pixel_index / 96 > 32 && pixel_index / 96 < 35)) ||
                        ((pixel_index % 96 > 80 && pixel_index % 96 < 85) &&(pixel_index / 96 > 34 && pixel_index / 96 < 37)) ||
                        ((pixel_index % 96 > 86 && pixel_index % 96 < 91) &&(pixel_index / 96 > 32 && pixel_index / 96 < 39)) ||
                        ((pixel_index % 96 > 90 && pixel_index % 96 < 93) &&(pixel_index / 96 > 34 && pixel_index / 96 < 39)) ||
                        ((pixel_index % 96 > 92 && pixel_index % 96 < 95) &&(pixel_index / 96 > 36 && pixel_index / 96 < 39)) ||
                        ((pixel_index % 96 > 88 && pixel_index % 96 < 91) &&(pixel_index / 96 > 38 && pixel_index / 96 < 41)) ||
                        ((pixel_index % 96 > 72 && pixel_index % 96 < 75) &&(pixel_index / 96 > 30 && pixel_index / 96 < 33)) ||
                        ((pixel_index % 96 > 68 && pixel_index % 96 < 71) &&(pixel_index / 96 > 22 && pixel_index / 96 < 29)) ||
                        ((pixel_index % 96 > 70 && pixel_index % 96 < 73) &&(pixel_index / 96 > 22 && pixel_index / 96 < 27)) ||
                        ((pixel_index % 96 > 72 && pixel_index % 96 < 75) &&(pixel_index / 96 > 22 && pixel_index / 96 < 25)) ||
                        ((pixel_index % 96 > 70 && pixel_index % 96 < 73) &&(pixel_index / 96 > 28 && pixel_index / 96 < 31)) ||
                        ((pixel_index % 96 > 72 && pixel_index % 96 < 79) &&(pixel_index / 96 > 46 && pixel_index / 96 < 51)) || 
                        ((pixel_index % 96 > 70 && pixel_index % 96 < 73) &&(pixel_index / 96 > 48 && pixel_index / 96 < 51)) ||
                        ((pixel_index % 96 > 86 && pixel_index % 96 < 93) &&(pixel_index / 96 > 46 && pixel_index / 96 < 51)) ||
                        ((pixel_index % 96 > 92 && pixel_index % 96 < 95) &&(pixel_index / 96 > 48 && pixel_index / 96 < 51)))
                        oled_data <= 16'h7320;
                //draw face and arms
                else if (((pixel_index % 96 > 70 && pixel_index % 96 < 73) &&(pixel_index / 96 > 26 && pixel_index / 96 < 29)) ||
                        ((pixel_index % 96 > 72 && pixel_index % 96 < 77) &&(pixel_index / 96 > 24 && pixel_index / 96 < 29)) ||
                        ((pixel_index % 96 > 76 && pixel_index % 96 < 79) &&(pixel_index / 96 > 22 && pixel_index / 96 < 27)) ||
                        ((pixel_index % 96 > 78 && pixel_index % 96 < 81) &&(pixel_index / 96 > 26 && pixel_index / 96 < 29)) ||
                        ((pixel_index % 96 > 80 && pixel_index % 96 < 85) &&(pixel_index / 96 > 22 && pixel_index / 96 < 31)) ||
                        ((pixel_index % 96 > 84 && pixel_index % 96 < 87) &&(pixel_index / 96 > 24 && pixel_index / 96 < 27)) ||
                        ((pixel_index % 96 > 88 && pixel_index % 96 < 91) &&(pixel_index / 96 > 24 && pixel_index / 96 < 29)) ||
                        ((pixel_index % 96 > 84 && pixel_index % 96 < 89) &&(pixel_index / 96 > 28 && pixel_index / 96 < 31)) ||
                        ((pixel_index % 96 > 74 && pixel_index % 96 < 89) &&(pixel_index / 96 > 30 && pixel_index / 96 < 33)) ||
                        ((pixel_index % 96 > 78 && pixel_index % 96 < 81) &&(pixel_index / 96 > 38 && pixel_index / 96 < 41)) ||
                        ((pixel_index % 96 > 84 && pixel_index % 96 < 87) &&(pixel_index / 96 > 38 && pixel_index / 96 < 41)) ||
                        ((pixel_index % 96 > 88 && pixel_index % 96 < 91) &&(pixel_index / 96 > 40 && pixel_index / 96 < 43)) ||
                        ((pixel_index % 96 > 68 && pixel_index % 96 < 73) &&(pixel_index / 96 > 20 && pixel_index / 96 < 23)) ||
                        ((pixel_index % 96 > 68 && pixel_index % 96 < 75) &&(pixel_index / 96 > 16 && pixel_index / 96 < 21)) ||
                        ((pixel_index % 96 > 90 && pixel_index % 96 < 95) &&(pixel_index / 96 > 38 && pixel_index / 96 < 45)))
                        oled_data <= 16'hFD40;

                else if (((pixel_index % 96 > 70 && pixel_index % 96 < 79) &&(pixel_index / 96 > 34 && pixel_index / 96 < 39)) ||
                        ((pixel_index % 96 > 70 && pixel_index % 96 < 77) &&(pixel_index / 96 > 38 && pixel_index / 96 < 43)) ||
                        ((pixel_index % 96 > 70 && pixel_index % 96 < 75) &&(pixel_index / 96 > 42 && pixel_index / 96 < 45)))
                        oled_data <= 16'h0000;    
                       
                end
                
                
                //megaman > mario 
                if (led_count > led_count2)
                begin
                    if (((x > 29 && x < 69) &&(y == 32)) || 
                    ((x > 28 && x < 31) &&(y > 32 && y < 37)) ||
                    ((x == 28) && (y > 33 && y < 36)) ||
                    ((x > 29 && x < 69) &&(y == 37)) ||
                    ((x > 67 && x < 70) &&(y > 32 && y < 37)) ||
                    ((x == 70) &&(y > 33 && y < 36)))
                    oled_data <= 16'h049F;

                    else if (((x > 30 && x < 68) &&(y == 33)) || 
                         ((x > 30 && x < 33) &&(y > 33 && y < 36)) ||
                         ((x > 30 && x < 68) &&(y == 36)) ||
                         ((x > 65 && x < 68) &&(y > 33 && y < 36)))
                         oled_data <= 16'h05FF;
        
                    else if ((x > 32 && x < 66) && (y > 33 && y < 36))
                    oled_data <= 16'h8FFF;
                    
                    mario_health_clock <= mario_health_clock + 1;
                    if (mario_health_clock == 19'd312500)
                    begin
                        mario_health_counter <= mario_health_counter + 1;
                        mario_health_clock <= 0;
                    end
                end
                
                //megaman = mario
                if (led_count == led_count2)
                begin
                            if (((x > 29 && x < 47) &&(y == 32)) || 
                                            ((x > 28 && x < 31) &&(y > 32 && y < 37)) ||
                                            ((x == 28) && (y > 33 && y < 36)) ||
                                            ((x > 29 && x < 47) &&(y == 37)) ||
                                            ((x > 45 && x < 48) &&(y > 32 && y < 37)) ||
                                            ((x == 48) &&(y > 33 && y < 36)))
                                            oled_data <= 16'h049F;
                            
                            else if (((x > 30 && x < 46) &&(y == 33)) || 
                                                 ((x > 30 && x < 33) &&(y > 33 && y < 36)) ||
                                                 ((x > 30 && x < 46) &&(y == 36)) ||
                                                 ((x > 43 && x < 46) &&(y > 33 && y < 36)))
                                 oled_data <= 16'h05FF;
                                
                            else if ((x > 32 && x < 44) && (y > 33 && y < 36))
                                oled_data <= 16'h8FFF;
                
                            else if (((x > 50 && x < 69) &&(y == 32)) || 
                                            ((x > 49 && x < 52) &&(y > 32 && y < 37)) ||
                                            ((x == 49) && (y > 33 && y < 36)) ||
                                            ((x > 50 && x < 69) &&(y == 37)) ||
                                            ((x > 67 && x < 70) &&(y > 32 && y < 37)) ||
                                            ((x == 70) &&(y > 33 && y < 36)))
                                            oled_data <= 16'hF980;
                            
                            else if (((x > 49 && x < 68) &&(y == 33)) || 
                                     ((x > 49 && x < 52) &&(y > 33 && y < 36)) ||
                                     ((x > 49 && x < 68) &&(y == 36)) ||
                                     ((x > 65 && x < 68) &&(y > 33 && y < 36)))
                                 oled_data <= 16'hFCA0;
                                
                            else if ((x > 51 && x < 66) && (y > 33 && y < 36))
                                oled_data <= 16'hF7A0;
                end
                
                //mario > megaman
                if (led_count < led_count2)
                begin
                            if (((x > 29 && x < 69) &&(y == 32)) || 
                                            ((x > 28 && x < 31) &&(y > 32 && y < 37)) ||
                                            ((x == 28) && (y > 33 && y < 36)) ||
                                            ((x > 29 && x < 69) &&(y == 37)) ||
                                            ((x > 67 && x < 70) &&(y > 32 && y < 37)) ||
                                            ((x == 70) &&(y > 33 && y < 36)))
                                            oled_data <= 16'hF980;
                
                            else if (((x > 30 && x < 68) &&(y == 33)) || 
                                                 ((x > 30 && x < 33) &&(y > 33 && y < 36)) ||
                                                 ((x > 30 && x < 68) &&(y == 36)) ||
                                                 ((x > 65 && x < 68) &&(y > 33 && y < 36)))
                                                 oled_data <= 16'hFCA0;
                                
                            else if ((x > 32 && x < 66) && (y > 33 && y < 36))
                                oled_data <= 16'hF7A0;
                                
                                megaman_health_clock <= megaman_health_clock + 1;
                                if (megaman_health_clock == 19'd312500)
                                begin
                                    megaman_health_counter <= megaman_health_counter + 1;
                                    megaman_health_clock <= 0;
                                end
                end
                
                if (led_count == 0 && led_count2 == 0)
                begin
                    if ( x >= 28 && x <= 70 && y >= 32 && y <= 37) begin oled_data <= 16'h0000; end
                end
                
                if (megaman_health_counter == 93)
                begin
                    finalGameStart <= 0; //game ends
                    marioWin <= 1;
                end

                if (mario_health_counter == 93)
                begin
                    finalGameStart <= 0; //game ends
                    megamanWin <= 1;
                end                
                
        end         
    else if (finalGameStart == 0)
    begin
        if (marioWin == 1)
        begin
        oled_data <= 16'h0000;
        //gameover        
        if ( y == 28 && x == 12 ) begin oled_data <= 16'h0841; end
        if ( y == 28 && x == 13 ) begin oled_data <= 16'h4228; end
        if ( y == 28 && x >= 14 && x <= 16 ) begin oled_data <= 16'h52AA; end
        if ( y == 28 && x == 17 ) begin oled_data <= 16'h5AEB; end
        if ( y == 28 && x == 18 ) begin oled_data <= 16'h2945; end
        if ( y == 28 && x == 21 ) begin oled_data <= 16'h18E3; end
        if ( y == 28 && x == 22 ) begin oled_data <= 16'h528A; end
        if ( y == 28 && x == 23 ) begin oled_data <= 16'h52AA; end
        if ( y == 28 && x == 24 ) begin oled_data <= 16'h39E7; end
        if ( y == 28 && x == 27 ) begin oled_data <= 16'h0841; end
        if ( y == 28 && x == 28 ) begin oled_data <= 16'h52AA; end
        if ( y == 28 && x == 29 ) begin oled_data <= 16'h632C; end
        if ( y == 28 && x == 30 ) begin oled_data <= 16'h18C3; end
        if ( y == 28 && x == 34 ) begin oled_data <= 16'h528A; end
        if ( y == 28 && x == 35 ) begin oled_data <= 16'h4208; end
        if ( y == 28 && x == 36 ) begin oled_data <= 16'h2104; end
        if ( y == 28 && x >= 37 && x <= 38 ) begin oled_data <= 16'h73AE; end
        if ( y == 28 && x == 39 ) begin oled_data <= 16'h7BEF; end
        if ( y == 28 && x >= 40 && x <= 41 ) begin oled_data <= 16'h8410; end
        if ( y == 28 && x == 42 ) begin oled_data <= 16'h7BEF; end
        if ( y == 28 && x == 43 ) begin oled_data <= 16'h8430; end
        if ( y == 28 && x == 44 ) begin oled_data <= 16'h632C; end
        if ( y == 28 && x == 50 ) begin oled_data <= 16'h2965; end
        if ( y == 28 && x >= 51 && x <= 52 ) begin oled_data <= 16'h528A; end
        if ( y == 28 && x >= 53 && x <= 54 ) begin oled_data <= 16'h52AA; end
        if ( y == 28 && x == 55 ) begin oled_data <= 16'h4A49; end
        if ( y == 28 && x == 56 ) begin oled_data <= 16'h0841; end
        if ( y == 28 && x == 58 ) begin oled_data <= 16'h4208; end
        if ( y == 28 && x == 59 ) begin oled_data <= 16'h528A; end
        if ( y == 28 && x == 60 ) begin oled_data <= 16'h18C3; end
        if ( y == 28 && x == 63 ) begin oled_data <= 16'h18E3; end
        if ( y == 28 && x == 64 ) begin oled_data <= 16'h528A; end
        if ( y == 28 && x == 65 ) begin oled_data <= 16'h39E7; end
        if ( y == 28 && x == 66 ) begin oled_data <= 16'h18C3; end
        if ( y == 28 && x >= 67 && x <= 68 ) begin oled_data <= 16'h73AE; end
        if ( y == 28 && x == 69 ) begin oled_data <= 16'h7BEF; end
        if ( y == 28 && x >= 70 && x <= 71 ) begin oled_data <= 16'h8410; end
        if ( y == 28 && x == 72 ) begin oled_data <= 16'h7BEF; end
        if ( y == 28 && x == 73 ) begin oled_data <= 16'h8C51; end
        if ( y == 28 && x == 74 ) begin oled_data <= 16'h5ACB; end
        if ( y == 28 && x == 75 ) begin oled_data <= 16'h2124; end
        if ( y == 28 && x == 76 ) begin oled_data <= 16'h528A; end
        if ( y == 28 && x == 77 ) begin oled_data <= 16'h4A69; end
        if ( y == 28 && x >= 78 && x <= 80 ) begin oled_data <= 16'h52AA; end
        if ( y == 28 && x == 81 ) begin oled_data <= 16'h4A69; end
        if ( y == 29 && x == 11 ) begin oled_data <= 16'h0861; end
        if ( y == 29 && x == 12 ) begin oled_data <= 16'h5ACB; end
        if ( y == 29 && x == 13 ) begin oled_data <= 16'hFFDF; end
        if ( y == 29 && x == 14 ) begin oled_data <= 16'hDEFB; end
        if ( y == 29 && x >= 15 && x <= 16 ) begin oled_data <= 16'hD69A; end
        if ( y == 29 && x == 17 ) begin oled_data <= 16'hE73C; end
        if ( y == 29 && x == 18 ) begin oled_data <= 16'h6B4D; end
        if ( y == 29 && x == 21 ) begin oled_data <= 16'h9CD3; end
        if ( y == 29 && x == 22 ) begin oled_data <= 16'hFFFF; end
        if ( y == 29 && x == 23 ) begin oled_data <= 16'hDEDB; end
        if ( y == 29 && x == 24 ) begin oled_data <= 16'hF79E; end
        if ( y == 29 && x == 25 ) begin oled_data <= 16'h4A49; end
        if ( y == 29 && x == 28 ) begin oled_data <= 16'hEF5D; end
        if ( y == 29 && x == 29 ) begin oled_data <= 16'hFFFF; end
        if ( y == 29 && x == 30 ) begin oled_data <= 16'h8C51; end
        if ( y == 29 && x == 32 ) begin oled_data <= 16'h18C3; end
        if ( y == 29 && x == 33 ) begin oled_data <= 16'h8C71; end
        if ( y == 29 && x == 34 ) begin oled_data <= 16'hFFFF; end
        if ( y == 29 && x == 35 ) begin oled_data <= 16'hE73C; end
        if ( y == 29 && x == 36 ) begin oled_data <= 16'h5ACB; end
        if ( y == 29 && x >= 37 && x <= 38 ) begin oled_data <= 16'hFFFF; end
        if ( y == 29 && x == 39 ) begin oled_data <= 16'hDEDB; end
        if ( y == 29 && x >= 40 && x <= 41 ) begin oled_data <= 16'hD6BA; end
        if ( y == 29 && x == 42 ) begin oled_data <= 16'hD69A; end
        if ( y == 29 && x == 43 ) begin oled_data <= 16'hDEFB; end
        if ( y == 29 && x == 44 ) begin oled_data <= 16'hAD55; end
        if ( y == 29 && x == 49 ) begin oled_data <= 16'h18E3; end
        if ( y == 29 && x == 50 ) begin oled_data <= 16'hBDF7; end
        if ( y == 29 && x == 51 ) begin oled_data <= 16'hFFDF; end
        if ( y == 29 && x == 52 ) begin oled_data <= 16'hCE79; end
        if ( y == 29 && x == 53 ) begin oled_data <= 16'hD69A; end
        if ( y == 29 && x == 54 ) begin oled_data <= 16'hDEFB; end
        if ( y == 29 && x == 55 ) begin oled_data <= 16'hFFFF; end
        if ( y == 29 && x == 56 ) begin oled_data <= 16'h5ACB; end
        if ( y == 29 && x == 58 ) begin oled_data <= 16'hDEFB; end
        if ( y == 29 && x == 59 ) begin oled_data <= 16'hFFFF; end
        if ( y == 29 && x == 60 ) begin oled_data <= 16'h5ACB; end
        if ( y == 29 && x == 63 ) begin oled_data <= 16'h632C; end
        if ( y == 29 && x == 64 ) begin oled_data <= 16'hFFFF; end
        if ( y == 29 && x == 65 ) begin oled_data <= 16'hDEFB; end
        if ( y == 29 && x == 66 ) begin oled_data <= 16'h4208; end
        if ( y == 29 && x >= 67 && x <= 68 ) begin oled_data <= 16'hFFFF; end
        if ( y == 29 && x == 69 ) begin oled_data <= 16'hDEFB; end
        if ( y == 29 && x >= 70 && x <= 71 ) begin oled_data <= 16'hD6BA; end
        if ( y == 29 && x == 72 ) begin oled_data <= 16'hD69A; end
        if ( y == 29 && x == 73 ) begin oled_data <= 16'hE71C; end
        if ( y == 29 && x == 74 ) begin oled_data <= 16'h8C71; end
        if ( y == 29 && x == 75 ) begin oled_data <= 16'h8C51; end
        if ( y == 29 && x == 76 ) begin oled_data <= 16'hFFFF; end
        if ( y == 29 && x == 77 ) begin oled_data <= 16'hF79E; end
        if ( y == 29 && x >= 78 && x <= 79 ) begin oled_data <= 16'hD69A; end
        if ( y == 29 && x == 80 ) begin oled_data <= 16'hD6BA; end
        if ( y == 29 && x == 81 ) begin oled_data <= 16'hFFFF; end
        if ( y == 29 && x == 82 ) begin oled_data <= 16'h7BEF; end
        if ( y == 29 && x == 83 ) begin oled_data <= 16'h0841; end
        if ( y == 30 && x == 11 ) begin oled_data <= 16'h73AE; end
        if ( y == 30 && x == 12 ) begin oled_data <= 16'hFFFF; end
        if ( y == 30 && x == 13 ) begin oled_data <= 16'hD69A; end
        if ( y == 30 && x == 14 ) begin oled_data <= 16'h2124; end
        if ( y == 30 && x == 19 ) begin oled_data <= 16'h0861; end
        if ( y == 30 && x == 20 ) begin oled_data <= 16'hA514; end
        if ( y == 30 && x == 21 ) begin oled_data <= 16'hFFFF; end
        if ( y == 30 && x == 22 ) begin oled_data <= 16'h8C71; end
        if ( y == 30 && x == 23 ) begin oled_data <= 16'h18E3; end
        if ( y == 30 && x == 24 ) begin oled_data <= 16'hDEFB; end
        if ( y == 30 && x == 25 ) begin oled_data <= 16'hFFFF; end
        if ( y == 30 && x == 26 ) begin oled_data <= 16'h528A; end
        if ( y == 30 && x == 28 ) begin oled_data <= 16'hE71C; end
        if ( y == 30 && x >= 29 && x <= 30 ) begin oled_data <= 16'hFFFF; end
        if ( y == 30 && x == 31 ) begin oled_data <= 16'h8C51; end
        if ( y == 30 && x == 32 ) begin oled_data <= 16'h8430; end
        if ( y == 30 && x >= 33 && x <= 34 ) begin oled_data <= 16'hFFFF; end
        if ( y == 30 && x == 35 ) begin oled_data <= 16'hE71C; end
        if ( y == 30 && x == 36 ) begin oled_data <= 16'h52AA; end
        if ( y == 30 && x == 37 ) begin oled_data <= 16'hFFDF; end
        if ( y == 30 && x == 38 ) begin oled_data <= 16'hF79E; end
        if ( y == 30 && x == 39 ) begin oled_data <= 16'h18E3; end
        if ( y == 30 && x == 49 ) begin oled_data <= 16'hB596; end
        if ( y == 30 && x == 50 ) begin oled_data <= 16'hFFFF; end
        if ( y == 30 && x == 51 ) begin oled_data <= 16'h9CF3; end
        if ( y == 30 && x == 54 ) begin oled_data <= 16'h2104; end
        if ( y == 30 && x == 55 ) begin oled_data <= 16'hF79E; end
        if ( y == 30 && x == 56 ) begin oled_data <= 16'hFFFF; end
        if ( y == 30 && x == 57 ) begin oled_data <= 16'h4208; end
        if ( y == 30 && x == 58 ) begin oled_data <= 16'hCE79; end
        if ( y == 30 && x == 59 ) begin oled_data <= 16'hFFFF; end
        if ( y == 30 && x == 60 ) begin oled_data <= 16'h52AA; end
        if ( y == 30 && x == 63 ) begin oled_data <= 16'h630C; end
        if ( y == 30 && x == 64 ) begin oled_data <= 16'hFFFF; end
        if ( y == 30 && x == 65 ) begin oled_data <= 16'hD6BA; end
        if ( y == 30 && x == 66 ) begin oled_data <= 16'h39E7; end
        if ( y == 30 && x == 67 ) begin oled_data <= 16'hF7BE; end
        if ( y == 30 && x == 68 ) begin oled_data <= 16'hFFDF; end
        if ( y == 30 && x == 69 ) begin oled_data <= 16'h2945; end
        if ( y == 30 && x == 75 ) begin oled_data <= 16'h8C51; end
        if ( y == 30 && x == 76 ) begin oled_data <= 16'hFFFF; end
        if ( y == 30 && x == 77 ) begin oled_data <= 16'hB5B6; end
        if ( y == 30 && x == 80 ) begin oled_data <= 16'h0861; end
        if ( y == 30 && x == 81 ) begin oled_data <= 16'hDEDB; end
        if ( y == 30 && x == 82 ) begin oled_data <= 16'hFFFF; end
        if ( y == 30 && x == 83 ) begin oled_data <= 16'h5ACB; end
        if ( y == 31 && x == 10 ) begin oled_data <= 16'h6B4D; end
        if ( y == 31 && x == 11 ) begin oled_data <= 16'hFFFF; end
        if ( y == 31 && x == 12 ) begin oled_data <= 16'hDEFB; end
        if ( y == 31 && x == 16 ) begin oled_data <= 16'h18C3; end
        if ( y == 31 && x == 17 ) begin oled_data <= 16'h2104; end
        if ( y == 31 && x == 19 ) begin oled_data <= 16'h9CD3; end
        if ( y == 31 && x == 20 ) begin oled_data <= 16'hFFFF; end
        if ( y == 31 && x == 21 ) begin oled_data <= 16'hA534; end
        if ( y == 31 && x == 24 ) begin oled_data <= 16'h2945; end
        if ( y == 31 && x == 25 ) begin oled_data <= 16'hF79E; end
        if ( y == 31 && x == 26 ) begin oled_data <= 16'hFFFF; end
        if ( y == 31 && x == 27 ) begin oled_data <= 16'h52AA; end
        if ( y == 31 && x == 28 ) begin oled_data <= 16'hDEDB; end
        if ( y == 31 && x == 29 ) begin oled_data <= 16'hFFFF; end
        if ( y == 31 && x >= 30 && x <= 33 ) begin oled_data <= 16'hFFDF; end
        if ( y == 31 && x == 34 ) begin oled_data <= 16'hFFFF; end
        if ( y == 31 && x == 35 ) begin oled_data <= 16'hE71C; end
        if ( y == 31 && x == 36 ) begin oled_data <= 16'h52AA; end
        if ( y == 31 && x == 37 ) begin oled_data <= 16'hFFFF; end
        if ( y == 31 && x == 38 ) begin oled_data <= 16'hF7BE; end
        if ( y == 31 && x == 39 ) begin oled_data <= 16'h4A49; end
        if ( y == 31 && x == 40 ) begin oled_data <= 16'h2945; end
        if ( y == 31 && x == 41 ) begin oled_data <= 16'h31A6; end
        if ( y == 31 && x == 49 ) begin oled_data <= 16'hAD75; end
        if ( y == 31 && x == 50 ) begin oled_data <= 16'hFFFF; end
        if ( y == 31 && x == 51 ) begin oled_data <= 16'hA514; end
        if ( y == 31 && x == 54 ) begin oled_data <= 16'h2124; end
        if ( y == 31 && x == 55 ) begin oled_data <= 16'hF7BE; end
        if ( y == 31 && x == 56 ) begin oled_data <= 16'hFFFF; end
        if ( y == 31 && x == 57 ) begin oled_data <= 16'h4208; end
        if ( y == 31 && x == 58 ) begin oled_data <= 16'hCE79; end
        if ( y == 31 && x == 59 ) begin oled_data <= 16'hFFFF; end
        if ( y == 31 && x == 60 ) begin oled_data <= 16'h6B4D; end
        if ( y == 31 && x == 63 ) begin oled_data <= 16'h630C; end
        if ( y == 31 && x == 64 ) begin oled_data <= 16'hFFFF; end
        if ( y == 31 && x == 65 ) begin oled_data <= 16'hDEDB; end
        if ( y == 31 && x == 66 ) begin oled_data <= 16'h39E7; end
        if ( y == 31 && x >= 67 && x <= 68 ) begin oled_data <= 16'hFFDF; end
        if ( y == 31 && x == 69 ) begin oled_data <= 16'h528A; end
        if ( y == 31 && x == 70 ) begin oled_data <= 16'h2124; end
        if ( y == 31 && x == 71 ) begin oled_data <= 16'h31A6; end
        if ( y == 31 && x == 72 ) begin oled_data <= 16'h18C3; end
        if ( y == 31 && x == 75 ) begin oled_data <= 16'h8C51; end
        if ( y == 31 && x == 76 ) begin oled_data <= 16'hFFFF; end
        if ( y == 31 && x == 77 ) begin oled_data <= 16'hBDD7; end
        if ( y == 31 && x == 80 ) begin oled_data <= 16'h2124; end
        if ( y == 31 && x == 81 ) begin oled_data <= 16'hDEFB; end
        if ( y == 31 && x == 82 ) begin oled_data <= 16'hFFFF; end
        if ( y == 31 && x == 83 ) begin oled_data <= 16'h5ACB; end
        if ( y == 32 && x == 10 ) begin oled_data <= 16'h6B4D; end
        if ( y == 32 && x == 11 ) begin oled_data <= 16'hFFFF; end
        if ( y == 32 && x == 12 ) begin oled_data <= 16'hDEFB; end
        if ( y == 32 && x == 13 ) begin oled_data <= 16'h0861; end
        if ( y == 32 && x == 15 ) begin oled_data <= 16'hCE79; end
        if ( y == 32 && x == 16 ) begin oled_data <= 16'hFFDF; end
        if ( y == 32 && x == 17 ) begin oled_data <= 16'hFFFF; end
        if ( y == 32 && x == 18 ) begin oled_data <= 16'h6B4D; end
        if ( y == 32 && x == 19 ) begin oled_data <= 16'h8C71; end
        if ( y == 32 && x == 20 ) begin oled_data <= 16'hFFFF; end
        if ( y == 32 && x == 21 ) begin oled_data <= 16'hA514; end
        if ( y == 32 && x == 24 ) begin oled_data <= 16'h2104; end
        if ( y == 32 && x == 25 ) begin oled_data <= 16'hF79E; end
        if ( y == 32 && x == 26 ) begin oled_data <= 16'hFFFF; end
        if ( y == 32 && x == 27 ) begin oled_data <= 16'h5ACB; end
        if ( y == 32 && x == 28 ) begin oled_data <= 16'hDEDB; end
        if ( y == 32 && x >= 29 && x <= 34 ) begin oled_data <= 16'hFFFF; end
        if ( y == 32 && x == 35 ) begin oled_data <= 16'hE71C; end
        if ( y == 32 && x == 36 ) begin oled_data <= 16'h52AA; end
        if ( y == 32 && x >= 37 && x <= 38 ) begin oled_data <= 16'hFFFF; end
        if ( y == 32 && x == 39 ) begin oled_data <= 16'hF79E; end
        if ( y == 32 && x == 40 ) begin oled_data <= 16'hEF7D; end
        if ( y == 32 && x == 41 ) begin oled_data <= 16'hFFFF; end
        if ( y == 32 && x == 42 ) begin oled_data <= 16'h7BCF; end
        if ( y == 32 && x == 49 ) begin oled_data <= 16'hAD75; end
        if ( y == 32 && x == 50 ) begin oled_data <= 16'hFFFF; end
        if ( y == 32 && x == 51 ) begin oled_data <= 16'hA514; end
        if ( y == 32 && x == 54 ) begin oled_data <= 16'h2124; end
        if ( y == 32 && x == 55 ) begin oled_data <= 16'hF7BE; end
        if ( y == 32 && x == 56 ) begin oled_data <= 16'hFFFF; end
        if ( y == 32 && x == 57 ) begin oled_data <= 16'h4208; end
        if ( y == 32 && x == 58 ) begin oled_data <= 16'hD6BA; end
        if ( y == 32 && x >= 59 && x <= 60 ) begin oled_data <= 16'hFFFF; end
        if ( y == 32 && x == 61 ) begin oled_data <= 16'h6B6D; end
        if ( y == 32 && x == 62 ) begin oled_data <= 16'h52AA; end
        if ( y == 32 && x == 63 ) begin oled_data <= 16'hEF7D; end
        if ( y == 32 && x == 64 ) begin oled_data <= 16'hFFFF; end
        if ( y == 32 && x == 65 ) begin oled_data <= 16'hD69A; end
        if ( y == 32 && x == 66 ) begin oled_data <= 16'h39E7; end
        if ( y == 32 && x == 67 ) begin oled_data <= 16'hFFDF; end
        if ( y == 32 && x == 68 ) begin oled_data <= 16'hFFFF; end
        if ( y == 32 && x == 69 ) begin oled_data <= 16'hF79E; end
        if ( y == 32 && x == 70 ) begin oled_data <= 16'hEF5D; end
        if ( y == 32 && x == 71 ) begin oled_data <= 16'hFFFF; end
        if ( y == 32 && x == 72 ) begin oled_data <= 16'h8430; end
        if ( y == 32 && x == 75 ) begin oled_data <= 16'h8C51; end
        if ( y == 32 && x == 76 ) begin oled_data <= 16'hFFFF; end
        if ( y == 32 && x == 77 ) begin oled_data <= 16'hBDD7; end
        if ( y == 32 && x == 79 ) begin oled_data <= 16'h18E3; end
        if ( y == 32 && x == 80 ) begin oled_data <= 16'hE73C; end
        if ( y == 32 && x >= 81 && x <= 82 ) begin oled_data <= 16'hFFFF; end
        if ( y == 32 && x == 83 ) begin oled_data <= 16'h5AEB; end
        if ( y == 33 && x == 10 ) begin oled_data <= 16'h6B6D; end
        if ( y == 33 && x == 11 ) begin oled_data <= 16'hFFFF; end
        if ( y == 33 && x == 12 ) begin oled_data <= 16'hDEDB; end
        if ( y == 33 && x == 13 ) begin oled_data <= 16'h0841; end
        if ( y == 33 && x == 15 ) begin oled_data <= 16'h31A6; end
        if ( y == 33 && x == 16 ) begin oled_data <= 16'hC618; end
        if ( y == 33 && x == 17 ) begin oled_data <= 16'hFFFF; end
        if ( y == 33 && x == 18 ) begin oled_data <= 16'h6B6D; end
        if ( y == 33 && x == 19 ) begin oled_data <= 16'h9492; end
        if ( y == 33 && x == 20 ) begin oled_data <= 16'hFFFF; end
        if ( y == 33 && x == 21 ) begin oled_data <= 16'hEF5D; end
        if ( y == 33 && x == 22 ) begin oled_data <= 16'hCE79; end
        if ( y == 33 && x == 23 ) begin oled_data <= 16'hD69A; end
        if ( y == 33 && x == 24 ) begin oled_data <= 16'hD6BA; end
        if ( y == 33 && x == 25 ) begin oled_data <= 16'hFFDF; end
        if ( y == 33 && x == 26 ) begin oled_data <= 16'hFFFF; end
        if ( y == 33 && x == 27 ) begin oled_data <= 16'h5ACB; end
        if ( y == 33 && x == 28 ) begin oled_data <= 16'hD6BA; end
        if ( y == 33 && x == 29 ) begin oled_data <= 16'hFFFF; end
        if ( y == 33 && x == 30 ) begin oled_data <= 16'h8410; end
        if ( y == 33 && x == 31 ) begin oled_data <= 16'hB596; end
        if ( y == 33 && x == 32 ) begin oled_data <= 16'hBDF7; end
        if ( y == 33 && x == 33 ) begin oled_data <= 16'h6B4D; end
        if ( y == 33 && x == 34 ) begin oled_data <= 16'hFFFF; end
        if ( y == 33 && x == 35 ) begin oled_data <= 16'hE71C; end
        if ( y == 33 && x == 36 ) begin oled_data <= 16'h52AA; end
        if ( y == 33 && x == 37 ) begin oled_data <= 16'hFFFF; end
        if ( y == 33 && x == 38 ) begin oled_data <= 16'hF7BE; end
        if ( y == 33 && x == 39 ) begin oled_data <= 16'h4208; end
        if ( y == 33 && x == 40 ) begin oled_data <= 16'h18E3; end
        if ( y == 33 && x == 41 ) begin oled_data <= 16'h2945; end
        if ( y == 33 && x == 49 ) begin oled_data <= 16'hAD75; end
        if ( y == 33 && x == 50 ) begin oled_data <= 16'hFFFF; end
        if ( y == 33 && x == 51 ) begin oled_data <= 16'hA514; end
        if ( y == 33 && x == 54 ) begin oled_data <= 16'h2945; end
        if ( y == 33 && x == 55 ) begin oled_data <= 16'hF7BE; end
        if ( y == 33 && x == 56 ) begin oled_data <= 16'hFFFF; end
        if ( y == 33 && x == 57 ) begin oled_data <= 16'h39C7; end
        if ( y == 33 && x == 58 ) begin oled_data <= 16'h2965; end
        if ( y == 33 && x == 59 ) begin oled_data <= 16'hE71C; end
        if ( y == 33 && x == 60 ) begin oled_data <= 16'hFFFF; end
        if ( y == 33 && x >= 61 && x <= 62 ) begin oled_data <= 16'hEF5D; end
        if ( y == 33 && x == 63 ) begin oled_data <= 16'hFFFF; end
        if ( y == 33 && x == 64 ) begin oled_data <= 16'hE71C; end
        if ( y == 33 && x == 65 ) begin oled_data <= 16'h18C3; end
        if ( y == 33 && x == 66 ) begin oled_data <= 16'h3186; end
        if ( y == 33 && x == 67 ) begin oled_data <= 16'hFFFF; end
        if ( y == 33 && x == 68 ) begin oled_data <= 16'hFFDF; end
        if ( y == 33 && x == 69 ) begin oled_data <= 16'h4A49; end
        if ( y == 33 && x == 70 ) begin oled_data <= 16'h18C3; end
        if ( y == 33 && x == 71 ) begin oled_data <= 16'h2945; end
        if ( y == 33 && x == 75 ) begin oled_data <= 16'h8C71; end
        if ( y == 33 && x == 76 ) begin oled_data <= 16'hFFFF; end
        if ( y == 33 && x == 77 ) begin oled_data <= 16'hEF7D; end
        if ( y == 33 && x == 78 ) begin oled_data <= 16'hC638; end
        if ( y == 33 && x == 79 ) begin oled_data <= 16'hC618; end
        if ( y == 33 && x == 80 ) begin oled_data <= 16'hFFDF; end
        if ( y == 33 && x == 81 ) begin oled_data <= 16'h5ACB; end
        if ( y == 33 && x == 82 ) begin oled_data <= 16'h39E7; end
        if ( y == 33 && x == 83 ) begin oled_data <= 16'h18E3; end
        if ( y == 34 && x == 10 ) begin oled_data <= 16'h18E3; end
        if ( y == 34 && x == 11 ) begin oled_data <= 16'h8410; end
        if ( y == 34 && x == 12 ) begin oled_data <= 16'hFFDF; end
        if ( y == 34 && x == 13 ) begin oled_data <= 16'hA514; end
        if ( y == 34 && x == 14 ) begin oled_data <= 16'h0861; end
        if ( y == 34 && x == 16 ) begin oled_data <= 16'hA514; end
        if ( y == 34 && x == 17 ) begin oled_data <= 16'hFFFF; end
        if ( y == 34 && x == 18 ) begin oled_data <= 16'h6B4D; end
        if ( y == 34 && x == 19 ) begin oled_data <= 16'h8C71; end
        if ( y == 34 && x == 20 ) begin oled_data <= 16'hFFFF; end
        if ( y == 34 && x == 21 ) begin oled_data <= 16'hC638; end
        if ( y == 34 && x == 22 ) begin oled_data <= 16'h6B6D; end
        if ( y == 34 && x == 23 ) begin oled_data <= 16'h73AE; end
        if ( y == 34 && x == 24 ) begin oled_data <= 16'h8430; end
        if ( y == 34 && x == 25 ) begin oled_data <= 16'hF79E; end
        if ( y == 34 && x == 26 ) begin oled_data <= 16'hFFFF; end
        if ( y == 34 && x == 27 ) begin oled_data <= 16'h52AA; end
        if ( y == 34 && x == 28 ) begin oled_data <= 16'hD69A; end
        if ( y == 34 && x == 29 ) begin oled_data <= 16'hFFFF; end
        if ( y == 34 && x == 30 ) begin oled_data <= 16'h632C; end
        if ( y == 34 && x == 31 ) begin oled_data <= 16'h2124; end
        if ( y == 34 && x == 32 ) begin oled_data <= 16'h3186; end
        if ( y == 34 && x == 33 ) begin oled_data <= 16'h4228; end
        if ( y == 34 && x == 34 ) begin oled_data <= 16'hFFFF; end
        if ( y == 34 && x == 35 ) begin oled_data <= 16'hDEFB; end
        if ( y == 34 && x == 36 ) begin oled_data <= 16'h528A; end
        if ( y == 34 && x == 37 ) begin oled_data <= 16'hFFDF; end
        if ( y == 34 && x == 38 ) begin oled_data <= 16'hF79E; end
        if ( y == 34 && x == 39 ) begin oled_data <= 16'h18E3; end
        if ( y == 34 && x == 49 ) begin oled_data <= 16'hB5B6; end
        if ( y == 34 && x == 50 ) begin oled_data <= 16'hFFFF; end
        if ( y == 34 && x == 51 ) begin oled_data <= 16'h9CD3; end
        if ( y == 34 && x == 54 ) begin oled_data <= 16'h2104; end
        if ( y == 34 && x == 55 ) begin oled_data <= 16'hEF7D; end
        if ( y == 34 && x == 56 ) begin oled_data <= 16'hFFFF; end
        if ( y == 34 && x == 57 ) begin oled_data <= 16'h39E7; end
        if ( y == 34 && x == 59 ) begin oled_data <= 16'h4208; end
        if ( y == 34 && x == 60 ) begin oled_data <= 16'hDEDB; end
        if ( y == 34 && x >= 61 && x <= 62 ) begin oled_data <= 16'hFFFF; end
        if ( y == 34 && x == 63 ) begin oled_data <= 16'hDEDB; end
        if ( y == 34 && x == 64 ) begin oled_data <= 16'h4A49; end
        if ( y == 34 && x == 66 ) begin oled_data <= 16'h2965; end
        if ( y == 34 && x == 67 ) begin oled_data <= 16'hFFDF; end
        if ( y == 34 && x == 68 ) begin oled_data <= 16'hF7BE; end
        if ( y == 34 && x == 69 ) begin oled_data <= 16'h2945; end
        if ( y == 34 && x == 75 ) begin oled_data <= 16'h8C51; end
        if ( y == 34 && x == 76 ) begin oled_data <= 16'hFFFF; end
        if ( y == 34 && x == 77 ) begin oled_data <= 16'hCE59; end
        if ( y == 34 && x == 78 ) begin oled_data <= 16'h8C71; end
        if ( y == 34 && x == 79 ) begin oled_data <= 16'hFFFF; end
        if ( y == 34 && x == 80 ) begin oled_data <= 16'hF7BE; end
        if ( y == 34 && x == 81 ) begin oled_data <= 16'hB5B6; end
        if ( y == 34 && x == 82 ) begin oled_data <= 16'h2124; end
        if ( y == 35 && x == 12 ) begin oled_data <= 16'h8C71; end
        if ( y == 35 && x == 13 ) begin oled_data <= 16'hFFFF; end
        if ( y == 35 && x == 14 ) begin oled_data <= 16'hBDD7; end
        if ( y == 35 && x == 15 ) begin oled_data <= 16'hAD55; end
        if ( y == 35 && x == 16 ) begin oled_data <= 16'hE73C; end
        if ( y == 35 && x == 17 ) begin oled_data <= 16'hFFFF; end
        if ( y == 35 && x == 18 ) begin oled_data <= 16'h738E; end
        if ( y == 35 && x == 19 ) begin oled_data <= 16'h9492; end
        if ( y == 35 && x == 20 ) begin oled_data <= 16'hFFFF; end
        if ( y == 35 && x == 21 ) begin oled_data <= 16'hA534; end
        if ( y == 35 && x == 24 ) begin oled_data <= 16'h2104; end
        if ( y == 35 && x == 25 ) begin oled_data <= 16'hF7BE; end
        if ( y == 35 && x == 26 ) begin oled_data <= 16'hFFFF; end
        if ( y == 35 && x == 27 ) begin oled_data <= 16'h5AEB; end
        if ( y == 35 && x == 28 ) begin oled_data <= 16'hD6BA; end
        if ( y == 35 && x == 29 ) begin oled_data <= 16'hFFFF; end
        if ( y == 35 && x == 30 ) begin oled_data <= 16'h73AE; end
        if ( y == 35 && x == 33 ) begin oled_data <= 16'h52AA; end
        if ( y == 35 && x == 34 ) begin oled_data <= 16'hFFFF; end
        if ( y == 35 && x == 35 ) begin oled_data <= 16'hE73C; end
        if ( y == 35 && x == 36 ) begin oled_data <= 16'h5AEB; end
        if ( y == 35 && x >= 37 && x <= 38 ) begin oled_data <= 16'hFFFF; end
        if ( y == 35 && x == 39 ) begin oled_data <= 16'hBDF7; end
        if ( y == 35 && x == 40 ) begin oled_data <= 16'hAD75; end
        if ( y == 35 && x == 41 ) begin oled_data <= 16'hB596; end
        if ( y == 35 && x == 42 ) begin oled_data <= 16'hAD75; end
        if ( y == 35 && x == 43 ) begin oled_data <= 16'hB5B6; end
        if ( y == 35 && x == 44 ) begin oled_data <= 16'h8C51; end
        if ( y == 35 && x == 49 ) begin oled_data <= 16'h52AA; end
        if ( y == 35 && x == 50 ) begin oled_data <= 16'hCE79; end
        if ( y == 35 && x == 51 ) begin oled_data <= 16'hEF5D; end
        if ( y == 35 && x == 52 ) begin oled_data <= 16'hAD55; end
        if ( y == 35 && x == 53 ) begin oled_data <= 16'hAD75; end
        if ( y == 35 && x == 54 ) begin oled_data <= 16'hBDD7; end
        if ( y == 35 && x == 55 ) begin oled_data <= 16'hFFFF; end
        if ( y == 35 && x == 56 ) begin oled_data <= 16'h8430; end
        if ( y == 35 && x == 60 ) begin oled_data <= 16'h4A69; end
        if ( y == 35 && x == 61 ) begin oled_data <= 16'hD6BA; end
        if ( y == 35 && x == 62 ) begin oled_data <= 16'hDEDB; end
        if ( y == 35 && x == 63 ) begin oled_data <= 16'h528A; end
        if ( y == 35 && x == 66 ) begin oled_data <= 16'h3186; end
        if ( y == 35 && x >= 67 && x <= 68 ) begin oled_data <= 16'hFFFF; end
        if ( y == 35 && x == 69 ) begin oled_data <= 16'hBDF7; end
        if ( y == 35 && x == 70 ) begin oled_data <= 16'hAD75; end
        if ( y == 35 && x == 71 ) begin oled_data <= 16'hB596; end
        if ( y == 35 && x == 72 ) begin oled_data <= 16'hAD75; end
        if ( y == 35 && x == 73 ) begin oled_data <= 16'hBDD7; end
        if ( y == 35 && x == 74 ) begin oled_data <= 16'h738E; end
        if ( y == 35 && x == 75 ) begin oled_data <= 16'h8C51; end
        if ( y == 35 && x == 76 ) begin oled_data <= 16'hFFFF; end
        if ( y == 35 && x == 77 ) begin oled_data <= 16'hBDD7; end
        if ( y == 35 && x == 79 ) begin oled_data <= 16'h8C51; end
        if ( y == 35 && x == 80 ) begin oled_data <= 16'hFFDF; end
        if ( y == 35 && x == 81 ) begin oled_data <= 16'hFFFF; end
        if ( y == 35 && x == 82 ) begin oled_data <= 16'hD6BA; end
        if ( y == 35 && x == 83 ) begin oled_data <= 16'h39C7; end
        if ( y == 36 && x == 12 ) begin oled_data <= 16'h0861; end
        if ( y == 36 && x == 13 ) begin oled_data <= 16'h73AE; end
        if ( y == 36 && x >= 14 && x <= 15 ) begin oled_data <= 16'h8C71; end
        if ( y == 36 && x == 16 ) begin oled_data <= 16'h7BEF; end
        if ( y == 36 && x == 17 ) begin oled_data <= 16'h8430; end
        if ( y == 36 && x == 18 ) begin oled_data <= 16'h31A6; end
        if ( y == 36 && x == 19 ) begin oled_data <= 16'h4228; end
        if ( y == 36 && x == 20 ) begin oled_data <= 16'h8C71; end
        if ( y == 36 && x == 21 ) begin oled_data <= 16'h528A; end
        if ( y == 36 && x == 25 ) begin oled_data <= 16'h73AE; end
        if ( y == 36 && x == 26 ) begin oled_data <= 16'h8410; end
        if ( y == 36 && x == 27 ) begin oled_data <= 16'h2945; end
        if ( y == 36 && x == 28 ) begin oled_data <= 16'h6B4D; end
        if ( y == 36 && x == 29 ) begin oled_data <= 16'h8C51; end
        if ( y == 36 && x == 30 ) begin oled_data <= 16'h39C7; end
        if ( y == 36 && x == 33 ) begin oled_data <= 16'h2124; end
        if ( y == 36 && x == 34 ) begin oled_data <= 16'h8430; end
        if ( y == 36 && x == 35 ) begin oled_data <= 16'h6B6D; end
        if ( y == 36 && x == 36 ) begin oled_data <= 16'h2965; end
        if ( y == 36 && x >= 37 && x <= 38 ) begin oled_data <= 16'h7BEF; end
        if ( y == 36 && x == 39 ) begin oled_data <= 16'h8C51; end
        if ( y == 36 && x >= 40 && x <= 42 ) begin oled_data <= 16'h8C71; end
        if ( y == 36 && x == 43 ) begin oled_data <= 16'h9492; end
        if ( y == 36 && x == 44 ) begin oled_data <= 16'h738E; end
        if ( y == 36 && x == 50 ) begin oled_data <= 16'h31A6; end
        if ( y == 36 && x >= 51 && x <= 52 ) begin oled_data <= 16'h8C51; end
        if ( y == 36 && x == 53 ) begin oled_data <= 16'h8C71; end
        if ( y == 36 && x == 54 ) begin oled_data <= 16'h8C51; end
        if ( y == 36 && x == 55 ) begin oled_data <= 16'h7BCF; end
        if ( y == 36 && x == 61 ) begin oled_data <= 16'h4A49; end
        if ( y == 36 && x == 62 ) begin oled_data <= 16'h4A69; end
        if ( y == 36 && x >= 67 && x <= 68 ) begin oled_data <= 16'h7BEF; end
        if ( y == 36 && x == 69 ) begin oled_data <= 16'h8C51; end
        if ( y == 36 && x >= 70 && x <= 71 ) begin oled_data <= 16'h8C71; end
        if ( y == 36 && x == 72 ) begin oled_data <= 16'h8C51; end
        if ( y == 36 && x == 73 ) begin oled_data <= 16'h94B2; end
        if ( y == 36 && x == 74 ) begin oled_data <= 16'h630C; end
        if ( y == 36 && x == 75 ) begin oled_data <= 16'h39E7; end
        if ( y == 36 && x == 76 ) begin oled_data <= 16'h8C71; end
        if ( y == 36 && x == 77 ) begin oled_data <= 16'h5AEB; end
        if ( y == 36 && x == 79 ) begin oled_data <= 16'h0861; end
        if ( y == 36 && x == 80 ) begin oled_data <= 16'h73AE; end
        if ( y == 36 && x == 81 ) begin oled_data <= 16'h7BCF; end
        if ( y == 36 && x == 82 ) begin oled_data <= 16'h8C71; end
        if ( y == 36 && x == 83 ) begin oled_data <= 16'h31A6; end
        end
        if (megamanWin == 1)
        begin
        oled_data <= 16'h0000;
        if (((pixel_index % 96 > 17 && pixel_index % 96 < 22) &&(pixel_index / 96 > 15 && pixel_index / 96 < 46)) ||
                        ((pixel_index % 96 > 21 && pixel_index % 96 < 26) &&(pixel_index / 96 > 35 && pixel_index / 96 < 46)) || 
                        ((pixel_index % 96 > 25 && pixel_index % 96 < 28) &&(pixel_index / 96 > 35 && pixel_index / 96 < 42)) ||
                        ((pixel_index % 96 > 27 && pixel_index % 96 < 30) &&(pixel_index / 96 > 31 && pixel_index / 96 < 39)) ||
                        ((pixel_index % 96 > 29 && pixel_index % 96 < 32) &&(pixel_index / 96 > 35 && pixel_index / 96 < 42)) ||
                        ((pixel_index % 96 > 31 && pixel_index % 96 < 36) &&(pixel_index / 96 > 35 && pixel_index / 96 < 46)) ||
                        ((pixel_index % 96 > 35 && pixel_index % 96 < 40) &&(pixel_index / 96 > 15 && pixel_index / 96 < 46)) ||
                        ((pixel_index % 96 > 45 && pixel_index % 96 < 50) &&(pixel_index / 96 > 15 && pixel_index / 96 < 46)) ||
                        ((pixel_index % 96 > 55 && pixel_index % 96 < 60) &&(pixel_index / 96 > 15 && pixel_index / 96 < 46)) ||
                        ((pixel_index % 96 > 59 && pixel_index % 96 < 62) &&(pixel_index / 96 > 17 && pixel_index / 96 < 26)) ||
                        ((pixel_index % 96 > 61 && pixel_index % 96 < 64) &&(pixel_index / 96 > 20 && pixel_index / 96 < 29)) ||
                        ((pixel_index % 96 > 63 && pixel_index % 96 < 66) &&(pixel_index / 96 > 23 && pixel_index / 96 < 33)) ||
                        ((pixel_index % 96 > 65 && pixel_index % 96 < 68) &&(pixel_index / 96 > 27 && pixel_index / 96 < 36)) ||
                        ((pixel_index % 96 > 67 && pixel_index % 96 < 70) &&(pixel_index / 96 > 30 && pixel_index / 96 < 40)) ||
                        ((pixel_index % 96 > 69 && pixel_index % 96 < 72) &&(pixel_index / 96 > 33 && pixel_index / 96 < 44)) ||
                        ((pixel_index % 96 > 71 && pixel_index % 96 < 76) &&(pixel_index / 96 > 15 && pixel_index / 96 < 46)))
                        oled_data <= 16'hFFFF;
        end
    end
    end
    
    //Volume bar
    else if (sw[11] == 0 && sw[12] == 0 && sw[10] == 0)
    begin
        oled_data <= 16'h0000;
        dead <= 0;
        gameStart <= 1;
        virus_counter <= 0;
        virus_clock <= 0;
        gameover_counter <= 0;
        winCounter <= 0;
        virus_death_counter <= 0;
        finalGameStart <= 1;
        marioWin <= 0;
        megamanWin <= 0;
        megaman_health_clock <= 0;
        mario_health_clock <= 0;
        megaman_health_counter <= 0;
        mario_health_counter <= 0;
                //volume bar
                case (display_scheme)
                    //default: black background
                    2'b00: oled_data <= 16'b0000000000000000;
                    //2nd scheme: white background
                    2'b01: oled_data <= 16'b1111111111111111;
                    //3rd scheme: turquoise background
                    2'b10: oled_data <= 16'h07F7;
                endcase   
                case (display_border)
                    2'b01: begin    
                        if ((pixel_index < 96) || (pixel_index % 96 == 0) || (pixel_index > 6048) || (pixel_index % 96 == 95)) begin
                            case (display_scheme)
                                //default: white border
                                2'b00: oled_data <= 16'b1111111111111111;
                                //2nd scheme: pink border
                                2'b01: oled_data <= 16'hF817;
                                //3rd scheme: purple border
                                2'b10: oled_data <= 16'hD81F;
                            endcase
                        end        
                    end
                    2'b10: begin
                        if ((pixel_index / 96 < 3) || (pixel_index / 96 > 60) || (pixel_index % 96 < 3) || (pixel_index % 96 > 92)) begin
                            case (display_scheme)
                                //default: white border
                                2'b00: oled_data <= 16'b1111111111111111;
                                //2nd scheme: pink border
                                2'b01: oled_data <= 16'hDA53;
                                //3rd scheme: purple border
                                2'b10: oled_data <= 16'hD81F;
                            endcase
                        end        
                    end        
                endcase
                case (display_mode)
                    2'b01: begin
                        case (led_count)
                            5'd1: begin
                                if (display_border == 2'd0 || display_border == 2'd1) begin
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 59 && pixel_index / 96 < 63)) begin
                                        case (display_scheme)
                                        //default: green bar
                                        2'b00: oled_data <= 16'h27E0;
                                        //2nd scheme: blue bar
                                        2'b01: oled_data <= 16'h073F;
                                        //3rd scheme: white bar
                                        2'b10: oled_data <= 16'hFFFF;
                                        endcase
                                    end  
                                end    
                                if (display_border == 2'd2) begin
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 57 && pixel_index / 96 < 61)) begin
                                        case (display_scheme)
                                        //default: green bar
                                        2'b00: oled_data <= 16'h27E0;
                                        //2nd scheme: blue bar
                                        2'b01: oled_data <= 16'h073F;
                                        //3rd scheme: white bar
                                        2'b10: oled_data <= 16'hFFFF;
                                        endcase
                                    end
                                end                                 
                            end
                            5'd2: begin
                                if (display_border == 2'd0 || display_border == 2'd1) begin
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 56 && pixel_index / 96 < 63)) begin
                                        case (display_scheme)
                                        //default: green bar
                                        2'b00: oled_data <= 16'h27E0;
                                        //2nd scheme: blue bar
                                        2'b01: oled_data <= 16'h073F;
                                        //3rd scheme: white bar
                                        2'b10: oled_data <= 16'hFFFF;
                                        endcase
                                    end  
                                end    
                                if (display_border == 2'd2) begin
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 54 && pixel_index / 96 < 61)) begin
                                        case (display_scheme)
                                        //default: green bar
                                        2'b00: oled_data <= 16'h27E0;
                                        //2nd scheme: blue bar
                                        2'b01: oled_data <= 16'h073F;
                                        //3rd scheme: white bar
                                        2'b10: oled_data <= 16'hFFFF;
                                        endcase
                                    end
                                end
                            end                                    
                            5'd3: begin
                                if (display_border == 2'd0 || display_border == 2'd1) begin
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 52 && pixel_index / 96 < 63)) begin
                                        case (display_scheme)
                                        //default: green bar
                                        2'b00: oled_data <= 16'h27E0;
                                        //2nd scheme: blue bar
                                        2'b01: oled_data <= 16'h073F;
                                        //3rd scheme: white bar
                                        2'b10: oled_data <= 16'hFFFF;
                                        endcase
                                    end  
                                end    
                                if (display_border == 2'd2) begin
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 51 && pixel_index / 96 < 61)) begin
                                        case (display_scheme)
                                        //default: green bar
                                        2'b00: oled_data <= 16'h27E0;
                                        //2nd scheme: blue bar
                                        2'b01: oled_data <= 16'h073F;
                                        //3rd scheme: white bar
                                        2'b10: oled_data <= 16'hFFFF;
                                        endcase
                                    end
                                end
                            end                                    
                            5'd4: begin
                                if (display_border == 2'd0 || display_border == 2'd1) begin
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 48 && pixel_index / 96 < 63)) begin
                                        case (display_scheme)
                                        //default: green bar
                                        2'b00: oled_data <= 16'h27E0;
                                        //2nd scheme: blue bar
                                        2'b01: oled_data <= 16'h073F;
                                        //3rd scheme: white bar
                                        2'b10: oled_data <= 16'hFFFF;
                                        endcase
                                    end  
                                end    
                                if (display_border == 2'd2) begin
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 48 && pixel_index / 96 < 61)) begin
                                        case (display_scheme)
                                        //default: green bar
                                        2'b00: oled_data <= 16'h27E0;
                                        //2nd scheme: blue bar
                                        2'b01: oled_data <= 16'h073F;
                                        //3rd scheme: white bar
                                        2'b10: oled_data <= 16'hFFFF;
                                        endcase
                                    end
                                end
                            end                                    
                            5'd5: begin
                                if (display_border == 2'd0 || display_border == 2'd1) begin
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 44 && pixel_index / 96 < 63)) begin
                                        case (display_scheme)
                                        //default: green bar
                                        2'b00: oled_data <= 16'h27E0;
                                        //2nd scheme: blue bar
                                        2'b01: oled_data <= 16'h073F;
                                        //3rd scheme: white bar
                                        2'b10: oled_data <= 16'hFFFF;
                                        endcase
                                    end  
                                end    
                                if (display_border == 2'd2) begin
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 45 && pixel_index / 96 < 61)) begin
                                        case (display_scheme)
                                        //default: green bar
                                        2'b00: oled_data <= 16'h27E0;
                                        //2nd scheme: blue bar
                                        2'b01: oled_data <= 16'h073F;
                                        //3rd scheme: white bar
                                        2'b10: oled_data <= 16'hFFFF;
                                        endcase
                                    end
                                end
                            end                                    
                            5'd6: begin
                                if (display_border == 2'd0 || display_border == 2'd1) begin
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 40 && pixel_index / 96 < 63)) begin
                                        case (display_scheme)
                                        //default: green bar
                                        2'b00: oled_data <= 16'h27E0;
                                        //2nd scheme: blue bar
                                        2'b01: oled_data <= 16'h073F;
                                        //3rd scheme: white bar
                                        2'b10: oled_data <= 16'hFFFF;
                                        endcase
                                    end  
                                end    
                                if (display_border == 2'd2) begin
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 42 && pixel_index / 96 < 61)) begin
                                        case (display_scheme)
                                        //default: green bar
                                        2'b00: oled_data <= 16'h27E0;
                                        //2nd scheme: blue bar
                                        2'b01: oled_data <= 16'h073F;
                                        //3rd scheme: white bar
                                        2'b10: oled_data <= 16'hFFFF;
                                        endcase
                                    end
                                end
                            end                                    
                            5'd7: begin
                                if (display_border == 2'd0 || display_border == 2'd1) begin
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 40 && pixel_index / 96 < 63)) begin
                                        case (display_scheme)
                                        //default: green bar
                                        2'b00: oled_data <= 16'h27E0;
                                        //2nd scheme: blue bar
                                        2'b01: oled_data <= 16'h073F;
                                        //3rd scheme: white bar
                                        2'b10: oled_data <= 16'hFFFF;
                                        endcase
                                    end  
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 36 && pixel_index / 96 < 41)) begin
                                        case (display_scheme)
                                        //default: yellow bar
                                        2'b00: oled_data <= 16'hFFC0;
                                        //2nd scheme: purple bar
                                        2'b01: oled_data <= 16'h801F;
                                        //3rd scheme: orange bar
                                        2'b10: oled_data <= 16'hFCE0;
                                        endcase
                                    end  
                                end    
                                if (display_border == 2'd2) begin
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 42 && pixel_index / 96 < 61)) begin
                                        case (display_scheme)
                                        //default: green bar
                                        2'b00: oled_data <= 16'h27E0;
                                        //2nd scheme: blue bar
                                        2'b01: oled_data <= 16'h073F;
                                        //3rd scheme: white bar
                                        2'b10: oled_data <= 16'hFFFF;
                                        endcase
                                    end
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 38 && pixel_index / 96 < 43)) begin
                                        case (display_scheme)
                                        //default: yellow bar
                                        2'b00: oled_data <= 16'hFFC0;
                                        //2nd scheme: purple bar
                                        2'b01: oled_data <= 16'h801F;
                                        //3rd scheme: orange bar
                                        2'b10: oled_data <= 16'hFCE0;
                                        endcase
                                    end
                                end
                            end                                    
                            5'd8: begin
                                if (display_border == 2'd0 || display_border == 2'd1) begin
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 40 && pixel_index / 96 < 63)) begin
                                        case (display_scheme)
                                        //default: green bar
                                        2'b00: oled_data <= 16'h27E0;
                                        //2nd scheme: blue bar
                                        2'b01: oled_data <= 16'h073F;
                                        //3rd scheme: white bar
                                        2'b10: oled_data <= 16'hFFFF;
                                        endcase
                                    end  
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 32 && pixel_index / 96 < 41)) begin
                                        case (display_scheme)
                                        //default: yellow bar
                                        2'b00: oled_data <= 16'hFFC0;
                                        //2nd scheme: purple bar
                                        2'b01: oled_data <= 16'h801F;
                                        //3rd scheme: orange bar
                                        2'b10: oled_data <= 16'hFCE0;
                                        endcase
                                    end  
                                end    
                                if (display_border == 2'd2) begin
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 42 && pixel_index / 96 < 61)) begin
                                        case (display_scheme)
                                        //default: green bar
                                        2'b00: oled_data <= 16'h27E0;
                                        //2nd scheme: blue bar
                                        2'b01: oled_data <= 16'h073F;
                                        //3rd scheme: white bar
                                        2'b10: oled_data <= 16'hFFFF;
                                        endcase
                                    end
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 34 && pixel_index / 96 < 43)) begin
                                        case (display_scheme)
                                        //default: yellow bar
                                        2'b00: oled_data <= 16'hFFC0;
                                        //2nd scheme: purple bar
                                        2'b01: oled_data <= 16'h801F;
                                        //3rd scheme: orange bar
                                        2'b10: oled_data <= 16'hFCE0;
                                        endcase
                                    end
                                end
                            end                                    
                            5'd9: begin
                                if (display_border == 2'd0 || display_border == 2'd1) begin
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 40 && pixel_index / 96 < 63)) begin
                                        case (display_scheme)
                                        //default: green bar
                                        2'b00: oled_data <= 16'h27E0;
                                        //2nd scheme: blue bar
                                        2'b01: oled_data <= 16'h073F;
                                        //3rd scheme: white bar
                                        2'b10: oled_data <= 16'hFFFF;
                                        endcase
                                    end  
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 28 && pixel_index / 96 < 41)) begin
                                        case (display_scheme)
                                        //default: yellow bar
                                        2'b00: oled_data <= 16'hFFC0;
                                        //2nd scheme: purple bar
                                        2'b01: oled_data <= 16'h801F;
                                        //3rd scheme: orange bar
                                        2'b10: oled_data <= 16'hFCE0;
                                        endcase
                                    end  
                                end    
                                if (display_border == 2'd2) begin
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 42 && pixel_index / 96 < 61)) begin
                                        case (display_scheme)
                                        //default: green bar
                                        2'b00: oled_data <= 16'h27E0;
                                        //2nd scheme: blue bar
                                        2'b01: oled_data <= 16'h073F;
                                        //3rd scheme: white bar
                                        2'b10: oled_data <= 16'hFFFF;
                                        endcase
                                    end
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 30 && pixel_index / 96 < 43)) begin
                                        case (display_scheme)
                                        //default: yellow bar
                                        2'b00: oled_data <= 16'hFFC0;
                                        //2nd scheme: purple bar
                                        2'b01: oled_data <= 16'h801F;
                                        //3rd scheme: orange bar
                                        2'b10: oled_data <= 16'hFCE0;
                                        endcase
                                    end
                                end
                            end                                    
                            5'd10: begin
                                if (display_border == 2'd0 || display_border == 2'd1) begin
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 40 && pixel_index / 96 < 63)) begin
                                        case (display_scheme)
                                        //default: green bar
                                        2'b00: oled_data <= 16'h27E0;
                                        //2nd scheme: blue bar
                                        2'b01: oled_data <= 16'h073F;
                                        //3rd scheme: white bar
                                        2'b10: oled_data <= 16'hFFFF;
                                        endcase
                                    end  
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 24 && pixel_index / 96 < 41)) begin
                                        case (display_scheme)
                                        //default: yellow bar
                                        2'b00: oled_data <= 16'hFFC0;
                                        //2nd scheme: purple bar
                                        2'b01: oled_data <= 16'h801F;
                                        //3rd scheme: orange bar
                                        2'b10: oled_data <= 16'hFCE0;
                                        endcase
                                    end  
                                end    
                                if (display_border == 2'd2) begin
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 42 && pixel_index / 96 < 61)) begin
                                        case (display_scheme)
                                        //default: green bar
                                        2'b00: oled_data <= 16'h27E0;
                                        //2nd scheme: blue bar
                                        2'b01: oled_data <= 16'h073F;
                                        //3rd scheme: white bar
                                        2'b10: oled_data <= 16'hFFFF;
                                        endcase
                                    end
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 26 && pixel_index / 96 < 43)) begin
                                        case (display_scheme)
                                        //default: yellow bar
                                        2'b00: oled_data <= 16'hFFC0;
                                        //2nd scheme: purple bar
                                        2'b01: oled_data <= 16'h801F;
                                        //3rd scheme: orange bar
                                        2'b10: oled_data <= 16'hFCE0;
                                        endcase
                                    end
                                end
                            end                                    
                            5'd11: begin
                                if (display_border == 2'd0 || display_border == 2'd1) begin
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 40 && pixel_index / 96 < 63)) begin
                                        case (display_scheme)
                                        //default: green bar
                                        2'b00: oled_data <= 16'h27E0;
                                        //2nd scheme: blue bar
                                        2'b01: oled_data <= 16'h073F;
                                        //3rd scheme: white bar
                                        2'b10: oled_data <= 16'hFFFF;
                                        endcase
                                    end  
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 20 && pixel_index / 96 < 41)) begin
                                        case (display_scheme)
                                        //default: yellow bar
                                        2'b00: oled_data <= 16'hFFC0;
                                        //2nd scheme: purple bar
                                        2'b01: oled_data <= 16'h801F;
                                        //3rd scheme: orange bar
                                        2'b10: oled_data <= 16'hFCE0;
                                        endcase
                                    end  
                                end    
                                if (display_border == 2'd2) begin
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 42 && pixel_index / 96 < 61)) begin
                                        case (display_scheme)
                                        //default: green bar
                                        2'b00: oled_data <= 16'h27E0;
                                        //2nd scheme: blue bar
                                        2'b01: oled_data <= 16'h073F;
                                        //3rd scheme: white bar
                                        2'b10: oled_data <= 16'hFFFF;
                                        endcase
                                    end
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 22 && pixel_index / 96 < 43)) begin
                                        case (display_scheme)
                                        //default: yellow bar
                                        2'b00: oled_data <= 16'hFFC0;
                                        //2nd scheme: purple bar
                                        2'b01: oled_data <= 16'h801F;
                                        //3rd scheme: orange bar
                                        2'b10: oled_data <= 16'hFCE0;
                                        endcase
                                    end
                                end
                            end                                    
                            5'd12: begin
                                if (display_border == 2'd0 || display_border == 2'd1) begin
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 40 && pixel_index / 96 < 63)) begin
                                        case (display_scheme)
                                        //default: green bar
                                        2'b00: oled_data <= 16'h27E0;
                                        //2nd scheme: blue bar
                                        2'b01: oled_data <= 16'h073F;
                                        //3rd scheme: white bar
                                        2'b10: oled_data <= 16'hFFFF;
                                        endcase
                                    end  
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 20 && pixel_index / 96 < 41)) begin
                                        case (display_scheme)
                                        //default: yellow bar
                                        2'b00: oled_data <= 16'hFFC0;
                                        //2nd scheme: purple bar
                                        2'b01: oled_data <= 16'h801F;
                                        //3rd scheme: orange bar
                                        2'b10: oled_data <= 16'hFCE0;
                                        endcase
                                    end  
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 16 && pixel_index / 96 < 21)) begin
                                        case (display_scheme)
                                        //default: red bar
                                        2'b00: oled_data <= 16'hF800;
                                        //2nd scheme: pink bar
                                        2'b01: oled_data <= 16'hF810;
                                        //3rd scheme: black bar
                                        2'b10: oled_data <= 16'h0000;
                                        endcase
                                    end  
                                end    
                                if (display_border == 2'd2) begin
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 42 && pixel_index / 96 < 61)) begin
                                        case (display_scheme)
                                        //default: green bar
                                        2'b00: oled_data <= 16'h27E0;
                                        //2nd scheme: blue bar
                                        2'b01: oled_data <= 16'h073F;
                                        //3rd scheme: white bar
                                        2'b10: oled_data <= 16'hFFFF;
                                        endcase
                                    end
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 22 && pixel_index / 96 < 43)) begin
                                        case (display_scheme)
                                        //default: yellow bar
                                        2'b00: oled_data <= 16'hFFC0;
                                        //2nd scheme: purple bar
                                        2'b01: oled_data <= 16'h801F;
                                        //3rd scheme: orange bar
                                        2'b10: oled_data <= 16'hFCE0;
                                        endcase
                                    end
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 18 && pixel_index / 96 < 23)) begin
                                        case (display_scheme)
                                        //default: red bar
                                        2'b00: oled_data <= 16'hF800;
                                        //2nd scheme: pink bar
                                        2'b01: oled_data <= 16'hF810;
                                        //3rd scheme: black bar
                                        2'b10: oled_data <= 16'h0000;
                                        endcase
                                    end  
                                end
                            end                                    
                            5'd13: begin
                                if (display_border == 2'd0 || display_border == 2'd1) begin
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 40 && pixel_index / 96 < 63)) begin
                                        case (display_scheme)
                                        //default: green bar
                                        2'b00: oled_data <= 16'h27E0;
                                        //2nd scheme: blue bar
                                        2'b01: oled_data <= 16'h073F;
                                        //3rd scheme: white bar
                                        2'b10: oled_data <= 16'hFFFF;
                                        endcase
                                    end  
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 20 && pixel_index / 96 < 41)) begin
                                        case (display_scheme)
                                        //default: yellow bar
                                        2'b00: oled_data <= 16'hFFC0;
                                        //2nd scheme: purple bar
                                        2'b01: oled_data <= 16'h801F;
                                        //3rd scheme: orange bar
                                        2'b10: oled_data <= 16'hFCE0;
                                        endcase
                                    end  
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 12 && pixel_index / 96 < 21)) begin
                                        case (display_scheme)
                                        //default: red bar
                                        2'b00: oled_data <= 16'hF800;
                                        //2nd scheme: pink bar
                                        2'b01: oled_data <= 16'hF810;
                                        //3rd scheme: black bar
                                        2'b10: oled_data <= 16'h0000;
                                        endcase
                                    end  
                                end    
                                if (display_border == 2'd2) begin
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 42 && pixel_index / 96 < 61)) begin
                                        case (display_scheme)
                                        //default: green bar
                                        2'b00: oled_data <= 16'h27E0;
                                        //2nd scheme: blue bar
                                        2'b01: oled_data <= 16'h073F;
                                        //3rd scheme: white bar
                                        2'b10: oled_data <= 16'hFFFF;
                                        endcase
                                    end
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 22 && pixel_index / 96 < 43)) begin
                                        case (display_scheme)
                                        //default: yellow bar
                                        2'b00: oled_data <= 16'hFFC0;
                                        //2nd scheme: purple bar
                                        2'b01: oled_data <= 16'h801F;
                                        //3rd scheme: orange bar
                                        2'b10: oled_data <= 16'hFCE0;
                                        endcase
                                    end
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 14 && pixel_index / 96 < 23)) begin
                                        case (display_scheme)
                                        //default: red bar
                                        2'b00: oled_data <= 16'hF800;
                                        //2nd scheme: pink bar
                                        2'b01: oled_data <= 16'hF810;
                                        //3rd scheme: black bar
                                        2'b10: oled_data <= 16'h0000;
                                        endcase
                                    end  
                                end
                            end                                    
                            5'd14: begin
                                if (display_border == 2'd0 || display_border == 2'd1) begin
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 40 && pixel_index / 96 < 63)) begin
                                        case (display_scheme)
                                        //default: green bar
                                        2'b00: oled_data <= 16'h27E0;
                                        //2nd scheme: blue bar
                                        2'b01: oled_data <= 16'h073F;
                                        //3rd scheme: white bar
                                        2'b10: oled_data <= 16'hFFFF;
                                        endcase
                                    end  
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 20 && pixel_index / 96 < 41)) begin
                                        case (display_scheme)
                                        //default: yellow bar
                                        2'b00: oled_data <= 16'hFFC0;
                                        //2nd scheme: purple bar
                                        2'b01: oled_data <= 16'h801F;
                                        //3rd scheme: orange bar
                                        2'b10: oled_data <= 16'hFCE0;
                                        endcase
                                    end  
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 8 && pixel_index / 96 < 21)) begin
                                        case (display_scheme)
                                        //default: red bar
                                        2'b00: oled_data <= 16'hF800;
                                        //2nd scheme: pink bar
                                        2'b01: oled_data <= 16'hF810;
                                        //3rd scheme: black bar
                                        2'b10: oled_data <= 16'h0000;
                                        endcase
                                    end  
                                end    
                                if (display_border == 2'd2) begin
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 42 && pixel_index / 96 < 61)) begin
                                        case (display_scheme)
                                        //default: green bar
                                        2'b00: oled_data <= 16'h27E0;
                                        //2nd scheme: blue bar
                                        2'b01: oled_data <= 16'h073F;
                                        //3rd scheme: white bar
                                        2'b10: oled_data <= 16'hFFFF;
                                        endcase
                                    end
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 22 && pixel_index / 96 < 43)) begin
                                        case (display_scheme)
                                        //default: yellow bar
                                        2'b00: oled_data <= 16'hFFC0;
                                        //2nd scheme: purple bar
                                        2'b01: oled_data <= 16'h801F;
                                        //3rd scheme: orange bar
                                        2'b10: oled_data <= 16'hFCE0;
                                        endcase
                                    end
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 10 && pixel_index / 96 < 23)) begin
                                        case (display_scheme)
                                        //default: red bar
                                        2'b00: oled_data <= 16'hF800;
                                        //2nd scheme: pink bar
                                        2'b01: oled_data <= 16'hF810;
                                        //3rd scheme: black bar
                                        2'b10: oled_data <= 16'h0000;
                                        endcase
                                    end  
                                end
                            end                                    
                            5'd15: begin
                                if (display_border == 2'd0 || display_border == 2'd1) begin
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 40 && pixel_index / 96 < 63)) begin
                                        case (display_scheme)
                                        //default: green bar
                                        2'b00: oled_data <= 16'h27E0;
                                        //2nd scheme: blue bar
                                        2'b01: oled_data <= 16'h073F;
                                        //3rd scheme: white bar
                                        2'b10: oled_data <= 16'hFFFF;
                                        endcase
                                    end  
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 20 && pixel_index / 96 < 41)) begin
                                        case (display_scheme)
                                        //default: yellow bar
                                        2'b00: oled_data <= 16'hFFC0;
                                        //2nd scheme: purple bar
                                        2'b01: oled_data <= 16'h801F;
                                        //3rd scheme: orange bar
                                        2'b10: oled_data <= 16'hFCE0;
                                        endcase
                                    end  
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 4 && pixel_index / 96 < 21)) begin
                                        case (display_scheme)
                                        //default: red bar
                                        2'b00: oled_data <= 16'hF800;
                                        //2nd scheme: pink bar
                                        2'b01: oled_data <= 16'hF810;
                                        //3rd scheme: black bar
                                        2'b10: oled_data <= 16'h0000;
                                        endcase
                                    end  
                                end    
                                if (display_border == 2'd2) begin
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 42 && pixel_index / 96 < 61)) begin
                                        case (display_scheme)
                                        //default: green bar
                                        2'b00: oled_data <= 16'h27E0;
                                        //2nd scheme: blue bar
                                        2'b01: oled_data <= 16'h073F;
                                        //3rd scheme: white bar
                                        2'b10: oled_data <= 16'hFFFF;
                                        endcase
                                    end
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 22 && pixel_index / 96 < 43)) begin
                                        case (display_scheme)
                                        //default: yellow bar
                                        2'b00: oled_data <= 16'hFFC0;
                                        //2nd scheme: purple bar
                                        2'b01: oled_data <= 16'h801F;
                                        //3rd scheme: orange bar
                                        2'b10: oled_data <= 16'hFCE0;
                                        endcase
                                    end
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 6 && pixel_index / 96 < 23)) begin
                                        case (display_scheme)
                                        //default: red bar
                                        2'b00: oled_data <= 16'hF800;
                                        //2nd scheme: pink bar
                                        2'b01: oled_data <= 16'hF810;
                                        //3rd scheme: black bar
                                        2'b10: oled_data <= 16'h0000;
                                        endcase
                                    end  
                                end
                            end                                    
                            5'd16: begin
                                if (display_border == 2'd0 || display_border == 2'd1) begin
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 40 && pixel_index / 96 < 63)) begin
                                        case (display_scheme)
                                        //default: green bar
                                        2'b00: oled_data <= 16'h27E0;
                                        //2nd scheme: blue bar
                                        2'b01: oled_data <= 16'h073F;
                                        //3rd scheme: white bar
                                        2'b10: oled_data <= 16'hFFFF;
                                        endcase
                                    end  
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 20 && pixel_index / 96 < 41)) begin
                                        case (display_scheme)
                                        //default: yellow bar
                                        2'b00: oled_data <= 16'hFFC0;
                                        //2nd scheme: purple bar
                                        2'b01: oled_data <= 16'h801F;
                                        //3rd scheme: orange bar
                                        2'b10: oled_data <= 16'hFCE0;
                                        endcase
                                    end  
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 0 && pixel_index / 96 < 21)) begin
                                        case (display_scheme)
                                        //default: red bar
                                        2'b00: oled_data <= 16'hF800;
                                        //2nd scheme: pink bar
                                        2'b01: oled_data <= 16'hF810;
                                        //3rd scheme: black bar
                                        2'b10: oled_data <= 16'h0000;
                                        endcase
                                    end  
                                end    
                                if (display_border == 2'd2) begin
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 42 && pixel_index / 96 < 61)) begin
                                        case (display_scheme)
                                        //default: green bar
                                        2'b00: oled_data <= 16'h27E0;
                                        //2nd scheme: blue bar
                                        2'b01: oled_data <= 16'h073F;
                                        //3rd scheme: white bar
                                        2'b10: oled_data <= 16'hFFFF;
                                        endcase
                                    end
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 22 && pixel_index / 96 < 43)) begin
                                        case (display_scheme)
                                        //default: yellow bar
                                        2'b00: oled_data <= 16'hFFC0;
                                        //2nd scheme: purple bar
                                        2'b01: oled_data <= 16'h801F;
                                        //3rd scheme: orange bar
                                        2'b10: oled_data <= 16'hFCE0;
                                        endcase
                                    end
                                    if ((pixel_index % 96 > 43 && pixel_index % 96 < 54) && (pixel_index / 96 > 2 && pixel_index / 96 < 23)) begin
                                        case (display_scheme)
                                        //default: red bar
                                        2'b00: oled_data <= 16'hF800;
                                        //2nd scheme: pink bar
                                        2'b01: oled_data <= 16'hF810;
                                        //3rd scheme: black bar
                                        2'b10: oled_data <= 16'h0000;
                                        endcase
                                    end  
                                end                                    
                            end
                       endcase
                    end   
                endcase                        
    end      
    end    

endmodule