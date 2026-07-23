if SERVER then return end
zclib = zclib or {}
zclib.Blendmodes = zclib.Blendmodes or {}

/*
	In order to simulate a blend mode we change the color src and dest
	BlendModes:
		Additive:[srcBlend = BLEND_SRC_ALPHA, destBlend = BLEND_ONE, blendFunc = BLENDFUNC_ADD]
		Multiply:[srcBlend = BLEND_DST_COLOR, destBlend = BLEND_ZERO, blendFunc = BLENDFUNC_ADD]
*/

/*
	NOTE OpenGL doesent support the Overlay Blendmode by default and im not gonna write a custom shader, fuck that.
	So using 2 masks with one being inverted and blending both using Multiply on to the basetexture seems close enough
*/

zclib.Blendmodes.List = {
	[0] = {
		name = "Normal",
	},
	["Additive"] = {
		name = "Additive",
		srcBlend = BLEND_SRC_ALPHA,
		destBlend = BLEND_ONE,
		blendFunc = BLENDFUNC_ADD,
		srcBlendAlpha = BLEND_ONE,
		destBlendAlpha = BLEND_ZERO,
		blendFuncAlpha = BLENDFUNC_ADD
	},
	["Multiply"] = {
		name = "Multiply",
		srcBlend = BLEND_DST_COLOR,
		destBlend = BLEND_ONE_MINUS_SRC_ALPHA,
		blendFunc = BLENDFUNC_ADD,
		srcBlendAlpha = BLEND_ONE,
		destBlendAlpha = BLEND_ZERO,
		blendFuncAlpha = BLENDFUNC_ADD
	},
	["Lighten"] = {
		name = "Lighten",
		srcBlend = BLEND_SRC_ALPHA,
		destBlend = BLEND_ONE,
		blendFunc = BLENDFUNC_MAX,
		srcBlendAlpha = BLEND_ONE,
		destBlendAlpha = BLEND_ZERO,
		blendFuncAlpha = BLENDFUNC_ADD
	},
	["Difference"] = {
		name = "Difference",
		srcBlend = BLEND_ONE,
		destBlend = BLEND_ONE,
		blendFunc = BLENDFUNC_SUBTRACT,
		srcBlendAlpha = BLEND_ONE,
		destBlendAlpha = BLEND_ZERO,
		blendFuncAlpha = BLENDFUNC_ADD
	},
	["StraightAlpha"] = {
		name = "StraightAlpha",
		srcBlend = BLEND_SRC_ALPHA,
		destBlend = BLEND_ONE_MINUS_SRC_ALPHA,
		blendFunc = BLENDFUNC_ADD,
		srcBlendAlpha = BLEND_ONE,
		destBlendAlpha = BLEND_ONE_MINUS_SRC_ALPHA,
		blendFuncAlpha = BLENDFUNC_ADD
	},
	["Darken"] = {
		name = "Darken",
		srcBlend = BLEND_ONE,
		destBlend = BLEND_ONE,
		blendFunc = BLENDFUNC_MIN,
		srcBlendAlpha = BLEND_ONE,
		destBlendAlpha = BLEND_ZERO,
		blendFuncAlpha = BLENDFUNC_ADD
	},
}

/*
	Handels the blending of surface calls
*/
function zclib.Blendmodes.Blend(mode,keepalpha,func)
	local bm = zclib.Blendmodes.List[mode]

	if keepalpha then
		render.OverrideBlend(true, bm.srcBlend, bm.destBlend, bm.blendFunc, BLEND_ZERO, BLEND_DST_ALPHA, BLENDFUNC_ADD)
	else
		render.OverrideBlend(true, bm.srcBlend, bm.destBlend, bm.blendFunc, bm.srcBlendAlpha, bm.destBlendAlpha, bm.blendFuncAlpha)
	end
	pcall(func)
	render.OverrideBlend(false)
end
