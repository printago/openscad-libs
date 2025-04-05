use <text_tools.scad>   

////////     ////////////     ////////////
////////    BASE FUNCTIONS    ////////////
////////     ////////////     ////////////
    
module create_cutter_outline(lipHeight = 3,
     supportHeight = 10,
     bladeHeight = 20,
     baseHeight = 3,
     baseWidth = 3,
     lipWidth = -1.2,
     supportWidth = 1.6,
     bladeWidth = 0.8) {

     linear_extrude(height = lipHeight) {
          difference() {
               union() {
                    for (i = [0 : $children - 1]) {
                         children(i);
                    }
               }
               offset(delta = lipWidth, chamfer = true) {
                    union() {
                         for (i = [0 : $children - 1]) {
                              children(i);
                         }
                    }
               }
          }
     }

     linear_extrude(height = baseHeight) {
          difference() {
               offset(delta = baseWidth) union() {
                    for (i = [0 : $children - 1]) {
                         children(i);
                    }
               }
               union() {
                    for (i = [0 : $children - 1]) {
                         children(i);
                    }
               }
          }
     }

     linear_extrude(height = supportHeight) {
          difference() {
               offset(delta = supportWidth) union() {
                    for (i = [0 : $children - 1]) {
                         children(i);
                    }
               }
               union() {
                    for (i = [0 : $children - 1]) {
                         children(i);
                    }
               }
          }
     }

     linear_extrude(height = bladeHeight) {
          difference() {
               offset(delta = bladeWidth) union() {
                    for (i = [0 : $children - 1]) {
                         children(i);
                    }
               }
               union() {
                    for (i = [0 : $children - 1]) {
                         children(i);
                    }
               }
          }
     }
} 

module create_simple_inner_detail(innerOffset = 0.25,
                                  baseHeight = 2.5, 
                                  baseWidth = 2.5, 
                                  barWidth=2, 
                                  barOffsetX=0, 
                                  barOffsetY=0, 
                                  barSpacingX = 25, 
                                  barSpacingY = 25, 
                                  bars="both", 
                                  childrenHeight = 8, 
                                  childrenBuffer=8) {
    assert(bars=="both" || bars == "h" || bars=="v", "Valid 'bars' values are 'both', 'h', or 'v'");
    
    //extrude the whole inner base
    color("red")
    linear_extrude(height = baseHeight) {
        //draws the outline of the DXF and hollows it out.
        difference() {
            
            offset(delta = -innerOffset, chamfer = false) 
            children(0);
                       
            offset(delta = -baseWidth - innerOffset, chamfer = true) children(0);
            
        }
        
        //adds the Lateral Support Grid
        intersection() {
            difference() {
                union() {
                  if(bars != "v") {
                      for (i = [-750 : barSpacingY : 750]) {
                      translate([barOffsetX, barOffsetY, 0])
                        translate([-750,i,0]) square([1500,barWidth]);
                      }
                  }
                  if (bars != "h") {
                      for (i = [-750 : barSpacingX : 750]) {
                        translate([barOffsetX, barOffsetY, 0])
                        translate([i,-750,0]) square([barWidth,1500]);
                      }
                  }
                  if ($children > 1) {
                    for (i = [1 : $children - 1]) { // Start from the second child
                        offset(delta=childrenBuffer) children(i, $fn=360);                
                    }
                  }
                }
                if ($children > 1) {
                    for (i = [1 : $children - 1]) { // Start from the second child
                        children(i, $fn=360);                
                    }
                }
            }
            offset(delta = -innerOffset, chamfer = false) 
                children(0);      
        }
    }
   
    if ($children > 1) {     
        for (i = [1 : $children - 1]) { // Start from the second child
            color(rands(0, 1, 3))
            linear_extrude(height = childrenHeight) {
                children(i, $fn=360);
            }
        }
    }

    
}

////////     ////////////     ////////////
////////    USER FUNCTIONS    ////////////
////////     ////////////     ////////////

