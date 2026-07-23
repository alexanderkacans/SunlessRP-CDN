if SERVER then return end

// Blues Masks and Shadows
//https://forum.facepunch.com/f/gmoddev/oaxt/Blue-s-Masks-and-Shadows/1/

//This code can be improved alot.
//Feel free to improve, use or modify in anyway altough credit would be apreciated.

// This will be used in the future as it has custom stuff and i dont want it to collide with the original blues masks

zclib.BMASKS = zclib.BMASKS or {} //Global table, access the functions here
zclib.BMASKS.Materials = zclib.BMASKS.Materials or {} //Cache materials so they dont need to be reloaded
zclib.BMASKS.Masks = zclib.BMASKS.Masks or {} //A table of all active mask objects, you should destroy a mask object when done with it

//The material used to draw the render targets
zclib.BMASKS.MaskMaterial = CreateMaterial("!bluemask", "UnlitGeneric", {
	[ "$translucent" ] = 1,
	[ "$vertexalpha" ] = 1,
	[ "$alpha" ] = 1,
})

//Creates a mask with the specified options
//Be sure to pass a unique maskName for each mask, otherwise they will override each other
zclib.BMASKS.CreateMask = function(maskName, maskPath, maskProperties)
	local mask = {}

	//Set mask name
	mask.name = maskName

	//Load materials
	if zclib.BMASKS.Materials[ maskPath ] == nil then
		zclib.BMASKS.Materials[ maskPath ] = Material(maskPath, maskProperties)
	end

	//Set the mask material
	mask.material = zclib.BMASKS.Materials[ maskPath ]

	//Create the render target
	mask.renderTarget = GetRenderTargetEx("zclib.BMASKS:" .. maskName, ScrW(), ScrH(), RT_SIZE_FULL_FRAME_BUFFER, MATERIAL_RT_DEPTH_NONE, 2, CREATERENDERTARGETFLAGS_UNFILTERABLE_OK, IMAGE_FORMAT_RGBA8888)
	zclib.BMASKS.Masks[ maskName ] = mask

	return maskName
end

//Call this to begin drawing with a mask.
//After calling this any draw call will be masked until you call EndMask(maskName)
zclib.BMASKS.BeginMask = function(maskName)

	//FindMask
	if zclib.BMASKS.Masks[ maskName ] == nil then
		print("Cannot begin a mask without creating it first!")

		return false
	end

	//Store current render target
	zclib.BMASKS.Masks[ maskName ].previousRenderTarget = render.GetRenderTarget()

	render.SetWriteDepthToDestAlpha( false )

	//Confirgure drawing so that we write to the masks render target
	render.PushRenderTarget(zclib.BMASKS.Masks[ maskName ].renderTarget)
	render.OverrideAlphaWriteEnable(true, true)
	render.Clear(0, 0, 0, 0)
end

//Ends the mask and draws it
//Not calling this after calling BeginMask will cause some really bad effects
//This done return the render target used, using this you can create other effects such as drop shadows without problems
//Passes true for dontDraw will result in it not being render and only returning the texture of the result (which is ScrW()xScrH())
local CachedOpacities = {}
zclib.BMASKS.EndMask = function(maskName, x, y, sizex, sizey, opacity, rotation, dontDraw , MakeTile)
	dontDraw = dontDraw or false
	opacity = opacity or 255

	render.OverrideBlend(true, BLEND_ZERO, BLEND_ONE, BLENDFUNC_ADD, BLEND_DST_ALPHA, BLEND_ZERO, BLENDFUNC_ADD)
	//render.OverrideBlend( true, BLEND_SRC_COLOR, BLEND_SRC_ALPHA, BLENDFUNC_MIN )

	// Cache that color, no reason to spamm
	if CachedOpacities[ opacity ] == nil then CachedOpacities[ opacity ] = Color(255, 255, 255, opacity) end


	surface.SetDrawColor(CachedOpacities[ opacity ])
	surface.SetMaterial(zclib.BMASKS.Masks[ maskName ].material)

	if MakeTile then
		local u0, v0 = 0 + x, 0 + y
		local u1, v1 = 1 + x, 1 + y
		surface.DrawTexturedRectUV(0, 0, sizex, sizex, u0, v0, u1, v1)
	else
		if rotation == nil then
			surface.DrawTexturedRect(x, y , sizex, sizey)
		else
			surface.DrawTexturedRectRotated(x, y, sizex, sizey, rotation)
		end
	end

	render.OverrideBlend( false )
	render.SetWriteDepthToDestAlpha( true )

	render.OverrideAlphaWriteEnable(false)
	render.PopRenderTarget()

	//Update material
	zclib.BMASKS.MaskMaterial:SetTexture('$basetexture', zclib.BMASKS.Masks[ maskName ].renderTarget)

	//Clear material for upcoming draw calls
	draw.NoTexture()

	//Only draw if they want it to
	if not dontDraw then

		//Now draw finished result
		surface.SetDrawColor(color_white)
		surface.SetMaterial(zclib.BMASKS.MaskMaterial)

		render.SetMaterial(zclib.BMASKS.MaskMaterial)
		render.DrawScreenQuad()
	end



	return zclib.BMASKS.Masks[ maskName ].renderTarget
end


zclib.BMASKS.CreateMask("zclib_Circle", "materials/zerochain/zerolib/mask/mask_circle.png", "smooth")
zclib.BMASKS.CreateMask("zclib_gradient_topdown", "materials/zerochain/zerolib/mask/gradient_topdown.png", "smooth")
zclib.BMASKS.CreateMask("zclib_gradient_topdown_border", "materials/zerochain/zerolib/mask/gradient_topdown_border.png", "smooth")
zclib.BMASKS.CreateMask("zclib_radial_invert_glow", "materials/zerochain/zerolib/mask/radial_invert_glow.png", "smooth")
zclib.BMASKS.CreateMask("radial_shadow", "materials/zerochain/zerolib/mask/radial_shadow.png", "smooth")
zclib.BMASKS.CreateMask("mask_roundbox", "materials/zerochain/zerolib/mask/mask_roundbox.png", "smooth")
