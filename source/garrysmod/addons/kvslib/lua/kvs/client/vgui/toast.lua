local PANEL = {}

local config = KVS.GetConfig
local font = KVS.GetFont

local functionsToOverride = {
	'SetSize', 'Center', 'MakePopup'
}

function PANEL:Init( )
	local this = self

	-- Override default functions
	for _, name in pairs( functionsToOverride ) do
		self[ name .. 'Internal' ] = self[ name ]
		self[ name ] = function( ... )
			self[ name .. 'Internal' ]( unpack( { ... } ) )
			return self
		end
	end

	-- TODO: Add default_duration to config file
	self.StartTime = CurTime( )
	self.Duration = config( 'vgui.toast.default_duration', true ) or 60
	self._TimerIdentifier = util.CRC( tostring ( math.random(0, os.time( ) ) ) )
	self.Icon = nil
	self.Content = nil
	self.BorderRounded = { true, true, true, true }
	self.ShowCloseButton = false
	-- TODO: Add main_color to config file 
	self.MainColor = config( 'vgui.toast.main_color', true ) or Color( 52, 152, 219, 255 )
	self.UseAnimation = true
	self.AnimationSpeed = 3
	self.Scale = 1
	self.OriginalX = 0
	self.OriginalY = 0
	self.BorderRadius = 5

	self._PanelToast = vgui.Create( 'DPanel', self )
	self._PanelToast:Dock( FILL )
	function self._PanelToast:Paint( ) end

	self._ColorIndicator = vgui.Create( 'DPanel', self._PanelToast )
	self._ColorIndicator:Dock( LEFT )
	function self._ColorIndicator:Paint( w, h )
		draw.RoundedBoxEx( this.BorderRadius, 0, 0, w, h, this.MainColor, this.BorderRounded[1], false, !this:GetPopupToast( ), false )
	end

	self._ProgressBar = vgui.Create( 'DPanel', self._PanelToast )
	self._ProgressBar:Dock( BOTTOM )
	function self._ProgressBar:Paint( w, h )
		local progress_color = KVS:GetDarkenColor( this.MainColor, 0.4 )
		if ( not this._TimerIdentifier or not timer.Exists( this._TimerIdentifier ) ) and not this._IsClosing then
			draw.RoundedBoxEx( this.BorderRadius, 0, 0, w, h, progress_color, false, false, false, this.BorderRounded[4] )
			return
		end

		if this._IsClosing then
			draw.RoundedBoxEx( this.BorderRadius, 0, 0, 0, h, progress_color, false, false, false, false )
			return
		end

		if this:IsHovered( ) or this:IsChildHovered( false ) then
			timer.Pause( this._TimerIdentifier )
		else
			timer.UnPause( this._TimerIdentifier )
		end

		local width = w * math.Clamp( math.abs( timer.TimeLeft( this._TimerIdentifier ) ) / this.Duration , 0, 1 )
		draw.RoundedBoxEx( this.BorderRadius, 0, 0, width, h, progress_color, false, false, false, w <= width and this.BorderRounded[4] or false )
	end

	self._Icon = vgui.Create( 'DLabel', self._PanelToast )
	self._Icon:Dock( LEFT )
	self._Icon:SetFont( font( 'FAS', 31, 'extended' ) )
	self._Icon:SetText( '' )
	self._Icon:SetContentAlignment( 5 )

	self._Container = vgui.Create( 'DPanel', self._PanelToast )
	self._Container:Dock( FILL )
	self._Container.Paint = function( ) end

	self._Content = vgui.Create( 'DLabel', self._Container )
	self._Content:Dock( FILL )
	self._Content:SetFont( font( 'Vegur', 18 ) )
	self._Content:SetWrap( true )
	self._Content:SetText( '' )
	self._Content:SetContentAlignment( 5 )

	self._CloseButton = vgui.Create( 'KVS.ButtonIcon', self._Container )
	self._CloseButton:Dock( RIGHT )
	self._CloseButton:SetIcon( font( 'FAR', 18, 'extended' ), 0xf057, config( 'vgui.color.white' ) )
	self._CloseButton:SetHoverIcon( font( 'FAS', 18, 'extended' ), 0xf057, config( 'vgui.color.dark_red' ) )
	self._CloseButton:DockMargin( 0, 5, 5, 0 )
	self._CloseButton.DoClick = function()
		this:Close( )
	end
