// --------------------------------------------------------------------------
//  GRADIENT_NAV2 — structural Verilog, generated from the Xschem netlist.
//
//  DO NOT EDIT: regenerate with
//      python3 scripts/spice_to_verilog.py
//
//  source: /foss/designs/a_zonetic2026/XSCHEM/simulation/GRADIENT_NAV2.sch/GRADIENT_NAV2.spice
//  built:  2026-08-29 18:13
//
//  Black-box modules have ports and no body. OpenROAD binds them to the
//  LEF MACRO of the same name; giving it a body would make OpenROAD
//  elaborate an empty hierarchy and drop the instance.
// --------------------------------------------------------------------------

`default_nettype none
// COMP (black box)
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

// DECODER (black box)
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

// INV_1 (black box)
module INV_1 (
    VDD,
    IN,
    OUT,
    VSS
);
    inout  VDD;
    input  IN;
    output OUT;
    inout  VSS;

endmodule

// OPAM_LIN_flat (black box)
module OPAM_LIN_flat (
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

// WEIGHT (black box)
module WEIGHT (
    VDD,
    GND,
    OUT,
    VA,
    VC,
    VB,
    VD
);
    inout  VDD;
    inout  GND;
    inout  OUT;
    input  VA;
    input  VC;
    input  VB;
    input  VD;

endmodule

// COMP_OUT (structural)
module COMP_OUT (
    VDD,
    OUT,
    IN,
    OUT_N,
    VSS
);
    inout  VDD;
    output OUT;
    input  IN;
    output OUT_N;
    inout  VSS;

    wire   net1;

    INV_1 x1 (
        .VDD(VDD),
        .IN(IN),
        .OUT(net1),
        .VSS(VSS)
    );
    INV_1 x2 (
        .VDD(VDD),
        .IN(net1),
        .OUT(OUT),
        .VSS(VSS)
    );
    INV_1 x3 (
        .VDD(VDD),
        .IN(OUT),
        .OUT(OUT_N),
        .VSS(VSS)
    );

endmodule

// GRADIENT2 (structural)
module GRADIENT2 (
    SXN,
    SXP,
    VDD,
    X,
    SYN,
    Y,
    Z,
    SYP,
    VSS,
    SZN,
    SZP
);
    input  SXN;
    input  SXP;
    inout  VDD;
    inout  X;
    input  SYN;
    inout  Y;
    inout  Z;
    input  SYP;
    inout  VSS;
    input  SZN;
    input  SZP;

    wire   SX;
    wire   net1;
    wire   SY;
    wire   net2;
    wire   SZ;
    wire   net3;

    COMP x4 (
        .VDD(VDD),
        .INN(SX),
        .OUT(net1),
        .INP(SY),
        .VSS(VSS)
    );
    COMP x5 (
        .VDD(VDD),
        .INN(SX),
        .OUT(net2),
        .INP(SZ),
        .VSS(VSS)
    );
    COMP x6 (
        .VDD(VDD),
        .INN(SY),
        .OUT(net3),
        .INP(SZ),
        .VSS(VSS)
    );
    DECODER x7 (
        .VDD(VDD),
        .XY(net1),
        .XZ(net2),
        .X(X),
        .Y(Y),
        .YZ(net3),
        .Z(Z),
        .VSS(VSS)
    );
    OPAM_LIN_flat x8 (
        .VDD(VDD),
        .INN(SXN),
        .OUT(SX),
        .INP(SXP),
        .VSS(VSS)
    );
    OPAM_LIN_flat x1 (
        .VDD(VDD),
        .INN(SYN),
        .OUT(SY),
        .INP(SYP),
        .VSS(VSS)
    );
    OPAM_LIN_flat x2 (
        .VDD(VDD),
        .INN(SZN),
        .OUT(SZ),
        .INP(SZP),
        .VSS(VSS)
    );

endmodule

// GRADIENT_NAV2 (structural)
module GRADIENT_NAV2 (
    VDD,
    VSS,
    XP,
    X,
    XN,
    YP,
    Y,
    YN,
    ZP,
    Z,
    ZN,
    S2P,
    S2N,
    S4P,
    S4N,
    S3P,
    S3N,
    S1P,
    S1N
);
    inout  VDD;
    inout  VSS;
    output XP;
    output X;
    output XN;
    output YP;
    output Y;
    output YN;
    output ZP;
    output Z;
    output ZN;
    input  S2P;
    input  S2N;
    input  S4P;
    input  S4N;
    input  S3P;
    input  S3N;
    input  S1P;
    input  S1N;

    wire   X1;
    wire   X2;
    wire   X3;
    wire   X4;
    wire   Y1;
    wire   Y2;
    wire   Y3;
    wire   Y4;
    wire   Z1;
    wire   Z2;
    wire   Z3;
    wire   Z4;

    WEIGHT x5 (
        .VDD(VDD),
        .GND(VSS),
        .OUT(X),
        .VA(X1),
        .VC(X2),
        .VB(X3),
        .VD(X4)
    );
    WEIGHT x6 (
        .VDD(VDD),
        .GND(VSS),
        .OUT(Y),
        .VA(Y1),
        .VC(Y2),
        .VB(Y3),
        .VD(Y4)
    );
    WEIGHT x7 (
        .VDD(VDD),
        .GND(VSS),
        .OUT(Z),
        .VA(Z1),
        .VC(Z2),
        .VB(Z3),
        .VD(Z4)
    );
    COMP_OUT x8 (
        .VDD(VDD),
        .OUT(XN),
        .IN(X),
        .OUT_N(XP),
        .VSS(VSS)
    );
    COMP_OUT x9 (
        .VDD(VDD),
        .OUT(YN),
        .IN(Y),
        .OUT_N(YP),
        .VSS(VSS)
    );
    COMP_OUT x10 (
        .VDD(VDD),
        .OUT(ZN),
        .IN(Z),
        .OUT_N(ZP),
        .VSS(VSS)
    );
    GRADIENT2 x1 (
        .SXN(S1N),
        .SXP(S1P),
        .VDD(VDD),
        .X(X1),
        .SYN(S2N),
        .Y(Y1),
        .Z(Z1),
        .SYP(S2P),
        .VSS(VSS),
        .SZN(S3N),
        .SZP(S3P)
    );
    GRADIENT2 x2 (
        .SXN(S4N),
        .SXP(S4P),
        .VDD(VDD),
        .X(X2),
        .SYN(S1N),
        .Y(Y2),
        .Z(Z2),
        .SYP(S1P),
        .VSS(VSS),
        .SZN(S2N),
        .SZP(S2P)
    );
    GRADIENT2 x3 (
        .SXN(S3N),
        .SXP(S3P),
        .VDD(VDD),
        .X(X3),
        .SYN(S4N),
        .Y(Y3),
        .Z(Z3),
        .SYP(S4P),
        .VSS(VSS),
        .SZN(S1N),
        .SZP(S1P)
    );
    GRADIENT2 x4 (
        .SXN(S2N),
        .SXP(S2P),
        .VDD(VDD),
        .X(X4),
        .SYN(S3N),
        .Y(Y4),
        .Z(Z4),
        .SYP(S3P),
        .VSS(VSS),
        .SZN(S4N),
        .SZP(S4P)
    );

endmodule

`default_nettype wire
