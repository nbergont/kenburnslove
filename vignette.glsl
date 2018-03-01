
vec4 effect(vec4 color, Image currentTexture, vec2 texCoords, vec2 screenCoords){
	float dist = distance(texCoords, vec2(.5, .5));
	//return vec4(color.zyz, 1.0 - smoothstep(.6, .2, dist));
	return color * (1.0-smoothstep(0.9, .35, dist));
}