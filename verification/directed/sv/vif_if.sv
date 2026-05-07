`ifndef VIF_IF_SV
`define VIF_IF_SV

interface vif_if(
    input logic clk_i
);

  timeunit      1ns;
  timeprecision 100ps;

  import config_pkg::*;

  logic rst_ni;
  logic sig_in_i;
  logic rise_pulse_o;
  logic fall_pulse_o;

  /*clocking cb @(posedge clk_i);
    default input #1ns output #1ns;
    logic rst_ni;
    logic sig_in_i;
    logic rise_pulse_o;
    logic fall_pulse_o;
  endclocking*/

endinterface : vif_if

`endif // VIF_IF_SV
