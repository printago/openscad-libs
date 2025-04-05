module Hexagon_socket_screw_keys(){

    module regular_polygon(order = 6, r=1){
         angles=[ for (i = [0:order-1]) i*(360/order) ];
         coords=[ for (th=angles) [r*cos(th), r*sin(th)] ];
         polygon(coords);
     }
     
    color("#a8b0b2")
    rotate_extrude(angle = 90, $fn = 30)
    translate([5,0,0])
    regular_polygon(); 
     
    translate([0,5,0])

    color("#a8b0b2")
    rotate([30,0,0])
    rotate([00,-90,00])
    linear_extrude(height = 10) 

    //translate([5,0,0])
    regular_polygon(); 
     
    color("#a8b0b2")
    translate([5,0,0])
    rotate([90,-0,00])
    linear_extrude(height = 2) 

    //translate([5,0,0])
    regular_polygon(); 
      
  
}

Hexagon_socket_screw_keys();


// Written by Nicolì Angelo (Gengio) 2024: 
// MIT License

//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

