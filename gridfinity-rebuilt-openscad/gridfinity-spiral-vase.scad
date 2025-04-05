// ===== INFORMATION ===== //
/*
 IMPORTANT: rendering will be better in development builds and not the official release of OpenSCAD, but it makes rendering only take a couple seconds, even for comically large bins.


https://github.com/kennetek/gridfinity-rebuilt-openscad

*/

include <src/core/standard.scad>
use <src/core/gridfinity-rebuilt-utility.scad>
use <src/helpers/generic-helpers.scad>

// ===== PARAMETERS ===== //

/* [Special Variables] */
$fa = 8;
$fs = 0.25;

/* [Bin or Base] */
type = 1; // [0:bin, 1:base]

/* [Printer Settings] */
// extrusion width (walls will be twice this size)
nozzle = 0.6;
// slicer layer size
layer = 0.35;
// number of base layers on build plate
bottom_layer = 3;

/* [General Settings] */
// number of bases along x-axis
gridx = 1;
// number of bases along y-axis
gridy = 1;
// bin height. See bin height information and "gridz_define" below.
gridz = 6;
// number of compartments along x-axis
n_divx = 2;

/* [Toggles] */
// toggle holes on the base for magnet
enable_holes = true;
// round up the bin height to match the closest 7mm unit
enable_zsnap = false;
// toggle the lip on the top of the bin that allows stacking
enable_lip = true;
// chamfer inside bin for easy part removal
enable_scoop_chamfer = true;
// funnel-like features on the back of tabs for fingers to grab
enable_funnel = true;
// front inset (added for strength when there is a scoop)
enable_inset = true;
// "pinches" the top lip of the bin, for added strength
enable_pinch = true;

/* [Styles] */
// determine what the variable "gridz" applies to based on your use case
gridz_define = 0; // [0:gridz is the height of bins in units of 7mm increments - Zack's method,1:gridz is the internal height in millimeters, 2:gridz is the overall external height of the bin in millimeters]
// how tabs are implemented
style_tab = 0; // [0:continuous, 1:broken, 2:auto, 3:right, 4:center, 5:left, 6:none]
// where to put X cutouts for attaching bases
// selecting none will also disable crosses on bases
style_base = 0; // [0:all, 1:corners, 2:edges, 3:auto, 4:none]

// tab angle
a_tab = 40;

// ===== IMPLEMENTATION ===== //

color("tomato")
if (type != 0) gridfinityBaseVase(2*nozzle, d_bottom); // Generate a single base
else gridfinityVase(); // Generate the bin


// ===== CONSTRUCTION ===== //

//Deprecated Variables
d_hole = 26;  // center-to-center distance between holes
//End Deprecated Variables

d_bottom = layer*(max(bottom_layer,1));
x_l = l_grid/2;

dht = (gridz_define==0)?gridz*7 : (gridz_define==1)?h_bot+gridz+BASE_HEIGHT : gridz-(enable_lip?3.8:0);
d_height = (enable_zsnap?((abs(dht)%7==0)?dht:dht+7-abs(dht)%7):dht)-BASE_HEIGHT;

d_fo1 = 2*+BASE_TOP_RADIUS;

f2c = sqrt(2)*(sqrt(2)-1); // fillet to chamfer ratio
me = ((gridx*l_grid-0.5)/n_divx)-nozzle*4-d_fo1-12.7-4;
m = min(d_tabw/1.8 + max(0,me), d_tabw/1.25);
d_ramp = f2c*(l_grid*((d_height-2)/7+1)/12-r_f2)+d_wall2;
d_edge = ((gridx*l_grid-0.5)/n_divx-d_tabw-d_fo1)/2;
n_st = gridz <= 3 ? 6 : d_edge < 2 && style_tab != 0 && style_tab != 6 ? 1 : style_tab == 1 && n_divx <= 1? 0 : style_tab;

n_x = (n_st==0?1:n_divx);
spacing = (gridx*l_grid-0.5)/(n_divx);
shift = n_st==3?-1:n_st==5?1:0;
shiftauto = function (a,b) n_st!=2?0:a==1?-1:a==b?1:0;

xAll = function (a,b) true;
xCorner = function(a,b) (a==1||a==gridx)&&(b==1||b==gridy);
xEdge = function(a,b) (a==1)||(a==gridx)||(b==1)||(b==gridy);
xAuto = function(a,b) xCorner(a,b) || (a%2==1 && b%2 == 1);
xNone = function(a,b) false;
xFunc = [xAll, xCorner, xEdge, xAuto, xNone];


