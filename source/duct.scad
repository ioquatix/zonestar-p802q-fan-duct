
use <intake.scad>;
use <interpolate.scad>;

//$fn=32;
$fa=5;
$fs=0.1;

// Controls the number of vents.
vent_count = 8;

inner_radius = 15;
outer_radius = inner_radius + 22;
fan_radius = 24;

inner_height = 3;
outer_height = 4;

// outer_height = 5;
// inner_height = outer_height * 0.3;

thickness = 1;
inner_inset = thickness*2;
duct_width = outer_radius - inner_radius;
baffle_height = inner_height+thickness*2;
wheel_height = inner_height+thickness*2;

duct_rotation = -40;

// cube([50, 50, 2], true);

function spiral_lerp(t) =
	lookup(t, [
		[0, outer_radius],
		[360, inner_radius]
	]);

module spiral(step_size = 5) {
	render()
	rotate(duct_rotation, [0, 0, 1]) difference() {
		linear_extrude(height=outer_height)
		polygon(points=
			[for(t = [0:step_size:360])
				[spiral_lerp(t)*sin(t),spiral_lerp(t)*cos(t)]]
		);
		
		//cylinder(h=outer_height, r=inner_radius);
	}
}

function baffle_lerp(t, width) =
	lookup(t, [
		[0, inner_radius + width],
		[360/vent_count, inner_radius]
	]);

module baffle(width) {
	rotation_angle = 360 / vent_count;
	step_size = rotation_angle / 12;
	
	blade = concat(
		[for(t = [0:step_size:rotation_angle])
			[baffle_lerp(t, width)*sin(t),baffle_lerp(t, width)*cos(t)]],
		[for(t = [rotation_angle:-step_size:step_size*2])
			[(inner_radius-inner_inset)*sin(t),(inner_radius-inner_inset)*cos(t)]]
	);
	
	fin = [for(t = [0:0.1:1]) quadratic_interpolate(t,
		blade[0],
		blade[2],
		blade[len(blade)-1]
	)];
	
	linear_extrude(height=baffle_height) polygon(points=concat(fin, blade));
}

module baffles() {
	rotation_angle = 360/vent_count;
	start_width = outer_radius - inner_radius;

	for(i = [0:vent_count-1]) rotate(duct_rotation + rotation_angle * i, [0, 0, 1]) {
		tube_width = start_width * (i+1)/vent_count;
		color("orange") baffle(tube_width / (i+1));
	}
}

module wheel(h=wheel_height,r1=inner_radius-thickness,r2=inner_radius) {
	render() difference() {
		cylinder(h=h,r=r2);
		cylinder(h=h,r=r1);
	}
}

module wheel_slope() {
	slope_height = outer_height - inner_height;
	
	// The subtraction here is to smooth out the top of the inlet ducting.
	translate([0, 0, outer_height]) scale([1, 1, -1]) cylinder(h=slope_height,r1=fan_radius-3,r2=inner_radius);
	translate([0, 0, outer_height]) cylinder(h=10,r=fan_radius-3);
}

module vortex_shape() {
	render() translate([0, 0, thickness]) difference() {
		union() {
			spiral();
			translate([0, fan_radius, 0]) fan_intake(inner_radius, outer_radius, duct_rotation);
		}
		
		wheel_slope();
	}
}

module sloped_ring(r1=thickness, r2=0) {
	render() difference() {
		cylinder(h=thickness,r=inner_radius);
		cylinder(h=thickness,r1=inner_radius-r1,r2=inner_radius-r2);
	}
}

module vortex_fins() {
	baffles();

	sloped_ring(r1=inner_inset);
	
	difference() {
		translate([0, 0, inner_height]) cylinder(h=thickness*2, r=inner_radius);
		translate([0, 0, inner_height]) sloped_ring(r1=inner_inset);
	}
}

module vortex_chamber() {
	render() difference() {
		render() minkowski() {
			vortex_shape();
			translate([0, 0, -thickness]) cylinder(h=thickness*2,r=thickness,$fn=8);
		}
		
		// Cut out inside wall:
		cylinder(h=inner_height+thickness, r=inner_radius);
		
		// Cut out the fan opening:
		translate([0, 0, thickness]) translate([0, fan_radius]) fan_opening();
		
		vortex_shape();
		
		// open up the vortex assembly to ease design
		//translate([0, 0, 5+2]) cube([100, 100, 10], true);
	}
}

module duct() {
	render() difference() {
		union() {
			vortex_chamber();
			vortex_fins();
		}
		
		cylinder(h=baffle_height*1.2,r1=inner_radius-inner_inset,r2=inner_radius);
	}
}

// Useful for debugging internal shape:
//vortex_shape();
//spiral();

//extruder();
//translate([0, 25, 0]) fan_intake();
//fan_bracket();
duct();
