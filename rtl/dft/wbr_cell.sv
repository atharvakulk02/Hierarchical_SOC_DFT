module wbr_cell (
    input  clk,
    input  scan_en,
    input  test_mode,
    input  func_in,
    input  scan_in,
    output scan_out,
    output func_out
);

reg capture_ff;

always@(posedge clk) begin
    if(scan_en)
        capture_ff<=scan_in;
    else
        capture_ff<=func_in;
end

assign scan_out=capture_ff;
assign func_out=test_mode?capture_ff:func_in;

endmodule
