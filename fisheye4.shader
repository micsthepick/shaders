uniform int center_x_percent = 50;
uniform int center_y_percent = 50;
uniform float power_x<
  string widget_type = "slider";
  float minimum = 0.01;
  float maximum = 5.0;
  float step = 0.01;
> = 1.0;
uniform float power_y<
  string widget_type = "slider";
  float minimum = 0.01;
  float maximum = 5.0;
  float step = 0.01;
> = 1.0;
uniform float scale_x<
  string widget_type = "slider";
  float minimum = 0.01;
  float maximum = 5.0;
  float step = 0.01;
> = 1.0;
uniform float scale_y<
  string widget_type = "slider";
  float minimum = 0.01;
  float maximum = 5.0;
  float step = 0.01;
> = 1.0;
uniform bool inverse = true;

/*
   Adapted from: https://github.com/exeldro/obs-lua/fisheye.shader
   
   Slightly changed the code to run with "OBS ShaderFilter Plus" plugin.
   OBS ShaderFilter Plus supports both: Windows and Linux.
*/

float4 mainImage(VertData v_in) : TARGET
{
    float2 scale = float2(scale_x, scale_y);
    float2 center_pos = float2(center_x_percent, center_y_percent) * .01;
    float2 uv_scaled = (v_in.uv - center_pos) / scale + center_pos;
    float2 power = float2(power_x, power_y);
    float2 center_offset = center_pos - 0.5;
    float b = sqrt(dot(center_pos, center_pos));
    float2 uvFinal;
    if (!inverse)
        uvFinal = center_pos  + (uv_scaled - center_pos) * atan(distance(center_pos, uv_scaled) * power) * b / tan( b * abs(power));
    else if (inverse)
        uvFinal = center_pos  + (uv_scaled - center_pos) * tan(distance(center_pos, uv_scaled) * power) * b / atan(b * abs(power));
    //else 
    //    uvFinal = uv;
    return image.Sample(textureSampler, uvFinal);
}