// -----------------------------------------------------------------------------
//  TEMPLATE - the connectivity is NOT filled in.
// -----------------------------------------------------------------------------
//  This file exists so OpenROAD has something to link against and so the macro
//  interfaces are visible in one place. The nets between the blocks are left
//  unconnected on purpose: the intended wiring lives in the schematics
//  (XSCHEM/COMBINATION/GRADIENT.sch and XSCHEM/GRADIENT_NAV.sch) and guessing it
//  here would produce a chip that routes cleanly and does the wrong thing.
//
//  To turn this into the real top level:
//    1. declare the top-level ports you actually want to expose,
//    2. declare the internal wires,
//    3. connect each macro instance below.
//
//  Note on directions: OUT (COMP) and WE / OUT / OUT_N (WEIGHT_COMP) come out as
//  `inout` because that is how they are declared in the schematics (iopin / :B).
//  If they are really outputs, change them to `opin` in xschem and regenerate -
//  synthesis and timing will both behave better.
// -----------------------------------------------------------------------------

module top (
    VDD,
    VSS
);
  inout VDD;
  inout VSS;

  // ---------------------------------------------------------------------------
  // Internal wires - declare them here, e.g.
  //   wire comp_out;
  //   wire weight_out, weight_out_n;
  // ---------------------------------------------------------------------------

  // Comparator - 104.28 x 31.46 um
  COMP u_comp (
      .VDD (VDD),
      .VSS (VSS),
      .INP (),   // <- connect
      .INN (),   // <- connect
      .OUT ()    // <- connect
  );

  // Weight comparator - 37.17 x 25.00 um
  WEIGHT_COMP u_weight_comp (
      .VDD   (VDD),
      .VSS   (VSS),
      .VA    (),   // <- connect
      .VB    (),   // <- connect
      .VC    (),   // <- connect
      .VD    (),   // <- connect
      .WE    (),   // <- connect
      .OUT   (),   // <- connect
      .OUT_N ()    // <- connect
  );

endmodule
