zclib = zclib or {}
zclib.Effect = zclib.Effect or {}

game.AddParticles("particles/zclib_vfx.pcf")
PrecacheParticleSystem("zclib_item_trail")
PrecacheParticleSystem("zclib_item_trail01")
PrecacheParticleSystem("zclib_sell")

game.AddParticles("particles/zmb_vgui.pcf")
PrecacheParticleSystem("zmb_vgui_destroy")
PrecacheParticleSystem("zmb_vgui_magic")
PrecacheParticleSystem("zmb_vgui_repair")
PrecacheParticleSystem("zmb_vgui_use")
PrecacheParticleSystem("zmb_vgui_upgrade")
PrecacheParticleSystem("zmb_vgui_techno")
PrecacheParticleSystem("zmb_vgui_sell")

PrecacheParticleSystem("zmb_vgui_firework_blue")
PrecacheParticleSystem("zmb_vgui_firework_green")
PrecacheParticleSystem("zmb_vgui_firework_red")
PrecacheParticleSystem("zmb_vgui_firework_yellow")


function zclib.Effect.Generic(effect, vPoint)
	local effectdata = EffectData()
	effectdata:SetStart(vPoint)
	effectdata:SetOrigin(vPoint)
	effectdata:SetScale(2)
	util.Effect(effect, effectdata, true, true)
end

if CLIENT then
	function zclib.Effect.RandomDecals(pos, decal, radius,amount)
		for i = 1, amount or 15 do
			local decal_pos = pos + Vector(1, 0, 0) * math.random(-radius, radius) + Vector(0, 1, 0) * math.random(-radius, radius)
			util.Decal(decal, decal_pos + Vector(0, 0, 5), decal_pos - Vector(0, 0, 50))
		end
	end

	function zclib.Effect.ParticleEffect(effect, pos, ang, ent)
		if zclib.Convar.Get("zclib_cl_particleeffects") == 0 then return end
		if not effect then return end
		if not pos then return end
		if not ang then return end

		if ent and IsValid(ent) then
			ParticleEffect(effect, pos, ang, ent)
		else
			ParticleEffect(effect, pos, ang)
		end
	end

	function zclib.Effect.ParticleEffectAttach(effect, attachType, ent, attachid)
		if zclib.Convar.Get("zclib_cl_particleeffects") == 0 then return end
		if not IsValid(ent) then return end
		if not attachType then return end
		if not effect then return end
		if not attachid then return end

		ParticleEffectAttach(effect, attachType, ent, attachid)
	end
end

zclib.NetEvent = zclib.NetEvent or {}

zclib.NetEvent.Definitions = {}
function zclib.NetEvent.AddDefinition(id,data,action,server)

	zclib.NetEvent.Definitions[id] = {
		data = data,
		action = action,
		server = server,
	}

	if SERVER then
		util.AddNetworkString("zclib_fx_" .. id)
	end

	if CLIENT then
		net.Receive("zclib_fx_" .. id, function(len)

			local received = {}
			for k,v in ipairs(data) do
				if v.type == "entity" then
					received[k] = net.ReadEntity()
				elseif v.type == "vector" then
					received[k] = net.ReadVector()
				elseif v.type == "uiint" then
					received[k] = net.ReadUInt(16)
				elseif v.type == "int" then
					received[k] = net.ReadInt(16)
				elseif v.type == "string" then
					received[k] = net.ReadString()
				elseif v.type == "bool" then
					received[k] = net.ReadBool()
				elseif v.type == "angle" then
					received[k] = net.ReadAngle()
				elseif v.type == "float" then
					received[k] = net.ReadFloat()
				end
			end

			if IsValid(LocalPlayer()) then
				pcall(action,received)
			end
		end)
	end
end


// Sends a Net Effect Msg to all clients
function zclib.NetEvent.Create(id, data01)

	local EffectGroup = zclib.NetEvent.Definitions[id]
	if not EffectGroup then return end

	// Should we call it on server too?
	if EffectGroup.server then
		pcall(EffectGroup.action,data01)
	end

	net.Start("zclib_fx_" .. id)
	for k,v in ipairs(EffectGroup.data) do
		if v.type == "entity" then
			net.WriteEntity(data01[k])
		elseif v.type == "vector" then
			net.WriteVector(data01[k])
		elseif v.type == "uiint" then
			net.WriteUInt(data01[k],16)
		elseif v.type == "int" then
			net.WriteInt(data01[k],16)
		elseif v.type == "string" then
			net.WriteString(data01[k])
		elseif v.type == "bool" then
			net.WriteBool(data01[k])
		elseif v.type == "angle" then
			net.WriteAngle(data01[k])
		elseif v.type == "float" then
			net.WriteFloat(data01[k])
		end
	end
	net.Broadcast()
end

zclib.NetEvent.AddDefinition("zclib_sell", {
	[1] = {
		type = "vector"
	}
}, function(received)
	local pos = received[1]
	if pos == nil then return end
	zclib.Effect.ParticleEffect("zclib_sell", pos, angle_zero, LocalPlayer())
	zclib.Sound.EmitFromPosition(pos,"cash")
end)
