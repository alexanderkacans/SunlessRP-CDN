local PANEL = {}

function PANEL:Init()
    self.headerHeight = 40
    self:DockPadding( 0, self.headerHeight, 0, 0 )

    self.removeOnClose = true
    self:CreateCloseButton()
end

function PANEL:CreateCloseButton()
    if( self.dontShowClose ) then return end

    local size = 24

    if( IsValid( self.closeButton ) ) then
        self.closeButton:SetSize( size, size )
        self.closeButton:SetPos( self:GetWide()-size-((self.headerHeight-size)/2), (self.headerHeight/2)-(size/2) )
        return
    end

    self.closeButton = vgui.Create( "DButton", self )
	self.closeButton:SetSize( size, size )
	self.closeButton:SetPos( self:GetWide()-size-((self.headerHeight-size)/2), (self.headerHeight/2)-(size/2) )
	self.closeButton:SetText( "" )
    local CloseMat = Material( "materials/bricks_server/close.png" )
    local textColor = BRICKS_SERVER.Func.GetTheme( 6 )
	self.closeButton.Paint = function( self2, w, h )
		if( self2:IsHovered() and !self2:IsDown() ) then
			surface.SetDrawColor( textColor.r*0.6, textColor.g*0.6, textColor.b*0.6 )
		elseif( self2:IsDown() || self2.m_bSelected ) then
			surface.SetDrawColor( textColor.r*0.8, textColor.g*0.8, textColor.b*0.8 )
		else
			surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
		end

		surface.SetMaterial( CloseMat )
		surface.DrawTexturedRect( 0, 0, w, h )
	end
    self.closeButton.DoClick = function()
        if( self.onCloseFunc ) then
            self.onCloseFunc()
        end

        if( self.removeOnClose or BRS_REMOVEONCLOSE ) then
            self:Remove()
        else
            self:SetVisible( false )
        end
    end
end

function PANEL:OnSizeChanged( newW, newH )
    self:CreateCloseButton()
end

function PANEL:SetHeader( header )
    self.header = header
end

function PANEL:DisableClose()
    self.dontShowClose = true

    if( IsValid( self.closeButton ) ) then
        self.closeButton:Remove()
    end
end

local rounded = 5
function PANEL:Paint( w, h )
    BRICKS_SERVER.BSHADOWS.BeginShadow()
    local x, y = self:LocalToScreen( 0, 0 )
    draw.RoundedBox( rounded, x, y, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )			
    BRICKS_SERVER.BSHADOWS.EndShadow( 1, 2, 2, 255, 0, 0, false )

    draw.RoundedBoxEx( rounded, 0, 0, w, self.headerHeight, BRICKS_SERVER.Func.GetTheme( 0 ), true, true, false, false )

    draw.SimpleText( (self.header or BRICKS_SERVER.Func.L( "menu" )), "BRICKS_SERVER_Font30", 10, (self.headerHeight or 40)/2-2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
end

vgui.Register( "bricks_server_dframepanel", PANEL, "DPanel" )