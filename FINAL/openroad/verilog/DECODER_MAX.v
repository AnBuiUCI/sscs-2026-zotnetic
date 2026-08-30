// Black-box declaration of the DECODER_MAX analog macro.
// The layout is the real implementation; this only gives the tools
// an interface to bind against.

(* blackbox *)
module DECODER_MAX (
    VDD,
    XY,
    XZ,
    X,
    Y,
    YZ,
    Z,
    VSS
);
  inout  VDD;
  input  XY;
  input  XZ;
  output X;
  output Y;
  input  YZ;
  output Z;
  inout  VSS;
endmodule
