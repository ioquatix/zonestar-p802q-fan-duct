
use <bolts.scad>;

clip_offset = 0.5;
extruder_offset = 20;

module fan_intake_clip() {
	render() translate([0, -2, 0]) {
		cylinder(h=15,r=1, $fn=16);
		translate([-0.5, 0, 0]) cube([1, 3, 15]);
	}
}

module fan_intake_plug() {
	translate([26+clip_offset, 0, 12]) rotate(90, [-1, 0, 0]) fan_intake_clip();
	translate([4-clip_offset, 0, 12]) rotate(90, [-1, 0, 0]) fan_intake_clip();
}

module fan_opening() {
	translate([5, 0, 11]) cube([20, 15, 10]);
}

module fan_intake() {
	render() union() {
		translate([5, 0, 10]) cube([20, 15, 5]);
		hull() {
			translate([5, 0, 10]) cube([20, 15, 1]);
			intersection() {
				translate([15, 0, 10]) rotate(90, [-1, 0, 0]) cylinder(h=15,r=10);
				translate([5, 0, 0]) cube([20, 15, 10]);
			}
			cube([1, 10, 10/2]);
		}
	}
}

module fan_ducting_example() {
	render() difference() {
		union() {
			render() minkowski() {
				fan_intake();
				translate([0, 0, -thickness]) cylinder(h=thickness*2,r=thickness,$fn=8);
			}
		}
		fan_intake();
		fan_opening();
	}
	//fan_intake_plug();
}

module fan_mock() {
	translate([0, 0, extruder_offset+50/2]) rotate(-90, [1, 0, 0]) {
		color("white") translate([0, 0, 15/2]) cube([50, 50, 15], center=true);
	}
}

module fan_mounting_bracket() {
	render() translate([0, 0, extruder_offset]) difference() {
		translate([-26, -3, 0]) {
			// scews centered by 30 apart
			translate([0, -12+3, 53 - 3]) cube([52, 12, 3]);
			//55 to base of fan
			cube([52, 3, 53]);
		}
		
		// The offset of the screw is -3 from the edge.
		translate([-15, -6, 47]) hole();
		translate([15, -6, 47]) hole();
		
		translate([0, -3, 50/2]) rotate(-90, [1, 0, 0]) {
			#rotate(45, [0, 0, 1]) translate([0, 30, 0]) hole(depth=3, inset=0);
			#rotate(45, [0, 0, 1]) translate([0, -30, 0]) hole(depth=3, inset=0);
		}
	}
}

module extruder() {
	color("orange") {
		translate([0, 0, 6]) cylinder(h=70-6, r=3);
		cylinder(h=6,r1=0.5, r2=5);
		translate([0, 0, 10+15/2]) cube([18, 22, 15], true);
	}
}

extruder();
translate([0, 26, 0]) {
	fan_mock();
	fan_mounting_bracket();
	fan_ducting_example();
	color("red") fan_opening();
	//color("blue") fan_intake();
	//color("green") fan_intake_plug();
}