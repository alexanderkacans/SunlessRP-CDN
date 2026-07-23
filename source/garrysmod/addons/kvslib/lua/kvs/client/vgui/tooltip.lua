local PANEL = {}

KVS:AccessorFunc( PANEL, 'm_parent', 'Parent' )
KVS:AccessorFunc( PANEL, 'm_backgroundColor', 'BackgroundColor' )
KVS:AccessorFunc( PANEL, 'm_offset', 'Offset' )
KVS:AccessorFunc( PANEL, 'm_fadeInDuration', 'FadeInDuration', FORCE_NUMBER )
KVS:AccessorFunc( PANEL, 'm_fadeOutDuration', 'FadeOutDuration', FORCE_NUMBER )
KVS:AccessorFunc( PANEL, 'm_mode', 'Mode', FORCE_STRING )
KVS:AccessorFunc( PANEL, 'm_arrowVisible', 'ArrowVisible', FORCE_BOOL )
KVS:AccessorFunc( PANEL, 'm_cornerRadius', 'CornerRadius', FORCE_NUMBER )

local font = KVS.GetFont
local config = KVS.GetConfig

function PANEL:Init( )
    self:SetMode( 'fixed' )
    self:SetFadeInDuration( 0.2 )
    self:SetFadeOutDuration( 0.2 )
    self:SetArrowVisible( true )

    self:SetCornerRadius( 6 )
    self:SetBackgroundColor( config( 'vgui.tooltip.default_color', true ) or config( 'vgui.color.white', true ) or Color( 44, 44, 44, 230 ) )

    self:SetOffset( Vector( ) )

    self:SetAlpha( 0 )
    self:SetDrawOnTop( true )
    self:SetFont( font( 'Vegur', 18 ) )
    self:SetColor( KVS:GetColorFromContrast( self.m_backgroundColor ) )
    self:SetContentAlignment( 5 )
end

function PANEL:PerformLayout( w, h )
    self:SizeToContentsX( 25 )
    self:SizeToContentsY( 15 )
end

function PANEL:SetBackgroundColor( color )
    self.m_backgroundColor = color
    self:SetColor( KVS:GetColorFromContrast( self.m_backgroundColor ) )
    return self
end

-- function PANEL:UpdateColours( )
    -- return self:SetTextStyleColor( Color( 255, 255, 255 ) )
-- end

function PANEL:Think( )
    if ( not IsValid( self.m_parent ) ) then self:Remove( ) end
    
    local alpha = self:GetAlpha( )
    
    if ( self.m_parent:IsHovered( ) ) then
        if ( alpha == 0 ) then self:Show( ) end
    else
        if ( alpha == self.m_backgroundColor.a ) then self:Hide( ) end
        return
    end

    local w, h = self:GetSize()
    local screen_x, screen_y = self.m_parent:LocalToScreen( )
    local x, y

    if ( self.m_mode == 'custom' ) then
        -- if ( self.SetTooltipPos ) then self:SetTooltipPos( x, y, w, h ) end
        return
    elseif ( self.m_mode == 'fixed' ) then
        x, y = screen_x + self.m_parent:GetWide( ) / 2 - w / 2, screen_y - h
    elseif ( self.m_mode == 'cursor' ) then
        x, y = gui.MouseX( ) - w / 2, gui.MouseY( ) - h
    elseif ( self.m_mode == 'fixed_y' ) then
        x, y = gui.MouseX( ) - w / 2, screen_y - h
    end

    if ( self.m_offset != Vector( ) ) then
        x, y = x + self.m_offset.x, y + self.m_offset.y
    end

    x = math.Clamp( x, 0, ScrW( ) )
    y = math.Clamp( y, 0, ScrH( ) )

    self:SetPos( x, y )
end

function PANEL:Paint( w, h )
    self:SetColor( KVS:GetColorFromContrast( self.m_backgroundColor ) )

    draw.RoundedBox( self.m_cornerRadius, 0, 0, w, h * 0.90, self.m_backgroundColor )

    if ( self.m_arrowVisible == false ) then return end

    local triangle = {
        { x = w / 2 - w * 0.05, y = h * 0.9 - 0.5 },
        { x = w / 2 + w * 0.05, y = h * 0.9 - 0.5 },
        { x = w / 2, y = h }
    }

    surface.SetDrawColor( self.m_backgroundColor.r, self.m_backgroundColor.g, self.m_backgroundColor.b )
    draw.NoTexture( )
    surface.DrawPoly( triangle )
end

function PANEL:Show( )
    self:AlphaTo( self.m_backgroundColor.a, self.m_fadeInDuration )
end

function PANEL:Hide( )
    self:AlphaTo( 0, self.m_fadeOutDuration )
end

derma.DefineControl( 'KVS.Tooltip', '', PANEL, 'DLabel' )

local meta = FindMetaTable( 'Panel' )

function meta:AddTooltip( text )
    self.TOOLTIP = vgui.Create( 'KVS.Tooltip' )
    self.TOOLTIP:SetParent( self )
    self.TOOLTIP:SetText( text or '' )
    return self.TOOLTIP
end

function meta:GetTooltip( )
    return self.TOOLTIP
end

function meta:SetTooltipText( text )
    if ( not self.TOOLTIP ) then return end
    self.TOOLTIP:SetText( text or '' )
    return self.TOOLTIP
end
