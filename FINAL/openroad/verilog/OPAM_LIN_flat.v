// Black-box declaration of the OPAM_LIN_flat analog macro.
// The layout is the real implementation; this only gives the tools
// an interface to bind against.

(* blackbox *)
module OPAM_LIN_flat (
    INN,
    INP,
    VDD,
    VSS,
    OUT
);
  input  INN;
  input  INP;
  inout  VDD;
  inout  VSS;
  inout  OUT;
endmodule
