uniform float power<
    string label = "Power";
    string widget_type = "slider";
    float minimum = 5.0;
    float maximum = 200.0;
    float step = 5;
> = 0.01;
uniform float gamma<
    string label = "Gamma";
    string widget_type = "slider";
    float minimum = 0.1;
    float maximum = 3.0;
    float step = 0.01;
> = 2.2;
uniform int num_iter<
    string label = "Number iterations";
    string widget_type = "slider";
    int minimum = 3;
    int maximum = 25;
    int step = 1;
> = 5;
uniform int directions<
    string label = "Num Directions";
    string widget_type = "slider";
    int minimum = 3;
    int maximum = 25;
    int step = 1;
> = 16;
uniform float alphabright<
    string label = "Opacity";
    string widget_type = "slider";
    float minimum = -1.0;
    float maximum = 1.0;
    float step = 0.05;
> = -0.5;
uniform float alphacont<
    string label = "Opacity Multiplier";
    string widget_type = "slider";
    float minimum = -3.0;
    float maximum = 3.0;
    float step = 0.05;
> = 2.5;

#define PI 3.14159265358979323


float3 lin2srgb(float3 c)
{
    return pow(c, float3(gamma, gamma, gamma));
}

float3 srgb2lin(float3 c)
{
    return pow(c, float3(1.0/gamma, 1.0/gamma, 1.0/gamma));
}

float3 spectrum_offset_rgb(float t)
{
    float t0 = 3.0 * t - 1.5;
    float3 ret = clamp(float3(-t0, 1.0-abs(t0), t0), 0.0, 1.0);
    return ret;
}

float3 spectrum_offset(float t)
{
    return spectrum_offset_rgb(t);
}

float2 distort(float2 coord, float amt, float2 min_distort, float2 max_distort, float theta) {
    float2 distort = min_distort + amt * (max_distort - min_distort);
    return coord + distort * float2(cos(theta), sin(theta));
}

float4 mainImage(VertData v_in) : TARGET
{
    float4 original = image.Sample(textureSampler, v_in.uv);
    float3 sumcol = float3(0.0, 0.0, 0.0);
    float3 sumw = float3(0.0, 0.0, 0.0);
    float2 max_distort = float2(power, power) * uv_pixel_interval;
    float2 min_distort = max_distort / num_iter;
    int num_dir = (directions & 1) + (directions & 2) + (directions & 4) + (directions & 8);
    float stepsize = 1.0 / (float(num_iter)-1.0);
    float colSumA = 0;
    float t = 0;
    for (int i=0; i<num_iter; i++) {
        float3 w = spectrum_offset(t);
        float3 col = float3(0.0, 0.0, 0.0);
        for (int d = 0; d < directions; d++) {
            float4 sample = image.Sample(textureSampler, distort(v_in.uv, t, min_distort, max_distort, 2 * PI * float(d) / float(directions)));
            sumcol += srgb2lin(sample.rgb) * w;
            colSumA += sample.a;
            sumw += w;
        }
        t += stepsize;
    }

    float3 outcol = original.rgb;
    outcol = sumcol.rgb / sumw;
    outcol = lerp(lin2srgb(outcol), original.rgb, original.a);
    float al = alphabright+exp(alphacont)*colSumA/float(num_iter * directions);
    al = max(al, original.a);
    return float4(outcol, al);
    return image.Sample(textureSampler, v_in.uv);
}
