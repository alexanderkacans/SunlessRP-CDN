local lerpclose = 0
local DarkSaber_DelayBetweenLast = 0.1

hook.Add("KeyPress", "anz.DarksaberIgniteUnignite", function(ply, key)
    local wep = ply:GetActiveWeapon()
    if not wep.IsLightsaber then return end
    if wep:GetModel() ~= "models/swtor/anzati/lightsabers/darksaber_2.mdl" then return end

    if key == IN_RELOAD and not ply:KeyDown(IN_USE) then
        local IsOpening = not wep:GetEnabled()

        timer.Create("anzati.Darksaber.Ignite" .. ply:SteamID64(), 0.01, 100, function()
            local BladeBone = wep:LookupBone("blade")
            local lerpclosebonus = 0

            if IsOpening then
                lerpclosebonus = lerpclose + DarkSaber_DelayBetweenLast
            else
                lerpclosebonus = lerpclose - DarkSaber_DelayBetweenLast
            end

            lerpclose = math.Clamp(lerpclosebonus, 0, 1)
            wep:ManipulateBoneScale(BladeBone, Vector(lerpclose, lerpclose, lerpclose))
        end)
    end
end)