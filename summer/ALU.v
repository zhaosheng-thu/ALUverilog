module ALU(//集成模块
   input clk,
   input [3:0] row,
   output [3:0] col,
	output [3:0] out_num,//4*4键盘原始输出
	output [2:0] length,
	output [3:0] num_state,//数字位数状态
	output [7:0] led,//led灯管
	output reg [3:0] num_calculate,//修正过的数字
	output reg [2:0] length_calculate,//修正计算的长度
	output reg [10:0] data_a1,
	output reg [10:0] data_b1,
	output reg [2:0] cs,//共用一个计算符
	output reg carry_in1,
	output [10:0] s1,
   output zero1,
   output carry_out1,
	output reg f
);
keyboard keyboard_instance(
   .clk(clk),
   .row(row),
   .col(col),
   .out_num(out_num),
	.length(length)
);
// 在这里实例化ledtube模块
ledtube ledtube_instance(
   .clk(clk),          // 连接公共的时钟信号
   .num_led(num_calculate),  // 将ALU的输出连接到ledtube的num_led输入
	.length(length_calculate),
	.num_state(num_state),
	.led(led)
);//低八位
alumdl alu_inst1(
    .data_a(data_a1),
    .data_b(data_b1),
    .cs(cs),
    .carry_in(carry_in1),
    .s(s1),
    .zero(zero1),
    .carry_out(carry_out1)
);
parameter ZERO=4'h0;
parameter ONE=4'h1;
parameter TWO=4'h2;
parameter THREE=4'h3;
parameter FOUR=4'h4;
parameter FIVE=4'h5;
parameter SIX=4'h6;
parameter SEVEN=4'h7;
parameter EIGHT=4'h8;
parameter NINE=4'h9;
//操作符
parameter AND =3'b000,OR=3'b001,ADD=3'b010,SUB=3'b011,SLT=3'b100,SUBC=3'b101,ADDC=3'b110;
reg [3:0] num=0;//第一位数字
reg [3:0] pre_num=0;//第二位数字
reg [3:0] p_pre_num=0;//第三位数字
reg [3:0] p_p_pre_num=0;
reg [10:0] data_a=0;
reg [10:0] data_b=0;
reg [10:0] s=0;
reg [2:0] length_memory_alu;
reg [2:0] begin_cal;//输入完毕开始计算标志
reg key_clk;
reg [19:0] cnt;//计数器
reg [10:0] temp_s1;
reg [10:0] temp;
reg [3:0] digits[0:3];//记忆化存储结果的每一位，然后倒序输出
reg [4:0] flag;//计数标志
reg flag_sub;
integer i;
initial begin
	length_memory_alu=0;
	num_calculate=ZERO;
	num=0;
	pre_num=0;
	p_pre_num=0;
	p_p_pre_num=0;
	begin_cal=0;
	carry_in1=0;
	data_a1=0;
	data_b1=0;
	s=0;
	f=1;
	key_clk=0;
	flag=0;//计数
	flag_sub=0;
	i=0;
	digits[0]=15;digits[1]=15;digits[2]=15;digits[3]=15;//初始化
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
always @ (posedge clk)//键盘输入转化为数字和运算符
	begin
		if(length_memory_alu!=length)
			begin
				if(out_num>=0&&out_num<=9)//数字
					begin
						length_calculate=length;//因为为数字，更新length_calculate
						case(out_num)
						4'h0: 
						begin
							if(length!=0)num_calculate=SEVEN;
							else num_calculate=0;
						end
						4'h1: num_calculate=EIGHT;
						4'h2: num_calculate=NINE;
						4'h3: num_calculate=FOUR;
						4'h4: num_calculate=FIVE;
						4'h5: num_calculate=SIX;
						4'h6: num_calculate=ONE;
						4'h7: num_calculate=TWO;
						4'h8: num_calculate=THREE;
						4'h9: num_calculate=ZERO;
						default: num_calculate=0;
						endcase
						//数字迭代
						begin p_pre_num<=pre_num;
						end
						begin pre_num<=num;
						end
						begin num<=num_calculate;
						end
					end
				else if(out_num>=10&&out_num<=14)//运算符
					begin
						case(out_num)
						4'hC: cs=SLT;
						4'hD: cs=SUB;
						4'hE: cs=ADD;
						4'hA: cs=OR;
						4'hB: cs=AND;
						default:cs=ADD;
						//4'hF: begin_cal=1;
						endcase
						begin
							length_calculate=0;//重置
							if(begin_cal!=3&&begin_cal!=1)//不是计算后的结果
								begin
									data_a=p_pre_num*100+pre_num*10+num;//更新第一个数
								end
							else	
								begin
									flag=0;
								end
							data_a1=data_a;//低八位计算
							begin_cal=1;//已输入一个数字
							//length_memory_alu=0;//重置length
							p_pre_num=0;
							pre_num=0;
							num=0;//重置num
						end
					end
				else if(out_num==15)//等号
					begin
						length_calculate=0;//重置
						begin_cal=2;//两个数字输入完毕，计算
						data_b=p_pre_num*100+pre_num*10+num;//更新第二个数
						/*if(cs==SUB&&data_a<data_b)//特判减法第一个数小于第二个数
							begin
								temp=data_a;
								data_a=data_b;
								data_b=temp;
								data_a1=data_a[7:0];//低八位计算
								flag_sub=1;//需要负号
							end*/
						data_b1=data_b;//低八位计算
						p_pre_num=0;
						pre_num=0;
						num=0;//重置num
						length_memory_alu=length;//重置length
					end
				
			end
			length_memory_alu=length;//更新length_memory
			if(begin_cal==2)//计算完毕(低八位)
				begin
					if(flag<3)
						begin
							flag=flag+1;//延迟
						end
					else if(flag==3)
						begin
							/*if(cs==SUB)cs=SUBC;
							else if(cs==ADD)cs=ADDC;//带进位高八位
							data_a1=data_a[15:8];//低八位计算
							data_b1=data_b[15:8];//低八位计算
							carry_in1=carry_out1;*/
							flag=flag+1;
						end
					else if(flag>3&&flag<6)
						flag=flag+1;
					else if(flag==6)
						begin
							/*temp={s1,temp_s1};//赋值*/
							temp=s1;
							s=temp;
							if(temp==0)//特判0
								digits[0]=0;
							begin
								if(cs==SUB&&data_a<data_b)//减法负数特判
									begin
										temp_s1=temp-1;//补码减一
										temp=~temp_s1;
										flag_sub=1;//需要负号
									end
								else if(data_a[10]==1)
									begin
										if(cs==SLT)//比较负数特判
											begin
												temp=1;
												s=temp;
											end
										if(cs==ADD)//加法变正特判
											begin
												temp_s1=data_a-1;
												temp_s1=~temp_s1;
												if(temp_s1<data_b)flag_sub=0;
												else
													begin
														temp=~(s1-1);
														flag_sub=1;
													end
											end
										if(cs==SUB)
											begin
												temp=s1;
												temp_s1=temp-1;//补码减一
												temp=~temp_s1;
												flag_sub=1;//需要负号
											end
									end
								else 
									begin
										if(s1>1000)//取模
											begin
												temp=s1%1000;
												s=temp;
											end
								end
							end
							for (i=0;i<4;i=i+1) 
								begin
									if(temp!=0)
										begin
											digits[i]=temp%10;
											temp=temp/10;
										end
									else
										begin
											if(flag_sub==1)
												begin
													digits[i]=4'hA;
													flag_sub=0;
												end
										end
								end
							flag=flag+1;
							i=4;
						end
					else if(flag>6&&flag<9)
						flag=flag+1;
					else
						begin
							if(i>0)//数位正确
								begin
									num_calculate = digits[i-1];
									length_calculate=length_calculate+1;
									flag=7;//小幅度分频
									i=i-1;//下一位
								end
							else//数位为0,已输出完毕,赋值以准备下一次运算
								begin
									data_a=s;
									i=0;
									begin_cal=3;//结束本次运算的标志
									digits[0]=15;digits[1]=15;digits[2]=15;digits[3]=15;//初始化
									carry_in1=0;
								end
						end
				end
	end
endmodule
