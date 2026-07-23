if SERVER then return end

// Blues Masks and Shadows
//https://forum.facepunch.com/f/gmoddev/oaxt/Blue-s-Masks-and-Shadows/1/

//This code can be improved alot.
//Feel free to improve, use or modify in anyway altough credit would be apreciated.

// NOTE Implement this in the libary such that it wont conflict with other people who use bluesmasks

BMASKS = {} //Global table, access the functions here
BMASKS.Materials = {} //Cache materials so they dont need to be reloaded
BMASKS.Masks = {} //A table of all active mask objects, you should destroy a mask object when done with it

//The material used to draw the render targets
BMASKS.MaskMaterial = CreateMaterial("!bluemask", "UnlitGeneric", {
	[ "$translucent" ] = 1,
	[ "$vertexalpha" ] = 1,
	[ "$alpha" ] = 1
})

//Creates a mask with the specified options
//Be sure to pass a unique maskName for each mask, otherwise they will override each other
BMASKS.CreateMask = function(maskName, maskPath, maskProperties)
	local mask = {}

	//Set mask name
	mask.name = maskName

	//Load materials
	if BMASKS.Materials[ maskPath ] == nil then
		BMASKS.Materials[ maskPath ] = Material(maskPath, maskProperties)
	end

	//Set the mask material
	mask.material = BMASKS.Materials[ maskPath ]

	//Create the render target
	mask.renderTarget = GetRenderTargetEx("BMASKS:" .. maskName, ScrW(), ScrH(), RT_SIZE_FULL_FRAME_BUFFER, MATERIAL_RT_DEPTH_NONE, 2, CREATERENDERTARGETFLAGS_UNFILTERABLE_OK, IMAGE_FORMAT_RGBA8888)
	BMASKS.Masks[ maskName ] = mask

	return maskName
end

//Call this to begin drawing with a mask.
//After calling this any draw call will be masked until you call EndMask(maskName)
BMASKS.BeginMask = function(maskName)

	//FindMask
	if BMASKS.Masks[ maskName ] == nil then
		print("Cannot begin a mask without creating it first!")

		return false
	end

	//Store current render target
	BMASKS.Masks[ maskName ].previousRenderTarget = render.GetRenderTarget()

	//Confirgure drawing so that we write to the masks render target
	render.PushRenderTarget(BMASKS.Masks[ maskName ].renderTarget)
	render.OverrideAlphaWriteEnable(true, true)
	render.Clear(0, 0, 0, 0)
end

//Ends the mask and draws it
//Not calling this after calling BeginMask will cause some really bad effects
//This done return the render target used, using this you can create other effects such as drop shadows without problems
//Passes true for dontDraw will result in it not being render and only returning the texture of the result (which is ScrW()xScrH())
local CachedOpacities = {}
BMASKS.EndMask = function(maskName, x, y, sizex, sizey, opacity, rotation, dontDraw , MakeTile)
	dontDraw = dontDraw or false
	rotation = rotation or 0
	opacity = opacity or 255

	//Draw the mask
	//render.OverrideBlendFunc(true, BLEND_ZERO, BLEND_SRC_ALPHA, BLEND_DST_ALPHA, BLEND_ZERO)

	render.OverrideBlend(true, BLEND_ZERO, BLEND_SRC_ALPHA, BLENDFUNC_ADD, BLEND_DST_ALPHA, BLEND_ZERO, BLENDFUNC_ADD)

	// Cache that color, no reason to spamm
	if CachedOpacities[ opacity ] == nil then CachedOpacities[ opacity ] = Color(255, 255, 255, opacity) end

	surface.SetDrawColor(CachedOpacities[ opacity ])
	surface.SetMaterial(BMASKS.Masks[ maskName ].material)

	if MakeTile then
		local u0, v0 = 0 + x, 0 + y
		local u1, v1 = 1 + x, 1 + y
		surface.DrawTexturedRectUV(0, 0, sizex, sizex, u0, v0, u1, v1)
	else
		if rotation == nil or rotation == 0 then
			surface.DrawTexturedRect(x, y, sizex, sizey)
		else
			surface.DrawTexturedRectRotated(x, y, sizex, sizey, rotation)
		end
	end

	render.OverrideBlend( false )
	//render.OverrideBlendFunc(false)

	render.OverrideAlphaWriteEnable(false)
	render.PopRenderTarget()

	//Update material
	BMASKS.MaskMaterial:SetTexture('$basetexture', BMASKS.Masks[ maskName ].renderTarget)

	//Clear material for upcoming draw calls
	draw.NoTexture()

	//Only draw if they want it to
	if not dontDraw then

		//Now draw finished result
		surface.SetDrawColor(color_white)
		surface.SetMaterial(BMASKS.MaskMaterial)
		render.SetMaterial(BMASKS.MaskMaterial)
		render.DrawScreenQuad()
	end

	return BMASKS.Masks[ maskName ].renderTarget
end

BMASKS.CreateMask("zclib_Circle", "materials/zerochain/zerolib/mask/mask_circle.png", "smooth")
BMASKS.CreateMask("zclib_gradient_topdown", "materials/zerochain/zerolib/mask/gradient_topdown.png", "smooth")
BMASKS.CreateMask("zclib_gradient_topdown_border", "materials/zerochain/zerolib/mask/gradient_topdown_border.png", "smooth")
BMASKS.CreateMask("zclib_radial_invert_glow", "materials/zerochain/zerolib/mask/radial_invert_glow.png", "smooth")
BMASKS.CreateMask("radial_shadow", "materials/zerochain/zerolib/mask/radial_shadow.png", "smooth")
