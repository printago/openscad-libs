function get_font_name(easy_font_name) = 
    easy_font_name == "disney" ? "WaltographSCAD" :
    easy_font_name == "ariana" ? "Ariana Violeta:style=Ariana Violeta" :
    easy_font_name == "barbie" ? "Bartex Pro:style=Regular" :
    easy_font_name == "count"  ? "Count and Spell:style=Regular" :
    easy_font_name == "ceceps" ? "Cecep's Handwriting:style=Regular" :
    easy_font_name == "anjhay" ? "Anjhay:style=Regular" :
    easy_font_name == "star"   ?   "Star Strella:style=Regular" :
    easy_font_name == "batman" ? "BatmanForeverAlternate:style=Regular" :
    easy_font_name == "potter"  ? "Harry P:style=Regular":
    easy_font_name == "helvetica" ? "Helvetica:style=Regular":
    easy_font_name == "helvetica_bold" ? "Helvetica:style=Bold":
    easy_font_name == "jura_b" ? "Jura:style=Bold" :
    easy_font_name == "jura"   ? "Jura:style=Regular":
    easy_font_name == "hotel"   ? "Grand Hotel:style=Regular":
    easy_font_name == "moana"   ? "Moanas:style=Medium" :
    easy_font_name == "script_b"   ? "Dancing Script:style=Bold" :
    easy_font_name == "bluey"   ? "Blue Custard:style=Regular" :
    easy_font_name == "dancing" ? "Dancing Script:style=Regular":
    easy_font_name == "dancing_bold" ? "Dancing Script:style=Bold":
    easy_font_name == "caring" ? "Care Bear Family:style=Regular":   
    easy_font_name == "great_vibes" ? "Great Vibes:style=Regular":   
    easy_font_name == "VollkornBold" ? "Vollkorn:style=Bold":   
    easy_font_name == "Ontel" ? "Ontel:style=Regular":   
    
    easy_font_name; // return the original, assume it's a full-font-specification.

module _draw_ref_box(box) {
    translate([box[0][0], box[0][1]])
        square([box[1][0]-box[0][0], box[1][1]-box[0][1]]);
    
}

function to_upper(string) = 
  chr([for(s = string) let(c = ord(s)) c >= 97 && c <= 122 ? c - 32 : c]);

function to_lower (string) = 
  chr([for(s=string) let(c=ord(s)) c<91 && c>64 ?c+32:c]); 

module draw_fit_text(
    text_string, 
    bounding_box = [[0, 0], [100, 50]],  //bottom LEFT to top RIGHT
    font = "Liberation Sans", 
    halign = "center", 
    valign = "center", 
    spacing = 1, 
    direction = "ltr", 
    language = "en", 
    script = "latin", 
    $fn = 360,
    draw_bound = false,
    fill_text = false) {
    
    // Starting with a base size to scale from
    size = 10; 
    
    if (draw_bound) {
        _draw_ref_box(bounding_box);
    }
    
    // Calculate initial metrics
    metrics = textmetrics(text = text_string, size = size, font = font, halign = halign, valign = valign, spacing = spacing, direction = direction, language = language, script = script, $fn = $fn);

    // Extract the bounding box dimensions
    box_width = abs(bounding_box[1][0] - bounding_box[0][0]);
    box_height = abs(bounding_box[1][1] - bounding_box[0][1]);

    // Determine scale factors based on bounding box dimensions and metrics
    scale_factor_width = box_width / metrics.size.x;
    scale_factor_height = box_height / (metrics.ascent - metrics.descent);

    // Use the smaller of the two scale factors to ensure text fits within the box
    final_scale_factor = min(scale_factor_width, scale_factor_height);

    if (fill_text == true) {
        fill()
        translate([bounding_box[0][0]+box_width/2, bounding_box[0][1]+box_height/2, 0]) {
            scale([final_scale_factor, final_scale_factor, 0]) {
                text(
                    text = text_string, 
                    size = size, 
                    font = font, 
                    halign = halign, 
                    valign = valign, 
                    spacing = spacing, 
                    direction = direction, 
                    language = language, 
                    script = script, 
                    $fn = $fn
                );
            }
        }

    } else {
        // Render the text at the adjusted size, centered in the bounding box
        translate([bounding_box[0][0]+box_width/2, bounding_box[0][1]+box_height/2, 0]) {
            scale([final_scale_factor, final_scale_factor, 0]) {
                text(
                    text = text_string, 
                    size = size, 
                    font = font, 
                    halign = halign, 
                    valign = valign, 
                    spacing = spacing, 
                    direction = direction, 
                    language = language, 
                    script = script, 
                    $fn = $fn
                );
            }
        }
    }
}

