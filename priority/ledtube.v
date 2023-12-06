module ledtube(
	input clk,
	input [3:0] num_led,
	input [2:0] length,
	output reg [3:0] num_state,
	output reg [7:0] led
);
reg [19:0] cnt;//计数器
reg [3:0] num=0;//第一位数字
reg [3:0] pre_num=0;//第二位数字
reg [3:0] p_pre_num=0;//第三位数字
reg [3:0] p_p_pre_num=0;
reg [2:0] length_memory=0;
reg key_clk;
parameter FIRST=4'b1110;
parameter SECOND=4'b1101;
parameter THIRD=4'b1011;
parameter FOURTH=4'b0111;
initial begin
	num<=15;
	pre_num<=15;
	p_pre_num<=15;
	p_p_pre_num<=15;
	length_memory<=0;
	num_state=FIRST;
end
always @ (posedge clk)
	begin 
		if(cnt<=12500)//分频
			cnt<=cnt + 1;
		else begin
			cnt<=0;
			key_clk<=~key_clk;
		end
	end
always @ (posedge key_clk)
	case(num_state)//数字赋值
	FOURTH:
		begin
			num_state=FIRST;
			case(num)
				0:led<= 'hc0;
				1:led<= 'hf9;
				2:led<= 'ha4;
				3:led<= 'hb0;
				4:led<= 'h99;
				5:led<= 'h92;
				6:led<= 'h82;
				7:led<= 'hf8;
				8:led<= 'h80;
				9:led<= 'h90;
				4'hA:led<= 8'hbf;//负号
				default:led<= 8'b11111111;
			endcase
		end
	THIRD:
		begin
			num_state=FOURTH;
			case(p_p_pre_num)
				0:led<= 'hc0;
				1:led<= 'hf9;
				2:led<= 'ha4;
				3:led<= 'hb0;
				4:led<= 'h99;
				5:led<= 'h92;
				6:led<= 'h82;
				7:led<= 'hf8;
				8:led<= 'h80;
				9:led<= 'h90;
				4'hA:led<= 8'hbf;//负号
				default:led<= 8'b11111111;
			endcase
		end
	FIRST:
		begin
			num_state=SECOND;
			case(pre_num)
				0:led<= 'hc0;
				1:led<= 'hf9;
				2:led<= 'ha4;
				3:led<= 'hb0;
				4:led<= 'h99;
				5:led<= 'h92;
				6:led<= 'h82;
				7:led<= 'hf8;
				8:led<= 'h80;
				9:led<= 'h90;
				4'hA:led<= 8'hbf;//负号
				default:led<= 8'b11111111;
			endcase
		end
		SECOND:
		begin
			num_state=THIRD;
			case(p_pre_num)
				0:led<= 'hc0;
				1:led<= 'hf9;
				2:led<= 'ha4;
				3:led<= 'hb0;
				4:led<= 'h99;
				5:led<= 'h92;
				6:led<= 'h82;
				7:led<= 'hf8;
				8:led<= 'h80;
				9:led<= 'h90;
				4'hA:led<= 8'hbf;//负号
				default:led<= 8'b11111111;
			endcase
		end
	endcase
always @ (posedge clk)
	begin
		if(length_memory!=length)//数字更新
			begin
				begin p_p_pre_num=p_pre_num;
				end
				begin p_pre_num=pre_num;
				end
				begin pre_num=num;
				end
				begin num=num_led;
				end
			end
		length_memory=length;//更新memory
		//重置LED显示
		if(length==0)//重置
			begin	
				num<=15;
				pre_num<=15;
				p_pre_num<=15;
				p_p_pre_num<=15;
				length_memory<=0;
			end
	 end

endmodule
