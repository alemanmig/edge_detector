module sva (
  input  logic clk_i,
  input  logic rst_ni,    // Asynchronous active-low reset
  input  logic sig_in_i,
  input  logic rise_pulse_o,
  input  logic fall_pulse_o
);

  property  TP01_Proper;
    @(posedge clk_i)
      disable iff(!rst_ni)
        (($past(sig_in_i,4)===1'b0)      &&  ($past(sig_in_i,3)===1'b0)      &&  ($past(sig_in_i,2)===1'b1)      &&  ($past(sig_in_i)===1'b1)      &&  (sig_in_i===1'b1))     |->
        (($past(rise_pulse_o,4)===1'b0)  &&  ($past(rise_pulse_o,3)===1'b0)  &&  ($past(rise_pulse_o,2)===1'b1)  &&  ($past(rise_pulse_o)===1'b0)  &&  (rise_pulse_o===1'b0));
  endproperty

  //property  Rise_Proper;
  //  @(posedge clk_i)
  //   disable iff(!rst_ni)
  //     (($past(sig_in_i)===1'b0)  &&  (sig_in_i===1'b1))  |-> rise_pulse_o;
  //endproperty

  //property  Fall_Proper;
  //  @(posedge clk_i)
  //    disable iff(!rst_ni)
  //      (($past(sig_in_i)===1'b1)  &&  (sig_in_i===1'b0)) |-> fall_pulse_o;
  //endproperty

  //Rise_Assert : assert  property(Rise_Proper)
  //  $info("Rise Passed");
  //else
  //  $error("Rise not passed");

  //Fall_Assert   : assert  property(Fall_Proper)
  //  $info("Fall Passed");
  //else
  //  $error("Fall not passed");

  TP01_Assert : assert  property(TP01_Proper)
    $info("TP-01 Passed");
  else
    $error("TP-01 not passed");

endmodule
