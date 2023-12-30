precision highp float;
uniform int KLOG<
  string widget_type = "slider";
  int minimum = 1;
  int maximum = 8;
  int step=1;
> = 6;
uniform int direction<
    string label = "Direction";
    string widget_type = "select";
    int option_0_value = 0;
    string option_0_label = "Horizontal";
    int option_1_value = 1;
    string option_1_label = "Vertical";
> = 0;
uniform bool inverse = false;


float4 fft (
  sampler2D src,
  VertData v_in,
  float2 resolution,
  float subtransformSize,
  bool horizontal,
  bool forward
) {
  const float TWOPI = 6.283185307179586;
  const float PI2 = 1.5707963267948966;

  float2 twiddle;
  float4 rePos, imPos, evenVal, oddRe, oddIm;;
  float index, evenIndex, twiddleArgument;

  float2 pos = v_in.uv * resolution;
  bool real = (horizontal ? pos.y : pos.x) < 0.5;

  index = (horizontal ? pos.x : v_in.uv.y) - 0.5;

  evenIndex = floor(index / subtransformSize) *
    (subtransformSize * 0.5) +
    mod(index, subtransformSize * 0.5) +
    0.5;

  if (horizontal) {
    rePos = float4(evenIndex, v_in.uv.y, evenIndex, v_in.uv.y);
  } else {
    rePos = float4(pos.x, evenIndex, v_in.uv.x, evenIndex);
  }

  rePos *= resolution.xyxy;

  if (horizontal) {
    rePos.z += 0.5;
  } else {
    rePos.w += 0.5;
  }

  imPos = rePos;

  if (horizontal) {
    if (real) {
      imPos.yw += 0.5;
    } else {
      rePos.yw -= 0.5;
    }
  } else {
    if (real) {
      imPos.xz += 0.5;
    } else {
      rePos.xz -= 0.5;
    }
  }

  evenVal = texture2D(src, real ? rePos.xy : imPos.xy);
  oddRe = texture2D(src, rePos.zw);
  oddIm = texture2D(src, imPos.zw);

  twiddleArgument = (forward ? TWOPI : -TWOPI) * (index / subtransformSize);
  if (!real) twiddleArgument -= PI2;
  twiddle = float2(cos(twiddleArgument), sin(twiddleArgument));

  return evenVal + twiddle.x * oddRe + -twiddle.y * oddIm;
}

float4 mainImage(VertData v_in) : TARGET
{
  return float4(fft(image, v_in, uv_size, 1 << KLOG, (direction == 0), !inverse).xyz, 1.0);
};