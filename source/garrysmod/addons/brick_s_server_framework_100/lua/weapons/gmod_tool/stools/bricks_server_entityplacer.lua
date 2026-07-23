TOOL.Category = "Bricks Server"
TOOL.Name = "Entity Placer"
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
	
	local entClassTable = BRICKS_SERVER.DEVCONFIG.EntityTypes[ply:GetNW2String( "bricks_server_stoolcmd_entityclass" )]
	if( entClassTable ) then
		local entity = ents.Create( ply:GetNW2String( "bricks_server_stoolcmd_entityclass" ) )
		if( !IsValid( entity ) ) then
			BRICKS_SERVER.Func.SendNotification( ply, 1, 2, BRICKS_SERVER.Func.L( "invalidEntityType" ) )
			return
		end
		entity:SetPos( trace.HitPos )
		if( entClassTable.AngleToSurface == true ) then
			entity:SetAngles( trace.HitNormal:Angle() )
		elseif( entClassTable.AngleToPlayer == true ) then
			entity:SetAngles( Angle( entity:GetAngles().p, ply:GetAngles().y+180, entity:GetAngles().r ) )
		end
		entity:Spawn()
		
		BRICKS_SERVER.Func.SendNotification( ply, 1, 2, BRICKS_SERVER.Func.L( "entityPlaced" ) )
		ply:ConCommand( "bricks_server_saveentpositions" )
	else
		BRICKS_SERVER.Func.SendNotification( ply, 1, 2, BRICKS_SERVER.Func.L( "invalidEntityType" ) )
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
	
	if( BRICKS_SERVER.DEVCONFIG.EntityTypes[trace.Entity:GetClass()] ) then
		trace.Entity:Remove()
		BRICKS_SERVER.Func.SendNotification( ply, 1, 2, BRICKS_SERVER.Func.L( "entityRemoved" ) )
		ply:ConCommand( "bricks_server_saveentpositions" )
	else
		BRICKS_SERVER.Func.SendNotification( ply, 1, 2, BRICKS_SERVER.Func.L( "canOnlyUseToolEntity" ) )
		return false
	end
end

function TOOL:DrawToolScreen( width, height )
	if( not BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) ) then return end

	surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
	surface.DrawRect( 0, 0, width, height )

	surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 0 ) )
	surface.DrawRect( 0, 0, width, 60 )
	
	draw.SimpleText( language.GetPhrase( "tool.bricks_server_entityplacer.name" ), "BRICKS_SERVER_Font33", width/2, 30, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	local entitySelected = BRICKS_SERVER.DEVCONFIG.EntityTypes[LocalPlayer():GetNW2String( "bricks_server_stoolcmd_entityclass", "" )]
	draw.SimpleText( BRICKS_SERVER.Func.L( "selected" ), "BRICKS_SERVER_Font33", width/2, 60+((height-60)/2)-15, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
	draw.SimpleText( ((entitySelected and (entitySelected.PrintName or BRICKS_SERVER.Func.L( "error" ))) or BRICKS_SERVER.Func.L( "none" )), "BRICKS_SERVER_Font25", width/2, 60+((height-60)/2)-15, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
end

function TOOL.BuildCPanel( panel )
	panel:AddControl("Header", { Text = BRICKS_SERVER.Func.L( "entityType" ), Description = BRICKS_SERVER.Func.L( "entityPlacerDescription" ) })
 
	local combo = panel:AddControl( "ComboBox", { Label = BRICKS_SERVER.Func.L( "entityType" ) } )
	for k, v in pairs( BRICKS_SERVER.DEVCONFIG.EntityTypes ) do
		if( not istable( v ) or not v.Placeable ) then continue end

		combo:AddOption( (v.PrintName or k), { k } )
	end
	function combo:OnSelect( index, text, data )
		net.Start( "BRS.Net.ToolEntityPlacer" )
			net.WriteString( data[1] )
		net.SendToServer()
	end
end

if( CLIENT ) then
	language.Add( "tool.bricks_server_entityplacer.name", BRICKS_SERVER.Func.L( "entityPlacer" ) )
	language.Add( "tool.bricks_server_entityplacer.desc", BRICKS_SERVER.Func.L( "entityPlacerDescriptionSmall" ) )
	language.Add( "tool.bricks_server_entityplacer.0", BRICKS_SERVER.Func.L( "entityPlacerInstructions" ) )
elseif( SERVER ) then
	util.AddNetworkString( "BRS.Net.ToolEntityPlacer" )
	net.Receive( "BRS.Net.ToolEntityPlacer", function( len, ply )
		if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then return end

		ply:SetNW2String( "bricks_server_stoolcmd_entityclass", net.ReadString() )
	end )
end