
height = 4;
distance = 50;
size = 4;

translate([-distance/2, 0, 0]) cube([size, size, height]);
translate([distance/2, 0, 0]) cube([size, size, height]);
translate([-distance/2, 0, height]) cube([distance+size, size, 1]);