AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Dynamic NPC Drop"
ENT.Author = "Zippy"
ENT.Category = ""
ENT.Spawnable = false

ENT.Model = nil
ENT.Sound = nil
ENT.HealthGive = nil
ENT.ArmorGive = nil
ENT.AmmoType = nil
ENT.AmmoCount = nil
ENT.PickupRadius = 60

if !SERVER then return end

local ammoModels = {
    ["AR2"] = "models/Items/combine_rifle_cartridge01.mdl",
    ["AR2AltFire"] = "models/Items/combine_rifle_ammo01.mdl",
    ["Pistol"] = "models/Items/BoxSRounds.mdl",
    ["SMG1"] = "models/Items/BoxMRounds.mdl",
    ["357"] = "models/Items/357ammo.mdl",
    ["XBowBolt"] = "models/Items/CrossbowRounds.mdl",
    ["Buckshot"] = "models/Items/BoxBuckshot.mdl",
    ["RPG_Round"] = "models/weapons/w_missile_closed.mdl",
    ["SMG1_Grenade"] = "models/Items/AR2_Grenade.mdl",
    ["Grenade"] = "models/Items/grenadeAmmo.mdl",
    ["slam"] = "models/weapons/w_slam.mdl",
}

if !DYNAMIC_ITEM_DROP_TBL then
    DYNAMIC_ITEM_DROP_TBL = {}
end

-----------------------------------------------------------------------------------------------=#
util.AddNetworkString("CleanUpDynamicItemDrops")
net.Receive("CleanUpDynamicItemDrops", function( _, ply )

    if !ply:IsSuperAdmin() then return end
    for _, v in ipairs(DYNAMIC_ITEM_DROP_TBL) do
        v:Remove()
    end

end)
-----------------------------------------------------------------------------------------------=#
function ENT:Initialize()

    if self.Model then
        self:SetModel(self.Model)
    elseif self.AmmoType then
        self:SetModel(ammoModels[self.AmmoType] or "models/Items/BoxMRounds.mdl")
    end

    self:PhysicsInit(SOLID_VPHYSICS)
    self:GetPhysicsObject():Wake()

    self.PickedUp = false
    self.LargePickupRadiusT = CurTime()

    local lifeTime = GetConVar("dynamic_itemdrops_lifetime"):GetInt()
    if lifeTime != 0 then
        SafeRemoveEntityDelayed(self, lifeTime)
    end

    -- Register in table
    table.insert(DYNAMIC_ITEM_DROP_TBL, self)
    self:CallOnRemove("DYNAMIC_ITEM_DROP_TBL_REMOVE", function() table.RemoveByValue(DYNAMIC_ITEM_DROP_TBL, self) end)

    -- Nocollide with all other spawned items:
    for _, v in ipairs(DYNAMIC_ITEM_DROP_TBL) do
        if v == self then continue end
        constraint.NoCollide(v, self, 0, 0)
    end

    -- -- Allow players to pick up their own drops after some time
    -- timer.Simple(3, function()
    --     if IsValid(self) && IsValid(self:GetOwner()) then
    --         self:SetOwner(NULL)
    --     end
    -- end)

end
-----------------------------------------------------------------------------------------------=#
local VMANIP = file.Exists("autorun/server/sv_vmanippickup.lua", "LUA")
function ENT:CheckVManip()
    return VMANIP && GetConVar("sv_vmanip_pickups"):GetBool()
end
-----------------------------------------------------------------------------------------------=#
function ENT:CheckPickUpUseKey()
    -- Returns true if the pickup is picked up with the use key
    if GetConVar("dynamic_itemdrops_use"):GetBool() then return true end
    if self:CheckVManip() then return true end
    return false
end
-----------------------------------------------------------------------------------------------=#
function ENT:PickUp_Final()

    self.PickedUp = true

    if self.Sound then
        self:EmitSound(self.Sound)
    end

    if self:CheckVManip() then
        -- Remove with delay with vmanip pickups
        SafeRemoveEntityDelayed(self, 0.2)
    else
        self:Remove()
    end

end
-----------------------------------------------------------------------------------------------=#
function ENT:GetAmmoLimit()
    local cvarLimit = GetConVar("gmod_maxammo"):GetInt()
    if cvarLimit == 0 then
        return game.GetAmmoMax(game.GetAmmoID(self.AmmoType))
    else
        return cvarLimit
    end
end
-----------------------------------------------------------------------------------------------=#
function ENT:PickUp( ent )
    if self.PickedUp then return end
    if ent:IsValid() && ent:IsPlayer() && ent:Alive() then    
        if self.HealthGive && ent:Health() < ent:GetMaxHealth() then

            ent:SetHealth( math.Clamp(ent:Health() + self.HealthGive, 0, ent:GetMaxHealth()) )
            self:PickUp_Final()

        elseif self.ArmorGive && ent:Armor() < ent:GetMaxArmor() then

            ent:SetArmor( math.Clamp(ent:Armor() + self.ArmorGive, 0, ent:GetMaxArmor()) )
            self:PickUp_Final()


        elseif self.AmmoType && ent:GetAmmoCount(self.AmmoType) < self:GetAmmoLimit() then

            ent:GiveAmmo(self.AmmoCount, self.AmmoType)
            self:PickUp_Final()

        end
    end
end
-----------------------------------------------------------------------------------------------=#
function ENT:Use( ent )
    self:PickUp( ent )
end
-----------------------------------------------------------------------------------------------=#
function ENT:Touch( ent )
    if self:CheckPickUpUseKey() then return end
    self:PickUp( ent )
end
-----------------------------------------------------------------------------------------------=#
function ENT:Think()
    if !self:CheckPickUpUseKey() && self.LargePickupRadiusT < CurTime() then
        -- Larger pickup radius
        for _, v in ipairs(ents.FindInSphere(self:WorldSpaceCenter(), self.PickupRadius)) do self:PickUp(v) end
        self.LargePickupRadiusT = CurTime()+0.1
    end
end
-----------------------------------------------------------------------------------------------=#
