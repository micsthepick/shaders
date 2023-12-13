// Adapted from https://godotshaders.com/shader/green-screen-chromakey/ by BlueMoon_Coder

#pragma shaderfilter set key_color__description Key Color
#pragma shaderfilter set key_color__default 7FFF00FF
uniform float4 key_color;
uniform int similarity = 40;
uniform int smoothness = 8;
uniform int spill = 10;
uniform int bias = 0;
uniform int luma_limit = 10;
uniform float p = 1.5;

float3 mix(float3 rgb1, float3 rgb2, float frac) {
  return rgb1 + (rgb2 - rgb1) * frac;
}

// Adapted From https://github.com/obsproject/obs-studio/blob/master/plugins/obs-filters/data/chroma_key_filter.effect
float2 RGBtoUV(float3 rgb) {
  return float2(
    (rgb.x * -0.100644 + rgb.y * -0.338572 + rgb.z *  0.439216 + 0.501961) * exp( bias * 0.001),
    (rgb.x *  0.439216 + rgb.y * -0.398942 + rgb.z * -0.040274 + 0.501961) * exp(-bias * 0.001)
  );
}

float RGBtoY(float3 rgb) {
  return rgb.x * 0.182586 + rgb.y * 0.614231 + rgb.z * 0.062007 + 0.062745;
}

float4 render(float2 texCoord) {
  float4 rgba = image.Sample(builtin_texture_sampler, texCoord);
  float chromaDist = distance(RGBtoUV(rgba.xyz), RGBtoUV(key_color.xyz));
  
  float lumaDist = abs(RGBtoY(rgba.rgb) - RGBtoY(key_color));

  float baseMask = chromaDist - similarity * 0.001;
  float lumaMask = 1 - clamp(luma_limit * 0.001 - lumaDist, 0., 1.);
  
  float fullMask = pow(clamp(baseMask * lumaMask / smoothness * 1000, 0., 1.), p);
  rgba.a = fullMask;

  float spillVal = pow(clamp(baseMask / spill * 1000, 0., 1.), p);
  float desat = clamp(rgba.x * 0.2126 + rgba.y * 0.7152 + rgba.z * 0.0722, 0., 1.);
  rgba.xyz = mix(float3(desat, desat, desat), rgba.xyz, spillVal);

  return rgba;
}