module keyboard(
	input clk,
	//行作为输入
	input [3:0] row,
	output reg [3:0] col,
	output reg [3:0] out_num,
	output reg [2:0] length
);
reg [19:0] cnt;//计数器
reg key_clk;
reg [3:0] memory_row;//记忆row的值
reg [5:0] final_state,nxt_state;
parameter NONE=6'b000001;
parameter COL1=6'b000010;
parameter COL2=6'b000100;
parameter COL3=6'b001000;
parameter COL4=6'b010000;
parameter PRESS=6'b100000;
initial begin//初始化
	nxt_state=NONE;
	memory_row=4'b1111;
	length=0;
	out_num=0;//初始化
end
//分频，防止多次误输入
always @ (posedge clk)
	begin 
		if(cnt<=1250)//分频
			cnt<=cnt + 1;
		else begin
			cnt<=0;
			key_clk<=~key_clk;
		end
	end
always @ (posedge key_clk)
	begin
		case(nxt_state)
		NONE:
			begin
				memory_row=row;//更新memory_row
				col<=4'b0000;
			end
		COL1:
			begin
				//此处不更新!
				col<=4'b0111;
			end
		COL2:
			begin
				memory_row=row;//更新memory_row
				col<=4'b1011;
			end
		COL3:
			begin
				memory_row=row;//更新memory_row
				col<=4'b1101;
			end
		COL4:
			begin
				memory_row=row;//更新memory_row
				col<=4'b1110;
			end
		PRESS:
			begin
				if(memory_row!=row) length<=length+1'b1;//输入数字长度更新
				case(row)
				4'b0111:
					case(col)
					4'b0111:out_num<=4'h0;
					4'b1011:out_num<=4'h1;
					4'b1101:out_num<=4'h2;
					4'b1110:out_num<=4'hC;
					endcase
				4'b1011:
					case(col)
					4'b0111:out_num<=4'h3;
					4'b1011:out_num<=4'h4;
					4'b1101:out_num<=4'h5;
					4'b1110:out_num<=4'hD;
					endcase
				4'b1101:
					case(col)
					4'b0111:out_num<=4'h6;
					4'b1011:out_num<=4'h7;
					4'b1101:out_num<=4'h8;
					4'b1110:out_num<=4'hE;
					endcase
				4'b1110:
					case(col)
					4'b0111:out_num<=4'hA;
					4'b1011:out_num<=4'h9;
					4'b1101:out_num<=4'hB;
					4'b1110:out_num<=4'hF;
					endcase
				endcase
				memory_row=row;//更新memory_row
			end
		endcase
	end

always @ *
	case(final_state)
	NONE:
		if(row!=4'hF)
			nxt_state=COL1;//开始扫描
		else
			nxt_state=NONE;
	COL1:
		if(row!=4'hF)
			nxt_state=PRESS;//找到对应行列
		else
			nxt_state=COL2;//继续
	COL2:
		if(row!=4'hF)
			nxt_state=PRESS;
		else
			nxt_state=COL3;
	COL3:
		if(row!=4'hF)
			nxt_state=PRESS;
		else
			nxt_state=COL4;
	COL4:
		if(row!=4'hF)
			nxt_state=PRESS;
		else
			nxt_state=NONE;
	PRESS:
		if(row!=4'hF)
			nxt_state=PRESS;
		else
			nxt_state=NONE;//锁住press状态
	endcase
always @ (posedge key_clk)
	begin
		final_state=nxt_state;//更新state
	end
endmodule
