module edge_detector_cov (
    input logic clk_i,
    input logic rst_ni,
    input logic sig_in_i,
    input logic rise_pulse_o,
    input logic fall_pulse_o
);

  typedef enum logic [1:0] {
    TRANS_STABLE_0 = 2'b00,
    TRANS_RISE     = 2'b01,
    TRANS_FALL     = 2'b10,
    TRANS_STABLE_1 = 2'b11
  } transition_e;

  transition_e transition_kind;
  logic prev_sig_q;
  logic prev_rst_ni_q;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      prev_sig_q   <= 1'b0;
      prev_rst_ni_q <= 1'b0;
    end else begin
      prev_sig_q   <= sig_in_i;
      prev_rst_ni_q <= rst_ni;
    end
  end

  always_comb begin
    unique case ({prev_sig_q, sig_in_i})
      2'b00: transition_kind = TRANS_STABLE_0;
      2'b01: transition_kind = TRANS_RISE;
      2'b10: transition_kind = TRANS_FALL;
      2'b11: transition_kind = TRANS_STABLE_1;
      default: transition_kind = TRANS_STABLE_0;
    endcase
  end

  covergroup edge_detector_cg @(posedge clk_i);
    option.per_instance = 1;
    option.name = "edge_detector_cg";

    cp_transition: coverpoint transition_kind iff (rst_ni && prev_rst_ni_q) {
      bins stable_low  = {TRANS_STABLE_0};
      bins rise_edge   = {TRANS_RISE};
      bins fall_edge   = {TRANS_FALL};
      bins stable_high = {TRANS_STABLE_1};
    }

    cp_rise_pulse: coverpoint rise_pulse_o iff (rst_ni) {
      bins no_pulse = {1'b0};
      bins pulse    = {1'b1};
      bins one_cycle_width = (1'b0 => 1'b1 => 1'b0);
    }

    cp_fall_pulse: coverpoint fall_pulse_o iff (rst_ni) {
      bins no_pulse = {1'b0};
      bins pulse    = {1'b1};
      bins one_cycle_width = (1'b0 => 1'b1 => 1'b0);
    }

    cp_no_overlap: coverpoint {rise_pulse_o, fall_pulse_o} iff (rst_ni) {
      bins idle      = {2'b00};
      bins rise_only = {2'b10};
      bins fall_only = {2'b01};
      illegal_bins overlap = {2'b11};
    }

    cp_post_reset: coverpoint {prev_rst_ni_q, sig_in_i, rise_pulse_o, fall_pulse_o} iff (rst_ni) {
      bins first_high_after_reset = {4'b0110};
      bins first_low_after_reset  = {4'b0100};
    }

    cross_transition_outputs: cross cp_transition, cp_no_overlap iff (rst_ni && prev_rst_ni_q) {
      bins rise_detected =
          binsof(cp_transition.rise_edge) && binsof(cp_no_overlap.rise_only);
      bins fall_detected =
          binsof(cp_transition.fall_edge) && binsof(cp_no_overlap.fall_only);
      bins stable_low_idle =
          binsof(cp_transition.stable_low) && binsof(cp_no_overlap.idle);
      bins stable_high_idle =
          binsof(cp_transition.stable_high) && binsof(cp_no_overlap.idle);
    }
  endgroup

  edge_detector_cg cg_inst = new();

endmodule
