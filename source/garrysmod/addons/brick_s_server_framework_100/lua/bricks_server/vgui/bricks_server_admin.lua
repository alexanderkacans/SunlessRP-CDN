local PANEL = {}

function PANEL:Init()
    if( BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) ) then
        self.panelWide = ScrW()*0.6-BRICKS_SERVER.DEVCONFIG.MainNavWidth
        
        self.topBar = vgui.Create( "DPanel", self )
        self.topBar:Dock( TOP )
        self.topBar:SetTall( 60 )
        self.topBar.Paint = function( self, w, h ) 
            surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
            surface.DrawRect( 0, 0, w, h )
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

        local slotsWide = 3
        self.spacing = 10
        local gridWide = self.panelWide-50-10-self.spacing
        self.slotWide, self.slotTall = (gridWide-((slotsWide-1)*self.spacing))/slotsWide, 75
    
        self.slotPanels = {}
        for i = 1, slotsWide do
            self.slotPanels[i] = vgui.Create( "DPanel", self.scrollPanel )
            self.slotPanels[i]:SetPos( ((i-1)*(self.slotWide+self.spacing)), 0 )
            self.slotPanels[i]:SetSize( self.slotWide, 0 )
            self.slotPanels[i].slotCount = 0
            self.slotPanels[i].Paint = function() end
        end

        self.loadedPlayers = {}
        
        self:Refresh()
    end
end

