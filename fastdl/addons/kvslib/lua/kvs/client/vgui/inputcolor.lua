PANEL = { }

local config = KVS.GetConfig
local font = KVS.GetFont

KVS:AccessorFunc( PANEL, 'SelectedColor', 'SelectedColor' )
KVS:AccessorFunc( PANEL, 'CoirnerColor', 'CoirnerColor' )
KVS:AccessorFunc( PANEL, 'BackgroundColor', 'BackgroundColor' )
KVS:AccessorFunc( PANEL, 'BorderRadius', 'BorderRadius', FORCE_NUMBER )

function PANEL:InitVar( )
	KVS:MakeChainableMethod( self, { 'SetPos', 'SetSize', 'SetTall', 'SetWide' } )

	self.m_SelectedColorMargin = 3
	self.m_CornerHoveredLerp = 0

	self.SelectedColor = Color( 168, 45, 207, 255 )
	self.CornerColor = config( 'vgui.color.white' )

	self.BackgroundColor = config( 'vgui.color.light_black', true )
	self.BorderRadius = 4
	self.Border = { true, true, true, true }
end

function PANEL:Init( )
	self:InitVar( )
end

function PANEL:SetColor( color )
	self.SelectedColor = color
	return self
end

function PANEL:GetColor()
	return self.SelectedColor
end

function PANEL:OpenSelectorPanel( )
	local this = self
	if ( self.Menu and IsValid( self.Menu ) and ispanel( self.Menu ) ) then
		self.Menu:Remove( )
		self.Menu = nil
	end

	local x, y = self:LocalToScreen( 0, self:GetTall() )

	-- the wide will be the size of the Color wheel, so we add in the height the size of the rest
	local wide = math.Clamp( self:GetWide(), 320, 500 )
	local height = wide + 35 + wide * 0.075 + 10 * 2
	

	self.Menu = vgui.Create( 'DFrame', self )
	self.Menu:ShowCloseButton( false )
	self.Menu:SetTitle( "" )

	self.Menu.GetDeleteSelf = function( ) end
	RegisterDermaMenuForClose( self.Menu )
	self.Menu.Paint = function( pnl, w, h )
		draw.RoundedBox( 5, 0, 10, w, h - 10, this.BackgroundColor or config( 'vgui.color.light_black' ) )

		local triangle = {
	        { x = w / 2 - w * 0.02, y = 10 },
	        { x = w / 2, y = 0 },
	        { x = w / 2 + w * 0.02, y = 10 }
	    }

	    surface.SetDrawColor( this.BackgroundColor or config( 'vgui.color.light_black' ) )
	    draw.NoTexture( )
	    surface.DrawPoly( triangle )
	end

	self.Menu.Header = vgui.Create( 'KVS.Panel', self.Menu ):SetDock( TOP ):SetMargin( 10, 25, 10, 0 ):SetTall( 35 )
	self.Menu.Content = vgui.Create( 'KVS.Panel', self.Menu ):SetDock( FILL ):SetMargin( 10, 10, 10, 0 )

	-- self.Menu.Header.SelectedColor = vgui.Create( 'KVS.Panel', self.Menu.Header ):SetDock( LEFT ):SetWide( 35 )
	-- self.Menu.Header.SelectedColor:SetBackgroundColor( self.SelectedColor ):SetBorder( true, true, true, true ):SetBorderRadius( 5 ):DockMargin( 0, 0, 10, 0 )

	self.Menu.Header.R = vgui.Create( 'KVS.Input', self.Menu.Header ):Dock( LEFT ):DockMargin( 10, 0, 0, 0 ):SetWide( ( wide - 10 * 7 ) / 4 )
	self.Menu.Header.R:Prepend( 'R', nil, config( 'vgui.color.white' ) )
	self.Menu.Header.R:SetNumeric( true )
	self.Menu.Header.R:SetText( string.format( '%d', self.SelectedColor.r ) )

	self.Menu.Header.G = vgui.Create( 'KVS.Input', self.Menu.Header ):Dock( LEFT ):DockMargin( 10, 0, 0, 0 ):SetWide( ( wide - 10 * 7 ) / 4 )
	self.Menu.Header.G:Prepend( 'G', nil, config( 'vgui.color.white' ) )
	self.Menu.Header.G:SetNumeric( true )
	self.Menu.Header.G:SetText( string.format( '%d', self.SelectedColor.g ) )

	self.Menu.Header.B = vgui.Create( 'KVS.Input', self.Menu.Header ):Dock( LEFT ):DockMargin( 10, 0, 0, 0 ):SetWide( ( wide - 10 * 7 ) / 4 )
	self.Menu.Header.B:Prepend( 'B', nil, config( 'vgui.color.white' ) )
	self.Menu.Header.B:SetNumeric( true )
	self.Menu.Header.B:SetText( string.format( '%d', self.SelectedColor.b ) )

	self.Menu.Header.Alpha = vgui.Create( 'KVS.Input', self.Menu.Header ):Dock( LEFT ):DockMargin( 10, 0, 0, 0 ):SetWide( ( wide - 10 * 7 ) / 4 )
	self.Menu.Header.Alpha:Prepend( 'A', nil, config( 'vgui.color.white' ) )
	self.Menu.Header.Alpha:SetText( string.format( '%d', self.SelectedColor.a ) )

	-- self.Menu:SetBackgroundColor( config( 'vgui.color.black' ) )
	self.Menu.ColorPicker = vgui.Create( 'KVS.ColorPicker', self.Menu.Content )
	self.Menu.ColorPicker:GetColorWheel():SetBorderColor( config( 'vgui.color.white' ) )
	self.Menu.ColorPicker:SetSize( self.Menu.Content:GetTall() )
	self.Menu.ColorPicker:SetColor( self.SelectedColor )
	self.Menu.ColorPicker:Dock( FILL )
	function self.Menu.ColorPicker:OnValueChanged( color )
		this.SelectedColor = color
		if this.OnValueChanged and isfunction( this.OnValueChanged ) then this:OnValueChanged( color ) end
		-- this.Menu.Header.SelectedColor:SetBackgroundColor( this.SelectedColor )
		this.Menu.Header.Alpha:SetText( string.format( '%d', this.SelectedColor.a ) )
		this.Menu.Header.R:SetText( string.format( '%d', this.SelectedColor.r ) )
		this.Menu.Header.G:SetText( string.format( '%d', this.SelectedColor.g ) )
		this.Menu.Header.B:SetText( string.format( '%d', this.SelectedColor.b ) )
	end

	-- self.Menu.m_bIsMenuComponent = true
	self.Menu.ColorPicker.m_bIsMenuComponent = true
	self.Menu.Header.m_bIsMenuComponent = true
	self.Menu.Content.m_bIsMenuComponent = true
	-- self.Menu.Header.SelectedColor.m_bIsMenuComponent = true
	-- self.Menu.Header.RGB.m_bIsMenuComponent = true
	self.Menu.Header.Alpha.m_bIsMenuComponent = true

	--[[
		Fait que tous les inputs sont utilisables
	]]
	local fOnValueChangedInputs = function( self, value )
		if ( tonumber( value ) or 0 ) <= 0 then
			self:SetText( 0 )
		elseif tonumber( value ) > 255 then
			self:SetText( 255 )
		end
	end

	local fOnLoseFocus = function( self )
		local r, g, b, a = this.Menu.Header.R:GetValue(), this.Menu.Header.G:GetValue(), this.Menu.Header.B:GetValue(), this.Menu.Header.Alpha:GetValue()
		this.Menu.ColorPicker:SetColor( Color( r, g, b, a ) )
	end

	this.Menu.Header.R.OnValueChanged, this.Menu.Header.G.OnValueChanged, this.Menu.Header.B.OnValueChanged, this.Menu.Header.Alpha.OnValueChanged = fOnValueChangedInputs, fOnValueChangedInputs, fOnValueChangedInputs, fOnValueChangedInputs
	this.Menu.Header.R.OnLoseFocus, this.Menu.Header.G.OnLoseFocus, this.Menu.Header.B.OnLoseFocus, this.Menu.Header.Alpha.OnLoseFocus = fOnLoseFocus, fOnLoseFocus, fOnLoseFocus, fOnLoseFocus

	self.Menu:SetSize( wide, height )
	self.Menu:SetPos( math.Clamp( x - (wide - self:GetWide()) / 2, 0, ScrW() ), math.Clamp( y, 0, ScrH() - height ) )
	self.Menu:MakePopup()
	self.Menu:SetVisible( true )
