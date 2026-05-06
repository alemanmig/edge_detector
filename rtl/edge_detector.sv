// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Rising/Falling Edge Detector — single-cycle pulses
//
// Generates a one-clock-wide pulse on each 0→1 (rise_pulse_o) and
// 1→0 (fall_pulse_o) transition of sig_in_i.
//
// Logic:
//   rise_pulse_o =  sig_in_i & ~sig_prev_q
//   fall_pulse_o = ~sig_in_i &  sig_prev_q
//
// Note: if sig_in_i originates from an asynchronous source, place a
// two-flop synchronizer before this module to mitigate metastability.

module edge_detector #(
  // Value loaded into sig_prev on reset (default 0 → no spurious pulse at start-up).
  parameter bit ResetPrev = 1'b0
) (
  input  logic clk_i,
  input  logic rst_ni,    // Asynchronous active-low reset
  input  logic sig_in_i,
  output logic rise_pulse_o,
  output logic fall_pulse_o
);

  logic sig_prev_q;

  // Register the previous sample; cleared to ResetPrev on reset.
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      sig_prev_q <= ResetPrev;
    end else begin
      sig_prev_q <= sig_in_i;
    end
  end

  // Single-cycle pulse combinational logic.
  assign rise_pulse_o =  sig_in_i & ~sig_prev_q;
  assign fall_pulse_o = ~sig_in_i &  sig_prev_q;

endmodule
