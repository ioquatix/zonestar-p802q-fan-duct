use <intake.scad>;
use <interpolate.scad>;

//$fn=32;
$fa=5;
$fs=0.1;

// Controls the number of vents.
vent_count = 9;
// and relative position
duct_rotation = -360/vent_count;
duct_offset = 3;

// Inner size of the hole and of the spiral
inner_radius = 15;
outer_radius = inner_radius + 22;
fan_radius = 24;

// Height of the duct
inner_height = 2;
outer_height = 3;

// Wall thickness
thickness = 1.0;
inner_inset = thickness*2;

// Derived dimensions
duct_width = outer_radius - inner_radius;
baffle_height = inner_height+thickness*2;
wheel_height = inner_height+thickness*2;

// updated to keep in mind the different direction of the vents
function spiral_lerp(t) =
	lookup(t, [
		[0, outer_radius],
		[360, /*inner_radius+inner_inset*/inner_radius+(outer_radius - inner_radius)/vent_count]
	]);

module spiral(step_size = 5) {
	render() union() {
        rotate(duct_rotation, [0, 0, 1]) difference() {
            linear_extrude(height=outer_height)
            polygon(points=
                [for(t = [0:step_size:360])
                    [spiral_lerp(t)*sin(t),spiral_lerp(t)*cos(t)]]
            );
            
            cylinder(h=outer_height, r=inner_radius-inner_inset);
        }
    }
}

// updated to keep in mind the different direction of the vents
function baffle_lerp(t, width) =
	lookup(t, [
		[0, inner_radius + width],
		[360/vent_count, inner_radius-inner_inset]
	]);

// modified shape of the baffles to have a third of open space and 2/3 of filled space. Changed the form to avoit sharp angles too.
module baffle(width) {
	rotation_angle = 360 / vent_count;
	step_size = rotation_angle / (vent_count*3);
        render () union () {
            blade = concat(
                [for(t = [-rotation_angle/4:step_size:rotation_angle])
                    [baffle_lerp(t, width)*sin(t),baffle_lerp(t, width)*cos(t)]],
                [for(t = [rotation_angle:-step_size:step_size*vent_count])
                    [(inner_radius-inner_inset)*sin(t),(inner_radius-inner_inset)*cos(t)]]
            );

            fin = [for(t = [0:0.1:1]) quadratic_interpolate(t,
                blade[0],
                blade[2],
                blade[len(blade)-1]
            )];
            
            linear_extrude(height=baffle_height) polygon(points=concat(fin, blade));
        }
}

module baffles() {
	rotation_angle = 360/vent_count;
	start_width = outer_radius - inner_radius;

	render () union () {
        for(i = [0:vent_count-1]) rotate(duct_rotation + rotation_angle * i, [0, 0, 1]) {
            baffle(start_width / vent_count);
        }
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
	render () union () {
        // The subtraction here is to smooth out the top of the inlet ducting.
        translate([0, 0, outer_height]) scale([1, 1, -1]) cylinder(h=slope_height,r1=fan_radius,r2=inner_radius-inner_inset);
        translate([0, 0, outer_height]) cylinder(h=10,r=fan_radius-3);
    }
}

// changed to manage the direction of the flow
module vortex_shape() {
	render() translate([0, 0, thickness]) difference() {
		union() {
			spiral();
			translate([0, fan_radius, 0]) fan_intake(inner_radius, outer_radius, duct_rotation, height=outer_height);
		}
		wheel_slope();
	}
}

// changed to manage the direction of the flow
module sloped_ring(r1=thickness, r2=0) {
	render() difference() {
		cylinder(h=thickness,r=inner_radius+((outer_radius-inner_radius)/vent_count));
		cylinder(h=thickness,r1=inner_radius-r1,r2=inner_radius+((outer_radius-inner_radius)/vent_count)-r2);
	}
}

module vortex_fins() {
	render() union () {
        baffles();

        sloped_ring(r1=0);
    }
}
// very complex to change as minkowski and difference easily end up in a non existing object. Changed some parameters to be parametric
module vortex_chamber() {
	render() union () {
        render() difference() {
            render() minkowski() {
                vortex_shape();
                translate([0, 0, -thickness]) cylinder(h=thickness*2,r=thickness,$fn=12);
            }
            
            // Cut out inside wall:
            cylinder(h=thickness*2,r=inner_radius+((outer_radius-inner_radius)/vent_count));

            vortex_shape();
        }
	}
}

module duct() {
	render() union () {
        render() difference() {
            translate([0, 0, duct_offset]) union() {
                vortex_chamber();
                vortex_fins();
            }
		
            translate([0, 0, duct_offset]) cylinder(h=baffle_height*1.2,r1=inner_radius,r2=inner_radius-inner_inset);
            
            // Cut out the fan opening:
            translate([0, 0, thickness]) translate([0, fan_radius]) fan_opening();
        }
    }
}

// Useful for debugging internal shape:
//color ("red") translate ([0,0,10])vortex_shape();
//color ("red") translate ([0,0,10]) spiral();
//sloped_ring();
//extruder();
//translate([0, 25, 0]) fan_intake();
//fan_bracket();
//vortex_chamber();
//vortex_shape();
//translate([0, fan_radius, 0]) fan_intake(inner_radius+inner_inset, outer_radius, duct_rotation, height=outer_height);
//spiral();
//color ("green ") translate ([0,0,-10])vortex_fins();
	//	translate([0, 0, duct_offset]) cylinder(h=baffle_height*1.2,r1=inner_radius,r2=inner_radius-inner_inset);
//color ("blue") translate([0, 0, 17 ])	rotate(0, [0, 0, 1]) vortex_fins();
//render () difference () {
    //translate ([-35,-35,6]) cube(100);
//}
/*color ("green") translate([0, 0, 15 ])			union() {
			spiral();
			translate([0, fan_radius, 0]) fan_intake(inner_radius, outer_radius, duct_rotation, height=outer_height);
		}
color ("red") translate([0, 0, 16 ])			union() {
			translate([0, fan_radius, 0]) fan_intake(inner_radius, outer_radius, duct_rotation, height=outer_height);
		}
        */
duct();