module three_line_cutter(text_line_1 = "YourTextHere",
                         text_line_2 = "", 
                         text_line_3 = "", 
                         size_in_inches = 3.5, 
                         output = "detail", 
                         font_name = "", 
                         draw_text_bounds = false, 
                         scale_equal = true, 
                         text_bounding_boxes=[],
                         barWidth=8, 
                         barOffsetX=-55, 
                         barOffsetY=-6, 
                         barSpacingX = 100, 
                         barSpacingY = 25, 
                         bars="both",
                         text_direction = "ltr",
                         detail_height = 8, 
                         detail_buffer = 2) {
    $fn = 360;
    model_scale = size_in_inches * 0.254;
    cookie_cutter_lip_height = 3;
    
    fontName = get_font_name(font_name);
    font_name = fontName;
    
    //cookie render vars //
        cookie_thickness = 6.35; // Thickness of the cookie in mm (0.25")
        cookie_indent_distance = 3;
    //////////////////////
    
   
    num_lines = text_line_3 != "" && text_line_2 != "" && text_line_1 != "" ? 3 :
            text_line_2 != "" && text_line_1 != "" ? 2 : 1;
                    
    textbox_array = (len(text_bounding_boxes) > 0) ? text_bounding_boxes : get_bounding_boxes("" , num_lines);
                    
    drawBounds = draw_text_bounds == true ? 1 : 0;
    scale_mode = "equal";
    sf1 =  get_scale_factor(text_string=text_line_1, bounding_box=textbox_array[0], font=font_name);
    sf2 = (text_line_2 != "") ? get_scale_factor(text_string=text_line_2, bounding_box=textbox_array[1], font=font_name) : 10000 ;
    sf3 = (text_line_3 != "") ? get_scale_factor(text_string=text_line_3, bounding_box=textbox_array[2], font=font_name) : 10000 ;
    min_factor = min(sf1,sf2,sf3); 

    move_z = (output == "all") ? cookie_cutter_lip_height  : 0;
    cookie_detail_rotate = (output == "cookie") ? 180 : 0;
    cookie_detail_translate = (output == "cookie") ? -8-cookie_thickness+cookie_indent_distance: 0;
    difference() {
        if (output=="cookie") {
            linear_extrude(cookie_thickness) 
                scale([model_scale,model_scale,1])
                children(0);
        }
        mirror([1,0,0]) {
            if (output != "outline") {
                // for "all"
                translate([0,0,move_z])
                
                //for "cookie"
                rotate([0,cookie_detail_rotate,0])
                translate([0,0,cookie_detail_translate])
                
                
                scale([model_scale,model_scale,1]) {
                    create_simple_inner_detail(bars = bars, barWidth = barWidth, barOffsetX = barOffsetX, barOffsetY = barOffsetY, 
                                               barSpacingX = barSpacingX, barSpacingY=barSpacingY, childrenBuffer=detail_buffer, childrenHeight = detail_height) {
                        children(0);
                        if (text_line_1 != "" && textbox_array[0] != undef && scale_equal == true) {
                            draw_text_known_scale(text_string=text_line_1, bounding_box=textbox_array[0], font=font_name, draw_bound=drawBounds, scale_factor = min_factor, valign = "center", direction = text_direction);
                        } else if (text_line_1 != "" && textbox_array[0] != undef && scale_equal == false) {
                            draw_fit_text(text_string=text_line_1, bounding_box=textbox_array[0], font=font_name, draw_bound=drawBounds, valign = "center", direction = text_direction);
                        }
                        
                        if (text_line_2 != "" && textbox_array[1] != undef && scale_equal == true) {
                            draw_text_known_scale(text_string=text_line_2, bounding_box=textbox_array[1], font=font_name, draw_bound=drawBounds,scale_factor = min_factor, direction =text_direction);
                        } else if (text_line_2 != "" && textbox_array[1] != undef && scale_equal == false) {
                            draw_fit_text(text_string=text_line_2, bounding_box=textbox_array[1], font=font_name, draw_bound=drawBounds, valign = "center", direction = text_direction);
                        }
                        
                        if (text_line_3 != "" && textbox_array[2] != undef && scale_equal == true) {
                            draw_text_known_scale(text_string=text_line_3, bounding_box=textbox_array[2], font=font_name, draw_bound=drawBounds, scale_factor = min_factor, direction =text_direction);
                        } else if (text_line_3 != "" && textbox_array[2] != undef && scale_equal == false) {
                            draw_fit_text(text_string=text_line_3, bounding_box=textbox_array[2], font=font_name, draw_bound=drawBounds, valign = "center", direction=text_direction);
                        }
                        
                        if ($children > 1) {     
                            for (i = [1 : $children - 1]) { // Start from the second child
                                children(i);
                            }
                        }  
                    }}
                    
                
            } // detail end

            //outline
            if (output != "detail" && output != "cookie") {        
                create_cutter_outline(lipHeight = cookie_cutter_lip_height) {    
                    scale([model_scale,model_scale,1]) 
                    children(0);
                }
            }
        }
    
    } // cookie difference
}


