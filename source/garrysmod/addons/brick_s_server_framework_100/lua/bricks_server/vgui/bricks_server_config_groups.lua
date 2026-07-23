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
    local textX, textY = surface.GetTextSize( "Create Group" )
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

        draw.SimpleText( "Create Group", "BRICKS_SERVER_Font20", 12+iconSize+5, h/2, BRICKS_SERVER.Func.GetTheme( 6, 20+(235*(alpha/255)) ), 0, TEXT_ALIGN_CENTER )
    end
    createNewButton.DoClick = function()
        BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "newGroupName" ), BRICKS_SERVER.Func.L( "groupName" ), function( text ) 
            for key, val in pairs( (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).GENERAL.Groups ) do
                if( val[1] == text ) then
                    BRICKS_SERVER.Func.CreateTopNotification( BRICKS_SERVER.Func.L( "groupAlreadyExists" ), 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
                    return
                end
            end
            
            table.insert( BS_ConfigCopyTable.GENERAL.Groups, { text, {} } )
            self:Refresh()
            BRICKS_SERVER.Func.ConfigChange( "GENERAL" )
        end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), false )
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
    self.slotWide, self.slotTall = (gridWide-((slotsWide-1)*self.spacing))/slotsWide, 60+10+40+10+60

    self.slotPanels = {}
    for i = 1, slotsWide do
        self.slotPanels[i] = vgui.Create( "DPanel", self.scrollPanel )
        self.slotPanels[i]:SetPos( ((i-1)*(self.slotWide+self.spacing)), 0 )
        self.slotPanels[i]:SetSize( self.slotWide, 0 )
        self.slotPanels[i].slotCount = 0
        self.slotPanels[i].Paint = function() end
    end

    self:Refresh()
end

