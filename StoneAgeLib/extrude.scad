// extrude.scad
//
// Part of the StoneAgeLib
//
// Version 1
// February 3, 2025
// By: Stone Age Sculptor
// License: CC0 (Public Domain)
//
// Version 2
// February 4, 2025
// By: Stone Age Sculptor
// License: CC0 (Public Domain)
// Changes:
//   Function pillow from Reddit user oldesole1 removed.
//   He is working on his function to improve it.
//
// Version 3
// March 2, 2025
// By: Stone Age Sculptor
// License: CC0 (Public Domain)
// Changes:
//   module outwards_bevel_extrude() added.
//   Name "linear_extrude_chamfer()" is
//   changed to "chamfer_extrude()".
//
// This version number is the overall version for everything in this file.
// Some modules and functions in this file may have their own version.

if(version()[0] < 2024)
{
  echo("Warning: The roof() function is not available.");
}


// ==============================================================
// outward_bevel_extrude
// ---------------------
// A module that extrudes a 2D shape and
// can add a outwards bevel.
//
// Parameters:
//   height       The total height
//   bevel        The common height of the top and bottom bevel
//   bevel_top    The height of the top bevel.
//                Overrides the common bevel.
//   bevel_bottom The height of the bottom bevel.
//                Overrides the common bevel.
//
// To do: 
//   * Set the angle
//   * Combine with linear_extrude_chamfer with negative chamfer
module outward_bevel_extrude(height=1,bevel,bevel_top,bevel_bottom)
{
  epsilon = 0.001;

  bothbev   = is_undef(bevel)        ? 0 : bevel;
  topbev    = is_undef(bevel_top)    ? bothbev : bevel_top;
  bottombev = is_undef(bevel_bottom) ? bothbev : bevel_bottom;
  
  // Extrude the whole shape for the total height.
  linear_extrude(height)
    children();

  if(bottombev > 0)
    translate([0,0,bottombev])
      mirror([0,0,1])
        make_bevel(bottombev)
          children();
  
  if(topbev > 0)
    translate([0,0,height-topbev])
      make_bevel(topbev)
        children();

  module make_bevel(bev)
  {
    // A negative shape is used.
    // The angle for roof() is 45 degrees,
    // therefor the original shape is made
    // larger with the amount of the height
    // of the bevel.
    // That is used for the negative shape.
    difference()
    {
      linear_extrude(bev,convexity=2)
        offset(delta=bev+epsilon)
          children();

      // Calculate the roof() over the
      // negative shape.
      // Lower it a little to be sure
      // that the difference removes
      // all of it.
      translate([0,0,-epsilon])
      roof(convexity=4)
        difference()
        {
          offset(delta=2*bev+epsilon)
            children();
          children();
        }
    }
  }
}


// ==============================================================
// Route the roof() to either a fake roof for old versions
// of OpenSCAD or call the new roof() function.
module roof_router(convexity)
{
  if(version()[0] < 2024)
    fake_roof(convexity=convexity)
      children();
  else
    roof(convexity=convexity)
      children();
}


// ==============================================================
//
// fake_roof
// ---------
// Version 1
// January 31, 2025
// By: Stone Age Sculptor
// License: CC0 (Public Domain)
//
// Warning: It does not work well yet.
//
// The roof function is imitated.
// A minkowski with a upside down cone 
// on the negative 2D shape is used
// for a fake roof().
module fake_roof(convexity)
{
  difference()
  {
    epsilon = 0.01;
    boxsize = 10000;

    difference()
    {
      translate([-boxsize/2,-boxsize/2,0])
        cube(boxsize);
      
      // Speed up minkowski with render().
      // It seems just as slow.
      render()
        minkowski(convexity=convexity)
        {
          render()
            translate([0,0,-epsilon])
              linear_extrude(2*epsilon)
                difference()
                {
                  square(boxsize+1,center=true);
                  children();
                }
          cylinder(h=boxsize+1,d1=0,d2=2*(boxsize+1),$fn=8);
        }
    }
  }
}


// ==============================================================
//
// chamfer_extrude
// ---------------
// Extrude a 2D shape with a chamfered top and bottom.
// There are no checks yet for wrong parameters.
//
// Parameters:
//   height          : the total height
//   chamfer         : the chamfer for top and bottom
//   chamfer_top     : the top chamfer, overrides 'chamfer'
//   chamfer_bottom  : the bottom chamfer, overrides 'chamfer'
//   angle           : angle for top and bottom chamfer 1...89
//   angle_top       : top angle, overrides 'angle'
//   angle_bottom    : bottom angle, overrides 'angle'
module chamfer_extrude(height=1,chamfer,chamfer_top,chamfer_bottom,angle,angle_top,angle_bottom)
{
  bothchamf   = is_undef(chamfer)        ? 0 : chamfer;
  topchamf    = is_undef(chamfer_top)    ? bothchamf : chamfer_top;
  bottomchamf = is_undef(chamfer_bottom) ? bothchamf : chamfer_bottom;

  bothang     = is_undef(angle)          ? 45 : angle;
  topang      = is_undef(angle_top)      ? bothang : angle_top;
  bottomang   = is_undef(angle_bottom)   ? bothang : angle_bottom;

  // The roof() has a 45 degree angle.
  // That makes it easy to set the angle,
  // because the tangens of 45 is 1.
  topscale    = tan(topang);
  bottomscale = tan(bottomang);

  intersection()
  {
    union()
    {
      // The bottom chamfer.
      // Since the roof() function is only upward,
      // a mirror() is used.
      // It is raised a tiny amount to be sure
      // that it connects to the middle part.
      if(bottomchamf > 0)
        color("#4DB58D")
          translate([0,0,bottomchamf+0.001])
            mirror([0,0,1])
              scale([1,1,bottomscale])
                roof_router(convexity=3)
                  children();

      // The middle part.
      color("#26E49C")
        translate([0,0,bottomchamf])
          linear_extrude(height-bottomchamf-topchamf)
            children();

      // The top chamfer.
      // It is lowered a tiny amount to be sure
      // that it connects to the middle part.
      if(topchamf > 0)
        color("#4CA986")
          translate([0,0,height-topchamf-0.001])
            scale([1,1,topscale])
              roof_router(convexity=3)
                children();
    }

    // To make it look better in the preview,
    // the box for the intersection is made bigger for
    // x and y and is made bigger for z when there is
    // no chamfer on that surface.
    zlower = bottomchamf == 0 ? 1 : 0;
    zupper = topchamf    == 0 ? height + zlower + 1 : height + zlower;
    color("#A4D3C1")
      translate([0,0,-zlower])
        linear_extrude(height=zupper,convexity=3)
          offset(2)        // 1.0001 or 2 or any value above 1.
            children();
  }  
}

// ==============================================================