function PANEL:Refresh()
    for k, v in ipairs( self.slotPanels ) do
        v:Clear()
        v:SetTall( 0 )
        v.slotCount = 0
    end

    local actionCategories = {}
    for k, v in pairs( BRICKS_SERVER.AdminPlayerFunctions or {} ) do
        if( not actionCategories[v[2]] ) then
            actionCategories[v[2]] = {}
        end

        table.insert( actionCategories[v[2]], v )
    end

    self.loadedPlayers = {}
    for k, v in ipairs( player.GetAll() ) do
        self.loadedPlayers[v] = true

        if( self.searchBar:GetValue() != "" and not string.find( string.lower( v:Nick() ), string.lower( self.searchBar:GetValue() ) ) and not string.find( string.lower( v:SteamID64() or "" ), string.lower( self.searchBar:GetValue() ) ) ) then
            continue
        end

        local slotParent
        for k, v in ipairs( self.slotPanels ) do
            local nextPanel = k == #self.slotPanels and self.slotPanels[1] or self.slotPanels[k+1]
            if( v.slotCount != 0 and v.slotCount > nextPanel.slotCount ) then continue end

            slotParent = v
            v.slotCount = v.slotCount+1
            v.targetHeight = v:GetTall()+self.slotTall+(v.slotCount == 1 and 0 or self.spacing)
            v:SetTall( v.targetHeight )
            break
        end

        local playerBack = vgui.Create( "DPanel", slotParent )
        playerBack:Dock( TOP )
        playerBack:DockMargin( 0, 0, 0, self.spacing )
        playerBack:SetTall( self.slotTall )
        playerBack.Paint = function( self2, w, h )
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
        end

        local name = v:Nick()
        local steamID = v:SteamID()

        local group = BRICKS_SERVER.Func.GetGroup( v )
        local rankName = group and group[1] or BRICKS_SERVER.Func.GetAdminGroup( v )

        surface.SetFont( "BRICKS_SERVER_Font23" )
        local nameX, nameY = surface.GetTextSize( name )

        surface.SetFont( "BRICKS_SERVER_Font18" )
        local textX, textY = surface.GetTextSize( rankName )
        local boxW, boxH = textX+10, textY+3

        local playerInfo = vgui.Create( "DPanel", playerBack )
        playerInfo:Dock( TOP )
        playerInfo:SetTall( self.slotTall )
        local alpha = 0
        playerInfo.Paint = function( self2, w, h )
            if( not IsValid( self2.button ) ) then return end

            -- BUTTON PAINT --
            local expanded = playerBack:GetTall() > self.slotTall

            if( expanded ) then
                alpha = math.Clamp( alpha+5, 0, 75 )
            elseif( not self2.button:IsDown() and self2.button:IsHovered() ) then
                alpha = math.Clamp( alpha+5, 0, 100 )
            else
                alpha = math.Clamp( alpha-5, 0, 100 )
            end

            draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ), true, true, not expanded, not expanded )

            surface.SetAlphaMultiplier( alpha/255 )
            draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ), true, true, not expanded, not expanded )
            surface.SetAlphaMultiplier( 1 )

            -- INFO --
            draw.SimpleText( name, "BRICKS_SERVER_Font23", h+5, h/2+2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_BOTTOM )
            draw.SimpleText( steamID != "NULL" and steamID or "BOT", "BRICKS_SERVER_Font17", h+5, h/2-2, BRICKS_SERVER.Func.GetTheme( 6, 75 ), 0, 0 )

            draw.RoundedBox( 8, h+5+nameX+5, (h/2+2)-boxH-3, boxW, boxH, ((group or {})[3] or BRICKS_SERVER.Func.GetTheme( 5 )) )
            draw.SimpleText( rankName, "BRICKS_SERVER_Font18", h+5+nameX+5+(boxW/2), (h/2+2-3)-(boxH/2), BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end

        local playerAvatar = vgui.Create( "bricks_server_rounded_avatar", playerInfo )
        local size = playerInfo:GetTall()-10
        playerAvatar:SetSize( size, size )
        playerAvatar:SetPos( 5, 5 )
        playerAvatar.rounded = 8
        playerAvatar:SetPlayer( v, 128 )

        playerInfo.button = vgui.Create( "DButton", playerInfo )
        playerInfo.button:Dock( FILL )
        playerInfo.button:SetText( "" )
        playerInfo.button.textureRotation = -90
        playerInfo.button.Paint = function( self2, w, h ) end
        playerInfo.button.DoClick = function()
            playerBack.Expanded = not playerBack.Expanded

            if( playerBack.Expanded ) then
                slotParent.targetHeight = slotParent.targetHeight+playerBack.expandedExtraH
                playerBack:SizeTo( self.slotWide, self.slotTall+playerBack.expandedExtraH, 0.2 )
            else
                slotParent.targetHeight = slotParent.targetHeight-playerBack.expandedExtraH
                playerBack:SizeTo( self.slotWide, self.slotTall, 0.2 )
            end

            slotParent:SizeTo( self.slotWide, slotParent.targetHeight, 0.2 )
        end

        local actionPanelW, actionPanelH = self.slotWide-20, 40
        local function setChildrenWidths( parent )
            if( not parent ) then return end

            local totalChildrenW = 0
            local children = parent:GetChildren()
            for k, v in ipairs( children ) do
                totalChildrenW = totalChildrenW+v:GetWide()
            end

            for k, v in ipairs( children ) do
                v:SetWide( (v:GetWide()/totalChildrenW)*(actionPanelW-(#children-1)*5) )
            end
        end

        local actionPanels = {}
        for key, val in pairs( actionCategories ) do
            for key2, val2 in pairs( val ) do
                surface.SetFont( "BRICKS_SERVER_Font21" )
                local textX, textY = surface.GetTextSize( key .. " " .. val2[1] )
                textX = textX+30

                if( not actionPanels[#actionPanels] or actionPanels[#actionPanels].totalButtonW+textX > actionPanelW ) then
                    if( actionPanels[#actionPanels] ) then
                        setChildrenWidths( actionPanels[#actionPanels] )
                    end

                    actionPanels[#actionPanels+1] = vgui.Create( "DPanel", playerBack )
                    actionPanels[#actionPanels]:Dock( TOP )
                    actionPanels[#actionPanels]:DockMargin( 10, #actionPanels == 1 and 10 or 0, 10, 5 )
                    actionPanels[#actionPanels]:SetTall( actionPanelH )
                    actionPanels[#actionPanels].totalButtonW = 0
                    actionPanels[#actionPanels].Paint = function() end
                end

                actionPanels[#actionPanels].totalButtonW = actionPanels[#actionPanels].totalButtonW+textX+(actionPanels[#actionPanels].totalButtonW != 0 and 5 or 0)

                local playerAction = vgui.Create( "DButton", actionPanels[#actionPanels] )
                playerAction:Dock( LEFT )
                playerAction:SetText( "" )
                playerAction:DockMargin( 0, 0, 5, 0 )
                playerAction:SetWide( textX )
                local alpha = 0
                playerAction.Paint = function( self2, w, h )
                    if( self2:IsHovered() ) then
                        alpha = math.Clamp( alpha+10, 0, 75 )
                    else
                        alpha = math.Clamp( alpha-10, 0, 75 )
                    end
                    
                    draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3, 150 ) )
                    draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2, alpha ) )

                    BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 2, 200 ), 8 )
            
                    draw.SimpleText( key .. " " .. val2[1], "BRICKS_SERVER_Font21", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6, 75+((alpha/75)*180) ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                end
                playerAction.DoClick = function()
                    val2[3]( v )
                end
            end
        end
        setChildrenWidths( actionPanels[#actionPanels] )

        playerBack.expandedExtraH = 20+(#actionPanels*actionPanelH)+((#actionPanels-1)*5)
    end
end

function PANEL:Think()
    if( not self.loadedPlayers ) then return end

    for k, v in pairs( self.loadedPlayers ) do
        if( not IsValid( k ) ) then 
            self:Refresh()
            break 
        end
    end

    for k, v in pairs( player.GetAll() ) do
        if( not self.loadedPlayers[v] ) then 
            self:Refresh()
            break 
        end
    end
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_admin", PANEL, "DPanel" )