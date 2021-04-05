`default_nettype none
module remote(input[2:0] r, input[2:0] g, input[2:0] b,
  input  clk,
  output reg led
  );
  reg [2:0] state;
  reg [1:0] seg_count;
  reg [12:0] rst_count;
  reg [7:0] bits;
  reg [7:0] led_num;
  
  wire[7:0] rw;
  wire[7:0] gw;
  wire[7:0] bw;
  
  convert(r, rw);
  convert(g, gw);
  convert(b, bw);
  
  //BRG
  reg [24:0] color;
  
  // Process the state machine at each 10MHz clock edge.
  always@(posedge clk)
    begin
		color[23:16] <= bw[7:0];
		color[15:8] <= rw[7:0];
		color[7:0] <= gw[7:0];

      if (state == 0 || state == 1 || state == 2 || state == 3)
        begin
          seg_count = seg_count + 1;
          if (seg_count == 0)
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
          rst_count = rst_count + 1;
          if (rst_count == 0)
            begin
              state = 0;
            end
        end
      // Set the correct pin state.
      if (color & (1 << bits))
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