//Helper to Draws Union of 2D-Shapes
module draw_outline_shape(model_scale = 1) {
    if ($children > 0) 
        for (i = [0 : $children - 1])
                children(i);

}

////////     ////////////     ////////////
//////// 2D DRAWING FUNCTIONS ////////////
////////     ////////////     ////////////

module draw_scalloped_circle(diameter, scallop_count) {
    scallop_radius = (diameter / 2) * sin(180 / scallop_count);
    translate_distance = (diameter / 2) - scallop_radius;
    for (i = [0:scallop_count - 1]) {
        rotate(i * 360/scallop_count) {
            translate([translate_distance, 0, 0]) {
                hull() {
                    _scallop(scallop_radius);
                    rotate(180) _scallop(scallop_radius);
                }
            }
        }
    }
    // A circle that fits within the inner boundary of the scallops
    circle((diameter / 2) - scallop_radius, $fn=360);
}

module draw_heart(radius, center = true) {
    offsetX = center ? 0 : radius + radius * cos(45);
    offsetY = center ? 1.5 * radius * sin(45) - 0.5 * radius : 3 * radius * sin(45);

    translate([offsetX, offsetY, 0]) union() {
        _heart_sub_component(radius);
        mirror([1, 0, 0]) _heart_sub_component(radius);
    }
}

module draw_scalloped_heart(radius, scallop_count, center = true) {
    offsetX = center ? 0 : radius + radius * cos(45);
    offsetY = center ? 0.5 * radius * sin(45) - 0.5 * radius : 3 * radius * sin(45);

    translate([offsetX, offsetY, 0]) {
        _scalloped_heart_half(radius, scallop_count);
        mirror([1, 0, 0]) _scalloped_heart_half(radius, scallop_count);
    }
}

module draw_scalloped_square(diameter, scallop_count) {
    //side_length = diameter;
    total_scallops = scallop_count; // Total scallops around the square
    scallops_per_side = ceil(total_scallops / 3); // Scallops per side
    scallop_radius = (diameter / 2) * sin(180 / scallop_count); // Ensure consistent scallop size
    
    side_length = diameter - scallop_radius;
    for (side = [0:3]) {
        for (i = [0:scallops_per_side - 1]) {
            if (side == 0) { // Bottom side
                translate([-side_length / 2 + i * (side_length / scallops_per_side), -side_length / 2])
                    _scallop(scallop_radius);
            } else if (side == 1) { // Right side
                translate([side_length / 2, -side_length / 2 + i * (side_length / scallops_per_side)])
                    _scallop(scallop_radius);
            } else if (side == 2) { // Top side
                translate([side_length / 2 - i * (side_length / scallops_per_side), side_length / 2])
                    _scallop(scallop_radius);
            } else if (side == 3) { // Left side
                translate([-side_length / 2, (side_length / 2 - i  * (side_length / scallops_per_side))])
                    _scallop(scallop_radius);
            }
        }
    }
    translate([-diameter/2, -diameter/2,0])
    difference() {
        square(diameter);// - ((diameter / 2) * sin(180 / scallop_count)));    
    }   
}

module draw_field(spaceX = 5, spaceY = 5) {
     for (x = [-100 :spaceX:100]) {
        for(y = [-100:spaceY:100]) {
            offset_x = (floor(y / spaceY) % 2) ? x + spaceX / 2 : x;
            translate([offset_x,y,0])
            children(0);
        }
     }
}

module sector(radius, angles, fn = 360) {
    r = radius / cos(180 / fn);
    step = -360 / fn;

    points = concat([[0, 0]],
        [for(a = [angles[0] : step : angles[1] - 360]) 
            [r * cos(a), r * sin(a)]
        ],
        [[r * cos(angles[1]), r * sin(angles[1])]]
    );

    difference() {
        circle(radius, $fn = fn);
        polygon(points);      
    }
}

module arc(radius, angles, width = 1, fn = 24) {
    difference() {
        sector(radius + width, angles, fn);
        sector(radius, angles, fn);
    }
}