end

function PANEL:GetPopupToast( )

	return self.IsPopupToast or false

end

function PANEL:SetPopupToast( isPopup, textAccept, textRefuse, onAccept, onRefuse, colorAccept, colorRefuse )

	if self.IsPopupToast == isPopup then return self end

	self.IsPopupToast = isPopup

	if isPopup then

		if self._ChoicePanel and IsValid( self._ChoicePanel ) then
			return self
		end

		if self._ColorIndicator and IsValid( self._ColorIndicator ) then
			self._ColorIndicator:Remove( )
		end

		self._ChoicePanel = vgui.Create( 'DPanel', self )
		self._ChoicePanel:Dock( BOTTOM )
		function self._ChoicePanel:Paint( w, h )
		end

		self._AcceptButton = vgui.Create( 'KVS.Button', self._ChoicePanel )
		self._AcceptButton:Dock( LEFT )
		self._AcceptButton:WithIcon( font( 'FAR', 18, 'extended' ), 0xf058, config( 'vgui.color.white' ) )
		self._AcceptButton:DockMargin( 0, 0, 0, 0 )
		self._AcceptButton:SetBorder( false, false, self.BorderRounded[3], false )
		self._AcceptButton:SetColor( colorAccept or config( 'vgui.color.accept_green' ) )
		self._AcceptButton:SetText( textAccept or "ACCEPT" )
		self._AcceptButton.DoClick = function()
			if onAccept and isfunction( onAccept ) then 
				onAccept()
			end

			self:Close( )
		end

		self._RefuseButton = vgui.Create( 'KVS.Button', self._ChoicePanel )
		self._RefuseButton:Dock( RIGHT )
		self._RefuseButton:WithIcon( font( 'FAR', 18, 'extended' ), 0xf057, config( 'vgui.color.white' ) )
		self._RefuseButton:DockMargin( 0, 0, 0, 0 )
		self._RefuseButton:SetBorder( false, false, false, self.BorderRounded[4] )
		self._RefuseButton:SetColor( colorRefuse or config( 'vgui.color.refuse_red' ) )
		self._RefuseButton:SetText( textRefuse or "DENY" )
		self._RefuseButton.DoClick = function()
			if onRefuse and isfunction( onRefuse ) then 
				onRefuse()
			end

			self:Close( )
		end

		return self._ChoicePanel

	elseif self._ChoicePanel and IsValid( self._ChoicePanel ) then
		
		self._PopupButtonSize = 0
		self._ChoicePanel:Remove( )

	end

end

function PANEL:PerformLayout( )
	local width, height = math.ceil( ScrW() * 0.2 ) * self.Scale, math.ceil( ScrH() * 0.07 ) * self.Scale
	
	if self.IsPopupToast then
		self._PopupButtonSize = height * 0.45
		height = height + self._PopupButtonSize
	end

	self:SetSize( width, height )

	if self._ChoicePanel and IsValid( self._ChoicePanel ) then
		self._ChoicePanel:SetTall( self._PopupButtonSize )
	end

	if self._AcceptButton and IsValid( self._AcceptButton ) then
		self._AcceptButton:SetWide( width / 2 )
	end

	if self._RefuseButton and IsValid( self._RefuseButton ) then
		self._RefuseButton:SetWide( width / 2 )
	end

	if self._ColorIndicator and IsValid( self._ColorIndicator ) then
		self._ColorIndicator:SetWide( width * 0.05 )
	end

	if self._ProgressBar and IsValid( self._ProgressBar ) then
		self._ProgressBar:SetHeight( ( height - ( self._PopupButtonSize or 0 ) ) * 0.06 )
	end

	if self.Icon ~= nil then
		self._Icon:SetFont( self.Icon.Font )
		self._Icon:SetColor( self.Icon.Color )
		self._Icon:SetText( utf8.char( self.Icon.Unicode ) )
		self._Icon:SetVisible( true )
	else
		self._Icon:SetVisible( false )
	end

	if self.Content ~= nil then
		self._Content:DockMargin( 0, 5 * self.Scale, 0, 5 * self.Scale )
		self._Content:SetText( self.Content )
	end

	self._CloseButton:SetVisible( self.ShowCloseButton )
	if self.ShowCloseButton then
		self._CloseButton:SetAlignement( 8 )
	end
