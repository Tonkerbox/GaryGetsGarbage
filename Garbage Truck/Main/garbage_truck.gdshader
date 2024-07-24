shader_type spatial;

uniform sampler2D screenTex : hint_screen_texture, filter_linear;
uniform int pixelSize;

void fragment() {
	float x = float(int(FRAGCOORD.x) % pixelSize);
	float y = float(int(FRAGCOORD.y) % pixelSize);
	
	x = FRAGCOORD.x + floor(float(pixelSize) / 2.0) - x;
	y = FRAGCOORD.y + floor(float(pixelSize) / 2.0) - y;
	
	ALBEDO = texture(screenTex, vec2(x, y) / VIEWPORT_SIZE).xyz;
}
