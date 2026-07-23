local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel()
    function self.RefreshPanel()
        self:Clear()

        for k, v in pairs( BRICKS_SERVER.BASECONFIG.THEME ) do
            local themeBack = vgui.Create( "DPanel", self )
            themeBack:Dock( TOP )
            themeBack:DockMargin( 0, 0, 0, 5 )
            themeBack:SetTall( 100 )
            local displayColor = BRICKS_SERVER.Func.GetTheme( k ) or Color( 155, 155, 155 )
            themeBack.Paint = function( self2, w, h )
                draw.RoundedBox( 5, 0, 0, w, h, Color( 0, 0, 0 ) )
                draw.RoundedBox( 5, 2, 2, w-4, h-4, displayColor )

                if( k != 6 ) then
                    draw.SimpleText( BRICKS_SERVER.Func.L( "themeColorX", k ), "BRICKS_SERVER_Font33", 15, 5, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                else
                    local textCol = BRICKS_SERVER.Func.GetTheme( 6 )
                    draw.SimpleText( BRICKS_SERVER.Func.L( "themeTextColor" ), "BRICKS_SERVER_Font33", 15, 5, Color( math.abs( textCol.r-255 ), math.abs( textCol.g-255 ), math.abs( textCol.b-255 ) ), 0, 0 )
                end
            end

            local themeMixer = vgui.Create( "DColorMixer", themeBack )
            themeMixer:Dock( RIGHT )
            themeMixer:DockMargin( 5, 5, 5, 5 )
            themeMixer:SetWide( 250 )
            themeMixer:SetPalette( false )
            themeMixer:SetAlphaBar( false) 
            themeMixer:SetWangs( true )
            themeMixer:SetColor( BRICKS_SERVER.Func.GetTheme( k ) )
            themeMixer.ValueChanged = function()
                displayColor = themeMixer:GetColor() or Color( 155, 155, 155 )
                BS_ConfigCopyTable.THEME[k] = themeMixer:GetColor() or Color( 155, 155, 155 )
                BRICKS_SERVER.Func.ConfigChange( "THEME" )
            end
        end

        local accentBack = vgui.Create( "DPanel", self )
        accentBack:Dock( TOP )
        accentBack:DockMargin( 0, 0, 0, 5 )
        accentBack:SetTall( 100 )
        accentBack:DockPadding( 0, 0, 30, 0 )
        accentBack.Paint = function( self2, w, h )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
            draw.RoundedBox( 5, 5, 45, w-10, h-45-5, BRICKS_SERVER.Func.GetTheme( 2 ) )

            draw.SimpleText( BRICKS_SERVER.Func.L( "presetAccents" ), "BRICKS_SERVER_Font33", 15, 5, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
        end

        local first = true
        for k, v in pairs( BRICKS_SERVER.DEVCONFIG.AccentThemes ) do
            local accentButton = vgui.Create( "DButton", accentBack )
            accentButton:Dock( LEFT )
            accentButton:SetText( "" )
            if( first ) then
                accentButton:DockMargin( 10, 50, 0, 10 )
                first = false
            else
                accentButton:DockMargin( 5, 50, 0, 10 )
            end
            accentButton:SetWide( 40 )
            local changeAlpha = 0
            accentButton.Paint = function( self2, w, h )
                if( self2:IsHovered() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 100 )
                else
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 100 )
                end
                
                draw.RoundedBox( 5, 0, 0, w, h, v[1] )
        
                surface.SetAlphaMultiplier( changeAlpha/255 )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
                surface.SetAlphaMultiplier( 1 )
            end
            accentButton.DoClick = function()
                BS_ConfigCopyTable.THEME[4] = v[1]
                BS_ConfigCopyTable.THEME[5] = v[2]
                BRICKS_SERVER.Func.ConfigChange( "THEME" )
                self.RefreshPanel()
            end
        end

        local backgroundBack = vgui.Create( "DPanel", self )
        backgroundBack:Dock( TOP )
        backgroundBack:DockMargin( 0, 0, 0, 5 )
        backgroundBack:SetTall( 100 )
        backgroundBack:DockPadding( 0, 0, 30, 0 )
        backgroundBack.Paint = function( self2, w, h )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
            draw.RoundedBox( 5, 5, 45, w-10, h-45-5, BRICKS_SERVER.Func.GetTheme( 2 ) )

            draw.SimpleText( BRICKS_SERVER.Func.L( "presetBackgrounds" ), "BRICKS_SERVER_Font33", 15, 5, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
        end

        local first = true
        for k, v in pairs( BRICKS_SERVER.DEVCONFIG.BackgroundThemes ) do
            local backgroundButton = vgui.Create( "DButton", backgroundBack )
            backgroundButton:Dock( LEFT )
            backgroundButton:SetText( "" )
            if( first ) then
                backgroundButton:DockMargin( 10, 50, 0, 10 )
                first = false
            else
                backgroundButton:DockMargin( 5, 50, 0, 10 )
            end
            backgroundButton:SetWide( 40 )
            local changeAlpha = 0
            backgroundButton.Paint = function( self2, w, h )
                if( self2:IsHovered() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 100 )
                else
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 100 )
                end
                
                draw.RoundedBox( 5, 0, 0, w, h, v[1] )
        
                surface.SetAlphaMultiplier( changeAlpha/255 )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
                surface.SetAlphaMultiplier( 1 )
            end
            backgroundButton.DoClick = function()
                BS_ConfigCopyTable.THEME[0] = v[1]
                BS_ConfigCopyTable.THEME[1] = v[2]
                BS_ConfigCopyTable.THEME[2] = v[3]
                BS_ConfigCopyTable.THEME[3] = v[4]
                BS_ConfigCopyTable.THEME[6] = v[6]
                BRICKS_SERVER.Func.ConfigChange( "THEME" )
                self.RefreshPanel()
            end
        end

        local themeReset = vgui.Create( "DButton", self )
        themeReset:Dock( TOP )
        themeReset:SetText( "" )
        themeReset:DockMargin( 0, 0, 0, 5 )
        themeReset:SetTall( 40 )
        local changeAlpha = 0
        themeReset.Paint = function( self2, w, h )
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
    
            draw.SimpleText( BRICKS_SERVER.Func.L( "resetToBaseThemes" ), "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
        themeReset.DoClick = function()
            BS_ConfigCopyTable.THEME = table.Copy( BRICKS_SERVER.BASECONFIG.THEME )
            BRICKS_SERVER.Func.ConfigChange( "THEME" )
            self.RefreshPanel()
        end

        local themeResetPrevious = vgui.Create( "DButton", self )
        themeResetPrevious:Dock( TOP )
        themeResetPrevious:SetText( "" )
        themeResetPrevious:DockMargin( 0, 0, 0, 5 )
        themeResetPrevious:SetTall( 40 )
        local changeAlpha = 0
        themeResetPrevious.Paint = function( self2, w, h )
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
    
            draw.SimpleText( BRICKS_SERVER.Func.L( "resetToCurrentThemes" ), "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
        themeResetPrevious.DoClick = function()
            BS_ConfigCopyTable.THEME = table.Copy( BRICKS_SERVER.CONFIG.THEME )
            BRICKS_SERVER.Func.ConfigChange( "THEME" )
            self.RefreshPanel()
        end
    end
    self.RefreshPanel()
end

function PANEL:Paint( w, h )
    
end

vgui.Register( "bricks_server_config_themes", PANEL, "bricks_server_scrollpanel" )