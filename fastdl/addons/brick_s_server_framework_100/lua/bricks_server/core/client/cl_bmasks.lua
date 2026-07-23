if( not BRICKS_SERVER.BMASKS ) then
    BRICKS_SERVER.BMASKS = {} --Global table, access the functions here

    BRICKS_SERVER.BMASKS.Materials = {} --Cache materials so they dont need to be reloaded
    BRICKS_SERVER.BMASKS.Masks = {} --A table of all active mask objects, you should destroy a mask object when done with it

    --The material used to draw the render targets
    BRICKS_SERVER.BMASKS.MaskMaterial = CreateMaterial("!bluemask","UnlitGeneric",{
        ["$translucent"] = 1,
        ["$vertexalpha"] = 1,
        ["$alpha"] = 1,
    })

    --Creates a mask with the specified options
    --Be sure to pass a unique maskName for each mask, otherwise they will override each other
    BRICKS_SERVER.BMASKS.CreateMask = function(maskName, maskPath, maskProperties)
        local mask = {}

        --Set mask name
        mask.name = maskName

        --Load materials
        if BRICKS_SERVER.BMASKS.Materials[maskPath] == nil then
            BRICKS_SERVER.BMASKS.Materials[maskPath] = Material(maskPath, maskProperties)
        end

        --Set the mask material
        mask.material = BRICKS_SERVER.BMASKS.Materials[maskPath]

        --Create the render target
        mask.renderTarget = GetRenderTargetEx("BRICKS_SERVER.BMASKS:"..maskName, ScrW(), ScrH(), RT_SIZE_FULL_FRAME_BUFFER, MATERIAL_RT_DEPTH_NONE, 2, CREATERENDERTARGETFLAGS_UNFILTERABLE_OK, IMAGE_FORMAT_RGBA8888)

        BRICKS_SERVER.BMASKS.Masks[maskName] = mask

        return maskName
    end

    --Call this to begin drawing with a mask.
    --After calling this any draw call will be masked until you call EndMask(maskName)
    BRICKS_SERVER.BMASKS.BeginMask = function(maskName)
        --FindMask
        if BRICKS_SERVER.BMASKS.Masks[maskName] == nil then 
            print("Cannot begin a mask without creating it first!") 
            return false
        end

        --Store current render target
        BRICKS_SERVER.BMASKS.Masks[maskName].previousRenderTarget = render.GetRenderTarget() 
        
        --Confirgure drawing so that we write to the masks render target
        render.PushRenderTarget(BRICKS_SERVER.BMASKS.Masks[maskName].renderTarget)
        render.OverrideAlphaWriteEnable( true, true )
        render.Clear( 0, 0, 0, 0 ) 
    end

    --Ends the mask and draws it
    --Not calling this after calling BeginMask will cause some really bad effects 
    --This done return the render target used, using this you can create other effects such as drop shadows without problems
    --Passes true for dontDraw will result in it not being render and only returning the texture of the result (which is ScrW()xScrH())
    BRICKS_SERVER.BMASKS.EndMask = function(maskName, x, y, sizex, sizey, opacity, rotation, dontDraw)

        dontDraw = dontDraw or false
        rotation = rotation or 0
        opacity = opacity or 255

        --Draw the mask
        render.OverrideBlendFunc( true, BLEND_ZERO, BLEND_SRC_ALPHA, BLEND_DST_ALPHA, BLEND_ZERO )
        surface.SetDrawColor(255,255,255,opacity)
        surface.SetMaterial(BRICKS_SERVER.BMASKS.Masks[maskName].material)
        if rotation == nil or rotation == 0 then
            surface.DrawTexturedRect(x, y, sizex, sizey) 
        else
            surface.DrawTexturedRectRotated(x, y, sizex, sizey, rotation) 
        end
        render.OverrideBlendFunc(false)
        render.OverrideAlphaWriteEnable( false )
        render.PopRenderTarget() 

        --Update material
        BRICKS_SERVER.BMASKS.MaskMaterial:SetTexture('$basetexture', BRICKS_SERVER.BMASKS.Masks[maskName].renderTarget)

        --Clear material for upcoming draw calls
        draw.NoTexture()

        --Only draw if they want is to
        if not dontDraw then
            --Now draw finished result
            surface.SetDrawColor(255,255,255,255) 
            surface.SetMaterial(BRICKS_SERVER.BMASKS.MaskMaterial) 
            render.SetMaterial(BRICKS_SERVER.BMASKS.MaskMaterial)
            render.DrawScreenQuad() 
        end

        return BRICKS_SERVER.BMASKS.Masks[maskName].renderTarget
    end
end