module draw_text_known_scale(
    text_string, 
    bounding_box = [[0, 0], [100, 50]],
    font = "Liberation Sans", 
    halign = "center", // Default: "left"
    valign = "center", // Default: "baseline"
    spacing = 1, 
    direction = "ltr", 
    language = "en", 
    script = "latin", 
    $fn = 360,
    scale_factor = 1,
    draw_bound = false) {
    
    size = 10;
    
    if (draw_bound) {
        _draw_ref_box(bounding_box);
    }
    
    
    box_width = abs(bounding_box[1][0] - bounding_box[0][0]);
    box_height = abs(bounding_box[1][1] - bounding_box[0][1]);
    
    translate([bounding_box[0][0]+box_width/2, bounding_box[0][1]+box_height/2, 0]) {
        scale([scale_factor, scale_factor, 0]) {
            text(
                text = text_string, 
                size = size, 
                font = font, 
                halign = halign, 
                valign = valign, 
                spacing = spacing, 
                direction = direction, 
                language = language, 
                script = script, 
                $fn = $fn
            );
        }
    }
}

function get_scale_factor(
    text_string, 
    bounding_box = [[0, 0], [100, 50]],
    font = "Liberation Sans", 
    halign = "center", // Default: "left"
    valign = "center", // Default: "baseline"
    spacing = 1, 
    direction = "ltr", 
    language = "en", 
    script = "latin", 
    $fn = 360
) = 
    let(
        size = 10, // Base size for initial text metrics
        metrics = textmetrics(
            text = text_string, 
            size = size, 
            font = font, 
            halign = halign, 
            valign = valign, 
            spacing = spacing, 
            direction = direction, 
            language = language, 
            script = script, 
            $fn = $fn
        ),
        box_width = abs(bounding_box[1][0] - bounding_box[0][0]),
        box_height = abs(bounding_box[1][1] - bounding_box[0][1]),
        scale_factor_width = box_width / metrics.size.x,
        scale_factor_height = box_height / (metrics.ascent - metrics.descent)
    )
    min(scale_factor_width, scale_factor_height);
    
function get_text_height(
                text_string = "",
                bounding_box = [[0, 0], [100, 50]],
                font = "Liberation Sans", 
                halign = "center", 
                valign = "center", 
                spacing = 1, 
                direction = "ltr", 
                language = "en", 
                script = "latin", 
                $fn = 0) =
    
        let(
        size = 10, // Base size for initial text metrics
        metrics = textmetrics(
            text = text_string, 
            size = size, 
            font = font, 
            halign = halign, 
            valign = valign, 
            spacing = spacing, 
            direction = direction, 
            language = language, 
            script = script, 
            $fn = $fn
        ),
        box_width = abs(bounding_box[1][0] - bounding_box[0][0]),
        box_height = abs(bounding_box[1][1] - bounding_box[0][1]),
        scale_factor_width = box_width / metrics.size.x,
        scale_factor_height = box_height / (metrics.ascent - metrics.descent)
    )
    min(metrics.ascent - metrics.descent);
    
        
function substring(string, start, length=undef) = 
	length == undef? 
		between(string, start, len(string)) 
	: 
		between(string, start, length+start)
	;

function between(string, start, end) = 
	string == undef?
		undef
	: start == undef?
		undef
	: start > len(string)?
		undef
	: start < 0?
		before(string, end)
	: end == undef?
		undef
	: end < 0?
		undef
	: end > len(string)?
		after(string, start-1)
	: start > end?
		undef
	: start == end ? 
		"" 
	: 
        join([for (i=[start:end-1]) string[i]])
	;
    
function join(strings, delimeter="") = 
	strings == undef?
		undef
	: strings == []?
		""
	: _join(strings, len(strings)-1, delimeter);
    
function _join(strings, index, delimeter) = 
	index==0 ? 
		strings[index] 
	: str(_join(strings, index-1, delimeter), delimeter, strings[index]) ;

