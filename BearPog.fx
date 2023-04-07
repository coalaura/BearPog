//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Laura's epic shader (called BearPog cause idfk)
// Copyright © 2023 coalaura
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#include "ReShade.fxh"

uniform int UIHELP <
	ui_type = "radio";
	ui_label = " ";
	ui_text = "\nDis shater wil make yuo get all the killz in arena, it wil make youre aim 10000 much better.\n";
>;

uniform bool BearStretchRes <
	ui_label = "Stretch-Res";
	ui_tooltip = "Make yuor aim even more better";
> = false;

uniform float BearScaleFactor <
	ui_type = "slider";
	ui_label = "Scale Factor";
	ui_tooltip = "Mmmmmhhhhh gimme dat pixel goodness";
	ui_min = 1.0;
	ui_max = 3.0;
	ui_step = 0.1;
	ui_spacing = 2.0;
> = 1.0;

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

float4 _sharpen(float2 tex : TEXCOORD0, float amount)
{
	float dx = amount / BUFFER_WIDTH;
	float dy = amount / BUFFER_HEIGHT;

	float val0 = 2.0;
	float val1 = -0.125;

	float4 c1 = tex2D(ReShade::BackBuffer, tex + float2(-dx, -dy)) * val1;
	float4 c2 = tex2D(ReShade::BackBuffer, tex + float2(  0, -dy)) * val1;
	float4 c3 = tex2D(ReShade::BackBuffer, tex + float2(-dx,   0)) * val1;
	float4 c4 = tex2D(ReShade::BackBuffer, tex + float2( dx,   0)) * val1;
	float4 c5 = tex2D(ReShade::BackBuffer, tex + float2(  0,  dy)) * val1;
	float4 c6 = tex2D(ReShade::BackBuffer, tex + float2( dx,  dy)) * val1;
	float4 c7 = tex2D(ReShade::BackBuffer, tex + float2(-dx, +dy)) * val1;
	float4 c8 = tex2D(ReShade::BackBuffer, tex + float2(+dx, -dy)) * val1;
	float4 c9 = tex2D(ReShade::BackBuffer, tex) * val0;

	float4 c0 = (c1 + c2 + c3 + c4 + c5 + c6 + c7 + c8 + c9);

	return c0;
}

void _saturate(inout float4 color, float amount)
{
	float gray = 0.2989 * color.x + 0.5870 * color.y + 0.1140 * color.z;

	color.x = -gray * amount + color.x * (1.0 + amount);
	color.y = -gray * amount + color.y * (1.0 + amount);
	color.z = -gray * amount + color.z * (1.0 + amount);
}

void _brightness(inout float4 color, float amount)
{
	float gray = 1.0 - (0.2989 * color.x + 0.5870 * color.y + 0.1140 * color.z);

	amount *= 1.0 - sqrt(1.0 - pow(gray, 6.0));

	color.x = clamp(color.x + amount, 0.0, 1.0);
	color.y = clamp(color.y + amount, 0.0, 1.0);
	color.z = clamp(color.z + amount, 0.0, 1.0);
}

void _contrast(inout float4 color, float amount)
{
	float intercept = 0.5 * (1.0 - amount);

	color.x = clamp(color.x * amount + intercept, 0.0, 1.0);
	color.y = clamp(color.y * amount + intercept, 0.0, 1.0);
	color.z = clamp(color.z * amount + intercept, 0.0, 1.0);
}

void BearPogPS(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 res : SV_Target0)
{
	float scaleFactor = BUFFER_HEIGHT / (300.0 / BearScaleFactor);

	if (BearStretchRes) {
		texcoord.x = (texcoord.x * 0.76) + 0.12;
	}

	float x = floor(floor(texcoord.x * BUFFER_WIDTH) / scaleFactor) * scaleFactor / BUFFER_WIDTH;
	float y = floor(floor(texcoord.y * BUFFER_HEIGHT) / scaleFactor) * scaleFactor / BUFFER_HEIGHT;

	texcoord.x = x;
	texcoord.y = y;

	float4 color = _sharpen(texcoord.xy, 4.0);

	_saturate(color, 2.3);

	_brightness(color, 0.35);

	_contrast(color, 1.75);

	_brightness(color, 0.15);

	res.xyz = color.xyz;
	res.w = 1.0;
}

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

technique BearPog
{
	pass BearPog_Apply
	{
		VertexShader = PostProcessVS;
		PixelShader = BearPogPS;
	}
}
