use <Thread_Library.scad>
use <CustomizableFastPrintableAuger.scad>
//$fn=40;
$fa = 1;
$fs = 0.02;

// The big part:

r1 = 1 /2;
h1 = 0.067;
r2 = .94 /2;
h2 = .24;
r3 = .92 /2;

h = .567;

slot_t = .067;
slot_h = .253 - h1;

// tension screw
off_r3 = 0.14;
off_r1 = (.296 +.08)/2;

// #6 screw


//hole_center_h = .3; // probably centered between h1 and h
offset = .028;
bolt_head_r = .232;

thread_to_black_part = .574;
black_part = .372;
metal_lip = .110;
plastic_in_metal = .043;

// Lead screw main:
lead_screw_pitch = 20; // TPI
lead_screw_starts = 2;
lead_screw_diameter = 3/8;
lead_screw_offset = thread_to_black_part - black_part - metal_lip
 + lead_screw_diameter / 2 ; // height as measured from bottom
lead_screw_offset = (h - h1) / 2 + .028/2;

// Lead Screw taper:
ls_taper_len = 1/8;
ls_taper_big = 1.5;
ls_taper_small = 1;


// Clamping Mechanism:
slot_width = 1/32;

clamp_screw_diameter = .1380; // #6 screw
clamp_screw_offset = r1 - off_r1; // From center.

clamp_screw_head_diameter = .226; // #6 socket head
clamp_screw_head_depth = 1/8;


main_radius = r1;
main_height = h - h1;



//////////////////////
//CUSTOMIZER OPTIONS//
//////////////////////

oversize = 0.005; //inch
/* [Auger] */

//The total amount of twist, in degrees
Auger_twist = 10*360; //[90:1080]

//The radius of the auger's "flight" past the shaft
Auger_flight_radius = (0.025+oversize)*25.4; //[5:50]

//The number of "flights"
Auger_num_flights = 2;//[1:5]

//The height, from top to bottom of the "shaft"
Auger_flight_length = 1*25.4; //[10:200]

//Angle of the top surface of the "flight"
Auger_top_surface_angle =  5; //[-40:40]

/* [Printer] */

//The overhang angle your printer is capable of
Printer_overhang_capability = 5; //[0:40]

//The thickness of perimeter support material
Auger_perimeter_thickness = 0; //[0:None, 0.8:Thin, 2:Thick]

/* [Uninteresting] */

//The radius of the auger's "shaft"
Auger_shaft_radius = (0.375 - (0.05 - oversize*2))*25.4/2; //[2:25]

//The thickness of the "flight" (in the direction of height)
Auger_flight_thickness =  0.025 * 25.4;  //[0.2:Thin, 1:Medium, 10:Thick]

Auger_handedness = "right";  //["right":Right, "left":Left]

/* [Hidden] */





M_PI = 3.14159;
mm = 1;
inch = 25.4 * mm;



scale(inch/mm) // mm to inch
  difference(){
    // Main part
    translate([0,0,-h1]) union() {
		cylinder(r=r3, h=h);
		cylinder(r=r2, h=h2);
		cylinder(r=r1, h=h1);
	}




    // Slot
    translate([0,-main_radius-1,slot_h])
      cube([3,3,slot_width]);

    // clamp screw
    translate([clamp_screw_offset,0,-h1-.1])
        cylinder(r=clamp_screw_diameter/2,h=h);
    translate([clamp_screw_offset,0, -h1-.001])
        cylinder(r=clamp_screw_head_diameter/2,h=clamp_screw_head_depth);


	translate([0,0,lead_screw_offset])
		rotate([90,0,0])
		{

			//Auger_shaft_radius + Auger_flight_radius
			translate([0,0,-main_radius])
			scale(mm/inch)
			auger(
				rShaft = Auger_shaft_radius,
				r1 = Auger_shaft_radius + Auger_flight_radius,
				h = Auger_flight_length,
				overhangAngle = Printer_overhang_capability,
				topsideAngle = Auger_top_surface_angle,
				multiStart = Auger_num_flights,
				flightThickness = Auger_flight_thickness,
				turns = Auger_twist/360,
				supportThickness = Auger_perimeter_thickness,
				handedness=Auger_handedness,
				truncateTop=false, /*Todo: Still needs work!*/
				/*$fn=10,*/
				$fa=1,
				$fs=0.5
				);

			scale([1.2,1,1])
			for (side = [-1,1])
				rotate([90+side*90])
				translate([0,0,main_radius-lead_screw_diameter*.7])
				cylinder(r1=0, r2= lead_screw_diameter, h = lead_screw_diameter);

		}

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
