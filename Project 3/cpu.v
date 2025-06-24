///////////////////////////////////////////////////////////////////////////
// MODULE: CPU for TSC microcomputer: cpu.v
// Author: DoHyun Kim, Seoyoung Kim
// Description: implement a single-cycle TSC CPU

// DEFINITIONS
`define WORD_SIZE 16    // data and address word size

// MODULE DECLARATION
module cpu (
    output readM,                       // read from memory
    output [`WORD_SIZE-1:0] address,    // current address for data
    inout [`WORD_SIZE-1:0] data,        // data being input or output
    input inputReady,                   // indicates that data is ready from the input port
    input reset_n,                      // active-low RESET signal
    input clk,                          // clock signal
  
    // for debuging/testing purpose
    output [`WORD_SIZE-1:0] num_inst,   // number of instruction during execution
    output [`WORD_SIZE-1:0] output_port // this will be used for a "WWD" instruction
);
    wire [1:0] addr1, addr2, addr3;  // = addr1,2,3, in RF.v, SA, SB, DR in handout
    wire MB, LD, MD;
    wire WWD, LHI, JMP;   // It becomes 1 when it matches each operation. 
    wire [3:0] FS;        // = OP in ALU.v
    wire [7:0] IMM;       //
    wire [11:0] JMPaddr;  // target address to jmp
    
    reg [`WORD_SIZE-1:0] pc;
    reg [`WORD_SIZE-1:0] inst;
    reg [`WORD_SIZE-1:0] num_inst_r;
    reg [`WORD_SIZE-1:0] output_port_r;

    wire [`WORD_SIZE-1:0] datapath_output;
    wire [`WORD_SIZE-1:0] wwd_data;

    assign num_inst = num_inst_r;
    assign address = pc; 
    assign readM = 1'b1;
    assign output_port = WWD ? wwd_data : output_port_r;
    
    control_unit CU (inst,
        addr1, addr2, addr3,
        MB, LD, MD, FS,
        WWD, LHI, JMP,
        JMPaddr, IMM
    );
    
    datapath DP (clk, 
        reset_n, addr1, addr2, addr3, 
        MB, LD, FS, IMM, 
        LHI, WWD, datapath_output,
        wwd_data
    );

    always @(posedge clk) begin
        if (!reset_n) begin
            pc <= 0;
            num_inst_r <= 0;
            output_port_r <= 0;
        end else begin
            if (inputReady) begin
                num_inst_r <= num_inst_r + 1;
                inst <= data;
                if (WWD) begin output_port_r <= wwd_data; end 
                if (JMP) begin pc <= {4'b0000, JMPaddr}; end
                else begin pc <= pc + 1; end
            end
        end
    end
endmodule

module control_unit (
    input [15:0] instruction,
    output reg [1:0] addr1, // = addr1 in RF
    output reg [1:0] addr2, // = addr2 in RF
    output reg [1:0] addr3, // = addr3 in RF
    output reg MB, 
    output reg LD, 
    output reg MD,
    output reg [3:0] FS, // = OP in ALU
    output reg WWD,// if WWD, 1
    output reg LHI,// if LHI, 1
    output reg JMP,// if JMP, 1
    output reg [11:0] JMPaddr, // target address
    output reg [7:0] IMM
);

    wire [3:0] opcode = instruction[15:12];
    wire [5:0] funccode  = instruction[5:0];

    always @(*) begin
        addr1 = instruction[11:10];
        addr2 = instruction[9:8];
        addr3 = 2'b00;
        JMPaddr = 12'b000000000000;
        MB  = 0;
        LD  = 0;
        MD  = 0;
        JMP  = 0;
        FS  = 2'b00;
        WWD = 0;
        LHI = 0;
        IMM = instruction[7:0];
        //r-type: add, wwd
        if(opcode == 4'd15) begin
            case(funccode)
                6'd0: begin // add
                    addr3 = instruction[7:6];
                    MB = 0;
                    LD = 1;
                    FS = 4'b0000;
                end
                6'd28: begin //wwd
                    WWD = 1;
                end
             endcase
        end
        
        if(opcode == 4'd4) begin // adi
            addr3 = instruction[9:8];
            MB = 1;
            LD = 1;
            FS = 4'b0000;
        end
        
        if(opcode == 4'd6) begin // LHI
            addr3 = instruction[9:8];
            LHI = 1;
            LD = 1;
        end
        
        if(opcode == 4'd9) begin // JMP
            JMPaddr = instruction[11:0];
            JMP = 1;
        end
    end
endmodule

module datapath(
    input clk,
    input reset_n, 
    input [1:0] addr1, addr2, addr3,
    input MB,
    input LD,
    input [3:0] FS,
    input [7:0] IMM,
    input LHI,
    input WWD,
    output reg [`WORD_SIZE-1:0] result,
    output [`WORD_SIZE-1:0] wwd_data_out
);
    reg [`WORD_SIZE-1:0] rf [3:0];
    wire [`WORD_SIZE-1:0] A = rf[addr1];
    wire [`WORD_SIZE-1:0] B = rf[addr2];
    wire [`WORD_SIZE-1:0] B_input = MB ? {{8{IMM[7]}}, IMM} : B;
    reg [`WORD_SIZE-1:0] alu_result;

    assign wwd_data_out = A;

    always @(*) begin
        case (FS)
            4'b0000: alu_result = A + B_input;
            default: alu_result = 16'd0;
        endcase

        if (LHI)
            alu_result = {IMM, 8'b0};

        if (WWD) begin
            result = A;
        end else begin
            result = alu_result;
        end
    end

    always @(*) begin
        if (!reset_n) begin
            rf[0] <= 16'b0;
            rf[1] <= 16'b0;
            rf[2] <= 16'b0;
            rf[3] <= 16'b0;
        end else if (LD) begin
            rf[addr3] <= alu_result;
        end
    end
endmodule