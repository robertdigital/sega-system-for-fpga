module MEM_stage(Wr_id, Fmask, MEMctrl, Src1, Result, seqNPC, EOI, Flags, flush0, CLK, RST, // from EXE stage / other stages
                 D_addr, D_data_in, D_data_out, IORQ, MREQ, RD, WR, D_wait,                 // to/from memory, active high
		 Wr_id_out, Fmask_out, Result_out, Flags_out, mem_pipe_stall, paging_RQ
                      // debug
                      , DEBUG_uop, DEBUG_uop_out, DEBUG_seqNPC_out, DEBUG_taken, DEBUG_taken_out
                      , DEBUG_addr_out, DEBUG_rdata_out, DEBUG_wdata_out
);   // WB stage output
// from EXE stage / other stages
input [4:0] Wr_id;
input [7:0] Fmask;
input [6:0] MEMctrl;
input [15:0] Src1;
input [15:0] Result;
input [15:0] seqNPC;
input EOI;
input [7:0] Flags;
input flush0;
input CLK, RST;

// to/from memory, active high
output [15:0] D_addr;
input  [7:0]  D_data_in; // used for load / in
output [7:0]  D_data_out; // used for store / out
output IORQ, MREQ;
output RD, WR;
input  D_wait;

output [4:0] Wr_id_out;
output [7:0] Fmask_out;
output [15:0] Result_out;
output [7:0] Flags_out;
output mem_pipe_stall;
output paging_RQ;

// debug
input [38:0] DEBUG_uop;
output [38:0] DEBUG_uop_out;
output [15:0] DEBUG_seqNPC_out;
input DEBUG_taken;
output DEBUG_taken_out;
output [15:0] DEBUG_addr_out;
output [7:0] DEBUG_rdata_out, DEBUG_wdata_out;
wire [15:0] DEBUG_addr;
wire [7:0] DEBUG_rdata, DEBUG_wdata;

wire [7:0] flags_int;
wire [15:0] muxout_int;

assign D_addr = ((IORQ | MREQ) == 1) ? Result : 16'bz;
assign D_data_out = ((IORQ | MREQ) & WR) ? Src1[7:0] : 8'bz;
assign IORQ = MEMctrl[2];
assign MREQ = MEMctrl[4];
assign RD   = MEMctrl[1];
assign WR   = MEMctrl[6];

paging_handler page(CLK, RST, MEMctrl[4], Result, MEMctrl[0], flush0, paging_RQ);	

assign mem_pipe_stall = D_wait & (MEMctrl[2]  | MEMctrl[4] );

// mux. 1:load/IN , 0: ALU result
assign muxout_int = ((MEMctrl[3] == 1'b1) ? {D_data_in[7],D_data_in[7],D_data_in[7],D_data_in[7],D_data_in[7],D_data_in[7],D_data_in[7],D_data_in[7],D_data_in} : Result);

parity_F_correction parity(flags_int, Flags, D_data_in, MEMctrl[5]);

MEM_stage_latch thelatch(CLK,RST,
                       Wr_id,Fmask,muxout_int, flags_int,
                       mem_pipe_stall,
                       Wr_id_out,Fmask_out,Result_out,Flags_out
                      // debug
                      ,DEBUG_uop, DEBUG_uop_out, seqNPC, DEBUG_seqNPC_out, DEBUG_taken, DEBUG_taken_out
                      ,D_addr, DEBUG_addr_out, D_data_in, DEBUG_rdata_out, D_data_out, DEBUG_wdata_out
);

endmodule
