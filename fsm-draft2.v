module part3(SW, CLOCK_50, KEY, LEDR);
input [2:0]SW;
input [1:0]KEY;
output[9:0]LEDR;

wire [2:0]presentstate;

assign presentstate[2] = SW[2];
assign presentstate[1] = SW[1];
assign presentstate[0] = SW[0]; 
assign LEDR[9:1] = 0;

//calling all these monsters of modules
wire[3:0]yout;
wire[2:0] length;
wire shift, b0, enable, load, z;
input CLOCK_50;

letter_selector yes(presentstate, yout, length);
shift_register okay(yout, shift, load, b0);
down_counter mhmm(load, length, shift, enable, z);
halfsec_counter awnah(KEY[1], CLOCK_50, enable);
fsm hellnah(b0, enable, KEY[0], KEY[1], z, load, shift, LEDR[0]);

endmodule

///////////////////////////////////////////////////////////////

module letter_selector(presentstate, yout, counter);
input[2:0] presentstate; 
output reg [3:0] yout;
output reg [2:0] counter;
parameter[2:0]A = 3'b000;
parameter[2:0]B = 3'b001;
parameter[2:0]C = 3'b010;
parameter[2:0]D = 3'b011;
parameter[2:0]E = 3'b100;
parameter[2:0]F = 3'b101;
parameter[2:0]G = 3'b110;
parameter[2:0]H = 3'b111;

always@(*)
case(presentstate)
	A:
	yout <= 4'b01xx;

	B:
	yout <= 4'b1000;

	C:
	yout <= 4'b1010;

	D:
	yout <= 4'b100x;

	E:
	yout <= 4'b0xxx;

	F:
	yout <= 4'b0010;

	G:
	yout <= 4'b110x;

	H:
	yout <= 4'b0000;

	default:
	yout <= 4'bxxxx; 
endcase

always@(*)
case(presentstate)
	A:
	counter <= 3'b011;

	B:
	counter <= 3'b101;

	C:
	counter <= 3'b101;

	D:
	counter <= 3'b100;

	E:
	counter <= 3'b010;

	F:
	counter <= 3'b101;

	G:
	counter <= 3'b100;

	H:
	counter <= 3'b101;

	default:
	counter <= 3'bxxx; 
endcase

endmodule

///////////////////////////////////////////////////////////////

module shift_register(yout, shift, load, b0);
input[3:0] yout;
input shift, load;
output b0;  
//maybe replace key1 with load;

wire q1, q2, q3;
 
flipflop one(yout[0], shift, b0, load, q1); 
flipflop two(yout[1], shift, q1, load, q2);
flipflop three(yout[2], shift, q2, load, q3);
flipflop four(yout[3], shift, q3, load, b0);

endmodule

/////////////////////////////////////////////////////////////


module flipflop(yout_bit, enable, Q, start, qout); //start is load
input yout_bit, enable, Q, start; 
//reset is KEY0
output reg qout;

always@(posedge enable)

	begin
	if(start) 
		qout <= yout_bit;
		
	else
		qout <= Q;	
	end
	
endmodule

/////////////////////////////////////////////////////////

module down_counter(load, length, shift, enable, z); 
input shift, load, enable;
input [2:0] length;
reg[2:0] counter;
output z;
always@(posedge enable)
begin
	if(load)//load
	counter <= length;
	
	else if(z)
	counter <= 3'b001;
	
	else if(shift) 
	counter <= (counter - 1'b1);
end

assign z = (counter == 3'b001);

endmodule

//////////////////////////////////////////////////////////////

module halfsec_counter(KEY, CLOCK_50, enable);
input KEY;

input CLOCK_50;
output reg enable;
reg[24:0]fastcounter = 25'd25000000;


always @(posedge CLOCK_50) begin
if (fastcounter == 0)
enable <= 1;
else if (KEY == 0 | enable == 1)
begin
fastcounter <= 25'd25000000;
enable <= 0;
end
else
fastcounter<= fastcounter - 1;
end
endmodule

/////////////////////////////////////////////////////////////

module fsm(b0, enable, key0, key1, z, load, shift, LEDR); //need key1 and key0 as reset
input b0, enable, key0, key1, z;
output [0:0] LEDR;
output reg shift, load;

reg[2:0] pstate, newstate;

parameter A = 3'b000; // reset KEY
parameter B = 3'b001;
parameter dash = 3'b010, d2 = 3'b011, d3 = 3'b100;
parameter dot = 3'b101;  
parameter space = 3'b110;

always@(posedge enable) begin
if(!key0) //key0 is reset
	pstate <= A;
else
	pstate <= newstate;
end


always@(*)
case(pstate)

	A: begin
		if(!key1)
			newstate <= A;
		else begin
			newstate <= B;
			load <=1; end
		end
		
	B: begin
		if(!enable) begin
			newstate <= B;
			load <=0; end
		else if (enable & !b0) begin
			load <=0;
			newstate <= dot; end
		else if (enable & b0) begin
			newstate <= dash;
			load <=0;end
		else
			newstate <= B;
		end

	dash: begin 
		if(!enable)
		newstate <= dash;
		else if (enable)
		newstate <= d2;
		else
			newstate <= B;
		end

	d2: begin
		if(!enable)
		newstate <= d2;
		else if(enable)
		newstate <= d3;
		else
			newstate <= B;
		end

	d3: begin
		if(!enable)
		newstate <= d3;
		else if(enable) begin
		newstate <= space;
		end
		else
			newstate <= B;
		end

	dot: begin
		if(!enable)
		newstate <= dot;
		else if (enable) begin
		newstate <= space;
		end
		else
			newstate <= B;
		end
	
	space: begin
		if(!enable) begin
		newstate <= space;
		shift <= 1; end
//		else if (enable & !b0)begin 
//		newstate <= dot;
//		shift <= 0; end	
//		else if (enable & b0)begin 
//		newstate <= dash;
//		shift <= 0; end
		else if (!z & enable) begin 
		newstate <= B;
		shift <= 0; end
		else if (enable & z) begin
		newstate <= space;
		shift <= 0; end
		else
			newstate <= B;
		end
	
	default: begin
	newstate <= B;
	load <= 0;
	shift <= 0; end

endcase

assign LEDR = ((pstate == dot) | (pstate == dash) | (pstate == d2) | (pstate == d3)); 

endmodule
