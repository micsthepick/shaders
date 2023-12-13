uniform float scale = 1;
uniform float Fx = 0;
uniform float Fy = 0;
uniform float sx = 1;
uniform float sy = 1;
uniform float a = 1;
uniform float b = 1;

float4 render(float2 uv)
{
    float2 uvadj = 2 * uv - 1;
    uvadj /= float2(sx * a, sy * b);
    float2 vMapping = uvadj;
    vMapping -= float2(uvadj.y*uvadj.y*uvadj.x*Fx, uvadj.x*uvadj.x*uvadj.y*Fy)/(scale*scale)*0.01;
    vMapping *= float2(a, b) / scale;
    return image.Sample(builtin_texture_sampler, vMapping*0.5 + 0.5);
}