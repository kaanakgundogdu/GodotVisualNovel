shader_type canvas_item;

// Darkens the edges of the screen or a card and keeps the center clear.
// Useful for focusing attention or adding mood to a scene.
// strength: how dark the edges get. 0.0 turns the effect off.
// softness: how soft the edge to center falloff is. Higher is softer.
// color: the color used for the darkened edges. Default is black.

uniform float strength : hint_range(0.0, 1.0) = 0.3;
uniform float softness : hint_range(0.01, 1.0) = 0.5;
uniform vec4 color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	vec2 centered = UV - vec2(0.5);
	// 1.414214 is sqrt(2), it scales distance so a screen corner equals 1.0.
	float dist = length(centered) * 1.414214;
	float vignette_amount = smoothstep(1.0 - softness, 1.0, dist) * strength;
	vec3 result = mix(tex_color.rgb, color.rgb, vignette_amount);
	COLOR = vec4(result, tex_color.a);
}
