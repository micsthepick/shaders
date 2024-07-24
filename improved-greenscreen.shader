// Adapted from https://godotshaders.com/shader/green-screen-chromakey/ by BlueMoon_Coder
//uniforms
uniform float3 triplet_key_color<
	string label = "key color (screen)";
	float3 minimum = {0.0, 0.0, 0.0};
	float3 maximum = {1.0, 1.0, 1.0};
	float3 step = {0.001, 0.001, 0.001};
> = {0.0, 0.0, 0.0};

uniform float triplet_similarity<
	string label = "similarity";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0.0;
	float maximum = 4.0;
> = 0.75;

uniform float smoothness<
	string label = "smoothness";
	float step = 0.001;
	float minimum = 0.0;
	float maximum = 4.0;
	string widget_type = "slider";
> = 0.008;

uniform float spill<
	string label = "spill reduction";
	float step = 0.001;
	float minimum = 0.0;
	float maximum = 3.0;
	string widget_type = "slider";
> = 0.0;

uniform float3 triplet_strength<
	string label = "strength";
	string widget_type = "slider";
	float3 minimum = {0.0, 0.0, 0.0};
	float3 maximum = {1.0, 1.0, 1.0};
	float3 step = {0.005, 0.005, 0.005};
> = {0.25., 1.0., 1.0};

uniform int cp<
	string label = "Color mode";
	string widget_type = "select";
	int option_0_value = 0;
	int option_1_value = 1;
	int option_2_value = 2;
	int option_3_value = 3;
	int option_4_value = 4;
	int option_5_value = 5;
	string option_0_label = "Off";
	string option_1_label = "YUV";
	string option_2_label = "YPrPg";
	string option_3_label = "YPbPr";
	string option_4_label = "greenscreen optimized (YCoCg)";
	string option_5_label = "bluescreen optimized";
> = 2;

uniform int color_solo<
	string label = "Color solo";
	string widget_type = "select";
	int option_0_value = 0;
	int option_1_value = 1;
	int option_2_value = 2;
	int option_3_value = 3;
	string option_0_label = "Regular";
	string option_1_label = "Solo luma";
	string option_2_label = "solo component 1";
	string option_3_label = "solo component 2";
> = 0;

uniform int color_channel<
	string label = "Color channel";
	string widget_type = "select";
	int option_0_value = 0;
	int option_1_value = 1;
	int option_2_value = 2;
	int option_3_value = 3;
	int option_4_value = 4;
	string option_0_label = "All";
	string option_1_label = "luma";
	string option_2_label = "component 1";
	string option_3_label = "component 2";
	string option_4_label = "Out Alpha";
> = 0;

float RGBtoY(float3 c) {
	return c.r * 0.25 + c.g * 0.5 + c.b * 0.25;
}

// from wikipedia
float3 RGB2Y_Co_Cg(float3 c) {
  return float3(
       RGBtoY(c),
       c.r * 0.5              - c.b * 0.5 + 0.5,
      -c.r * 0.25 + c.g * 0.5 - c.b * 0.25 + 0.5
  );
}

float3 XYZ2blue(float3 c) {
	return float3(
		RGBtoY(c),
		c.g * 0.6666666 - c.r * 0.3333333 + 0.3333333,
		+c.r * 0.25 + c.g * 0.5 - c.b * 0.25 + 0.25
	);
}

float3 mix(float3 rgbA, float3 rgbB, float fract) {
	return rgbA + (rgbB - rgbA) * float3(fract, fract, fract);
}

// same as OBS's Filter
float3 RGB2YUV(float3 rgb) {
    return float3(
    rgb.x *  0.182586 + rgb.y *  0.614231 + rgb.z *  0.062007 + 0.062745,
    rgb.x *  0.439216 + rgb.y * -0.398942 + rgb.z * -0.040274 + 0.501961,
    rgb.x * -0.100644 + rgb.y * -0.338572 + rgb.z *  0.439216 + 0.501961
  );
}

float RGB2YPbPrY(float3 rgb) {
    return 0.2126 * rgb.r + 0.7152 * rgb.g + 0.0722 * rgb.b;
}

float3 RGB2YPbPr(float3 rgb) {
    float y = RGB2YPbPrY(rgb);
    return float3(y, 0.5 + 0.5*(rgb.b - y), 0.5 + 0.5*(rgb.r - y));
}


float3 RGB2YPrPg(float3 rgb) {
    float y = RGB2YPbPrY(rgb);
    return float3(y, 0.5 + 0.5*(rgb.r - y), 0.5 + 0.5*(rgb.g - y));
}

float4 mainImage(VertData v_in) : TARGET
{
	float4 rgba = image.Sample(textureSampler, v_in.uv);
	float3 oldrgb = rgba.rgb;
	float val = 255.0;
	float3 bias = float3(val, val, val);
	if (1 == color_solo) {
		bias = float3(val, 0, 0);
	}
	if (2 == color_solo) {
		bias = float3(0, val, 0);
	}
	if (3 == color_solo) {
		bias = float3(0, 0, val);
	}
	float3 xyz = rgba.rgb;
	float3 diff = bias;
	float3 keycolor_converted = float3(0.0, 0.0, 0.0);
	if (1 == cp) {
		xyz = RGB2YUV(xyz);
		keycolor_converted = RGB2YUV(triplet_key_color);
		diff *= (xyz - keycolor_converted);
	}
	if (2 == cp) {
		xyz = RGB2YPrPg(xyz);
		keycolor_converted = RGB2YPrPg(triplet_key_color);
		diff *= (xyz - keycolor_converted);
	}
	if (3 == cp) {
		xyz = RGB2YPbPr(xyz);
		keycolor_converted = RGB2YPbPr(triplet_key_color);
		diff *= (xyz - keycolor_converted);
	}
	if (4 == cp) {
		xyz = RGB2Y_Co_Cg(xyz);
		keycolor_converted = RGB2Y_Co_Cg(triplet_key_color);
		diff *= (xyz - keycolor_converted);
	}
	if (5 == cp) {
		xyz = XYZ2blue(xyz);
		keycolor_converted = XYZ2blue(triplet_key_color);
		diff *= (xyz - keycolor_converted);
	}
	float3 dist = diff * diff;

	float3 baseMask = dist * triplet_strength - bias * triplet_similarity * dot(triplet_strength, triplet_strength);
	
	float maskVal = (baseMask.x + baseMask.y + baseMask.z + 0.00000001);
	
	float fullMask = maskVal / (smoothness * val + 0.00000001);
	rgba.a *= clamp(fullMask, 0., 1.);;

	float spillVal = clamp(fullMask-spill, 0., 1.);
	float desat = clamp(RGBtoY(rgba.rgb), 0., 1.);
	rgba.rgb = mix(float3(desat, desat, desat), rgba.rgb, spillVal);

	if (0 == cp) {
		rgba.rgb = oldrgb;
		rgba.a = 1;
	}
	if (1 == color_channel) {
		rgba.rgb = xyz.xxx * triplet_strength.xxx;
		rgba.a = 1;
	}

	if (2 == color_channel) {
		rgba.rgb = xyz.yyy * triplet_strength.yyy;
		rgba.a = 1;
	}

	if (3 == color_channel) {
		rgba.rgb = xyz.zzz * triplet_strength.zzz;
		rgba.a = 1;
	}

	if (4 == color_channel) {
		rgba.rgb = rgba.aaa;
		rgba.a = 1;
	}

	return rgba;
	return image.Sample(textureSampler, v_in.uv);
}
