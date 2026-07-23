local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel()
    function self.RefreshPanel()
        self:Clear()

        self.slots = nil
        if( self.grid and IsValid( self.grid ) ) then
            self.grid:Remove()
        end

        local entitySearchBarBack = vgui.Create( "DPanel", self )
        entitySearchBarBack:Dock( TOP )
        entitySearchBarBack:DockMargin( 0, 0, 0, 5 )
        entitySearchBarBack:SetTall( 40 )
        local search = Material( "materials/bricks_server/search.png" )
        local Alpha = 0
        local Alpha2 = 20
        local color1 = BRICKS_SERVER.Func.GetTheme( 2 )
        local entitySearchBar
        entitySearchBarBack.Paint = function( self2, w, h )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
    
            if( entitySearchBar:IsEditing() ) then
                Alpha = math.Clamp( Alpha+5, 0, 100 )
                Alpha2 = math.Clamp( Alpha2+20, 20, 255 )
            else
                Alpha = math.Clamp( Alpha-5, 0, 100 )
                Alpha2 = math.Clamp( Alpha2-20, 20, 255 )
            end
            
            draw.RoundedBox( 5, 0, 0, w, h, Color( color1.r, color1.g, color1.b, Alpha ) )
        
            surface.SetDrawColor( 255, 255, 255, Alpha2 )
            surface.SetMaterial(search)
            local size = 24
            surface.DrawTexturedRect( w-size-(h-size)/2, (h-size)/2, size, size )
        end
    
        entitySearchBar = vgui.Create( "bricks_server_search", entitySearchBarBack )
        entitySearchBar:Dock( FILL )
        
        local entitySpacing = 5
        local gridWide = (ScrW()*0.6)-BRICKS_SERVER.DEVCONFIG.MainNavWidth-20
        local wantedSlotSize = 125*(ScrW()/2560)
        local slotsWide = math.floor( gridWide/wantedSlotSize )
    
        local slotSize = (gridWide-((slotsWide-1)*entitySpacing))/slotsWide
    
        local entityGrid = vgui.Create( "DIconLayout", self )
        entityGrid:Dock( TOP )
        entityGrid:SetSpaceY( entitySpacing )
        entityGrid:SetSpaceX( entitySpacing )
        entityGrid:SetTall( slotSize )

        local function CreateSlot( header, text, doClick, key )
            entityGrid.slots = (entityGrid.slots or 0)+1
            local slots = entityGrid.slots
            local slotsTall = math.ceil( slots/slotsWide )
            local newTall = (slotsTall*slotSize)+((slotsTall-1)*entitySpacing)
            if( entityGrid:GetTall() != newTall ) then
                entityGrid:SetTall( newTall )
            end

            local slotBack = entityGrid:Add( "DButton" )
            slotBack:SetSize( slotSize, slotSize )
            slotBack:SetText( "" )
            local changeAlpha = 0
            local x, y, w, h = 0, 0, slotSize, slotSize
            slotBack.Paint = function( self2, w, h )
                local toScreenX, toScreenY = self2:LocalToScreen( 0, 0 )
                if( x != toScreenX or y != toScreenY ) then
                    x, y = toScreenX, toScreenY
                end

                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

                if( key and BS_ConfigCopyTable.INVENTORY.Whitelist[key] ) then
                    draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
                end
                
                if( self2:IsDown() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 175 )
                elseif( self2:IsHovered() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 100 )
                else
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 100 )
                end

                surface.SetAlphaMultiplier( changeAlpha/255 )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
                surface.SetAlphaMultiplier( 1 )

                draw.SimpleText( header, "BRICKS_SERVER_Font17B", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
                draw.SimpleText( text, "BRICKS_SERVER_Font17", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
            end
            slotBack.DoClick = function( self2 )
                doClick( self2, x, y, w, h )
            end
        end

        function self.FillEntityList()
            entityGrid:Clear()

            if( not BS_ConfigCopyTable.INVENTORY.Whitelist ) then
                BS_ConfigCopyTable.INVENTORY.Whitelist = {}
            end

            entityGrid.slots = 1

            for k, v in pairs( list.Get( "SpawnableEntities" ) ) do
                if( (entitySearchBar:GetValue() or "") != "" and not string.find( string.lower( v.PrintName or "" ), string.lower( entitySearchBar:GetValue() or "" ) ) and not string.find( string.lower( k ), string.lower( entitySearchBar:GetValue() or "" ) ) ) then
                    continue
                end

                local actions = {}
                if( not BS_ConfigCopyTable.INVENTORY.Whitelist[k] ) then
                    actions[BRICKS_SERVER.Func.L( "whitelist" )] = function() 
                        BS_ConfigCopyTable.INVENTORY.Whitelist[k] = { true, true }
                        self.FillEntityList()
                        BRICKS_SERVER.Func.ConfigChange( "INVENTORY" )
                    end
                else
                    actions[BRICKS_SERVER.Func.L( "unWhitelist" )] = function() 
                        BS_ConfigCopyTable.INVENTORY.Whitelist[k] = nil
                        self.FillEntityList()
                        BRICKS_SERVER.Func.ConfigChange( "INVENTORY" )
                    end
                end

                CreateSlot( (v.PrintName or BRICKS_SERVER.Func.L( "nil" )), k, function( slotBack, x, y, w, h )
                    slotBack.Menu = vgui.Create( "bricks_server_dmenu" )
                    for key, val in pairs( actions ) do
                        slotBack.Menu:AddOption( key, val )
                    end
                    slotBack.Menu:Open()
                    slotBack.Menu:SetPos( x+w+5, y+(h/2)-(slotBack.Menu:GetTall()/2) )
                end, k )
            end

            for k, v in pairs( BS_ConfigCopyTable.INVENTORY.Whitelist ) do
                if( list.Get( "SpawnableEntities" )[k] ) then continue end

                if( (entitySearchBar:GetValue() or "") != "" and not string.find( string.lower( k ), string.lower( entitySearchBar:GetValue() or "" ) ) ) then
                    continue
                end

                local actions = {}
                actions[BRICKS_SERVER.Func.L( "remove" )] = function() 
                    BS_ConfigCopyTable.INVENTORY.Whitelist[k] = nil
                    self.FillEntityList()
                    BRICKS_SERVER.Func.ConfigChange( "INVENTORY" )
                end

                CreateSlot( BRICKS_SERVER.Func.L( "custom" ), k, function( slotBack, x, y, w, h )
                    slotBack.Menu = vgui.Create( "bricks_server_dmenu" )
                    for key, val in pairs( actions ) do
                        slotBack.Menu:AddOption( key, val )
                    end
                    slotBack.Menu:Open()
                    slotBack.Menu:SetPos( x+w+5, y+(h/2)-(slotBack.Menu:GetTall()/2) )
                end, k )
            end

            local addNewButton = entityGrid:Add( "DButton" )
            addNewButton:SetText( "" )
            addNewButton:SetSize( slotSize, slotSize )
            local changeAlpha = 0
            local newMat = Material( "materials/bricks_server/add_64.png")
            addNewButton.Paint = function( self2, w, h )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
                
                if( self2:IsDown() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 175 )
                elseif( self2:IsHovered() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 100 )
                else
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 100 )
                end

                surface.SetAlphaMultiplier( changeAlpha/255 )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )
                surface.SetAlphaMultiplier( 1 )

                surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
                surface.SetMaterial( newMat )
                local iconSize = 64
                surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )

                draw.SimpleText( BRICKS_SERVER.Func.L( "addCustom" ), "BRICKS_SERVER_Font17", w/2, h-10, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
            end
            addNewButton.DoClick = function()
                BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "entClassWhitelist" ), "", function( text ) 
                    if( list.Get( "SpawnableEntities" )[text] ) then
                        notification.AddLegacy( BRICKS_SERVER.Func.L( "entClassAlreadyOnList" ), 1, 5 )
                        return
                    end

                    BS_ConfigCopyTable.INVENTORY.Whitelist[text] = { true, true }
                    self.FillEntityList()
                    BRICKS_SERVER.Func.ConfigChange( "INVENTORY" )
                end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ) )
            end
        end
        self.FillEntityList()

        entitySearchBar.OnChange = function()
            self.FillEntityList()
        end
    end
    self.RefreshPanel()
end

function PANEL:Paint( w, h )
    
end

vgui.Register( "bricks_server_config_itemwhitelist", PANEL, "bricks_server_scrollpanel" )