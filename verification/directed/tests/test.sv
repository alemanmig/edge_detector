module test (
    vif_if vif
);
  import config_pkg::*;

  // =================== MAIN SEQUENCE ==================== //

  initial begin
    $display("Begin Of Simulation.");
    initialize_signals();

    tp_05_reset();
    reset();
    tp_01_rising_edge();
    reset();
    tp_02_falling_edge();
    reset();
    tp_03_multiple_edges();
    reset();
    tp_04_no_retrigger();

    #(100ns);
    $display("End Of Simulation.");
    $finish;
  end


  // ======================= TASKS ======================== //

  task automatic initialize_signals();
    vif.rst_ni  = 1'b1;
    vif.sig_in_i = 1'b0;
  endtask : initialize_signals


  task automatic reset(input logic sig_in_value = 1'b0, input int unsigned hold_cycles = 2);
    vif.rst_ni   = 1'b0;
    vif.sig_in_i = sig_in_value;
    repeat (hold_cycles) @(posedge vif.clk_i);
    @(negedge vif.clk_i);
    vif.rst_ni = 1'b1;
  endtask : reset


  task automatic drive_cycle(input logic sig_in_value);
    @(negedge vif.clk_i);
    vif.sig_in_i = sig_in_value;
    @(posedge vif.clk_i);
    $display("[DRV ] %10t: sig_in_i=%0b rise_pulse_o=%0b fall_pulse_o=%0b",
             $realtime, vif.sig_in_i, vif.rise_pulse_o, vif.fall_pulse_o);
  endtask : drive_cycle


  task automatic tp_01_rising_edge();
    $display("[TEST] %10t: TP-01 Rising Edge", $realtime);
    drive_cycle(1'b0);
    drive_cycle(1'b0);
    drive_cycle(1'b1);
    drive_cycle(1'b1);
    drive_cycle(1'b1);
  endtask : tp_01_rising_edge


  task automatic tp_02_falling_edge();
    $display("[TEST] %10t: TP-02 Falling Edge", $realtime);
    drive_cycle(1'b1);
    drive_cycle(1'b1);
    drive_cycle(1'b0);
    drive_cycle(1'b0);
    drive_cycle(1'b0);
  endtask : tp_02_falling_edge


  task automatic tp_03_multiple_edges();
    $display("[TEST] %10t: TP-03 Multiple Edges", $realtime);
    drive_cycle(1'b0);
    drive_cycle(1'b1);
    drive_cycle(1'b0);
    drive_cycle(1'b1);
    drive_cycle(1'b0);
  endtask : tp_03_multiple_edges


  task automatic tp_04_no_retrigger();
    $display("[TEST] %10t: TP-04 No Re-trigger", $realtime);
    repeat (5) drive_cycle(1'b0);
    repeat (5) drive_cycle(1'b1);
  endtask : tp_04_no_retrigger


  task automatic tp_05_reset();
    $display("[TEST] %10t: TP-05 Reset", $realtime);
    reset(1'b1);
    drive_cycle(1'b1);
    drive_cycle(1'b1);
    drive_cycle(1'b0);
  endtask : tp_05_reset


  task automatic wait_cycles(input int unsigned num_cycles);
    repeat (num_cycles) @(posedge vif.clk_i);
  endtask : wait_cycles


endmodule : test
