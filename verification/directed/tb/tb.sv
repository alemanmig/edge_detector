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
edge_detector dut (
  .clk_i        (vif.clk_i),
  .rst_ni       (vif.rst_ni),
  .sig_in_i     (vif.sig_in_i),
  .rise_pulse_o (vif.rise_pulse_o),
  .fall_pulse_o (vif.fall_pulse_o)
);

bind edge_detector sva dut_sva(
  .clk_i          (vif.clk_i),
  .rst_ni         (vif.rst_ni),
  .sig_in_i       (vif.sig_in_i),
  .rise_pulse_o   (vif.rise_pulse_o),
  .fall_pulse_o   (vif.fall_pulse_o)
);

initial begin
  $timeformat(-9, 1, "ns", 10);
end

endmodule : tb
