// Black-box declaration of the io_secondary_5p0 analog macro.
// The layout is the real implementation; this only gives the tools
// an interface to bind against.

(* blackbox *)
module io_secondary_5p0 (
    VDD,
    to_gate,
    ASIG5V,
    VSS
);
  inout  VDD;
  output to_gate;
  input  ASIG5V;
  inout  VSS;
endmodule
