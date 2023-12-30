precision highp float;
uniform int KLOG<
  string widget_type = "slider";
  int minimum = 1;
  int maximum = 8;
  int step=1;
> = 6;
uniform float scaleby<
  string widget_type = "slider";
  float minimum = 0.0;
  float maximum = 3.0;
  float step = 0.01;
> = 0;

float scaleForward_f(in float x, in float f_frac) {
    if (x-0.5 < -1e-8) return (1-f_frac)*x+f_frac*(0.5-sqrt(0.25-x*x));
    if (x-0.5 > +1e-8) return (1-f_frac)*x+f_frac*(0.5+sqrt(0.25-(x-1)*(x-1)));
    return 0.5;
}

float3 scaleForward(in float3 x, in float f_frac) {
    return float3(
        scaleForward_f(x.x, f_frac),
        scaleForward_f(x.y, f_frac),
        scaleForward_f(x.z, f_frac)
    );
}

float3 scaleForward_r(in float3 x) {
    for (int i = 0; i < floor(scaleby); i++) {
        x = scaleForward(x, 1.0);
    }
    float f_frac = scaleby-floor(scaleby);
    if (f_frac > 1e-8) x = scaleForward(x, f_frac);
    return x;
}

float shouldNotNegate(in int val, in int pos, in int n) {
    int nt = 1;
    float sign = 1.0;
    while (n > 0) {
        n >>= 1;
        if (((n & val) > 0) && ((pos & nt) > 0)) {
            sign = -sign;
        }
        nt <<= 1;
    }
    return sign;
}

float4 mainImage(VertData v_in) : TARGET
{
    int ks = 1 << KLOG;
    int kp = ks << KLOG;
    float4 obsTex = image.Sample(textureSampler, v_in.uv);
    float3 colorSum = float3(obsTex.xyz);
    float2 xy = floor(v_in.pos.xy);
    float kernelMult = 1.0 / kp;
    if (v_in.uv.x < 0 || v_in.uv.y < 0 || v_in.uv.x > 1 || v_in.uv.y > 1) return float4(0.0);
    colorSum = float3(0.0);
    float snn_stor;
    float3 nextColor;;
    for (int xi = 0; xi < ks; xi++) {
        snn_stor = shouldNotNegate(xi,int(xy.x),ks);
        for (int yi = 0; yi < ks; yi++) {
            nextColor = image.Load(int3(xi, yi, 0)).xyz;
            colorSum += snn_stor*shouldNotNegate(yi,int(xy.y),ks)*nextColor*kernelMult;
        }
    }
    if (xy.x >= 1.0 || xy.y >= 1.0) {
        colorSum += float3(0.5);
        return float4(scaleForward_r(colorSum), 1.0);
    }
    return float4(colorSum, 1.0);
}
