module processor;

reg [31:0] pc;

reg clk;
reg [7:0] datmem[0:31], mem[0:31];

wire [31:0] dataa,datab;
wire [31:0] out2,out3,out4, out5, out6, out7, out8; 
wire [31:0] sum, extad, adder1out, adder2out;
wire [31:0] sextad,readdata;
wire [31:0] jaddress, baddress; // baddress is used for ben and bvf instruction 


wire [5:0] inst31_26;
wire [4:0] inst25_21, inst20_16, inst15_11, out1;
wire [15:0] inst15_0;
wire [25:0] inst25_0;

wire [31:0] instruc,dpack;
wire [2:0] gout;
reg [2:0] cpsr;



wire cout,zout,nout,pcsrc,regdest,alusrc,memtoreg,regwrite,memread,
memwrite,branch,aluop1,aluop0,j, addisrc, sout, vout, pcsrc2, ben, bvf ;

reg [31:0] registerfile [0:31];

integer i;

// datamemory connections
always @(posedge clk)
begin
	if(memwrite)
	begin 
		datmem[sum[4:0]+3]=datab[7:0];
		datmem[sum[4:0]+2]=datab[15:8];
		datmem[sum[4:0]+1]=datab[23:16];
		datmem[sum[4:0]]=datab[31:24];
	end
end

//instruction memory
assign instruc = {mem[pc[4:0]],mem[pc[4:0]+1],mem[pc[4:0]+2],mem[pc[4:0]+3]};
assign inst31_26 = instruc[31:26];
assign inst25_21 = instruc[25:21];
assign inst20_16 = instruc[20:16];
assign inst15_11 = instruc[15:11];
assign inst15_0 = instruc[15:0];
assign inst25_0 = instruc[25:0];



assign jaddress = {pc[31:28], 2'b00,instruc[25:0]}; // Instead shifting, concatenation is made
assign baddress = {pc[31:28], extad[27:0]}; // Instead shifting concetanation is made
// registers
assign dataa = registerfile[inst25_21];
assign datab = registerfile[inst20_16];

//multiplexers
assign dpack={datmem[sum[5:0]],datmem[sum[5:0]+1],datmem[sum[5:0]+2],datmem[sum[5:0]+3]};

mult2_to_1_5  mult1(out1, instruc[20:16],instruc[15:11],regdest);
mult2_to_1_32 mult2(out2, datab, extad, alusrc);
mult2_to_1_32 mult3(out3, sum, dpack, memtoreg);
mult2_to_1_32 mult4(out4, adder1out,adder2out,pcsrc);
mult2_to_1_32 mult5(out5,out4, jaddress,j); // for jump instruction 
mult2_to_1_32 mult6(out6,dataa, extad ,addisrc);  // for addi instruction
mult2_to_1_32 mult7(out7,out5, baddress ,pcsrc2); // for ben instruction
mult2_to_1_32 mult8(out8,out7, baddress ,pcsrc3); // for bvf instruction 

always @(posedge clk)
begin
	registerfile[out1]= regwrite ? out3 : registerfile[out1];
end


// load pc
always @(posedge clk)
pc = out8;                   // according the multiplexers, update the pc 

always @(posedge clk)        // set CSPR 
begin
	if(ben|bvf|branch)
	assign cpsr = 3'b000 ;
	else
	assign cpsr = {sout,vout,zout}; // concatenation 

end 

// alu, adder and control logic connections

alu32 alu1(sum, out6, out2, sout,vout, zout, gout);
adder add1(pc,32'h4,adder1out);
adder add2(adder1out,sextad,adder2out);


/*
control(in, regdest, alusrc, memtoreg, regwrite, memread, memwrite, branch, aluop1, aluop2);
*/
control cont(instruc[31:26],regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,
aluop1,aluop0, j, addisrc, ben, bvf);

signext sext(instruc[15:0],extad);

alucont acont(aluop1,aluop0,instruc[3],instruc[2], instruc[1], instruc[0],gout);

shift shift2(sextad,extad);


assign pcsrc = branch && zout;
assign pcsrc2 = ben && (sout|zout) ; //branch if the previous instruction result is negative or equal to zero
assign pcsrc3 = bvf && vout ;  // branch if the previous instruction overflow
//initialize datamemory,instruction memory and registers
initial
begin
	$readmemh("C:/intelFPGA/Sourcefiles/initdata.dat",datmem);
	$readmemh("C:/intelFPGA/Sourcefiles/init.dat",mem);
	$readmemh("C:/intelFPGA/Sourcefiles/initreg.dat",registerfile);

	for(i=0; i<31; i=i+1)
	$display("Instruction Memory[%0d]= %h  ",i,mem[i],"Data Memory[%0d]= %h   ",i,datmem[i],
	"Register[%0d]= %h",i,registerfile[i]);
end

initial
begin
	pc=0;
	#400 $finish;
end

initial
begin
	clk=0;
forever #20  clk=~clk;
end

initial 
begin
	$monitor($time,"PC %h",pc,"  SUM %h",sum,"   INST %h",instruc[31:0],
	"   REGISTER %h %h %h %h ",registerfile[4],registerfile[5], registerfile[6],registerfile[1] );
end

endmodule

