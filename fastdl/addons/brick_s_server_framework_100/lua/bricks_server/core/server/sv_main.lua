util.AddNetworkString( "BRS.Net.OpenBrickServer" )

function BRICKS_SERVER.Func.OpenMenu( ply )
	net.Start( "BRS.Net.OpenBrickServer" )
	net.Send( ply )
end

hook.Add( "PlayerSay", "BRS.PlayerSay.OpenMenu", function( ply, text )
	if( string.lower( text ) == "!bricksserver" or string.lower( text ) == "/bricksserver" ) then
		BRICKS_SERVER.Func.OpenMenu( ply )
		return ""
	end
end )

concommand.Add( "bricksserver", function( ply, cmd, args )
	if( IsValid( ply ) and ply:IsPlayer() ) then
		BRICKS_SERVER.Func.OpenMenu( ply )
	end
end )

util.AddNetworkString( "BRS.Net.SendNetworkReady" )
net.Receive( "BRS.Net.SendNetworkReady", function( len, ply )
	if( ply.BRS_ReadyNetworked ) then return end

	ply.BRS_ReadyNetworked = true

	hook.Run( "BRS.Hooks.PlayerFullLoad", ply ) 
end )

util.AddNetworkString( "BRS.Net.SendServerTime" )
hook.Add( "BRS.Hooks.PlayerFullLoad", "BRS.Hooks.PlayerFullLoad.SendServerTime", function( ply )
	net.Start( "BRS.Net.SendServerTime" )
		net.WriteInt( os.time(), 32 )
		net.WriteInt( CurTime(), 32 )
	net.Send( ply )
end )

util.AddNetworkString( "BRS.Net.SendTopNotification" )
function BRICKS_SERVER.Func.SendTopNotification( ply, text, time, color )
	net.Start( "BRS.Net.SendTopNotification" )
		net.WriteString( text or "" )
		net.WriteUInt( (time or 5), 8)
		net.WriteColor( color or Color( BRICKS_SERVER.Func.GetTheme( 5 ).r, BRICKS_SERVER.Func.GetTheme( 5 ).g, BRICKS_SERVER.Func.GetTheme( 5 ).b ) )
	net.Send( ply )
end

util.AddNetworkString( "BRS.Net.SendNotification" )
function BRICKS_SERVER.Func.SendNotification( ply, type, time, message )
	net.Start( "BRS.Net.SendNotification" )
		net.WriteString( message or "" )
		net.WriteUInt( (type or 1), 8)
		net.WriteUInt( (time or 3), 8)
	net.Send( ply )
end

util.AddNetworkString( "BRS.Net.SendChatNotification" )
function BRICKS_SERVER.Func.SendChatNotification( ply, tagColor, tagString, msgColor, msgString )
	net.Start( "BRS.Net.SendChatNotification" )
		net.WriteColor( tagColor or Color( BRICKS_SERVER.Func.GetTheme( 5 ).r, BRICKS_SERVER.Func.GetTheme( 5 ).g, BRICKS_SERVER.Func.GetTheme( 5 ).b ) )
		net.WriteString( tagString or "" )
		net.WriteColor( msgColor or Color( BRICKS_SERVER.Func.GetTheme( 6 ).r, BRICKS_SERVER.Func.GetTheme( 6 ).g, BRICKS_SERVER.Func.GetTheme( 6 ).b ) )
		net.WriteString( msgString or "" )
	net.Send( ply )
end

util.AddNetworkString( "BRS.Net.UseMenuNPC" )