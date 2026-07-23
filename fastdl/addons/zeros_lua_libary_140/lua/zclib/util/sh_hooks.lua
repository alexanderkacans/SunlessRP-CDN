zclib = zclib or {}
zclib.Hook = zclib.Hook or {}

////////////////////////////////////////////
///////////////// Hooks ////////////////////
////////////////////////////////////////////
zclib.Hook.List = zclib.Hook.List or {}

function zclib.Hook.PrintAll()
	PrintTable(zclib.Hook.List)
end

function zclib.Hook.GetUniqueIdentifier(eventName, identifier)
	local _identifier = "a.zclib." .. eventName .. "." .. identifier
	if SERVER then
		_identifier = _identifier .. ".sv"
	else
		_identifier = _identifier .. ".cl"
	end
	return _identifier
end

function zclib.Hook.Exist(eventName, identifier)
	local reg_hooks = hook.GetTable()
	local _identifier = zclib.Hook.GetUniqueIdentifier(eventName, identifier)
	local exists = false
	if reg_hooks[eventName] and reg_hooks[eventName][_identifier] then
		exists = true
	end

	//print(eventName.." "..identifier.. "Exists: "..tostring(exists))
	return exists
end

function zclib.Hook.Add(eventName, identifier, func)

	// Lets make sure we remove the hook if its allready exist
	zclib.Hook.Remove(eventName, identifier)

	local _identifier = zclib.Hook.GetUniqueIdentifier(eventName, identifier)


	if zclib.util.FunctionValidater(func) then

		hook.Add(eventName, _identifier, func)

		if zclib.Hook.List[eventName] == nil then
			zclib.Hook.List[eventName] = {}
		end

		table.insert(zclib.Hook.List[eventName], identifier)
	end
end

function zclib.Hook.Remove(eventName, identifier)
	//print("Hook.Remove: [" .. eventName .. "] (" .. identifier .. ")")
	local _identifier = zclib.Hook.GetUniqueIdentifier(eventName, identifier)

	hook.Remove(eventName, _identifier)

	if zclib.Hook.List[eventName] then
		table.RemoveByValue(zclib.Hook.List[eventName], identifier)
	end
end
////////////////////////////////////////////
////////////////////////////////////////////
