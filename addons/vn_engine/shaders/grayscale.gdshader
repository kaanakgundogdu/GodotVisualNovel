shader_type canvas_item;

// Turns a background or sprite black and white. Good for flashbacks,
// memories, or a bad end look.
// amount: how much color is removed. 0.0 keeps full color. 1.0 is full grayscale.

uniform float amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	float luma = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
	vec3 gray = vec3(luma);
	vec3 result = mix(tex_color.rgb, gray, amount);
	COLOR = vec4(result, tex_color.a);
}
