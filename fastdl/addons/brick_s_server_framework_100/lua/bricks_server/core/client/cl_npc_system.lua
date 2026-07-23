function BRICKS_SERVER.Func.CreateNPCEditor( NPCKey, oldNPCTable, onSave, onCancel )
	BS_NPC_EDITOR = vgui.Create( "DFrame" )
	BS_NPC_EDITOR:SetSize( ScrW(), ScrH() )
	BS_NPC_EDITOR:Center()
	BS_NPC_EDITOR:SetTitle( "" )
	BS_NPC_EDITOR:ShowCloseButton( false )
	BS_NPC_EDITOR:SetDraggable( false )
	BS_NPC_EDITOR:MakePopup()
	BS_NPC_EDITOR:SetAlpha( 0 )
	BS_NPC_EDITOR:AlphaTo( 255, 0.1, 0 )
	BS_NPC_EDITOR.Paint = function( self2 ) 
		BRICKS_SERVER.Func.DrawBlur( self2, 4, 4 )
	end

	local backPanel = vgui.Create( "DPanel", BS_NPC_EDITOR )
	backPanel.Paint = function( self2, w, h ) 
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )
		draw.RoundedBox( 5, 1, 1, w-2, h-2, BRICKS_SERVER.Func.GetTheme( 2 ) )
	end

	local NPCTable = table.Copy( oldNPCTable )

	local textArea

	local actions = {
		[1] = { BRICKS_SERVER.Func.L( "name" ), Material( "materials/bricks_server/name.png" ), function()
			BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "newNameQuery" ), NPCTable.Name, function( text ) 
				NPCTable.Name = text
			end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), false )
		end, "Name" },
		[2] = { BRICKS_SERVER.Func.L( "model" ), Material( "materials/bricks_server/icon.png" ), function()
			BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "newModelQuery" ), (NPCTable.Model or ""), function( text ) 
				if( text == "" ) then
					NPCTable.Model = nil
				else
					NPCTable.Model = text
				end
			end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), false )
		end, "Model" },
		[3] = { BRICKS_SERVER.Func.L( "type" ), Material( "materials/bricks_server/amount.png" ), function()
			local options = {}
			for k, v in pairs( BRICKS_SERVER.DEVCONFIG.NPCTypes ) do
				options[k] = k
			end
			BRICKS_SERVER.Func.ComboRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "npcTypeQuery" ), (NPCTable.Type or ""), options, function( value, data ) 
				if( BRICKS_SERVER.DEVCONFIG.NPCTypes[data] ) then
					NPCTable.Type = data
					backPanel.FillActions()
					backPanel.FillOptions()
				else
					notification.AddLegacy( BRICKS_SERVER.Func.L( "invalidType" ), 1, 3 )
				end
			end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ) )
		end, "Type" }
	}

	local originalActionsLen = #actions
	function backPanel.FillActions()
		for k, v in pairs( actions ) do
			if( k > originalActionsLen ) then
				actions[k] = nil
			end
		end

		if( BRICKS_SERVER.DEVCONFIG.NPCTypes[(NPCTable.Type or "")] and BRICKS_SERVER.DEVCONFIG.NPCTypes[(NPCTable.Type or "")].ReqInfo ) then
			for k, v in pairs( BRICKS_SERVER.DEVCONFIG.NPCTypes[(NPCTable.Type or "")].ReqInfo ) do
				local actionTable = {}
				if( v[2] == "string" ) then
					actionTable = { v[1], Material( "materials/bricks_server/more_24.png" ), function()
						BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "valueQuery", v[1] ), (NPCTable.ReqInfo or {})[k] or "", function( text ) 
							NPCTable.ReqInfo = NPCTable.ReqInfo or {}
							NPCTable.ReqInfo[k] = text
						end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), false )
					end }
				elseif( v[2] == "integer" ) then
					actionTable = { v[1], Material( "materials/bricks_server/more_24.png" ), function()
						BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "valueQuery", v[1] ), (NPCTable.ReqInfo or {})[k] or 0, function( number ) 
							NPCTable.ReqInfo = NPCTable.ReqInfo or {}
							NPCTable.ReqInfo[k] = number
						end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), true )
					end }
				elseif( v[2] == "table" ) then
					actionTable = { v[1], Material( "materials/bricks_server/more_24.png" ), function()
						local options = BRICKS_SERVER.Func.GetList( v[3] ) or {}
						BRICKS_SERVER.Func.ComboRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "valueQuery", v[1] ), (NPCTable.ReqInfo or {})[k] or "", options, function( value, data ) 
							if( options[data] ) then
								NPCTable.ReqInfo = NPCTable.ReqInfo or {}
								NPCTable.ReqInfo[k] = data
							else
								notification.AddLegacy( BRICKS_SERVER.Func.L( "invalidOption" ), 1, 3 )
							end
						end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ) )
					end }
				end

				table.insert( actions, actionTable )
			end
		end
	end
	backPanel.FillActions()
	
	function backPanel.FillOptions()
		backPanel:Clear()

		textArea = vgui.Create( "DPanel", backPanel )
		textArea:Dock( TOP )
		textArea:DockMargin( 10, 10, 10, 0 )
		textArea:SetTall( 30 )
		textArea.Paint = function( self2, w, h ) 
			draw.SimpleText( BRICKS_SERVER.Func.L( "npcEditor" ), "BRICKS_SERVER_Font20", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
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

				if( v[4] and NPCTable[v[4]] and not v[5] ) then
					draw.SimpleText( v[1] .. " - " .. string.sub( NPCTable[v[4]], 1, 20 ), "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
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

			draw.SimpleText( BRICKS_SERVER.Func.L( "save" ), "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		leftButton.DoClick = function()
			onSave( NPCTable )

			BS_NPC_EDITOR:AlphaTo( 0, 0.1, 0, function()
				if( IsValid( BS_NPC_EDITOR ) ) then
					BS_NPC_EDITOR:Remove()
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

			BS_NPC_EDITOR:AlphaTo( 0, 0.1, 0, function()
				if( IsValid( BS_NPC_EDITOR ) ) then
					BS_NPC_EDITOR:Remove()
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