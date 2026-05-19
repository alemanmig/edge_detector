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
    first();
    reset();
    sequence_two();
    reset();
    multiple_edges();
    // Stimulus


    // Drain time
    //#(100ns);
    $display("End Of Simulation.");
    $finish;
  end


  // ======================= TASKS ======================== //

  task automatic reset();
    vif.rst_ni = 1'b0;
    vif.sig_in_i  = 1'b0;
    @(posedge vif.clk_i);   // hold for at least one rising edge
    vif.rst_ni = 1'b1;
  endtask : reset

  task automatic first();
    vif.sig_in_i = 1'b0;
   @(posedge vif.clk_i);
    vif.sig_in_i = 1'b0;
   @(posedge vif.clk_i);
    vif.sig_in_i = 1'b1;
   @(posedge vif.clk_i);
    vif.sig_in_i = 1'b1;
   @(posedge vif.clk_i);
    vif.sig_in_i = 1'b1;  // cambio para assertion
   @(posedge vif.clk_i);
  endtask

  task automatic sequence_two();
      vif.sig_in_i = 1'b1;
   @(posedge vif.clk_i);
    vif.sig_in_i = 1'b1;
   @(posedge vif.clk_i);
    vif.sig_in_i = 1'b0;
   @(posedge vif.clk_i);
    vif.sig_in_i = 1'b0;
   @(posedge vif.clk_i);
    vif.sig_in_i = 1'b0;  // cambio para assertion
   @(posedge vif.clk_i);
  endtask

  task automatic multiple_edges();
      vif.sig_in_i = 1'b0;
   @(posedge vif.clk_i);
    vif.sig_in_i = 1'b1;
   @(posedge vif.clk_i);
    vif.sig_in_i = 1'b0;
   @(posedge vif.clk_i);
    vif.sig_in_i = 1'b1;
   @(posedge vif.clk_i);
    vif.sig_in_i = 1'b0;  // cambio para assertion
   @(posedge vif.clk_i);
  endtask


endmodule : test
