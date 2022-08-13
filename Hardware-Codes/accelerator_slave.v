module AVS_AVALONSLAVE_CTRL #
(
  // you can add parameters here
  // you can change these parameters
  parameter integer AVS_AVALONSLAVE_DATA_WIDTH = 32,
  parameter integer AVS_AVALONSLAVE_ADDRESS_WIDTH = 4
)
(
  // user ports begin
  output wire START,
  input wire DONE,
  input wire INIT_START,
  output wire [10:0] NUM,
  output wire [18:0] SIZE,
  output wire [AVS_AVALONSLAVE_DATA_WIDTH - 1:0] RADDR,
  output wire [AVS_AVALONSLAVE_DATA_WIDTH - 1:0] LADDR,
  output wire [AVS_AVALONSLAVE_DATA_WIDTH - 1:0] WADDR,

  // user ports end
  // dont change these ports
  input wire CSI_CLOCK_CLK,
  input wire CSI_CLOCK_RESET,
  input wire [AVS_AVALONSLAVE_ADDRESS_WIDTH - 1:0] AVS_AVALONSLAVE_ADDRESS,
  output wire AVS_AVALONSLAVE_WAITREQUEST,
  input wire AVS_AVALONSLAVE_READ,
  input wire AVS_AVALONSLAVE_WRITE,
  output wire [AVS_AVALONSLAVE_DATA_WIDTH - 1:0] AVS_AVALONSLAVE_READDATA,
  input wire [AVS_AVALONSLAVE_DATA_WIDTH - 1:0] AVS_AVALONSLAVE_WRITEDATA
);

  // output wires and registers
  // you can change name and type of these ports
  wire start;
  wire wait_request;
  reg [AVS_AVALONSLAVE_DATA_WIDTH - 1:0] read_data;
  wire [10:0] num;
  wire [18:0] size;
  wire [AVS_AVALONSLAVE_DATA_WIDTH - 1:0] raddr;
  wire [AVS_AVALONSLAVE_DATA_WIDTH - 1:0] laddr;
  wire [AVS_AVALONSLAVE_DATA_WIDTH - 1:0] waddr;
  
  // these are slave registers. they MUST be here!
  reg [AVS_AVALONSLAVE_DATA_WIDTH - 1:0] slv_reg0;
  reg [AVS_AVALONSLAVE_DATA_WIDTH - 1:0] slv_reg1;
  reg [AVS_AVALONSLAVE_DATA_WIDTH - 1:0] slv_reg2;
  reg [AVS_AVALONSLAVE_DATA_WIDTH - 1:0] slv_reg3;

  // I/O assignment
  // never directly send values to output
  assign START = start;
  assign NUM = num;
  assign SIZE = size;
  assign RADDR = raddr;
  assign LADDR = laddr;
  assign WADDR = waddr;
  assign AVS_AVALONSLAVE_WAITREQUEST = wait_request;
  assign AVS_AVALONSLAVE_READDATA = read_data;
  
  always @(AVS_AVALONSLAVE_READ, AVS_AVALONSLAVE_ADDRESS, slv_reg0, slv_reg1, slv_reg2, slv_reg3)
  begin
    read_data = 32'bz;
    if(AVS_AVALONSLAVE_READ)
    begin
      // address is always bytewise so must devide it by 4 for 32bit word
		  case(AVS_AVALONSLAVE_ADDRESS >> 2)
				0: read_data = slv_reg0;
				1: read_data	= slv_reg1;
				2: read_data	= slv_reg2;
				3: read_data = slv_reg3;
		    default: read_data = 32'h0;
		  endcase
    end
  end

  // it is an example and you can change it or delete it completely
  always @(posedge CSI_CLOCK_CLK)
  begin
    // usually resets are active low but you can change its trigger type
    if(CSI_CLOCK_RESET == 0)
    begin
      slv_reg0 <= 0;
      slv_reg1 <= 0;
      slv_reg2 <= 0;
      slv_reg3 <= 0;
    end
    if(AVS_AVALONSLAVE_WRITE)
    begin
      // address is always bytewise so must devide it by 4 for 32bit word
      case(AVS_AVALONSLAVE_ADDRESS >> 2)
      0: slv_reg0 <= AVS_AVALONSLAVE_WRITEDATA;
      1: slv_reg1 <= AVS_AVALONSLAVE_WRITEDATA;
      2: slv_reg2 <= AVS_AVALONSLAVE_WRITEDATA;
      3: slv_reg3 <= AVS_AVALONSLAVE_WRITEDATA;
      default:
      begin
        slv_reg0 <= slv_reg0;
        slv_reg1 <= slv_reg1;
        slv_reg2 <= slv_reg2;
        slv_reg3 <= slv_reg3;
      end
      endcase
    end
    // it is an example design
    if(DONE)
    begin
      slv_reg0 <= (slv_reg0 | 32'h80000000);
    end
    if(INIT_START)
    begin
      slv_reg0 <= (slv_reg0 & 32'hFFFFFFFE);
    end
  end

  // do the other jobs yourself like last codes
  assign start = slv_reg0[0];
  assign num = slv_reg0[11:1];
  assign size = slv_reg0[30:12];
  assign raddr = slv_reg1;
  assign laddr = slv_reg2;
  assign waddr = slv_reg3;
  assign wait_request = 1'b0;

endmodule