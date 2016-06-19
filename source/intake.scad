
use <bolts.scad>;

clip_offset = 0.5;
extruder_offset = 20;
thickness = 1;
offset = 2;

module fan_opening() {
	translate([0, offset, 0]) {
		translate([5, 0, 11]) cube([20, 15, 10]);
		translate([25, 15/2-3/2, 20-3]) cube([0.5, 3, 4]);
	}
}

module fan_intake() {
	render() difference() {
		union() {
			translate([5, offset, 10]) cube([20, 15, 10-thickness]);
			hull() {
				translate([5, offset, 10]) cube([20, 15, 1]);
				intersection() {
					translate([5, 15/2+offset, 15/2]) rotate(90, [0, 1, 0]) cylinder(h=20,r=15/2);
					translate([5, offset, 0]) cube([20, 15, 10]);
				}
				
				translate([5+3, offset-7, 0]) rotate(-90, [0, 0, 1]) cube([1, 20, 10/2]);
				
				//translate([0, -10, 0]) 
				//rotate(135, [0, 0, 1]) translate([0, -25, 0]) 
				translate([0, -25, 0]) rotate(-45, [0, 0, 1]) translate([0, 15, 0]) cube([1, 15, 10/2]);
			}
		}
		
		translate([5, -5+offset, 5*2]) rotate(90, [0, 1, 0]) cylinder(h=25,r=5);
		translate([5, -5-40, 5]) cube([25, 40+offset, 10]);
		translate([5, -5+offset, 10]) cube([25, 5, 5]);
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
	render() translate([0, 0, extruder_offset]) difference() {
		translate([-26, -inset, 0]) {
			// scews centered by 30 apart
			translate([0, -10, 50]) cube([52, 10, block_height]);
		}
		
		// The offset of the screw is -3 from the edge.
		translate([-15, -6, 50]) #hole(depth=inset);
		translate([15, -6, 50]) #hole(depth=inset);
		
		fan_mount_holes();
	}
}

module fan_mount_bracket(thickness=4) {
	bottom_extension = 7;
	
	render() translate([0, thickness-2, extruder_offset]) difference() {
		translate([-26, -thickness, 0]) {
			//55 to base of fan
			translate([0, 0, 0]) cube([52, thickness, 50+block_height]);
			
			translate([30, 0, -bottom_extension]) cube([22, 18, bottom_extension+2]);
		}
		
		// Inset for duct attachment:
		translate([4, -1, -bottom_extension]) cube([22, 1+16+4, bottom_extension+2]);

		translate([0, 0, 25]) rotate(90, [1, 0, 0]) cylinder(r=20,h=thickness+1);

		// Fan screw holes
		translate([0, 0, 50/2]) rotate(90, [1, 0, 0]) {
			translate([23, 20, 0]) #hole(diameter=2.8, depth=thickness, inset=0);
			translate([-23, -18, 0]) #hole(diameter=2.8, depth=thickness, inset=0);
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
		
		fan_mount_top();
		fan_mount_bracket();
		
		fan_ducting_example();
		
		color("red") fan_opening();
		//color("blue") fan_intake();
		//color("green") fan_intake_plug();
	}
}

//fan_intake();
//example();
//fan_mount_bracket();