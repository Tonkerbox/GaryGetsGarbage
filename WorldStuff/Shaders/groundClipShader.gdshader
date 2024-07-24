shader_type spatial;

global uniform sampler2D heightMap;
global uniform sampler2D normalMap;
global uniform float amplitude;
uniform sampler2D baseTex;
uniform sampler2D secondTex;
uniform sampler2D thirdTex;
uniform vec2 scale;
uniform sampler2D mixNoise;
uniform sampler2D secondMixNoise;

varying vec2 texPos;

void vertex(){
	vec3 worldVert = VERTEX + MODEL_MATRIX[3].xyz;
	texPos = (worldVert.xz + .5)/float(textureSize(heightMap, 0).x);
	VERTEX.y = texture(heightMap, texPos).r * amplitude;
}

void fragment(){
	vec2 scaledPos = texPos * scale;
	vec2 wrappedPos = mod(scaledPos, 1.0);

	ivec2 texSize = textureSize(baseTex, 0);
	ivec2 texCoords = ivec2(wrappedPos * vec2(texSize));

	vec4 groundColor1 = texelFetch(baseTex, ivec2(wrappedPos * scale), 0);
	vec4 groundColor2 = texelFetch(secondTex, ivec2(wrappedPos * scale), 0);
	vec4 groundColor3 = texelFetch(thirdTex, ivec2(wrappedPos * scale), 0);

	vec4 mixedTex1Pass = mix(groundColor1, groundColor2, texture(mixNoise, texPos));
	vec4 mixedTex = mix(mixedTex1Pass, groundColor3, texture(secondMixNoise, texPos));

	ALBEDO = mixedTex.rgb;
	NORMAL_MAP = texture(normalMap, texPos).rgb;
}