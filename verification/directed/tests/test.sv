module test (
    vif_if vif
);
  // =================== DPI FUNCTIONS ==================== //
  //import "DPI-C" function real ref_model(real initial_value);

  // ================== GLOBAL VARIABLES ================== //

  import config_pkg::*;

  // =================== MAIN SEQUENCE ==================== //

  initial begin
    // Initial values
    $display("Begin Of Simulation.");
//    get_config_args();

    // Apply reset
    reset();

    // Stimulus


    // Drain time
    #(100ns);
    $display("End Of Simulation.");
    $finish;
  end


  // ======================= TASKS ======================== //

  task automatic reset();
    vif.rst_ni = 1'b1;
    vif.sig_in_i  = 1'b0;
    @(posedge vif.clk_i);   // hold for at least 2 rising edges
    @(posedge vif.clk_i);
    vif.rst_ni = 1'b0;
  endtask : reset


endmodule : test
