local translatekeypress = {
    [8192] = {
        PrettyPrint = "+reload"
    },
    [32] = {
        PrettyPrint = "+use"
    },
}

-- BOOLEAN, basically just prints the key pressed on screen!
local debugprint = false

hook.Add("KeyPress", "anz.Umbrella.Sequences", function(ply, key)
    local wep = ply:GetActiveWeapon()
    if not wep.IsLightsaber then return end
    if wep:GetModel() ~= "models/lightsabers/expgamer/expgamer_umbrella.mdl" then return end

    if debugprint then
        ply:PrintMessage(HUD_PRINTCENTER, translatekeypress[key].PrettyPrint or "")
    end

    if key == IN_USE then
        if not wep:GetEnabled() then return end

        -- spin to idle open
        if wep:GetSequence() == 1 then
            wep:ResetSequence("idle")
            wep:ResetSequenceInfo()
            wep:SetCycle(0)
            wep:SetPlaybackRate(1)
        elseif wep:GetSequence() == 0 then
            -- idle to spin
            wep:ResetSequence("spin")
            wep:ResetSequenceInfo()
            wep:SetCycle(0)
            wep:SetPlaybackRate(1)
        end
    elseif key == IN_RELOAD then
        if wep:GetEnabled() then
            wep:SetSequence("open")
        else
            wep:SetSequence("close")

            timer.Simple(0.5, function()
                wep:ResetSequence("idle")
                wep:ResetSequenceInfo()
                wep:SetCycle(0)
                wep:SetPlaybackRate(1)
            end)
        end
    end
end)