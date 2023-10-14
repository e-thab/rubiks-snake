shader_type spatial;
render_mode unshaded;

void vertex() {
	VERTEX.y += 0.001;
	VERTEX.x += 0.001;
	VERTEX *= 1.025;
}

void fragment() {
	ALBEDO = vec3(0.0, 0.5, 1.0);
	ALPHA = 0.45;
}
