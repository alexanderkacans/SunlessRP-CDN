local PANEL = {}

function PANEL:Init()
    self.search = vgui.Create( "bricks_server_search", self )
    self.search:Dock( FILL )
    self.search.OnChange = function()
        if( self.OnChange ) then
            self.OnChange()
        end
    end
    self.search.OnEnter = function()
        if( self.OnEnter ) then
            self.OnEnter()
        end
    end

    self:SetCornerRadius( 5 )
    self:SetRoundedCorners( true, true, true, true )
end

function PANEL:SetValue( val )
    return self.search:SetValue( val )
end

function PANEL:GetValue()
    return self.search:GetValue()
end

function PANEL:SetBackColor( color )
    self.backColor = color
end

function PANEL:SetHighlightColor( color )
    self.highlightColor = color
end

function PANEL:SetCornerRadius( cornerRadius )
    self.cornerRadius = cornerRadius
end

function PANEL:SetRoundedCorners( roundTopLeft, roundTopRight, roundBottomLeft, roundBottomRight )
    self.roundTopLeft, self.roundTopRight, self.roundBottomLeft, self.roundBottomRight = roundTopLeft, roundTopRight, roundBottomLeft, roundBottomRight
end

local search = Material( "materials/bricks_server/search.png" )
local alpha, alpha2 = 0, 20
function PANEL:Paint( w, h )
    draw.RoundedBoxEx( self.cornerRadius, 0, 0, w, h, (self.backColor or BRICKS_SERVER.Func.GetTheme( 3 )), self.roundTopLeft, self.roundTopRight, self.roundBottomLeft, self.roundBottomRight )

    if( self.search:IsEditing() ) then
        alpha = math.Clamp( alpha+5, 0, 100 )
        alpha2 = math.Clamp( alpha2+20, 20, 255 )
    else
        alpha = math.Clamp( alpha-5, 0, 100 )
        alpha2 = math.Clamp( alpha2-20, 20, 255 )
    end
    
    surface.SetAlphaMultiplier( alpha/255 )
    draw.RoundedBoxEx( self.cornerRadius, 0, 0, w, h, (self.highlightColor or BRICKS_SERVER.Func.GetTheme( 2 )), self.roundTopLeft, self.roundTopRight, self.roundBottomLeft, self.roundBottomRight )
    surface.SetAlphaMultiplier( 1 )

    surface.SetDrawColor( 255, 255, 255, alpha2 )
    surface.SetMaterial( search )
    local size = 24
    surface.DrawTexturedRect( w-size-(h-size)/2, (h-size)/2, size, size )
end

vgui.Register( "bricks_server_searchbar", PANEL, "DPanel" )