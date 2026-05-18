module test (
    vif_if vif
);
  // =================== DPI FUNCTIONS ==================== //
  //import "DPI-C" function real ref_model(real initial_value);

  // ================== GLOBAL VARIABLES ================== //

  import config_pkg::*;
  logic sig;

  assign  sig = vif.sig_in_i;

  // =================== MAIN SEQUENCE ==================== //

  initial begin
    // Initial values
    $display("Begin Of Simulation.");
//    get_config_args();

    // Apply reset
    //reset();

    // Stimulus
    TP05();
    TP01();
    TP02();
    TP03();
    TP04();

    // Drain time
    #(100ns);
    $display("End Of Simulation.");
    $finish;
  end


  // ======================= TASKS ======================== //

  task automatic reset();
    vif.rst_ni = 1'b1;
    vif.sig_in_i  = 1'b0;
    repeat (2) @(posedge vif.clk_i);
    vif.rst_ni = 1'b0;
    @(posedge vif.clk_i);
    vif.rst_ni = 1'b1;
    @(posedge vif.clk_i);
  endtask : reset

  //TP-01 Rising Edge
  task automatic TP01();
    vif.sig_in_i  = 1'b0;
    @(posedge vif.clk_i);
    vif.sig_in_i  = 1'b0;
    @(posedge vif.clk_i);
    vif.sig_in_i  = 1'b1;
    @(posedge vif.clk_i);
    vif.sig_in_i  = 1'b1;
    @(posedge vif.clk_i);
    vif.sig_in_i  = 1'b1;
    @(posedge vif.clk_i);
  endtask : TP01

  //TP-02 Falling Edge
  task automatic TP02();
    vif.sig_in_i  = 1'b1;
    @(posedge vif.clk_i);
    vif.sig_in_i  = 1'b1;
    @(posedge vif.clk_i);
    vif.sig_in_i  = 1'b0;
    @(posedge vif.clk_i);
    vif.sig_in_i  = 1'b0;
    @(posedge vif.clk_i);
    vif.sig_in_i  = 1'b0;
    @(posedge vif.clk_i);
  endtask : TP02

  //TP-03 Multiple Edges
  task automatic TP03();
    vif.sig_in_i  = 1'b0;
    @(posedge vif.clk_i);
    vif.sig_in_i  = 1'b1;
    @(posedge vif.clk_i);
    vif.sig_in_i  = 1'b0;
    @(posedge vif.clk_i);
    vif.sig_in_i  = 1'b1;
    @(posedge vif.clk_i);
    vif.sig_in_i  = 1'b0;
    @(posedge vif.clk_i);
  endtask : TP03

  //TP-04 No R-etrigger
  task automatic TP04();
    vif.sig_in_i  = 1'b0;
    repeat (5) @(posedge vif.clk_i);
    vif.sig_in_i  = 1'b1;
    repeat (5) @(posedge vif.clk_i);
  endtask : TP04

  //TP-05 Reset TERMINAR
  task automatic TP05();
    vif.sig_in_i  = 1'b1;
    vif.rst_ni    = 1'b1;
    repeat (2) @(posedge vif.clk_i);
    vif.rst_ni    = 1'b0;
    repeat (2) @(posedge vif.clk_i);
    vif.sig_in_i  = 1'b0;
    @(posedge vif.clk_i);
    vif.sig_in_i  = 1'b1;
    repeat (2) @(posedge vif.clk_i);
    vif.rst_ni    = 1'b1;
    repeat (2) @(posedge vif.clk_i);
    repeat (2) @(posedge vif.clk_i);
    vif.sig_in_i  = 1'b0;
    @(posedge vif.clk_i);
  endtask : TP05
  // ===================== FUNCTIONS ====================== //
  // =====================   COVER   ====================== //
  covergroup  edge_cov;
    coverpoint  sig {
      bins  rise = (0=>1);
      bins  fall = (1=>0);
    }
  endgroup

  edge_cov  edc;
  initial begin : coverage
    edc = new();
    forever begin @(posedge vif.clk_i);
      edc.sample();
    end
  end : coverage

endmodule : test