end

function PANEL:Paint( w, h )
	draw.RoundedBoxEx( self.BorderRadius, 0, 0, w, h, self.BackgroundColor, unpack( self.Border  ) )

	local selected_box_size = h - self.m_SelectedColorMargin * 2
	draw.RoundedBoxEx( self.BorderRadius / 2, self.m_SelectedColorMargin, self.m_SelectedColorMargin, selected_box_size, selected_box_size, self.SelectedColor, unpack( self.Border  ))

	local to = 0
	if self:IsHovered( ) then to = 255 end
	self.m_CornerHoveredLerp = Lerp( FrameTime() * 10, self.m_CornerHoveredLerp, to )

	local corner = {
		{ x = self.m_SelectedColorMargin + selected_box_size * 0.6, y = self.m_SelectedColorMargin + selected_box_size * 0.92 },
		{ x = self.m_SelectedColorMargin + selected_box_size * 0.92, y = self.m_SelectedColorMargin + selected_box_size * 0.6 },
		{ x = self.m_SelectedColorMargin + selected_box_size * 0.92, y = self.m_SelectedColorMargin + selected_box_size * 0.92 }
	}
	local corner_color = self.CornerColor
	if self.IsPressed then corner_color = KVS:GetDarkenColor( corner_color, 0.1 ) end

	surface.SetDrawColor( corner_color.r, corner_color.g, corner_color.b, self.m_CornerHoveredLerp )
	draw.NoTexture( )
	surface.DrawPoly( corner )

	if self:IsHovered( ) then
		self:SetCursor( 'hand' )
	else
		self:SetCursor( 'none' )
	end

	draw.SimpleText( string.format( 'rgba( %d, %d, %d, %d )', self.SelectedColor.r, self.SelectedColor.g, self.SelectedColor.b, self.SelectedColor.a ), font( 'Vegur', ScreenScale( 8 ) ), self.m_SelectedColorMargin * 3 + selected_box_size, h / 2, config( 'vgui.color.white' ), TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
end

function PANEL:OnMousePressed()
	self.IsPressed = true
end

function PANEL:IsSelectorOpened()
	return ( self.Menu and IsValid( self.Menu ) )
end

function PANEL:OnMouseReleased()
	self.IsPressed = false
	if self:IsSelectorOpened() then
		self.Menu:Remove()
	else
		-- open derma
		self:OpenSelectorPanel()
	end
end

derma.DefineControl( 'KVS.InputColor', nil, PANEL, 'EditablePanel' )

-- if IsValid( picker ) then picker:Remove() end
-- gui.EnableScreenClicker( true )
-- picker = vgui.Create( 'KVS.InputColor' )
-- picker:SetSize( 300, 35 )
-- picker:SetPos( 200, 200 )
