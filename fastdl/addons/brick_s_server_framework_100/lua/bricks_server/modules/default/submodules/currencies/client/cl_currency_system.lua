BRICKS_SERVER.Func.AddConfigPage( "Currencies", "bricks_server_config_currencies" )
BRICKS_SERVER.Func.AddAdminPlayerFunc( "Currency", "Set", function( ply ) 
	local options = {}
	for k, v in pairs( (BRICKS_SERVER.CONFIG.CURRENCIES or {}) ) do
		options[k] = v.Name
	end
	BRICKS_SERVER.Func.ComboRequest( "Admin", "What currency would you like to set?", 1, options, function( value, data ) 
		if( BRICKS_SERVER.CONFIG.CURRENCIES[data] ) then
			BRICKS_SERVER.Func.StringRequest( "Admin", "How much would you like their currency to?", 0, function( text ) 
				if( isnumber( tonumber( text ) ) ) then
					RunConsoleCommand( "setcurrency", ply:SteamID64(), data, text )
				else
					notification.AddLegacy( "Invalid number.", 1, 3 )
				end
			end, function() end, "OK", "Cancel", true )
		else
			notification.AddLegacy( "Invalid currency.", 1, 3 )
		end
	end, function() end, "OK", "Cancel" )
end )
BRICKS_SERVER.Func.AddAdminPlayerFunc( "Currency", "Add", function( ply ) 
	local options = {}
	for k, v in pairs( (BRICKS_SERVER.CONFIG.CURRENCIES or {}) ) do
		options[k] = v.Name
	end
	BRICKS_SERVER.Func.ComboRequest( "Admin", "What currency would you like to add?", 1, options, function( value, data ) 
		if( BRICKS_SERVER.CONFIG.CURRENCIES[data] ) then
			BRICKS_SERVER.Func.StringRequest( "Admin", "How much would you like to add?", 0, function( text ) 
				if( isnumber( tonumber( text ) ) ) then
					RunConsoleCommand( "addcurrency", ply:SteamID64(), data, text )
				else
					notification.AddLegacy( "Invalid number.", 1, 3 )
				end
			end, function() end, "OK", "Cancel", true )
		else
			notification.AddLegacy( "Invalid currency.", 1, 3 )
		end
	end, function() end, "OK", "Cancel" )
end )

BRS_CURRENCIES = BRS_CURRENCIES or {}
net.Receive( "BRS.Net.SetCurrencies", function()
	local currenciesTable = net.ReadTable()

	BRS_CURRENCIES = currenciesTable or {}

	if( IsValid( BRICKS_SERVER_F4 ) and BRICKS_SERVER_F4:IsVisible() and BRICKS_SERVER_F4.FillProfile ) then
		BRICKS_SERVER_F4.FillProfile()
	end
end )

