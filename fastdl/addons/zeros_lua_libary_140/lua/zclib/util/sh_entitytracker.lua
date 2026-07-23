zclib = zclib or {}
zclib.EntityTracker = zclib.EntityTracker or {}
zclib.EntityTracker.List = zclib.EntityTracker.List or {}

function zclib.EntityTracker.Add(ent)
	table.insert(zclib.EntityTracker.List, ent)
end

function zclib.EntityTracker.Remove(ent)
	table.RemoveByValue(zclib.EntityTracker.List, ent)
end

function zclib.EntityTracker.GetList()
	return zclib.EntityTracker.List
end
