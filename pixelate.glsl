// pixelation shader by Charles Fettinger for obs-shaderfilter plugin 3/2019
// with help from SkeltonBowTV
// https://github.com/Oncorporation/obs-shaderfilter
uniform float Target_Width = 20;
uniform float Target_Height = 20;
//uniform string notes = "adjust width and height to your screen dimension";

float4 render(float2 uv)
{
	float targetWidth = max(2.0, Target_Width);
	float targetHeight = max(2.0, Target_Height);

	float2 tex1;
	int pixelSizeX = Target_Width;//builtin_uv_size.x / targetWidth;
	int pixelSizeY = targetHeight;//builtin_uv_size.y / targetHeight;

	int pixelX = uv.x * builtin_uv_size.x;
	int pixelY = uv.y * builtin_uv_size.y;

	tex1.x = (((pixelX / pixelSizeX)*pixelSizeX) / builtin_uv_size.x) + (pixelSizeX / builtin_uv_size.x)/2;
	tex1.y = (((pixelY / pixelSizeY)*pixelSizeY) / builtin_uv_size.y) + (pixelSizeY / builtin_uv_size.y)/2;

	float4 c1 = image.Sample(builtin_texture_sampler, tex1);

	return c1;
}