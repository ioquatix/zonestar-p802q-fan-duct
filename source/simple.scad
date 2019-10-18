
use <intake.scad>;
use <interpolate.scad>;

thickness = 1;

module duct() {
	render() difference() {
		translate([0, 0, duct_offset]) union() {
			vortex_chamber();
			vortex_fins();
		}
		
	}
}

module duct() {
	render() difference() {
		render() minkowski() {
			translate([0, 24, thickness]) fan_intake();
			//translate([0, 0, -thickness]) cylinder(h=thickness*2, r=thickness, $fn=32);
			sphere(r=thickness, $fn=16);
		}
		
		// Cut out the fan opening:
		translate([0, 24, thickness]) {
			fan_opening();
			fan_intake();
		}
	}
}

//extruder();

//fan_bracket();

render() difference() {
	duct();
	rotate([40, 0, 0]) cube([40, 26, 40], true);
	translate([0, 0, -10]) cube([100, 100, 10]);
}
