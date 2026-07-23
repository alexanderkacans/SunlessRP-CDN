function BRICKS_SERVER.Func.Message( text, title, button, buttonFunc )
	local frameBack = vgui.Create( "DFrame" )
	frameBack:SetSize( ScrW(), ScrH() )
	frameBack:Center()
	frameBack:SetTitle( "" )
	frameBack:ShowCloseButton( false )
	frameBack:SetDraggable( false )
	frameBack:MakePopup()
	frameBack:SetAlpha( 0 )
	frameBack:AlphaTo( 255, 0.1, 0 )
	frameBack.Paint = function( self2, w, h ) 
		BRICKS_SERVER.Func.DrawBlur( self2, 4, 4 )

		surface.SetDrawColor( 0, 0, 0, 100 )
		surface.DrawRect( 0, 0, w, h )
	end

	surface.SetFont( "BRICKS_SERVER_Font20" )
	local textX, textY = surface.GetTextSize( text )

	local backPanel = vgui.Create( "bricks_server_dframepanel", frameBack )
	backPanel:SetHeader( title )
	backPanel:SetWide( math.max( ScrW()*0.15, textX+30 ) )
	backPanel.onCloseFunc = function()
		frameBack:Remove()
	end

	local textArea = vgui.Create( "DPanel", backPanel )
	textArea:Dock( TOP )
	textArea:DockMargin( 10, 10, 10, 0 )
	textArea:SetTall( 30 )
	textArea.Paint = function( self2, w, h ) 
		draw.SimpleText( text, "BRICKS_SERVER_Font20", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

	local bottomButton = vgui.Create( "DButton", backPanel )
	bottomButton:SetText( "" )
	bottomButton:Dock( BOTTOM )
	bottomButton:DockMargin( 10, 10, 10, 10 )
	bottomButton:SetTall( 40 )
	local changeAlpha = 0
	bottomButton.Paint = function( self2, w, h )
		if( self2:IsHovered() ) then
			changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
		else
			changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
		end
		
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

		surface.SetAlphaMultiplier( changeAlpha/255 )
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )
		surface.SetAlphaMultiplier( 1 )

		draw.SimpleText( button, "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	bottomButton.DoClick = function()
		if( buttonFunc ) then
			buttonFunc()
		end
		
		frameBack:AlphaTo( 0, 0.1, 0, function()
			if( IsValid( frameBack ) ) then
				frameBack:Remove()
			end
		end )
	end

	backPanel:SetTall( bottomButton:GetTall()+(4*10)+textArea:GetTall()+backPanel.headerHeight )
	backPanel:Center()
end

function BRICKS_SERVER.Func.Query( text, title, confirmText, cancelText, confirmFunc, cancelFunc )
	local frameBack = vgui.Create( "DFrame" )
	frameBack:SetSize( ScrW(), ScrH() )
	frameBack:Center()
	frameBack:SetTitle( "" )
	frameBack:ShowCloseButton( false )
	frameBack:SetDraggable( false )
	frameBack:MakePopup()
	frameBack:SetAlpha( 0 )
	frameBack:AlphaTo( 255, 0.1, 0 )
	frameBack.Paint = function( self2, w, h ) 
		BRICKS_SERVER.Func.DrawBlur( self2, 4, 4 )

		surface.SetDrawColor( 0, 0, 0, 100 )
		surface.DrawRect( 0, 0, w, h )
	end

	surface.SetFont( "BRICKS_SERVER_Font20" )
	local textX, textY = surface.GetTextSize( text )

	local backPanel = vgui.Create( "bricks_server_dframepanel", frameBack )
	backPanel:SetHeader( title )
	backPanel:SetWide( math.max( ScrW()*0.15, textX+30 ) )
	backPanel.onCloseFunc = function()
		frameBack:Remove()
	end

	local textArea = vgui.Create( "DPanel", backPanel )
	textArea:Dock( TOP )
	textArea:DockMargin( 10, 10, 10, 0 )
	textArea:SetTall( 30 )
	textArea.Paint = function( self2, w, h ) 
		draw.SimpleText( text, "BRICKS_SERVER_Font20", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

	local buttonBack = vgui.Create( "DPanel", backPanel )
	buttonBack:Dock( BOTTOM )
	buttonBack:DockMargin( 10, 10, 10, 10 )
	buttonBack:SetTall( 40 )
	buttonBack.Paint = function() end

	local confirmButton = vgui.Create( "DButton", buttonBack )
	confirmButton:SetText( "" )
	confirmButton:Dock( LEFT )
	confirmButton:SetWide( (backPanel:GetWide()-30)/2 )
	local changeAlpha = 0
	confirmButton.Paint = function( self2, w, h )
		if( self2:IsHovered() ) then
			changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
		else
			changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
		end
		
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

		surface.SetAlphaMultiplier( changeAlpha/255 )
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )
		surface.SetAlphaMultiplier( 1 )

		draw.SimpleText( confirmText, "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	confirmButton.DoClick = function()
		if( confirmFunc ) then
			confirmFunc()
		end
		
		frameBack:AlphaTo( 0, 0.1, 0, function()
			if( IsValid( frameBack ) ) then
				frameBack:Remove()
			end
		end )
	end

	local cancelButton = vgui.Create( "DButton", buttonBack )
	cancelButton:SetText( "" )
	cancelButton:Dock( RIGHT )
	cancelButton:SetWide( (backPanel:GetWide()-30)/2 )
	local changeAlpha = 0
	cancelButton.Paint = function( self2, w, h )
		if( self2:IsHovered() ) then
			changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
		else
			changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
		end
		
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

		surface.SetAlphaMultiplier( changeAlpha/255 )
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )
		surface.SetAlphaMultiplier( 1 )

		draw.SimpleText( cancelText, "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	cancelButton.DoClick = function()
		if( cancelFunc ) then
			cancelFunc()
		end

		frameBack:AlphaTo( 0, 0.1, 0, function()
			if( IsValid( frameBack ) ) then
				frameBack:Remove()
			end
		end )
	end

	backPanel:SetTall( buttonBack:GetTall()+(4*10)+textArea:GetTall()+backPanel.headerHeight )
	backPanel:Center()
end

function BRICKS_SERVER.Func.StringRequest( title, subtitle, default, func_confirm, func_cancel, confirmText, cancelText, numberOnly )
	local frameBack = vgui.Create( "DFrame" )
	frameBack:SetSize( ScrW(), ScrH() )
	frameBack:Center()
	frameBack:SetTitle( "" )
	frameBack:ShowCloseButton( false )
	frameBack:SetDraggable( false )
	frameBack:MakePopup()
	frameBack:SetAlpha( 0 )
	frameBack:AlphaTo( 255, 0.1, 0 )
	frameBack.Paint = function( self2, w, h ) 
		BRICKS_SERVER.Func.DrawBlur( self2, 4, 4 )

		surface.SetDrawColor( 0, 0, 0, 100 )
		surface.DrawRect( 0, 0, w, h )
	end

	surface.SetFont( "BRICKS_SERVER_Font20" )
	local textX, textY = surface.GetTextSize( subtitle )

	local backPanel = vgui.Create( "bricks_server_dframepanel", frameBack )
	backPanel:SetHeader( title )
	backPanel:SetWide( math.max( ScrW()*0.15, textX+30 ) )
	backPanel.onCloseFunc = function()
		frameBack:Remove()
	end

	local textArea = vgui.Create( "DPanel", backPanel )
	textArea:Dock( TOP )
	textArea:DockMargin( 10, 10, 10, 0 )
	textArea:SetTall( 30 )
	textArea.Paint = function( self2, w, h ) 
		draw.SimpleText( subtitle, "BRICKS_SERVER_Font20", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

	local textEntryBack = vgui.Create( "DPanel", backPanel )
	textEntryBack:Dock( TOP )
	textEntryBack:DockMargin( 10, 10, 10, 0 )
	textEntryBack:SetTall( 40 )
    local Alpha = 0
    local textEntry
    local color1 = BRICKS_SERVER.Func.GetTheme( 1 )
    textEntryBack.Paint = function( self2, w, h )
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

        if( textEntry:IsEditing() ) then
            Alpha = math.Clamp( Alpha+5, 0, 100 )
        else
            Alpha = math.Clamp( Alpha-5, 0, 100 )
        end
        
        draw.RoundedBox( 5, 0, 0, w, h, Color( color1.r, color1.g, color1.b, Alpha ) )
    end

	if( numberOnly ) then
		textEntry = vgui.Create( "bricks_server_numberwang", textEntryBack )
		textEntry:Dock( FILL )
		textEntry:SetMinMax( 0, 9999999999999 )
	else
		textEntry = vgui.Create( "bricks_server_textentry", textEntryBack )
		textEntry:Dock( FILL )
	end
	textEntry:SetValue( default or "" )

	local buttonPanel = vgui.Create( "DPanel", backPanel )
	buttonPanel:Dock( BOTTOM )
	buttonPanel:DockMargin( 10, 10, 10, 10 )
	buttonPanel:SetTall( 40 )
	buttonPanel.Paint = function( self2, w, h ) end

	local leftButton = vgui.Create( "DButton", buttonPanel )
	leftButton:Dock( LEFT )
	leftButton:SetText( "" )
	leftButton:DockMargin( 0, 0, 0, 0 )
	leftButton:SetWide( (backPanel:GetWide()-30)/2 )
	local changeAlpha = 0
	leftButton.Paint = function( self2, w, h )
		if( self2:IsHovered() ) then
			changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
		else
			changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
		end
		
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

		surface.SetAlphaMultiplier( changeAlpha/255 )
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )
		surface.SetAlphaMultiplier( 1 )

		draw.SimpleText( confirmText, "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	leftButton.DoClick = function()
		func_confirm( textEntry:GetValue() )
		frameBack:AlphaTo( 0, 0.1, 0, function()
			if( IsValid( frameBack ) ) then
				frameBack:Remove()
			end
		end )
	end

	local rightButton = vgui.Create( "DButton", buttonPanel )
	rightButton:Dock( RIGHT )
	rightButton:SetText( "" )
	rightButton:DockMargin( 0, 0, 0, 0 )
	rightButton:SetWide( (backPanel:GetWide()-30)/2 )
	local changeAlpha = 0
	rightButton.Paint = function( self2, w, h )
		if( self2:IsHovered() ) then
			changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
		else
			changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
		end
		
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

		surface.SetAlphaMultiplier( changeAlpha/255 )
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )
		surface.SetAlphaMultiplier( 1 )

		draw.SimpleText( cancelText, "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	rightButton.DoClick = function()
		func_cancel( textEntry:GetValue() )
		frameBack:AlphaTo( 0, 0.1, 0, function()
			if( IsValid( frameBack ) ) then
				frameBack:Remove()
			end
		end )
	end

	backPanel:SetTall( buttonPanel:GetTall()+(4*10)+textArea:GetTall()+textEntryBack:GetTall()+backPanel.headerHeight )
	backPanel:Center()
end

function BRICKS_SERVER.Func.ComboRequest( title, subtitle, default, options, func_confirm, func_cancel, confirmText, cancelText, searchSelect )
	local frameBack = vgui.Create( "DFrame" )
	frameBack:SetSize( ScrW(), ScrH() )
	frameBack:Center()
	frameBack:SetTitle( "" )
	frameBack:ShowCloseButton( false )
	frameBack:SetDraggable( false )
	frameBack:MakePopup()
	frameBack:SetAlpha( 0 )
	frameBack:AlphaTo( 255, 0.1, 0 )
	frameBack.Paint = function( self2, w, h ) 
		BRICKS_SERVER.Func.DrawBlur( self2, 4, 4 )

		surface.SetDrawColor( 0, 0, 0, 100 )
		surface.DrawRect( 0, 0, w, h )
	end

	surface.SetFont( "BRICKS_SERVER_Font20" )
	local textX, textY = surface.GetTextSize( subtitle )

	local backPanel = vgui.Create( "bricks_server_dframepanel", frameBack )
	backPanel:SetHeader( title )
	backPanel:SetWide( math.max( ScrW()*0.15, textX+30 ) )
	backPanel.onCloseFunc = function()
		frameBack:Remove()
	end

	local textArea = vgui.Create( "DPanel", backPanel )
	textArea:Dock( TOP )
	textArea:DockMargin( 10, 10, 10, 0 )
	textArea:SetTall( 30 )
	textArea.Paint = function( self2, w, h ) 
		draw.SimpleText( subtitle, "BRICKS_SERVER_Font20", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

	local comboEntry
	if( not searchSelect ) then
		comboEntry = vgui.Create( "bricks_server_combo", backPanel )
	else
		comboEntry = vgui.Create( "bricks_server_combo_search", backPanel )
	end

	if( not IsValid( comboEntry ) ) then return end

	comboEntry:Dock( TOP )
	comboEntry:DockMargin( 10, 10, 10, 0 )
	comboEntry:SetTall( 40 )
	comboEntry:SetValue( BRICKS_SERVER.Func.L( "selectOption" ) )
	for k, v in pairs( options ) do
		if( default != k and default != v ) then
			comboEntry:AddChoice( v, k, false )
		else
			comboEntry:AddChoice( v, k, true )
		end
	end

	local buttonPanel = vgui.Create( "DPanel", backPanel )
	buttonPanel:Dock( BOTTOM )
	buttonPanel:DockMargin( 10, 10, 10, 10 )
	buttonPanel:SetTall( 40 )
	buttonPanel.Paint = function( self2, w, h ) end

	local leftButton = vgui.Create( "DButton", buttonPanel )
	leftButton:Dock( LEFT )
	leftButton:SetText( "" )
	leftButton:DockMargin( 0, 0, 0, 0 )
	leftButton:SetWide( (backPanel:GetWide()-30)/2 )
	local changeAlpha = 0
	leftButton.Paint = function( self2, w, h )
		if( self2:IsHovered() ) then
			changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
		else
			changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
		end
		
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

		surface.SetAlphaMultiplier( changeAlpha/255 )
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )
		surface.SetAlphaMultiplier( 1 )

		draw.SimpleText( confirmText, "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	leftButton.DoClick = function()
		local value, data = comboEntry:GetSelected()
		if( value and data ) then
			func_confirm( value, data )
			frameBack:AlphaTo( 0, 0.1, 0, function()
				if( IsValid( frameBack ) ) then
					frameBack:Remove()
				end
			end )
		else
			notification.AddLegacy( BRICKS_SERVER.Func.L( "selectValue" ), 1, 3 )
		end
	end

	local rightButton = vgui.Create( "DButton", buttonPanel )
	rightButton:Dock( RIGHT )
	rightButton:SetText( "" )
	rightButton:DockMargin( 0, 0, 0, 0 )
	rightButton:SetWide( (backPanel:GetWide()-30)/2 )
	local changeAlpha = 0
	rightButton.Paint = function( self2, w, h )
		if( self2:IsHovered() ) then
			changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
		else
			changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
		end
		
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

		surface.SetAlphaMultiplier( changeAlpha/255 )
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )
		surface.SetAlphaMultiplier( 1 )

		draw.SimpleText( cancelText, "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	rightButton.DoClick = function()
		local value, data = comboEntry:GetSelected()
		if( value and data ) then
			func_cancel( value, data )
			frameBack:AlphaTo( 0, 0.1, 0, function()
				if( IsValid( frameBack ) ) then
					frameBack:Remove()
				end
			end )
		else
			func_cancel( false, false )
			frameBack:AlphaTo( 0, 0.1, 0, function()
				if( IsValid( frameBack ) ) then
					frameBack:Remove()
				end
			end )
		end
	end

	backPanel:SetTall( buttonPanel:GetTall()+(4*10)+textArea:GetTall()+comboEntry:GetTall()+backPanel.headerHeight )
	backPanel:Center()
end

function BRICKS_SERVER.Func.ColorRequest( title, subtitle, default, func_confirm, func_cancel, confirmText, cancelText )
	local frameBack = vgui.Create( "DFrame" )
	frameBack:SetSize( ScrW(), ScrH() )
	frameBack:Center()
	frameBack:SetTitle( "" )
	frameBack:ShowCloseButton( false )
	frameBack:SetDraggable( false )
	frameBack:MakePopup()
	frameBack:SetAlpha( 0 )
	frameBack:AlphaTo( 255, 0.1, 0 )
	frameBack.Paint = function( self2, w, h ) 
		BRICKS_SERVER.Func.DrawBlur( self2, 4, 4 )

		surface.SetDrawColor( 0, 0, 0, 100 )
		surface.DrawRect( 0, 0, w, h )
	end

	surface.SetFont( "BRICKS_SERVER_Font20" )
	local textX, textY = surface.GetTextSize( subtitle )

	local backPanel = vgui.Create( "bricks_server_dframepanel", frameBack )
	backPanel:SetHeader( title )
	backPanel:SetWide( math.max( ScrW()*0.17, textX+30 ) )
	backPanel.onCloseFunc = function()
		frameBack:Remove()
	end

	local textArea = vgui.Create( "DPanel", backPanel )
	textArea:Dock( TOP )
	textArea:DockMargin( 10, 10, 10, 0 )
	textArea:SetTall( 30 )
	textArea.Paint = function( self2, w, h ) 
		draw.SimpleText( subtitle, "BRICKS_SERVER_Font20", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

	local colorEntry = vgui.Create( "DColorMixer", backPanel )
	colorEntry:Dock( TOP )
	colorEntry:DockMargin( 10, 10, 10, 0 )
	colorEntry:SetTall( 150 )
	colorEntry:SetPalette( false )
	colorEntry:SetAlphaBar( false) 
	colorEntry:SetWangs( true )
	colorEntry:SetColor( default or Color( 255, 255, 255 ) )
	local displayColor = colorEntry:GetColor()
	colorEntry.ValueChanged = function()
		displayColor = colorEntry:GetColor()
	end

	local displayColorPanel = vgui.Create( "DPanel", backPanel )
	displayColorPanel:Dock( TOP )
	displayColorPanel:DockMargin( 10, 10, 10, 10 )
	displayColorPanel:SetTall( 20 )
	displayColorPanel.Paint = function( self2, w, h ) 
		draw.RoundedBox( 5, 0, 0, w, h, displayColor )
	end

	local buttonPanel = vgui.Create( "DPanel", backPanel )
	buttonPanel:Dock( BOTTOM )
	buttonPanel:DockMargin( 10, 0, 10, 10 )
	buttonPanel:SetTall( 40 )
	buttonPanel.Paint = function( self2, w, h ) end

	local leftButton = vgui.Create( "DButton", buttonPanel )
	leftButton:Dock( LEFT )
	leftButton:SetText( "" )
	leftButton:DockMargin( 0, 0, 0, 0 )
	surface.SetFont( "BRICKS_SERVER_Font25" )
	local textX, textY = surface.GetTextSize( confirmText )
	textX = textX+20
	leftButton:SetWide( math.max( (ScrW()/2560)*150, textX ) )
	local changeAlpha = 0
	leftButton.Paint = function( self2, w, h )
		if( self2:IsHovered() ) then
			changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
		else
			changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
		end
		
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

		surface.SetAlphaMultiplier( changeAlpha/255 )
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )
		surface.SetAlphaMultiplier( 1 )

		draw.SimpleText( confirmText, "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	leftButton.DoClick = function()
		local value = colorEntry:GetColor()
		if( value ) then
			func_confirm( value )
			frameBack:AlphaTo( 0, 0.1, 0, function()
				if( IsValid( frameBack ) ) then
					frameBack:Remove()
				end
			end )
		else
			notification.AddLegacy( BRICKS_SERVER.Func.L( "selectColor" ), 1, 3 )
		end
	end

	local rightButton = vgui.Create( "DButton", buttonPanel )
	rightButton:Dock( RIGHT )
	rightButton:SetText( "" )
	rightButton:DockMargin( 0, 0, 0, 0 )
	surface.SetFont( "BRICKS_SERVER_Font25" )
	local textX, textY = surface.GetTextSize( cancelText )
	textX = textX+20
	rightButton:SetWide( math.max( (ScrW()/2560)*150, textX ) )
	local changeAlpha = 0
	rightButton.Paint = function( self2, w, h )
		if( self2:IsHovered() ) then
			changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
		else
			changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
		end
		
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

		surface.SetAlphaMultiplier( changeAlpha/255 )
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )
		surface.SetAlphaMultiplier( 1 )

		draw.SimpleText( cancelText, "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	rightButton.DoClick = function()
		local value = colorEntry:GetColor()
		if( value ) then
			func_cancel( value )
			frameBack:AlphaTo( 0, 0.1, 0, function()
				if( IsValid( frameBack ) ) then
					frameBack:Remove()
				end
			end )
		else
			func_cancel( false )
			frameBack:AlphaTo( 0, 0.1, 0, function()
				if( IsValid( frameBack ) ) then
					frameBack:Remove()
				end
			end )
		end
	end

	backPanel:SetTall( buttonPanel:GetTall()+(4*10)+textArea:GetTall()+colorEntry:GetTall()+displayColorPanel:GetTall()+10+backPanel.headerHeight )
	backPanel:Center()
end

function BRICKS_SERVER.Func.PassiveQuery( text, title, time, confirmFunc, cancelFunc )
	local backPanel = vgui.Create( "bricks_server_dframepanel" )
	backPanel:DisableClose()
	backPanel:SetHeader( title )
	backPanel:SetWide( ScrW()*0.1 )

	local textArea = vgui.Create( "DPanel", backPanel )
	textArea:Dock( TOP )
	textArea:DockMargin( 10, 10, 10, 0 )
	textArea:SetTall( 30 )
	textArea.Paint = function( self2, w, h ) 
		draw.SimpleText( text, "BRICKS_SERVER_Font20", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

	local buttonBack = vgui.Create( "DPanel", backPanel )
	buttonBack:Dock( BOTTOM )
	buttonBack:DockMargin( 10, 10, 10, 10 )
	buttonBack:SetTall( 40 )
	buttonBack.Paint = function() end

	local confirmButton = vgui.Create( "DButton", buttonBack )
	confirmButton:SetText( "" )
	confirmButton:Dock( LEFT )
	confirmButton:SetWide( (backPanel:GetWide()-30)/2 )
	local changeAlpha = 0
	local tickMat = Material( "materials/bricks_server/tick_nofill.png" )
	confirmButton.Paint = function( self2, w, h )
		if( self2:IsHovered() ) then
			changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
		else
			changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
		end
		
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

		surface.SetAlphaMultiplier( changeAlpha/255 )
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )
		surface.SetAlphaMultiplier( 1 )

		surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
		surface.SetMaterial( tickMat )
		local size = 24
		surface.DrawTexturedRect( (w/2)-(size/2), (h/2)-(size/2), size, size )
	end
	confirmButton.DoClick = function()
		if( confirmFunc ) then
			confirmFunc()
		end
		
		backPanel:AlphaTo( 0, 0.1, 0, function()
			if( IsValid( backPanel ) ) then
				backPanel:Remove()
			end
		end )
	end

	local cancelButton = vgui.Create( "DButton", buttonBack )
	cancelButton:SetText( "" )
	cancelButton:Dock( RIGHT )
	cancelButton:SetWide( (backPanel:GetWide()-30)/2 )
	local changeAlpha = 0
	local denyMat = Material( "materials/bricks_server/close.png" )
	cancelButton.Paint = function( self2, w, h )
		if( self2:IsHovered() ) then
			changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
		else
			changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
		end
		
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

		surface.SetAlphaMultiplier( changeAlpha/255 )
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )
		surface.SetAlphaMultiplier( 1 )

		surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
		surface.SetMaterial( denyMat )
		local size = 24
		surface.DrawTexturedRect( (w/2)-(size/2), (h/2)-(size/2), size, size )
	end
	cancelButton.DoClick = function()
		if( cancelFunc ) then
			cancelFunc()
		end

		backPanel:AlphaTo( 0, 0.1, 0, function()
			if( IsValid( backPanel ) ) then
				backPanel:Remove()
			end
		end )
	end

	backPanel:SetTall( buttonBack:GetTall()+(4*10)+textArea:GetTall()+backPanel.headerHeight )
	backPanel:SetPos( 20, 20 )

	timer.Simple( (time or 5), function()
		if( IsValid( backPanel ) ) then
			if( cancelFunc ) then
				cancelFunc()
			end
			
			backPanel:AlphaTo( 0, 0.1, 0, function()
				if( IsValid( backPanel ) ) then
					backPanel:Remove()
				end
			end )
		end
	end )
end

function BRICKS_SERVER.Func.CreatePopoutQuery( text, parent, panelWide, panelTall, confirmText, cancelText, confirmFunc, cancelFunc, disableBackgroundButton )
	if( IsValid( parent.brs_popout ) ) then
		parent.brs_popout:Remove()
	end

	local popoutClose = vgui.Create( "DButton", parent )
	popoutClose:SetSize( panelWide, panelTall )
	popoutClose:SetAlpha( 0 )
	popoutClose:AlphaTo( 255, 0.2 )
	popoutClose:SetText( "" )
	popoutClose:SetCursor( "arrow" )
	popoutClose.Paint = function( self2, w, h )
		surface.SetDrawColor( 0, 0, 0, 150 )
		surface.DrawRect( 0, 0, w, h )
		BRICKS_SERVER.Func.DrawBlur( self2, 2, 2 )
	end

	surface.SetFont( "BRICKS_SERVER_Font20" )
	local textX, textY = surface.GetTextSize( text )

	local popoutWide, popoutTall = math.max( ScrW()*0.15, textX+40 ), 40+(4*10)+30+20

	parent.brs_popout = vgui.Create( "DPanel", parent )
	parent.brs_popout:SetSize( 0, 0 )
	parent.brs_popout:SizeTo( popoutWide, popoutTall, 0.2 )
	parent.brs_popout.Paint = function( self2, w, h )
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

		draw.SimpleText( text, "BRICKS_SERVER_Font20", w/2, h/3, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	parent.brs_popout.OnSizeChanged = function( self2 )
		self2:SetPos( (panelWide/2)-(self2:GetWide()/2), (panelTall/2)-(self2:GetTall()/2) )
	end
	parent.brs_popout.ClosePopout = function()
		if( IsValid( parent.brs_popout ) ) then
			parent.brs_popout:SizeTo( 0, 0, 0.2, 0, -1, function()
				if( IsValid( parent.brs_popout ) ) then
					parent.brs_popout:Remove()
				end
			end )
		end

		popoutClose:AlphaTo( 0, 0.2, 0, function()
			if( IsValid( popoutClose ) ) then
				popoutClose:Remove()
			end
		end )
	end

	popoutClose.DoClick = function()
		if( disableBackgroundButton ) then return end
		
		if( cancelFunc ) then
			cancelFunc()
		end

		parent.brs_popout.ClosePopout()
	end

	local buttonBack = vgui.Create( "DPanel", parent.brs_popout )
	buttonBack:Dock( BOTTOM )
	buttonBack:DockMargin( 10, 10, 10, 10 )
	buttonBack:SetTall( 40 )
	buttonBack.Paint = function() end

	local confirmButton = vgui.Create( "DButton", buttonBack )
	confirmButton:SetText( "" )
	confirmButton:Dock( LEFT )
	confirmButton:SetWide( (popoutWide-30)/2 )
	local changeAlpha = 0
	confirmButton.Paint = function( self2, w, h )
		if( self2:IsHovered() ) then
			changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
		else
			changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
		end
		
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )

		surface.SetAlphaMultiplier( changeAlpha/255 )
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )
		surface.SetAlphaMultiplier( 1 )

		draw.SimpleText( confirmText, "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	confirmButton.DoClick = function()
		if( confirmFunc ) then
			confirmFunc()
		end
		
		parent.brs_popout.ClosePopout()
	end

	local cancelButton = vgui.Create( "DButton", buttonBack )
	cancelButton:SetText( "" )
	cancelButton:Dock( RIGHT )
	cancelButton:SetWide( (popoutWide-30)/2 )
	local changeAlpha = 0
	cancelButton.Paint = function( self2, w, h )
		if( self2:IsHovered() ) then
			changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
		else
			changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
		end
		
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )

		surface.SetAlphaMultiplier( changeAlpha/255 )
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )
		surface.SetAlphaMultiplier( 1 )

		draw.SimpleText( cancelText, "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	cancelButton.DoClick = function()
		if( cancelFunc ) then
			cancelFunc()
		end

		parent.brs_popout.ClosePopout()
	end
end

function BRICKS_SERVER.Func.CreateTopNotification( text, time, accentColor )
	if( IsValid( BRS_TOPNOTIFICATION ) ) then
		BRS_TOPNOTIFICATION:Remove()
	end

	if( timer.Exists( "brs_topnotification_remove" ) ) then
		timer.Remove( "brs_topnotification_remove" )
	end

	surface.PlaySound( "ui/buttonclick.wav" )

	surface.SetFont( "BRICKS_SERVER_Font20" )
	local textX, textY = surface.GetTextSize( text )

	local popoutWide, popoutTall = math.max( ScrW()*0.15, textX+40 ), 40

	BRS_TOPNOTIFICATION = vgui.Create( "DPanel" )
	BRS_TOPNOTIFICATION:SetSize( 0, popoutTall )
	BRS_TOPNOTIFICATION:SizeTo( popoutWide, popoutTall, 0.2 )
	BRS_TOPNOTIFICATION.Paint = function( self2, w, h )
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

		BRICKS_SERVER.Func.DrawPartialRoundedBox( 5, 0, 0, 5, h, (accentColor or BRICKS_SERVER.Func.GetTheme( 5 )), 10, h )
		BRICKS_SERVER.Func.DrawPartialRoundedBox( 5, w-5, 0, 5, h, (accentColor or BRICKS_SERVER.Func.GetTheme( 5 )), 10, h, w-10 )

		draw.SimpleText( text, "BRICKS_SERVER_Font20", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	BRS_TOPNOTIFICATION.OnSizeChanged = function( self2 )
		self2:SetPos( (ScrW()/2)-(self2:GetWide()/2), 100 )
	end
	BRS_TOPNOTIFICATION.ClosePopout = function()
		if( IsValid( BRS_TOPNOTIFICATION ) ) then
			BRS_TOPNOTIFICATION:SizeTo( 0, popoutTall, 0.2, 0, -1, function()
				if( IsValid( BRS_TOPNOTIFICATION ) ) then
					BRS_TOPNOTIFICATION:Remove()
				end
			end )
		end
	end

	timer.Create( "brs_topnotification_remove", (time or 3), 1, function()
		if( IsValid( BRS_TOPNOTIFICATION ) ) then
			BRS_TOPNOTIFICATION.ClosePopout()
		end
	end )
end

function BRICKS_SERVER.Func.CreatePopoutPanel( parent, panelWide, panelTall, popoutWide, popoutTall )
	if( IsValid( parent.brs_popout ) ) then
		parent.brs_popout:Remove()
	end

	local popoutClose = vgui.Create( "DButton", parent )
	popoutClose:SetSize( panelWide, panelTall )
	popoutClose:SetAlpha( 0 )
	popoutClose:AlphaTo( 255, 0.2 )
	popoutClose:SetText( "" )
	popoutClose:SetCursor( "arrow" )
	popoutClose.Paint = function( self2, w, h )
		surface.SetDrawColor( 0, 0, 0, 150 )
		surface.DrawRect( 0, 0, w, h )
		BRICKS_SERVER.Func.DrawBlur( self2, 2, 2 )
	end

	parent.brs_popout = vgui.Create( "DPanel", parent )
	parent.brs_popout:SetSize( 0, 0 )
	parent.brs_popout:SizeTo( popoutWide, popoutTall, 0.2 )
	parent.brs_popout.SetColor = function( self2, color )
		self2.backColor = color
	end
	parent.brs_popout.Paint = function( self2, w, h )
		draw.RoundedBox( 5, 0, 0, w, h, (self2.backColor or BRICKS_SERVER.Func.GetTheme( 2 )) )
	end
	parent.brs_popout.OnSizeChanged = function( self2 )
		self2:SetPos( (panelWide/2)-(self2:GetWide()/2), (panelTall/2)-(self2:GetTall()/2) )
	end
	parent.brs_popout.ClosePopout = function()
		if( IsValid( parent.brs_popout ) ) then
			parent.brs_popout:SizeTo( 0, 0, 0.2, 0, -1, function()
				if( IsValid( parent.brs_popout ) ) then
					parent.brs_popout:Remove()
				end
			end )
		end

		popoutClose:AlphaTo( 0, 0.2, 0, function()
			if( IsValid( popoutClose ) ) then
				popoutClose:Remove()
			end
		end )
	end

	popoutClose.DoClick = function()
		parent.brs_popout.ClosePopout()
	end

	return parent.brs_popout
end

function BRICKS_SERVER.Func.CreatePopoutConfigPanel( parent, panelWide, panelTall, popoutWide, popoutTall, confirmFunc, cancelFunc )
	local popoutPanel = BRICKS_SERVER.Func.CreatePopoutPanel( parent, panelWide, panelTall, popoutWide, popoutTall )

	local buttonBack = vgui.Create( "DPanel", popoutPanel )
	buttonBack:Dock( BOTTOM )
	buttonBack:DockMargin( 10, 10, 10, 10 )
	buttonBack:SetTall( 40 )
	buttonBack.Paint = function() end

	local saveButton = vgui.Create( "DButton", buttonBack )
	saveButton:SetText( "" )
	saveButton:Dock( LEFT )
	saveButton:SetWide( (popoutWide-30)/2 )
	local changeAlpha = 0
	saveButton.Paint = function( self2, w, h )
		if( self2:IsHovered() ) then
			changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
		else
			changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
		end
		
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.Green )

		surface.SetAlphaMultiplier( changeAlpha/255 )
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkGreen )
		surface.SetAlphaMultiplier( 1 )

		draw.SimpleText( "Save", "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	saveButton.DoClick = function()
		if( confirmFunc ) then
			confirmFunc()
		end
		
		popoutPanel.ClosePopout()
	end

	local cancelButton = vgui.Create( "DButton", buttonBack )
	cancelButton:SetText( "" )
	cancelButton:Dock( RIGHT )
	cancelButton:SetWide( (popoutWide-30)/2 )
	local changeAlpha = 0
	cancelButton.Paint = function( self2, w, h )
		if( self2:IsHovered() ) then
			changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
		else
			changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
		end
		
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )

		surface.SetAlphaMultiplier( changeAlpha/255 )
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkRed )
		surface.SetAlphaMultiplier( 1 )

		draw.SimpleText( "Cancel", "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	cancelButton.DoClick = function()
		if( cancelFunc ) then
			cancelFunc()
		end

		popoutPanel.ClosePopout()
	end

	return popoutPanel
end