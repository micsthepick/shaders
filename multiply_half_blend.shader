uniform texture2d other;
uniform float scaleby<
  string widget_type = "slider";
  float minimum = 0.0;
  float maximum = 5.0;
  float step = 0.01;
> = 1.0;

float max3 (float3 v) {
  return max(max (v.x, v.y), v.z);
}

float4 mainImage(VertData v_in) : TARGET
{
    float4 otherTex = other.Sample(textureSampler, v_in.uv);
    float4 obsTex = image.Sample(textureSampler, v_in.uv);
    float3 obsBands = (obsTex.xyz)*2-1;
    float3 otherBands = (otherTex.xyz)*2-1;
    if ((v_in.uv.x <= uv_pixel_interval.x) && (v_in.uv.y <= uv_pixel_interval.y)) {
        return float4(obsTex.xyz, 1.0);
    }
    float3 yn = (obsBands*obsBands);
    float3 cn = (otherBands*otherBands);
    float3 colorOut = obsBands*cn/((cn+yn*scaleby)*otherBands)*0.5+0.5;
    return float4(colorOut, 1.0);
}
