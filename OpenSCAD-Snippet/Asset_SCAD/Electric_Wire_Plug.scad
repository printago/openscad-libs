module Electric_Wire_Plug(){

    color("white")
    translate([0,-1,0])
    cylinder(1,1,1, center= true, $fn = 30);

    color("white")
    cube([2,2,1], center= true);

    color("gray")
    translate([0,1.8,0])
    rotate([90,0,0])
    cylinder(1.6,0.15,0.15, center= true, $fn = 30);

    color("gray")
    translate([0,2.6,0])
    sphere(0.15, $fn = 30);

    color("gray")
    translate([0.6,2,0])
    rotate([90,0,0])
    cylinder(1.2,0.15,0.15, center= true, $fn = 30);

    color("gray")
    translate([0.6,2.6,0])
    sphere(0.15, $fn = 30);

    color("black")
    translate([0.6,1.5,0])
    rotate([90,0,0])
    cylinder(1,0.18,0.18, center= true, $fn = 30);

    color("black")
    translate([-0.6,1.5,0])
    rotate([90,0,0])
    cylinder(1,0.18,0.18, center= true, $fn = 30);

    color("gray")
    translate([-0.6,2,0])
    rotate([90,0,0])
    cylinder(1.2,0.15,0.15, center= true, $fn = 30);

    color("gray")
    translate([-0.6,2.6,0])
    sphere(0.15, $fn = 30);

    color("white")
    translate([0,-2,0])
    rotate([90,0,0])
    cylinder(1,0.4,0.4, center= true, $fn = 30);

}

Electric_Wire_Plug();

// Written by Nicolì Angelo (Gengio) 2024: 
// MIT License

//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.