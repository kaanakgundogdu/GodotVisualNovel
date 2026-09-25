shader_type canvas_item;

uniform vec4 color_center : source_color = vec4(0.23, 0.13, 0.02, 1.0);
uniform vec4 color_edge : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 color_halo : source_color = vec4(1.0, 0.76, 0.1, 1.0);
uniform float aspect = 1.7778;
uniform float halo_radius = 0.42;
uniform float orbit_radius = 0.42;
uniform float halo_strength : hint_range(0.0, 1.0) = 0.2;
uniform float cycle_time = 30.0;
uniform int ring_total = 17;
uniform float star_speed = 0.12;
uniform float star_density : hint_range(0.0, 1.0) = 0.35;
uniform float ripple_speed = 0.12;


float hash21(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

float stars(vec2 p, float layer) {
	float r = length(p);
	float a = atan(p.y, p.x) / TAU + 0.5;
	float lr = log(max(r, 0.001));
	float speed = star_speed * (0.6 + layer * 0.5);
	vec2 cell_uv = vec2(a * (70.0 + layer * 40.0), lr * 14.0 - TIME * speed * 14.0);
	vec2 id = floor(cell_uv);
	vec2 f = fract(cell_uv) - 0.5;
	float h = hash21(id + layer * 17.0);
	float present = step(1.0 - star_density, h);
	vec2 offset = vec2(hash21(id + 3.1) - 0.5, hash21(id + 7.7) - 0.5) * 0.6;
	vec2 d = f - offset;
	float streak = 0.08 + smoothstep(0.1, 0.8, r) * 0.35;
	float star = smoothstep(0.09, 0.0, length(vec2(d.x, d.y * (0.18 / streak))));
	return star * present * smoothstep(0.05, 0.35, r);
}

void fragment() {
	vec2 p = (UV - 0.5) * vec2(aspect, 1.0);
	float d = length(p);
	vec3 col = mix(color_center.rgb, color_edge.rgb, smoothstep(0.0, 0.75, d));

	float t = fract(TIME / cycle_time);
	float orbit_phase = smoothstep(0.2, 0.28, t) * (1.0 - smoothstep(0.5, 0.58, t));
	float spacing = orbit_radius / float(ring_total);
	float ring_id = floor(d / spacing + 0.5);
	float ring_line = smoothstep(0.0015, 0.0, abs(d - ring_id * spacing)) * step(ring_id, float(ring_total)) * step(1.0, ring_id);
	col += vec3(0.8, 0.85, 1.0) * ring_line * orbit_phase * 0.25;

	float ripple_t = fract(TIME * ripple_speed);
	for (int i = 0; i < 3; i++) {
		float rt = fract(ripple_t + float(i) / 3.0);
		float rr = halo_radius * (1.0 + rt * 1.6);
		float ripple = smoothstep(0.004, 0.0, abs(d - rr)) * (1.0 - rt) * (1.0 - rt);
		col += color_halo.rgb * ripple * 0.35;
	}

	float glow = exp(-pow((d - halo_radius) * 8.0, 2.0));
	col += color_halo.rgb * glow * halo_strength;

	vec3 star_col = vec3(0.0);
	for (int layer = 0; layer < 3; layer++) {
		float fl = float(layer);
		vec3 tint = mix(vec3(1.0), 0.6 + 0.4 * cos(TAU * (fl * 0.33 + vec3(0.0, 0.33, 0.67))), 0.5);
		star_col += tint * stars(p, fl);
	}
	col += star_col * 0.9;
	COLOR = vec4(col, 1.0);
}
