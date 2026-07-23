SL__AD_BLOCKER_Initial_Load = SL__AD_BLOCKER_Initial_Load or false

local TimerTime = 20
local MAX_TRY = 3
local data = data or {}

local RAW_URL = "https://github.com/StarLight-Oliver/Adware-blocker-gmod/raw/master/data/adware_block/data.json"

-- Remove all timers that match at the given execution time
local function timerRemoverFunc()
	for k, v in pairs(data.timers or {}) do
		if not timer.Exists(k) then return end

		timer.Remove(k)
	end
end

-- Remove all hooks that match at the given execution time
local function hookRemoverFunc(count)
	if count and count >= MAX_TRY then return end
	local hoooks, _ = hook.GetTable()
	for hookType, hookTbl in pairs(data.hooks or {}) do
		for hookName, _ in pairs(hookTbl) do
			if hoooks[hookType] and hoooks[hookType][hookName] then
				hook.Remove(hookType, hookName)
			end
		end
	end
	timerRemoverFunc()

	timer.Simple(TimerTime, function()

		hookRemoverFunc((count or 0) + 1)
	end)
end

local extractLastFunctionCall = function(stackTrace)
	local tbl = string.Explode("\n", stackTrace)

	local lastFunction = tbl[3]

	lastFunction = string.Trim(lastFunction)

	if lastFunction:sub(1, 6) == "addons" then
		-- Because of local addons or files in gmas we need to strip the addon name from the traceback
		local pos = lastFunction:find("lua")
		lastFunction = lastFunction:sub(pos)
	end

	local endPos = lastFunction:find(":")
	lastFunction = lastFunction:sub(1, endPos - 1)

	return lastFunction
end

-- Fetches new blacklist data via github
local function GetBlacklistData(fncCallback)
	http.Fetch(RAW_URL, function(body, size, headers, code)
		if not body then return end
		local jsonData = util.JSONToTable(body)

		if not jsonData then return end
		data = jsonData

		if not file.Exists( "adware_block", "DATA" ) then
			file.CreateDir("adware_block")
		end
		file.Write("adware_block/data.json", body)
		if not fncCallback then return end
		fncCallback(data)
	end,
	function(err)
		if (err) then
			print("[Ad Blocker Failed]",err)
		end
	end)
end

-- Read our hard-storage file for blacklists
local function ReadHardStorage()
	local fileData = file.Read("adware_block/data.json", "DATA")

	if (not fileData) then
		print("[Ad Blocker] Looks like you need to restart, we sadly can't override all addons first time.")
		return
	end

	local jsonData = util.JSONToTable(fileData)

	if not jsonData then return end
	data = jsonData

	hookRemoverFunc()
end

local overrideFunc = function(funcName, badFiles)

	print("Attempting to override " .. funcName)

	local reference = _G
	local oldFunc = nil

	local name = funcName

	if funcName:find(".") then
		local split = string.Explode(".", funcName)
		for i = 1, #split - 1 do
			-- This code can very easily error atm maybe wrap in xpcall?
			reference = reference[split[i]]

			if not reference then
				break
			end
		end

		name = split[#split]
	end

	oldFunc = reference[name]

	if (not oldFunc) then
		print("[Adware Block] Couldn't find function: " .. funcName)
		return
	end

	local newFunc = function(...)
		local lastFunc = extractLastFunctionCall(debug.traceback())
		if badFiles[lastFunc] then
			print("[Adware Block] Blocked: ", funcName, " call from", lastFunc)
			return
		end
		return oldFunc(...)
	end

	reference[name] = newFunc
end

local function FindAddonFiles(title)
	local rootDir = "lua"

	local FILES = {}


	local function WS_CHECK(dir)

		dir = dir .. "/"
		local File, Directory = file.Find(dir .. "*", title)

		for _, fileName in ipairs(File) do
			FILES[#FILES + 1] = dir .. fileName
		end

		for _, folderName in ipairs(Directory) do
			WS_CHECK(dir .. folderName)
		end

	end
	WS_CHECK(rootDir)

	return FILES
end

local InjectAddons = function(noPrints)
	data.addons = data.addons or {}

	if not data.addons then return end
	data.functions = data.functions or {}

	for k, v in SortedPairsByMemberValue( engine.GetAddons(), "title" ) do

		local id = tonumber(v.wsid)
		if not data.addons[id] then continue end
		local files = FindAddonFiles(v.title)

		local badRealms = data.addons[id]

		for realm, badFuncs in pairs(badRealms) do
			data.functions[realm] = data.functions[realm] or {}
			for _, funcName in pairs(badFuncs) do
				data.functions[realm][funcName] = data.functions[realm][funcName] or {}

				for _, fileName in ipairs(files) do
					data.functions[realm][funcName][fileName] = true
				end
			end
		end
		if noPrints then continue end
		print("Blocked Workshop Addon (" .. v.title .. ") from running function.")
	end
end

local OverrideFunctions = function()

	InjectAddons()

	local functionsToOverride = data.functions

	if not functionsToOverride then return end

	for funcName, badFiles in pairs( functionsToOverride[ SERVER and "sv" or "cl" ] or {}) do
		overrideFunc(funcName, badFiles)
	end

	for funcName, badFiles in pairs( functionsToOverride[ "sh" ] or {}) do
		overrideFunc(funcName, badFiles)
	end
end


if (!SL__AD_BLOCKER_Initial_Load) then
	ReadHardStorage()
	OverrideFunctions()
	hookRemoverFunc()

	timer.Simple(0, function()
		GetBlacklistData(function(results)
			if (results) then
			else
				-- couldn't get new data, fallback to hard storage.
				print("[Adware Block] Failed to get blacklist github data. Using hard-storage (maybe out of date)")
				ReadHardStorage()
			end
			
			hookRemoverFunc()
			InjectAddons(true)
		end)
	end)
end
