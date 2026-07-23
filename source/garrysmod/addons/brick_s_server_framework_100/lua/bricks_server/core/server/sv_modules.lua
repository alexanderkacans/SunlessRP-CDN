if( not game.IsDedicated() ) then return end

-- if( timer.Exists( "BRS_SERVERPING_TIMER" ) ) then
--     timer.Remove( "BRS_SERVERPING_TIMER" )
-- end

-- timer.Create( "BRS_SERVERPING_TIMER", 900, 0, function()
--     local headers = {
--         ["server-name"] = GetHostName() or "None",
--         ["server-map"] = game.GetMap() or "None",
--         ["server-gamemode"] = engine.ActiveGamemode() or "None",
--         ["server-players"] = tostring( player.GetCount() or 0 ),
--         ["server-max-players"] = tostring( game.MaxPlayers() or 0 )
--     }

--     for k, v in pairs( BRICKS_SERVER.DLCMODULES ) do
--         if( not BRICKS_SERVER.Modules[k] ) then continue end

--         headers[tostring(v.ScriptID)] = util.TableToJSON( { (BRICKS_SERVER.Modules[k][4] or "None"), (BRICKS_SERVER.Modules[k][5] or "None") } )
--     end

--     http.Post( "https://brickwall-dev-servers.herokuapp.com/serverping", {}, function() end, function() end, headers )
-- end )