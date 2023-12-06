module alumdl(data_a,data_b,s,zero,cs,carry_in,carry_out);
	input[10:0] data_a;
	input[10:0] data_b;
	input[2:0] cs;
	input carry_in;
	output reg [10:0] s;
	output zero;
	output reg carry_out;
	parameter AND =3'b000,OR=3'b001,ADD=3'b010,SUB=3'b011,SLT=3'b100,SUBC=3'b101,ADDC=3'b110;
	reg[11:0] temp=12'b0;
	assign zero=(s==0);
	initial begin
		s=0;
		carry_out=0;
	end
	always @ *
		begin
			case(cs)
			AND:
				begin
					s=data_a&data_b;
					carry_out=1'b0;
				end
			OR:
				begin
					s=data_a|data_b;
					carry_out=1'b0;
				end
			ADD:
				begin
					s=data_a+data_b;
					carry_out=1'b0;
				end
			SUB:
				begin
					temp=data_a-data_b;
					carry_out=~temp[11];
					s[10:0]=temp[10:0];
				end
			SLT:
				begin
					if(data_a[10:0]<data_b[10:0]) s[10:0]=1;
					else s[10:0]=0;
					carry_out=1'b0;
				end
			SUBC:
				begin
					temp=data_a-data_b-(1-carry_in);
					//temp=data_a-data_b-carry_in;
					carry_out=~temp[11];
					s[10:0]=temp[10:0];
				end
			ADDC:
				begin
					temp=data_a+data_b+carry_in;
					carry_out=temp[11];
					s[10:0]=temp[10:0];
				end
			default:
				begin
					s[10:0]=11'b0;
					carry_out=1'b0;
				end
			endcase
		end
endmodule
