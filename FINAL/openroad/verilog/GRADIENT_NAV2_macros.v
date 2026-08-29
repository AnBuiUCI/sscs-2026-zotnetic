// --------------------------------------------------------------------------
//  GRADIENT_NAV2 — flat top: nothing but hard macros.
//
//  DO NOT EDIT: regenerate with
//      python3 scripts/spice_to_verilog.py
//
//  source: /foss/designs/a_zonetic2026/XSCHEM/simulation/GRADIENT_NAV2.sch/GRADIENT_NAV2.spice
//  built:  2026-08-29 18:13
//
//  This is what OpenROAD reads. Every instance below has a LEF MACRO,
//  so there is nothing left to elaborate and nothing to place but the
//  blocks themselves. The black-box module headers live in the per-macro
//  files that build_collateral.py writes; they are for yosys, not for
//  OpenROAD (see the README).
// --------------------------------------------------------------------------

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

    wire   x1_SX;
    wire   x1_net1;
    wire   x1_SY;
    wire   x1_net2;
    wire   x1_SZ;
    wire   x1_net3;
    wire   X1;
    wire   Y1;
    wire   Z1;
    wire   x2_SX;
    wire   x2_net1;
    wire   x2_SY;
    wire   x2_net2;
    wire   x2_SZ;
    wire   x2_net3;
    wire   X2;
    wire   Y2;
    wire   Z2;
    wire   x3_SX;
    wire   x3_net1;
    wire   x3_SY;
    wire   x3_net2;
    wire   x3_SZ;
    wire   x3_net3;
    wire   X3;
    wire   Y3;
    wire   Z3;
    wire   x4_SX;
    wire   x4_net1;
    wire   x4_SY;
    wire   x4_net2;
    wire   x4_SZ;
    wire   x4_net3;
    wire   X4;
    wire   Y4;
    wire   Z4;

    COMP x1_x4 (
        .VDD(VDD),
        .INN(x1_SX),
        .OUT(x1_net1),
        .INP(x1_SY),
        .VSS(VSS)
    );
    COMP x1_x5 (
        .VDD(VDD),
        .INN(x1_SX),
        .OUT(x1_net2),
        .INP(x1_SZ),
        .VSS(VSS)
    );
    COMP x1_x6 (
        .VDD(VDD),
        .INN(x1_SY),
        .OUT(x1_net3),
        .INP(x1_SZ),
        .VSS(VSS)
    );
    COMP x2_x4 (
        .VDD(VDD),
        .INN(x2_SX),
        .OUT(x2_net1),
        .INP(x2_SY),
        .VSS(VSS)
    );
    COMP x2_x5 (
        .VDD(VDD),
        .INN(x2_SX),
        .OUT(x2_net2),
        .INP(x2_SZ),
        .VSS(VSS)
    );
    COMP x2_x6 (
        .VDD(VDD),
        .INN(x2_SY),
        .OUT(x2_net3),
        .INP(x2_SZ),
        .VSS(VSS)
    );
    COMP x3_x4 (
        .VDD(VDD),
        .INN(x3_SX),
        .OUT(x3_net1),
        .INP(x3_SY),
        .VSS(VSS)
    );
    COMP x3_x5 (
        .VDD(VDD),
        .INN(x3_SX),
        .OUT(x3_net2),
        .INP(x3_SZ),
        .VSS(VSS)
    );
    COMP x3_x6 (
        .VDD(VDD),
        .INN(x3_SY),
        .OUT(x3_net3),
        .INP(x3_SZ),
        .VSS(VSS)
    );
    COMP x4_x4 (
        .VDD(VDD),
        .INN(x4_SX),
        .OUT(x4_net1),
        .INP(x4_SY),
        .VSS(VSS)
    );
    COMP x4_x5 (
        .VDD(VDD),
        .INN(x4_SX),
        .OUT(x4_net2),
        .INP(x4_SZ),
        .VSS(VSS)
    );
    COMP x4_x6 (
        .VDD(VDD),
        .INN(x4_SY),
        .OUT(x4_net3),
        .INP(x4_SZ),
        .VSS(VSS)
    );
    DECODER x1_x7 (
        .VDD(VDD),
        .XY(x1_net1),
        .XZ(x1_net2),
        .X(X1),
        .Y(Y1),
        .YZ(x1_net3),
        .Z(Z1),
        .VSS(VSS)
    );
    DECODER x2_x7 (
        .VDD(VDD),
        .XY(x2_net1),
        .XZ(x2_net2),
        .X(X2),
        .Y(Y2),
        .YZ(x2_net3),
        .Z(Z2),
        .VSS(VSS)
    );
    DECODER x3_x7 (
        .VDD(VDD),
        .XY(x3_net1),
        .XZ(x3_net2),
        .X(X3),
        .Y(Y3),
        .YZ(x3_net3),
        .Z(Z3),
        .VSS(VSS)
    );
    DECODER x4_x7 (
        .VDD(VDD),
        .XY(x4_net1),
        .XZ(x4_net2),
        .X(X4),
        .Y(Y4),
        .YZ(x4_net3),
        .Z(Z4),
        .VSS(VSS)
    );
    OPAM_LIN_flat x1_x1 (
        .VDD(VDD),
        .INN(S2N),
        .OUT(x1_SY),
        .INP(S2P),
        .VSS(VSS)
    );
    OPAM_LIN_flat x1_x2 (
        .VDD(VDD),
        .INN(S3N),
        .OUT(x1_SZ),
        .INP(S3P),
        .VSS(VSS)
    );
    OPAM_LIN_flat x1_x8 (
        .VDD(VDD),
        .INN(S1N),
        .OUT(x1_SX),
        .INP(S1P),
        .VSS(VSS)
    );
    OPAM_LIN_flat x2_x1 (
        .VDD(VDD),
        .INN(S1N),
        .OUT(x2_SY),
        .INP(S1P),
        .VSS(VSS)
    );
    OPAM_LIN_flat x2_x2 (
        .VDD(VDD),
        .INN(S2N),
        .OUT(x2_SZ),
        .INP(S2P),
        .VSS(VSS)
    );
    OPAM_LIN_flat x2_x8 (
        .VDD(VDD),
        .INN(S4N),
        .OUT(x2_SX),
        .INP(S4P),
        .VSS(VSS)
    );
    OPAM_LIN_flat x3_x1 (
        .VDD(VDD),
        .INN(S4N),
        .OUT(x3_SY),
        .INP(S4P),
        .VSS(VSS)
    );
    OPAM_LIN_flat x3_x2 (
        .VDD(VDD),
        .INN(S1N),
        .OUT(x3_SZ),
        .INP(S1P),
        .VSS(VSS)
    );
    OPAM_LIN_flat x3_x8 (
        .VDD(VDD),
        .INN(S3N),
        .OUT(x3_SX),
        .INP(S3P),
        .VSS(VSS)
    );
    OPAM_LIN_flat x4_x1 (
        .VDD(VDD),
        .INN(S3N),
        .OUT(x4_SY),
        .INP(S3P),
        .VSS(VSS)
    );
    OPAM_LIN_flat x4_x2 (
        .VDD(VDD),
        .INN(S4N),
        .OUT(x4_SZ),
        .INP(S4P),
        .VSS(VSS)
    );
    OPAM_LIN_flat x4_x8 (
        .VDD(VDD),
        .INN(S2N),
        .OUT(x4_SX),
        .INP(S2P),
        .VSS(VSS)
    );
    WEIGHT_COMP x5_weight_comp (
        .VDD(VDD),
        .VSS(VSS),
        .VA(X1),
        .VB(X2),
        .VC(X3),
        .VD(X4),
        .WE(X),
        .OUT(XN),
        .OUT_N(XP)
    );
    WEIGHT_COMP x6_weight_comp (
        .VDD(VDD),
        .VSS(VSS),
        .VA(Y1),
        .VB(Y2),
        .VC(Y3),
        .VD(Y4),
        .WE(Y),
        .OUT(YN),
        .OUT_N(YP)
    );
    WEIGHT_COMP x7_weight_comp (
        .VDD(VDD),
        .VSS(VSS),
        .VA(Z1),
        .VB(Z2),
        .VC(Z3),
        .VD(Z4),
        .WE(Z),
        .OUT(ZN),
        .OUT_N(ZP)
    );

endmodule