module gridfinityVase() {
    $dh = d_height;
    difference() {
        union() {
            difference() {
                block_vase_base();

                if (n_st != 6)
                transform_style()
                transform_vtab_base((n_st<2?gridx*l_grid/n_x-0.5-d_fo1:d_tabw)-nozzle*4)
                block_tab_base(-nozzle*sqrt(2));
            }

            if (enable_scoop_chamfer)
            intersection() {
                block_vase();
                translate([0,gridy*l_grid/2-0.25-d_wall2/2,d_height/2+0.1])
                cube([gridx*l_grid,d_wall2,d_height-0.2],center=true);
            }

            if (enable_funnel && gridz > 3)
            pattern_linear((n_st==0?n_divx>1?n_divx:gridx:1), 1, (gridx*l_grid-d_fo1)/(n_st==0?n_divx>1?n_divx:gridx:1))
            transform_funnel()
            block_funnel_outside();

            if (n_divx > 1)
            pattern_linear(n_divx-1,1,(gridx*l_grid-0.5)/(n_divx))
            block_divider();

            if (n_divx < 1)
            pattern_linear(n_st == 0 ? n_divx>1 ? n_divx-1 : gridx-1 : 1, 1, (gridx*l_grid-d_fo1)/((n_divx>1 ? n_divx : gridx)))
            block_tabsupport();
        }

        if (enable_funnel && gridz > 3)
        pattern_linear((n_st==0?n_divx>1?n_divx:gridx:1), 1, (gridx*l_grid-d_fo1)/(n_st==0?n_divx>1?n_divx:gridx:1))
        transform_funnel()
        block_funnel_inside();

        if (!enable_lip)
        translate([0,0,1.5*d_height])
        cube([gridx*l_grid,gridy*l_grid,d_height], center=true);

        block_x();
        block_inset();
        if (enable_pinch)
        block_pinch(d_height);

        if (bottom_layer <= 0)
        translate([0,0,-50+layer+0.01])
        cube([gridx*l_grid*10,gridy*l_grid*10,100], center=true);
    }
}

module gridfinityBaseVase(wall_thickness, bottom_thickness) {
    difference() {
        union() {
            base_outer_shell(wall_thickness, bottom_thickness);
            intersection() {
                pattern_circular(4){
                    rotate([0,0,45])
                    translate([-wall_thickness/2, 3, 0])
                    cube([wall_thickness, l_grid, BASE_PROFILE_MAX.y]);

                    if (enable_holes) {
                        block_magnet_blank(wall_thickness);
                    }
                }
                base_solid();
            }
            if (style_base != 4) {
                translate([0, 0, BASE_PROFILE_MAX.y])
                linear_extrude(bottom_thickness)
                profile_x(0.1);
            }
        }
        if (enable_holes) {
            pattern_circular(4)
            block_magnet_blank(0, false);
        }

        // magic slice
        // Tricks slicer into not ignoring the center.
        rotate([0, 0, 90])
        translate([0, 0, bottom_thickness])
        cube([0.005, 2*l_grid, 2*BASE_HEIGHT]);
    }
}

module block_magnet_blank(o = 0, half = true) {
    magnet_radius = MAGNET_HOLE_RADIUS + o;

    translate([d_hole/2, d_hole/2, 0.1])
    difference() {
        hull() {
            cylinder(r = magnet_radius, h = MAGNET_HOLE_DEPTH*2, center = true);
            cylinder(r = magnet_radius-(BASE_HEIGHT+0.1-MAGNET_HOLE_DEPTH), h = (BASE_HEIGHT+0.1)*2, center = true);
        }
        if (half)
        mirror([0,0,1])
        cylinder(r=magnet_radius*2, h = (BASE_HEIGHT+0.1)*4);
    }
}

module block_pinch(height_mm) {
    assert(is_num(height_mm));

    translate([0, 0, -BASE_HEIGHT])
    block_wall(gridx, gridy, l_grid) {
        translate([d_wall2-nozzle*2-d_clear*2,0,0])
        profile_wall(height_mm);
    }
}

module block_tabsupport() {
    intersection() {
        translate([0,0,0.1])
        block_vase(d_height*4);

        cube([nozzle*2, gridy*l_grid, d_height*3], center=true);

        transform_vtab_base(gridx*l_grid*2)
        block_tab_base(-nozzle*sqrt(2));
    }
}

