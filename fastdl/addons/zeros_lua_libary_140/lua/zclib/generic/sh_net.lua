zclib = zclib or {}
zclib.Net = zclib.Net or {}

/*

	A System to keep track on net messages

*/

if not zclib.config.NetTrack then return end

zclib.Net.Track = zclib.Net.Track or {}
zclib.Net.LastTrack = zclib.Net.LastTrack or {}

/*
	zclib.Net.Track = {
		[netStr] = {
			count = 1,
			length = 1
		}
	}
*/

function zclib.Net.AddTrack(strName,len)
	if zclib.Net.Track[strName] == nil then
		zclib.Net.Track[strName] = {
			count = 0,
			length = 0,
		}
	end

	zclib.Net.Track[strName].count = (zclib.Net.Track[strName].count or 0) + 1
	zclib.Net.Track[strName].length = (zclib.Net.Track[strName].length or 0) + len
end


function zclib.Net.GetCount(strName)
	if not zclib.Net.Track[strName] then return 0 end
	return zclib.Net.Track[strName].count or 0
end

function zclib.Net.GetLength(strName)
	if not zclib.Net.Track[strName] then return 0 end
	return zclib.Net.Track[strName].length or 0
end


function zclib.Net.GetLastCount(strName)
	if not zclib.Net.LastTrack[strName] then return 0 end
	return zclib.Net.LastTrack[strName].count or 0
end

function zclib.Net.GetLastLength(strName)
	if not zclib.Net.LastTrack[strName] then return 0 end
	return zclib.Net.LastTrack[strName].length or 0
end


local ActiveHooks = hook.GetTable()

// If eProtect is installed then use its hook for tracking incoming net messages
if ActiveHooks["eP:PreNetworking"] then
	hook.Add("eP:PreNetworking","zclib_net_track",function(client,strName,len)
		zclib.Net.AddTrack(strName,len)
	end)
else

	// Otherwhise implement your own hooks
	function net.Incoming( len, client )
	    local i = net.ReadHeader()
	    local strName = util.NetworkIDToString( i )

	    if ( !strName ) then return end

	    local func = net.Receivers[ strName:lower() ]
	    if ( !func ) then return end

	    len = len - 16

		zclib.Net.AddTrack(strName,len)

        local pre = hook.Run("zclib_PreNetworking", client, strName, len)

        if pre == false then return end

        func( len, client )

        hook.Run("zclib_PostNetworking", client, strName, len)
	end
end

local LastTest = 0
function zclib.Net.Cache()
	zclib.Net.LastTrack = table.Copy(zclib.Net.Track)
	LastTest = SysTime()
end

function zclib.Net.SortedByCount(list, limit)
	local nList = {}

	for net_id, data in pairs(list) do
		local len = zclib.Net.GetLength(net_id)
		// data.count < limit then continue end
		if math.Round(len / 8000,3) < limit then continue end

		table.insert(nList, {
			net_id = net_id,
			net_count = data.count,
			net_length = len
		})
	end

	table.sort(nList, function(a, b) return a.net_length > b.net_length end)

	return nList
end

function zclib.Net.PrintList(limitMax,alist,IsDiffrence,limit)
	for _,data in ipairs(alist) do
		if data.net_count == nil or data.net_count == 0 then continue end
		//if data.net_count < limit then continue end

		if data.net_length == nil or data.net_length == 0 then continue end
		if math.Round(data.net_length / 8000,3) < limit then continue end

		local fract = 1 / (limitMax * 2) * math.Clamp(data.net_count - limitMax, 0, limitMax)
		local col = zclib.util.LerpColor(fract, color_white, color_red)

		local count = data.net_count
		local NetLen = math.Round(data.net_length / 8000,3)
		if IsDiffrence then
			count = "+" .. count
			NetLen = "+" .. NetLen
		end

		MsgC(col, string.sub(data.net_id, 1, 45) .. string.rep(" ", 45 - data.net_id:len()) .. count .. string.rep(" ", 5 - string.len(count)) .. " | " .. NetLen .. string.rep(" ", 5 - string.len(NetLen)) .. " KB" .. "\n")
	end
end

function zclib.Net.GetDiffrence(limit)
	local winnerClass,winnerCount = "" , 0
	local diffList = {}

	for net_id,data in pairs(zclib.Net.Track) do

		local cdiff = zclib.Net.GetCount(net_id) - zclib.Net.GetLastCount(net_id)

		local ldiff = zclib.Net.GetLength(net_id) - zclib.Net.GetLastLength(net_id)

		diffList[ net_id ] = {count = cdiff,length = ldiff}

		if cdiff > winnerCount then
			winnerClass = net_id
			//winnerCount = cdiff
			winnerCount = ldiff
		end
	end

	diffList = zclib.Net.SortedByCount(diffList,limit)

	return winnerClass , winnerCount , diffList
end

function zclib.Net.Print(limit)
	print(" ")
	MsgC(color_black, "-------------------------------------------" .. "\n")

	local domain = "SERVER"
	local domain_color = Color(108,163,255)
	if CLIENT then
		domain = "CLIENT"
		domain_color = Color(255,212,108)
	end
	MsgC(domain_color, "zcLib - Net Count - " .. domain .. "\n")

	local sorted = zclib.Net.SortedByCount(zclib.Net.Track,limit)
	zclib.Net.PrintList(1000,sorted,false,limit)

	MsgC(color_black, "-------------------------------------------" .. "\n")

	local winnerClass , winnerCount , diffList = zclib.Net.GetDiffrence(limit)
	if winnerCount <= 0 then
		MsgC(domain_color, "Since the last Net Test ("..zclib.util.FormatTime(SysTime() - LastTest).." ago) there was no new net_message called!\n")
	else
		MsgC(domain_color, "Since the last Net Test ("..zclib.util.FormatTime(SysTime() - LastTest).." ago) the net_message that was called the most is " .. winnerClass .." with " .. winnerCount .. "!" .. "\n")
	end

	zclib.Net.PrintList(200,diffList,true,limit)

	// Lets test again
	zclib.Net.Cache()

	MsgC(color_black, "-------------------------------------------" .. "\n")
	print(" ")
end

if SERVER then
	util.AddNetworkString("zclib.Net.Print")

	// Lets use the first playing joining as a init function
	zclib.Hook.Add("zclib_PlayerJoined", "zclib_PlayerJoined_NetTracker", function(ply)
		zclib.Net.Cache()
		zclib.Hook.Remove("zclib_PlayerJoined", "zclib_PlayerJoined_NetTracker")
	end)
else
	net.Receive("zclib.Net.Print", function(len, ply)
		local limit = net.ReadUInt(16)
		zclib.Net.Print(limit)
	end)

	zclib.Hook.Add("zclib_PlayerInitialized", "zclib_PlayerInitialized_NetTracker", function()
		timer.Simple(3,function()
			zclib.Net.Cache()
		end)
	end)
end

concommand.Add("zclib_print_net", function(ply, cmd, args)
	if zclib.Player.IsAdmin(ply) or not IsValid(ply) then
		local limit = tonumber(args[1] or 1) or 1
		zclib.Net.Print(limit)

		if SERVER and IsValid(ply) and zclib.Player.IsAdmin(ply) then
			net.Start("zclib.Net.Print")
			net.WriteUInt(limit,16)
			net.Send(ply)
		end
	end
end)
