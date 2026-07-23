local playerMeta = FindMetaTable("Player")

util.AddNetworkString( "BRS.Net.SetCurrencies" )
function playerMeta:SetCurrencyTable( currenciesTable )
	if( not currenciesTable ) then return end

	self.BRS_CURRENCIES = (currenciesTable or {})

	net.Start( "BRS.Net.SetCurrencies" )
		net.WriteTable( currenciesTable )
	net.Send( self )
end

function playerMeta:SetCurrency( currency, amount )
	if( not BRICKS_SERVER.CONFIG.CURRENCIES[currency] ) then return end

	amount = math.max( amount, 0 )

	local currenciesTable = self:GetCurrencies()
	if( not currenciesTable[currency] ) then
		BRICKS_SERVER.Func.InsertCurrencyEntryDB( self:SteamID64(), currency, amount )
	else
		BRICKS_SERVER.Func.UpdateCurrencyEntryDB( self:SteamID64(), currency, amount )
	end

	currenciesTable[currency] = amount
	self:SetCurrencyTable( currenciesTable )
end

function playerMeta:AddCurrency( currency, amount )
	if( not BRICKS_SERVER.CONFIG.CURRENCIES[currency] ) then return end

	self:SetCurrency( currency, self:GetCurrency( currency )+amount )
end

hook.Add( "PlayerInitialSpawn", "BRS.PlayerInitialSpawn.CurrenciesLoadData", function( ply ) 
	BRICKS_SERVER.Func.FetchCurrencyEntryDB( ply:SteamID64(), function( data )
		local currenciesTable = {}
		for k, v in pairs( data ) do
			currenciesTable[tonumber( v.currencyKey )] = tonumber( v.amount )
		end

		ply:SetCurrencyTable( currenciesTable )
	end )
end )

util.AddNetworkString( "BRS.Net.Admin_AddCurrency" )
net.Receive( "BRS.Net.Admin_AddCurrency", function( len, ply )
	local victimID64 = net.ReadString()
	local currencyType = net.ReadUInt( 8 )
	local amount = net.ReadInt( 32 )

	if( not victimID64 or not currencyType or not amount or not BRICKS_SERVER.CONFIG.CURRENCIES[currencyType] ) then return end
	if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then return end

	local victim = player.GetBySteamID64( victimID64 )

	if( not IsValid( victim ) ) then return end

	victim:AddCurrency( currencyType, amount )

	BRICKS_SERVER.Func.SendNotification( ply, 1, 5, "Gave " .. victim:Nick() .. " " .. string.Comma( amount ) .. " " .. (BRICKS_SERVER.CONFIG.CURRENCIES[currencyType].Name or "ERROR") )
	BRICKS_SERVER.Func.SendNotification( victim, 1, 5, "An admin has gave you " .. string.Comma( amount ) .. " " .. (BRICKS_SERVER.CONFIG.CURRENCIES[currencyType].Name or "ERROR") )
end )

util.AddNetworkString( "BRS.Net.Admin_SetCurrency" )
net.Receive( "BRS.Net.Admin_SetCurrency", function( len, ply )
	local victimID64 = net.ReadString()
	local currencyType = net.ReadUInt( 8 )
	local amount = net.ReadInt( 32 )

	if( not victimID64 or not currencyType or not amount or not BRICKS_SERVER.CONFIG.CURRENCIES[currencyType] ) then return end
	if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then return end

	local victim = player.GetBySteamID64( victimID64 )

	if( not IsValid( victim ) ) then return end

	victim:SetCurrency( currencyType, amount )

	BRICKS_SERVER.Func.SendNotification( ply, 1, 5, "Set " .. victim:Nick() .. "'s " .. (BRICKS_SERVER.CONFIG.CURRENCIES[currencyType].Name or "ERROR") .. " to " .. string.Comma( amount ) )
	BRICKS_SERVER.Func.SendNotification( victim, 1, 5, "An admin has set your " .. (BRICKS_SERVER.CONFIG.CURRENCIES[currencyType].Name or "ERROR") .. " to " .. string.Comma( amount ) )
end )

hook.Add( "BRS.Hooks.ConfigUpdated", "BRS.Hooks.ConfigUpdated.Currencies", function( keysChanged )	
	if( table.HasValue( (keysChanged or {}), "CURRENCIES" ) and BRICKS_SERVER.LoadCurrencies ) then
		BRICKS_SERVER.LoadCurrencies()
	end
end )