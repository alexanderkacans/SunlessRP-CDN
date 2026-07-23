local PANEL = {}

-- KVS:AccessorFunc( PANEL, 'm_color', 'Color' )
-- KVS:AccessorFunc( PANEL, 'm_alpha', 'Alpha' )

function PANEL:Init( )
    local this = self

    KVS:OverrideMeta( self, 'SetSize', function( w, h ) return false, w, w end )
    -- KVS:OverrideMeta( self, 'Dock', function( w, h ) self:InvalidateParent( true ) return false end )

    self:SetSize( 300 )

    self.m_colorwheel = vgui.Create( 'KVS.ColorWheel', self )
    function self.m_colorwheel:OnValueChanged( value )
        this:OnValueChanged( this:GetColor( ) )
    end

    self.m_alphaslider = vgui.Create( 'KVS.Slider', self )
    self.m_alphaslider:SetMin( 0 )
    self.m_alphaslider:SetMax( 255 )
    function self.m_alphaslider:DrawSlideBar( x, y, w, h )
        local screen_x, screen_y = self:LocalToScreen( )
        x, y = screen_x + x, screen_y + y
        -- w, h = x + w, y + h
        KVS:DrawLinearGradient( x, y, w, h, Color( 0, 0, 0, 0 ), ColorAlpha( this.m_colorwheel:GetColor( true ), 255 ) )
    end
    function self.m_alphaslider:OnValueChanged( value )
        this.m_colorwheel:SetAlpha( value )
        self:SetTooltipText( value )
        this:OnValueChanged( this:GetColor( ) )
    end
    self.m_alphaslider:SetValue( self.m_colorwheel:GetAlpha( ) )

    self.m_darknessslider = vgui.Create( 'KVS.Slider', self )
    self.m_darknessslider:SetMin( 0 )
    self.m_darknessslider:SetMax( 1 )
    function self.m_darknessslider:DrawSlideBar( x, y, w, h )
        local screen_x, screen_y = self:LocalToScreen( )
        x, y = screen_x + x, screen_y + y
        KVS:DrawLinearGradient( x, y, w, h, this.m_colorwheel:GetColor( true ), Color( 0, 0, 0 ) )
    end
    function self.m_darknessslider:OnValueChanged( value )
        this.m_colorwheel:SetDarkness( value )
        self:SetTooltipText( value )
        this:OnValueChanged( this:GetColor( ) )
    end
    self.m_darknessslider:SetValue( self.m_colorwheel:GetDarkness( ) )
end

function PANEL:PerformLayout( w, h )
    self.m_colorwheel:SetSize( w * 0.825 )
    self.m_colorwheel:SetPos( w * 0.09 , h * 0.015 )

    self.m_darknessslider:SetSize( w * 0.75, h * 0.05 )
    self.m_darknessslider:SetPos( w * 0.125, h * 0.85 )

    self.m_alphaslider:SetSize( w * 0.75, h * 0.05 )
    self.m_alphaslider:SetPos( w * 0.125, h * 0.925 )
end

function PANEL:OnValueChanged( color )

end

function PANEL:GetColorWheel( )
    return self.m_colorwheel
end

function PANEL:SetColor( color )
    self.m_colorwheel:SetColor( color )
    self.m_colorwheel:OnValueChanged( color )
    self:SetDarkness( self.m_colorwheel:GetDarkness( ) )
    self:SetAlpha( self.m_colorwheel:GetAlpha( ) )
    return self
end

function PANEL:GetColor( )
    return self.m_colorwheel:GetColor( )
end

function PANEL:GetAlphaBar( )
    return self.m_alphaslider
end

function PANEL:GetAlpha( )
    return self.m_alphaslider:GetValue( )
end

function PANEL:SetAlpha( value )
    self.m_alphaslider:SetValue( value )
    self.m_alphaslider:OnValueChanged( value )
    return self
end

function PANEL:GetDarkerBar( )
    return self.m_darknessslider
end

function PANEL:SetDarkness( value )
    self.m_darknessslider:SetValue( value )
    self.m_darknessslider:OnValueChanged( value )
    return self
end

function PANEL:GetDarkness(  )
    return self.m_darknessslider:GetValue( )
end

function PANEL:Paint( w, h )
end

vgui.Register( 'KVS.ColorPicker', PANEL, 'DPanel' )
