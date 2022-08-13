module AVM_AVALONMASTER_MAGNITUDE #
(
  // you can add parameters here
  // you can change these parameters
  parameter integer AVM_AVALONMASTER_DATA_WIDTH = 32,
  parameter integer AVM_AVALONMASTER_ADDRESS_WIDTH = 32
)
(
  // user ports begin

  // these are just some example ports. you can change them all
  input wire START,
  output wire DONE,
  output wire INIT_START,
  input wire [10:0] NUM,
  input wire [18:0] SIZE,
  input wire [AVM_AVALONMASTER_DATA_WIDTH - 1:0] RADDR,
  input wire [AVM_AVALONMASTER_DATA_WIDTH - 1:0] LADDR,
  input wire [AVM_AVALONMASTER_DATA_WIDTH - 1:0] WADDR,

  // user ports end
  // dont change these ports
  input wire CSI_CLOCK_CLK,
  input wire CSI_CLOCK_RESET,
  output wire [AVM_AVALONMASTER_ADDRESS_WIDTH - 1:0] AVM_AVALONMASTER_ADDRESS,
  input wire AVM_AVALONMASTER_WAITREQUEST,
  output wire AVM_AVALONMASTER_READ,
  output wire AVM_AVALONMASTER_WRITE,
  input wire [AVM_AVALONMASTER_DATA_WIDTH - 1:0] AVM_AVALONMASTER_READDATA,
  output wire [AVM_AVALONMASTER_DATA_WIDTH - 1:0] AVM_AVALONMASTER_WRITEDATA
);

  // output wires and registers
  // you can change name and type of these ports
  reg done;
  reg init_start;
  reg [AVM_AVALONMASTER_ADDRESS_WIDTH - 1:0] address;
  reg read;
  reg write;
  wire [AVM_AVALONMASTER_DATA_WIDTH - 1:0] writedata;

  // I/O assignment
  // never directly send values to output
  assign DONE = done;
  assign INIT_START = init_start;
  assign AVM_AVALONMASTER_ADDRESS = address;
  assign AVM_AVALONMASTER_READ = read;
  assign AVM_AVALONMASTER_WRITE = write;
  assign AVM_AVALONMASTER_WRITEDATA = writedata;

  /****************************************************************************
  * all main function must be here or in main module. you MUST NOT use control
  * interface for the main operation and only can import and export some wires
  * from/to it
  ****************************************************************************/

  // user logic begin
  wire [31:0] abs_rdata = AVM_AVALONMASTER_READDATA[31] ? (~AVM_AVALONMASTER_READDATA + 32'h1) : AVM_AVALONMASTER_READDATA;
  wire wr = AVM_AVALONMASTER_WAITREQUEST;
  reg [63:0] sum;
  reg [31:0] waddr, raddr, laddr;
  reg [18:0] cnt2;
  reg [10:0] cnt1;
  reg [1:0] sel_addr;
  reg init1, init2, init_waddr, inc_waddr, init_raddr, inc_raddr, init_laddr, inc_laddr, init_sum, inc_sum, sel_data;
  wire co1, co2;
  
  parameter [2:0] idle = 3'h0, init = 3'h1, right_read = 3'h2, left_read = 3'h3, WLW = 3'h4, WHW = 3'h5;
  
  always @(posedge CSI_CLOCK_CLK) begin
    if(CSI_CLOCK_RESET == 0) cnt1 <= 11'h0;
    else if(init1) cnt1 <= NUM - 11'h1;
    else if(inc_waddr) cnt1 <= cnt1 - 11'h1;
  end
  assign co1 = ~(|cnt1);
  
  always @(posedge CSI_CLOCK_CLK) begin
    if(CSI_CLOCK_RESET == 0) waddr <= 32'h0;
    else if(init_waddr) waddr <= WADDR;
    else if(inc_waddr) waddr <= waddr + 32'h8;
  end
      
  always @(posedge CSI_CLOCK_CLK) begin
    if(CSI_CLOCK_RESET == 0) cnt2 <= 19'h0;
    else if(init2) cnt2 <= SIZE - 19'h1;
    else if(inc_raddr || inc_laddr) cnt2 <= cnt2 - 19'h1;
  end
  assign co2 = ~(|cnt2);
  
  always @(posedge CSI_CLOCK_CLK) begin
    if(CSI_CLOCK_RESET == 0) raddr <= 32'h0;
    else if(init_raddr) raddr <= RADDR;
    else if(inc_raddr) raddr <= raddr + 32'h4;
  end
  
  always @(posedge CSI_CLOCK_CLK) begin
    if(CSI_CLOCK_RESET == 0) laddr <= 32'h0;
    else if(init_laddr) laddr <= LADDR;
    else if(inc_laddr) laddr <= laddr + 32'h4;
  end
  
  always @(waddr, raddr, laddr, sel_addr) begin
    case(sel_addr)
      2'h0: address = raddr;
      2'h1: address = laddr;
      2'h2: address = waddr;
      2'h3: address = waddr + 32'h4;
      default: address = 32'h0;
    endcase
  end
  
  always @(posedge CSI_CLOCK_CLK) begin
    if(CSI_CLOCK_RESET == 0) sum <= 64'h0;
    else if(init_sum) sum <= 64'h0;
    else if(inc_sum) sum <= sum + abs_rdata;
  end
  
  assign writedata = sel_data ? sum[63:32] : sum[31:0];
  
  reg [2:0] ps, ns;
  always @(ps, START, wr, co1, co2) begin
    begin ns = idle; {read, write, init1, init2, init_waddr, inc_waddr, init_raddr, inc_raddr, init_laddr, inc_laddr, init_sum, inc_sum, sel_addr, sel_data, done, init_start} = 17'h0; end
    case(ps)
      idle: begin ns = START ? init : idle; end
      init: begin ns = right_read; init1 = 1'h1; init2 = 1'h1; init_waddr = 1'h1; init_raddr = 1'h1; init_laddr = 1'h1; init_sum = 1'h1; init_start = 1'h1; end
      right_read: begin ns = (~wr && co2) ? left_read : right_read; read = 1'h1; inc_sum = ~wr; inc_raddr = ~wr; init2 = (~wr && co2); end
      left_read: begin ns = (~wr && co2) ? WLW : left_read; read = 1'h1; inc_sum = ~wr; inc_laddr = ~wr; init2 = (~wr && co2); sel_addr = 2'h1; end
      WLW: begin ns = wr ? WLW : WHW; write = 1'h1; sel_addr = 2'h2; end
      WHW: begin ns = (~wr && co1) ? idle : (~wr && ~co1) ? right_read : WHW; write = 1'h1; sel_addr = 2'h3; sel_data = 1'h1; inc_waddr = ~wr; init_sum = ~wr; done = (~wr && co1); end
      default: begin ns = idle; {read, write, init1, init2, init_waddr, inc_waddr, init_raddr, inc_raddr, init_laddr, inc_laddr, init_sum, inc_sum, sel_addr, sel_data, done, init_start} = 17'h0; end
    endcase
  end
  
  always @(posedge CSI_CLOCK_CLK) begin
    if(CSI_CLOCK_RESET == 0) ps <= idle;
    else ps <= ns;
  end
  
  // user logic end

endmodule
