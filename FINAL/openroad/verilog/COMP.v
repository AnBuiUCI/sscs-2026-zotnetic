// Black-box declaration of the COMP analog macro.
// The layout is the real implementation; this only gives the tools
// an interface to bind against.

(* blackbox *)
module COMP (
    VDD,
    INN,
    OUT,
    INP,
    VSS
);
  inout  VDD;
  input  INN;
  inout  OUT;
  input  INP;
  inout  VSS;
endmodule
