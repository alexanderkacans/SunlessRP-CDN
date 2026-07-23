local PANEL = {}

function PANEL:Init()

end

function PANEL:LoadURL( url, wide )
    if( self.openedURL ) then return end

    self:OpenURL( url )

    self.openedURL = true
    

    local button = vgui.Create( "DButton", self )
    button:SetSize( 36, 36 )
    button:SetPos( wide-5-36, 5 )
    button:SetText( "" )
    local changeAlpha = 95
    local webMat = Material( "materials/bricks_server/web.png" )
    button.Paint = function( self3, w, h )
        if( self3:IsDown() ) then
            changeAlpha = math.Clamp( changeAlpha+10, 95, 255 )
        elseif( self3:IsHovered() ) then
            changeAlpha = math.Clamp( changeAlpha+10, 95, 165 )
        else
            changeAlpha = math.Clamp( changeAlpha-10, 95, 165 )
        end

        surface.SetAlphaMultiplier( changeAlpha/255 )
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
        surface.SetAlphaMultiplier( 1 )

        surface.SetMaterial( webMat )
        local size = 24
        surface.SetDrawColor( 0, 0, 0, 255 )
        surface.DrawTexturedRect( (h-size)/2-1, (h-size)/2+1, size, size )

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.DrawTexturedRect( (h-size)/2, (h-size)/2, size, size )
    end
    button.DoClick = function()
        gui.OpenURL( url )
    end
end

local loadingIcon = Material( "materials/bricks_server/loading.png" )
function PANEL:Paint( w, h )
    surface.SetDrawColor( 255, 255, 255, 255 )
    surface.SetMaterial( loadingIcon )
    local size = 32
    surface.DrawTexturedRectRotated( w/2, h/2, size, size, -(CurTime() % 360 * 250) )

    draw.SimpleText( BRICKS_SERVER.Func.L( "loading" ), "BRICKS_SERVER_Font20", w/2, h/2+(size/2)+5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
end

vgui.Register( "bricks_server_url", PANEL, "DHTML" )