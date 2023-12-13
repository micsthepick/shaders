uniform int center_x_percent = 50;
uniform int center_y_percent = 50;
uniform float power_x = 10;
uniform float power_y = 10;
uniform float scale_x = 10;
uniform float scale_y = 10;
uniform bool inverse = true;

/*
   Adapted from: https://github.com/exeldro/obs-lua/fisheye.shader
   
   Slightly changed the code to run with "OBS ShaderFilter Plus" plugin.
   OBS ShaderFilter Plus supports both: Windows and Linux.
*/

float4 render(float2 uv) {
    float2 scale = float2(scale_x, scale_y) * 0.1;
    float2 center_pos = float2(center_x_percent, center_y_percent) * .01;
    float2 uv_scaled = (uv - center_pos) / scale + center_pos;
    float2 power = float2(power_x, power_y) * 0.1;
    float b = 0.0;
    if (!inverse){
        b = sqrt(dot(center_pos, center_pos));
    }else {
        if (builtin_uv_size.x < builtin_uv_size.y){
            b = center_pos.x;
        }else{
            b = center_pos.y;
        }
    }
    float2 uvFinal;
    if (!inverse)
        uvFinal = center_pos  + normalize(uv_scaled - center_pos) * tan(distance(center_pos, uv_scaled) * power) * b / tan( b * power);
    else if (inverse)
        uvFinal = center_pos  + normalize(uv_scaled - center_pos) * atan(distance(center_pos, uv_scaled) * -power) * b / atan(-power * b);
    //else 
    //    uvFinal = uv;
    return image.Sample(builtin_texture_sampler, uvFinal);
}