
use <intake.scad>;

//$fn=32;
$fa=5;
$fs=0.1;

outer_radius = 25;
inner_radius = 15;
outer_height = 5;

inner_height = outer_height * 0.3;

thickness = 1;
duct_height = 10;
duct_width = outer_radius - inner_radius;
vent_size = 5;
baffle_height = inner_height+thickness*2;
vent_angle = 8;

wheel_height = inner_height + thickness * 2;
vent_height = wheel_height;

vent_count = 3;

function spiral_lerp(t) =
	lookup(t, [
		[0, inner_radius],
		[360, outer_radius]
	]);

module spiral(step_size = 10) {
	render()
	difference() {
		linear_extrude(height=outer_height)
		polygon(points=
			[for(t = [360:-step_size:0])
				[spiral_lerp(t)*sin(t),spiral_lerp(t)*cos(t)]]
		);
		
		cylinder(h=outer_height, r=inner_radius);
	}
}

function baffle_lerp(t, width) =
	lookup(t, [
		[0, inner_radius],
		[360/vent_count, inner_radius + width]
	]);

// Linear interpolation.
function lerp(t, a, b) = (a * (1 - t)) + (b * t);

// Saw-tooth interpolation.
function serp(t, a, b, c) = t < 0.5 ? lerp(t * 2, a, b) : lerp(((t - 0.5) * 2), b, c);

/// Cubic interpolate between four values
function quadratic_interpolate(t, a, b, c) =
	let(p1 = lerp(t, a, b), p2 = lerp(t, b, c))
	lerp(t, p1, p2);

module baffle(width) {
	rotation_angle = 360 / vent_count;
	step_size = rotation_angle / 16;
	
	blade = concat(
		[for(t = [rotation_angle:-step_size:0])
			[baffle_lerp(t, width)*sin(t),baffle_lerp(t, width)*cos(t)]],
		[for(t = [0:step_size:rotation_angle-(step_size*2)])
			[(inner_radius-width)*sin(t),(inner_radius-width)*cos(t)]]
	);
	
	fin = [for(t = [0:0.02:1]) quadratic_interpolate(t,
		blade[len(blade)-1],
		blade[2],
		blade[0]
	)];
	
	linear_extrude(height=baffle_height) polygon(points=concat(blade, fin));
}

module baffles() {
	rotation_angle = 360/vent_count;
	start_width = outer_radius - inner_radius;

	for(i = [0:vent_count-1]) rotate(rotation_angle * i, [0, 0, 1]) {
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

module vent_fin(height=vent_fin_height) {
	intersection() {
		translate([0, 1.5, 0]) wheel(r1=5, r2=6, h=height);
		union() {
			translate([6, -3.5, 0]) rotate(70, [0, 0, 1]) cube([10, 2.5, height]);
			translate([-2, -6, 0]) rotate(10, [0, 0, 1]) cube([10, 5, height]);
		}
	}
}

module vent(height=vent_height) {
	difference() {
		translate([-5, -1.5, 0.1]) rotate(14, [1, 0, 0]) rotate(-10, [0, 0, 1]) cube([2, 4, height]);
		translate([-6, -1.5, inner_height + thickness]) cube([5, 10, thickness*2]);
	}
}

module vent_positions()
{
	rotation_angle = 360 / vent_count;
	
	for (i = [0:rotation_angle:360]) {
		rotate(i, [0, 0, 1]) {
			translate([3, inner_radius-thickness, 0]) rotate(vent_angle, [0, 0, 1]) children();
		}
	}
}

module vents() {
	vent_positions() vent();
}

module vent_fins() {
	vent_positions() vent_fin();
}

module wheel_slope() {
	slope_height = outer_height - inner_height;
	
	translate([0, 0, outer_height]) scale([1, 1, -1]) cylinder(h=slope_height,r1=outer_radius,r2=inner_radius);
	translate([0, 0, outer_height]) cylinder(h=10,r=outer_radius);
}

module fan_duct() {
	intersection() {
		scale([1, (duct_width+outer_radius)/outer_radius, 1]) wheel();
		cube([outer_radius*2, outer_radius*2, outer_height]);
	}
}

module vortex_shape() {
	render() translate([0, 0, thickness]) difference() {
		union() {
			spiral();
			translate([0, outer_radius]) fan_intake();
		}
		
		wheel_slope();
	}
}

module vortex_fins() {
	render() intersection() {
		baffles();
		vortex_shape();
	}
}

module vortex_chamber() {
	render() difference() {
		render() minkowski() {
			vortex_shape();
			translate([0, 0, -thickness]) cylinder(h=thickness*2,r=thickness,$fn=8);
		}
		
		// Cut out inside wall
		cylinder(h=wheel_height, r=inner_radius);
		
		vortex_shape();
		
		// open up the vortex assembly to ease design
		//translate([0, 0, 5+2]) cube([100, 100, 10], true);
	}
	
	baffles();
}

module duct() {
	render() difference() {
		vortex_chamber();
		
		translate([0, 0, thickness]) translate([0, outer_radius]) fan_opening();
		
		//vent_fins();
	}
}

// Useful for debugging internal shape:
//vortex_fins();
//vortex_chamber();
//spiral();

extruder();
duct();

// Air intake.
//translate([0, outer_radius, 4]) color("blue") fan_opening();
