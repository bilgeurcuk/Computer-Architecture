module control(in, regdest, alusrc, memtoreg, regwrite, memread, memwrite, branch, aluop1, aluop2,
               jump,addisrc, ben, bvf);
input [5:0] in;
output regdest, alusrc, memtoreg, regwrite, memread, memwrite, branch, aluop1, aluop2, 
	jump, addisrc, ben, bvf;

wire rformat,lw,sw,beq,j, isrc, bensrc, bvfsrc;

assign rformat =~| in;

assign lw = in[5]& (~in[4])&(~in[3])&(~in[2])&in[1]&in[0];

assign sw = in[5]& (~in[4])&in[3]&(~in[2])&in[1]&in[0];

assign beq = ~in[5]& (~in[4])&(~in[3])&in[2]&(~in[1])&(~in[0]);

assign j= (~in[5])& (~in[4])&(~in[3])& (~in[2])&(in[1])&(~in[0]);

assign isrc = (~in[5])& (~in[4])&(in[3])& (~in[2])&(~in[1])&(~in[0]);

assign bensrc = (~in[5])& (~in[4])&(~in[3])& (in[2])&(in[1])&(~in[0]);

assign bvfsrc = (~in[5])& (~in[4])&(~in[3])& (in[2])&(~in[1])&(in[0]);

assign regdest = rformat;

assign alusrc = lw|sw;
assign memtoreg = lw;
assign regwrite = rformat|lw;
assign memread = lw;
assign memwrite = sw;
assign branch = beq| bensrc;
assign aluop1 = rformat;
assign aluop2 = beq;
assign jump = j;
assign addisrc = isrc;
assign ben  = bensrc;
assign bvf = bvfsrc ;


endmodule
