module tb;

  timeunit      1ns;
  timeprecision 100ps;

  import config_pkg::*;

  // Clock signal
  logic clk_i = 0;
  localparam int unsigned ClkPeriod = 10;  // 100 MHz -> 10 ns period
  always #( (ClkPeriod / 2) * 1ns) clk_i = ~clk_i;

  // Interface
  vif_if vif (clk_i);

  // Test
  test top_test (vif);

  // Instantiation
edge_detector #(
  .ResetPrev (1'b0)
) u_edge_detector (
  .clk_i        (clk_i),
  .rst_ni       (rst_ni),
  .sig_in_i     (sig_in_i),
  .rise_pulse_o (rise_pulse_o),
  .fall_pulse_o (fall_pulse_o)
);

  initial begin
    $timeformat(-9, 1, "ns", 10);
  end

endmodule : tb
