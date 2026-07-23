local PANEL = {}

AccessorFunc( PANEL, "m_bDeleteSelf", "DeleteSelf" )

function PANEL:Init()
	self:SetSize( 150, 45 )

	self:SetAlpha( 0 )
	self:AlphaTo( 255, 0.05, 0 )

	self.optionCount = 0
end

local optionH = 45
function PANEL:AddOption( label, onClick, ... )
	local args = { ... }

	self.optionCount = self.optionCount+1

	self:SetTall( self.optionCount*optionH )
	
	local optionButton = vgui.Create( "DButton", self )
	optionButton:Dock( TOP )
	optionButton:SetTall( optionH )
	optionButton:SetText( "" )
	optionButton.OptionPos = self.optionCount
	local alpha = 0
	optionButton.Paint = function( self2, w, h )
		if( self2:IsHovered() ) then
			alpha = math.Clamp( alpha+20, 0, 255 )
		else
			alpha = math.Clamp( alpha-20, 0, 255 )
		end

		if( self2.OptionPos == 1 and self.optionCount > 1 ) then
			draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3, alpha ), true, true, false, false)
		elseif( self2.OptionPos == self.optionCount and self.optionCount > 1 ) then
			draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3, alpha ), false, false, true, true)
		elseif( self.optionCount <= 1 ) then
			draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3, alpha ) )
		else
			surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3, alpha ) )
			surface.DrawRect( 0, 0, w, h )
		end

		draw.SimpleText( label, "BRICKS_SERVER_Font20", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), 1, 1 )
	end
    optionButton.DoClick = function()
        onClick( unpack( args ) )
        self:Remove()
    end
end

function PANEL:Open( parent, x, y )
	self.parent = parent

	self:MakePopup()
	self:SetPos( x, y )
end

function PANEL:Think()
	if( not self:HasFocus() ) then
		if( not self.removeTime ) then
			self.removeTime = CurTime()+0.1
		end
	elseif( self.removeTime ) then
		self.removeTime = nil
	end

	if( not IsValid( self.parent ) or not self.parent:IsVisible() or (self.removeTime and CurTime() >= self.removeTime) ) then
		self:Remove()
	end
end

function PANEL:Paint( w, h )
	local x, y = self:LocalToScreen( 0, 0 )

	BRICKS_SERVER.BSHADOWS.BeginShadow()
	draw.RoundedBox( 8, x, y, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )	
	BRICKS_SERVER.BSHADOWS.EndShadow(2, 2, 1, 255, 0, 0, false )
end

vgui.Register( "bricks_server_popupdmenu", PANEL, "DPanel" )