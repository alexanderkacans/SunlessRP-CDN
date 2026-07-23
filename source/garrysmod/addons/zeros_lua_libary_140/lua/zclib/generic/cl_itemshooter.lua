if SERVER then return end

/*

    A System which creates a Client model on position A and shoots it to position B over the defined time frame

*/

zclib = zclib or {}
zclib.ItemShooter = zclib.ItemShooter or {}

zclib.ItemShooter.Items = zclib.ItemShooter.Items or {}

function zclib.ItemShooter.Add(from,to,time,OnEntityCreated,ThrowSound,DestinationSound,EntityTrail,OnEntityRemoved)

    zclib.Sound.EmitFromPosition(from,ThrowSound or "throw")

    local data = {
        // When did action start
        start_time = CurTime(),

        // How long will the item fly
        travel_time = time,

        // Where does the item spawn from
        from = from,

        // Where does the item move to
        to = to,

		// Can be used to modify the entity on creation
        OnEntityCreated = OnEntityCreated,

		// Called before the entity gets removed
		OnEntityRemoved = OnEntityRemoved,

		// The sound it should play when the item hits its destination
		DestinationSound = DestinationSound,

		// The trail of the entity
		EntityTrail = EntityTrail,
    }

    table.insert(zclib.ItemShooter.Items,data)


    // Create think hook if it doesent exist
    zclib.ItemShooter.Start()
end

function zclib.ItemShooter.Start()
    zclib.Hook.Remove("Think", "ItemShooter")
    zclib.Hook.Add("Think", "ItemShooter", function()
        zclib.ItemShooter.Logic()
    end)
end

function zclib.ItemShooter.Stop()
    zclib.Hook.Remove("Think", "ItemShooter")
end

function zclib.ItemShooter.Logic()
    for k, v in pairs(zclib.ItemShooter.Items) do
        if v and (v.start_time + v.travel_time) > CurTime() then
            zclib.ItemShooter.ItemLogic(v)
        else
            if IsValid(v.item_ent) then
                zclib.ClientModel.Remove(v.item_ent)
                v.item_ent = nil
            end

			if v.OnEntityRemoved then pcall(v.OnEntityRemoved,v.item_ent,v.to) end

            zclib.Sound.EmitFromPosition(v.to,v.DestinationSound or "inv_add")

            zclib.ItemShooter.Items[k] = nil
        end
    end

    if table.Count(zclib.ItemShooter.Items) <= 0 then
        zclib.ItemShooter.Stop()
    end
end

// Handels the bot movement
function zclib.ItemShooter.ItemLogic(data)
    if IsValid(data.item_ent) then

        local dest_time = data.start_time + data.travel_time

        local time_dif = math.Clamp(dest_time - CurTime(),0,100)

        if time_dif < 0.005 then
            data.item_ent:StopParticles()
        end

        local fract = math.Clamp((1 / data.travel_time) * time_dif, 0, 1)

        fract = 1 - fract

        local startPos, endPos = data.from , data.to

        local _pos = LerpVector(fract, startPos,endPos)

        // Lerp a height position so the drone reached its heighest point in the mid of its path
        local dist = startPos:DistToSqr(endPos)
        local max_height = math.Clamp((15 / 15000) * dist,1,50)
        local height = max_height
        if fract < 0.5 then
            height = height * math.EaseInOut((1 / 0.5) * fract, 0, 1)
        else
            height = height * math.EaseInOut(1 - (1 / 0.5) * (fract - 0.5), 0,1)
        end
        _pos = _pos + Vector(0,0,height)


        local flyDir = data.item_ent:GetPos() - endPos
        flyDir = flyDir:Angle()
        flyDir:RotateAroundAxis(flyDir:Right(),180)

        local rot = math.Round(CurTime() % 360,2) * 300

        data.item_ent:SetAngles(Angle(rot,flyDir.y,rot))

        data.item_ent:SetPos(_pos)
    else
        data.item_ent = zclib.ClientModel.AddProp()
        if IsValid(data.item_ent) then
            data.item_ent:SetModel("models/props_junk/PopCan01a.mdl")
            data.item_ent:SetPos(data.from)

            local bound_min,bound_max = data.item_ent:GetModelBounds()
            local size = bound_max - bound_min
            size = size:Length()
            local scale = 3 / size
            data.item_ent:SetModelScale(scale)

            pcall(data.OnEntityCreated,data.item_ent)

            zclib.Effect.ParticleEffectAttach(data.EntityTrail or "zclib_item_trail01", PATTACH_POINT_FOLLOW, data.item_ent, 0)
        end
    end
end
