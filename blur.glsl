// This shader is only here to help you understand how a very basic box blur works.
// It should not be used as it's fairly inefficient and doesn't look as good as
// a gaussian blur. Look at the "Blur (convoluted)" examples instead.

#define BLUR_RADIUS 3.0
#define SAMPLE_RANGE 3
#define SAMPLE_RANGE_FLOAT 3.0
vec4 effect(vec4 color, Image currentTexture, vec2 texCoords, vec2 screenCoords){
  vec4 sum = vec4(0);
  for(int x = -SAMPLE_RANGE; x < SAMPLE_RANGE + 1; x++){
    for(int y = -SAMPLE_RANGE; y < SAMPLE_RANGE + 1; y++){
      // textureOffset
      sum += Texel(currentTexture, texCoords + BLUR_RADIUS*vec2(x, y)/love_ScreenSize.xy);
    }
  }
  sum = sum/(2.0*SAMPLE_RANGE_FLOAT*2.0*SAMPLE_RANGE_FLOAT);
  return sum;
}