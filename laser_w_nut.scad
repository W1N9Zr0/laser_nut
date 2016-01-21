use <CustomizableFastPrintableAuger.scad>
mm = 1;
inch = 25.4*mm;

$fa = 1;
$fs = .5;
fudge = 0.01; // fudge factor for overlapping boolean ops
clearance = 0.1;

thread_gauge = false;

oversize = 0.005*inch;
oversize_threads = oversize;

laser_nut(oversize = oversize, oversize_threads = oversize_threads, thread_angle = 15, shrink_od = true);

translate([0,0,h+1]) {
	intersection() {
		nut2();
		translate([0,0,-h1-fudge]) cylinder(r=r1*1.5, h= h1 + slot_h + fudge, $fn=4);
	}

	translate([0,0,h-h1+slot_h+1])
	rotate([180,0,0])
	difference() {
		nut2();
		translate([0,0,-h1-fudge]) cylinder(r=r1*1.5, h= h1 + slot_h + fudge+clearance/2, $fn=4);
	}
}

module nut2() {
	laser_nut(oversize = oversize, oversize_threads = oversize_threads, thread_angle = 5, two_screws = true);
}


// The big part:
r1 = 1*inch /2;
h1 = .067*inch;
r2 = .94*inch /2;
h2 = .24*inch;
r3 = .92*inch /2;

h = .567*inch;

slot_w = .067*inch;
slot_h = .253*inch - h1;

// Lead screw main:
lead_screw_pitch = 20; // TPI
lead_screw_starts = 2;
lead_screw_diameter = 3/8*inch;
// lead screw is almost centered between h1 and h
lead_screw_offset = (h - h1) / 2 + .028*inch/2;

// Clamp screw:
// clamp screw position measured from edges
off_r3 = .14*inch;
off_r1 = (.296 +.08)*inch/2;

clamp_screw_offset = r1 - off_r1; // From center.
clamp_screw_diameter = 3*mm + clearance*2; // M3 button head
clamp_screw_head_diameter = 5.7*mm + clearance*2;
clamp_screw_head_depth = 1.65*mm + clearance;
clamp_nut_diameter = 5.5*mm + clearance*2;
clamp_nut_height = 2.4*mm + clearance;


module laser_nut(oversize = 0, oversize_threads = 0, thread_angle = 0, two_screws = false, shrink_od = false) {
  difference(){
    // Main part
    translate([0,0,-h1]) union() {
		cylinder(r=r3-(shrink_od ? clearance/2 : 0), h=h);
		cylinder(r=r2-(shrink_od ? clearance/2 : 0), h=h2);
		cylinder(r=r1-(shrink_od ? clearance/2 : 0), h=h1-(shrink_od ? clearance/2 : 0));
	}

	if (thread_gauge)
		translate([0,0,-h1-fudge])
		cylinder(r=r1*2, h = h1+lead_screw_offset+fudge*2, $fn = 4);

    // Slot
    translate([0,-r1,slot_h])
      cube([r1,r1*2,slot_w+clearance]);

    // clamp screw
	for (side = [0:two_screws?1:0]) rotate(side*180)
    translate([clamp_screw_offset,0,-h1-fudge]) {
        cylinder(d=clamp_screw_diameter,h=h+fudge*2);
        cylinder(d=clamp_screw_head_diameter,h=clamp_screw_head_depth+fudge);
		translate([0,0,h-clamp_nut_height]) rotate(180/6)
			cylinder(d = clamp_nut_diameter / cos(180/6), h=clamp_nut_height+fudge*2, $fn = 6);
		echo("	Required screw length (excluding head):", h - clamp_screw_head_depth);
	}


	translate([0,0,lead_screw_offset])
		rotate([90,0,0])
		{
			thread_p = 1*inch / lead_screw_pitch;

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
			translate([0,0,-r1-oversize_threads/2])
			rotate(0)
			auger(
				rShaft = Auger_shaft_radius + oversize,
				r1 = Auger_shaft_radius + Auger_flight_radius + oversize,
				h = Auger_flight_length,
				overhangAngle = Printer_overhang_capability,
				topsideAngle = Auger_top_surface_angle,
				multiStart = Auger_num_flights,
				flightThickness = Auger_flight_thickness + oversize_threads,
				turns = Auger_twist/360,
				supportThickness = Auger_perimeter_thickness,
				handedness=Auger_handedness,
				truncateTop=true
				);

			// simple 0 degree auger to compare against
			*translate([0,0,-r1])
			rotate(0)
			%auger(
				rShaft = Auger_shaft_radius,
				r1 = Auger_shaft_radius + Auger_flight_radius,
				h = Auger_flight_length,
				overhangAngle = 0,
				topsideAngle = 0,
				multiStart = Auger_num_flights,
				flightThickness = Auger_flight_thickness,
				turns = Auger_twist/360,
				supportThickness = Auger_perimeter_thickness,
				handedness=Auger_handedness,
				truncateTop=true
				);

			// thread gauge
			if (thread_gauge)
				%color([0,1,0,0.3])
				translate([0,lead_screw_diameter/2, -thread_p/2 + (Auger_flight_thickness+oversize_threads)/2])
				for (i = [1:lead_screw_pitch])
					translate([0,0, (i/lead_screw_pitch-.5)*inch])
					cube([2,3,Auger_flight_thickness], center = true);

			scale([1.1,1,1])
			for (side = [0,180]) rotate([side])
				translate([0,0,r1-lead_screw_diameter*.66])
				cylinder(r1=0, r2= lead_screw_diameter, h = lead_screw_diameter);

		}

  }
}
