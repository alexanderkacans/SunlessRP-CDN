local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel()
    local itemActions = {
        [1] = { BRICKS_SERVER.Func.L( "edit" ), function( k, v )
            BRICKS_SERVER.Func.CreateNPCEditor( k, v, function( NPCTable ) 
                BS_ConfigCopyTable.NPCS[k] = NPCTable
                BRICKS_SERVER.Func.ConfigChange( "NPCS" )
                self.RefreshPanel()
            end, function() end )
        end }
    }
    
    BS_ConfigCopyTable.NPCS = BS_ConfigCopyTable.NPCS or {}
    function self.RefreshPanel()
        self:Clear()

        self.slots = nil
        if( self.grid and IsValid( self.grid ) ) then
            self.grid:Remove()
        end

        BRICKS_SERVER.Func.FillVariableConfigs( self, "NPCS", "NPCS" )

        for k, v in pairs( BS_ConfigCopyTable.NPCS or {} ) do
            local itemBack = vgui.Create( "DPanel", self )
            itemBack:Dock( TOP )
            itemBack:DockMargin( 0, 0, 0, 5 )
            itemBack:SetTall( 100 )
            itemBack:DockPadding( 0, 0, 25, 0 )
            itemBack.Paint = function( self2, w, h )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
                draw.RoundedBox( 5, 5, 5, h-10, h-10, BRICKS_SERVER.Func.GetTheme( 2 ) )

                draw.SimpleText( v.Name, "BRICKS_SERVER_Font33", h+15, 5, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                draw.SimpleText( v.Type, "BRICKS_SERVER_Font20", h+15, 32, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
            end

            local itemIcon = vgui.Create( "DModelPanel" , itemBack )
            itemIcon:SetPos( 5, 5 )
            itemIcon:SetSize( itemBack:GetTall()-10, itemBack:GetTall()-10 )
            itemIcon:SetModel( v.Model or "models/breen.mdl" )
            itemIcon:SetCamPos( itemIcon:GetCamPos()+Vector( 40, 0, 0 ) )
            itemIcon:SetColor( v.ModelColor or Color( 255, 255, 255 ) )
            function itemIcon:LayoutEntity(ent) return end

            if( IsValid( itemIcon.Entity ) ) then
                local eyepos = itemIcon.Entity:GetBonePosition( (itemIcon.Entity:LookupBone("ValveBiped.Bip01_Head1") or 1) ) or Vector( 0, 0, 0 )
                eyepos:Add(Vector(0, 0, 2))	-- Move up slightly
                itemIcon:SetLookAt(eyepos)
                itemIcon:SetCamPos(eyepos-Vector(-20, 0, 0))	-- Move cam in front of eyes
                itemIcon.Entity:SetEyeTarget(eyepos-Vector(-12, 0, 0))
            end

            local newItemActions = table.Copy( itemActions )
            if( BRICKS_SERVER.DEVCONFIG.NPCTypes[(v.Type or "")] and BRICKS_SERVER.DEVCONFIG.NPCTypes[(v.Type or "")].TypeDataFunction ) then
                newItemActions[2] = { (BRICKS_SERVER.Func.L( "edit" ) .. " " .. (BRICKS_SERVER.DEVCONFIG.NPCTypes[(v.Type or "")].TypeDataName or "Data")), function( k, v )
                    if( BRICKS_SERVER.DEVCONFIG.NPCTypes[(v.Type or "")] and BRICKS_SERVER.DEVCONFIG.NPCTypes[(v.Type or "")].TypeDataFunction ) then
                        BRICKS_SERVER.DEVCONFIG.NPCTypes[(v.Type or "")].TypeDataFunction( k, v )
                        BRICKS_SERVER.Func.ConfigChange( "NPCS" )
                    end
                end }
                newItemActions[3] = { BRICKS_SERVER.Func.L( "remove" ), function( k, v )
                    BS_ConfigCopyTable.NPCS[k] = nil
                    BRICKS_SERVER.Func.ConfigChange( "NPCS" )
                    self.RefreshPanel()
                end, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkRed }
            else
                newItemActions[2] = { BRICKS_SERVER.Func.L( "remove" ), function( k, v )
                    BS_ConfigCopyTable.NPCS[k] = nil
                    BRICKS_SERVER.Func.ConfigChange( "NPCS" )
                    self.RefreshPanel()
                end, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkRed }
            end

            for key2, val2 in ipairs( newItemActions ) do
                local itemAction = vgui.Create( "DButton", itemBack )
                itemAction:Dock( RIGHT )
                itemAction:SetText( "" )
                itemAction:DockMargin( 5, 25, 0, 25 )
                surface.SetFont( "BRICKS_SERVER_Font25" )
                local textX, textY = surface.GetTextSize( val2[1] )
                textX = textX+20
                itemAction:SetWide( math.max( (ScrW()/2560)*150, textX ) )
                local changeAlpha = 0
                itemAction.Paint = function( self2, w, h )
                    if( self2:IsDown() ) then
                        changeAlpha = math.Clamp( changeAlpha+10, 0, 125 )
                    elseif( self2:IsHovered() ) then
                        changeAlpha = math.Clamp( changeAlpha+10, 0, 75 )
                    else
                        changeAlpha = math.Clamp( changeAlpha-10, 0, 75 )
                    end
                    
                    if( val2[3] ) then
                        draw.RoundedBox( 5, 0, 0, w, h, val2[3] )
                    else
                        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
                    end
            
                    surface.SetAlphaMultiplier( changeAlpha/255 )
                        if( val2[4] ) then
                            draw.RoundedBox( 5, 0, 0, w, h, val2[4] )
                        else
                            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
                        end
                    surface.SetAlphaMultiplier( 1 )
            
                    draw.SimpleText( val2[1], "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                end
                itemAction.DoClick = function()
                    val2[2]( k, v )
                end
            end
        end

        local addNewNPC = vgui.Create( "DButton", self )
        addNewNPC:Dock( TOP )
        addNewNPC:SetText( "" )
        addNewNPC:SetTall( 40 )
        local changeAlpha = 0
        addNewNPC.Paint = function( self2, w, h )
            if( self2:IsDown() ) then
                changeAlpha = math.Clamp( changeAlpha+10, 0, 125 )
            elseif( self2:IsHovered() ) then
                changeAlpha = math.Clamp( changeAlpha+10, 0, 75 )
            else
                changeAlpha = math.Clamp( changeAlpha-10, 0, 75 )
            end
            
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
    
            surface.SetAlphaMultiplier( changeAlpha/255 )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
            surface.SetAlphaMultiplier( 1 )
    
            draw.SimpleText( BRICKS_SERVER.Func.L( "addNPC" ), "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
        addNewNPC.DoClick = function()
            BS_ConfigCopyTable.NPCS = BS_ConfigCopyTable.NPCS or {}
            local newNPC = {
                Name = BRICKS_SERVER.Func.L( "newNPC" )
            }
            table.insert( BS_ConfigCopyTable.NPCS, newNPC )
            BRICKS_SERVER.Func.ConfigChange( "NPCS" )
            self.RefreshPanel()
        end
    end
    self.RefreshPanel()
end

function PANEL:Paint( w, h )
    
end

vgui.Register( "bricks_server_config_npcs", PANEL, "bricks_server_scrollpanel" )