module upController(input clk, input up,
input[1:0] pr_s, output reg[1:0] nx_s);

parameter D = 500000;

reg[31:0] count = 32'd0;

always @(posedge clk)
begin
	if(up == 0 && pr_s == 2'd0)
	begin
		nx_s <= 2'd1;
	end
	else if(pr_s == 2'd1)
	begin
		count <= count + 1;
		if(count >= D - 2) nx_s <= 2'd2;
		if(up == 1)
		begin 
			nx_s <= 2'd0;
			
		end
	end
	else if(pr_s == 2'd2)
	begin
		
		nx_s <= 2'd3;
		
	end
	else if(pr_s == 2'd3)
	begin
		count <= 0;
		if(up == 1) nx_s <= 2'd0;
		
	end
end
endmodule

module downController(input clk, input down,
input[1:0] pr_s, output reg[1:0] nx_s);

parameter D = 500000;

reg[31:0] count = 32'd0;

always @(posedge clk)
begin
	if(down == 0 && pr_s == 2'd0)
	begin
		nx_s <= 2'd1;
	end
	else if(pr_s == 2'd1)
	begin
		count <= count + 1;
		if(count >= D - 2) nx_s <= 2'd2;
		if(down == 1)
		begin 
			nx_s <= 2'd0;
			
		end
	end
	else if(pr_s == 2'd2)
	begin
		
		nx_s <= 2'd3;
		
	end
	else if(pr_s == 2'd3)
	begin
		count <= 0;
		if(down == 1) nx_s <= 2'd0;
		
	end
end
endmodule