
module fan_opening() {
	translate([5, 4, 8]) cube([20, 10, 4]);
}

module fan_intake() {
	hull() {
		translate([5, 4, 10]) cube([20, 10, 1]);
		translate([20, 4, 5]) rotate(90, [-1, 0, 0]) cylinder(h=10,r=5);
		cube([1, 15, 10/2]);
	}
}

color("red") fan_inset();
color("blue") fan_intake();