function BRICKS_SERVER.Func.CreateCurrencyEditor( currencyKey, oldCurrencyTable, onSave, onCancel )
	BS_CURRENCY_EDITOR = vgui.Create( "DFrame" )
	BS_CURRENCY_EDITOR:SetSize( ScrW(), ScrH() )
	BS_CURRENCY_EDITOR:Center()
	BS_CURRENCY_EDITOR:SetTitle( "" )
	BS_CURRENCY_EDITOR:ShowCloseButton( false )
	BS_CURRENCY_EDITOR:SetDraggable( false )
	BS_CURRENCY_EDITOR:MakePopup()
	BS_CURRENCY_EDITOR:SetAlpha( 0 )
	BS_CURRENCY_EDITOR:AlphaTo( 255, 0.1, 0 )
	BS_CURRENCY_EDITOR.Paint = function( self2 ) 
		BRICKS_SERVER.Func.DrawBlur( self2, 4, 4 )
	end

	local backPanel = vgui.Create( "DPanel", BS_CURRENCY_EDITOR )
	backPanel.Paint = function( self2, w, h ) 
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )
		draw.RoundedBox( 5, 1, 1, w-2, h-2, BRICKS_SERVER.Func.GetTheme( 2 ) )
	end

	local currencyTable = table.Copy( oldCurrencyTable )

	local textArea

	local actions = {
		[1] = { "Name", Material( "materials/bricks_server/name.png" ), function()
			BRICKS_SERVER.Func.StringRequest( "Admin", "What should the new name be?", currencyTable.Name, function( text ) 
				currencyTable.Name = text
			end, function() end, "OK", "Cancel", false )
		end, "Name" },
		[2] = { "Prefix", Material( "materials/bricks_server/currency.png" ), function()
			BRICKS_SERVER.Func.StringRequest( "Admin", "What should the prefix be?", currencyTable.Prefix or "", function( text ) 
				if( currencyTable.Prefix and text == "" ) then
					currencyTable.Prefix = nil
					return
				end

				currencyTable.Prefix = text
			end, function() end, "OK", "Cancel", false )
		end, "Prefix" },
		[3] = { "Suffix", Material( "materials/bricks_server/currency.png" ), function()
			BRICKS_SERVER.Func.StringRequest( "Admin", "What should the suffix be?", currencyTable.Suffix or "", function( text ) 
				if( currencyTable.Suffix and text == "" ) then
					currencyTable.Suffix = nil
					return
				end

				currencyTable.Suffix = text
			end, function() end, "OK", "Cancel", false )
		end, "Suffix" }
	}

	function backPanel.FillOptions()
		backPanel:Clear()

		textArea = vgui.Create( "DPanel", backPanel )
		textArea:Dock( TOP )
		textArea:DockMargin( 10, 10, 10, 0 )
		textArea:SetTall( 30 )
		textArea.Paint = function( self2, w, h ) 
			draw.SimpleText( "Currency Editor", "BRICKS_SERVER_Font20", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end

		for k, v in ipairs( actions ) do
			local actionButton = vgui.Create( "DButton", backPanel )
			actionButton:SetText( "" )
			actionButton:Dock( TOP )
			actionButton:DockMargin( 10, 10, 10, 0 )
			actionButton:SetTall( 40 )
			local changeAlpha = 0
			actionButton.Paint = function( self2, w, h )
				if( self2:IsDown() ) then
					changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
				elseif( self2:IsHovered() ) then
					changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
				else
					changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
				end
				
				draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
		
				surface.SetAlphaMultiplier( changeAlpha/255 )
					draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )
				surface.SetAlphaMultiplier( 1 )

				if( v[2] ) then
					surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
					surface.SetMaterial( v[2] )
					local iconSize = 24
					surface.DrawTexturedRect( (h-iconSize)/2, (h/2)-(iconSize/2), iconSize, iconSize )
				end

				if( v[4] and currencyTable[v[4]] and not v[5] ) then
					draw.SimpleText( v[1] .. " - " .. string.sub( currencyTable[v[4]], 1, 20 ), "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				elseif( v[5] and isfunction( v[5] ) ) then
					draw.SimpleText( v[1] .. " - " .. v[5](), "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				else
					draw.SimpleText( v[1], "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				end
			end
			actionButton.DoClick = function()
				if( v[3] ) then
					v[3]()
				end
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
		local changeAlpha = 0
		leftButton.Paint = function( self2, w, h )
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
		leftButton.DoClick = function()
			onSave( currencyTable )

			BS_CURRENCY_EDITOR:AlphaTo( 0, 0.1, 0, function()
				if( IsValid( BS_CURRENCY_EDITOR ) ) then
					BS_CURRENCY_EDITOR:Remove()
				end
			end )
		end

		local rightButton = vgui.Create( "DButton", buttonPanel )
		rightButton:Dock( RIGHT )
		rightButton:SetText( "" )
		rightButton:DockMargin( 0, 0, 0, 0 )
		local changeAlpha = 0
		rightButton.Paint = function( self2, w, h )
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
		rightButton.DoClick = function()
			onCancel()

			BS_CURRENCY_EDITOR:AlphaTo( 0, 0.1, 0, function()
				if( IsValid( BS_CURRENCY_EDITOR ) ) then
					BS_CURRENCY_EDITOR:Remove()
				end
			end )
		end

		backPanel:SetSize( (2*10)+(2*150)+80, buttonPanel:GetTall()+(4*10)+textArea:GetTall()+(#actions*50) )
		backPanel:Center()

		leftButton:SetWide( (backPanel:GetWide()-30)/2 )
		rightButton:SetWide( (backPanel:GetWide()-30)/2 )
	end
	backPanel.FillOptions()
end

hook.Add( "BRS.Hooks.ConfigReceived", "BRS.Hooks.ConfigReceived.Currencies", function( configUnCompressed )
    if( configUnCompressed.CURRENCIES and BRICKS_SERVER.LoadCurrencies ) then
        BRICKS_SERVER.LoadCurrencies()
    end
end )