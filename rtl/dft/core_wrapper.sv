module core_wrapper(
        input clk,
        input resetn,
        output trap,
        output mem_valid,
        output mem_instr,
        input mem_ready,
        output [31:0] mem_addr,
        output [31:0] mem_wdata,
        output [3:0] mem_wstrb,
        input [31:0] mem_rdata,
        input [31:0] irq,
        output [31:0] eoi,
        input scan_en,
        input test_mode,
        input scan_in,
        output scan_out
    );

    wire core_trap;
    wire core_mem_valid;
    wire core_mem_instr;
    wire core_mem_ready;
    wire [31:0] core_mem_addr;
    wire [31:0] core_mem_wdata;
    wire [3:0] core_mem_wstrb;
    wire [31:0] core_mem_rdata;
    wire [31:0] core_irq;
    wire [31:0] core_eoi;

    picorv32 #(
        .ENABLE_COUNTERS(1),
        .ENABLE_REGS_16_31(1),
        .ENABLE_IRQ(1),
        .ENABLE_MUL(0),
        .ENABLE_DIV(0),
        .ENABLE_FAST_MUL(0)
    ) core (
        .clk    (clk),
        .resetn (resetn),
        .trap   (core_trap),
        .mem_valid  (core_mem_valid),
        .mem_instr  (core_mem_instr),
        .mem_ready  (core_mem_ready),
        .mem_addr   (core_mem_addr),
        .mem_wdata  (core_mem_wdata),
        .mem_wstrb  (core_mem_wstrb),
        .mem_rdata  (core_mem_rdata),
        .irq    (core_irq),
        .eoi    (core_eoi)
    );

    wire [9:0] scan_chain;
    wbr_cell wrap_trap(
        .clk    (clk),
        .scan_en    (scan_en),
        .test_mode (test_mode),
        .func_in    (core_trap),
        .scan_in    (scan_in),
        .scan_out   (scan_chain[0]),
        .func_out   (trap)
    );

    wbr_cell wrap_mem_valid(
        .clk    (clk),
        .scan_en    (scan_en),
        .test_mode (test_mode),
        .func_in    (core_mem_valid),
        .scan_in    (scan_chain[0]),
        .scan_out   (scan_chain[1]),
        .func_out   (mem_valid)
    );

    wbr_cell wrap_mem_instr(
        .clk    (clk),
        .scan_en    (scan_en),
        .test_mode  (test_mode),
        .func_in    (core_mem_instr),
        .scan_in    (scan_chain[1]),
        .scan_out   (scan_chain[2]),
        .func_out   (mem_instr)
    );

    wbr_cell wrap_mem_ready(
        .clk    (clk),
        .scan_en    (scan_en),
        .test_mode  (test_mode),
        .func_in    (mem_ready),
        .scan_in    (scan_chain[2]),
        .scan_out   (scan_chain[3]),
        .func_out   (core_mem_ready)
    );

    wire [32:0] rdata_scan;
    assign rdata_scan[0]=scan_chain[3];
    genvar i;
    generate
        for (i=0;i<32;i=i+1) begin : wrap_mem_rdata
            wbr_cell wrap_bit(
                .clk(clk),
                .scan_en    (scan_en),
                .test_mode  (test_mode),
                .func_in    (mem_rdata[i]),
                .scan_in    (rdata_scan[i]),
                .scan_out   (rdata_scan[i+1]),
                .func_out   (core_mem_rdata[i])
            );
        end
    endgenerate

    wire [32:0] addr_scan;
    assign addr_scan[0] = rdata_scan[32];
    genvar j;
    generate
        for (j=0;j<32;j=j+1) begin : wrap_mem_addr
            wbr_cell wrap_bit(
                .clk        (clk),
                .scan_en    (scan_en),
                .test_mode  (test_mode),
                .func_in    (core_mem_addr[j]),
                .scan_in    (addr_scan[j]),
                .scan_out   (addr_scan[j+1]),
                .func_out   (mem_addr[j])
            );
        end
    endgenerate

    wire [32:0] wdata_scan;
    assign wdata_scan[0] = addr_scan[32];
    genvar k;
    generate
        for (k=0;k<32;k=k+1) begin : wrap_mem_wdata
            wbr_cell wrap_bit(
                .clk        (clk),
                .scan_en    (scan_en),
                .test_mode  (test_mode),
                .func_in    (core_mem_wdata[k]),
                .scan_in    (wdata_scan[k]),
                .scan_out   (wdata_scan[k+1]),
                .func_out   (mem_wdata[k])
            );
        end
    endgenerate

    wire [4:0] wstrb_scan;
    assign wstrb_scan[0] = wdata_scan[32];
    genvar l;
    generate
        for (l=0;l<4;l=l+1) begin : wrap_mem_wstrb
            wbr_cell wrap_bit(
                .clk        (clk),
                .scan_en    (scan_en),
                .test_mode  (test_mode),
                .func_in    (core_mem_wstrb[l]),
                .scan_in    (wstrb_scan[l]),
                .scan_out   (wstrb_scan[l+1]),
                .func_out   (mem_wstrb[l])
            );
        end
    endgenerate

    wire [32:0] irq_scan;
    assign irq_scan[0] = wstrb_scan[4];
    genvar m;
    generate
        for (m=0;m<32;m=m+1) begin : wrap_irq
            wbr_cell wrap_bit(
                .clk        (clk),
                .scan_en    (scan_en),
                .test_mode  (test_mode),
                .func_in    (irq[m]),
                .scan_in    (irq_scan[m]),
                .scan_out   (irq_scan[m+1]),
                .func_out   (core_irq[m])
            );
        end
    endgenerate

    wire [32:0] eoi_scan;
    assign eoi_scan[0] = irq_scan[32];
    genvar n;
    generate
        for (n=0;n<32;n=n+1) begin : wrap_eoi
            wbr_cell wrap_bit(
                .clk        (clk),
                .scan_en    (scan_en),
                .test_mode  (test_mode),
                .func_in    (core_eoi[n]),
                .scan_in    (eoi_scan[n]),
                .scan_out   (eoi_scan[n+1]),
                .func_out   (eoi[n])
            );
        end
    endgenerate

    assign scan_out=eoi_scan[32];

endmodule