module block_divider() {
    difference() {
        intersection() {
            translate([0,0,0.1])
            block_vase();
            cube([nozzle*2, gridy*l_grid, d_height*2], center=true);
        }

        if (n_st == 0) block_tab(0.1);
        else block_divider_edgecut();

        // cut divider clearance on negative Y side
        translate([-gridx*l_grid/2,-(gridy*l_grid/2-0.25),0])
        cube([gridx*l_grid,nozzle*2+0.1,d_height*2]);

        // cut divider clearance on positive Y side
        mirror([0,1,0])
        if (enable_scoop_chamfer)
            translate([-gridx*l_grid/2,-(gridy*l_grid/2-0.25),0])
            cube([gridx*l_grid,d_wall2+0.1,d_height*2]);
        else block_divider_edgecut();

        // cut divider to have clearance with scoop
        if (enable_scoop_chamfer)
        transform_scoop()
        offset(delta = 0.1)
        polygon([
            [0,0],
            [d_ramp,d_ramp],
            [d_ramp,d_ramp+nozzle/sqrt(2)],
            [-nozzle/sqrt(2),0]
        ]);
    }

    // divider slices
    difference() {
        for (i = [0:(d_height-d_bottom)/(layer)]) {

        if (2*i*layer < d_height-layer/2-d_bottom-0.1)
        mirror([0,1,0])
        translate([0,(gridy*l_grid/2-0.25-nozzle)/2,layer/2+d_bottom+2*i*layer])
        cube([nozzle*2-0.01,gridy*l_grid/2-0.25-nozzle,layer],center=true);

        if ((2*i+1)*layer < d_height-layer/2-d_bottom-0.1)
        translate([0,(gridy*l_grid/2-0.25-nozzle)/2,layer/2+d_bottom+(2*i+1)*layer])
        cube([nozzle*2-0.01,gridy*l_grid/2-0.25-nozzle,layer],center=true);

        }

        // divider slices cut to tabs
        if (n_st == 0)
        transform_style()
        transform_vtab_base((n_st<2?gridx*l_grid/n_x-0.5-d_fo1:d_tabw)-nozzle*4)
        block_tab_base(-nozzle*sqrt(2));
    }
}

module block_divider_edgecut() {
    translate([-50,-gridy*l_grid/2+0.25,0])
    rotate([90,0,90])
    linear_extrude(100)
    offset(delta = 0.1)
    mirror([1,0,0])
    translate([-r_base,0,0])
    profile_wall($dh);
}

module transform_funnel() {
    if (me > 6 && enable_funnel && gridz > 3 && n_st != 6)
    transform_style()
    render()
    children();
}

module block_funnel_inside() {
    intersection() {
        block_tabscoop(m-nozzle*3*sqrt(2), 0.003, nozzle*2, 0.01);
        block_tab(0.1);
    }
}

module block_funnel_outside() {
    intersection() {
        difference() {
            block_tabscoop(m, 0, 0, 0);
            block_tabscoop(m-nozzle*4*sqrt(2), 0.003, nozzle*2, -1);
        }
        block_tab(-nozzle*sqrt(2)/2);
    }
}

module block_vase_base() {
    difference() {
        // base
        translate([0,0,-BASE_HEIGHT]) {
            translate([0,0,-0.1])
            color("firebrick")
            block_bottom(d_bottom, gridx, gridy, l_grid);
            color("royalblue")
            block_wall(gridx, gridy, l_grid) {
                if (enable_lip) profile_wall($dh);
                else profile_wall2($dh);
            }
        }

        // magic slice
        rotate([0,0,90])
        mirror([0,1,0])
        translate([0,0,d_bottom+0.001])
        cube([0.001,l_grid*gridx,d_height+d_bottom*2]);
    }

    // scoop piece
    if (enable_scoop_chamfer)
    transform_scoop()
    polygon([
        [0,0],
        [d_ramp,d_ramp],
        [d_ramp,d_ramp+0.6/sqrt(2)],
        [-0.6/sqrt(2),0]
    ]);

    // outside tab cutter
    if (n_st != 6)
    translate([-(n_x-1)*spacing/2,0,0])
    for (i = [1:n_x])
    translate([(i-1)*spacing,0,0])
    translate([shiftauto(i,n_x)*d_edge + shift*d_edge,0,0])
    intersection() {
        block_vase();
        transform_vtab_base(n_st<2?gridx*l_grid/n_x-0.5-d_fo1:d_tabw)
        profile_tab();
    }
}

module block_inset() {
    ixx = (gridx*l_grid-0.5)/2;
    iyy = d_height/2.1;
    izz = sqrt(ixx^2+iyy^2)*tan(40);
    if (enable_scoop_chamfer && enable_inset)
    difference() {
        intersection() {
            rotate([0,90,0])
            translate([-iyy,0,0])
            block_inset_sub(iyy, gridx*l_grid, 45);

            rotate([0,90,0])
            translate([-iyy,0,0])
            rotate([0,90,0])
            block_inset_sub(ixx, d_height*2, 45);
        }

        mirror([0,1,0])
        translate([-gridx*l_grid/2,-(gridy*l_grid-0.5)/2+d_wall2-2*nozzle,0])
        cube([gridx*l_grid,izz,d_height*2]);
    }
}

