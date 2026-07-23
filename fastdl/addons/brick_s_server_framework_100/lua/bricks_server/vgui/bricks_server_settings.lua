local PANEL = {}

function PANEL:FillSettings()
    self:Clear()

    for k, v in pairs( BRICKS_SERVER.BASECLIENTCONFIG ) do
        local type = v[2] or ""
        if( type == "string" or type == "number" or type == "bind" or type == "bool" ) then
            local displayValue = BRICKS_SERVER.Func.GetClientConfig( k ) or BRICKS_SERVER.Func.L( "emptyValue" )
            if( type == "bind" and BRICKS_SERVER.DEVCONFIG.KEY_BINDS[displayValue] ) then
                displayValue = string.upper( BRICKS_SERVER.DEVCONFIG.KEY_BINDS[displayValue] )
            elseif( type == "bool" ) then
                displayValue = string.upper( tostring( BRICKS_SERVER.Func.GetClientConfig( k ) or false ) )
            end

            local variableBack = vgui.Create( "DPanel", self )
            variableBack:Dock( TOP )
            variableBack:DockMargin( 0, 0, 0, 5 )
            variableBack:SetTall( 65 )
            variableBack:DockPadding( 0, 0, 30, 0 )
            variableBack.Paint = function( self2, w, h )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

                draw.SimpleText( v[1] or k, "BRICKS_SERVER_Font33", 15, 5, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                draw.SimpleText( displayValue, "BRICKS_SERVER_Font20", 18, 32, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
            end

            local variableAction = vgui.Create( "DButton", variableBack )
            variableAction:SetPos( 0, 0 )
            variableAction:SetSize( (ScrW()*0.6)-BRICKS_SERVER.DEVCONFIG.MainNavWidth-20, variableBack:GetTall() )
            variableAction:SetText( "" )
            local changeAlpha = 0
            variableAction.Paint = function( self2, w, h ) 
                if( self2:IsDown() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 125 )
                elseif( self2:IsHovered() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 95 )
                else
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
                end

                surface.SetAlphaMultiplier( changeAlpha/255 )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
                surface.SetAlphaMultiplier( 1 )
            end
            variableAction.DoClick = function( self2 )
                if( type == "bind" ) then
                    self2:RequestFocus()
                    displayValue = BRICKS_SERVER.Func.L( "pressKey" )
                elseif( type == "bool" ) then
                    BRICKS_SERVER.Func.ChangeClientConfig( k, not (BRICKS_SERVER.Func.GetClientConfig( k ) or false) )
                    self:FillSettings()
                elseif( type == "number" ) then
                    BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "newValueQuery" ), BRICKS_SERVER.Func.GetClientConfig( k ) or 0, function( number ) 
                        BRICKS_SERVER.Func.ChangeClientConfig( k, number )
                        self:FillSettings()
                    end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), true )
                elseif( type == "string" ) then
                    BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "newValueQuery" ), BRICKS_SERVER.Func.GetClientConfig( k ) or "", function( text ) 
                        BRICKS_SERVER.Func.ChangeClientConfig( k, text )
                        self:FillSettings()
                    end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ) )
                end
            end

            if( type == "bind" ) then
                variableAction.OnKeyCodeReleased = function( self, text )
                    BRICKS_SERVER.Func.ChangeClientConfig( k, text )
                    self:FocusNext()
                    displayValue = BRICKS_SERVER.Func.GetClientConfig( k ) or BRICKS_SERVER.Func.L( "emptyValue" )
                    if( BRICKS_SERVER.DEVCONFIG.KEY_BINDS[displayValue] ) then
                        displayValue = string.upper( BRICKS_SERVER.DEVCONFIG.KEY_BINDS[displayValue] )
                    end
                end
            end
        end
    end
end

function PANEL:Init()
    self:FillSettings()
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_settings", PANEL, "bricks_server_scrollpanel" )