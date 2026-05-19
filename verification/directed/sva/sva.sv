
module sva #(
    parameter int ClkFreq    = 100_000_000,
    parameter int StableTime = 10
)(
  input  logic clk_i,
  input  logic rst_ni,    // Asynchronous active-low reset
  input  logic sig_in_i,
  input  logic  rise_pulse_o,
  input logic  fall_pulse_o
);

  initial begin
    $display("[%0t] SVA module instantiated: %m", $time);
  end

// TP-01 Rising edge
sequence ex_one;
 ((sig_in_i == 1'b0) && (rise_pulse_o  == 1'b0) && (fall_pulse_o == 1'b0)) ##1  
 ((sig_in_i == 1'b0) && (rise_pulse_o  == 1'b0) && (fall_pulse_o == 1'b0)) ##1
 ((sig_in_i == 1'b1) && (rise_pulse_o  == 1'b1) && (fall_pulse_o == 1'b0)) ##1
 ((sig_in_i == 1'b1) && (rise_pulse_o  == 1'b0) && (fall_pulse_o == 1'b0)) ##1
 ((sig_in_i == 1'b1) && (rise_pulse_o  == 1'b0) && (fall_pulse_o == 1'b0));
endsequence

property one_check;
 @(posedge clk_i) disable iff (!rst_ni)
  ex_one; 
endproperty

check_assert: assert property (one_check) 
  else $error("Failed first sequence");

property expected_one;
 @(posedge clk_i) disable iff (!rst_ni)
(sig_in_i == 1'b0) ##1
(sig_in_i == 1'b0) ##1
(sig_in_i == 1'b1) 
  |->
(rise_pulse_o == 1'b0) ##1
(rise_pulse_o == 1'b0) ##1
(rise_pulse_o == 1'b1);
endproperty

check_expected_one: assert property (expected_one)
  else $error("failed one in cycle two");

property rise_zero_specific_cycles_p;
  @(posedge clk_i) disable iff (!rst_ni)

    (sig_in_i == 1'b0) ##1
    (sig_in_i == 1'b0) ##1
    (sig_in_i == 1'b1) ##1
    (sig_in_i == 1'b1) ##1
    (sig_in_i == 1'b1)

    |->
    (rise_pulse_o == 1'b0) ##1
    (rise_pulse_o == 1'b0) ##1
    (rise_pulse_o == 1'b1) ##1
    (rise_pulse_o == 1'b0) ##1
    (rise_pulse_o == 1'b0);

endproperty

check_expected_two: assert property (rise_zero_specific_cycles_p) 
  else $error("failed zeros in specific cycles");

property all_zero_fall;
 @(posedge clk_i) disable iff (!rst_ni)
  $fell(sig_in_i) |-> (fall_pulse_o && !rise_pulse_o); 
endproperty 

check_expected_fall: assert property (all_zero_fall)
  else $error("failed we have some fall");

////////////////////////////////////////////////
// Falling edge sequence two

sequence ex_two;
 ((sig_in_i == 1'b1) && (rise_pulse_o  == 1'b1) && (fall_pulse_o == 1'b0)) ##1  
 ((sig_in_i == 1'b1) && (rise_pulse_o  == 1'b1) && (fall_pulse_o == 1'b0)) ##1
 ((sig_in_i == 1'b0) && (rise_pulse_o  == 1'b0) && (fall_pulse_o == 1'b1)) ##1
 ((sig_in_i == 1'b0) && (rise_pulse_o  == 1'b0) && (fall_pulse_o == 1'b0)) ##1
 ((sig_in_i == 1'b0) && (rise_pulse_o  == 1'b0) && (fall_pulse_o == 1'b0));
endsequence

property two_check;
 @(posedge clk_i) disable iff (!rst_ni)
  ex_two; 
endproperty

check_assert_two: assert property (two_check) 
  else $error("Failed first sequence");

property expected_fall_one;
 @(posedge clk_i) disable iff (!rst_ni)
(sig_in_i == 1'b1) ##1
(sig_in_i == 1'b1) ##1
(sig_in_i == 1'b0) 
  |->
(fall_pulse_o == 1'b0) ##1
(fall_pulse_o == 1'b0) ##1
(fall_pulse_o == 1'b1);
endproperty

check_expected_fall_one: assert property (expected_fall_one)
  else $error("failed one in cycle two");

property fall_zero_specific_cycles_p;
  @(posedge clk_i) disable iff (!rst_ni)

    (sig_in_i == 1'b1) ##1
    (sig_in_i == 1'b1) ##1
    (sig_in_i == 1'b0) ##1
    (sig_in_i == 1'b0) ##1
    (sig_in_i == 1'b0)

    |->
    (fall_pulse_o == 1'b0) ##1
    (fall_pulse_o == 1'b0) ##1
    (fall_pulse_o == 1'b1) ##1
    (fall_pulse_o == 1'b0) ##1
    (fall_pulse_o == 1'b0);

endproperty

check_expected_fall_two: assert property (fall_zero_specific_cycles_p) 
  else $error("failed zeros in specific cycles");

property all_zero_rise;
 @(posedge clk_i) disable iff (!rst_ni)
  $rose(sig_in_i) |-> (!fall_pulse_o && rise_pulse_o); 
endproperty 

check_expected_rise: assert property (all_zero_rise)
  else $error("failed we have some rise");

// TP-05 - Reset 
// validate post reset 
sequence change_reset;
  (!rst_ni && sig_in_i) ##1 (rst_ni && sig_in_i);  
endsequence 

property post_reset;
 @(posedge clk_i) 
  change_reset |-> (rise_pulse_o && !fall_pulse_o);
endproperty

check_reset: assert property (post_reset)
  else $error("TP-05 failed: Bad behavior post reset");

// Multiple Edges 
// validate alternate transitions

sequence alternate_inputs;
  !sig_in_i ##1 sig_in_i  // Cuenta cambios de 0 a 1
endsequence

sequence alternate_inputs_two;
  sig_in_i ##1 !sig_in_i  // Cuenta cambios de 1 a 0 
endsequence

property alternate_outputs;
 @(posedge clk_i) disable iff (!rst_ni) 
  alternate_inputs |-> (rise_pulse_o && !fall_pulse_o);
endproperty

property alternate_outputs_two;
 @(posedge clk_i) disable iff (!rst_ni) 
  alternate_inputs_two |-> (fall_pulse_o && !rise_pulse_o);
endproperty

check_rises: assert property (alternate_outputs) 
  else $error("TP-03 failed: Something is wrong with rise pulse when alternate inputs");

check_falls: assert property (alternate_outputs_two)
  else $error("TP-03 failed: Something is wrong with fall pulses when alternate inputs");

endmodule