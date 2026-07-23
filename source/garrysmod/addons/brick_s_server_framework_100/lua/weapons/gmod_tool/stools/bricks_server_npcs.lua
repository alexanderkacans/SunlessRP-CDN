TOOL.Category = "Bricks Server"
TOOL.Name = "NPC Placer"
TOOL.Command = nil
TOOL.ConfigName = "" --Setting this means that you do not have to create external configuration files to define the layout of the tool config-hud 

function TOOL:LeftClick( trace )
	if( !trace.HitPos || IsValid( trace.Entity ) && trace.Entity:IsPlayer() ) then return false end
	if( CLIENT ) then return true end

	local ply = self:GetOwner()
	
	if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then
		BRICKS_SERVER.Func.SendNotification( ply, 1, 2, BRICKS_SERVER.Func.L( "noToolPermission" ) )
		return
	end

	if( BRICKS_SERVER.CONFIG.NPCS[ply:GetNW2Int( "bricks_server_tool_npctype" )] ) then
		local NPCEnt = ents.Create( "bricks_server_npc" )
		NPCEnt:SetPos( trace.HitPos )
		local EntAngles = NPCEnt:GetAngles()
		local PlayerAngle = ply:GetAngles()
		NPCEnt:SetAngles( Angle( EntAngles.p, PlayerAngle.y+180, EntAngles.r ) )
		NPCEnt:Spawn()
		NPCEnt:SetNPCKey( ply:GetNW2Int( "bricks_server_tool_npctype" ) )
		
		BRICKS_SERVER.Func.SendNotification( ply, 1, 2, BRICKS_SERVER.Func.L( "npcPlaced" ) )
		ply:ConCommand( "bricks_server_saveentpositions" )
	else
		BRICKS_SERVER.Func.SendNotification( ply, 1, 2, BRICKS_SERVER.Func.L( "invalidNPCType" ) )
	end
end
 
function TOOL:RightClick( trace )
	if( !trace.HitPos ) then return false end
	if( !IsValid( trace.Entity ) or trace.Entity:IsPlayer() ) then return false end
	if( CLIENT ) then return true end

	local ply = self:GetOwner()
	
	if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then
		BRICKS_SERVER.Func.SendNotification( ply, 1, 2, BRICKS_SERVER.Func.L( "noToolPermission" ) )
		return
	end
	
	if( trace.Entity:GetClass() == "bricks_server_npc" ) then
		trace.Entity:Remove()
		BRICKS_SERVER.Func.SendNotification( ply, 1, 2, BRICKS_SERVER.Func.L( "npcRemoved" ) )
		ply:ConCommand( "bricks_server_saveentpositions" )
	else
		BRICKS_SERVER.Func.SendNotification( ply, 1, 2, BRICKS_SERVER.Func.L( "errorNotNPC" ) )
		return false
	end
end

function TOOL:DrawToolScreen( width, height )
	if( not BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) ) then return end

	surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
	surface.DrawRect( 0, 0, width, height )

	surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 0 ) )
	surface.DrawRect( 0, 0, width, 60 )
	
	draw.SimpleText( language.GetPhrase( "tool.bricks_server_npcs.name" ), "BRICKS_SERVER_Font33", width/2, 30, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	local NPCSelected = BRICKS_SERVER.CONFIG.NPCS[LocalPlayer():GetNW2Int( "bricks_server_tool_npctype", 0 )]
	draw.SimpleText( BRICKS_SERVER.Func.L( "selected" ), "BRICKS_SERVER_Font33", width/2, 60+((height-60)/2)-15, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
	draw.SimpleText( ((NPCSelected and (NPCSelected.Name or BRICKS_SERVER.Func.L( "error" ))) or BRICKS_SERVER.Func.L( "none" )), "BRICKS_SERVER_Font25", width/2, 60+((height-60)/2)-15, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
end

function TOOL.BuildCPanel( panel )
	panel:AddControl("Header", { Text = BRICKS_SERVER.Func.L( "npcType" ), Description = BRICKS_SERVER.Func.L( "npcPlacerDescription" ) })
 
	local combo = panel:AddControl( "ComboBox", { Label = BRICKS_SERVER.Func.L( "npcType" ) } )
	for k, v in pairs( BRICKS_SERVER.CONFIG.NPCS or {} ) do
		combo:AddOption( v.Name, { k } )
	end
	function combo:OnSelect( index, text, data )
		net.Start( "BRS.Net.ToolNPCPlacer" )
			net.WriteUInt( data[1], 8 )
		net.SendToServer()
	end
end

if( CLIENT ) then
	language.Add( "tool.bricks_server_npcs.name", BRICKS_SERVER.Func.L( "npcPlacer" ) )
	language.Add( "tool.bricks_server_npcs.desc", BRICKS_SERVER.Func.L( "npcPlacerDescriptionSmall" ) )
	language.Add( "tool.bricks_server_npcs.0", BRICKS_SERVER.Func.L( "entityPlacerInstructions" ) )
elseif( SERVER ) then
	util.AddNetworkString( "BRS.Net.ToolNPCPlacer" )
	net.Receive( "BRS.Net.ToolNPCPlacer", function( len, ply )
		if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then return end

		ply:SetNW2Int( "bricks_server_tool_npctype", net.ReadUInt( 8 ) )
	end )
end