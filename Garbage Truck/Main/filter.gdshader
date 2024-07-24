shader_type canvas_item;

uniform float pixelSize : hint_range(1.0, 100.0) = 4.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec2 pixelUVSize = vec2(1080, 1080);

    // Round the current UV to the nearest pixel
    vec2 roundedUV = floor(SCREEN_UV / pixelUVSize) * pixelUVSize;

    // Ensure we're not sampling outside the texture
    roundedUV = clamp(roundedUV, vec2(0.0), vec2(1.0) - pixelUVSize);

    // Sample the screen texture at the rounded UV coordinates
    COLOR = texture(SCREEN_TEXTURE, roundedUV);
}
