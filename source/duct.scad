
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
vent_fin_height = outer_height+thickness*2;
vent_angle = 8;

wheel_height = inner_height + thickness * 2;
vent_height = wheel_height;

vent_count = 3;

function spiral_lerp(t, a = inner_radius, b = outer_radius) =
	lookup(t, [
		[0, inner_radius+0.5],
		[360, outer_radius]
	]);

module spiral(step_size = 10) {
	linear_extrude(height=outer_height)
	polygon(points=concat(
		[for(t = [360:-step_size:10])
			[spiral_lerp(t)*sin(t),spiral_lerp(t)*cos(t)]],
		[for(t = [10:step_size:360])
			[(inner_radius)*sin(t),(inner_radius)*cos(t)]]
	));
}

module wheel(h=wheel_height,r1=inner_radius-2,r2=inner_radius) {
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
		rotate(i-16, [0, 0, 1]) {
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
		vent_fins();
		vortex_shape();
	}
}

module vortex_chamber() {
	render() difference() {
		union() {
			render() minkowski() {
				vortex_shape();
				translate([0, 0, -thickness]) cylinder(h=thickness*2,r=thickness,$fn=8);
			}
		}
		vortex_shape();
	}
	
	wheel();
}

module duct() {
	render() difference() {
		vortex_chamber();
		
		translate([0, 0, thickness]) translate([0, outer_radius]) fan_opening();
		
		vents();
	}
}

// Useful for debugging internal shape:
//vents();
//vortex_shape();

extruder();
duct();

// Air intake.
//translate([0, outer_radius, 4]) color("blue") fan_opening();
