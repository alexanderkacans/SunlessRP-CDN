local PANEL = {}

local surface = surface
local draw = draw
local gui = gui
local vgui = vgui
local font = KVS.GetFont
local config = KVS.GetConfig

KVS:AccessorFunc( PANEL, 'UseAnimation', 'UseAnimation', FORCE_BOOL )
KVS:AccessorFunc( PANEL, 'AnimationSpeed', 'AnimationSpeed', FORCE_NUMBER )
KVS:AccessorFunc( PANEL, 'SmoothAlpha', 'SmoothAlpha', FORCE_BOOL )

KVS:AccessorFunc( PANEL, 'ToolBarTall', 'ToolBarTall', FORCE_NUMBER )
KVS:AccessorFunc( PANEL, 'ToolBarBackgroundColor', 'ToolBarBackgroundColor' )

KVS:AccessorFunc( PANEL, 'Sizable', 'Sizable', FORCE_BOOL )
KVS:AccessorFunc( PANEL, 'Draggable', 'Draggable', FORCE_BOOL )
KVS:AccessorFunc( PANEL, 'BorderRadius', 'BorderRadius', FORCE_NUMBER )

KVS:AccessorFunc( PANEL, 'Font', 'Font', FORCE_STRING, true )
KVS:AccessorFunc( PANEL, 'MainColor', 'MainColor', nil, true )
KVS:AccessorFunc( PANEL, 'BackgroundColor', 'BackgroundColor' )

function PANEL:InitVar( )
	-- Override some default functino to make them chainable by adding `return self`
	KVS:MakeChainableMethod( self, { 'SetPos', 'SetSize', 'Center', 'Show', 'MakePopup' } )

	-- Instanciate internal var
	self.m_OpenCloseLerp = 0
	self.m_IsOpening = false
	self.m_IsClosing = false
	self.m_Dragging = nil
	self.m_Sizable = nil

	self.m_iMinWidth = 150
	self.m_iMinHeight = 20

	self.Border = { true, true, false, false }
	self.Padding = { 5, 5, 5, 5 }

	self.Draggable = false
	self.Sizable = false

	self:SetUseAnimation( false )
	self:SetAnimationSpeed( 3 )
	self.SmoothAlpha = false

	self.BorderRadius = 5
	self.Font = config( 'kvs.default_font', true ) or 'Vegur'

	self.ToolBarTall =  50
	self.ToolBarBackgroundColor = config( 'vgui.color.black', true ) or Color( 28, 29, 31, 255 )

	self.MainColor = config( 'vgui.color.white', true ) or Color( 233, 233, 233, 255 )
	self.BackgroundColor = config( 'vgui.color.black_rhard', true ) or Color( 28, 29, 31, 180 )
end

function PANEL:Init( )
	local this = self

	-- Instanciate some var
	self:InitVar( )

	-- Set default frame configuration
	self:DockPadding( 0, self:GetToolBarTall( ), 0, 0 )

	-- Instanciate toolbar of the frame
	self._Toolbar = vgui.Create( 'DPanel', self )
	self._Toolbar:SetTall( self:GetToolBarTall( ) )
	function self._Toolbar:OnMousePressed( )
		this:OnMousePressed( )
	end

	-- Instanciate icon show on the top left corner
	self._Toolbar._FrameIcon = vgui.Create( 'DLabel', self._Toolbar )
	local m_FrameIcon = self._Toolbar._FrameIcon
	m_FrameIcon:Dock( LEFT )
	m_FrameIcon:DockMargin( 15, 0, 0, 0 )
	m_FrameIcon:SetText( '' )
	m_FrameIcon:SetVisible( false )

	-- Instanciate the title of the frame
	self._Toolbar._frameTitle = vgui.Create( 'DLabel', self._Toolbar )
	local m_FrameTitle = self._Toolbar._frameTitle
	m_FrameTitle:SetFont( font( self:GetFont( ), 19 ) )
	m_FrameTitle:SetColor( self:GetMainColor( ) )
	m_FrameTitle:Dock( LEFT )
	m_FrameTitle:DockMargin( 15, 0, 0, 0 )

	-- Instanciate the sub title of the frame
	self._Toolbar._frameSubTitle = { }
	self._Toolbar._frameSubTitle = vgui.Create( 'DLabel', self._Toolbar )
	local m_FrameSubTitle = self._Toolbar._frameSubTitle
	m_FrameSubTitle:SetText( '' )
	m_FrameSubTitle:SetFont( font( self:GetFont( ), 17, 'weight:400' ) )
	m_FrameSubTitle:Dock( LEFT )
	m_FrameSubTitle:DockMargin( 15, 0, 0, 0 )

	-- Paint the design ou the toolbar
	function self._Toolbar:Paint( w, h )
		draw.RoundedBoxEx( this:GetBorderRadius( ) , 0, 0, w, h, this:GetToolBarBackgroundColor( ), unpack( this.Border ) )
		-- if the subtitle is not empty we have to draw the vertical seprator
		if ( m_FrameSubTitle and m_FrameSubTitle:GetText( ) ~= '' ) then
			local title_x, title_y = m_FrameTitle:GetPos( )
			surface.SetDrawColor( KVS:GetLightenColor( config( 'vgui.color.gray' ), 1 ) )
			surface.DrawLine( title_x + m_FrameTitle:GetWide() + 5, title_y + 12.5, title_x + m_FrameTitle:GetWide() + 5 , title_y + m_FrameTitle:GetTall() - 12.5 )
		end
	end

	-- Instanciate the close button with defautl close action
	self._Toolbar._CloseButton = vgui.Create( 'KVS.ButtonIcon', self._Toolbar )
	local m_CloseButton = self._Toolbar._CloseButton
	m_CloseButton:SetTall( self:GetToolBarTall( ) )
	m_CloseButton:Dock( RIGHT )
	m_CloseButton:DockMargin( 0, 0, 15, 0 )
	m_CloseButton:SetIcon( font( 'FAR', 18, 'extended' ), 0xf057, config( 'vgui.color.white' ) )
	m_CloseButton:SetHoverIcon( font( 'FAS', 18, 'extended' ), 0xf057, config( 'vgui.color.dark_red' ) )
	function m_CloseButton:DoClick( ) this:Close( ) end

	-- Instanciate the main container of the frame
	self._Container = vgui.Create( 'DPanel', self )
	self._Container:Dock( FILL )
	function self._Container:OnMousePressed( )
		this:OnMousePressed( )
	end
	function self._Container:Paint( w, h ) end
