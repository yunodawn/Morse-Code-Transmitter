module part2(KEY, SW, LEDR);

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

parameter A = 9'b000000001;
parameter B = 9'b000000010;
parameter C = 9'b000000100;
parameter D = 9'b000001000;
parameter E = 9'b000010000;
parameter F = 9'b000100000;
parameter G = 9'b001000000;
parameter H = 9'b010000000;
parameter I = 9'b100000000;

wire[8:0] nstate; //this is newstate shortened
//nextstate[0] = A
//nextstate[1] = B
//nextstate[2] = C
//etc

assign nstate[0] = 1'b0; //a 
assign nstate[1] = (((pstate == A) | (pstate == F) | (pstate == G) | (pstate == H) | (pstate == I)) & ~w); //b
assign nstate[2] = (pstate == B & ~w); //c
assign nstate[3] = (pstate == C & ~w); //d
assign nstate[4] = (pstate == D & ~w) | (pstate == E & ~w); //e
assign nstate[5] = (((pstate == A) | (pstate == B) | (pstate == C) | (pstate == D) | (pstate == E)) & w); // f
assign nstate[6] = (pstate == F & w); //g
assign nstate[7] = (pstate == G & w); //h
assign nstate[8] = (pstate == H & w) | (pstate == I & w); // i


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
 