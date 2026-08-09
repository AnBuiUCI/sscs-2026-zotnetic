// Black-box declaration of the DECODER analog macro.
// The layout is the real implementation; this only gives the tools
// an interface to bind against.

(* blackbox *)
module DECODER (
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
  inout  X;
  inout  Y;
  input  YZ;
  inout  Z;
  inout  VSS;
endmodule
