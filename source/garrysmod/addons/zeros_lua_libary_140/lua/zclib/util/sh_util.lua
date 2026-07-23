zclib = zclib or {}
zclib.util = zclib.util or {}

// EntityDistance check for net messages
zclib.netdist = 1500

function zclib.Print(msg)
	if zclib.config.NoPrint then return end
	MsgC(Color(37, 69, 129), "[Zero´s Libary] ", color_white, msg .. "\n")
end

function zclib.ErrorPrint(msg)
	if zclib.config.NoPrint then return end
	MsgC(Color(37, 69, 129), "[Zero´s Libary] ", Color(255, 0, 0), msg .. "\n")
end

// Basic notify function
function zclib.Notify(ply, msg, ntfType)
	if not IsValid(ply) then return end

	if SERVER then
		if DarkRP and DarkRP.notify then
			DarkRP.notify(ply, ntfType, 8, msg)
		else
			ply:ChatPrint(msg)
		end
	else
		zclib.vgui.Notify(msg, ntfType)
	end
end

function zclib.util.IsInsideViewCone(pos,eyepos,eyeangles,view_distance,cone_rad)
	local x = eyepos
	local dir = eyeangles:Forward()

	//debugoverlay.Sphere(x,5,1,Color( 0, 255, 0 ),false)

	// So you project pos onto dir to find the point's distance along the axis:
	local cone_dist = (pos - x):Dot(dir)

	//At this point, you can reject values outside 0 <= cone_dist <= view_distance.

	//Then you calculate the cone radius at that point along the axis:
	local cone_radius = (cone_dist / view_distance) * cone_rad

	// And finally calculate the point's orthogonal distance from the axis to compare against the cone radius:
	local orth_distance = ((pos - x) - cone_dist * dir):Length()

	//debugoverlay.Sphere(x,cone_radius,1,Color( 255, 255, 0 ),false)

	//debugoverlay.BoxAngles(eyepos, Vector(0, -15, -15), Vector(view_distance, 15, 15),eyeangles, 1, Color(255, 255, 255, 25))

	local is_point_inside_cone = (orth_distance < cone_radius)

	return is_point_inside_cone
end

if CLIENT then
	function zclib.util.LoopedSound(ent, soundfile, shouldplay,dist)
		if shouldplay and zclib.util.InDistance(LocalPlayer():GetPos(), ent:GetPos(), dist or 500) then
			if ent.Sounds == nil then
				ent.Sounds = {}
			end

			if ent.Sounds[soundfile] == nil then
				ent.Sounds[soundfile] = CreateSound(ent, soundfile)
			end

			if ent.Sounds[soundfile]:IsPlaying() == false then

				ent.Sounds[soundfile]:Play()
				ent.Sounds[soundfile]:ChangeVolume(zclib.Convar.Get("zclib_cl_sfx_volume"), 0)
				ent.LastVolume = zclib.Convar.Get("zclib_cl_sfx_volume")
			else
				if ent.LastVolume ~= zclib.Convar.Get("zclib_cl_sfx_volume") then
					ent.LastVolume = zclib.Convar.Get("zclib_cl_sfx_volume")
					ent.Sounds[soundfile]:ChangeVolume(ent.LastVolume, 0)
				end
			end
		else
			if ent.Sounds == nil then
				ent.Sounds = {}
			end

			if ent.Sounds[soundfile] ~= nil and ent.Sounds[soundfile]:IsPlaying() == true then
				ent.Sounds[soundfile]:ChangeVolume(0, 0)
				ent.Sounds[soundfile]:Stop()

				ent.Sounds[soundfile] = nil
			end
		end
	end

	function zclib.util.ScreenPointToRay(ViewPos,filter,mask)
		local x, y = input.GetCursorPos()
		local dir = gui.ScreenToVector( x,y )

		// Trace for valid Spawn Pos
		local c_trace = zclib.util.TraceLine({
			start = ViewPos,
			endpos = ViewPos + dir:Angle():Forward() * 10000,
			filter = filter,
			mask = mask,
		}, "ScreenPointToRay")
		return c_trace
	end

	local wtr = { collisiongroup = COLLISION_GROUP_WORLD, output = {} }
	local woff = Vector(0,0,100000)
	function zclib.util.IsInWorld( pos )
		wtr.start = pos
		wtr.endpos = pos - woff
		return util.TraceLine( wtr ).HitWorld
	end
end

