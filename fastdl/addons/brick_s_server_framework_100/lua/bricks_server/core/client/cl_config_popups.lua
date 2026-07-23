function BRICKS_SERVER.Func.CreateGroupEditor( defaultGroups, onSave, onCancel, swap )
	BS_GROUP_EDITOR = vgui.Create( "DFrame" )
	BS_GROUP_EDITOR:SetSize( ScrW(), ScrH() )
	BS_GROUP_EDITOR:Center()
	BS_GROUP_EDITOR:SetTitle( "" )
	BS_GROUP_EDITOR:ShowCloseButton( false )
	BS_GROUP_EDITOR:SetDraggable( false )
	BS_GROUP_EDITOR:MakePopup()
	BS_GROUP_EDITOR:SetAlpha( 0 )
	BS_GROUP_EDITOR:AlphaTo( 255, 0.1, 0 )
	BS_GROUP_EDITOR.Paint = function( self2 ) 
		BRICKS_SERVER.Func.DrawBlur( self2, 4, 4 )
	end

	local backPanel = vgui.Create( "DPanel", BS_GROUP_EDITOR )
	backPanel.Paint = function( self2, w, h ) 
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )
		draw.RoundedBox( 5, 1, 1, w-2, h-2, BRICKS_SERVER.Func.GetTheme( 2 ) )
	end

	local groupsTable = table.Copy( defaultGroups )
	local textArea

	function backPanel.FillGroups()
		backPanel:Clear()

		textArea = vgui.Create( "DPanel", backPanel )
		textArea:Dock( TOP )
		textArea:DockMargin( 10, 10, 10, 0 )
		textArea:SetTall( 30 )
		textArea.Paint = function( self2, w, h ) 
			draw.SimpleText( BRICKS_SERVER.Func.L( "userGroupEditor" ), "BRICKS_SERVER_Font20", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end

		for k, v in pairs( groupsTable ) do
			local actionButtonBack = vgui.Create( "DPanel", backPanel )
			actionButtonBack:Dock( TOP )
			actionButtonBack:DockMargin( 10, 10, 10, 0 )
			actionButtonBack:SetTall( 40 )
			actionButtonBack.Paint = function() end

			local actionButtonDelete = vgui.Create( "DButton", actionButtonBack )
			actionButtonDelete:SetText( "" )
			actionButtonDelete:Dock( RIGHT )
			actionButtonDelete:DockMargin( 5, 0, 0, 0 )
			actionButtonDelete:SetWide( actionButtonBack:GetTall() )
			local changeAlpha = 0
			local deleteMat = Material( "materials/bricks_server/delete.png" )
			actionButtonDelete.Paint = function( self2, w, h )
				if( self2:IsDown() ) then
					changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
				elseif( self2:IsHovered() ) then
					changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
				else
					changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
				end
				
				draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
		
				surface.SetAlphaMultiplier( changeAlpha/255 )
					draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkRed )
				surface.SetAlphaMultiplier( 1 )

				surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
				surface.SetMaterial( deleteMat )
				local iconSize = h*0.65
				surface.DrawTexturedRect( (h-iconSize)/2, (h/2)-(iconSize/2), iconSize, iconSize )
			end
			actionButtonDelete.DoClick = function()
				if( isnumber( k ) ) then
					table.remove( groupsTable, k )
				else
					groupsTable[k] = nil
				end

				backPanel.FillGroups()
			end

			local actionButton = vgui.Create( "DPanel", actionButtonBack )
			actionButton:Dock( FILL )
			actionButton.Paint = function( self2, w, h )
				draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

				draw.SimpleText( ((not swap and v) or k), "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			end
		end

		local newGroupButton = vgui.Create( "DButton", backPanel )
		newGroupButton:SetText( "" )
		newGroupButton:Dock( TOP )
		newGroupButton:DockMargin( 10, 10, 10, 0 )
		newGroupButton:SetTall( 40 )
		local changeAlpha = 0
		newGroupButton.Paint = function( self2, w, h )
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

			draw.SimpleText( BRICKS_SERVER.Func.L( "addNewGroup" ), "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		newGroupButton.DoClick = function()
			BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "newUserGroup" ), BRICKS_SERVER.Func.L( "groupName" ), function( text ) 
				if( not swap ) then
					table.insert( groupsTable, text )
				else
					groupsTable[text] = true
				end
				backPanel.FillGroups()
			end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), false )
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
	
			draw.SimpleText( BRICKS_SERVER.Func.L( "save" ), "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		leftButton.DoClick = function()
			onSave( groupsTable )
	
			BS_GROUP_EDITOR:AlphaTo( 0, 0.1, 0, function()
				if( IsValid( BS_GROUP_EDITOR ) ) then
					BS_GROUP_EDITOR:Remove()
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
	
			draw.SimpleText( BRICKS_SERVER.Func.L( "cancel" ), "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		rightButton.DoClick = function()
			onCancel()
	
			BS_GROUP_EDITOR:AlphaTo( 0, 0.1, 0, function()
				if( IsValid( BS_GROUP_EDITOR ) ) then
					BS_GROUP_EDITOR:Remove()
				end
			end )
		end
	
		backPanel:SetSize( (2*10)+(2*150)+80, buttonPanel:GetTall()+(5*10)+textArea:GetTall()+((table.Count( groupsTable ) or 10)*50)+newGroupButton:GetTall() )
		backPanel:Center()
	
		leftButton:SetWide( (backPanel:GetWide()-30)/2 )
		rightButton:SetWide( (backPanel:GetWide()-30)/2 )
	end
	backPanel.FillGroups()
end

function BRICKS_SERVER.Func.CreateTeamSelector( defaultTable, subtitle, saveFunc )
	local frameBack = vgui.Create( "DFrame" )
	frameBack:SetSize( ScrW(), ScrH() )
	frameBack:Center()
	frameBack:SetTitle( "" )
	frameBack:ShowCloseButton( false )
	frameBack:SetDraggable( false )
	frameBack:MakePopup()
	frameBack:SetAlpha( 0 )
	frameBack:AlphaTo( 255, 0.1, 0 )
	frameBack.Paint = function( self2 ) 
		BRICKS_SERVER.Func.DrawBlur( self2, 4, 4 )
	end

	local teamsTableCopy = table.Copy( defaultTable )

	local backPanel = vgui.Create( "DPanel", frameBack )
	backPanel:SetSize( ScrW()*0.4, 0 )
	backPanel.Paint = function( self2, w, h ) 
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )
		draw.RoundedBox( 5, 1, 1, w-2, h-2, BRICKS_SERVER.Func.GetTheme( 2 ) )
	end

	local textArea = vgui.Create( "DPanel", backPanel )
	textArea:Dock( TOP )
	textArea:DockMargin( 10, 10, 10, 0 )
	textArea:SetTall( 30 )
	textArea.Paint = function( self2, w, h ) 
		draw.SimpleText( subtitle, "BRICKS_SERVER_Font20", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

	local chooserBack = vgui.Create( "bricks_server_scrollpanel", backPanel )
	chooserBack:Dock( TOP )
	chooserBack:DockMargin( 10, 10, 10, 0 )
	chooserBack:SetTall( ScrH()*0.4 )
	chooserBack.Paint = function() end
	
	local spacing = 5
	local gridWide = backPanel:GetWide()-20
    local wantedSlotSize = 135
    local slotsWide = math.floor( gridWide/wantedSlotSize )
	local slotSize = (gridWide-((slotsWide-1)*spacing))/slotsWide

	local chooserLayout = vgui.Create( "DIconLayout", chooserBack )
    chooserLayout:Dock( FILL )
    chooserLayout:SetSpaceY( spacing )
	chooserLayout:SetSpaceX( spacing )
	
	function backPanel.RefreshTeams()
		chooserLayout:Clear()
		
		for k, v in pairs( RPExtraTeams ) do
			local materialEntry = chooserLayout:Add( "DButton" )
			materialEntry:SetSize( slotSize, slotSize )
			materialEntry:SetText( "" )
			local changeAlpha = 0
			local name = util.CRC( k )
			local icon
			materialEntry.Paint = function( self2, w, h )
				if( teamsTableCopy[v.command] ) then
					draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 4 ) )
				else
					draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
				end

				if( icon:IsDown() ) then
					changeAlpha = math.Clamp( changeAlpha+10, 0, 150 )
				elseif( icon:IsHovered() ) then
					changeAlpha = math.Clamp( changeAlpha+10, 0, 95 )
				else
					changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
				end

				surface.SetAlphaMultiplier( changeAlpha/255 )
				draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
				surface.SetAlphaMultiplier( 1 )

				if( string.len( v.name ) > 16 ) then
					draw.SimpleText( string.sub( v.name, 1, 16 ) .. "...", "BRICKS_SERVER_Font20", w/2, h-5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
				else
					draw.SimpleText( v.name, "BRICKS_SERVER_Font20", w/2, h-5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
				end
			end

			icon = vgui.Create( "DModelPanel", materialEntry )
			icon:Dock( FILL )
			icon:DockMargin( 0, 0, 0, 30 )
			if( istable( v.model ) ) then
				icon:SetModel( v.model[1] )
			else
				icon:SetModel( v.model )
			end
			function icon:LayoutEntity( Entity ) return end

			icon.DoClick = function()
				if( teamsTableCopy[v.command] ) then
					teamsTableCopy[v.command] = nil
				else
					teamsTableCopy[v.command] = true
				end
			end
		end

		chooserLayout:PerformLayout()
		chooserBack:Rebuild()
	end
	backPanel.RefreshTeams()

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
	local textX, textY = surface.GetTextSize( BRICKS_SERVER.Func.L( "confirm" ) )
	textX = textX+20
	leftButton:SetWide( math.max( (ScrW()/2560)*150, textX ) )
	local changeAlpha = 0
	leftButton.Paint = function( self2, w, h )
		if( self2:IsHovered() ) then
			changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
		else
			changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
		end
		
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

		surface.SetAlphaMultiplier( changeAlpha/255 )
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 4 ) )
		surface.SetAlphaMultiplier( 1 )

		draw.SimpleText( BRICKS_SERVER.Func.L( "confirm" ), "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	leftButton.DoClick = function()
		saveFunc( teamsTableCopy )
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
	surface.SetFont( "BRICKS_SERVER_Font25" )
	local textX, textY = surface.GetTextSize( BRICKS_SERVER.Func.L( "cancel" ) )
	textX = textX+20
	rightButton:SetWide( math.max( (ScrW()/2560)*150, textX ) )
	local changeAlpha = 0
	rightButton.Paint = function( self2, w, h )
		if( self2:IsHovered() ) then
			changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
		else
			changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
		end
		
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

		surface.SetAlphaMultiplier( changeAlpha/255 )
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 4 ) )
		surface.SetAlphaMultiplier( 1 )

		draw.SimpleText( BRICKS_SERVER.Func.L( "cancel" ), "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	rightButton.DoClick = function()
		frameBack:AlphaTo( 0, 0.1, 0, function()
			if( IsValid( frameBack ) ) then
				frameBack:Remove()
			end
		end )
	end

	backPanel:SetSize( backPanel:GetWide(), buttonPanel:GetTall()+(4*10)+textArea:GetTall()+chooserBack:GetTall()+10 )
	backPanel:Center()
end

function BRICKS_SERVER.Func.CreateShipmentSelector( defaultTable, subtitle, saveFunc )
	local frameBack = vgui.Create( "DFrame" )
	frameBack:SetSize( ScrW(), ScrH() )
	frameBack:Center()
	frameBack:SetTitle( "" )
	frameBack:ShowCloseButton( false )
	frameBack:SetDraggable( false )
	frameBack:MakePopup()
	frameBack:SetAlpha( 0 )
	frameBack:AlphaTo( 255, 0.1, 0 )
	frameBack.Paint = function( self2 ) 
		BRICKS_SERVER.Func.DrawBlur( self2, 4, 4 )
	end

	local shipmentsTableCopy = table.Copy( defaultTable )

	for k, v in pairs( shipmentsTableCopy ) do
		local found, foundKey = DarkRP.getShipmentByName( k )

		if( not found ) then
			shipmentsTableCopy[k] = nil
		end
	end

	local backPanel = vgui.Create( "DPanel", frameBack )
	backPanel:SetSize( ScrW()*0.4, 0 )
	backPanel.Paint = function( self2, w, h ) 
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )
		draw.RoundedBox( 5, 1, 1, w-2, h-2, BRICKS_SERVER.Func.GetTheme( 2 ) )
	end

	local textArea = vgui.Create( "DPanel", backPanel )
	textArea:Dock( TOP )
	textArea:DockMargin( 10, 10, 10, 0 )
	textArea:SetTall( 30 )
	textArea.Paint = function( self2, w, h ) 
		draw.SimpleText( subtitle, "BRICKS_SERVER_Font20", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

	local chooserBack = vgui.Create( "bricks_server_scrollpanel", backPanel )
	chooserBack:Dock( TOP )
	chooserBack:DockMargin( 10, 10, 10, 0 )
	chooserBack:SetTall( ScrH()*0.4 )
	chooserBack.Paint = function() end
	
	local spacing = 5
	local gridWide = backPanel:GetWide()-20
    local wantedSlotSize = 135
    local slotsWide = math.floor( gridWide/wantedSlotSize )
	local slotSize = (gridWide-((slotsWide-1)*spacing))/slotsWide

	local chooserLayout = vgui.Create( "DIconLayout", chooserBack )
    chooserLayout:Dock( FILL )
    chooserLayout:SetSpaceY( spacing )
	chooserLayout:SetSpaceX( spacing )
	
	function backPanel.RefreshTeams()
		chooserLayout:Clear()
		
		for k, v in pairs( CustomShipments ) do
			local materialEntry = chooserLayout:Add( "DButton" )
			materialEntry:SetSize( slotSize, slotSize )
			materialEntry:SetText( "" )
			local changeAlpha = 0
			local name = util.CRC( k )
			local icon
			materialEntry.Paint = function( self2, w, h )
				if( shipmentsTableCopy[v.name] ) then
					draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 4 ) )
				else
					draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
				end

				if( icon:IsDown() ) then
					changeAlpha = math.Clamp( changeAlpha+10, 0, 150 )
				elseif( icon:IsHovered() ) then
					changeAlpha = math.Clamp( changeAlpha+10, 0, 95 )
				else
					changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
				end

				surface.SetAlphaMultiplier( changeAlpha/255 )
				draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
				surface.SetAlphaMultiplier( 1 )

				if( string.len( v.name ) > 16 ) then
					draw.SimpleText( string.sub( v.name, 1, 16 ) .. "...", "BRICKS_SERVER_Font20", w/2, h-5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
				else
					draw.SimpleText( v.name, "BRICKS_SERVER_Font20", w/2, h-5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
				end
			end

			icon = vgui.Create( "DModelPanel", materialEntry )
			icon:Dock( FILL )
			icon:SetModel( v.model )
			if( IsValid( icon.Entity ) ) then
				function icon:LayoutEntity( Entity ) return end
				local mn, mx = icon.Entity:GetRenderBounds()
				local size = 0
				size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
				size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
				size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )
		
				icon:SetFOV( 70 )
				icon:SetCamPos( Vector( size, size, size ) )
				icon:SetLookAt( (mn + mx) * 0.5 )
			end

			icon.DoClick = function()
				if( shipmentsTableCopy[v.name] ) then
					shipmentsTableCopy[v.name] = nil
				else
					shipmentsTableCopy[v.name] = true
				end
			end
		end

		chooserLayout:PerformLayout()
		chooserBack:Rebuild()
	end
	backPanel.RefreshTeams()

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
	local textX, textY = surface.GetTextSize( BRICKS_SERVER.Func.L( "confirm" ) )
	textX = textX+20
	leftButton:SetWide( math.max( (ScrW()/2560)*150, textX ) )
	local changeAlpha = 0
	leftButton.Paint = function( self2, w, h )
		if( self2:IsHovered() ) then
			changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
		else
			changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
		end
		
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

		surface.SetAlphaMultiplier( changeAlpha/255 )
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 4 ) )
		surface.SetAlphaMultiplier( 1 )

		draw.SimpleText( BRICKS_SERVER.Func.L( "confirm" ), "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	leftButton.DoClick = function()
		saveFunc( shipmentsTableCopy )
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
	surface.SetFont( "BRICKS_SERVER_Font25" )
	local textX, textY = surface.GetTextSize( BRICKS_SERVER.Func.L( "cancel" ) )
	textX = textX+20
	rightButton:SetWide( math.max( (ScrW()/2560)*150, textX ) )
	local changeAlpha = 0
	rightButton.Paint = function( self2, w, h )
		if( self2:IsHovered() ) then
			changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
		else
			changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
		end
		
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

		surface.SetAlphaMultiplier( changeAlpha/255 )
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 4 ) )
		surface.SetAlphaMultiplier( 1 )

		draw.SimpleText( BRICKS_SERVER.Func.L( "cancel" ), "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	rightButton.DoClick = function()
		frameBack:AlphaTo( 0, 0.1, 0, function()
			if( IsValid( frameBack ) ) then
				frameBack:Remove()
			end
		end )
	end

	backPanel:SetSize( backPanel:GetWide(), buttonPanel:GetTall()+(4*10)+textArea:GetTall()+chooserBack:GetTall()+10 )
	backPanel:Center()
end

function BRICKS_SERVER.Func.MaterialRequest( title, subtitle, default, func_confirm, func_cancel, confirmText, cancelText )
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
	backPanel:SetWide( math.max( ScrW()*0.4, textX+30 ) )
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

	local chooserBack = vgui.Create( "DPanel", backPanel )
	chooserBack:Dock( TOP )
	chooserBack:DockMargin( 10, 10, 10, 0 )
	chooserBack:SetTall( ScrH()*0.4 )
	chooserBack.Paint = function() end

	local materialsScroll = vgui.Create( "bricks_server_scrollpanel", chooserBack )
	materialsScroll:Dock( FILL )
	materialsScroll.Paint = function( self2, w, h ) end
	
	local spacing = 5
	local gridWide = backPanel:GetWide()-20
    local wantedSlotSize = 100
    local slotsWide = math.floor( gridWide/wantedSlotSize )
	local slotSize = (gridWide-((slotsWide-1)*spacing))/slotsWide

	local materialsGridCustom = vgui.Create( "DIconLayout", materialsScroll )
    materialsGridCustom:Dock( TOP )
    materialsGridCustom:DockMargin( 0, 0, 0, 0 )
    materialsGridCustom:SetSpaceY( spacing )
	materialsGridCustom:SetSpaceX( spacing )
	
	local materialsGridDefault = vgui.Create( "DIconLayout", materialsScroll )
    materialsGridDefault:Dock( TOP )
    materialsGridDefault:SetSpaceY( spacing )
	materialsGridDefault:SetSpaceX( spacing )
	
	local selected = default
	function backPanel.RefreshMaterials( time )
		local defaultMaterials = {}
		local customMaterials = {}

		materialsGridCustom:Clear()
		materialsGridDefault:Clear()

		for k, v in pairs( BRICKS_SERVER.CachedMaterials ) do
			if( string.StartWith( k, "http" ) ) then
				table.insert( customMaterials, { v, k } )
			else
				table.insert( defaultMaterials, { v, k } )
			end
		end

		table.SortByMember( defaultMaterials, 2, true )

		local materialCustomHeader = materialsGridCustom:Add( "DPanel" )
		materialCustomHeader:SetSize( gridWide-20, 40 )
		materialCustomHeader.Paint = function( self2, w, h )
			draw.SimpleText( BRICKS_SERVER.Func.L( "custom" ), "BRICKS_SERVER_Font25", 0, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
		end

		for k, v in pairs( customMaterials ) do
			local materialEntry = materialsGridCustom:Add( "DButton" )
			materialEntry:SetSize( slotSize, slotSize )
			materialEntry:SetText( "" )
			local changeAlpha = 0
			local name = util.CRC( v[2] )
			materialEntry.Paint = function( self2, w, h )
				if( selected == v[2] ) then
					draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 4 ) )
				else
					draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
				end

				if( self2:IsDown() ) then
					changeAlpha = math.Clamp( changeAlpha+10, 0, 150 )
				elseif( self2:IsHovered() ) then
					changeAlpha = math.Clamp( changeAlpha+10, 0, 95 )
				else
					changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
				end

				surface.SetAlphaMultiplier( changeAlpha/255 )
				draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
				surface.SetAlphaMultiplier( 1 )

				if( BRICKS_SERVER.CachedMaterials[v[2]] ) then
					surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
					surface.SetMaterial( BRICKS_SERVER.CachedMaterials[v[2]] )
					local iconSize = h*0.5
					surface.DrawTexturedRect( (h-iconSize)/2, (h/2)-(iconSize/2), iconSize, iconSize )
				end

				draw.SimpleText( name, "BRICKS_SERVER_Font17", w/2, h-5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
			end
			materialEntry.DoClick = function()
				selected = v[2]
			end
		end

		local customMaterialNew = materialsGridCustom:Add( "DButton" )
		customMaterialNew:SetSize( slotSize, slotSize )
		customMaterialNew:SetText( "" )
		local changeAlpha = 0
		local newMat = Material( "materials/bricks_server/add.png")
		customMaterialNew.Paint = function( self2, w, h )
			draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

			if( self2:IsDown() ) then
				changeAlpha = math.Clamp( changeAlpha+10, 0, 150 )
			elseif( self2:IsHovered() ) then
				changeAlpha = math.Clamp( changeAlpha+10, 0, 95 )
			else
				changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
			end

			surface.SetAlphaMultiplier( changeAlpha/255 )
			draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
			surface.SetAlphaMultiplier( 1 )

			if( newMat ) then
				surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
				surface.SetMaterial( newMat )
				local iconSize = 32
				surface.DrawTexturedRect( (h-iconSize)/2, (h/2)-(iconSize/2), iconSize, iconSize )
			end

			draw.SimpleText( BRICKS_SERVER.Func.L( "addNew" ), "BRICKS_SERVER_Font17", w/2, h-5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
		end
		customMaterialNew.DoClick = function()
			BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "material" ), BRICKS_SERVER.Func.L( "directImage" ), "https://i.imgur.com/XBwi3Nh.png", function( text ) 
				selected = text
				BRICKS_SERVER.Func.CacheImageFromURL( text, function() backPanel.RefreshMaterials() end )
			end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), false )
		end

		local materialDefaultHeader = materialsGridDefault:Add( "DPanel" )
		materialDefaultHeader:SetSize( gridWide-20, 40 )
		materialDefaultHeader.Paint = function( self2, w, h )
			draw.SimpleText( BRICKS_SERVER.Func.L( "default" ), "BRICKS_SERVER_Font25", 0, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
		end

		for k, v in pairs( defaultMaterials ) do
			local materialEntry = materialsGridDefault:Add( "DButton" )
			materialEntry:SetSize( slotSize, slotSize )
			materialEntry:SetText( "" )
			local changeAlpha = 0
			materialEntry.Paint = function( self2, w, h )
				if( selected == v[2] ) then
					draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 4 ) )
				else
					draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
				end
				if( self2:IsDown() ) then
					changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
				elseif( self2:IsHovered() ) then
					changeAlpha = math.Clamp( changeAlpha+10, 0, 95 )
				else
					changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
				end

				surface.SetAlphaMultiplier( changeAlpha/255 )
				draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
				surface.SetAlphaMultiplier( 1 )

				if( BRICKS_SERVER.CachedMaterials[v[2]] ) then
					surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
					surface.SetMaterial( BRICKS_SERVER.CachedMaterials[v[2]] )
					local iconSize = h*0.5
					surface.DrawTexturedRect( (h-iconSize)/2, (h/2)-(iconSize/2), iconSize, iconSize )
				end

				draw.SimpleText( string.Replace( v[2], ".png", "" ), "BRICKS_SERVER_Font17", w/2, h-5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
			end
			materialEntry.DoClick = function()
				selected = v[2]
			end
		end

		materialsGridCustom:SetTall( (math.ceil((#customMaterials+1)/slotsWide)*slotSize)+((math.ceil((#customMaterials+1)/slotsWide)-1)*spacing)+45 )
		materialsGridDefault:SetTall( (math.ceil(#defaultMaterials/slotsWide)*slotSize)+((math.ceil(#defaultMaterials/slotsWide)-1)*spacing)+45 )

		materialsGridCustom:PerformLayout()
		materialsGridDefault:PerformLayout()
		materialsScroll:Rebuild()
	end
	backPanel.RefreshMaterials()

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
		if( BRICKS_SERVER.CachedMaterials[selected] ) then
			func_confirm( selected )
			frameBack:AlphaTo( 0, 0.1, 0, function()
				if( IsValid( frameBack ) ) then
					frameBack:Remove()
				end
			end )
		else
			notification.AddLegacy( BRICKS_SERVER.Func.L( "selectMaterial" ), 1, 3 )
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
		func_cancel( selected )
		frameBack:AlphaTo( 0, 0.1, 0, function()
			if( IsValid( frameBack ) ) then
				frameBack:Remove()
			end
		end )
	end

	backPanel:SetTall( buttonPanel:GetTall()+(4*10)+textArea:GetTall()+chooserBack:GetTall()+10+backPanel.headerHeight )
	backPanel:Center()
end