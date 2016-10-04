
// Linear interpolation.
function lerp(t, a, b) = (a * (1 - t)) + (b * t);

// Saw-tooth interpolation.
function serp(t, a, b, c) = t < 0.5 ? lerp(t * 2, a, b) : lerp(((t - 0.5) * 2), b, c);

/// Cubic interpolate between four values
function quadratic_interpolate(t, a, b, c) =
	let(p1 = lerp(t, a, b), p2 = lerp(t, b, c))
	lerp(t, p1, p2);