end

function PANEL:PerformLayout( )
	local m_FrameIcon = self._Toolbar._FrameIcon
	local m_FrameTitle = self._Toolbar._frameTitle
	local m_FrameSubTitle = self._Toolbar._frameSubTitle
	local m_FrameIcon_Text = m_FrameIcon:GetText( )

	m_FrameTitle:SetColor( self:GetMainColor( ) )

	self._Toolbar._CloseButton:SetAlignement( 5 )
	self._Toolbar:SetWide( self:GetWide( ) )

	if ( m_FrameIcon_Text ~= nil and m_FrameIcon_Text ~= '' ) then
		m_FrameIcon:SetColor( self:GetMainColor( ) )
		m_FrameIcon:SetVisible( true )
		m_FrameIcon:SetSize( 25, 25 )
		m_FrameTitle:DockMargin( 0, 0, 0, 0 )
	end

	m_FrameTitle:SetColor( self:GetMainColor( ) )
	m_FrameSubTitle:SetColor( KVS:GetLightenColor( config( 'vgui.color.gray' ), 1 ) )
	m_FrameSubTitle:SetFont( font( self:GetFont( ), 17, 'weight:400' ) )

	self._Container:Dock( FILL )
	self._Container:DockPadding( unpack( self.Padding ) )

	-- Call `PostPerformLayout` if were defined by developer
	if ( self.PostPerformLayout ) then self:PostPerformLayout( ) end
end

function PANEL:Paint( w, h )
	-- showcase when animation are set to false
	if ( not self:GetUseAnimation( ) ) then
		draw.RoundedBoxEx( self:GetBorderRadius( ), 0, 0, w, h, self:GetBackgroundColor( ), unpack( self.Border ) )
		return
	end

	local frameTimeSpeed = FrameTime( ) * self:GetAnimationSpeed( )

	-- showcase when we should draw container background and this is not the closing process
	if ( self.m_IsClosing == false ) then
		self.m_IsOpening = true
		self.m_OpenCloseLerp = Lerp( frameTimeSpeed, self.m_OpenCloseLerp, h )
		if ( self.m_OpenCloseLerp >= h ) then
			self.m_IsOpening = false
		end
	end

	-- showcase when we should draw container background and this is not the closing process
	if ( self.m_IsClosing == true ) then
		self.m_OpenCloseLerp = Lerp( frameTimeSpeed, self.m_OpenCloseLerp, 0 )
		if ( self.m_OpenCloseLerp <= self:GetToolBarTall( ) ) then
			gui.EnableScreenClicker( false )
			self:Remove()
			if ( self.PostClose ) then self:PostClose( ) end
			return
		end
	end

	-- finnaly we draw the container paint
	draw.RoundedBoxEx( self:GetBorderRadius( ), 0, 0, w, self.m_OpenCloseLerp, self:GetBackgroundColor( ), unpack( self.Border ) )
end