function zclib.util.FormatDate(date)
	local chars = string.Split( date, "/" )
	local CleanDate = chars[3] .. "/" .. chars[2] .. "/" .. chars[1] .. " - " .. chars[4]

	return CleanDate
end

function zclib.util.GetDate()
	return os.time()
end

function zclib.util.GenerateUniqueID(template)
	return string.gsub(template, "[xy]", function(c)
		local v = (c == "x") and math.random(0, 0xf) or math.random(8, 0xb)

		return tostring(string.format("%x", v))
	end) .. "a"
end

function zclib.util.UnitToMeter(unit)
	return math.Round(unit * 0.01953125) .. "m"
end

// Takes in a savefile name and makes it clean and nice
function zclib.util.StringClean(id)
	// Make it lower case
	id = string.lower(id)

	// Lets removed any problematic symbols
	local pattern = '[\\/:%*%?"<>!|]' // a set of all restricted characters
	id = string.gsub(id,pattern,"",99)

	// Replace empty space with underline
	id = string.Replace(id," ","_")

	return id
end

function zclib.util.StringToUniqueID(str)
	local _bytes = {string.byte(str, 1, string.len(str))}
	local _seed = table.concat( _bytes,"", 1, #_bytes )
	math.randomseed( _seed )
	return math.random(1,9999999)
end


function zclib.util.FormatTime(time)
	local divid = time / 60
	local minutes = math.floor(time / 60)
	local seconds = math.Round(60 * (divid - minutes))

	local lang_m = zclib.Language["Minutes"]
	local lang_s = zclib.Language["Seconds"]

	if seconds > 0 and minutes > 0 then
		return minutes .. " " .. lang_m .. " | " .. seconds .. " " .. lang_s
	elseif seconds <= 0 and minutes > 0 then
		return minutes .. " " .. lang_m
	elseif seconds >= 0 and minutes <= 0 then
		return seconds .. " " .. lang_s
	end
end

// Checks if the distance between pos01 and pos02 is smaller then dist
function zclib.util.InDistance(pos01, pos02, dist)
	return pos01:DistToSqr(pos02) < (dist * dist)
end

// Used to fix the Duplication Glitch
local CollisionCooldownList = {}
function zclib.util.CollisionCooldown(ent)
	if zclib.Entity.GettingRemoved(ent) then return true end

	// NOTE I changed the way the collision cooldown gets saved since there will be problems for scripts which use the duplicator.CreateEntityFromTable function
	// As it saved any value from the entity which means that once the entity will be reconstructed it would cause the cooldown to be at the time at which it got saved
	local Cooldown = CollisionCooldownList[ent]
	if Cooldown == nil then
		CollisionCooldownList[ent] = CurTime() + 0.5
		return false
	else
		if CurTime() < Cooldown then
			return true
		else
			CollisionCooldownList[ent] = CurTime() + 0.5
			return false
		end
	end
end


function zclib.util.SnapValue(snapval,val)
	val = val / snapval
	val = math.Round(val)
	val = val * snapval
	return val
end

// Tells us if the functions is valid
function zclib.util.FunctionValidater(func)
	if (type(func) == "function") then return true end
	return false
end

// Performs a TraceLine
function zclib.util.TraceLine(tracedata,identifier)
	return util.TraceLine(tracedata)
end

// Calculates how much of the AddAmount will remain and how much can be added
function zclib.util.GetRemain(HaveAmount, CapAmount, AddAmount)
	local diff = CapAmount - HaveAmount
	local add = math.Clamp(AddAmount, 0, diff)
	local remain = AddAmount - add
	return remain, add
end

function zclib.util.RandomChance(chance)
	if math.random(0, 100) < math.Clamp(chance,0,100) then
		return true
	else
		return false
	end
end

// Returns a random postion on a
function zclib.util.GetRandomPositionInsideCircle(rad_min,rad_max,height)
	local randomAngle = math.random(360)
	local InnerCircleRadius = math.random(rad_min,rad_max)
	return Vector(math.cos(randomAngle) * InnerCircleRadius, math.sin(randomAngle) * InnerCircleRadius, height)
end

// Calls the provided function with a small delay, we cant use time 0 (NextFrame) since some scripts can fuck with that
function zclib.util.CallDelayed(ent,func)
	timer.Simple(math.Rand(0.001,0.01),function()
		if IsValid(ent) and ent:IsValid() then
			pcall(func)
		end
	end)
end
