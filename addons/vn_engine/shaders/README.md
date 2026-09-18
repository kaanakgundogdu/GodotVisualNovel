# VN Engine Shaders

Simple `canvas_item` shaders for the visual novel engine. Each shader is one
file, cheap enough for a full screen `ColorRect` or `TextureRect`.

| Shader | Uniform | Type | Range | Default | Meaning |
|---|---|---|---|---|---|
| transition.gdshader | kind | int | 0 to 7 | 0 | Which transition, see file header |
| | progress | float | 0.0 to 1.0 | 0.0 | How far into the transition |
| | color | color | - | black | Cover color |
| locked_blur.gdshader | strength | float | 0.0 to 8.0 | 4.0 | Blur amount |
| | darken | float | 0.0 to 1.0 | 0.4 | Darken amount |
| grayscale.gdshader | amount | float | 0.0 to 1.0 | 0.0 | 0 is full color, 1 is full grayscale |
| sepia.gdshader | amount | float | 0.0 to 1.0 | 0.0 | 0 is normal image, 1 is full tint |
| | tint | color | - | warm brown | Tint color used for the toning |
| vignette.gdshader | strength | float | 0.0 to 1.0 | 0.3 | How dark the screen edges get |
| | softness | float | 0.01 to 1.0 | 0.5 | How soft the edge falloff is |
| | color | color | - | black | Color used for the darkened edges |

## How to attach one

1. Make a `ShaderMaterial`, either in the Inspector or with `ShaderMaterial.new()` in code.
2. Set its `shader` property to the `.gdshader` file, for example `grayscale.gdshader`.
3. Assign the material to the node's `material` property. Use a `Sprite2D` or `TextureRect` for a single CG or character, or a full screen `ColorRect` for a global effect.
4. Animate a uniform with a `Tween`, for example:
   `tween.tween_method(material.set_shader_parameter.bind("amount"), 0.0, 1.0, 1.5)`
