module tam(
    input clk,
    input resetn,
    input test_mode,
    input scan_en,
    input mem_ready_0,
    input scan_in,
    output scan_out,
    output  [31:0]  mem_wdata_0,
    output mem_valid_0,
    output mem_instr_0,
    input   [31:0]  mem_rdata_0,
    output  [31:0]  mem_addr_0,
    output trap_0,
    output  [3:0] mem_wstrb_0,
    input   [31:0]  irq_0,
    output  [31:0]  eoi_0,
    input mem_ready_1,
    output  [31:0]  mem_wdata_1,
    output mem_valid_1,
    output mem_instr_1,
    input   [31:0]  mem_rdata_1,
    output  [31:0]  mem_addr_1,
    output trap_1,
    output  [3:0] mem_wstrb_1,
    input   [31:0]  irq_1,
    output  [31:0]  eoi_1
);

wire scan_mid;

core_wrapper core0(
    .clk    (clk),
    .scan_en    (scan_en),
    .resetn (resetn),
    .test_mode  (test_mode),
    .scan_in    (scan_in),
    .trap (trap_0),
    .mem_valid  (mem_valid_0),
    .mem_ready  (mem_ready_0),
    .mem_instr  (mem_instr_0),
    .mem_addr   (mem_addr_0),
    .mem_wdata  (mem_wdata_0),
    .mem_rdata  (mem_rdata_0),
    .mem_wstrb   (mem_wstrb_0),
    .scan_out   (scan_mid),
    .irq    (irq_0),
    .eoi    (eoi_0)
);

core_wrapper core1(
    .clk    (clk),
    .scan_en    (scan_en),
    .resetn (resetn),
    .test_mode  (test_mode),
    .scan_in    (scan_mid),
    .trap (trap_1),
    .mem_valid  (mem_valid_1),
    .mem_ready  (mem_ready_1),
    .mem_instr  (mem_instr_1),
    .mem_addr   (mem_addr_1),
    .mem_wdata  (mem_wdata_1),
    .mem_rdata  (mem_rdata_1),
    .mem_wstrb   (mem_wstrb_1),
    .scan_out   (scan_out),
    .irq    (irq_1),
    .eoi    (eoi_1)
);

endmodule