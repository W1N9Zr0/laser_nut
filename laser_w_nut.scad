use <CustomizableFastPrintableAuger.scad>
// all units in inches! output stl in mm using scale()

$fa = 1;
$fs = 0.02;

// The big part:
r1 = 1 /2;
h1 = 0.067;
r2 = .94 /2;
h2 = .24;
r3 = .92 /2;

h = .567;

slot_w = .067;
slot_h = .253 - h1;

// Lead screw main:
lead_screw_pitch = 20; // TPI
lead_screw_starts = 2;
lead_screw_diameter = 3/8;
// lead screw is almost centered between h1 and h
lead_screw_offset = (h - h1) / 2 + .028/2;

// Clamp screw:
// clamp screw position measured from edges
off_r3 = 0.14;
off_r1 = (.296 +.08)/2;

clamp_screw_diameter = .1380; // #6 screw
clamp_screw_offset = r1 - off_r1; // From center.

clamp_screw_head_diameter = .226; // #6 socket head
clamp_screw_head_depth = 1/8;


module laser_nut(oversize = 0.005, thread_angle = 5) {
  scale(25.4)
  //difference()
  {
    // Main part
    *translate([0,0,-h1]) union() {
		cylinder(r=r3, h=h);
		cylinder(r=r2, h=h2);
		cylinder(r=r1, h=h1);
	}




    // Slot
    *translate([0,-r1-1,slot_h])
      cube([3,3,slot_w]);

    // clamp screw
    *translate([clamp_screw_offset,0,-h1-.1])
        cylinder(r=clamp_screw_diameter/2,h=h);
    *translate([clamp_screw_offset,0, -h1-.0001])
        cylinder(r=clamp_screw_head_diameter/2,h=clamp_screw_head_depth);


	translate([0,0,lead_screw_offset])
		rotate([90,0,0])
		{
			thread_p = 1 / lead_screw_pitch;

			//The radius of the auger's "flight" past the shaft
			Auger_flight_radius = thread_p/2; //[5:50]

			//The number of "flights"
			Auger_num_flights = lead_screw_starts;//[1:5]

			//The height, from top to bottom of the "shaft"
			Auger_flight_length = r1 * 2; //[10:200]

			//The total amount of twist, in degrees
			Auger_twist = Auger_flight_length / thread_p / lead_screw_starts *360; //[90:1080]

			//Angle of the top surface of the "flight"
			Auger_top_surface_angle =  thread_angle; //[-40:40]

			//The overhang angle your printer is capable of
			Printer_overhang_capability = thread_angle; //[0:40]

			//The thickness of perimeter support material
			Auger_perimeter_thickness = 0; //[0:None, 0.8:Thin, 2:Thick]

			/* [Uninteresting] */

			//The radius of the auger's "shaft"
			Auger_shaft_radius = lead_screw_diameter/2 - thread_p/2; //[2:25]

			//The thickness of the "flight" (in the direction of height)
			Auger_flight_thickness =  thread_p/2 -thread_p/4*sin(thread_angle)*2;  //[0.2:Thin, 1:Medium, 10:Thick]

			Auger_handedness = "right";  //["right":Right, "left":Left]

			//Auger_shaft_radius + Auger_flight_radius
			translate([0,0,-r1])
			rotate(0)
			auger(
				rShaft = Auger_shaft_radius + oversize,
				r1 = Auger_shaft_radius + Auger_flight_radius + oversize,
				h = Auger_flight_length,
				overhangAngle = Printer_overhang_capability,
				topsideAngle = Auger_top_surface_angle,
				multiStart = Auger_num_flights,
				flightThickness = Auger_flight_thickness,
				turns = Auger_twist/360,
				supportThickness = Auger_perimeter_thickness,
				handedness=Auger_handedness,
				truncateTop=true /*Todo: Still needs work!*/
				);

			translate([0,.4,-r1])
			rotate(0)
			auger(
				rShaft = Auger_shaft_radius + oversize,
				r1 = Auger_shaft_radius + Auger_flight_radius + oversize,
				h = Auger_flight_length,
				overhangAngle = 0,
				topsideAngle = 0,
				multiStart = Auger_num_flights,
				flightThickness = Auger_flight_thickness,
				turns = Auger_twist/360,
				supportThickness = Auger_perimeter_thickness,
				handedness="left",
				truncateTop=true /*Todo: Still needs work!*/
				);

			// thread gauge
			%color([1,0,1,0.3])
			translate([0,.38/2, thread_p/8-thread_p/2])
			for (i = [0:lead_screw_pitch])
				translate([0,0, i/lead_screw_pitch-.5])
				cube([.2,.1,Auger_flight_thickness], center = true);

			*scale([1.1,1,1])
			for (side = [0,180]) rotate([side])
				translate([0,0,r1-lead_screw_diameter*.66])
				cylinder(r1=0, r2= lead_screw_diameter, h = lead_screw_diameter);

		}

  }
}

laser_nut(oversize = 0.005, thread_angle = $t);
