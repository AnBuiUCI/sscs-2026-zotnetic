// B26_A: our block inside the padring's user area.
// WRITTEN BY scripts/integrate_padframe.py -- do not edit by hand.
//
// The programming of the six digital pads lives in the PROGRAMMING
// table of that script and nowhere else:
//   OE     -> VDD   output always enabled: these six are permanent outputs
//   IE     -> VSS   receiver off; we never read the pad back
//   PU     -> VSS   no pull-up (don't care with OE=1, but tie it somewhere)
//   PD     -> VSS   no pull-down
//   CS     -> VSS   plain CMOS input rather than Schmitt (moot with IE=0)
//   SL     -> VSS   slow slew: less noise injected into an analogue chip
//   PDRV0  -> VSS   drive strength 4 mA, the lowest
//   PDRV1  -> VSS     ... the other half of the same code

module B26_A (
    VSS,
    S4P,
    S4N,
    Z,
    ZN_CS,
    ZN_SL,
    ZN_IE,
    ZN_OE,
    ZN_PU,
    ZN_PD,
    ZN_OUT,
    ZN_PDRV0,
    ZN_PDRV1,
    ZN_IN,
    ZP_CS,
    ZP_SL,
    ZP_IE,
    ZP_OE,
    ZP_PU,
    ZP_PD,
    ZP_OUT,
    ZP_PDRV0,
    ZP_PDRV1,
    ZP_IN,
    Y,
    YN_CS,
    YN_SL,
    YN_IE,
    YN_OE,
    YN_PU,
    YN_PD,
    YN_OUT,
    YN_PDRV0,
    YN_PDRV1,
    YN_IN,
    YP_CS,
    YP_SL,
    YP_IE,
    YP_OE,
    YP_PU,
    YP_PD,
    YP_OUT,
    YP_PDRV0,
    YP_PDRV1,
    YP_IN,
    X,
    XN_CS,
    XN_SL,
    XN_IE,
    XN_OE,
    XN_PU,
    XN_PD,
    XN_OUT,
    XN_PDRV0,
    XN_PDRV1,
    XN_IN,
    XP_CS,
    XP_SL,
    XP_IE,
    XP_OE,
    XP_PU,
    XP_PD,
    XP_OUT,
    XP_PDRV0,
    XP_PDRV1,
    XP_IN,
    S1N,
    S1P,
    S3P,
    S3N,
    S2N,
    S2P,
    VDD);
  inout VSS;
  inout S4P;
  inout S4N;
  inout Z;
  output ZN_CS;
  output ZN_SL;
  output ZN_IE;
  output ZN_OE;
  output ZN_PU;
  output ZN_PD;
  output ZN_OUT;
  output ZN_PDRV0;
  output ZN_PDRV1;
  input ZN_IN;
  output ZP_CS;
  output ZP_SL;
  output ZP_IE;
  output ZP_OE;
  output ZP_PU;
  output ZP_PD;
  output ZP_OUT;
  output ZP_PDRV0;
  output ZP_PDRV1;
  input ZP_IN;
  inout Y;
  output YN_CS;
  output YN_SL;
  output YN_IE;
  output YN_OE;
  output YN_PU;
  output YN_PD;
  output YN_OUT;
  output YN_PDRV0;
  output YN_PDRV1;
  input YN_IN;
  output YP_CS;
  output YP_SL;
  output YP_IE;
  output YP_OE;
  output YP_PU;
  output YP_PD;
  output YP_OUT;
  output YP_PDRV0;
  output YP_PDRV1;
  input YP_IN;
  inout X;
  output XN_CS;
  output XN_SL;
  output XN_IE;
  output XN_OE;
  output XN_PU;
  output XN_PD;
  output XN_OUT;
  output XN_PDRV0;
  output XN_PDRV1;
  input XN_IN;
  output XP_CS;
  output XP_SL;
  output XP_IE;
  output XP_OE;
  output XP_PU;
  output XP_PD;
  output XP_OUT;
  output XP_PDRV0;
  output XP_PDRV1;
  input XP_IN;
  inout S1N;
  inout S1P;
  inout S3P;
  inout S3N;
  inout S2N;
  inout S2P;
  inout VDD;

  assign ZN_CS = VSS;
  assign ZN_SL = VSS;
  assign ZN_IE = VSS;
  assign ZN_OE = VDD;
  assign ZN_PU = VSS;
  assign ZN_PD = VSS;
  assign ZN_PDRV0 = VSS;
  assign ZN_PDRV1 = VSS;
  assign ZP_CS = VSS;
  assign ZP_SL = VSS;
  assign ZP_IE = VSS;
  assign ZP_OE = VDD;
  assign ZP_PU = VSS;
  assign ZP_PD = VSS;
  assign ZP_PDRV0 = VSS;
  assign ZP_PDRV1 = VSS;
  assign YN_CS = VSS;
  assign YN_SL = VSS;
  assign YN_IE = VSS;
  assign YN_OE = VDD;
  assign YN_PU = VSS;
  assign YN_PD = VSS;
  assign YN_PDRV0 = VSS;
  assign YN_PDRV1 = VSS;
  assign YP_CS = VSS;
  assign YP_SL = VSS;
  assign YP_IE = VSS;
  assign YP_OE = VDD;
  assign YP_PU = VSS;
  assign YP_PD = VSS;
  assign YP_PDRV0 = VSS;
  assign YP_PDRV1 = VSS;
  assign XN_CS = VSS;
  assign XN_SL = VSS;
  assign XN_IE = VSS;
  assign XN_OE = VDD;
  assign XN_PU = VSS;
  assign XN_PD = VSS;
  assign XN_PDRV0 = VSS;
  assign XN_PDRV1 = VSS;
  assign XP_CS = VSS;
  assign XP_SL = VSS;
  assign XP_IE = VSS;
  assign XP_OE = VDD;
  assign XP_PU = VSS;
  assign XP_PD = VSS;
  assign XP_PDRV0 = VSS;
  assign XP_PDRV1 = VSS;

  // Secondary ESD, one io_secondary_5p0 per analogue pin.
  // Series resistor plus the two diodes, NEXT TO THE PAD:
  // anything between the pad and the clamp is unprotected.
  wire S4P_I;
  wire S4N_I;
  wire Z_I;
  wire Y_I;
  wire X_I;
  wire S1N_I;
  wire S1P_I;
  wire S3P_I;
  wire S3N_I;
  wire S2N_I;
  wire S2P_I;
  io_secondary_5p0 x_esd_S4P (.VDD(VDD), .to_gate(S4P_I), .ASIG5V(S4P), .VSS(VSS));
  io_secondary_5p0 x_esd_S4N (.VDD(VDD), .to_gate(S4N_I), .ASIG5V(S4N), .VSS(VSS));
  io_secondary_5p0 x_esd_Z (.VDD(VDD), .to_gate(Z_I), .ASIG5V(Z), .VSS(VSS));
  io_secondary_5p0 x_esd_Y (.VDD(VDD), .to_gate(Y_I), .ASIG5V(Y), .VSS(VSS));
  io_secondary_5p0 x_esd_X (.VDD(VDD), .to_gate(X_I), .ASIG5V(X), .VSS(VSS));
  io_secondary_5p0 x_esd_S1N (.VDD(VDD), .to_gate(S1N_I), .ASIG5V(S1N), .VSS(VSS));
  io_secondary_5p0 x_esd_S1P (.VDD(VDD), .to_gate(S1P_I), .ASIG5V(S1P), .VSS(VSS));
  io_secondary_5p0 x_esd_S3P (.VDD(VDD), .to_gate(S3P_I), .ASIG5V(S3P), .VSS(VSS));
  io_secondary_5p0 x_esd_S3N (.VDD(VDD), .to_gate(S3N_I), .ASIG5V(S3N), .VSS(VSS));
  io_secondary_5p0 x_esd_S2N (.VDD(VDD), .to_gate(S2N_I), .ASIG5V(S2N), .VSS(VSS));
  io_secondary_5p0 x_esd_S2P (.VDD(VDD), .to_gate(S2P_I), .ASIG5V(S2P), .VSS(VSS));

  GRADIENT_NAV2 x_core (
      .VSS(VSS),
      .S4P(S4P_I),
      .S4N(S4N_I),
      .Z(Z_I),
      .ZN(ZN_OUT),
      .ZP(ZP_OUT),
      .Y(Y_I),
      .YN(YN_OUT),
      .YP(YP_OUT),
      .X(X_I),
      .XN(XN_OUT),
      .XP(XP_OUT),
      .S1N(S1N_I),
      .S1P(S1P_I),
      .S3P(S3P_I),
      .S3N(S3N_I),
      .S2N(S2N_I),
      .S2P(S2P_I),
      .VDD(VDD));

endmodule
