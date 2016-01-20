// Parametric Printable Auger
// It is licensed under the Creative Commons - GNU GPL license.
// � 2013 by William Gibson
// http://www.thingiverse.com/thing:96462

use <../utils/build_plate.scad>
use <sweep.scad>
use <scad-utils/transformations.scad>
use <scad-utils/shapes.scad>
use <draw-helpers.scad>
use <obiscad/vector.scad>

use <scad-utils/linalg.scad>


M_PI = 3.14159;
mm = 1;
inch = 25.4 * mm;

	
function rotatex(a)=[[1,0,0],
                     [0,cos(a),-sin(a)],
                     [0,sin(a),cos(a)]];
                     

function rotatey(a)=[[cos(a),0,sin(a)],
                     [0,1,0],
                     [-sin(a),0,cos(a)]];
                     
					 
function rotatez(a)=[[cos(a),-sin(a),0],
                     [sin(a),cos(a),0],
                     [0,0,1]];
 function rotatea(c,s,l,m,n)=[[l*l*(1-c)+c,m*l*(1-c)-n*s,n*l*(1-c)+m*s],
                             [l*m*(1-c)+n*s,m*m*(1-c)+c,n*m*(1-c)-l*s],
                             [l*n*(1-c)-m*s,m*n*(1-c)+l*s,n*n*(1-c)+c]];
                             

function rotateanv(a,nv)=rotatea(cos(a),sin(a),nv[0],nv[1],nv[2]);

function rotate(a,v)=(v==undef)?rotatez(a[2])*rotatey(a[1])*rotatex(a[0]):
                     rotateanv(a,v/sqrt(v*v)); 


function rotate_from_to(a,b,_axis=[]) = 
        len(_axis) == 0 
        ? rotate_from_to(a,b,unit(cross(a,b))) 
        : _axis*_axis >= 0.99 ? rotation_from_axis(unit(b),_axis,cross(_axis,unit(b))) * 
    transpose_3(rotation_from_axis(unit(a),_axis,cross(_axis,unit(a)))) : identity3();
	
function rotate_from_to2(a,b,roll=0,_axis=[]) = 
        len(_axis) == 0 
        ? rotate(roll, b) * rotate_from_to(a,b,unit(cross(a,b))) 
        : _axis*_axis >= 0.99 ? rotation_from_axis(unit(b),_axis,cross(_axis,unit(b))) * 
    transpose_3(rotation_from_axis(unit(a),_axis,cross(_axis,unit(a)))) : identity3(); 

	


function angle(frac, totalDeg, exponent) = totalDeg * pow(frac, exponent);
function funcX(frac, totalDeg, exponent, r) = r * cos(angle(frac, totalDeg, exponent));
function funcY(frac, totalDeg, exponent, r) = r * sin(angle(frac, totalDeg, exponent));


function augerFlightCrossSection(flightThickness, extraTopsideFlight, extraFlight, r)
	=[	
		[-r, extraFlight],
		[-r, -flightThickness-extraTopsideFlight],
		[0, -flightThickness],
		[0, 0]
	];
	


module augerFlight(numSteps, flightThickness, turns, rShaft, r1, h, topsideAngle, overhangAngle, handedness, twistPower=1)
{
	totalAngleDeg = 360.0 * turns;
	
	extraFlight = tan(overhangAngle)*(r1-rShaft);
	//echo("Calculated extra flight thickness (from overhang angle) (mm): ", extraFlight);
	
	extraTopsideFlight = tan(topsideAngle)*(r1-rShaft);
	//echo("Calculated extra flight thickness (from topsideAngle angle) (mm): ", extraTopsideFlight);

	height = max(0.001, h - flightThickness - extraTopsideFlight); //Must be strictly >0 so we actually get something,
	
	heightStep=(height/numSteps);
	//echo("Calculated height step (mm): ", heightStep);

	shape_points = augerFlightCrossSection(flightThickness, extraTopsideFlight, extraFlight, r1-rShaft);
	
	startHeight = max(-1 * extraTopsideFlight, 0);
	echo("startHeight",startHeight);
	*polygon(shape_points);	
	
	
	pathAngle = [for (i=[0:numSteps])
		let(t=i/numSteps, y=t*height) 
			angle(t, totalAngleDeg, twistPower)];

	path = [for (i=[0:numSteps])
		let(t=i/numSteps, y=t*height) 
			[funcX(t, totalAngleDeg, twistPower, r1),funcY(t, totalAngleDeg, twistPower, r1), y]];

	
	//path_transforms1 = construct_transform_path(path); //We can't use this! It uses the tangent to the path (we need tangent to the circle) and doesn't roll the 2D shape first.		
	path_transforms1 = [
	for (i=[0:len(path)-1])
		construct_rt(rotate_from_to2([0,0,1], [-path[i][1], path[i][0], 0], roll=pathAngle[i]), path[i])
	];

	
	