end

function PANEL:Paint( w, h )
	draw.RoundedBoxEx( self.BorderRadius, 0, 0, w, h, Color( 44, 44, 44, 255 ), unpack( self.BorderRounded ) )
end

function PANEL:SetBorder( left, top, right, bottom )
	self.BorderRounded = { left, top, right, bottom }
	return self
end

function PANEL:SetPosition( x, y )
	self.OriginalX = x
	self.OriginalY = y

	if self.UseAnimation then
		if x > ScrW() / 2 then
			self:SetPos( ScrW() + self:GetWide( ) * 1.1, self.OriginalY )
		else
			self:SetPos( 0 - self:GetWide( ) * 1.2, self.OriginalY )
		end
	end

	return self
end

function PANEL:Close( )
	local this = self
	self._IsClosing = true
	surface.PlaySound( self.CloseSound or config( 'vgui.toast.sound.on_close', true ) or 'buttons/combine_button1.wav' )
	if self.UseAnimation then
		local x = 0
		if self.OriginalX > ScrW() / 2 then
			x = ScrW()
		else
			x = 0 - self:GetWide( )
		end

		self:MoveTo( x, self.OriginalY, 1 / self.AnimationSpeed, 0, -1, function( )
			this:Remove( )
			if this.PostClose then this:PostClose( this ) end
		end)
	else
		self:Remove( )
		if self.PostClose then self:PostClose( self ) end
	end
end

function PANEL:Display( )
	local this = self
	self:SetVisible( true )
	surface.PlaySound( self.OpenSound or config( 'vgui.toast.sound.on_open', true ) or 'buttons/button19.wav' )
	if self.UseAnimation then
		self:MoveTo( self.OriginalX, self.OriginalY, 1 / self.AnimationSpeed, 0, -1 )
	else
		self:SetPos( self.OriginalX, self.OriginalY )
		self:Show( )
	end

	if self.Duration > 0 then
		self._TimerIdentifier = self._TimerIdentifier .. util.CRC( tostring( self.StartTime ) .. '.progress.toast.timer' .. tostring( self.Duration ) .. tostring( os.time() ) )
		timer.Create( self._TimerIdentifier, self.Duration, 1, function( ) if IsValid( this ) then this:Close() end end)
	end

	return self
end

function PANEL:SetScale( scale )
	if scale <= 0 then
		error( 'Toast out of bounds scale : ' .. scale  )
		return nil
	end
	self.Scale = scale
	self:InvalidateLayout( true )
	return self
end

function PANEL:SetAnimationSpeed( speed )
	self.AnimationSpeed = speed
	return self
end

function PANEL:SetUseAnimation( animation )
	self.UseAnimation = animation
	return self
end

function PANEL:SetMainColor( color )
	if not IsColor( color ) then
		-- TODO: Handle error message
		error( 'Not a color on the toast : ' .. color )
		return nil
	end
	self.MainColor = color
	return self
end

function PANEL:SetShowCloseButton( show )
	self.ShowCloseButton = show
	self:InvalidateLayout( true )
	return self
end

function PANEL:SetRoundedBorder( rounded )
	self.BorderRounded = { rounded, rounded, rounded, rounded }
	return self
end

function PANEL:SetBorderRadius( radius )
	self.BorderRadius = radius
	return self
end

function PANEL:SetDuration( duration )
	self.Duration = duration

	if duration <= 0 then
		if self._ProgressBar and IsValid( self._ProgressBar ) then
			self._ProgressBar:Remove( )
		end
	end

	if timer.Exists( self._TimerIdentifier )  then
		
		timer.Remove( self._TimerIdentifier )

	end

	return self
end

function PANEL:SetIcon( font_name, unicode, color )
	-- TODO: Handle font verification with Stim super method
	self.Icon = { Font = font_name, Unicode = unicode, Color = color }
	self:InvalidateLayout( true )
	return self
end

function PANEL:SetContent( text )
	self.Content = text
	self:InvalidateLayout( true )
	return self
end

function PANEL:SetOpenSound( sound )
	self.OpenSound = sound
	return self
end

function PANEL:SetCloseSound( sound )
	self.CloseSound = sound
	return self
end

derma.DefineControl( 'KVS.Toast' , nil, PANEL, 'EditablePanel' )