function PANEL:Think( )
	local screen_x, screen_y = self:LocalToScreen( 0, 0 )
	local mouse_x = math.Clamp( gui.MouseX( ), 1, ScrW( ) - 1 )
	local mouse_y = math.Clamp( gui.MouseY( ), 1, ScrH( ) - 1 )

	if ( self.m_Dragging ) then
		local x = mouse_x - self.m_Dragging[ 1 ]
		local y = mouse_y - self.m_Dragging[ 2 ]
		x = math.Clamp( x, 0, ScrW( ) - self:GetWide( ) )
		y = math.Clamp( y, 0, ScrH( ) - self:GetTall( ) )
		self:SetPos( x, y )
	end

	if ( self.m_Sizing ) then
		local x = mouse_x - self.m_Sizing[ 1 ]
		local y = mouse_y - self.m_Sizing[ 2 ]
		local px, py = self:GetPos( )

		if ( x < self.m_iMinWidth ) then
			x = self.m_iMinWidth
		elseif ( x > ScrW( ) - px ) then
			x = ScrW() - px
		end

		if ( y < self.m_iMinHeight ) then
			y = self.m_iMinHeight
		elseif ( y > ScrH( ) - py ) then
			y = ScrH() - py
		end

		self:SetSize( x, y )
		self:SetCursor( 'sizenwse' )
		self:GetContainer( ):SetCursor( 'sizenwse' )
		return
	end

	if ( self:GetContainer( ):IsHovered( ) and self:IsSizable( ) and mouse_x > ( screen_x + self:GetWide( ) - 20 ) and mouse_y > ( screen_y + self:GetTall( ) - 20 ) ) then
		self:GetContainer( ):SetCursor( 'sizenwse' )
		return
	end

	if ( ( self:IsHovered( ) or self:IsChildHovered( ) ) and self:GetDraggable( ) and mouse_y < ( screen_y + self:GetToolBarTall( ) ) ) then
		self:SetCursor( 'sizeall' )
		self._Toolbar:SetCursor( 'sizeall' )
		return
	end

	self:SetCursor( 'arrow' )
	self._Toolbar:SetCursor( 'arrow' )

	-- Don't allow the frame to go higher than 0
	if ( self.y < 0 ) then
		self:SetPos( self.x, 0 )
	end
end

function PANEL:OnMousePressed( )
	local screen_x, screen_y = self:LocalToScreen( 0, 0 )

	if ( self:IsSizable( ) and gui.MouseX() > ( screen_x + self:GetWide() - 20 ) and gui.MouseY() > ( screen_y + self:GetTall() - 20 ) ) then
		self.m_Sizing = { gui.MouseX() - self:GetWide(), gui.MouseY() - self:GetTall() }
		self:MouseCapture( true )
		return
	end

	if ( self:IsDraggable( ) and gui.MouseY( ) < ( screen_y + self:GetToolBarTall( ) ) ) then
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

--- Function used to set the top title of the frame
function PANEL:SetTitle( title )
	local _title = string.upper( title )
	local m_FrameTitle = self._Toolbar._frameTitle
	m_FrameTitle:SetText( _title )
	m_FrameTitle:SetWide( KVS:GetSizeFromFont( m_FrameTitle:GetFont( ), _title ) + 10 )
	return self
end

function PANEL:GetTitle( )
	return self._Toolbar._frameTitle:GetText( )
end

--- Function used to set a subtitle of your frame
function PANEL:SetSubTitle( subtitle )
	local m_FrameSubTitle = self._Toolbar._frameSubTitle
	m_FrameSubTitle:SetText( subtitle )
	m_FrameSubTitle:SetWide( KVS:GetSizeFromFont( m_FrameSubTitle:GetFont( ), subtitle ) + 10 )
	return self
end

function PANEL:GetSubTitle( )
	return self._Toolbar._frameSubTitle:GetText( )
end

--- Function used to set an icon for your frame, based on Font Awesome
function PANEL:SetFrameIcon( font_name, unicode, color )
	local m_FrameIcon = self._Toolbar._FrameIcon
	m_FrameIcon:SetText( utf8.char( unicode ) )
	m_FrameIcon:SetFont( font_name )
	m_FrameIcon:SetTextColor( color )
	return self
end

function PANEL:GetFrameIcon( )
	local m_FrameIcon = self._Toolbar._FrameIcon
	return m_FrameIcon:GetText( ), m_FrameIcon:GetFont( ), m_FrameIcon:GetTextColor( )
end

--- Function used to activate or deactivate the close button
-- @param show boolean |
function PANEL:ShowCloseButton( show )
	self._Toolbar._CloseButton:SetVisible( show )
	return self
end

--- Function used to recover the main container of the frame
function PANEL:GetContainer()
	return self._Container
end

function PANEL:SetBorder( left, top, right, bottom )
	self.Border = { left, top, right, bottom }
	return self
end

function PANEL:GetBorder( )
	return unpack( self.Border )
end

function PANEL:SetPadding( left, top, right, bottom )
	self.Padding = { left, top, right, bottom }
	return self
end

function PANEL:GetPadding( )
	return unpack( self.Padding )
end

function PANEL:IsDraggable( )
	return self:GetDraggable( )
end

function PANEL:IsSizable( )
	return self:GetSizable( )
end


-- Function for override
function PANEL:OnClose()
end

--- Function used to begin the closing process of the frame
function PANEL:Close( )
	self:OnClose()
	surface.PlaySound( 'buttons/blip1.wav' ) -- how to manage sound ?
	if ( self:GetUseAnimation( ) ) then
		self.m_IsClosing = true
	else
		gui.EnableScreenClicker( false )
		self:Remove( )
		if ( self.PostClose ) then self:PostClose( ) end
	end
end

derma.DefineControl( 'KVS.Frame' , nil, PANEL, 'EditablePanel' )