function PANEL:Refresh()
    local removeMat = Material( "materials/bricks_server/delete.png" )
    local editMat = Material( "materials/bricks_server/edit.png" )
    local upMat = Material( "materials/bricks_server/up.png" )
    local downMat = Material( "materials/bricks_server/down.png" )

    for k, v in ipairs( self.slotPanels ) do
        v:Clear()
        v:SetTall( 0 )
        v.slotCount = 0
    end

    for k, v in ipairs( BS_ConfigCopyTable.GENERAL.Groups ) do
        if( self.searchBar:GetValue() != "" and not string.find( string.lower( v[1] ), string.lower( self.searchBar:GetValue() ) ) ) then
            continue
        end

        local slotParent = self.slotPanels[1]
        for key, val in ipairs( self.slotPanels ) do
            if( val.slotCount < slotParent.slotCount ) then
                slotParent = val
                break
            end
        end

        slotParent.slotCount = slotParent.slotCount+1
        slotParent.targetHeight = slotParent:GetTall()+self.slotTall+(slotParent.slotCount == 1 and 0 or self.spacing)
        slotParent:SetTall( slotParent.targetHeight )

        surface.SetFont( "BRICKS_SERVER_Font25" )
        local headerX, headerY = surface.GetTextSize( v[1] )

        local groupCount = table.Count( v[2] )
        surface.SetFont( "BRICKS_SERVER_Font17" )
        local groupX, groupY = surface.GetTextSize( groupCount .. " User Group" .. (groupCount != 1 and "s" or "") )

        local contentH = headerY+groupY-10

        local topH = 60
        local groupBack = vgui.Create( "DPanel", slotParent )
        groupBack:Dock( TOP )
        groupBack:DockMargin( 0, 0, 0, self.spacing )
        groupBack:DockPadding( 0, topH, 0, 0 )
        groupBack:SetTall( self.slotTall )
        groupBack.targetHeight = self.slotTall
        groupBack.Paint = function( self2, w, h )
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

            draw.RoundedBoxEx( 8, 0, 0, w, topH, BRICKS_SERVER.Func.GetTheme( 3 ), true, true, false, false )
            draw.RoundedBoxEx( 8, 0, 0, w, topH, BRICKS_SERVER.Func.GetTheme( 1, 75 ), true, true, false, false )

            draw.SimpleText( v[1] .. " - " .. k, "BRICKS_SERVER_Font25", w/2, (topH/2)-(contentH/2)-4, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
            draw.SimpleText( groupCount .. " User Group" .. (groupCount != 1 and "s" or ""), "BRICKS_SERVER_Font17", w/2, (topH/2)+(contentH/2), BRICKS_SERVER.Func.GetTheme( 6, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
        end

        local actionBack = vgui.Create( "DPanel", groupBack )
        actionBack:Dock( TOP )
        actionBack:DockMargin( 10, 10, 10, 0 )
        actionBack:SetTall( 40 )
        actionBack:DockPadding( 0, 0, 10, 0 )
        actionBack.Paint = function( self2, w, h ) end
        actionBack.AddButton = function( self2, material, func )
            local button = vgui.Create( "DButton", self2 )
            button:Dock( LEFT )
            button:SetWide( self2:GetTall() )
            button:DockMargin( 0, 0, 5, 0 )
            button:SetText( "" )
            local alpha = 0
            local x, y = 0, 0
            button.Paint = function( self3, w, h )
                local toScreenX, toScreenY = self3:LocalToScreen( 0, 0 )
                if( x != toScreenX or y != toScreenY ) then
                    x, y = toScreenX, toScreenY
                end
        
                if( self3:IsHovered() ) then
                    alpha = math.Clamp( alpha+10, 0, 105 )
                else
                    alpha = math.Clamp( alpha-10, 0, 105 )
                end
        
                draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )
                draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3, 150+alpha ) )
        
                surface.SetMaterial( material )
                surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6, 150+alpha ) )
                local iconSize = 24
                surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
            end
            button.DoClick = function()
                func( x, y, button:GetWide(), button:GetWide() )
            end
        end

        actionBack:AddButton( removeMat, function( x, y, w, h )
            table.remove( BS_ConfigCopyTable.GENERAL.Groups, k )
            self:Refresh()
            BRICKS_SERVER.Func.ConfigChange( "GENERAL" )
        end )
        actionBack:AddButton( editMat, function( x, y, w, h )
            actionBack.Menu = vgui.Create( "bricks_server_dmenu" )
            actionBack.Menu:AddOption( BRICKS_SERVER.Func.L( "editUserGroups" ), function()
                BRICKS_SERVER.Func.CreateGroupEditor( (v[2] or {}), function( userGroups ) 
                    BS_ConfigCopyTable.GENERAL.Groups[k][2] = userGroups or {}
                    self:Refresh()
                    BRICKS_SERVER.Func.ConfigChange( "GENERAL" )
                end, function() end, true )
            end )
            actionBack.Menu:AddOption( BRICKS_SERVER.Func.L( "editColor" ), function()
                BRICKS_SERVER.Func.ColorRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "newGroupColor" ), (v[3] or BRICKS_SERVER.Func.GetTheme( 5 )), function( color ) 
                    BS_ConfigCopyTable.GENERAL.Groups[k][3] = color or BRICKS_SERVER.Func.GetTheme( 5 )
                    self:Refresh()
                    BRICKS_SERVER.Func.ConfigChange( "GENERAL" )
                end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ) )
            end )
            actionBack.Menu:AddOption( BRICKS_SERVER.Func.L( "editName" ), function()
                BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "newGroupName" ), (v[1] or "GroupName"), function( text ) 
                    for key, val in pairs( BS_ConfigCopyTable.GENERAL.Groups ) do
                        if( val[1] == text ) then
                            notification.AddLegacy( BRICKS_SERVER.Func.L( "groupAlreadyExists" ), 1, 5 )
                            return
                        end
                    end
                    
                    BS_ConfigCopyTable.GENERAL.Groups[k][1] = text
                    self:Refresh()
                    BRICKS_SERVER.Func.ConfigChange( "GENERAL" )
                end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), false )
            end )
            actionBack.Menu:Open()
            actionBack.Menu:SetPos( x+w+5, y+(h/2)-(actionBack.Menu:GetTall()/2) )
        end )
        actionBack:AddButton( downMat, function( x, y, w, h )
            if( k+1 <= #BS_ConfigCopyTable.GENERAL.Groups ) then
                if( BS_ConfigCopyTable.GENERAL.Groups[k+1] ) then
                    BS_ConfigCopyTable.GENERAL.Groups[k] = BS_ConfigCopyTable.GENERAL.Groups[k+1]
                end

                BS_ConfigCopyTable.GENERAL.Groups[k+1] = v
                self:Refresh()
                BRICKS_SERVER.Func.ConfigChange( "GENERAL" )
            end
        end )
        actionBack:AddButton( upMat, function( x, y, w, h )
            if( k-1 >= 1 ) then
                if( BS_ConfigCopyTable.GENERAL.Groups[k-1] ) then
                    BS_ConfigCopyTable.GENERAL.Groups[k] = BS_ConfigCopyTable.GENERAL.Groups[k-1]
                end

                BS_ConfigCopyTable.GENERAL.Groups[k-1] = v
                self:Refresh()
                BRICKS_SERVER.Func.ConfigChange( "GENERAL" )
            end
        end )

        local rarityBox = vgui.Create( "bricks_server_raritybox", groupBack )
        rarityBox:SetSize( self.slotWide, 10 )
        rarityBox:Dock( BOTTOM )
        rarityBox:SetRarityInfo( (istable( v[3] ) and v[3][1] == "") and v[3] or { "", "SolidColor", (v[3] or BRICKS_SERVER.Func.GetTheme( 5 )) } )
        rarityBox:SetCornerRadius( 8 )
        rarityBox:SetRoundedBoxDimensions( false, -10, false, 20 )

        local userGroupsBack = vgui.Create( "DPanel", groupBack )
        userGroupsBack:Dock( TOP )
        userGroupsBack:DockMargin( 10, 10, 10, 10 )
        userGroupsBack:SetTall( 40 )
        userGroupsBack.Paint = function( self2, w, h ) 
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )
        end

        userGroupsBack.expandButton = vgui.Create( "DButton", userGroupsBack )
        userGroupsBack.expandButton:Dock( TOP )
        userGroupsBack.expandButton:SetTall( userGroupsBack:GetTall() )
        userGroupsBack.expandButton:SetText( "" )
        local alpha = 0
        local arrow = Material( "bricks_server/down_16.png" )
        userGroupsBack.expandButton.textureRotation = -90
        userGroupsBack.expandButton.Paint = function( self2, w, h )
            local expanded = userGroupsBack:GetTall() > 40

            if( expanded ) then
                alpha = math.Clamp( alpha+5, 0, 75 )
            elseif( not self2:IsDown() and self2:IsHovered() ) then
                alpha = math.Clamp( alpha+5, 0, 100 )
            else
                alpha = math.Clamp( alpha-5, 0, 100 )
            end

            draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3, 150 ), true, true, not expanded, not expanded )

            surface.SetAlphaMultiplier( alpha/255 )
            draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ), true, true, not expanded, not expanded )
            surface.SetAlphaMultiplier( 1 )

            draw.SimpleText( "Edit User Groups", "BRICKS_SERVER_Font20", w/2, h/2-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

            surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
            surface.SetMaterial( arrow )
            local iconSize = 16
            surface.DrawTexturedRectRotated( w-((h-iconSize)/2)-(iconSize/2), h/2, iconSize, iconSize, math.Clamp( (self2.textureRotation or 0), -90, 0 ) )
        end
        userGroupsBack.expandButton.DoAnim = function( expanding )
            local anim = userGroupsBack.expandButton:NewAnimation( 0.2, 0, -1 )
        
            anim.Think = function( anim, pnl, fraction )
                if( expanding ) then
                    userGroupsBack.expandButton.textureRotation = (1-fraction)*-90
                else
                    userGroupsBack.expandButton.textureRotation = fraction*-90
                end
            end
        end
        userGroupsBack.expandButton.DoClick = function()
            userGroupsBack.Expanded = not userGroupsBack.Expanded

            if( userGroupsBack.Expanded ) then
                groupBack.targetHeight = groupBack.targetHeight+userGroupsBack.expandedExtraH
                slotParent.targetHeight = slotParent.targetHeight+userGroupsBack.expandedExtraH
                userGroupsBack:SizeTo( self.slotWide-20, 40+userGroupsBack.expandedExtraH, 0.2 )
                userGroupsBack.expandButton.DoAnim( true )
            else
                groupBack.targetHeight = groupBack.targetHeight-userGroupsBack.expandedExtraH
                slotParent.targetHeight = slotParent.targetHeight-userGroupsBack.expandedExtraH
                userGroupsBack:SizeTo( self.slotWide-20, 40, 0.2 )
                userGroupsBack.expandButton.DoAnim( false )
            end

            groupBack:SizeTo( self.slotWide, groupBack.targetHeight, 0.2 )
            slotParent:SizeTo( self.slotWide, slotParent.targetHeight, 0.2 )
        end

        userGroupsBack.searchBar = vgui.Create( "DPanel", userGroupsBack )
        userGroupsBack.searchBar:Dock( TOP )
        userGroupsBack.searchBar:SetTall( 30 )
        local search = Material( "materials/bricks_server/search_16.png" )
        local alpha = 0
        userGroupsBack.searchBar.Paint = function( self2, w, h )
            surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3, 100 ) )
            surface.DrawRect( 0, 0, w, h )
    
            if( self2.entry:IsEditing() ) then
                alpha = math.Clamp( alpha+5, 0, 100 )
            else
                alpha = math.Clamp( alpha-5, 0, 100 )
            end
            
            surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2, alpha ) )
            surface.DrawRect( 0, 0, w, h )
        
            surface.SetDrawColor( 255, 255, 255, 20+((alpha/100)*255) )
            surface.SetMaterial( search )
            local size = 16
            surface.DrawTexturedRect( w-size-(h-size)/2, (h-size)/2, size, size )
        end
    
        userGroupsBack.searchBar.entry = vgui.Create( "bricks_server_search", userGroupsBack.searchBar )
        userGroupsBack.searchBar.entry:Dock( FILL )
        userGroupsBack.searchBar.entry:SetFont( "BRICKS_SERVER_Font20" )
        userGroupsBack.searchBar.entry.OnChange = function()
            userGroupsBack.list.RefreshEntries()
        end

        local userGroupTall, userGroupSpacing = 25, 10
        userGroupsBack.list = vgui.Create( "DPanel", userGroupsBack )
        userGroupsBack.list:Dock( TOP )
        userGroupsBack.list:SetTall( 0 )
        userGroupsBack.list:DockMargin( 0, userGroupSpacing, 0, userGroupSpacing )
        userGroupsBack.list.Paint = function( self2, w, h ) end
        userGroupsBack.list.RefreshEntries = function()
            userGroupsBack.list:Clear()
            userGroupsBack.list:SetTall( 0 )

            local possibleUserGroups = BRICKS_SERVER.Func.GetAdminSystemRanks()
            for key, val in pairs( v[2] ) do
                if( not possibleUserGroups[key] ) then
                    BS_ConfigCopyTable.GENERAL.Groups[k][2][key] = nil
                end
            end

            for key, val in pairs( possibleUserGroups ) do
                if( userGroupsBack.searchBar.entry:GetValue() != "" and not string.find( string.lower( val ), string.lower( userGroupsBack.searchBar.entry:GetValue() ) ) ) then
                    continue
                end

                local userGroupEntry = vgui.Create( "DPanel", userGroupsBack.list )
                userGroupEntry:Dock( TOP )
                userGroupEntry:DockMargin( 20, 0, 20, userGroupSpacing )
                userGroupEntry:SetTall( userGroupTall )
                userGroupEntry.Paint = function( self2, w, h )
                    draw.SimpleText( val, "BRICKS_SERVER_Font20", 0, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
                end

                local userGroupButton = vgui.Create( "bricks_server_dcheckbox", userGroupEntry )
                userGroupButton:Dock( RIGHT )
                userGroupButton:SetValue( v[2][key] )
                userGroupButton:SetTitle( "" )
                userGroupButton.backgroundCol = BRICKS_SERVER.Func.GetTheme( 2 )
                userGroupButton.OnChange = function( value )
                    if( value == true ) then
                        BS_ConfigCopyTable.GENERAL.Groups[k][2][key] = true
                    else
                        BS_ConfigCopyTable.GENERAL.Groups[k][2][key] = nil
                    end
                    BRICKS_SERVER.Func.ConfigChange( "GENERAL" )
                end

                userGroupsBack.list:SetTall( userGroupsBack.list:GetTall()+userGroupEntry:GetTall()+(userGroupsBack.list:GetTall() > 0 and userGroupSpacing or 0) )
            end

            if( userGroupsBack.Expanded ) then
                groupBack.targetHeight = groupBack.targetHeight-userGroupsBack.expandedExtraH
                slotParent.targetHeight = slotParent.targetHeight-userGroupsBack.expandedExtraH
    
                userGroupsBack.expandedExtraH = (userGroupSpacing*2)+userGroupsBack.list:GetTall()+userGroupsBack.searchBar:GetTall()

                groupBack.targetHeight = groupBack.targetHeight+userGroupsBack.expandedExtraH
                slotParent.targetHeight = slotParent.targetHeight+userGroupsBack.expandedExtraH
                
                userGroupsBack:SizeTo( self.slotWide-20, 40+userGroupsBack.expandedExtraH, 0.1 )
                groupBack:SizeTo( self.slotWide, groupBack.targetHeight, 0.1 )
                slotParent:SizeTo( self.slotWide, slotParent.targetHeight, 0.1 )
            else
                userGroupsBack.expandedExtraH = (userGroupSpacing*2)+userGroupsBack.list:GetTall()+userGroupsBack.searchBar:GetTall()
            end
        end
        userGroupsBack.list.RefreshEntries()
    end
end

function PANEL:Paint( w, h )
    
end

vgui.Register( "bricks_server_config_groups", PANEL, "DPanel" )