	*draw_path(path);
	*draw_transforms(path_transforms1);
	
	*for (i=[0:len(path)-1])
		translate(path[i])
			orientate([-path[i][1], path[i][0], 0], roll=pathAngle[i])
				polygon(shape_points);
	
	sweep(shape_points, path_transforms1, inverted=(handedness=="right"));
	
}













////////////
//Examples//
////////////

//Simple Example
// auger(rShaft=1/8*inch, r=.75*inch, h=1*inch, 
// turns=2, multiStart=1, flightThickness = 0.2, 
// overhangAngle=20, supportThickness=0.0);

//Multistart example
// auger(rShaft=1/2*inch, r=2*inch, h=2*inch, 
// turns=1, multiStart=3, flightThickness = 0.6, 
// overhangAngle=20, supportThickness=0.0);

//Support example
// auger(rShaft=1/2*inch, r=2*inch, h=2*inch, 
// turns=2, multiStart=1, flightThickness = 0.6, 
// overhangAngle=10, supportThickness=0.8);

//Truncated top Example
// auger(rShaft=1/8*inch, r=.75*inch, h=1*inch, 
// turns=2, multiStart=1, flightThickness = 0.2, 
// overhangAngle=20, supportThickness=0.0,
// truncateTop=true);


// auger(rShaft=5, r1=30, h=40, 
// turns=4, multiStart=1, flightThickness = 1, 
// overhangAngle=20, supportThickness=0.0,
// truncateTop=true);



//cylinder(r=3/8*25.4/2, h=0.5*inch, $fn=20);

//////////////////////
//Auger Library Code//
//////////////////////

//Notes: 
//rShaft >= 1mm please
//flightThickness >= extrusion thickness of your printer
//supportThickness >= 2 * extrusion width of your printer, or zero to turn off.

