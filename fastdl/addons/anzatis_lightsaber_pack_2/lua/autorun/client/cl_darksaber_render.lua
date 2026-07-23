timer.Simple(1, function()
    hook.Remove("PostPlayerDraw", "rb655_lightsaber")
    hook.Add("PostPlayerDraw", "rb655_lightsaber", renderHilt)
end)

function renderHilt(ply)
    if not GetGlobalBool("rb655_lightsaber_hiltonbelt", false) then return end
    local wep = rb655_GetLightsaber(ply) --ply:GetWeapon( "weapon_lightsaber" )
    if not IsValid(wep) or wep == ply:GetActiveWeapon() then return end

    if not IsValid(ply.LightsaberMDL) then
        ply.LightsaberMDL = ClientsideModel(wep.WorldModel, RENDERGROUP_BOTH)
    end

    if not IsValid(ply.LightsaberMDL) then return end -- We are still invalid, bail
    ply.LightsaberMDL:SetNoDraw(true)

    if not ply.LightsaberMDL:GetModel() or ply.LightsaberMDL:GetModel() ~= wep.WorldModel then
        ply.LightsaberMDL:SetModel(wep.WorldModel)
    end

    if ply.LightsaberMDL:GetModel() == "models/swtor/anzati/lightsabers/darksaber_2.mdl" then
        ply.LightsaberMDL:SetModel("models/starwars/cwa/lightsabers/darksaber.mdl")
    end

    local pos, ang = ply:GetBonePosition(0)
    ang:RotateAroundAxis(ang:Up(), 80)
    local len = ply:GetVelocity():Length()

    if ply:GetVelocity():Distance(ply:GetForward() * len) < ply:GetVelocity():Distance(ply:GetForward() * -len) then
        ang:RotateAroundAxis(ang:Right(), math.min(ply:GetVelocity():Length() / 8, 55) - 5) -- Forward
    else
        ang:RotateAroundAxis(ang:Right(), -math.min(ply:GetVelocity():Length() / 8, 55) + 5)
    end

    if ply:GetVelocity():Distance(ply:GetRight() * len) < ply:GetVelocity():Distance(ply:GetRight() * -len) then
    else --ang:RotateAroundAxis( ang:Right(), math.min( ply:GetVelocity():Length() / 8, 55 ) - 5 ) -- Right
        ang:RotateAroundAxis(ang:Up(), -math.min(ply:GetVelocity():Length() / 16, 30) + 5)
    end

    pos = pos - ang:Right() * 8 - ang:Forward() * 8

    if wep.WorldModel == "models/weapons/starwars/w_maul_saber_staff_hilt.mdl" then
        pos = pos - ang:Forward() * 5
    end

    if wep.WorldModel == "models/weapons/starwars/w_kr_hilt.mdl" then
        pos = pos + ang:Forward() * 5
    end

    ang:RotateAroundAxis(ang:Forward(), 90)
    ply.LightsaberMDL:SetPos(pos)
    ply.LightsaberMDL:SetAngles(ang)
    ply.LightsaberMDL:DrawModel()
end