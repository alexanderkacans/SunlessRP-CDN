local PANEL = {}

--[[
	TODO :
	SetButtonColor
	SetDenyButtonColor
	SetAcceptButtonColor
]]

local config = KVS.GetConfig
local font = KVS.GetFont

KVS:AccessorFunc( PANEL, 'BorderRadius', 'BorderRadius', FORCE_NUMBER )
KVS:AccessorFunc( PANEL, '_IsBlur', 'Blur', FORCE_BOOL )
KVS:AccessorFunc( PANEL, '_ContentFont', 'ContentFont', FORCE_STRING )
KVS:AccessorFunc( PANEL, '_TitleFont', 'TitleFont', FORCE_STRING )
KVS:AccessorFunc( PANEL, '_SubtitleFont', 'SubtitleFont', FORCE_STRING )
KVS:AccessorFunc( PANEL, '_Animation', 'Animation', FORCE_BOOL )
KVS:AccessorFunc( PANEL, '_AnimationDelay', 'AnimationDelay', FORCE_NUMBER )

function PANEL:Init( )
	local this = self

	KVS:MakeChainableMethod( self, { 'SetPos', 'SetSize', 'Center', 'Show', 'MakePopup' } )

	self.BorderRounded = { true, true, true, true }
	self.MainColor = config( 'vgui.toast.main_color', true ) or Color( 52, 152, 219, 255 )
	self.BackgroundColor = config( 'vgui.toast.white', true ) or Color( 233, 233, 233, 255 )
	self.BorderRadius = 5

	self._ContentFont = font( 'Vegur', 15 )
	self._TitleFont = font( 'Vegur Bold', 30 )
	self._SubtitleFont = font( 'Vegur', 20 )

	self._TitlePanel = vgui.Create( 'KVS.Panel', self )
	self._TitlePanel:Dock( TOP )
	self._TitlePanel:SetMargin( 0, 0, 0, 0 )

	function self._TitlePanel:Paint( w, h )

		surface.SetFont( this._TitleFont )
		local title_w, title_h = surface.GetTextSize( this.Title )

		local subtitle_w, subtitle_h = 0, 0
		if ( this.Subtitle and isstring( this.Subtitle ) ) then
			surface.SetFont( this._SubtitleFont )
			subtitle_w, subtitle_h = surface.GetTextSize( this.Subtitle )
		end

		local icon_w, icon_h = 0, 0
		if ( this.Icon and isstring( this.Icon ) ) then
			surface.SetFont( this._IconFont )
			icon_w, icon_h = surface.GetTextSize( this.Icon )
		end

		-- marge entre le titre, sous titre
		local margin_between_texts = 1
		-- marge entre le titre, sous titre et icones
		local margin_between_icon = 5

		-- le plus long des textes ( pour centrer sur ce dernier )
		local max = math.max( title_w, subtitle_w )

		draw.RoundedBoxEx( this.BorderRadius, 0, 0, w, h, this.MainColor, true, true, false, false )
		draw.SimpleText( string.upper( this.Title or 'nil' ), this._TitleFont, ( w - max ) / 2, h / 2 - subtitle_h / 2 - margin_between_texts / 2, this.BackgroundColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

		if ( this.Subtitle and isstring( this.Subtitle ) ) then
			draw.SimpleText( this.Subtitle, this._SubtitleFont, ( w - max ) / 2, h / 2 + subtitle_h / 2 + margin_between_texts / 2, this.BackgroundColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		end

		if ( this.Icon and isstring( this.Icon ) ) then
			draw.SimpleText( this.Icon, this._IconFont, ( w - max ) / 2 - icon_w - margin_between_icon, h / 2, this.BackgroundColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		end
	end

	self._Content = vgui.Create( 'DLabel', self )
	self._Content:Dock( FILL )
	self._Content:SetWrap( true )
	self._Content:SetFont( font( 'Vegur', 18 ) )
	self._Content:DockMargin( 20, 5, 20, 5 )
	self._Content:SetColor( config( 'vgui.color.black_hard' ) )
	self._Content:SetText( 'Content' )
	self._Content:SetContentAlignment( 5 )

	self._ChoicePanel = vgui.Create( 'KVS.Panel', self )
	self._ChoicePanel:Dock( BOTTOM )
	function self._ChoicePanel:Paint( w, h )
	end

	self:SetType( 0 )
end

-- 0 = normal, with 'Accept' and 'Deny'
-- 1 = Information, with onlyy one button 'OK'
function PANEL:SetType( type )
	local this = self

	if type == 0 then
		if self._InformationButton and IsValid( self._InformationButton ) then
			self._InformationButton:Remove()
		end

		if not self._AcceptButton or not IsValid( self._AcceptButton ) then
			self._AcceptButton = vgui.Create( 'KVS.Button', self._ChoicePanel )
			self._AcceptButton:Dock( LEFT )
			self._AcceptButton:WithIcon( font( 'FAR', 18, 'extended' ), 0xf058, config( 'vgui.color.white' ) )
			self._AcceptButton:DockMargin( 0, 0, 0, 0 )
			self._AcceptButton:SetBorder( true, true, true, true )
			self._AcceptButton:SetColor( self.colorAccept or config( 'vgui.color.accept_green' ) )
			self._AcceptButton:SetText( 'ACCEPT' )
			function self._AcceptButton.DoClick()
				if this.OnAccept and isfunction( this.OnAccept ) then 
					this:OnAccept( )
				end

				this:Remove( )
			end
		end
		if not self._RefuseButton or not IsValid( self._RefuseButton ) then
			self._RefuseButton = vgui.Create( 'KVS.Button', self._ChoicePanel )
			self._RefuseButton:Dock( RIGHT )
			self._RefuseButton:WithIcon( font( 'FAR', 18, 'extended' ), 0xf057, config( 'vgui.color.white' ) )
			self._RefuseButton:DockMargin( 0, 0, 0, 0 )
			self._RefuseButton:SetBorder( true, true, true, true )
			self._RefuseButton:SetColor( self.colorRefuse or config( 'vgui.color.refuse_red' ) )
			self._RefuseButton:SetText( 'DENY' )
			function self._RefuseButton.DoClick()
				if this.OnDeny and isfunction( this.OnDeny ) then 
					this:OnDeny( )
				end

				this:Remove( )
			end
		end
	elseif type == 1 then
		if self._AcceptButton and IsValid( self._AcceptButton ) then
			self._AcceptButton:Remove()
		end
		if self._RefuseButton and IsValid( self._RefuseButton ) then
			self._RefuseButton:Remove()
		end

		self._InformationButton = vgui.Create( 'KVS.Button', self._ChoicePanel )
		self._InformationButton:Dock( FILL )
		self._InformationButton:WithIcon( font( 'FAR', 18, 'extended' ), 0xf058, config( 'vgui.color.white' ) )
		self._InformationButton:DockMargin( 0, 0, 0, 0 )
		self._InformationButton:SetBorder( true, true, true, true )
		self._InformationButton:SetColor( self.colorInformation or self.MainColor or config( 'vgui.color.primary' ) )
		self._InformationButton:SetText( 'OK' )
		function self._InformationButton.DoClick()
			if this.OnAccept and isfunction( this.OnAccept ) then 
				this:OnAccept( )
			end

			this:Remove( )
		end
	end

	return self
end

function PANEL:Think( )
	if self:GetAnimation( ) and not self.HasPlayedAnimation then
		self.HasPlayedAnimation = true
		self:SetAlpha( 0 )
		self:AlphaTo( 255, self:GetAnimationDelay( ) or 1 )
	end

	return self
end

-- for type 1 only
function PANEL:SetButtonText( text )
	if not self._InformationButton or not IsValid( self._InformationButton ) then return self end

	self._InformationButton:SetText( text )
	return self
end

-- for type 1 only
function PANEL:SetButtonIcon( font, unicode )
	if not self._InformationButton or not IsValid( self._InformationButton ) then return self end

	self._InformationButton:WithIcon( font, utf8.char( unicode ), config( 'vgui.color.white' ) )
	return self
end

-- for type 0 only
function PANEL:SetDenyText( text )
	if not self._RefuseButton or not IsValid( self._RefuseButton ) then return self end

	self._RefuseButton:SetText( text )
	return self
end

-- for type 0 only
function PANEL:SetAcceptText( text )
	if not self._AcceptButton or not IsValid( self._AcceptButton ) then return self end

	self._AcceptButton:SetText( text )
	return self
end

-- for type 0 only
function PANEL:OnAccept( )
	-- to be override
end

-- for type 0 only
function PANEL:OnDeny( )
	-- to be override
end

function PANEL:SetBorder( left, top, right, bottom )
	self.BorderRounded = { left, top, right, bottom }
	return self
end

function PANEL:SetContentAlignment( alignment )
	self._Content:SetContentAlignment( alignment )
	return self
end

function PANEL:SetContent( text )
	self._Content:SetText( text )
	return self
end

function PANEL:Paint( w, h )
	if ( self._IsBlur ) then
		Derma_DrawBackgroundBlur( self )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 200 ) )
	end

	draw.RoundedBoxEx( self.BorderRadius, 0, 0, w, h, self.BackgroundColor, unpack( self.BorderRounded ) )
end

function PANEL:Center( )
	self:SetPos( ( ScrW( ) - self:GetWide( ) ) / 2, ( ScrH( ) - self:GetTall( ) ) / 2 )
	return self
end

function PANEL:PerformLayout( )	
	self:SetSize( 400, 200 )
	self:Center( )
	
	if self._ChoicePanel and IsValid( self._ChoicePanel ) then
		self._ChoicePanel:SetTall( self:GetTall( ) * 0.175 )

		local margin_sides = self:GetWide( ) * 0.2
		local margin_bottom = self:GetTall( ) * 0.1

		self._ChoicePanel:SetMargin( margin_sides, 0, margin_sides, margin_bottom )
	end
	
	if self._AcceptButton and IsValid( self._AcceptButton ) then
		self._AcceptButton:SetWide( self._ChoicePanel:GetWide( ) * 0.5 - 5 )
	end
	
	if self._RefuseButton and IsValid( self._RefuseButton ) then
		self._RefuseButton:SetWide( self._ChoicePanel:GetWide( ) * 0.5 - 5 )
	end
	
	if self._TitlePanel and IsValid( self._TitlePanel ) then
		self._TitlePanel:SetTall( self:GetTall( ) * 0.3 )
	end
end

function PANEL:SetMainColor( color )
	self.MainColor = color
	return self
end

function PANEL:SetBackgroundColor( color )
	self.BackgroundColor = color
	return self
end

function PANEL:ShowCloseButton( show )
	self.ShowCloseButton = show
	self:InvalidateLayout( true )
	return self
end

function PANEL:SetSubtitle( subtitle )
	self.Subtitle = subtitle
	return self
end

function PANEL:GetSubtitle( )
	return self.Subtitle
end

function PANEL:SetTitle( title )
	self.Title = title
	return self
end

function PANEL:GetTitle( )
	return self.Title
end

function PANEL:SetIcon( font, unicode )
	self._IconFont = font
	self.Icon = utf8.char( unicode )
	return self
end

derma.DefineControl( 'KVS.Popup' , nil, PANEL, 'EditablePanel' )
