local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel()
    self.panelWide = ScrW()*0.6-BRICKS_SERVER.DEVCONFIG.MainNavWidth

    surface.SetFont( "BRICKS_SERVER_Font20" )
    local headerX, headerY = surface.GetTextSize( BRICKS_SERVER.Func.L( "changesServerRestart" ) )
    local fullWidth = 60+headerX+35

    self.topBar = vgui.Create( "DPanel", self )
    self.topBar:Dock( TOP )
    self.topBar:SetTall( 60 )
    local noticeMat = Material( "bricks_server/warning.png" )
    self.topBar.Paint = function( self, w, h ) 
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
        surface.DrawRect( 0, 0, w, h )

        -- Notice --
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3 ) )
        surface.DrawRect( w-fullWidth, 0, fullWidth, h )
        
        surface.SetDrawColor( BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
        surface.DrawRect( w-fullWidth, 0, h, h )

        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
        surface.SetMaterial( noticeMat )
        local iconSize = 32
        surface.DrawTexturedRect( w-fullWidth+(h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )

        draw.SimpleText( BRICKS_SERVER.Func.L( "changesServerRestart" ), "BRICKS_SERVER_Font20", w-fullWidth+60+((fullWidth-60)/2), h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end 

    self.searchBar = vgui.Create( "bricks_server_searchbar", self.topBar )
    self.searchBar:Dock( LEFT )
    self.searchBar:DockMargin( 25, 10, 10, 10 )
    self.searchBar:SetWide( math.min( ScrW()*0.2, self.panelWide-fullWidth-50 ) )
    self.searchBar:SetBackColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
    self.searchBar:SetHighlightColor( BRICKS_SERVER.Func.GetTheme( 0 ) )
    self.searchBar.OnChange = function()
        self:Refresh()
    end

    self.scrollPanel = vgui.Create( "bricks_server_scrollpanel_bar", self )
    self.scrollPanel:Dock( FILL )
    self.scrollPanel:DockMargin( 25, 25, 25, 25 )
    self.scrollPanel.Paint = function( self, w, h ) end 

    local spacing = 10
    local gridWide = self.panelWide-50-10-spacing
    local slotSize = 320
    local slotsWide = math.floor( gridWide/slotSize )
    self.slotWide, self.slotTall = (gridWide-((slotsWide-1)*spacing))/slotsWide, 0

    self.grid = vgui.Create( "DIconLayout", self.scrollPanel )
    self.grid:Dock( TOP )
    self.grid:SetSpaceY( spacing )
    self.grid:SetSpaceX( spacing )
    self.grid:SetTall( ScrH()*0.65 )

    self:Refresh()
end

function PANEL:Refresh()
    self.grid:Clear()

    local modules = {}
    for k, v in pairs( BRICKS_SERVER.DLCMODULES or {} ) do
        if( self.searchBar:GetValue() != "" and not string.find( string.lower( v.Name ), string.lower( self.searchBar:GetValue() ) ) ) then
            continue
        end

        local addDLC = true

        for key, val in pairs( v.Modules ) do
            if( BRICKS_SERVER.Modules[val] ) then
                addDLC = false
                break
            end
        end

        if( not addDLC ) then continue end

        local module = v
        module.Key = k
        module.DLC = true

        table.insert( modules, module )
    end

    for k, v in pairs( BRICKS_SERVER.Modules or {} ) do
        if( self.searchBar:GetValue() != "" and not string.find( string.lower( v[1] ), string.lower( self.searchBar:GetValue() ) ) ) then
            continue
        end

        table.insert( modules, {
            Key = k,
            Name = v[1],
            Icon = v[2],
            SubModules = v[3]
        } )
    end

    local subModuleTall, subModuleSpacing, iconSpacing = 25, 10, 75
    for k, v in pairs( modules ) do
        surface.SetFont( "BRICKS_SERVER_Font25" )
        local textX, textY = surface.GetTextSize( v.Name )

        local defaultSize = 25+textY+5+iconSpacing+64+iconSpacing+40+10+40+25

        self.slotTall = math.max( defaultSize, self.slotTall )
    end

    for k, v in pairs( modules ) do
        local moduleBack = vgui.Create( "DPanel", self.grid )
        moduleBack:SetSize( self.slotWide, self.slotTall )
        moduleBack.Paint = function( self2, w, h )
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
        end
        
        surface.SetFont( "BRICKS_SERVER_Font25" )
        local textX, textY = surface.GetTextSize( v.Name )

        local moduleName = vgui.Create( "DPanel", moduleBack )
        moduleName:Dock( TOP )
        moduleName:DockMargin( 0, 25, 0, 0 )
        moduleName:SetTall( textY+5 )
        local wide = textX+20
        moduleName.Paint = function( self2, w, h )
            draw.RoundedBox( 8, (w/2)-(wide/2), 0, wide, h, BRICKS_SERVER.Func.GetTheme( 5 ) )

            draw.SimpleText( v.Name, "BRICKS_SERVER_Font25", w/2, h/2-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end

        local moduleIcon = vgui.Create( "DPanel", moduleBack )
        moduleIcon:Dock( TOP )
        moduleIcon:DockMargin( 0, iconSpacing, 0, (not v.DLC and iconSpacing) or 0 )
        moduleIcon:SetTall( 64 )
        local iconMat = Material( v.Icon )
        moduleIcon.Paint = function( self2, w, h )
            surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
            surface.SetMaterial( iconMat )
            local iconSize = 64
            surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
        end

        local subModulesBack
        if( not v.DLC and table.Count( v.SubModules or {} ) > 0 ) then
            subModulesBack = vgui.Create( "DPanel", moduleBack )
            subModulesBack:Dock( v.Key != "default" and TOP or BOTTOM )
            subModulesBack:DockMargin( 10, 0, 10, v.Key != "default" and 0 or 10 )
            subModulesBack:SetTall( 40 )
            subModulesBack.Paint = function( self2, w, h ) end
            subModulesBack.FillSubModules = function( self2 )
                subModulesBack.list:Clear()

                for key, val in pairs( v.SubModules or {} ) do
                    local subModuleBack = vgui.Create( "DPanel", subModulesBack.list )
                    subModuleBack:Dock( TOP )
                    subModuleBack:DockMargin( 20, 0, 20, subModuleSpacing )
                    subModuleBack:SetTall( subModuleTall )
                    subModuleBack.Paint = function( self2, w, h )
                        draw.SimpleText( val, "BRICKS_SERVER_Font20", 0, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
                    end
        
                    local moduleTable = BS_ConfigCopyTable.MODULES[v.Key]
                    local subModuleEnabled = moduleTable and moduleTable[1] == true and moduleTable[2] and moduleTable[2][key] and moduleTable[2][key] == true
        
                    local subModuleButton = vgui.Create( "bricks_server_dcheckbox", subModuleBack )
                    subModuleButton:Dock( RIGHT )
                    subModuleButton:SetValue( subModuleEnabled )
                    subModuleButton:SetTitle( "" )
                    subModuleButton.backgroundCol = BRICKS_SERVER.Func.GetTheme( 2 )
                    subModuleButton.OnChange = function( value )
                        BS_ConfigCopyTable.MODULES[v.Key][2][key] = value
                        BRICKS_SERVER.Func.ConfigChange( "MODULES" )
                    end

                    if( not moduleTable or moduleTable[1] != true ) then
                        subModuleButton:SetDisabled( true )
                    end
                end
            end

            local subModulesExpand = vgui.Create( "DButton", subModulesBack )
            subModulesExpand:Dock( TOP )
            subModulesExpand:SetTall( subModulesBack:GetTall() )
            subModulesExpand:SetText( "" )
            local alpha = 0
            local arrow = Material( "bricks_server/down_16.png" )
            subModulesExpand.textureRotation = -90
            subModulesExpand.Paint = function( self2, w, h )
                local expanded = subModulesBack:GetTall() > 40

                if( not self2:IsDown() and self2:IsHovered() ) then
                    alpha = math.Clamp( alpha+5, 0, 150 )
                else
                    alpha = math.Clamp( alpha-5, 0, 150 )
                end

                draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ), true, true, not expanded, not expanded )

                surface.SetAlphaMultiplier( alpha/255 )
                draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ), true, true, not expanded, not expanded )
                surface.SetAlphaMultiplier( 1 )

                BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 1 ), 8 )

                draw.SimpleText( table.Count( v.SubModules or {} ) .. " Sub Modules", "BRICKS_SERVER_Font20", w/2, h/2-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

                surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
                surface.SetMaterial( arrow )
                local iconSize = 16
                surface.DrawTexturedRectRotated( w-((h-iconSize)/2)-(iconSize/2), h/2, iconSize, iconSize, math.Clamp( (self2.textureRotation or 0), -90, 0 ) )
            end
            subModulesExpand.DoAnim = function( expanding )
                local anim = subModulesExpand:NewAnimation( 0.2, 0, -1 )
            
                anim.Think = function( anim, pnl, fraction )
                    if( expanding ) then
                        subModulesExpand.textureRotation = (1-fraction)*-90
                    else
                        subModulesExpand.textureRotation = fraction*-90
                    end
                end
            end
            subModulesExpand.DoClick = function()
                if( table.Count( v.SubModules or {} ) <= 0 ) then return end

                subModulesBack.Expanded = not subModulesBack.Expanded

                if( subModulesBack.Expanded ) then
                    subModulesBack.FillSubModules()

                    local listTall = (table.Count( v.SubModules or {} )*(subModuleTall+subModuleSpacing))+subModuleSpacing
                    subModulesBack:SizeTo( self.slotWide-20, 40+listTall, 0.2 )
                    moduleBack:SizeTo( self.slotWide, self.slotTall+listTall, 0.2 )
                    subModulesExpand.DoAnim( true )
                else
                    subModulesBack:SizeTo( self.slotWide-20, 40, 0.2, 0, -1, function() 
                        if( not IsValid( subModulesBack.list ) ) then return end

                        subModulesBack.list:Clear()
                    end )

                    moduleBack:SizeTo( self.slotWide, self.slotTall, 0.2 )

                    subModulesExpand.DoAnim( false )
                end
            end

            subModulesBack.list = vgui.Create( "DPanel", subModulesBack )
            subModulesBack.list:Dock( FILL )
            subModulesBack.list:DockPadding( 0, subModuleSpacing, 0, 0 )
            subModulesBack.list.Paint = function( self2, w, h ) 
                draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ), false, false, true, true )
            end
        end
 
        if( v.Key != "default" ) then
            local moduleButton = vgui.Create( "DButton", moduleBack )
            moduleButton:Dock( BOTTOM )
            moduleButton:DockMargin( 10, 0, 10, 10 )
            moduleButton:SetTall( 40 )
            moduleButton:SetText( "" )
            local alpha = 0
            moduleButton.Paint = function( self2, w, h )
                local buttonText, buttonColor, buttonDownColor = BRICKS_SERVER.Func.L( "purchase" ), BRICKS_SERVER.Func.GetTheme( 5 ), BRICKS_SERVER.Func.GetTheme( 4 )

                if( not v.DLC ) then
                    local moduleEnabled = ((BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).MODULES or {})[v.Key] and ((BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).MODULES or {})[v.Key][1] == true

                    buttonText = (moduleEnabled and BRICKS_SERVER.Func.L( "enabled" )) or BRICKS_SERVER.Func.L( "disabled" )
                    buttonColor = (moduleEnabled and BRICKS_SERVER.DEVCONFIG.BaseThemes.Green) or BRICKS_SERVER.DEVCONFIG.BaseThemes.Red
                    buttonDownColor = (moduleEnabled and BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkGreen) or BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkRed
                elseif( not v.Link ) then
                    buttonText = BRICKS_SERVER.Func.L( "comingSoon" )
                    buttonColor = BRICKS_SERVER.Func.GetTheme( 2 )
                    buttonDownColor = BRICKS_SERVER.Func.GetTheme( 1 )
                end

                if( not self2:IsDown() and self2:IsHovered() ) then
                    alpha = math.Clamp( alpha+5, 0, 200 )
                else
                    alpha = math.Clamp( alpha-5, 0, 255 )
                end

                draw.RoundedBox( 5, 0, 0, w, h, buttonColor )

                surface.SetAlphaMultiplier( alpha/255 )
                draw.RoundedBox( 5, 0, 0, w, h, buttonDownColor )
                surface.SetAlphaMultiplier( 1 )

                BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, buttonDownColor )

                draw.SimpleText( buttonText, "BRICKS_SERVER_Font20", w/2, h/2-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end
            moduleButton.DoClick = function()
                if( not v.DLC ) then
                    BS_ConfigCopyTable.MODULES[v.Key] = BS_ConfigCopyTable.MODULES[v.Key] or {}
                    BS_ConfigCopyTable.MODULES[v.Key][1] = not BS_ConfigCopyTable.MODULES[v.Key][1]
                    BS_ConfigCopyTable.MODULES[v.Key][2] = BS_ConfigCopyTable.MODULES[v.Key][2] or {}
                    BRICKS_SERVER.Func.ConfigChange( "MODULES" )

                    if( IsValid( subModulesBack ) and subModulesBack.Expanded ) then
                        subModulesBack.FillSubModules()
                    end
                elseif( v.Link ) then
                    gui.OpenURL( v.Link )
                end
            end
        end

        if( v.Description ) then
            local moduleIcon = vgui.Create( "DPanel", moduleBack )
            moduleIcon:Dock( TOP )
            moduleIcon:DockMargin( 0, 35, 0, 0 )
            moduleIcon:SetTall( 20 )
            moduleIcon.Paint = function( self2, w, h )
                draw.SimpleText( BRICKS_SERVER.Func.L( "features" ), "BRICKS_SERVER_Font17", w/2, h/2-1, BRICKS_SERVER.Func.GetTheme( 5 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end

            local moduleDescription = vgui.Create( "DPanel" , moduleBack )
            moduleDescription:Dock( FILL )
            moduleDescription:DockMargin( 25, 5, 25, 5 )
            moduleDescription.Paint = function( self2, w, h )
                local description = BRICKS_SERVER.Func.TextWrap( v.Description, "BRICKS_SERVER_Font17", w )

                BRICKS_SERVER.Func.DrawNonParsedText( description, "BRICKS_SERVER_Font17", 0, 0, BRICKS_SERVER.Func.GetTheme( 6 ), 0 )
            end
        end
    end
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_config_modules", PANEL, "DPanel" )