local PANEL = {}

function PANEL:Init()
    self.margin = 0
end

function PANEL:FillPanel()
    self.panelWide, self.panelTall = ScrW()*0.6-BRICKS_SERVER.DEVCONFIG.MainNavWidth, ScrH()*0.65-40

    self.topBar = vgui.Create( "DPanel", self )
    self.topBar:Dock( TOP )
    self.topBar:SetTall( 60 )
    self.topBar.Paint = function( self, w, h ) 
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
        surface.DrawRect( 0, 0, w, h )
    end 

    surface.SetFont( "BRICKS_SERVER_Font20" )
    local textX, textY = surface.GetTextSize( "Create Rarity" )
    local totalContentW = 16+5+textX

    local createNewButton = vgui.Create( "DButton", self.topBar )
    createNewButton:Dock( RIGHT )
    createNewButton:DockMargin( 10, 10, 25, 10 )
    createNewButton:SetWide( totalContentW+27 )
    createNewButton:SetText( "" )
    local alpha = 0
    local addMat = Material( "bricks_server/add_16.png" )
    createNewButton.Paint = function( self2, w, h )
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )

        if( not self2:IsDown() and self2:IsHovered() ) then
            alpha = math.Clamp( alpha+10, 0, 255 )
        else
            alpha = math.Clamp( alpha-10, 0, 255 )
        end

        surface.SetAlphaMultiplier( alpha/255 )
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )
        surface.SetAlphaMultiplier( 1 )

        BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )

        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6, 20+(235*(alpha/255)) ) )
        surface.SetMaterial( addMat )
        local iconSize = 16
        surface.DrawTexturedRect( 12, (h/2)-(iconSize/2), iconSize, iconSize )

        draw.SimpleText( "Create Rarity", "BRICKS_SERVER_Font20", 12+iconSize+5, h/2, BRICKS_SERVER.Func.GetTheme( 6, 20+(235*(alpha/255)) ), 0, TEXT_ALIGN_CENTER )
    end
    createNewButton.DoClick = function()
        BS_ConfigCopyTable.GENERAL.Rarities = BS_ConfigCopyTable.GENERAL.Rarities or {}
        table.insert( BS_ConfigCopyTable.GENERAL.Rarities, 1, { BRICKS_SERVER.Func.L( "newRarity" ) .. " " .. (#BS_ConfigCopyTable.GENERAL.Rarities or 0)+1, "SolidColor", Color( 125, 125, 125 ) } )
        self:Refresh()
        BRICKS_SERVER.Func.ConfigChange( "GENERAL" )

        BRICKS_SERVER.Func.CreateTopNotification( "New rarity added!", 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Green )
    end

    self.searchBar = vgui.Create( "bricks_server_searchbar", self.topBar )
    self.searchBar:Dock( LEFT )
    self.searchBar:DockMargin( 25, 10, 10, 10 )
    self.searchBar:SetWide( ScrW()*0.2 )
    self.searchBar:SetBackColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
    self.searchBar:SetHighlightColor( BRICKS_SERVER.Func.GetTheme( 0 ) )
    self.searchBar.OnChange = function()
        self:Refresh()
    end

    self.scrollPanel = vgui.Create( "bricks_server_scrollpanel_bar", self )
    self.scrollPanel:Dock( FILL )
    self.scrollPanel:DockMargin( 25, 25, 25, 25 )
    self.scrollPanel.Paint = function( self, w, h ) end 

    self.spacing = 25
    local gridWide = self.panelWide-50-10-10
    self.slotsWide = 2
    self.slotWide, self.slotTall = (gridWide-((self.slotsWide-1)*self.spacing))/self.slotsWide, 150

    self.grid = vgui.Create( "DIconLayout", self.scrollPanel )
    self.grid:Dock( TOP )
    self.grid:SetSpaceY( 10 )
    self.grid:SetSpaceX( self.spacing )

    self:Refresh()
end

function PANEL:Refresh()
    self.grid:Clear()

    local sortedItems = {}
    for k, v in pairs( BS_ConfigCopyTable.GENERAL.Rarities or {} ) do
        if( self.searchBar:GetValue() != "" and not string.find( string.lower( v[1] ), string.lower( self.searchBar:GetValue() ) ) ) then
            continue
        end

        local itemTable = table.Copy( v )
        itemTable.Key = k

        table.insert( sortedItems, itemTable)
    end

    table.sort( sortedItems, function( a, b ) return ((a or {}).Key or 0) > ((b or {}).Key or 0) end )

    for k, v in pairs( sortedItems ) do
        local rarityBack = vgui.Create( "DPanel", self.grid )
        rarityBack:SetSize( self.slotWide, self.slotTall )
        rarityBack.Paint = function( self2, w, h ) end

        local rarityNum = vgui.Create( "DPanel", rarityBack )
        rarityNum:Dock( LEFT )
        rarityNum:DockMargin( 0, 0, 10, 0 )
        rarityNum:SetWide( 35 )
        rarityNum.Paint = function( self2, w, h )
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3, 125 ) )
    
            draw.SimpleText( #(BS_ConfigCopyTable.GENERAL.Rarities or {})-v.Key+1, "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6, 20 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end

        local rarityUpButton = vgui.Create( "DButton", rarityNum )
        rarityUpButton:SetText( "" )
        rarityUpButton:Dock( TOP )
        rarityUpButton:SetTall( rarityNum:GetWide() )
        local alpha = 0
        local upMat = Material( "materials/bricks_server/up_16.png" )
        rarityUpButton.Paint = function( self2, w, h )
            if( not self2:IsDown() and self2:IsHovered() ) then
                alpha = math.Clamp( alpha+10, 0, 255 )
            else
                alpha = math.Clamp( alpha-10, 0, 255 )
            end
    
            surface.SetAlphaMultiplier( alpha/255 )
            draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ), true, true, false, false )
            surface.SetAlphaMultiplier( 1 )
    
            BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 3 ), 8 )

            surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6, 20+(235*(alpha/255)) ) )
            surface.SetMaterial( upMat )
            local iconSize = 16
            surface.DrawTexturedRect( (h-iconSize)/2, (h/2)-(iconSize/2), iconSize, iconSize )
        end
        rarityUpButton.DoClick = function()
            if( v.Key >= #BS_ConfigCopyTable.GENERAL.Rarities ) then return end

            local targetTable = BS_ConfigCopyTable.GENERAL.Rarities[v.Key+1]

            if( not targetTable ) then return end

            BS_ConfigCopyTable.GENERAL.Rarities[v.Key+1] = v
            BS_ConfigCopyTable.GENERAL.Rarities[v.Key] = targetTable

            self:Refresh()
            BRICKS_SERVER.Func.ConfigChange( "GENERAL" )
        end

        local rarityDownButton = vgui.Create( "DButton", rarityNum )
        rarityDownButton:SetText( "" )
        rarityDownButton:Dock( BOTTOM )
        rarityDownButton:SetTall( rarityNum:GetWide() )
        local alpha = 0
        local downMat = Material( "materials/bricks_server/down_16.png" )
        rarityDownButton.Paint = function( self2, w, h )
            if( not self2:IsDown() and self2:IsHovered() ) then
                alpha = math.Clamp( alpha+10, 0, 255 )
            else
                alpha = math.Clamp( alpha-10, 0, 255 )
            end
    
            surface.SetAlphaMultiplier( alpha/255 )
            draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ), false, false, true, true )
            surface.SetAlphaMultiplier( 1 )
    
            BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 3 ), 8 )

            surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6, 20+(235*(alpha/255)) ) )
            surface.SetMaterial( downMat )
            local iconSize = 16
            surface.DrawTexturedRect( (h-iconSize)/2, (h/2)-(iconSize/2), iconSize, iconSize )
        end
        rarityDownButton.DoClick = function()
            if( v.Key <= 1 ) then return end

            local targetTable = BS_ConfigCopyTable.GENERAL.Rarities[v.Key-1]

            if( not targetTable ) then return end

            BS_ConfigCopyTable.GENERAL.Rarities[v.Key-1] = v
            BS_ConfigCopyTable.GENERAL.Rarities[v.Key] = targetTable

            self:Refresh()
            BRICKS_SERVER.Func.ConfigChange( "GENERAL" )
        end

        local rarityPanel = vgui.Create( "DPanel", rarityBack )
        rarityPanel:Dock( FILL )
        rarityPanel.Paint = function( self2, w, h )
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
    
            draw.SimpleText( v[1], "BRICKS_SERVER_Font30", 10+15, 10, BRICKS_SERVER.Func.GetRarityColor( v ), 0, 0 )
            draw.SimpleText( BRICKS_SERVER.DEVCONFIG.RarityTypes[v[2]].Title, "BRICKS_SERVER_Font21", 10+15, 32, BRICKS_SERVER.Func.GetTheme( 6, 125 ), 0, 0 )
        end

        surface.SetFont( "BRICKS_SERVER_Font30" )
        local nameX, nameY = surface.GetTextSize( v[1] )

        local rarityEditNameButton = vgui.Create( "DButton", rarityPanel )
        rarityEditNameButton:SetText( "" )
        rarityEditNameButton:SetSize( 16, 16 )
        rarityEditNameButton:SetPos( 10+15+nameX+5, 10+(nameY/2)-6 )
        local alpha = 20
        local editMat = Material( "materials/bricks_server/edit_16.png" )
        rarityEditNameButton.Paint = function( self2, w, h )
            if( not self2:IsDown() and self2:IsHovered() ) then
                alpha = math.Clamp( alpha+10, 20, 255 )
            else
                alpha = math.Clamp( alpha-10, 20, 255 )
            end
    
            surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6, alpha ) )
            surface.SetMaterial( editMat )
            local iconSize = 16
            surface.DrawTexturedRect( (h-iconSize)/2, (h/2)-(iconSize/2), iconSize, iconSize )
        end
        rarityEditNameButton.DoClick = function()
            BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), "What should the new rarity name be?", v[1], function( text ) 
                if( text == v[1] ) then return end

                BS_ConfigCopyTable.GENERAL.Rarities[v.Key][1] = text
                self:Refresh()
                BRICKS_SERVER.Func.ConfigChange( "GENERAL" )
			end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), false )
        end
    
        local rarityBox = vgui.Create( "bricks_server_raritybox", rarityPanel )
        rarityBox:SetSize( 10, rarityBack:GetTall() )
        rarityBox:SetPos( 0, 0 )
        rarityBox:SetRarityName( v[1], 1 )
        rarityBox:SetCornerRadius( 8 )
        rarityBox:SetRoundedBoxDimensions( false, false, 20, false )

        surface.SetFont( "BRICKS_SERVER_Font20" )
        local typeX, typeY = surface.GetTextSize( "Edit Type" )

        local editTypeButton = vgui.Create( "DButton", rarityPanel )
        editTypeButton:SetText( "" )
        editTypeButton:SetSize( typeX+25, 35 )
        editTypeButton:SetPos( rarityBack:GetWide()-rarityNum:GetWide()-10-10-40-editTypeButton:GetWide()-5, rarityBack:GetTall()-10-editTypeButton:GetTall() )
        local alpha = 0
        editTypeButton.Paint = function( self2, w, h )
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )

            if( not self2:IsDown() and self2:IsHovered() ) then
                alpha = math.Clamp( alpha+10, 0, 255 )
            else
                alpha = math.Clamp( alpha-10, 0, 255 )
            end
    
            surface.SetAlphaMultiplier( alpha/255 )
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )
            surface.SetAlphaMultiplier( 1 )
    
            BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 0 ), 8 )

            draw.SimpleText( "Edit Type", "BRICKS_SERVER_Font20", w/2, h/2-1, BRICKS_SERVER.Func.GetTheme( 6, 20+(235*(alpha/255)) ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
        editTypeButton.DoClick = function()
			local options = {}
			for k, v in pairs( BRICKS_SERVER.DEVCONFIG.RarityTypes ) do
				options[k] = v.Title
            end
            
			BRICKS_SERVER.Func.ComboRequest( BRICKS_SERVER.Func.L( "admin" ), "What should the rarity color type be?", v[2], options, function( value, data ) 
				if( BRICKS_SERVER.DEVCONFIG.RarityTypes[data] ) then
                    if( data == v[2] ) then return end

                    local oldColors = BS_ConfigCopyTable.GENERAL.Rarities[v.Key][3]
                    if( data == "Rainbow" ) then
                        BS_ConfigCopyTable.GENERAL.Rarities[v.Key][3] = nil
                    elseif( data == "SolidColor" ) then
                        BS_ConfigCopyTable.GENERAL.Rarities[v.Key][3] = (oldColors and (((istable( oldColors ) and not oldColors.r) and oldColors[1]) or oldColors)) or Color( 125, 125, 125 )
                    else
                        BS_ConfigCopyTable.GENERAL.Rarities[v.Key][3] = ((istable( oldColors ) and not oldColors.r) and oldColors) or { oldColors, oldColors }
                    end

                    BS_ConfigCopyTable.GENERAL.Rarities[v.Key][2] = data
                    self:Refresh()
                    BRICKS_SERVER.Func.ConfigChange( "GENERAL" )
				else
					notification.AddLegacy( BRICKS_SERVER.Func.L( "invalidType" ), 1, 3 )
				end
			end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ) )
        end

        local deleteButton = vgui.Create( "DButton", rarityPanel )
        deleteButton:SetText( "" )
        deleteButton:SetSize( 40, 40 )
        deleteButton:SetPos( rarityBack:GetWide()-rarityNum:GetWide()-10-10-deleteButton:GetWide(), rarityBack:GetTall()-10-deleteButton:GetTall() )
        local alpha = 0
        local deleteMat = Material( "materials/bricks_server/delete.png" )
        deleteButton.Paint = function( self2, w, h )
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )

            if( not self2:IsDown() and self2:IsHovered() ) then
                alpha = math.Clamp( alpha+10, 0, 255 )
            else
                alpha = math.Clamp( alpha-10, 0, 255 )
            end
    
            surface.SetAlphaMultiplier( alpha/255 )
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )
            surface.SetAlphaMultiplier( 1 )
    
            BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 4 ), 8 )

            surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6, 20+(235*(alpha/255)) ) )
            surface.SetMaterial( deleteMat )
            local iconSize = 24
            surface.DrawTexturedRect( (h-iconSize)/2, (h/2)-(iconSize/2), iconSize, iconSize )
        end
        deleteButton.DoClick = function()
            BRICKS_SERVER.Func.CreatePopoutQuery( "Are you sure you want to remove this rarity?", self, self.panelWide, self.panelTall, "Confirm", "Cancel", function()
                table.remove( BS_ConfigCopyTable.GENERAL.Rarities, v.Key )
                self:Refresh()
                BRICKS_SERVER.Func.ConfigChange( "GENERAL" )

                BRICKS_SERVER.Func.CreateTopNotification( "Rarity successfully removed!", 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
            end )
        end

        if( v[2] == "Gradient" or v[2] == "Fade" or v[2] == "SolidColor" ) then
            local colorsBack = vgui.Create( "DPanel", rarityPanel )
            colorsBack:SetSize( 0, 30 )
            colorsBack:SetPos( 10+10, rarityBack:GetTall()-10-colorsBack:GetTall() )
            colorsBack.Paint = function( self2, w, h ) end
            colorsBack.AddColor = function( color, doClick )
                colorsBack:SetWide( colorsBack:GetWide()+colorsBack:GetTall()+((colorsBack:GetWide() > 0 and 5) or 0) )

                local colorButton = vgui.Create( "DButton", colorsBack )
                colorButton:SetText( "" )
                colorButton:Dock( LEFT )
                colorButton:DockMargin( 0, 0, 5, 0 )
                colorButton:SetWide( colorsBack:GetTall() )
                local alpha = 0
                local x, y, w, h = 0, 0, colorButton:GetWide(), colorButton:GetWide()
                colorButton.Paint = function( self2, w, h )
                    local toScreenX, toScreenY = self2:LocalToScreen( 0, 0 )
                    if( x != toScreenX or y != toScreenY ) then
                        x, y = toScreenX, toScreenY
                    end

                    draw.RoundedBox( 8, 0, 0, w, h, color )
        
                    if( not self2:IsDown() and self2:IsHovered() ) then
                        alpha = math.Clamp( alpha+10, 0, 125 )
                    else
                        alpha = math.Clamp( alpha-10, 0, 125 )
                    end
            
                    surface.SetAlphaMultiplier( alpha/255 )
                    draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )
                    surface.SetAlphaMultiplier( 1 )
                end
                colorButton.DoClick = function()
                    doClick( colorButton, x+w-5, y+(h/2) )
                end
            end

            if( v[2] == "Gradient" or v[2] == "Fade" ) then
                for key, val in pairs( v[3] ) do
                    colorsBack.AddColor( val, function( colorButton, x, y )
                        colorButton.Menu = vgui.Create( "bricks_server_popupdmenu" )
                        colorButton.Menu:AddOption( "Edit Color", function() 
                            BRICKS_SERVER.Func.ColorRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "newColorQuery" ), val, function( color ) 
                                BS_ConfigCopyTable.GENERAL.Rarities[v.Key][3][key] = color
                                self:Refresh()
                                BRICKS_SERVER.Func.ConfigChange( "GENERAL" )
                            end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ) )
                        end )
                        if( #v[3] > 2 ) then
                            colorButton.Menu:AddOption( "Remove", function() 
                                if( #v[3] <= 2 ) then return end

                                table.remove( BS_ConfigCopyTable.GENERAL.Rarities[v.Key][3], key )
                                self:Refresh()
                                BRICKS_SERVER.Func.ConfigChange( "GENERAL" )
                            end )
                        end
                        colorButton.Menu:Open( colorButton, x, y-(colorButton.Menu:GetTall()/2) )
                    end )
                end

                colorsBack:SetWide( colorsBack:GetWide()+colorsBack:GetTall()+((colorsBack:GetWide() > 0 and 5) or 0) )

                local colorAddButton = vgui.Create( "DButton", colorsBack )
                colorAddButton:SetText( "" )
                colorAddButton:Dock( LEFT )
                colorAddButton:DockMargin( 0, 0, 5, 0 )
                colorAddButton:SetWide( colorsBack:GetTall() )
                local alpha = 0
                local addMat = Material( "materials/bricks_server/add_16_thin.png" )
                colorAddButton.Paint = function( self2, w, h )
                    draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )
        
                    if( not self2:IsDown() and self2:IsHovered() ) then
                        alpha = math.Clamp( alpha+10, 0, 255 )
                    else
                        alpha = math.Clamp( alpha-10, 0, 255 )
                    end
            
                    surface.SetAlphaMultiplier( alpha/255 )
                    draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )
                    surface.SetAlphaMultiplier( 1 )
            
                    BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 0 ), 8 )
        
                    surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6, 20+(235*(alpha/255)) ) )
                    surface.SetMaterial( addMat )
                    local iconSize = 16
                    surface.DrawTexturedRect( (h-iconSize)/2, (h/2)-(iconSize/2), iconSize, iconSize )
                end
                colorAddButton.DoClick = function()
                    BRICKS_SERVER.Func.ColorRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "newColorQuery" ), Color( 125, 125, 125 ), function( color ) 
                        table.insert( BS_ConfigCopyTable.GENERAL.Rarities[v.Key][3], color )
                        self:Refresh()
                        BRICKS_SERVER.Func.ConfigChange( "GENERAL" )
                    end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ) )
                end
            else
                colorsBack.AddColor( v[3], function()
                    BRICKS_SERVER.Func.ColorRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "newColorQuery" ), v[3], function( color ) 
                        BS_ConfigCopyTable.GENERAL.Rarities[v.Key][3] = color
                        self:Refresh()
                        BRICKS_SERVER.Func.ConfigChange( "GENERAL" )
                    end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ) )
                end )
            end
        end
    end
end

function PANEL:Paint( w, h )
    
end

vgui.Register( "bricks_server_config_rarities", PANEL, "DPanel" )