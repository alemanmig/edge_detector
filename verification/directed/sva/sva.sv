module sva (
    input logic clk_i,
    input logic rst_ni,
    input logic sig_in_i,
    input logic rise_pulse_o,
    input logic fall_pulse_o
);

  default clocking cb @(posedge clk_i);
  endclocking

  // A rising transition must produce a rise pulse in the same sampled cycle.
  property p_rise_detect;
    $past(rst_ni) && !$past(sig_in_i) && sig_in_i |-> rise_pulse_o && !fall_pulse_o;
  endproperty

  // A falling transition must produce a fall pulse in the same sampled cycle.
  property p_fall_detect;
    $past(rst_ni) && $past(sig_in_i) && !sig_in_i |-> fall_pulse_o && !rise_pulse_o;
  endproperty

  // While the input is stable, no output pulse should be generated.
  property p_no_pulse_when_stable;
    $past(rst_ni) && (sig_in_i == $past(sig_in_i)) |-> !rise_pulse_o && !fall_pulse_o;
  endproperty

  // A rise pulse must deassert on the next cycle.
  property p_rise_single_cycle;
    rise_pulse_o |=> !rise_pulse_o;
  endproperty

  // A fall pulse must deassert on the next cycle.
  property p_fall_single_cycle;
    fall_pulse_o |=> !fall_pulse_o;
  endproperty

  // Rise and fall pulses are mutually exclusive.
  property p_mutual_exclusion;
    !(rise_pulse_o && fall_pulse_o);
  endproperty

  // No pulse should be asserted while reset is active.
  property p_no_pulse_during_reset;
    !rst_ni |-> !rise_pulse_o && !fall_pulse_o;
  endproperty

  assert_rise_detect:       assert property (disable iff (!rst_ni) p_rise_detect);
  assert_fall_detect:       assert property (disable iff (!rst_ni) p_fall_detect);
  assert_no_pulse_stable:   assert property (disable iff (!rst_ni) p_no_pulse_when_stable);
  assert_rise_width:        assert property (disable iff (!rst_ni) p_rise_single_cycle);
  assert_fall_width:        assert property (disable iff (!rst_ni) p_fall_single_cycle);
  assert_mutual_exclusion:  assert property (disable iff (!rst_ni) p_mutual_exclusion);
  assert_no_pulse_reset:    assert property (p_no_pulse_during_reset);

  cover_rise_detect: cover property (rst_ni && $past(rst_ni) && !$past(sig_in_i) && sig_in_i);
  cover_fall_detect: cover property (rst_ni && $past(rst_ni) && $past(sig_in_i) && !sig_in_i);

endmodule
