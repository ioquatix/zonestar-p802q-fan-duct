
use <bolts.scad>;

$fn = 32;

clip_offset = 0.5;
extruder_offset = 20;

// Distance from outside of metal case to center of extruder.
fan_mount_offset = 24;
top_screws_offset = -1.5 / 2;

thickness = 1;
offset = 4;

module clip() {
	color("blue") render() translate([2, 0, 12]) {
		difference() {
			union() {
				translate([0, -8, 0]) {
					cube([8, 8, 8]);
					translate([18, 0, 0]) cube([8, 8, 8]);
				}
				translate([0, -2, 0]) cube([26, 24, 8]);
			}
			translate([2, 0, 0]) cube([22, 20, 8]);
			translate([2+6, -2, 0]) cube([22-12, 2, 8]);
			
			translate([0, -4, 4]) rotate([90, 0, 90]) bolt(3, 22, 2.5);
		}
	}
}

module fan_opening() {
	translate([0, offset, 0]) {
		translate([5, 0, 11]) cube([20, 15, 10]);
		translate([25, 15/2-3/2, 20-3]) cube([0.5, 3, 4]);
		translate([4, -1, 20]) cube([20+thickness*2, 15+thickness*2, 10]);
	}
}

module fan_intake(inner_radius, outer_radius, duct_rotation, height=4, width=20, inset_radius=2) {
	render() translate([5, 0, 0]) difference() {
		union() {
			translate([0, offset, 10]) cube([20, 15, 10-thickness]);
			// Fan attachment:
			hull() {
				translate([0, offset, 10]) cube([20, 15, 1]);
				intersection() {
					translate([0, 15/2+offset, 15/2]) rotate(90, [0, 1, 0]) cylinder(h=20,r=15/2);
					translate([0, offset, 0]) cube([20, 15, 10]);
				}
				
				translate([0, offset-inset_radius, 0]) rotate(-90, [0, 0, 1]) cube([1, 20, height]);
			}
			
			// Bottom connector to duct:
			hull() {
				across = outer_radius - inner_radius;
				
				translate([0, offset-inset_radius, 0]) rotate(-90, [0, 0, 1]) cube([1, 20, height]);
				translate([-5, -25, 0]) rotate(duct_rotation, [0, 0, 1]) translate([-1, inner_radius, 0]) cube([1, across, height]);
			}
		}
		
		// Cut out the rounded inset:
		inset_offset = height + inset_radius;
		
		translate([0, -inset_radius+offset, inset_offset]) rotate(90, [0, 1, 0]) cylinder(h=width,r=inset_radius);
		translate([0, -inset_radius-height, height]) cube([width, height+offset, 10]);
		translate([0, -inset_radius+offset, inset_offset]) cube([20, inset_radius, 20-height-inset_radius*2]);
	}
}

module fan_ducting_example(o) {
	render() translate([0, 0, thickness]) difference() {
		union() {
			render() minkowski() {
				fan_intake();
				translate([0, 0, -thickness]) cylinder(h=thickness*2,r=thickness,$fn=8);
			}
		}
		fan_intake();
		fan_opening();
	}
}

module fan_mock() {
	render() translate([0, offset, extruder_offset+50/2]) rotate(-90, [1, 0, 0]) {
		translate([0, 0, 15/2]) cube([50, 50, 15], center=true);
	}
}

block_height = 8;

module fan_mount_holes(thickness=2) {
	translate([0, -thickness-8, 50+block_height/2]) rotate(180, [0, 0, 1]) rotate(90, [1, 0, 0]) {
		translate([-22, 0, 0]) bolt(depth=10);
		translate([ 22, 0, 0]) bolt(depth=10);
	}
}

module fan_mount_top(inset=2) {
	render() translate([0, 2, extruder_offset]) difference() {
		translate([-26, -inset, 0]) {
			// scews centered by 30 apart
			translate([0, -10, 50]) cube([52, 10, block_height]);
		}
		
		// The offset of the screw is 3 from the edge.
		hull() {
			translate([-14, -inset-3, 50]) hole(depth=block_height, inset=0);
			translate([-16, -inset-3, 50]) hole(depth=block_height, inset=0);
		}
		
		hull() {
			translate([14, -inset-3, 50]) hole(depth=block_height, inset=0);
			translate([16, -inset-3, 50]) hole(depth=block_height, inset=0);
		}
		
		fan_mount_holes();
	}
}

module fan_mount_bracket(thickness=4) {
	bottom_extension = 8;
	
	render() translate([0, thickness, extruder_offset]) difference() {
		translate([-26, -thickness, 0]) {
			//55 to base of fan
			translate([0, 0, 0]) cube([52, thickness, 50+block_height]);
			
			translate([30, 0, -bottom_extension]) cube([22, 18, bottom_extension+2]);
		}
		
		// Inset for duct attachment:
		translate([4, -1, -bottom_extension]) cube([22, 1+16+4, bottom_extension+4]);

		translate([0, 0, 25]) rotate(90, [1, 0, 0]) cylinder(r=20,h=thickness+1);
		
		translate([0, 0, 50/2]) rotate([-90, 0, 0]) {
			translate([-23, 18, -thickness]) hole(diameter=2.8, depth=thickness, inset=1, extension=1);
			translate([23, -20, -thickness]) hole(diameter=2.8, depth=thickness, inset=1, extension=1);
		}
		
		fan_mount_holes();
	}
}

module extruder() {
	color("orange") {
		translate([0, 0, 6]) cylinder(h=70-6, r=3);
		cylinder(h=6,r1=0.5, r2=5);
		translate([0, 0, 10+15/2]) cube([18, 22, 15], true);
	}
}

module fan_example() {
	//extruder();
	translate([0, 25, 0]) {
		fan_mock();
		
		clip();
		
		fan_mount_top();
		fan_mount_bracket();
		
		fan_ducting_example();
		
		color("red") #fan_opening();
		color("blue") fan_intake();
	}
}

module fan_bracket() {
	translate([0, fan_mount_offset, 0]) {
		fan_mount_bracket();
		fan_mount_top();
	}
}

//fan_intake(height=3);
fan_example();
