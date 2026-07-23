local PANEL = { }

local draw = draw
local gui = gui
local vgui = vgui
local math = math

KVS:AccessorFunc( PANEL, 'Sizable', 'Sizable', FORCE_BOOL )
KVS:AccessorFunc( PANEL, 'Draggable', 'Draggable', FORCE_BOOL )
KVS:AccessorFunc( PANEL, 'BorderRadius', 'BorderRadius', FORCE_NUMBER )
KVS:AccessorFunc( PANEL, 'BackgroundColor', 'BackgroundColor' )

function PANEL:InitVar( )
	-- Override some default function to make them chainable by adding `return self`
	KVS:MakeChainableMethod( self, { 'SetPos', 'SetSize', 'SetTall', 'SetWide', 'Dock', 'DockMargin', 'DockPadding' } )

	-- Set internal variable
	self.m_Dragging = nil
	self.m_Sizing = nil
	self.m_MinWidth = 1
	self.m_MinHeight = 1

	self.Draggable = false
	self.Sizable = false
	self.BackgroundColor =  Color( 0, 0, 0, 0 )
	self.BorderRadius = 0
	self.AutoSize = { false, false }
	self.Margin = { 0, 0, 0, 0 }
	self.Padding = { 0, 0, 0, 0 }
	self.Border = { false, false, false, false }
end

function PANEL:Init( )
	-- Instanciate some var
	self:InitVar( )
end

function PANEL:Paint( w, h )
	draw.RoundedBoxEx( self:GetBorderRadius( ), 0, 0, w, h, self:GetBackgroundColor( ), unpack( self.Border ) )
end

function PANEL:PerformLayout( )
	if ( self.AutoSize and self.AutoSize[ 1 ] ) then
		local max_width = self:GetWide( )
		for _, v in pairs( self:GetChildren( ) ) do
			max_width = math.max( max_width, v:GetWide( ) )
		end
		self:SetWide( max_width )
	end

	if ( self.AutoSize and self.AutoSize[ 2 ] ) then
		local max_height = self:GetTall( )
		for _, v in pairs( self:GetChildren( ) ) do
			max_height = math.max( max_height, v:GetTall( ) )
		end
		self:SetTall( max_height )
	end

end

function PANEL:Think( )
	local mouse_x = math.Clamp( gui.MouseX(), 1, ScrW() - 1 )
	local mouse_y = math.Clamp( gui.MouseY(), 1, ScrH() - 1 )

	if ( self.m_Dragging ) then
		local x = mouse_x - self.m_Dragging[1]
		local y = mouse_y - self.m_Dragging[2]
		self:SetPos( x, y )
	end

	if ( self.m_Sizing ) then
		local x = mouse_x - self.m_Sizing[1]
		local y = mouse_y - self.m_Sizing[2]
		local px, py = self:GetPos( )

		if ( x < self.m_MinWidth ) then x = self.m_MinWidth elseif ( x > ScrW( ) - px and self:GetScreenLock( ) ) then x = ScrW( ) - px end
		if ( y < self.m_MinHeight ) then y = self.m_MinHeight elseif ( y > ScrH( ) - py and self:GetScreenLock( ) ) then y = ScrH( ) - py end

		self:SetSize( x, y )
		self:SetCursor( 'sizenwse' )
		return
	end

	local screen_x, screen_y = self:LocalToScreen( 0, 0 )
	if ( self:IsHovered( ) and self:IsSizable( ) and mouse_x > ( screen_x + self:GetWide( ) - 8 ) and mouse_y > ( screen_y + self:GetTall( ) - 8 ) ) then
		self:SetCursor( 'sizenwse' )
		return
	end

	local _, sy = self:GetSize()
	if ( self:IsHovered( ) and self:GetDraggable( ) and mouse_y < ( screen_y + sy ) ) then
		self:SetCursor( 'sizeall' )
		return
	end

	self:SetCursor( 'arrow' )
end

function PANEL:OnMousePressed( )
	local screen_x, screen_y = self:LocalToScreen( 0, 0 )

	if ( self:IsSizable( ) and gui.MouseX( ) > ( screen_x + self:GetWide( ) - 8 ) and gui.MouseY( ) > ( screen_y + self:GetTall( ) - 8 ) ) then
		self.m_Sizing = { gui.MouseX( ) - self:GetWide( ), gui.MouseY() - self:GetTall( ) }
		self:MouseCapture( true )
		return
	end

	local _, sy = self:GetSize()
	if ( self:GetDraggable( ) and gui.MouseY( ) < ( screen_y + sy ) ) then
		self.m_Dragging = { gui.MouseX( ) - self.x, gui.MouseY( ) - self.y }
		self:MouseCapture( true )
		return
	end
end

function PANEL:OnMouseReleased( )
	if ( self.DoClick ) then self:DoClick( ) end
	self.m_Dragging = nil
	self.m_Sizing = nil
	self:MouseCapture( false )
end

function PANEL:IsDraggable( )
	return self:GetDraggable( )
end

function PANEL:IsSizable( )
	return self:GetSizable( )
end

function PANEL:SetDock( dock )
	self:Dock( dock )
	return self
end

function PANEL:SetBorder( top_left, top_right, bottom_left, bottom_right )
	self.Border = { top_left, top_right, bottom_left, bottom_right }
	return self
end

function PANEL:GetBorder( )
	return unpack( self.Border )
end

function PANEL:SetMargin( left, top, right, bottom )
	self:DockMargin( left, top, right, bottom )
	return self
end

function PANEL:GetMargin( )
	return self:GetDockMargin()
end

function PANEL:SetPadding( left, top, right, bottom )
	self:DockPadding( left, top, right, bottom )
	return self
end

function PANEL:GetPadding( )
	return self:GetDockPadding()
end

function PANEL:SetAutoSize( wide, tall )
	self.AutoSize = { wide, tall }
	return self
end

function PANEL:GetAutoSize( )
	return unpack( self.AutoSize )
end

derma.DefineControl( 'KVS.Panel' , nil, PANEL, 'Panel' )
