

shader_type canvas_item;

// Declare the group’s drawn texture explicitly
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Animate the reveal: 0.0 = hidden, 1.0 = fully visible
uniform float progress : hint_range(0.0, 1.0) = 1.0;

// Size of each diamond, in pixels
uniform float diamond_pixel_size : hint_range(1.0, 100.0) = 10.0;

// Soft edge width (for smoother reveal)
uniform float softness : hint_range(0.0, 0.5) = 0.1;

void fragment() {
    // Sample what the CanvasGroup has rendered
    vec4 src = texture(SCREEN_TEXTURE, SCREEN_UV);

    // Diamond pattern based on screen coordinates
    float x_fraction = fract(FRAGCOORD.x / diamond_pixel_size);
    float y_fraction = fract(FRAGCOORD.y / diamond_pixel_size);
    float x_dist = abs(x_fraction - 0.5);
    float y_dist = abs(y_fraction - 0.5);

    // Compute the same reveal threshold as your original shader
    float pattern = x_dist + y_dist + SCREEN_UV.x + SCREEN_UV.y;

    // Smooth transition instead of hard discard
    float alpha_mask = smoothstep(progress * 4.0, progress * 4.0 - softness, pattern);

    // Apply the mask to the group’s content alpha
    src.a *= alpha_mask;

    COLOR = src;
}
