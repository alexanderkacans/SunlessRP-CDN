zclib = zclib or {}
zclib.Money = zclib.Money or {}
zclib.Money.List = zclib.Money.List or {}

/*

	Adds money support for diffrent gamemodes

*/
function zclib.Money.AddCurrency(id,data) zclib.Money.List[id] = data end

function zclib.Money.SetCurrency(currencyId)
	zclib.Money.ForceCurrency = currencyId
end

zclib.Money.AddCurrency("darkrp",{
	installed = function(ply) return DarkRP ~= nil end,
	give = function(ply,money) ply:addMoney(money) end,
	take = function(ply,money) ply:addMoney(-money) end,
	get = function(ply) return (tonumber(ply:getDarkRPVar("money")) or 0) end,
	has = function(ply,money) return (tonumber(ply:getDarkRPVar("money")) or 0) >= money end,
})

zclib.Money.AddCurrency("nutscript",{
	installed = function(ply) return nut ~= nil end,
	give = function(ply,money) ply:getChar():giveMoney(money) end,
	take = function(ply,money) ply:getChar():takeMoney(money) end,
	get = function(ply) return ply:getChar():getMoney() or 0 end,
	has = function(ply,money) return ply:getChar():hasMoney(money) end,
})

zclib.Money.AddCurrency("basewars",{
	installed = function(ply) return BaseWars ~= nil end,
	give = function(ply,money) ply:GiveMoney(money) end,
	take = function(ply,money) ply:GiveMoney(-money) end,
	get = function(ply) return ply:GetMoney() or 0 end,
	has = function(ply,money) return (ply:GetMoney() or 0) >= money end,
})

zclib.Money.AddCurrency("underdone",{
	installed = function(ply) return engine.ActiveGamemode() == "underdone" end,
	give = function(ply,money) ply:AddItem("money", money) end,
	take = function(ply,money) ply:RemoveItem("money", money) end,
	get = function(ply)
		// Not supported atm
		return 0
	end,
	has = function(ply,money) return ply:HasItem("money", money) end,
})

zclib.Money.AddCurrency("helix",{
	installed = function(ply) return (ix ~= nil && ix.char != nil) end,

	give = function(ply,money)
		local char = ply:GetCharacter()
		if char then
			char:SetMoney((char:GetMoney() or 0) + money)
		end
	end,

	take = function(ply,money)
		local char = ply:GetCharacter()
		if char then
			char:SetMoney((char:GetMoney() or 0) - money)
		end
	end,

	get = function(ply)
		local char = ply:GetCharacter()
		if char then
			return char:GetMoney() or 0
		else
			return 0
		end
	end,

	has = function(ply,money)
		local char = ply:GetCharacter()
		if char then
			return (char:GetMoney() or 0) >= money
		else
			return false
		end
	end,
})

zclib.Money.AddCurrency("sandbox",{
	installed = function(ply) return engine.ActiveGamemode() == "sandbox" and ply.PS2_Wallet == nil end,
	give = function(ply,money) end,
	take = function(ply,money) end,
	get = function(ply) return 0 end,
	has = function(ply,money) return true end,
})

zclib.Money.AddCurrency("sbox_ps2",{
	installed = function(ply) return engine.ActiveGamemode() == "sandbox" and ply.PS2_Wallet end,
	give = function(ply,money) ply:PS2_AddStandardPoints(money) end,
	take = function(ply,money) ply:PS2_AddStandardPoints(-money) end,
	get = function(ply) return ply.PS2_Wallet.points or 0 end,
	has = function(ply,money) return ply.PS2_Wallet.points >= money end,
})

/*
	Lets figure out what currency is used on this server
*/
function zclib.Money.GetCurrency(ply)
	local CurrencyID

	if zclib.Money.ForcedCurrency && zclib.Money.List[zclib.Money.ForcedCurrency] && zclib.Money.List[zclib.Money.ForcedCurrency]["installed"](ply) then
		CurrencyID = zclib.Money.ForcedCurrency
	else
		for k, v in pairs(zclib.Money.List) do
			if v.installed(ply) then
				CurrencyID = k
				break
			end
		end
	end

	return CurrencyID
end

if SERVER then
	function zclib.Money.Give(ply, money)
		if money <= 0 then return end
		if not IsValid(ply) then return end

		local CurrencyID = zclib.Money.GetCurrency(ply)
		local CurrencyData = zclib.Money.List[CurrencyID]
		if not CurrencyData or not CurrencyData.give then return end

		CurrencyData.give(ply,money)
	end

	function zclib.Money.Take(ply, money)
		if money <= 0 then return end
		if not IsValid(ply) then return end

		local CurrencyID = zclib.Money.GetCurrency(ply)
		local CurrencyData = zclib.Money.List[CurrencyID]
		if not CurrencyData or not CurrencyData.take then return end

		CurrencyData.take(ply,money)
	end
end

// Return how much money the player has
function zclib.Money.Get(ply)
	if not IsValid(ply) then return end

	local CurrencyID = zclib.Money.GetCurrency(ply)
	local CurrencyData = zclib.Money.List[CurrencyID]
	if not CurrencyData or not CurrencyData.get then return end

	return CurrencyData.get(ply)
end

function zclib.Money.Has(ply, money)
	if money <= 0 then return false end
	if not IsValid(ply) then return end

	local CurrencyID = zclib.Money.GetCurrency(ply)
	local CurrencyData = zclib.Money.List[CurrencyID]
	if not CurrencyData or not CurrencyData.has then return end

	return CurrencyData.has(ply,money)
end

// Returns the formated money as string
function zclib.Money.Format(money,round)
	if not money then return "0" end
	if round then
		money = math.Round(money)
	end
	money = tostring(money)
	local sep = ","
	local dp = string.find(money, "%.") or #money + 1

	for i = dp - 4, 1, -3 do
		money = money:sub(1, i) .. sep .. money:sub(i + 1)
	end

	return money
end

function zclib.Money.Display(money,round)
	if not zclib.config.CurrencyInvert then
		return zclib.config.Currency .. zclib.Money.Format(money,round)
	else
		return zclib.Money.Format(money,round) .. zclib.config.Currency
	end
end
