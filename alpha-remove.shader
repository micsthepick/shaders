uniform float4 bgcolor = {1.0, 1.0, 1.0, 1.0};

float4 mainImage(VertData v_in) : TARGET
{
    float4 rgba = image.Sample(textureSampler, v_in.uv);
    return float4(lerp(bgcolor.rgb, rgba.rgb, rgba.a), 1.0);
}