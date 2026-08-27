// Black-box declaration of the ESD_CDM analog macro.
// The layout is the real implementation; this only gives the tools
// an interface to bind against.

(* blackbox *)
module ESD_CDM (
    PAD,
    CORE,
    VDD,
    VSS
);
  input  PAD;
  output CORE;
  inout  VDD;
  inout  VSS;
endmodule