module block_inset_sub(x, y, ang) {
    translate([0,(gridy*l_grid-0.5)/2+r_fo1,0])
    mirror([0,1,0])
    linear_extrude(y,center=true)
    polygon([[-x,0],[x,0],[0,x*tan(ang)]]);
}

module transform_style() {
    translate([-(n_x-1)*spacing/2,0,0])
    for (i = [1:n_x])
    translate([(i-1)*spacing,0,0])
    translate([shiftauto(i,n_x)*d_edge + shift*d_edge,0,0])
    children();
}

module block_flushscoop() {
    translate([0,gridy*l_grid/2-d_wall2-nozzle/2-1,d_height/2])
    linear_extrude(d_height)
    union() {
        copy_mirror([1,0,0])
        polygon([[0,0],[gridx*l_grid/2-r_fo1,0],[gridx*l_grid/2-r_fo1,1],[gridx*l_grid/2-r_fo1-r_c1*5,d_wall2-nozzle*2+1],[0,d_wall2-nozzle*2+1]]);
    }

    transform_scoop()
    polygon([[0,0],[d_ramp,0],[d_ramp,d_ramp]]);
}

module profile_tab() {
    union() {
        copy_mirror([0,1,0])
        polygon([[0,0],[d_tabh*cos(a_tab),0],[d_tabh*cos(a_tab),d_tabh*sin(a_tab)]]);
    }
}

module profile_tabscoop(m) {
    polyhedron([[m/2,0,0],[0,-m,0],[-m/2,0,0],[0,0,m]], [[0,2,1],[1,2,3],[0,1,3],[0,3,2]]);
}

module block_tabscoop(a=m, b=0, c=0, d=-1) {
    translate([0,d_tabh*cos(a_tab)-l_grid*gridy/2+0.25+b,0])
    difference() {
        translate([0,0,-d_tabh*sin(a_tab)*2+d_height+2.1])
        profile_tabscoop(a);

        translate([-gridx*l_grid/2,-m,-m])
        cube([gridx*l_grid,m-d_tabh*cos(a_tab)+0.005+c,d_height*20]);

        if (d >= 0)
        translate([0,0,-d_tabh*sin(a_tab)+d_height+m/2+d+2.1])
        cube([gridx*l_grid,gridy*l_grid,m],center=true);
    }
}

module transform_vtab(a=0,b=1) {
    transform_vtab_base(gridx*l_grid/b-0.5-d_fo1+a)
    children();
}

module transform_vtab_base(a) {
    translate([0,d_tabh*cos(a_tab)-l_grid*gridy/2+0.25,-d_tabh*sin(a_tab)+d_height+2.1])
    rotate([90,0,270])
    linear_extrude(a, center=true)
    children();
}

module block_tab(del, b=1) {
    transform_vtab(-nozzle*4, b)
    block_tab_base(del);
}

module block_tab_base(del) {
    offset(delta = del)
    union() {
        profile_tab();
        translate([d_tabh*cos(a_tab),-d_tabh*sin(a_tab),0])
        square([l_grid,d_tabh*sin(a_tab)*2]);
    }
}

module transform_scoop() {
    intersection() {
        block_vase();
        translate([0,gridy*l_grid/2-d_ramp,layer*max(bottom_layer*1)])
        rotate([90,0,90])
        linear_extrude(2*l_grid*gridx,center=true)
        children();
    }
}

module block_vase(h = d_height*2) {
    translate([0,0,-0.1])
    rounded_square([gridx*l_grid-0.5-nozzle, gridy*l_grid-0.5-nozzle, h], r_base+0.01-nozzle/2, center=true);
}

module profile_x(x_f = 3) {
    difference() {
        square([x_l,x_l],center=true);

        pattern_circular(4)
        translate([0,nozzle*sqrt(2),0])
        rotate([0,0,45])
        translate([x_f,x_f,0])
        minkowski() {
            square([x_l,x_l]);
            circle(x_f);
        }
    }
}

module block_x() {
    translate([-(gridx-1)*l_grid/2,-(gridy-1)*l_grid/2,0])
    for (i = [1:gridx])
    for (j = [1:gridy])
    if (xFunc[style_base](i,j))
    translate([(i-1)*l_grid,(j-1)*l_grid,0])
    block_x_sub();
}

module block_x_sub() {
    linear_extrude(d_bottom*2+0.01,center=true)
    offset(0.05)
    profile_x();
}
