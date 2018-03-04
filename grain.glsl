
uniform float iTime;   // shader playback time (in seconds)
uniform float strength = 10.0; 

vec4 effect(vec4 color, sampler2D texture, vec2 texCoords, vec2 screenCoords) {
	
	vec2 uv = screenCoords.xy / love_ScreenSize.xy;
	vec4 texColor = texture2D(texture, texCoords);

	float x = (uv.x + 4.0 ) * (uv.y + 4.0 ) * (iTime * 10.0);
	vec4 grain = vec4(mod((mod(x, 13.0) + 1.0) * (mod(x, 123.0) + 1.0), 0.01)-0.005) * strength;
    
    texColor = texColor + grain;
	
	return texColor * color;
}
