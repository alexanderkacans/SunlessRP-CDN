zclib = zclib or {}
zclib.table = zclib.util or {}



// Creates a new randomized table from the input table
function zclib.table.randomize( t )
	local out = { }

	while #t > 0 do
		table.insert( out, table.remove( t, math.random( #t ) ) )
	end

	return out
end

function zclib.table.clean(tbl)
	local new_tbl = {}

	for k, v in pairs(tbl) do
		if v then
			new_tbl[k] = v
		end
	end

	return new_tbl
end

function zclib.table.ToString(tbl)
	local str = ""

	for k, v in pairs(tbl) do
		str = str .. k .. ", "
	end

	return str
end

function zclib.table.JobToString(tbl)
	local str = ""

	for k, v in pairs(tbl) do
		str = str .. team.GetName(k) .. ", "
	end

	return str
end

function zclib.table.invert(tbl)
	local new = {}

	for k, v in pairs(tbl) do
		new[v] = true
	end

	return new
end
