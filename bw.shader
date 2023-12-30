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

float scaleBack_f(in float x, in float f_frac) {
    if (x-0.5 < -1e-8) return (1-f_frac)*x+f_frac*sqrt(0.25-(x-0.5)*(x-0.5));
    if (x-0.5 > +1e-8) return (1-f_frac)*x+f_frac*(1-sqrt(0.25-(x-0.5)*(x-0.5)));
    return 0.5;
}

float3 scaleBack(in float3 x, in float f_frac) {
    return float3(
        scaleBack_f(x.x, f_frac),
        scaleBack_f(x.y, f_frac),
        scaleBack_f(x.z, f_frac)
    );
}

float3 scaleBack_r(in float3 x) {
    float f_frac = scaleby - floor(scaleby);
    if (f_frac > 1e-8) x = scaleBack(x, f_frac);
    for (int i = 0; i < floor(scaleby); i++) {
        x = scaleBack(x, 1.0);
    }
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
    float3 nextColor;
    for (int xi = 1; xi < ks; xi++) {
        snn_stor = shouldNotNegate(xi,int(xy.x),ks);

        for (int yi = 1; yi < ks; yi++) {
            nextColor = image.Load(int3(xi, yi, 0)).xyz;
            nextColor = scaleBack_r(nextColor);
            nextColor -= float3(0.5);
            colorSum += snn_stor*shouldNotNegate(yi,int(xy.y),ks)*nextColor;
        }
    }
    for (int xi = 1; xi < ks; xi++) {
            nextColor = image.Load(int3(xi, 0, 0)).xyz;
            nextColor = scaleBack_r(nextColor);
            nextColor -= float3(0.5);
            colorSum += shouldNotNegate(xi,int(xy.x),ks)*nextColor;
    }
    for (int yi = 1; yi < ks; yi++) {
            nextColor = image.Load(int3(0, yi, 0)).xyz;
            nextColor = scaleBack_r(nextColor);
            nextColor -= float3(0.5);
            colorSum += shouldNotNegate(yi,int(xy.y),ks)*nextColor;
    }
    nextColor = image.Load(int3(0, 0, 0)).xyz;
    colorSum += nextColor;

    return float4(colorSum, 1.0);
}
