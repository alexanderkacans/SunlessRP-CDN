CreateConVar("dynamic_itemdrops_enable", "1", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED))
CreateConVar("dynamic_itemdrops_disable_default", "1", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED))
CreateConVar("dynamic_itemdrops_realistic", "0", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED))
CreateConVar("dynamic_itemdrops_lifetime", "60", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED))
CreateConVar("dynamic_itemdrops_use", "0", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED))
local cvarAmmo = CreateConVar("dynamic_itemdrops_ammo", "1", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED))
local cvarHealth = CreateConVar("dynamic_itemdrops_health", "1", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED))
local cvarArmor = CreateConVar("dynamic_itemdrops_armor", "1", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED))
local cvarAmmoMult = CreateConVar("dynamic_itemdrops_ammomult", "1", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED))
local cvarHealthMult = CreateConVar("dynamic_itemdrops_healthmult", "1", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED))
local cvarArmorMult = CreateConVar("dynamic_itemdrops_armormult", "1", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED))
local cvarNPC = CreateConVar("dynamic_itemdrops_npcs", "1", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED))
local cvarNextbot = CreateConVar("dynamic_itemdrops_nextbots", "1", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED))
local cvarPlayer = CreateConVar("dynamic_itemdrops_players", "1", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED))

---------------------------------------------------------------------------------------------------------------------=#
if CLIENT then
    hook.Add("PopulateToolMenu", "PopulateToolMenu_DynamicNPCDrops", function() spawnmenu.AddToolMenuOption("Options", "AI", "Item Drops", "Item Drops", "", "", function( panel )

        -- Enable option
        panel:CheckBox("Enable", "dynamic_itemdrops_enable")
        panel:Help("Enable addon.")
        -----------------------------=#

        -- Drop types
        panel:CheckBox("Health", "dynamic_itemdrops_health")
        panel:Help("Drop health.")

        panel:CheckBox("Armor", "dynamic_itemdrops_armor")
        panel:Help("Drop armor.")

        panel:CheckBox("Ammo", "dynamic_itemdrops_ammo")
        panel:Help("Drop ammo.")
        -----------------------------=#

        -- Targets that should drop
        panel:CheckBox("NPCs", "dynamic_itemdrops_npcs")
        panel:Help("NPCs drop items.")

        panel:CheckBox("Nextbots", "dynamic_itemdrops_nextbots")
        panel:Help("Nextbots drop items.")

        panel:CheckBox("Players", "dynamic_itemdrops_players")
        panel:Help("Players drop items.")
        -----------------------------=#

        -- General options
        panel:CheckBox("Realistic Drops", "dynamic_itemdrops_realistic")
        panel:Help("More belivable drops, for example, only players and combines drop suit batteries, and targets only drop ammo if their weapons share the ammotype.")

        panel:CheckBox("Disable Default Drops", "dynamic_itemdrops_disable_default")
        panel:Help("Disable some default drops, and VJ Base item drops, for the full experience of the addon.")

        panel:CheckBox("Use Key", "dynamic_itemdrops_use")
        panel:Help("Drops can only be picked up with the use key.")
        -----------------------------=#

        -- Multipliers
        local min, max, dec = 0, 5, 2
        panel:NumSlider("Health Drop Multiplier", "dynamic_itemdrops_healthmult", min, max, dec)
        panel:Help("Multiply amount of health that health drops give by this amount.")

        panel:NumSlider("Armor Drop Multiplier", "dynamic_itemdrops_armormult", min, max, dec)
        panel:Help("Multiply amount of armor that armor drops give by this amount.")

        panel:NumSlider("Ammo Drop Multiplier", "dynamic_itemdrops_ammomult", min, max, dec)
        panel:Help("Multiply amount of ammo that ammo drops give by this amount.")
        -----------------------------=#

        -- Life time
        panel:NumSlider("Life Time", "dynamic_itemdrops_lifetime", 0, 3600, 0)
        panel:Help("Time until drop is removed, 0 = Never.")
        -----------------------------=#

        -- Cleanup button
        local cleanupB = panel:Button("Clean Up Item Drops")
        function cleanupB:DoClick()
            if !LocalPlayer():IsSuperAdmin() then return end
            net.Start("CleanUpDynamicItemDrops")
            net.SendToServer()
        end

    end) end)
