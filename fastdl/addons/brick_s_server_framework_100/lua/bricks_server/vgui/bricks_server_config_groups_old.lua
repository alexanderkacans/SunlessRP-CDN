local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel()
    local removeMat = Material( "materials/bricks_server/delete.png" )
    local editMat = Material( "materials/bricks_server/edit.png" )
    local upMat = Material( "materials/bricks_server/up.png" )
    local downMat = Material( "materials/bricks_server/down.png" )
    
    function self.RefreshPanel()
        self:Clear()

        self.slots = nil
        if( self.grid and IsValid( self.grid ) ) then
            self.grid:Remove()
        end

        for k, v in ipairs( (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).GENERAL.Groups ) do
            local GroupBack = vgui.Create( "DPanel", self )
            GroupBack:Dock( TOP )
            GroupBack:DockMargin( 0, 0, 0, 5 )
            GroupBack:SetTall( 65 )
            GroupBack:DockPadding( 0, 0, 10, 0 )
            local groupString = ""
            for key, val in pairs( v[2] or {} ) do
                if( groupString == "" ) then
                    groupString = key
                else
                    groupString = groupString .. ", " .. key
                end
            end
            GroupBack.Paint = function( self2, w, h )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
                draw.RoundedBoxEx( 5, 0, 0, 25, h, (v[3] or BRICKS_SERVER.Func.GetTheme( 5 )), true, false, true, false )

                surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3 ) )
                surface.DrawRect( 5, 0, 20, h )

                draw.SimpleText( v[1], "BRICKS_SERVER_Font33", 15, 5, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                if( v[2] and table.Count( v[2] ) > 0 ) then
                    draw.SimpleText( "User groups: " .. groupString, "BRICKS_SERVER_Font20", 18, 32, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                else
                    draw.SimpleText( BRICKS_SERVER.Func.L( "noUserGroups" ), "BRICKS_SERVER_Font20", 18, 32, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                end
            end
            GroupBack.AddButton = function( self2, material, func )
                local button = vgui.Create( "DButton", self2 )
                button:Dock( RIGHT )
                button:SetWide( 36 )
                button:DockMargin( 0, (self2:GetTall()-button:GetWide())/2, 0, (self2:GetTall()-button:GetWide())/2 )
                button:SetText( "" )
                local changeAlpha = 0
                local x, y = 0, 0
                button.Paint = function( self3, w, h )
                    local toScreenX, toScreenY = self3:LocalToScreen( 0, 0 )
                    if( x != toScreenX or y != toScreenY ) then
                        x, y = toScreenX, toScreenY
                    end
            
                    if( self3:IsDown() ) then
                        changeAlpha = math.Clamp( changeAlpha+10, 0, 125 )
                    elseif( self3:IsHovered() ) then
                        changeAlpha = math.Clamp( changeAlpha+10, 0, 95 )
                    else
                        changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
                    end
            
                    surface.SetAlphaMultiplier( changeAlpha/255 )
                    draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
                    surface.SetAlphaMultiplier( 1 )
            
                    surface.SetMaterial( material )
                    local size = 24
                    surface.SetDrawColor( 0, 0, 0, 255 )
                    surface.DrawTexturedRect( (h-size)/2-1, (h-size)/2+1, size, size )
            
                    surface.SetDrawColor( 255, 255, 255, 255 )
                    surface.DrawTexturedRect( (h-size)/2, (h-size)/2, size, size )
                end
                button.DoClick = function()
                    func( x, y, button:GetWide(), button:GetWide() )
                end
            end

            GroupBack:AddButton( removeMat, function( x, y, w, h )
                table.remove( BS_ConfigCopyTable.GENERAL.Groups, k )
                self.RefreshPanel()
                BRICKS_SERVER.Func.ConfigChange( "GENERAL" )
            end )
            GroupBack:AddButton( editMat, function( x, y, w, h )
                GroupBack.Menu = vgui.Create( "bricks_server_dmenu" )
                GroupBack.Menu:AddOption( BRICKS_SERVER.Func.L( "editUserGroups" ), function()
                    BRICKS_SERVER.Func.CreateGroupEditor( (v[2] or {}), function( userGroups ) 
                        BS_ConfigCopyTable.GENERAL.Groups[k][2] = userGroups or {}
                        self.RefreshPanel()
                        BRICKS_SERVER.Func.ConfigChange( "GENERAL" )
                    end, function() end, true )
                end )
                GroupBack.Menu:AddOption( BRICKS_SERVER.Func.L( "editColor" ), function()
                    BRICKS_SERVER.Func.ColorRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "newGroupColor" ), (v[3] or BRICKS_SERVER.Func.GetTheme( 5 )), function( color ) 
                        BS_ConfigCopyTable.GENERAL.Groups[k][3] = color or BRICKS_SERVER.Func.GetTheme( 5 )
                        self.RefreshPanel()
                        BRICKS_SERVER.Func.ConfigChange( "GENERAL" )
                    end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ) )
                end )
                GroupBack.Menu:AddOption( BRICKS_SERVER.Func.L( "editName" ), function()
                    BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "newGroupName" ), (v[1] or "GroupName"), function( text ) 
                        for key, val in pairs( BS_ConfigCopyTable.GENERAL.Groups ) do
                            if( val[1] == text ) then
                                notification.AddLegacy( BRICKS_SERVER.Func.L( "groupAlreadyExists" ), 1, 5 )
                                return
                            end
                        end
                        
                        BS_ConfigCopyTable.GENERAL.Groups[k][1] = text
                        self.RefreshPanel()
                        BRICKS_SERVER.Func.ConfigChange( "GENERAL" )
                    end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), false )
                end )
                GroupBack.Menu:Open()
                GroupBack.Menu:SetPos( x+w+5, y+(h/2)-(GroupBack.Menu:GetTall()/2) )
            end )
            GroupBack:AddButton( downMat, function( x, y, w, h )
                if( k+1 <= #BS_ConfigCopyTable.GENERAL.Groups ) then
                    if( BS_ConfigCopyTable.GENERAL.Groups[k+1] ) then
                        BS_ConfigCopyTable.GENERAL.Groups[k] = BS_ConfigCopyTable.GENERAL.Groups[k+1]
                    end

                    BS_ConfigCopyTable.GENERAL.Groups[k+1] = v
                    self.RefreshPanel()
                    BRICKS_SERVER.Func.ConfigChange( "GENERAL" )
                end
            end )
            GroupBack:AddButton( upMat, function( x, y, w, h )
                if( k-1 >= 1 ) then
                    if( BS_ConfigCopyTable.GENERAL.Groups[k-1] ) then
                        BS_ConfigCopyTable.GENERAL.Groups[k] = BS_ConfigCopyTable.GENERAL.Groups[k-1]
                    end

                    BS_ConfigCopyTable.GENERAL.Groups[k-1] = v
                    self.RefreshPanel()
                    BRICKS_SERVER.Func.ConfigChange( "GENERAL" )
                end
            end )
        end

        local addNewGroup = vgui.Create( "DButton", self )
        addNewGroup:SetText( "" )
        addNewGroup:Dock( TOP )
        addNewGroup:DockMargin( 0, 0, 0, 5 )
        addNewGroup:SetTall( 40 )
        local changeAlpha = 0
        addNewGroup.Paint = function( self2, w, h )
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
    
            draw.SimpleText( BRICKS_SERVER.Func.L( "addNewGroup" ), "BRICKS_SERVER_Font20", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
        addNewGroup.DoClick = function()
            BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "newGroupName" ), BRICKS_SERVER.Func.L( "groupName" ), function( text ) 
                for key, val in pairs( (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).GENERAL.Groups ) do
                    if( val[1] == text ) then
                        notification.AddLegacy( BRICKS_SERVER.Func.L( "groupAlreadyExists" ), 1, 5 )
                        return
                    end
                end
                
                table.insert( BS_ConfigCopyTable.GENERAL.Groups, { text, {} } )
                self.RefreshPanel()
                BRICKS_SERVER.Func.ConfigChange( "GENERAL" )
            end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), false )
        end
    end
    self.RefreshPanel()
end

function PANEL:Paint( w, h )
    
end

vgui.Register( "bricks_server_config_groups_old", PANEL, "bricks_server_scrollpanel" )