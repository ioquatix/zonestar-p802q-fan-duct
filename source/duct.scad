
use <intake.scad>

//$fn=32;
$fa=5;
$fs=0.1;

outer_radius = 26;
inner_radius = 15;
outer_height = 5;

inner_height = outer_height * 0.3;

thickness = 1;
duct_height = 10;
duct_width = outer_radius - inner_radius;
vent_size = 5;
vent_height = inner_height + thickness;
vent_fin_height = outer_height+thickness*2;
vent_angle = 8;

module wheel(h=outer_height,r1=inner_radius,r2=outer_radius) {
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
		translate([-1.5, -4, 0]) rotate(-12, [0, 1, 0]) rotate(10, [0, 0, 1]) cube([8, 5, height]);
		translate([-4, -4, inner_height + thickness]) cube([10, 8, thickness*2]);
		vent_fin();
	}
}

module vent_positions()
{
	for (i = [0:90:360]) {
		rotate(i, [0, 0, 1]) {
			translate([inner_radius-thickness, 0, 0]) rotate(vent_angle, [0, 0, 1]) children();
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

module turbine_shape() {
	render() translate([0, 0, thickness]) difference() {
		union() {
			wheel();
			fan_duct();
			scale([-1, 1, 1]) translate([0, outer_radius]) fan_intake();
		}
		
		wheel_slope();
	}
}

module turbine_fins() {
	render() intersection() {
		vent_fins();
		turbine_shape();
	}
}

module turbine_chamber() {
	render() difference() {
		union() {
			render() minkowski() {
				turbine_shape();
				translate([0, 0, -thickness]) cylinder(h=thickness*2,r=thickness,$fn=8);
			}
		}
		turbine_shape();
	}
}

module turbine() {
	render() difference() {
		union() {
			turbine_chamber();
			turbine_fins();
		}
		
		translate([0, 0, thickness]) scale([-1, 1, 1]) translate([0, outer_radius]) fan_opening();
		vents();
	}
}

//turbine_shape();
//wheel();
extruder();
scale([-1, 1, 1]) turbine();
//color("red") vent_fins();
//color("blue") vents();

// Air intake.
//translate([0, 26, 0]) {
//	color("blue") fan_opening();
//}

//vents();
//vent_fins();