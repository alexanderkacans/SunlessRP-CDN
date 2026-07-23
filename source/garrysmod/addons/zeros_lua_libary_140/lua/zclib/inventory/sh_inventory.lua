zclib = zclib or {}
zclib.Inventory = zclib.Inventory or {}

zclib.InventoryCache = zclib.InventoryCache or {}
/*

    This inventory system does not get saved and is only used to temporarly store items

*/

function zclib.Inventory.Get(ent)
    //zclib.Debug("zclib.Inventory.Get")
    if not IsValid(ent) then return {} end
    return ent.zclib_inv or zclib.InventoryCache[ent:EntIndex()] or {}
end

function zclib.Inventory.CanPickup(class)

    // Does this entity class have a ItemDefinition?
    local allowed_item = zclib.ItemDefinition.IsAllowed(class)

    // Is this entity class in our allowed list?
    for _, allowed in ipairs(zclib.config.Inventory.AllowedItems) do
        if (class:find(allowed)) then
            allowed_item = true
        end
    end

    // Is this entity class banned for pickup?
    for _, banned in ipairs(zclib.config.Inventory.BannedItems) do
        if (class:find(banned)) then
            allowed_item = false
        end
    end

    return allowed_item == true
end

function zclib.Inventory.GetSlotData(ent,slot_id)
    //zclib.Debug("zclib.Inventory.GetSlotData")
    if slot_id == nil then return end
    if not IsValid(ent) then return end
    local inv = zclib.Inventory.Get(ent)
    return inv[slot_id]
end

function zclib.Inventory.SlotIsEmpty(ent,slot_id)
    local slot_data = zclib.Inventory.GetSlotData(ent,slot_id)
    if slot_data == nil then return true end
    return table.IsEmpty(slot_data)
end

function zclib.Inventory.GetAmount(ent,slot_id)
    local slot_data = zclib.Inventory.GetSlotData(ent,slot_id)
    if zclib.Inventory.SlotIsEmpty(ent,slot_id) then return 1 end
    return slot_data.Amount or 1
end

// Returns the first SlotID that has the specified entity class
function zclib.Inventory.FindByClass(ent,Class)
    local slot = false
    for k,v in pairs(zclib.Inventory.Get(ent)) do
        if v and v.Class == Class then
            slot = k
            break
        end
    end
    zclib.Debug("zclib.Inventory.FindItem " .. tostring(slot))
    return slot
end

// Returns the first free slot it can find
function zclib.Inventory.FindFreeSlot(ent)
    if not IsValid(ent) then return false end
    local slot = false
    for k,v in pairs(zclib.Inventory.Get(ent)) do
        if v and zclib.Inventory.SlotIsEmpty(ent,k) then
            slot = k
            break
        end
    end
    zclib.Debug("zclib.Inventory.FindFreeSlot " .. tostring(slot))
    return slot
end

function zclib.Inventory.GetEntityName(ItemEnt)
    local itemclass = ItemEnt:GetClass()

    if zclib.config.PredefinedNames[itemclass] then return zclib.config.PredefinedNames[itemclass] end

    // Is there a Item definition for that class and does it want to overwrite the name
    local DefinitionData = zclib.ItemDefinition.Get(itemclass)
    if DefinitionData and DefinitionData.Name then
        // The name can be defined as a function or as a string
        return isfunction(DefinitionData.Name) and DefinitionData.Name(ItemEnt) or DefinitionData.Name
    end

    if ItemEnt.Name then return ItemEnt.Name end

    if ItemEnt.PrintName then return ItemEnt.PrintName end

    if ItemEnt:IsWeapon() then
        local wep_list = list.Get( "Weapon" )
        if wep_list[itemclass] and wep_list[itemclass].PrintName then
            return wep_list[itemclass].PrintName
        end
    end

    return itemclass
end

/*
	Changes the entities appearance according to the defined values from the registrated item
*/
function zclib.Inventory.ApplyItemVisuals(ent,SlotData)
    if SlotData == nil then return end

    if SlotData.Health then
        ent:SetHealth(SlotData.Health)
    end

    ent:SetModel(zclib.ItemDefinition.GetModel(ent:GetClass(),SlotData))

    ent:SetSkin(zclib.ItemDefinition.GetSkin(ent:GetClass(),SlotData))

    ent:SetMaterial(zclib.ItemDefinition.GetMaterial(ent:GetClass(),SlotData))

    ent:SetColor(zclib.ItemDefinition.GetColor(ent:GetClass(),SlotData))

	for k, v in pairs(zclib.ItemDefinition.GetBodyGroups(ent:GetClass(),SlotData)) do
		ent:SetBodygroup(k, v)
	end
end


/*

    This system handels the throwing of the item

*/
// A list of entity classes which the player can throw a item to
zclib.Inventory.ThrowTargets = zclib.Inventory.ThrowTargets or {}
function zclib.Inventory.AddThrowTarget(class)
    zclib.Debug("zclib.Inventory.AddThrowTarget " .. class)
    zclib.Inventory.ThrowTargets[class] = true
end

function zclib.Inventory.IsThrowTarget(ent,from,SlotID)
    if zclib.Inventory.ThrowTargets[ent:GetClass()] == nil then return false end
    if ent.zclib_inv == nil then return false end

    // If the entity has a CanPickUp function then ask the entity if it wants this itemID
    if ent.CanPickUp then
        return ent:CanPickUp(from,SlotID)
    else
        return true
    end
end

function zclib.Inventory.GetThrowTime(from,to)
    local traveltime = from:Distance(to)
    traveltime = traveltime / 500
    return traveltime
end

if zclib.config.Inventory.PlayerInv then zclib.Inventory.AddThrowTarget("player") end