module auger(rShaft = 0.5*inch, r1=1*inch, h=1*inch, multiStart=1, turns=1,
flightThickness = 0.2*mm, topsideAngle=0, overhangAngle=20, supportThickness=0*mm,
handedness="right" /*"left"*/,
truncateTop=false)
{	
	// echo("rShaft", rShaft);
	// echo("r1", r1);
	// echo("h", h);
	// echo("multiStart", multiStart);
	// echo("turns", turns);
	// echo("overhangAngle", overhangAngle);
	// echo("topsideAngle", topsideAngle);
	
	if(r1 <= rShaft)
		echo("ERROR: Auger module called with r < rShaft");
	
	if(overhangAngle < -1 * topsideAngle)
		echo("ERROR: Auger module called with topsideAngle past overhangAngle. e.g. overhangAngle of 15° means topsideAngle must be >= -15°.");
	
	if($fs < 0.1)
	{
		echo("WARNING: $fs too small!");
	}
	if($fa < 0.1)
	{
		echo("WARNING: $fa too small!");
	}
	
	//Calculate numSteps based on $fn, $fs, $fa
	numSteps=ceil(($fn > 0.0) ? $fn : 
	max(5,
	max(h/(max($fs,0.1)),
	max(360.0 / $fa, 
	r1*2*M_PI*turns / max($fs,0.1)))));
	
	echo("Number of Steps calculations:");
	echo("Minimum steps",5);
	echo("By Height", h/(max($fs,0.1)));
	echo("By Angle", 360.0 / $fa);
	echo("By Perimeter", r1*2*M_PI*turns / max($fs,0.1));
	echo("From $fn", $fn);
	echo("numSteps = ", numSteps);
		
	extraFlight = tan(overhangAngle)*(r1-rShaft);
	extraTopFlight = tan(topsideAngle)*(r1-rShaft);
	extraHeightForTruncation=truncateTop?extraTopFlight+flightThickness+extraFlight:0;

	
	// echo("extraTopFlight", extraTopFlight);
	// echo("flightThickness", flightThickness);
	// echo("extraFlight", extraFlight);
	
	extraTopFlightBelowZero = extraTopFlight < 0 ? -1 * extraTopFlight : 0;
	echo("extraTopFlightBelowZero",extraTopFlightBelowZero);
	
	extraTopFlightAboveZero = extraTopFlight > 0 ? extraTopFlight : 0;
	echo("extraTopFlightAboveZero",extraTopFlightAboveZero);
	
	echo("tmp", h - flightThickness - extraTopFlightAboveZero);
	echo("turns * multiStart",turns * multiStart);
	adjacentPathDistance = (h - flightThickness - extraTopFlightAboveZero) / (turns * multiStart); //Distance along height, between path at angle 0 and at angle 360 (etc)
	echo("adjacentPathDistance",adjacentPathDistance);
	
	flight_gap = min(0.1,2*(h/numSteps)); //Minimum gap; function of precision.
	echo("flight_gap",flight_gap);
	flight_root_thickness = extraFlight + flightThickness + extraTopFlight;
	height_between_flight_and_itself = adjacentPathDistance - flight_root_thickness - flight_gap;
	echo("height_between_flight_and_itself", height_between_flight_and_itself);
	
	turnsAboveOne = (multiStart * turns > 1) ? multiStart * turns : 0; //Either 0, or >=1.0; self-intersection not a problem below 1 complete turn.
	echo("turnsAboveOne",turnsAboveOne);
	
	echo("extraTopFlight",extraTopFlight);

	
	*cylinder(h=h,r=r1,$fn=20);
	
	
	heightAtWhichFlightJustNotSelfIntersecting = h - (height_between_flight_and_itself * turnsAboveOne);// + extraTopFlightBelowZero;
	
	
	
	minHeight = flight_root_thickness > h ? flight_root_thickness : h;
	echo("minHeight", minHeight);
	
	minValidHeight = (heightAtWhichFlightJustNotSelfIntersecting > h ? heightAtWhichFlightJustNotSelfIntersecting : minHeight);
	echo("minValidHeight", minValidHeight);
	
	if(minValidHeight > h)
	{
		echo("WARNING: Automatically extending height of auger so that each flight does not intersect another.");		
	}
	
	*cylinder(h=minValidHeight,r=r1,$fn=20);
	
	extendedMinValidHeight = minValidHeight + extraHeightForTruncation;
	turns = turns*(minValidHeight+extraHeightForTruncation)/minValidHeight;
	
	//h = extraHeightForTruncation+(heightAtWhichFlightJustNotSelfIntersecting > h ? heightAtWhichFlightJustNotSelfIntersecting : minHeight); //If neccessary, increase h.
	//turns = turns*(h+extraHeightForTruncation)/h;	

	echo("Total turn in degrees = ", 360*turns);
		
	intersection()
	{
		difference()
		{

			auger_not_truncated(rShaft=rShaft, r1=r1, h=extendedMinValidHeight, turns=turns*(handedness=="right"?1:-1), 
			flightThickness=flightThickness, overhangAngle=overhangAngle, topsideAngle=topsideAngle,
			multiStart=multiStart, supportThickness=supportThickness,
			handedness=handedness,
			numSteps=numSteps);
			
			//Cut off bottom of auger so it's printable.
			
			translate([0,0,-1 * extraFlight])
			cube([r1 * 3,r1 * 3,2*extraFlight], center=true);
			
			// if(truncateTop)
			// {
				// translate([0,0,extendedMinValidHeight])
				// #cube([r1 * 3,r1 * 3,2*(extraFlight+flightThickness)], center=true);
			// }
		}
	
		if(truncateTop)
			cylinder(r=r1*2, h=minValidHeight);
	}
}


module auger_not_truncated(rShaft = 0.5*inch, r1=1*inch, h=1*inch, turns=1, flightThickness = 0.2*mm, topsideAngle=0, overhangAngle=20, multiStart=1, supportThickness=0*mm, handedness=1, numSteps)
{
	//echo("rShaft", rShaft);
	//echo(overhangAngle);
	
	if(supportThickness > 0)
	{
		
		difference()
		{
			cylinder(h=h, r=r1+supportThickness, $fa=$fa/2);
			cylinder(h=h, r=r1-0.01, $fa=$fa/2);
			
		}
		
	}

	
	extraTopFlight = tan(topsideAngle)*(r1-rShaft);
	echo("extraTopFlight",extraTopFlight);
	extraTopFlightBelowZero = extraTopFlight < 0 ? -1 * extraTopFlight : 0;
	echo("extraTopFlightBelowZero",extraTopFlightBelowZero);
	
	cylinder(r=rShaft, h=h, $fn=numSteps); //Central shaft
	
	rShaftM1 = max(0, rShaft - 1); //1mm skinnier than the shaft, to ensure the flight 'sticks' to the shaft.
	for(start=[1:1:multiStart]) //render each flight
	{
		startAngle = 360 * start / multiStart;
		rotate([0,0,startAngle])
		{
			//render()
			{
				translate([0,0,extraTopFlightBelowZero])
				augerFlight(numSteps=numSteps, flightThickness=flightThickness, turns=turns, rShaft=rShaftM1, r1=r1, h=h-extraTopFlightBelowZero, topsideAngle=topsideAngle, overhangAngle=overhangAngle, handedness=handedness);
			}
		}
	} 
}



	
	


