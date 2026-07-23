local playerMeta = FindMetaTable("Player")

function playerMeta:GetCurrencies()
    if( CLIENT and self == LocalPlayer() ) then
        return BRS_CURRENCIES
    else
        return self.BRS_CURRENCIES or {}
    end
end

function playerMeta:GetCurrency( currency )
	if( not BRICKS_SERVER.CONFIG.CURRENCIES[currency] ) then return 0 end

    return self:GetCurrencies()[currency] or 0
end

concommand.Add( "addcurrency", function( ply, cmd, args )
    if( CLIENT ) then
		if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then 
			print( "BRICKS SERVER ERROR: NO ACCESS" )
			return 
		end

		if( args[1] and args[2] and args[3] and isstring( args[1] ) and isnumber( tonumber( args[2] ) ) and isnumber( tonumber( args[3] ) ) ) then
			net.Start( "BRS.Net.Admin_AddCurrency" )
				net.WriteString( args[1] )
				net.WriteUInt( tonumber( args[2] ), 8 )
				net.WriteInt( tonumber( args[3] ), 32 )
			net.SendToServer()
		end
    elseif( SERVER ) then
        local steamid64 = args[1]
        local currencyType = tonumber( args[2] or 0 )
        local amount = tonumber( args[3] or 0 )
        if( (not IsValid( ply ) or BRICKS_SERVER.Func.HasAdminAccess( ply )) and steamid64 and currencyType and amount ) then
            if( not BRICKS_SERVER.CONFIG.CURRENCIES[currencyType] ) then return end
        
            local victim = player.GetBySteamID64( steamid64 )
        
            if( not IsValid( victim ) ) then return end
        
            victim:AddCurrency( currencyType, amount )

            if( IsValid( ply ) ) then
				BRICKS_SERVER.Func.SendNotification( ply, 1, 5, "Gave " .. victim:Nick() .. " " .. string.Comma( amount ) .. " " .. (BRICKS_SERVER.CONFIG.CURRENCIES[currencyType].Name or "ERROR") )
            end

			BRICKS_SERVER.Func.SendNotification( victim, 1, 5, "An admin has gave you " .. string.Comma( amount ) .. " " .. (BRICKS_SERVER.CONFIG.CURRENCIES[currencyType].Name or "ERROR") )
        end
	end
end )

concommand.Add( "setcurrency", function( ply, cmd, args )
    if( CLIENT ) then
		if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then 
			print( "BRICKS SERVER ERROR: NO ACCESS" )
			return 
		end

		if( args[1] and args[2] and args[3] and isstring( args[1] ) and isnumber( tonumber( args[2] ) ) and isnumber( tonumber( args[3] ) ) ) then
			net.Start( "BRS.Net.Admin_SetCurrency" )
				net.WriteString( args[1] )
				net.WriteUInt( tonumber( args[2] ), 8 )
				net.WriteInt( tonumber( args[3] ), 32 )
			net.SendToServer()
		end
    elseif( SERVER ) then
        local steamid64 = args[1]
        local currencyType = tonumber( args[2] or 0 )
        local amount = tonumber( args[3] or 0 )
        if( (not IsValid( ply ) or BRICKS_SERVER.Func.HasAdminAccess( ply )) and steamid64 and currencyType and amount ) then
            if( not BRICKS_SERVER.CONFIG.CURRENCIES[currencyType] ) then return end
        
            local victim = player.GetBySteamID64( steamid64 )
        
            if( not IsValid( victim ) ) then return end
        
            victim:SetCurrency( currencyType, amount )

            if( IsValid( ply ) ) then
				BRICKS_SERVER.Func.SendNotification( ply, 1, 5, "Set " .. victim:Nick() .. "'s " .. (BRICKS_SERVER.CONFIG.CURRENCIES[currencyType].Name or "ERROR") .. " to " .. string.Comma( amount ) )
            end

			BRICKS_SERVER.Func.SendNotification( victim, 1, 5, "An admin has set your " .. (BRICKS_SERVER.CONFIG.CURRENCIES[currencyType].Name or "ERROR") .. " to " .. string.Comma( amount ) )
        end
	end
end )

function BRICKS_SERVER.LoadCurrencies()
	BRICKS_SERVER.DEVCONFIG.Currencies = BRICKS_SERVER.DEVCONFIG.Currencies or {}

	for k, v in pairs( BRICKS_SERVER.CONFIG.CURRENCIES or {} ) do
		BRICKS_SERVER.DEVCONFIG.Currencies["custom_" .. k] = {
			Title = v.Name,
			getFunction = function( ply )
				return ply:GetCurrency( k )
			end,
			addFunction = function( ply, amount )
				ply:AddCurrency( k, amount )
			end,
			formatFunction = function( amount )
				if( v.Prefix ) then
					return v.Prefix .. string.Comma( amount or 0 )
				elseif( v.Suffix ) then
					return string.Comma( amount or 0 ) .. " " .. v.Suffix
				else
					return string.Comma( amount or 0 )
				end
			end
		}
	end
end
BRICKS_SERVER.LoadCurrencies()