module _heart_sub_component(radius) {
    rotated_angle = 45;
    diameter = radius * 2;
    
    translate([-radius * cos(rotated_angle), 0, 0]) 
        rotate(-rotated_angle) union() {
            circle(radius);
            translate([0, -radius, 0]) 
                square(diameter);
        }
}

module _scalloped_heart_half(radius, scallop_count) {
    rotated_angle = 45;
    diameter = radius * 2;
    
    difference() {
        union() {
            translate([-radius * cos(rotated_angle),radius * cos(rotated_angle) , 0]) 
                draw_scalloped_circle(radius * 2, scallop_count);
            difference() {
                
                translate([0,0,0])
                    rotate(-rotated_angle)    
                        draw_scalloped_square(diameter, scallop_count);
                translate([-radius/2, radius/2, 0])
                    square(radius*10);
                }
        }
        translate([0,-radius*2.5,0])
            square(radius*5, center= false);
    }
}

module _scallop(radius) {
    intersection() {
        circle(radius, $fn=360);
        square([2*radius, 2*radius], center=true);
    }
}

////////        ////////////       ////////////
//////// SHARED FOR BOUNDING BOXES ////////////
////////        ////////////       ////////////

bounding_boxes = [
    ["PER9999", [ // 3 lines of text defined
        [ [[-25,-25], [25,5]] ],  // 1 line of text
        [ [[-25,-25], [25,5]], [[-25,-25], [25,5]] ],  // 2 lines of text
        [ [[-25,-25], [25,5]], [[-25,-25], [25,5]], [[-25,-25], [25,5]] ]  
    ]],
    ["PER9998", [ // 2 lines of text defined
        [ [[0, 0], [12, 12]] ],  
        [ [[0, 0], [12, 6]], [[0, 6], [12, 12]] ]  
    ]],
    ["PER004", [ 
        [ [[-25,-25],[25,5]] ],
        [ [[-25,-15], [25,5]], [[-20,-33], [20,-15]] ]
    ]],
    ["PER045", [
        [ [[-25,-25], [25,5]] ],
        [ [[-25,-5], [25,25]], [[-25,-25], [25,-5]] ],
        [ [[-23, 10], [23,35]], [[-25,-15], [25, 10]], [[-23,-35], [23,-15]] ]
    ]],
    ["PER047", [
        [ [[-25,-25], [25,5]] ]  
    ]],
    ["PER048", [
        [ [[-48,13.5], [20,27]] ]
    ]],
    ["PER049", [
        [ [[-35,12], [43,27]] ]
        
    ]],
    ["PER051", [
        [ [[-42,15], [21,29]] ]
    ]],
    ["PER052", [
        [ [[-40,-7.5], [40,6.5]] ]
    ]],
    ["PER055", [
                [ [[-40,-25], [40,25]] ],
                [ [[-40,1], [40,25]], [[-40,-25], [40,-1]] ],
                [ [[-43,9], [43,28]], [[-43,-11], [43,7]], [[-36,-32], [36,-13]] ]
    ]],
    ["PER056", [
                [ [[-38,-5], [38,4.0]] ]
    ]],
    ["PER058", [
                [ [[-16,-20], [25,-2]] ]
    ]],
    ["ANIMAL001", [
                [ [[-40,41], [40,56]] ]
    ]],
    ["ANIMAL002", [
                [ [[-38,-54], [38,-39]] ]
    ]],
    ["ANIMAL003", [
                [ [[-27,-25], [27,0]] ]
    ]],
    ["ANIMAL004", [
                [ [[-32,-55], [32,-40.5]] ]
    ]],
    ["ANIMAL005", [
                [ [[-30,-55], [30,-36]] ]
    ]],
    ["ANIMAL006", [
                [ [[-32,-51], [32,-36]] ]
    ]],
    ["ANIMAL007", [
                [ [[-20,-14], [21,0]] ]
    ]],
    ["ANIMAL008", [
                [ [[-33, 48], [33,63]] ]
    ]],
    ["ANIMAL009", [
                [ [[-28,10], [30,30]] ]
    ]],
    ["ANIMAL010", [
                [ [[-32,-50], [32,-35]] ]
    ]],
    ["ANIMAL011", [
                [ [[-33,-7], [20,5]] ]
    ]],
    ["ANIMAL012", [
                [ [[-28,-59], [28,-43]] ]
    ]],
    ["ANIMAL013", [
                [ [[-28,-59], [28,-43]] ]
    ]],
    ["ANIMAL015", [
                [ [[-28,-59], [28,-43]] ]
    ]],
    ["ANIMAL024", [
                [ [[-28,-59], [28,-43]] ]
    ]],
    ["PER059-PER230", [
                [ [[-20,-10], [20,10]] ]
    ]],
    ["PER231", [
                [ [[-27,-42], [27,-27]] ],
    ]],
    ["PER232", [
                [ [[-27,-43], [27,-28]] ],
    ]],
    ["STATE01", [
                [ [[-25,-25], [25,5]] ]
    ]],
    ["STATE02", [
                [ [[-12,-5], [20,15]] ]
    ]],
    ["STATE03", [
                [ [[-25,-13], [40,28]] ]
    ]],
    ["STATE04", [
                [ [[-40,-10], [25,20]] ]
    ]],
    ["STATE05", [
                [ [[-10,-17], [40,3]] ]
    ]],
    ["STATE06", [
                [ [[-30,-15], [30,15]] ]
    ]],
    ["STATE07", [
                [ [[-25,-5], [30,25]] ]
    ]],
    ["STATE08", [
                [ [[-42,0], [10,14]] ]
    ]],
    ["STATE09", [
                [ [[-15,20], [35,33]] ]
    ]],
    ["STATE10", [
                [ [[-25,-25], [25,5]] ]
    ]],
    ["STATE11", [
                [ [[-30,-20], [15,2]] ]
    ]],
    ["STATE12", [
                [ [[-25,-43], [25,-20]] ]
    ]],    
    ["STATE13", [
                [ [[-18,-5], [25,25]] ]
    ]],
    ["STATE14", [
                [ [[-15,-10], [25,20]] ]
    ]],
    ["STATE15", [
                [ [[-25,-10], [25,20]] ]
    ]],
    ["STATE16", [
                [ [[-25,-15], [25,15]] ]
    ]],
    ["STATE17", [
                [ [[0,-10], [40,10]] ]
    ]],
    ["STATE18", [
                [ [[-38,-24], [25,-3]] ]
    ]],
    ["STATE19", [
                [ [[-22,-6], [20,13]] ],
                [ [[-30, 5], [20,20]], [[-30,-15], [20,5]] ],
    ]],
    ["STATE20", [
                [ [[-50,0], [0,25]] ]
    ]],
    ["STATE21", [
                [ [[-45,-29], [5,-7]] ]
    ]],
    ["STATE22", [
                [ [[-48,-10], [-5,10]] ]
    ]],
    ["STATE23", [
                [ [[-40,5], [15,30]] ]
    ]],
    ["STATE24", [
                [ [[-17,-5], [24,25]] ]
    ]],
    ["STATE25", [
                [ [[-25,-20], [25,10]] ]
    ]],
    ["STATE26", [
                [ [[-25,-12], [25,17]] ]
    ]],
    ["STATE27", [
                [ [[-25,-15], [25,15]] ]
    ]],
    ["STATE28", [
                [ [[-25,5], [25,35]] ]
    ]],
    ["STATE29", [
                [ [[-21,-35], [15,-10]] ]
    ]],
    ["STATE30", [
                [ [[-65,-12], [-10,18]] ]
    ]],
    ["STATE31", [
                [ [[-40,-20], [40,20]] ]
    ]],
    ["STATE32", [
                [ [[-10,-15], [25,5]] ]
    ]],
    ["STATE33", [
                [ [[-20,18], [48,38]] ]
    ]],
    ["STATE34", [
                [ [[-25,-15], [25,15]] ]
    ]],
    ["STATE35", [
                [ [[-35,-15], [35,20]] ]
    ]],
    ["STATE36", [
                [ [[-5,-13], [40,15]] ]
    ]],
    ["STATE37", [
                [ [[-25,-18], [25,12]] ]
    ]],
    ["STATE38", [
                [ [[-25,-15], [25,15]] ]
    ]],
    ["STATE39", [
                [ [[-25,-15], [25,15]] ]
    ]],
    ["STATE40", [
                [ [[-20,-00], [25,25]] ]
    ]],
    ["STATE41", [
                [ [[-25,-10], [25,20]] ]
    ]],
    ["STATE42", [
                [ [[-30,12], [30,32]] ]
    ]],
    ["STATE43", [
                [ [[-18,-8], [35,17]] ]
    ]],
    ["STATE44", [
                [ [[-30,-25], [30,10]] ]
    ]],
    ["STATE45", [
                [ [[-15,20], [32,40]] ]
    ]],
    ["STATE46", [
                [ [[-5,-18], [35,3]] ]
    ]],
    ["STATE47", [
                [ [[-15,-15], [40,15]] ]
    ]],
    ["STATE48", [
                [ [[-38,-25], [2,-8]] ]
    ]],
    ["STATE49", [
                [ [[-25,-5], [25,25]] ]
    ]],
    ["STATE50", [
                [ [[-25,-15], [25,15]] ]
    ]],
    ["XMAS0021", [
                [ [[-18, -15], [40,5]] ]
    ]],
    ["XMAS0025", [
                [ [[-18, -15], [40,5]] ]
    ]],
    ["XMAS0047", [
                [ [[-12, 19], [38,46]] ]
    ]],
    ["PER234", [
                [ [[-30, 0], [30,25]] ]
    ]],
    ["PER235", [
                [ [[-40, -10], [10,13]] ]
    ]],
    ["BLUEY001", [
                [ [[-23,40], [33,52]] ]
    ]],
    ["BLUEY002", [
                [ [[-28,-52], [28,-40]] ]
    ]],
    ["BLUEY003", [
                [ [[-28,-52], [28,-40]] ]
    ]],
    ["BLUEY004", [
                [ [[-28,-52], [28,-40]] ]
    ]],
    ["BLUEY005", [
                [ [[-28,-52], [28,-40]] ]
    ]],
    ["BLUEY006", [
                [ [[-28,-52], [28,-40]] ]
    ]],
    ["BLUEY008", [
                [ [[-28,-52], [28,-40]] ]
    ]],
    ["BLUEY009", [
                [ [[-28,-52], [28,-40]] ]
    ]],
    ["BLUEY010", [
                [ [[-33,40], [23,52]] ]
    ]],
    ["BLUEY011", [
                [ [[-28,40], [28,52]] ]
    ]],
    ["BLUEY012", [
                [ [[-28,40], [28,52]] ]
    ]],
    ["BLUEY013", [
                [ [[-28,-52], [28,-40]] ]
    ]],
    ["BLUEY014", [
                [ [[-28,40], [28,52]] ]
    ]],
    ["BLUEY015", [
                [ [[-28,-52], [28,-40]] ]
    ]],
    ["BLUEY016", [
                [ [[-28,40], [28,52]] ]
    ]],
    ["BLUEY018", [
                [ [[-28,-52], [28,-40]] ]
    ]],
    ["BLUEY019", [
                [ [[-28,-52], [28,-40]] ]
    ]],
    ["BLUEY021", [
                [ [[-28,40], [28,52]] ]
    ]],
    ["BLUEY022", [
                [ [[-28,40], [28,52]] ]
    ]],
    ["BLUEY023", [
                [ [[-28,40], [28,52]] ]
    ]],
    ["BLUEY024", [
                [ [[-28,40], [28,52]] ]
    ]],
    ["BLUEY025", [
                [ [[-28,40], [28,52]] ]
    ]],
    ["PER237", [
                [ [[-28,-11], [28,11]] ]
    ]],
    ["XMAS0109", [
                [ [[-40, -18], [40,22]] ]
    ]],
    ["PER204", [ // 2 lines of text defined
        [ [[-35,-10], [35,10]] ],  
        [ [[-35,0], [35,20]], [[-35,-21], [35,-1]] ]  
    ]],
    ["XMAS0110", [
                [ [[-35,-23], [35,-6]] ]
    ]],
    ["XMAS0112", [
                [ [[-29,-1], [31,10]] ]
    ]],
    ["XMAS0113", [
                [ [[-28,0], [30,13]] ]
    ]],
    ["XMAS0114", [
                [ [[-35,-15], [35,2]] ]
    ]],
    ["XMAS0115", [
                [ [[-35,-5], [35,15]] ]
    ]],
    ["XMAS0116", [
                [ [[-30,-12.5], [30,-3.5]] ]
    ]],
    ["XMAS0117", [
                [ [[-35,-4], [35,15]] ]
    ]],
    ["XMAS0118", [
                [ [[-35,-23], [35,-6]] ]
    ]],
    ["XMAS0119", [
                [ [[-40,-11], [40,3]] ]
    ]],
    ["XMAS0120", [
                [ [[-35,-18], [35,-2]] ]
    ]],
    ["XMAS0121", [
                [ [[-32,-32], [32,-18]] ]
    ]],
    ["PER183", [ // 2 lines of text defined
        [ [[-35, -13], [35, 13]] ],  
        [ [[0, 0], [12, 6]], [[0, 6], [12, 12]] ]  
    ]],
    ["PER243", [ 
        [ [[-6.5,-32], [38,15]] ],
        [ [[-6.5,0], [38,15]], [[-6.5,-16], [38,-1]] ],
        [ [[-6.5,0], [38,15]], [[-6.5,-16], [38,-1]] , [[-6.5,-32], [38,-17]] ] 
    ]],
    ["PER227", [ // 2 lines of text defined
        [ [[-35, -13], [35, 13]] ],  
        [ [[-40, -2], [40, 25]], [[-40, -20], [40, 0]]  ]  
    ]],
    ["PER181", [ // 3 lines of text defined
        [ [[-30,-17], [30,17]] ],  // 1 line of text
        [ [[-30,0], [30,30]], [[-30,-30], [30,0]] ],  // 2 lines of text
        [ [[-30,10], [30,30]], [[-30,-10], [30,10]], [[-30,-30], [30,-10]] ]  
    ]],
    ["PER241", [
       [ [[-40, -14], [40,14]] ]
    ]],
    ["PER013", [
        [ [[-35,-15], [35,15]] ],
        [ [[-35,0], [35,30]], [[-35,-30], [35,0]] ],
        [ [[-40,10], [40,30]], [[-40,-10], [40,10]], [[-40,-30], [40,-10]] ]
    ]],
    ["PER123", [ // 3 lines of text defined
        [ [[-30,-15], [30,20]] ],  // 1 line of text
        [ [[-30,10], [30,40]], [[-30,-20], [30,10]] ],  // 2 lines of text
        [ [[-30,20], [30,40]], [[-30, 0], [30,20]], [[-30, -20], [30,00]] ]  
    ]],
    ["PER148", [ // 3 lines of text defined
        [ [[-30,-17], [30,17]] ],  // 1 line of text
        [ [[-30,0], [30,30]], [[-30,-30], [30,0]] ],  // 2 lines of text
        [ [[-30,10], [30,30]], [[-30,-10], [30,10]], [[-30,-30], [30,-10]] ]  
    ]],
    ["3LINE_CIRCLE", [
                [ [[-40,-20], [40,20]] ],
                [ [[-39,0], [39,25]], [[-39,-25], [39,0]] ],
                [ [[-36, 11.5], [36,32]], [[-43,-11], [43,11]], [[-36,-32], [36,-11.5]] ]
    ]],
    
    
    // Add entries for all other SKUs here...
];

