// pixelization shader by micsthepick for obs-shaderfilter plugin 5/2022
// https://github.com/Oncorporation/obs-shaderfilter

uniform int dx = 20;
uniform int dy = 20;
uniform int ox = 0;
uniform int oy = 0;
uniform int sx = 0;
uniform int sy = 0;
uniform int ex = 60;
uniform int ey = 60;

float4 render(float2 uv)
{
	uint divisor = dx * dy;
	float2 tex1;

	int pixelX = uv.x * builtin_uv_size.x;
	int pixelY = uv.y * builtin_uv_size.y;

	int startX = min(builtin_uv_size.x, max(0.0, sx));
	int startY = min(builtin_uv_size.y, max(0.0, sy));

	int endX = min(builtin_uv_size.x, max(0.0, ex));
	int endY = min(builtin_uv_size.y, max(0.0, ey));

	tex1.x = ((pixelX - ox) / dx)*dx + ox;
	tex1.y = ((pixelY - oy) / dy)*dy + oy;
	
	
	float4 c1;

	c1.x = 0;
	c1.y = 0;
	c1.z = 0;
	c1.w = 0;

	for (int xv = 0; xv < dx; xv++) {
		for (int yv = 0; yv < dy; yv++) {
			float2 tex2;
			tex2.x = tex1.x + xv;
			tex2.y = tex1.y + yv;
			tex2.x /= builtin_uv_size.x;
			tex2.y /= builtin_uv_size.y;
			tex2.x = min(1.0 - 1 / builtin_uv_size.x, max(0.0, tex2.x));
			tex2.y = min(1.0 - 1 / builtin_uv_size.y, max(0.0, tex2.y));
			c1 += image.Sample(builtin_texture_sampler, tex2);
		}
	}
	
	c1 /= divisor;

	c1.w = 1;

	uint cond = !(startX <= pixelX && pixelX < endX && startY <= pixelY && pixelY < endY);

	c1 += cond * (image.Sample(builtin_texture_sampler, uv) - c1);

	return c1;
}