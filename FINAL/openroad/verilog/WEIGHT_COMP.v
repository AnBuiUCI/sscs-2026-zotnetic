// Black-box declaration of the WEIGHT_COMP analog macro.
// The layout is the real implementation; this only gives the tools
// an interface to bind against.

(* blackbox *)
module WEIGHT_COMP (
    VDD,
    VSS,
    VA,
    VB,
    VC,
    VD,
    WE,
    OUT,
    OUT_N
);
  inout  VDD;
  inout  VSS;
  input  VA;
  input  VB;
  input  VC;
  input  VD;
  inout  WE;
  inout  OUT;
  inout  OUT_N;
endmodule