end
---------------------------------------------------------------------------------------------------------------------=#
if SERVER then
    hook.Add("OnEntityCreated", "RemoveNPCDefaultDrops", function( ent )

        if !GetConVar("dynamic_itemdrops_enable"):GetBool() then return end
        if !GetConVar("dynamic_itemdrops_disable_default"):GetBool() then return end

        timer.Simple(0, function()

            if !(IsValid(ent) && ent:IsNPC()) then return end

            local sf = ent:GetKeyValues().spawnflags
            sf = bit.band(sf, bit.bnot(8)) -- Remove spawn flag 8, which is to drop a health vial
            if ent:GetClass() == "npc_combine_s" then
                -- Remove combine ball drops from combines
                sf = bit.bor(sf, 262144)  
            end
            ent:SetKeyValue("spawnflags", sf)

            ent.ItemDropsOnDeath_EntityList = {} -- Clear VJ Base drops
        end)

    end)
    --------------------------------------------------------------------=#
    local function setPlayerAttackedNPC( ply, npc )
        ply.DynamicNPCDrops_AttackedNPC = npc
    end
    --------------------------------------------------------------------=#
    hook.Add("EntityTakeDamage", "PostEntityTakeDamage_DynamicNPCDrops", function( ent, dmg )

        -- "PreEntityTakeDamage"

        if !GetConVar("dynamic_itemdrops_enable"):GetBool() then return end
        if !(IsValid(ent)) then return end

        local at = dmg:GetAttacker()
        if IsValid(at) && at:IsPlayer() && (ent:IsNPC() or ent:IsNextBot() or ent:IsPlayer()) then

            -- Track what NPC the player is attacking
            setPlayerAttackedNPC(at, ent)

            -- Automatically set that NPC to drop some ammo after attacked
            local wep = at:GetActiveWeapon()
            if IsValid(wep) && wep.GetMaxClip1 && wep:GetMaxClip1() >= 5 then

                local ammoType = wep.GetPrimaryAmmoType && game.GetAmmoName(wep:GetPrimaryAmmoType())

                if !ent.AmmoToDrop then ent.AmmoToDrop = {} end

                if ammoType && ent.AmmoToDrop && !ent.AmmoToDrop[ammoType] then
                    ent.AmmoToDrop[ammoType] = math.ceil(wep:GetMaxClip1()*0.25)
                end
            end

        end

        if ent:IsPlayer() && (at:IsNPC() or at:IsNextBot() or at:IsPlayer()) && !IsValid(ent.DynamicNPCDrops_AttackedNPC) then
            -- Track what NPC the player is attacking, by checking which player the NPC is attacking:
            setPlayerAttackedNPC(ent, at)
        end
        
        if ent:IsPlayer() then

            -- Track player armor
            ent.DynamicNPCDrops_ArmorBefore = ent:Armor()

        end

    end)
    --------------------------------------------------------------------=#
    hook.Add("PostEntityTakeDamage", "PostEntityTakeDamage_DynamicNPCDrops", function( ply, dmg )

        if !GetConVar("dynamic_itemdrops_enable"):GetBool() then return end
        if !(IsValid(ply) && ply:IsPlayer()) then return end

        local at = dmg:GetAttacker()
        if IsValid(at) && (at:IsNPC() or at:IsNextBot() or at:IsPlayer()) then

            if !at.HealthToDrop then
                at.HealthToDrop = math.ceil( dmg:GetDamage() )
            else
                at.HealthToDrop = math.ceil( at.HealthToDrop + dmg:GetDamage() )
            end

            if ply.DynamicNPCDrops_ArmorBefore then
                local armorDamage = math.Clamp( math.ceil( ply.DynamicNPCDrops_ArmorBefore - ply:Armor() ), 0, ply:GetMaxArmor())
                if armorDamage > 0 then
                    if !at.ArmorToDrop then
                        at.ArmorToDrop = math.ceil( armorDamage )
                    else
                        at.ArmorToDrop = math.ceil( at.ArmorToDrop + armorDamage )
                    end
                end
            end
        end

    end)
    --------------------------------------------------------------------=#
    hook.Add("PlayerAmmoChanged", "PostEntityTakeDamage_DynamicNPCDrops", function( ply, ammoID, oldCount, newCount )
        if !IsValid(ply) then return end
        if !ply:Alive() then return end

        local reduction = newCount < oldCount
        if !reduction then return end

        local ammoType = game.GetAmmoName(ammoID)
        local npc = ply.DynamicNPCDrops_AttackedNPC or NULL
        local npcIsDeadPlayer = npc:IsPlayer() && !npc:Alive()

        if IsValid(npc) && !npcIsDeadPlayer then

            if !npc.AmmoToDrop then npc.AmmoToDrop = {} end
            if !npc.AmmoToDrop[ammoType] then
                npc.AmmoToDrop[ammoType] = oldCount-newCount
            else
                npc.AmmoToDrop[ammoType] = npc.AmmoToDrop[ammoType] + oldCount-newCount
            end

        end
    
    end)
    --------------------------------------------------------------------=#
    local combineClasses = {
        [CLASS_COMBINE] = true,
        [CLASS_METROPOLICE] = true,
        [CLASS_SCANNER] = true,
        [CLASS_STALKER] = true,
        [CLASS_COMBINE_HUNTER] = true,
        [CLASS_MANHACK] = true,
    }
    --------------------------------------------------------------------=#
    local function VJCombine( ent )
        if !ent.VJ_NPC_Class then return false end
        for _, v in ipairs( ent.VJ_NPC_Class ) do
            if v == "CLASS_COMBINE" then return true end
        end
        return false
    end
    --------------------------------------------------------------------=#
    local function isCombine(ent)
        return (ent.Classify && combineClasses[ent:Classify()]) or VJCombine(ent)
    end
    --------------------------------------------------------------------=#
    local function realisticCheck( ent, type, isAmmoType )

        if !GetConVar("dynamic_itemdrops_realistic"):GetBool() then return true end

        -- Only human type NPCs drop health
        if !isAmmoType && (type == "health" or type == "ammo") && ent.GetHullType && ent:GetHullType()==HULL_HUMAN then
            return true
        end

        -- Only combines and players drop armor
        if !isAmmoType && type == "armor" && ( ent:IsPlayer() or isCombine(ent) ) then
            return true
        end

        -- Only drop ammo if the ent has a weapon with that ammotype
        if isAmmoType then
            for _, wep in ipairs(ent:GetWeapons()) do
                if IsValid(wep) then

                    local ammo1 = wep.GetPrimaryAmmoType && game.GetAmmoName(wep:GetPrimaryAmmoType())
                    local ammo2 = wep.GetSecondaryAmmoType && game.GetAmmoName(wep:GetSecondaryAmmoType())

                    if type==ammo1 or type==ammo2 then
                        return true
                    end

                end
            end

            -- NPCs with grenades should be able to drop those
            local cls = ent:GetClass()
            local vjGrenade = ent.HasGrenadeAttack
            if type == "Grenade" && (cls=="npc_combine_s" or cls=="npc_zombine" or vjGrenade) then
                return true
            end
        end

        return false

    end
    --------------------------------------------------------------------=#
    local function itemDrop( npc )
        if !GetConVar("dynamic_itemdrops_enable"):GetBool() then return end
        if !IsValid(npc) then return end
        if npc.HasDynDropped then return end
        if npc:IsNPC() && !cvarNPC:GetBool() then return end
        if npc:IsPlayer() && !cvarPlayer:GetBool() then return end
        if npc:IsNextBot() && !cvarNextbot:GetBool() then return end

        if !npc:IsPlayer() then
            npc.HasDynDropped = true
        end

        local drop -- Health or armor

        -- Health
        if npc.HealthToDrop && realisticCheck(npc, "health") && cvarHealth:GetBool() then
            drop = ents.Create("item_dynamic_npc_drop")

            if npc.HealthToDrop >= 25 then
                drop.Model = "models/items/healthkit.mdl"
                drop.Sound = "HealthKit.Touch"
            else
                drop.Model = "models/healthvial.mdl"
                drop.Sound = "HealthVial.Touch"
            end

            drop.HealthGive = npc.HealthToDrop*cvarHealthMult:GetFloat()
            drop:SetPos(npc:WorldSpaceCenter())
            drop:Spawn()
        end

        -- Armor
        if npc.ArmorToDrop && realisticCheck(npc, "armor") && cvarArmor:GetBool() then
            drop = ents.Create("item_dynamic_npc_drop")
            drop.Model = "models/items/battery.mdl"
            drop.Sound = "ItemBattery.Touch"
            drop.ArmorGive = npc.ArmorToDrop*cvarArmorMult:GetFloat()
            drop:SetPos(npc:WorldSpaceCenter())
            drop:Spawn()
        end

        if IsValid(drop) then
            drop:SetOwner(npc)
        end

        -- Ammo
        if npc.AmmoToDrop && cvarAmmo:GetBool() then
            for k, v in pairs(npc.AmmoToDrop) do
                if v && realisticCheck(npc, k, true) then
                    local ammoDrop = ents.Create("item_dynamic_npc_drop")
                    ammoDrop.AmmoType = k
                    ammoDrop.AmmoCount = v*cvarAmmoMult:GetFloat()
                    ammoDrop:SetPos(npc:WorldSpaceCenter())
                    ammoDrop:SetOwner(npc)
                    ammoDrop:Spawn()
                end
            end
        end

        -- For players that respawn
        npc.HealthToDrop = nil
        npc.ArmorToDrop = nil
        npc.AmmoToDrop = nil
        for _, v in ipairs(player.GetAll()) do
            if v==self then continue end
            if v.DynamicNPCDrops_AttackedNPC == npc then v.DynamicNPCDrops_AttackedNPC = nil end -- This "NPC" (player in this case) is no longer being attacked since they are dead
        end
    end
    --------------------------------------------------------------------=#
        -- Hooks for detecting deaths --

    hook.Add("OnNPCKilled", "OnNPCKilled_DynamicDrop", itemDrop)
    hook.Add("PlayerDeath", "PlayerDeath_DynamicDrop", itemDrop)

    hook.Add("EntityRemoved", "EntityRemoved_DynamicDrop", function( ent )
        if ent.GetNPCState && ent:GetNPCState()==NPC_STATE_DEAD then itemDrop(ent) end
    end)

    hook.Add("InitPostEntity", "DynamicDrop_RegisterOnNPCKilled2", function()
        local OnNPCKilled = GAMEMODE.OnNPCKilled
        function GAMEMODE:OnNPCKilled(npc, ...)
            itemDrop(npc)
            OnNPCKilled(self, npc, ...)
        end
    end)

    --------------------------------------------------------------------=#
end
---------------------------------------------------------------------------------------------------------------------=#