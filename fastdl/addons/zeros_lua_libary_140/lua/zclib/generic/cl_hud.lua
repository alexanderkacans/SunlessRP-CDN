if SERVER then return end
zclib = zclib or {}
zclib.HUD = zclib.HUD or {}

// Returns the angles which makes the hud look at the players view pos
function zclib.HUD.GetLookAngles()
    local ang = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)
    if LocalPlayer():InVehicle() then
        local veh = LocalPlayer():GetVehicle()
        if IsValid(veh) then
            local _, vang = veh:GetVehicleViewPosition(0)
            ang = Angle(0, vang.y - 90, 90)
        end
    end
    return ang
end
