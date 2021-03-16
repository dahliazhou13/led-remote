`default_nettype none
module test(input[2:0] r, input[2:0] g, input[2:0] b, input mode, input up, input down,
  input  clk,
  output reg led, output[6:0] svg, output[6:0] neg_sign
  );
  // Neopixel state machine.
  reg [2:0] state;
  reg [1:0] npxc;
  reg [12:0] lpxc;
  reg [7:0] bits;
  reg [7:0] led_num;
  
  reg[3:0] bg_level = 4'd0;
  
  
  wire[7:0] rw;
  wire[7:0] gw;
  wire[7:0] bw;
  
  //if the display is negative
  reg neg = 0;
  
  wire[1:0] u_s;//up state
  wire[1:0] d_s; //down state
  
  parameter D = 5000000;
  
  reg[31:0] count = 32'd0;
  
  convert(r,rw);
  convert(g,gw);
  convert(b, bw);
  display(bg_level, svg);
  //assign_value(rw,gw,bw,test_color);
  
  
  //display negative sign
  second_display(neg, neg_sign);
  
  //BRG
  reg [24:0] test_color;
  
  //call on upController to update up state
  upController(clk, up, u_s, u_s);
  //call on downController to update down state
  downController(clk, down, d_s, d_s);
  
//  always @(negedge up or negedge down)
//  begin
//		if(up == 0)
//		begin
//			if(bg_level < 4) bg_level <= bg_level + 1;
//		end
//		else
//		begin
//			if(bg_level > 0) bg_level <= bg_level -1;
//		end
//		
//		
//  end
  
  // Process the state machine at each 12MHz clock edge.
  always@(posedge clk)
    begin
		
		count <= count + 1;
		if(count >= D) count <= 0;
		
		
		//if up_state is 2, we must update the bg_level
		if(u_s == 2'd2)
		begin
			if(bg_level == 4'd1 && neg == 1 )
			begin
				bg_level <= 4'd0;
				neg <= 0;
			end
			else if(bg_level == 4'd2 && neg == 1)
			begin
				bg_level <= 4'd1;
			end
			else if(bg_level < 4'd2) bg_level <= bg_level + 1;
		end
		
		//if down_state is 2, we must update the bg_level
		if(d_s == 2'd2)
		begin
			if(bg_level == 4'd1 && neg == 1 )
			begin
				bg_level <= 4'd2;
				
			end
			else if(bg_level == 4'd0)
			begin
				bg_level <= 4'd1;
				neg <= 1;
			end
			else if(bg_level > 4'd0 && !(bg_level == 4'd2 && neg == 1)) bg_level <= bg_level - 1;
		end
		

		
		
		if(bg_level == 3'd2 && neg == 0)
		// Full brightness
		begin
				test_color[23:16] <= bw;
				test_color[15:8] <= rw;
				test_color[7:0] <= gw;
		end
		else if(bg_level == 3'd1 && neg == 0)
		//7/8 brightness
		begin
			test_color[23:16] <= bw << 1;
			test_color[15:8] <= rw << 1;
			test_color[7:0] <= gw << 1;
			
		end
		
        else if(bg_level == 3'd0)
        // 3/4 brightness [0]
        begin
            test_color[23:16] <= bw << 2;
            test_color[15:8] <= rw << 2;
            test_color[7:0] <= gw << 2;
        end
        else if(bg_level == 3'd1 && neg == 1)
        // 5/8 brightness [-1]
        begin 
            test_color[23:16] <= bw << 3;
            test_color[15:8] <= rw << 3;
            test_color[7:0] <= gw << 3;
        end
        else if(bg_level == 3'd2 && neg == 1)
        // 1/2 brightness [-2]
        begin
            test_color[23:16] <= bw << 4;
            test_color[15:8] <= rw << 4;
            test_color[7:0] <= gw << 4;
        end
		
		
			if(mode == 1 && count < D/2) test_color <= 0;
			
			
      // Process the state machine; states 0-3 are the four WS2812B 'ticks',
      // each consisting of 83.33 * 4 ~= 333.33 nanoseconds. Four of those
      // ticks are then ~1333.33 nanoseconds long, and we can get close to
      // the ideal 1250ns period.
      // A '1' is 3 high periods followed by 1 low period (999.99/333.33 ns)
      // A '0' is 1 high period followed by 3 low periods (333.33/999.99 ns)
      if (state == 0 || state == 1 || state == 2 || state == 3)
        begin
          npxc = npxc + 1;
          if (npxc == 0)
            begin
              state = state + 1;
            end
        end
		  
      if (state == 4)
        begin
          bits = bits + 1;
			if (bits == 24)
            begin
              bits = 0;
              state = state + 1;
            end
          else
            begin
              state = 0;
            end
        end
      if (state == 5)
        begin
          led_num = led_num + 1;
          if (led_num == 60)
            begin
              led_num = 0;
              state = state + 1;
            end
          else
            begin
              state = 0;
            end
        end
      if (state == 6)
        begin
          lpxc = lpxc + 1;
          if (lpxc == 0)
            begin
              state = 0;
            end
        end
      // Set the correct pin state.
      if (test_color & (1 << bits))
        begin
        if (state == 0 || state == 1 || state == 2)
          begin
            led <= 1;
          end
        else if (state == 3 || state == 6)
          begin
            led <= 0;
          end
        end
      else
        begin
        if (state == 0)
          begin
            led <= 1;
          end
        else if (state == 1 || state == 2 || state == 3 || state == 6)
          begin
            led <= 0;
          end
      end
    end
endmodule

module convert(input[2:0] a, output[7:0] out);
	parameter D = 6'd36;
	assign out = a * D;
endmodule


//7-segment decoder
//This was written in the previous lab
module display(a,f);
input[3:0] a;
output[6:0] f;
wire a0,a1,a2,a3;

assign a0 = a[0];
assign a1 = a[1];
assign a2 = a[2];
assign a3 = a[3];

assign f[0] = (~a3&~a2&~a1&a0) | (~a3 & a2 & ~a1 & ~a0) | (a3 & ~a2 & a1 & a0) | (a3 & a2 & ~a1 & a0);
assign f[1] = (~a3&a2&~a1&a0) | (~a3&a2&a1&~a0) | (a3&~a2&a1&a0) | (a3&a2&~a1&~a0) |(a3&a2&a1);
assign f[2] = (~a3&~a2&a1&~a0) | (a3&a2&~a1&~a0) | (a3&a2&a1);
assign f[3] = (~a3&~a2&~a1&a0) |(~a3&a2&~a1&~a0) | (~a3&a2&a1&a0) | (a3&~a2&a1&~a0) | (a3&a2&a1&a0);
assign f[4] = (~a2&~a1&a0) | (~a3&a2&~a1) | (~a3&a2&a1&a0) | (~a3&~a2&a1&a0);
assign f[5] = (~a3&~a2&a0) | (~a3&a1&a0)|(~a3&~a2&a1) | (a3&a2&~a1&a0);
assign f[6] = (~a3&~a2&~a1) | (~a3&a2&a1&a0)  | (a3&a2&~a1&~a0);
endmodule

module second_display(b, f);
input b;
output[6:0] f;

assign f[0] = 1;
assign f[1] = 1;
assign f[2] = 1;
assign f[3] = 1;
assign f[4] = 1;
assign f[5] = 1;
assign f[6] = ~b;

endmodule
