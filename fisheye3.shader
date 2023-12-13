uniform float scale = 1;
uniform float F1x = 0;
uniform float F1y = 0;
uniform float F2x = 0;
uniform float F2y = 0;
uniform float sx = 1;
uniform float sy = 1;
uniform float a = 1;
uniform float b = 1;
uniform float cc = 0;

float4 render(float2 uv)
{
    float bb = sqrt(0.5);
    float2 power1 = float2(F1x, F1y) * 0.1;
    float2 power2 = float2(F2x, F2y) * 0.1;
    float2 signPower1 = abs(power1) < 0.0005;
    power2 *= pow(abs(power1)+signPower1,cc);
    float2 uvadj = 2 * uv - 1;
    uvadj /= float2(sx * a / scale, sy * b / scale);
    uvadj = normalize(uvadj) * (
        distance(uvadj, 0) * signPower1
        + (atan(distance(uvadj, 0) * power1 * bb)) / (atan(power1 * bb) + signPower1)
    );
    // * atan(distance(center_pos, uv_scaled) * -power) * b / atan(-power * b);
    float2 vMapping = uvadj;
    vMapping -= float2(uvadj.y*uvadj.y*uvadj.x, uvadj.x*uvadj.x*uvadj.y)*power2/(scale*scale);
    vMapping *= float2(a, b) / scale;
    return image.Sample(builtin_texture_sampler, vMapping * 0.5 + 0.5);
}