
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
vent_height = inner_height + thickness * 0.46;

module vent_fin(height) {
	translate([inner_radius-thickness, -4.6, 0]) rotate(10, [0, 0, 1]) cube([5, thickness, height]);
	translate([inner_radius-thickness+5, -3.7, 0]) rotate(50, [0, 0, 1]) cube([3, thickness, height]);
}

module vent(height) {
	translate([inner_radius-thickness-1.5, -3.88]) rotate(-12, [0, 1, 0]) rotate(10, [0, 0, 1]) cube([6, 5, height]);
}

module vents() {
	for (i = [0:45:360]) {
		rotate(i, [0, 0, 1]) {
			vent(vent_height);
		}
	}
}

module vent_fins() {
	for (i = [0:45:360]) {
		rotate(i, [0, 0, 1]) {
			vent_fin(inner_height+thickness*2);
		}
	}
}

module wheel() {
	render() difference() {
		cylinder(h=outer_height,r=outer_radius);
		cylinder(h=outer_height,r=inner_radius);
	}
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