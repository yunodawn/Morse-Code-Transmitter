module part5(KEY, SW, LEDR);

input[0:0]KEY;
input[1:0]SW;
output[9:0]LEDR;

wire [8:0]pstate;

FSM pleasework(KEY[0], SW[0], SW[1], LEDR[9], LEDR[8:0]); 

endmodule

/////////////////////////////////////////////////

module FSM(clk, reset, w, z, pstate);

input clk, reset, w;
output reg z;
output reg[8:0]pstate; // this is presentstate shortened

parameter A = 9'b000000000;
parameter B = 9'b000000011;
parameter C = 9'b000000101;
parameter D = 9'b000001001;
parameter E = 9'b000010001;
parameter F = 9'b000100001;
parameter G = 9'b001000001;
parameter H = 9'b010000001;
parameter I = 9'b100000001;

reg[8:0] nstate; //this is newstate shortened

always@(*) begin 
case(pstate)

	A: begin
	if (w == 1)
	nstate <= F;
	else
	nstate <= B;
	end


	B: begin
	if (w == 1)
	nstate <= F;
	else
	nstate <= C;
	end


	C: begin
	if (w == 1)
	nstate <= F;
	else
	nstate <= D;
	end


	D: begin
	if (w == 1)
	nstate <= F;
	else
	nstate <= E;
	end


	E: begin
	if (w == 1)
	nstate <= F;
	else
	nstate <= E;
	end


	F: begin
	if (w == 1)
	nstate <= G;
	else
	nstate <= B;
	end


	G: begin
	if (w == 1)
	nstate <= H;
	else
	nstate <= B;
	end


	H: begin
	if (w == 1)
	nstate <= I;
	else
	nstate <= B;
	end


	I: begin
	if (w == 1)
	nstate <= I;
	else
	nstate <= B;
	end

default:
	begin
	nstate <= A;
	end

endcase
end


always @(posedge clk or negedge reset) begin //or negedge reset
  if (!reset) 
    pstate <= A; // Reset to A
  
  else
    pstate <= nstate; 
 
 end
    //logic for z

always @(*) 
	begin
    z = (pstate == I) | (pstate == E);
	end 

	endmodule 
 


