use <Thread_Library.scad>
$fn=40;

// The big part:
main_radius = 0.9/2;
main_height = 3/4;

// Lead screw main:
lead_screw_pitch = 20; // TPI
lead_screw_starts = 2;
lead_screw_diameter = 3/8;
lead_screw_offset = 1/2; // height as measured from bottom

// Lead Screw taper:
ls_taper_len = 1/8;
ls_taper_big = 1.5;
ls_taper_small = 1;


// Clamping Mechanism:
slot_width = 1/32;

clamp_screw_diameter = 1/8;
clamp_screw_offset = 1/4; // From center.

clamp_screw_head_diameter = 3/16;
clamp_screw_head_depth = 1/8;


scale(25.4) // mm to inch
  difference(){
    // Main part
    cylinder(r=main_radius, h=main_height);



    // Slot
    translate([0,-main_radius-1,lead_screw_offset-slot_width/2])
      cube([3,3,slot_width]);

    // clamp screw
    translate([clamp_screw_offset,0,0]) 
        cylinder(r=clamp_screw_diameter/2,h=6);
    translate([clamp_screw_offset,0,main_height - clamp_screw_head_depth]) 
        cylinder(r=clamp_screw_head_diameter/2,h=5);
      
      
      
    // Blank Lead Scew
    /*
      translate([0,0,lead_screw_offset])
      rotate([90,0,0])
       cylinder(r=lead_screw_diameter/2,h=10,center=true);
      */ 
       
    // multi-start acme nut:
    translate([0,1,lead_screw_offset]) 
      scale(1/25.4) rotate([90,0,0])
        union(){
            for (i=[1:lead_screw_starts]){
                echo (360/i);
                rotate([0,0,360/i])
                    multi_start(lead_screw_pitch,
                        lead_screw_diameter,
                        lead_screw_starts);
            }
        }

    // Input / output taper!
      translate([0,-main_radius ,lead_screw_offset])
      rotate([90,0,0])
       cylinder(
            r2=lead_screw_diameter*ls_taper_big/2,
            r1=lead_screw_diameter*ls_taper_small/2,
            h=ls_taper_len ,center=true);
      translate([0,main_radius ,lead_screw_offset])
      rotate([90,0,0])
       cylinder(
            r1=lead_screw_diameter*ls_taper_big/2,
            r2=lead_screw_diameter*ls_taper_small/2,
            h=ls_taper_len, center=true);
      

      
  }




module multi_start( pitch,diameter,starts){
    length=20;
    // 20 tpi = 1/20" * 25.4
    pitch=25.4 / pitch; // (1/20" per inch * 25.4 mm/inch)
    pitchRadius = diameter /2 * 25.4; 
    starts=starts;

trapezoidThread(    
	length=length, 			// axial length of the threaded rod 
	pitch=pitch, 			// axial distance from crest to crest
    starts=starts,
	pitchRadius=pitchRadius, 	// radial distance from center to mid-profile
	threadHeightToPitch=0.5, 	// ratio between the height of the profile and the pitch 
						// std value for Acme or metric lead screw is 0.5
	profileRatio=0.5, 			// ratio between the lengths of the raised part of the profile and the pitch
						// std value for Acme or metric lead screw is 0.5
	threadAngle=29,			// angle between the two faces of the thread 
						// std value for Acme is 29 or for metric lead screw is 30
	RH=true, 				// true/false the thread winds clockwise looking along shaft, i.e.follows the Right Hand Rule
	clearance=0.1, 			// radial clearance, normalized to thread height
	backlash=0.1, 			// axial clearance, normalized to pitch
	stepsPerTurn=24,			// number of slices to create per turn,
	showVertices=false
		);

}