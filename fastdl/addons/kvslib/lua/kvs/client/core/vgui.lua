local font = KVS.GetFont
local config = KVS.GetConfig

--- Function used to Load all VGUI components from the folder components
function KVS:LoadVGUI( )
	local files = file.Find( string.format( '%s/*.lua', KVS.VGUI_PATH ), 'LUA' )
	for _, v in pairs( files ) do
		include( string.format( '%s/%s', KVS.VGUI_PATH, v ) )
	end
end

function KVS:YesNoBox( title, text, icon, onValidation, onFailure )
	if icon and not icon.font or not icon.unicode then return end
	local popup = vgui.Create( 'KVS.Popup' )
		:SetTitle( title or '' )
		:SetContent( text or '' )
		:SetIcon( icon.font, icon.unicode )
		:SetSize( 400, 200 )
		:SetBlur( true )
		:SetAcceptText( "YES" )
		:SetDenyText( "NO" )
		:MakePopup( )
		:Center( )
		:SetAnimation( true )
		:SetAnimationDelay( 0.2 )
	function popup:OnAccept( )
		if onValidation and isfunction( onValidation ) then
			onValidation()
		end
	end

	function popup:OnDeny( )
		if onFailure and isfunction( onFailure ) then
			onFailure()
		end
	end
end

function KVS:DermaStringRequest( strTitle, strText, strPlaceholder, fnEnter, fnCancel, strButtonText, strButtonCancelText )
	local size_x, size_y = 400, 170

	local dFrame = vgui.Create( "KVS.Frame" )
	dFrame:SetSize( size_x, size_y )
	dFrame:SetBorder( false )
	dFrame:SetUseAnimation( false )
	dFrame:ShowCloseButton( true )
	dFrame:SetTitle( strTitle )
	dFrame:Center()
	dFrame:MakePopup()
	function dFrame:Paint(w, h)
		Derma_DrawBackgroundBlur( dFrame, self.startTime )
		draw.RoundedBox(4, 0, 0, w, h, config("vgui.color.black_rhard"))
	end

	local dText = vgui.Create( "DLabel", dFrame )
	dText:Dock( TOP )
	dText:DockMargin( 10, 10, 10, 0 )
	dText:SetText( strText or "Message Text" )
	dText:SizeToContentsY()
	dText:SetFont( font( "Rajdhani Bold", 20 ) )
	dText:SetContentAlignment( 5 )
	dText:SetTextColor( color_white )

	local dEntry = vgui.Create( "KVS.Input", dFrame )
	dEntry:Dock( TOP )
	dEntry:DockMargin( 10, 10, 10, 10 )
	dEntry:SetText( strPlaceholder or "" )
	dEntry.OnEnter = function() dFrame:Close() fnEnter( dEntry:GetValue() ) end
	dEntry:RequestFocus()

	local panelButtons = vgui.Create( "KVS.Panel", dFrame )
	panelButtons:Dock( BOTTOM )
	panelButtons:SetTall( 30 )

	local acceptButton = vgui.Create( "KVS.Button", panelButtons )
	acceptButton:Dock( LEFT )
	acceptButton:SetWide( size_x / 2 )
	acceptButton:SetText( strButtonText )
	acceptButton:SetFont( font( 'Rajdhani Bold', 20 ) )
	acceptButton:SetColor( config( "vgui.color.primary" ) )
	acceptButton:SetBorder( false, false, true, false )
	acceptButton:WithIcon( font( 'FAS', 20, 'extended' ), 0xf058 )
	function acceptButton:DoClick()
		if fnEnter then
			fnEnter( dEntry:GetValue() or "" )
		end
		dFrame:Remove()
	end

	local refuseButton = vgui.Create( "KVS.Button", panelButtons )
	refuseButton:Dock( RIGHT )
	refuseButton:SetWide( size_x / 2 )
	refuseButton:SetText( strButtonCancelText )
	refuseButton:SetFont( font( 'Rajdhani Bold', 20 ) )
	refuseButton:SetColor( config( "vgui.color.refuse_red" ) )
	refuseButton:WithIcon( font( 'FAS', 20, 'extended' ), 0xf057 )
	refuseButton:SetBorder( false, false, false, true )
	function refuseButton:DoClick()
		if fnCancel then
			fnCancel()
		end
		dFrame:Remove()
	end
end