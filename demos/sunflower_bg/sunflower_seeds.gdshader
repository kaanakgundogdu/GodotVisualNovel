shader_type canvas_item;

uniform int seed_count = 900;
uniform float field_radius = 300.0;
uniform float seed_size = 14.0;
uniform float cycle_time = 30.0;
uniform float spin_speed = 0.04;
uniform float orbit_speed = 0.35;
uniform float angle_drift : hint_range(-0.2, 0.2) = 0.018;
uniform float stagger : hint_range(0.0, 0.9) = 0.55;
uniform float chaos_strength : hint_range(0.0, 1.0) = 1.0;
uniform vec4 color_body : source_color = vec4(0.78, 0.47, 0.04, 1.0);
uniform vec4 color_stripe : source_color = vec4(1.0, 0.96, 0.72, 1.0);
uniform vec4 color_rim : source_color = vec4(1.0, 0.81, 0.2, 1.0);

varying float v_glow;
varying vec3 v_chaos_color;

const float GOLDEN = 2.39996323;

vec3 hue_to_rgb(float h) {
	return clamp(abs(fract(h + vec3(0.0, 2.0 / 3.0, 1.0 / 3.0)) * 6.0 - 3.0) - 1.0, 0.0, 1.0);
}

float ease(float x) {
	x = clamp(x, 0.0, 1.0);
	return x * x * x * (x * (x * 6.0 - 15.0) + 10.0);
}

float step_weight(float t, float start, float len, float rel) {
	float local = (t - start) / len;
	float delayed = (local - rel * stagger) / (1.0 - stagger);
	return ease(delayed);
}

float wrap_angle(float a) {
	return a - TAU * floor((a + 3.14159265) / TAU);
}

vec2 polar_mix(vec2 a, vec2 b, float w) {
	float d = wrap_angle(b.y - a.y);
	return vec2(mix(a.x, b.x, w), a.y + d * w);
}

void vertex() {
	float n = float(INSTANCE_ID);
	float count = float(seed_count);
	float rel = sqrt((n + 1.0) / count);
	float t = fract(TIME / cycle_time);
	float spin = TIME * spin_speed;

	vec2 sun = vec2(field_radius * rel, n * GOLDEN + spin);

	float ring = floor((-1.0 + sqrt(1.0 + 4.0 * n / 3.0)) * 0.5);
	float ring_start = 3.0 * ring * (ring + 1.0);
	float ring_len = min(6.0 * (ring + 1.0), count - ring_start);
	float ring_total = floor((-1.0 + sqrt(1.0 + 4.0 * count / 3.0)) * 0.5) + 1.0;
	float ring_r = field_radius * (ring + 1.0) / ring_total;
	float ring_speed = orbit_speed / sqrt(ring + 1.0) * (mod(ring, 2.0) < 0.5 ? 1.0 : -1.0);
	vec2 orbit = vec2(ring_r, TAU * (n - ring_start) / ring_len + TIME * ring_speed);

	vec2 galaxy = vec2(field_radius * rel * 1.08, n * (GOLDEN + angle_drift) + spin * 2.0);

	float w1 = step_weight(t, 0.12, 0.16, rel);
	float w2 = step_weight(t, 0.46, 0.16, rel);
	float w3 = step_weight(t, 0.76, 0.18, rel);

	vec2 p = polar_mix(sun, orbit, w1);
	p = polar_mix(p, galaxy, w2);
	p = polar_mix(p, sun, w3);

	float in_orbit = w1 * (1.0 - w2);
	float in_galaxy = w2 * (1.0 - w3);
	float motion = 4.0 * w1 * (1.0 - w1) + 4.0 * w2 * (1.0 - w2) + 4.0 * w3 * (1.0 - w3);

	vec2 radial = vec2(cos(p.y), sin(p.y));
	vec2 tangent = vec2(-radial.y, radial.x);
	float size = seed_size * (0.75 + 0.45 * rel) * (1.0 - 0.15 * motion);
	float align = in_orbit;
	vec2 axis_a = normalize(mix(radial, tangent, align));
	vec2 axis_b = vec2(-axis_a.y, axis_a.x);
	VERTEX = radial * p.x + axis_a * VERTEX.x * size * 1.15 + axis_b * VERTEX.y * size * 0.8;

	vec3 ring_color = hue_to_rgb(ring / ring_total * 0.85 + TIME * 0.02);
	vec3 galaxy_color = hue_to_rgb(fract(n * (GOLDEN + angle_drift) / TAU) * 0.9 + 0.55);
	v_chaos_color = mix(ring_color, galaxy_color, clamp(in_galaxy + w2 * (1.0 - w3) * 0.0, 0.0, 1.0));
	v_glow = clamp(in_orbit + in_galaxy, 0.0, 1.0);
}

void fragment() {
	vec2 q = UV * 2.0 - 1.0;
	float taper = mix(0.55, 1.0, smoothstep(-1.0, 0.4, q.x));
	float d = length(vec2(q.x, q.y / taper));
	float aa = fwidth(d) * 1.5;
	float body = 1.0 - smoothstep(0.92 - aa, 0.92 + aa, d);
	float rim = smoothstep(0.62, 0.9, d);
	float stripe = (1.0 - smoothstep(0.1, 0.22, abs(q.y / taper))) * smoothstep(-0.9, -0.2, q.x) * (1.0 - smoothstep(0.55, 0.85, q.x));
	float chaos = v_glow * chaos_strength;
	vec3 body_col = mix(color_body.rgb, v_chaos_color * 0.55, chaos);
	vec3 rim_col = mix(color_rim.rgb, v_chaos_color * 0.9, chaos);
	vec3 stripe_col = mix(color_stripe.rgb, mix(v_chaos_color, vec3(1.0), 0.4), chaos);
	vec3 col = body_col;
	col = mix(col, rim_col, rim * 0.8);
	col = mix(col, stripe_col, stripe * 0.85);
	COLOR = vec4(col, body * color_body.a);
}