function get_bounding_boxes(sku, num_lines) =
    let(
        unit_len = (100/sqrt(2)/2),
        default_entry = [
            [ [[(-unit_len-8)*.85, -unit_len/2], [(unit_len+8)*.85, unit_len/2]] ],  // 1 line of text
            
            [ [[(-unit_len-4)*.85, 1], [(unit_len+4)*.85, unit_len-5]],   // Top box
              [[(-unit_len-4)*.85, -unit_len+4], [(unit_len+4)*.85, -1]] ],  // 2 lines of text
              
            [ [[-unit_len*.8, (unit_len / 3)+2.5], [unit_len*.8, unit_len]],     // Top box
              [[-unit_len*.8, (-unit_len / 3)+1], [unit_len*.8, (unit_len / 3)-1]], // Middle box
              [[-unit_len*.8, -unit_len], [unit_len*.8, (-unit_len / 3)-2.5]] ] // Bottom box   
        ],
        
        sku_entry = [for (entry = bounding_boxes) if (entry[0] == sku) entry][0],
        
        boxes = sku_entry == undef ? default_entry : sku_entry[1],
        highest_defined_index = sku_entry == undef ? num_lines -1 : len(boxes) - 1,
        index = min(num_lines - 1, highest_defined_index)
    )
    boxes[index];