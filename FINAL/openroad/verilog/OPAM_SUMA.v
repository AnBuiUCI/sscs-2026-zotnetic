// Black-box declaration of the OPAM_SUMA analog macro.
// The layout is the real implementation; this only gives the tools
// an interface to bind against.

(* blackbox *)
module OPAM_SUMA (
    A1,
    A2,
    B1,
    B2,
    OUT,
    VDD,
    VSS
);
  input  A1;
  input  A2;
  input  B1;
  input  B2;
  output OUT;
  inout  VDD;
  inout  VSS;
endmodule
