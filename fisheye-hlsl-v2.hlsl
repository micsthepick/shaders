uniform int center_x_percent = 50;
uniform int center_y_percent = 50;
uniform float warp_x = 0.1;
uniform float warp_y = 0.1;
uniform float stretch_x = 0.1;
uniform float stretch_y = 0.1;
uniform float power = 0;

float4 mainImage(VertData v_in) : TARGET
{
    float2 center_pos = float2(center_x_percent * .01, center_y_percent * .01);
    float2 uv = v_in.uv;
    float2 war_uv = float2(warp_x*10, warp_y*10);
    float2 st_uv = float2(stretch_x*10, stretch_y*10) * war_uv;
    if (power >= 0.0001){
        float b = sqrt(dot(center_pos, center_pos));
        uv = center_pos + st_uv * normalize(v_in.uv - center_pos) * tan(distance(center_pos, v_in.uv) * power / war_uv) * b / tan( b * power);
    } else if(power <= -0.0001){
        float b = sqrt(dot(center_pos, center_pos));
        uv = center_pos + st_uv * normalize(v_in.uv - center_pos) * atan(distance(center_pos, v_in.uv) * -power * 10.0 / war_uv) * b / atan(-power * b * 10.0);
    }
    return image.Sample(textureSampler, uv);
}