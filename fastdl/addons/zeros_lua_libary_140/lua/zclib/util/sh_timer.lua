zclib = zclib or {}
zclib.Timer = zclib.Timer or {}

////////////////////////////////////////////
///////////////// Timer ////////////////////
////////////////////////////////////////////
zclib.Timer.List = zclib.Timer.List or {}

function zclib.Timer.PrintAll()
	PrintTable(zclib.Timer.List)
end

function zclib.Timer.Create(timerid,time,rep,func)

	if zclib.util.FunctionValidater(func) then
		timer.Create(timerid, time, rep,func)
		table.insert(zclib.Timer.List, timerid)
	end
end

function zclib.Timer.Remove(timerid)
	if timer.Exists(timerid) then
		timer.Remove(timerid)
		table.RemoveByValue(zclib.Timer.List, timerid)
	end
end

concommand.Add("zclib_print_timer", function(ply, cmd, args)
	if zclib.Player.IsAdmin(ply) then
		zclib.Timer.PrintAll()
	end
end)
