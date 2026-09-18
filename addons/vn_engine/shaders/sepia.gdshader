shader_type canvas_item;

// Tints a background or sprite toward an old photo look, for a memory
// or flashback scene.
// amount: how strong the tint is. 0.0 is the normal image. 1.0 is full tint.
// tint: the color used for the tint. Default is a warm sepia brown.

uniform float amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 tint : source_color = vec4(0.44, 0.26, 0.08, 1.0);

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	float luma = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
	// Multiply by 2.0 so bright pixels can still reach a light tone
	// instead of being capped by the tint color's own brightness.
	vec3 toned = clamp(vec3(luma) * tint.rgb * 2.0, 0.0, 1.0);
	vec3 result = mix(tex_color.rgb, toned, amount);
	COLOR = vec4(result, tex_color.a);
}
