if CLIENT then return end
zclib = zclib or {}
zclib.Inventory = zclib.Inventory or {}

/*

    This inventory system does not get saved and is only used to temporarly store items

*/


// Opens the specified inventory
// NOTE This is usally the players own inventory or someone elses inventory if the requester was a admin
function zclib.Inventory.Open(ent,ply)
    net.Start("zclib_player_open")
    net.WriteEntity(ent)
    net.Send(ply)
end

zclib.Hook.Add("zclib_PlayerJoined", "zclib_Inventory_setup", function(ply)
    timer.Simple(0.5, function()
        if not IsValid(ply) then return end
        // Lets give the player a inventory
        if zclib.config.Inventory.PlayerInv then
            zclib.Inventory.Setup(ply,24)
        end
    end)
end)

util.AddNetworkString("zclib_player_open")
zclib.Hook.Add("PlayerSay", "zclib_PlayerSay_inventory", function(ply,txt)
    if zclib.config.Inventory.PlayerInv and txt == "!inv" then
        zclib.Inventory.Open(ply,ply)
    end
end)

zclib.Hook.Add("FindUseEntity", "zclib_Inventory_FindUseEntity", function(ply,defaultEnt)
    if zclib.config.Inventory.PlayerInv and zclib.Player.IsAdmin(ply) and IsValid(defaultEnt) and defaultEnt:IsPlayer() and defaultEnt:Alive() and defaultEnt.zclib_inv then
        zclib.Inventory.Open(defaultEnt,ply)
    end
end)

// Detect if the player wants to open the inventory or collect a entity
local ComboStart
zclib.Hook.Add("PlayerButtonDown", "zclib_PlayerButtonDown_inventory", function(ply,key)
    if zclib.config.Inventory.PlayerInv then
        if key  == KEY_I then
            zclib.Inventory.Open(ply,ply)
        elseif key == KEY_LALT then
            ComboStart = CurTime() + 1
        elseif key == KEY_E and ComboStart and ComboStart > CurTime() then
            local ent = ply:GetEyeTrace().Entity
            if IsValid(ent) and zclib.Inventory.CanPickup(ent:GetClass()) then
                zclib.Inventory.PickUpEntity(ply, ent,{},ply)
            end
        end
    end
end)

// Block the PlayerUse hook if we try to collect a entity
zclib.Hook.Add("PlayerUse", "zclib_PlayerUse_inventory", function(ply,ent)
    if ComboStart and ComboStart > CurTime() then return false end
end)

// TODO Once a player dies we should place all his items in a bag which despawns after 5 minutes
/*
zclib.Hook.Add("PlayerDeath", "zclib_PPlayerDeath_inventory", function(victim)
    if victim and victim.zclib_inv and zclib.config.Inventory.DropOnDeath then
    end
end)
*/

function zclib.Inventory.Setup(ent,size)
    zclib.Debug("zclib.Inventory.Setup")
    ent.zclib_inv = {}
    for i = 1, size do ent.zclib_inv[i] = {} end

    timer.Simple(0.1,function()
         zclib.Inventory.Synch(ent)
    end)
end

function zclib.Inventory.SetSlotData(ent, SlotID,SlotData)
    ent.zclib_inv[SlotID] = table.Copy(SlotData)
end

function zclib.Inventory.GetItemDataFromEntity(ent)
    local EntData = duplicator.CopyEntTable( ent )
    if EntData == nil then return end

    local ItemClass = ent:GetClass()

    // If this Entity class has a ItemDefinition then lets get its overwrite values instead of the entities current Visual Vars
    local DefinitionData = zclib.ItemDefinition.Get(ItemClass)

    local ItemData = {
        // Basic
        Class = ItemClass,
        Name = zclib.Inventory.GetEntityName(ent),
        Amount = zclib.ItemDefinition.GetAmount(ItemClass,ent),

        // CustomData
        Data = zclib.ItemDefinition.GetData(ItemClass,ent),

        // Object info
        IsWeapon = DefinitionData and DefinitionData.IsWeapon or ent:IsWeapon(),
        Health = ent:Health(),
        MaxHealth = ent:GetMaxHealth(),

        // Visuals
        Model = DefinitionData and DefinitionData.Model or ent:GetModel(),
        Skin = DefinitionData and DefinitionData.Skin or ent:GetSkin(),
        BodyG = DefinitionData and DefinitionData.BodyG or EntData.BodyG,
        Color = DefinitionData and DefinitionData.Color or ent:GetColor(),
        Material = DefinitionData and DefinitionData.Material or ent:GetMaterial(),
    }

    // Adds a default price value here
    ItemData.Price = zclib.ItemDefinition.GetPrice(ItemClass,ItemData)

    return ItemData
end

function zclib.Inventory.GetItemDataFromClass(class)
    if zclib.ItemDefinition.IsObject(class) then
        local ItemEnt = ents.Create(class)

        if IsValid(ItemEnt) then
            ItemEnt:Spawn()
            ItemEnt:Activate()
            SafeRemoveEntityDelayed(ItemEnt,0.1)
            return zclib.Inventory.GetItemDataFromEntity(ItemEnt)
        end
    else
        local DefinitionData = zclib.ItemDefinition.Get(class)

        local ItemData = {
            Class = class,
            Name = DefinitionData.Name,
            Amount = 1
        }

        return ItemData
    end
end

// Catches the Entity ItemID and adds its to the Inventory
function zclib.Inventory.PickUpEntity(ent, ItemEnt,AppendData,ply)
    if zclib.Entity.GettingRemoved(ItemEnt) then return end

    if zclib.Inventory.CanPickup(ItemEnt:GetClass()) == false then
        if IsValid(ply) then zclib.Notify(ply, "This entity is blacklisted!", 1) end
        return false
    end
    zclib.Debug("zclib.Inventory.PickUpEntity " .. tostring(ItemEnt))

    // Constructs the ItemData from the entity
    local ItemData = zclib.Inventory.GetItemDataFromEntity(ItemEnt)

    // Lets add any extra data
    if AppendData then table.Merge(ItemData,AppendData) end

    if zclib.Inventory.Give(ent, ItemData,ply) then

        // If the entity we are picking up has a inventory then lets give it every item it has
        if ItemEnt.zclib_inv then
            for k,v in pairs(zclib.Inventory.Get(ItemEnt)) do
                if v == nil then continue end
                if table.IsEmpty(v) then continue end
                zclib.Inventory.Give(ent, v)
            end
        end

        zclib.Entity.SafeRemove(ItemEnt)
        return true
    else
        return false
    end
end

function zclib.Inventory.GiveClass(ent, class)
    zclib.Inventory.Give(ent, zclib.Inventory.GetItemDataFromClass(class))
end

// Adds the given ItemData to the inventory
function zclib.Inventory.Give(ent, ItemData,ply)
    //zclib.Debug("zclib.Inventory.Give " .. ItemID)

    zclib.Sound.EmitFromEntity("inv_add", ent)

    // Make sure we precache the model first
    if ItemData.Model then util.PrecacheModel(ItemData.Model) end


    // If this Item has a Amount Cap aka is Stackable then lets search for any item of the same class which has room for more
    local StackLimit = zclib.ItemDefinition.GetStackLimit(ItemData.Class,ItemData)
    local RestAmount = ItemData.Amount
    if StackLimit then
        for k,v in pairs(zclib.Inventory.Get(ent)) do
            // If anything is nil then skip
            if v == nil or v.Class == nil or ItemData.Class == nil then continue end

            // If the slot is empty then we cant compare it
            if table.IsEmpty(v) then continue end

            // If the Item classes dont match then skip
            if zclib.ItemDefinition.Compare(v, ItemData) == false then continue end

            if v.Amount >= StackLimit then continue end

            local Old_AmountAtSlot = v.Amount
            local New_AmountAtSlot = math.Clamp(Old_AmountAtSlot + RestAmount, 0, StackLimit)

            local diff = New_AmountAtSlot - Old_AmountAtSlot
            RestAmount = math.Clamp(RestAmount - diff,0,1000)

            v.Amount = New_AmountAtSlot
        end
    end

    // If we still have some amount left then create a new item
    if RestAmount <= 0 then
        zclib.Inventory.Synch(ent)
        return true
    end
    ItemData.Amount = RestAmount

    local FreeSlot = zclib.Inventory.FindFreeSlot(ent)
    if FreeSlot then

        ent.zclib_inv[FreeSlot] = ItemData
        zclib.Inventory.Synch(ent)
        // Created new item
        return true
    else
        // Could not find a free slot
        if IsValid(ply) then zclib.Notify(ply, "Inventory is full!", 1) end
        return false
    end
end

function zclib.Inventory.TakeOne(ent,slot_id)
    local Data = zclib.Inventory.GetSlotData(ent,slot_id)
    Data.Amount = (Data.Amount or 1) - 1
    if Data.Amount <= 0 then zclib.Inventory.ClearSlot(ent, slot_id) end
end

// Clear the inventory slot
function zclib.Inventory.ClearSlot(ent, SlotID)
    zclib.Debug("zclib.Inventory.ClearSlot " .. SlotID)
    ent.zclib_inv[SlotID] = {}
    zclib.Inventory.Synch(ent)
    return true
end

function zclib.Inventory.CanInteract(ent, ply)
    if ply == ent then return true end
    if zclib.Player.IsOwner(ply, ent) then return true end
	if ent.IsPublicEntity then return true end
    //if zclib.Player.IsAdmin(ply) then return true end
    zclib.Notify(ply, "You dont own this!", 1)
    return false
end

////////////////////////////////////////////
////////////// DRAG / DROP /////////////////
////////////////////////////////////////////
// Switches the content from one slot to another
util.AddNetworkString("zclib_Inventory_Drag")
net.Receive("zclib_Inventory_Drag", function(len, ply)
    zclib.Debug("zclib_Inventory_Drag len: " .. len)
    if not IsValid(ply) then return end
    if zclib.Player.Timeout("default", ply) then return end

    local DraggedEnt = net.ReadEntity()
    local ReceiverEnt = net.ReadEntity()

    local DraggedSlot = net.ReadInt(10)
    local ReceiverSlot = net.ReadInt(10)

    if not IsValid(DraggedEnt) then return end
    if not IsValid(ReceiverEnt) then return end

    if DraggedSlot == nil then return end
    if ReceiverSlot == nil then return end

    if zclib.util.InDistance(DraggedEnt:GetPos(), ply:GetPos(), 500) == false then return end
    if zclib.util.InDistance(ReceiverEnt:GetPos(), ply:GetPos(), 500) == false then return end

    if zclib.Inventory.CanInteract(DraggedEnt, ply) == false then return end
    if zclib.Inventory.CanInteract(ReceiverEnt, ply) == false then return end

    local DraggedData = zclib.Inventory.GetSlotData(DraggedEnt,DraggedSlot)
    local ReceiverData = zclib.Inventory.GetSlotData(ReceiverEnt,ReceiverSlot)

    // Can be used to perform some other action when one item gets droped on another one
    local result01 = hook.Run("zclib_Inventory_OnDragDrop",ply,DraggedEnt,ReceiverEnt,DraggedData,ReceiverData)
    if result01 then return end

    // Can the item be used on the reciever item
    // Examble: A hammer can be used on a egg to crack it
    // The Dragged Item will not be removed or changed
    // The Receiver Item will be changed or removed
    local ModifiedReceiverData , RemoveDraggedItem = hook.Run("zclib_Inventory_DragDrop_CanUse",ply,DraggedEnt,ReceiverEnt,DraggedData,ReceiverData)
    if ModifiedReceiverData then
        // If the item got used up then remove it
        if RemoveDraggedItem then zclib.Inventory.ClearSlot(DraggedEnt, DraggedSlot) end

        // Overwrite the existing Receiver Data with the modified one
        zclib.Inventory.SetSlotData(ReceiverEnt, ReceiverSlot, ModifiedReceiverData)

        // Send update to clients for this entity
        zclib.Inventory.Synch(DraggedEnt)
        zclib.Inventory.Synch(ReceiverEnt)
        return
    end

    // Remove DragItem, Overwrite ReceiverItem
    local ResultData = hook.Run("zclib_Inventory_DragDrop_CanCombine",ply,DraggedEnt,ReceiverEnt,DraggedData,ReceiverData)
    if ResultData then
        // Remove the dragged item
        zclib.Inventory.ClearSlot(DraggedEnt, DraggedSlot)

        // Change the receiver data to the result
        zclib.Inventory.SetSlotData(ReceiverEnt, ReceiverSlot, ResultData)

        // Send update to clients for this entity
        zclib.Inventory.Synch(DraggedEnt)
        zclib.Inventory.Synch(ReceiverEnt)
        return
    end

    // Switch the draged item data with the receiver item data
    zclib.Inventory.SetSlotData(DraggedEnt, DraggedSlot,ReceiverData)
    zclib.Inventory.SetSlotData(ReceiverEnt, ReceiverSlot,DraggedData)

    // Send update to clients for this entity
    zclib.Inventory.Synch(DraggedEnt)
    zclib.Inventory.Synch(ReceiverEnt)
end)



////////////////////////////////////////////
//////// SYNCHRONIZE SERVER / CLIENT ///////
////////////////////////////////////////////
// Synchronizes the inventory to one or all players
util.AddNetworkString("zclib_Inventory_Sync")
function zclib.Inventory.Synch(ent)
    zclib.Debug("zclib.Inventory.Synch")
    if not IsValid(ent) then return end

    local e_String = util.TableToJSON(zclib.Inventory.Get(ent))
    local e_Compressed = util.Compress(e_String)

    net.Start("zclib_Inventory_Sync")
    net.WriteUInt(#e_Compressed, 16)
    net.WriteData(e_Compressed, #e_Compressed)
    net.WriteEntity(ent)
    net.WriteUInt(ent:EntIndex(),16)
    net.Broadcast()
end

function zclib.Inventory.SynchForPlayer(ent,ply)
    zclib.Debug("zclib.Inventory.Synch")
    if not IsValid(ent) then return end

    local e_String = util.TableToJSON(zclib.Inventory.Get(ent))
    local e_Compressed = util.Compress(e_String)
    net.Start("zclib_Inventory_Sync")
    net.WriteUInt(#e_Compressed, 16)
    net.WriteData(e_Compressed, #e_Compressed)
    net.WriteEntity(ent)
    net.WriteUInt(ent:EntIndex(),16)
    net.Send(ply)
end



////////////////////////////////////////////
///////////// SLOT OPTIONS /////////////////
////////////////////////////////////////////
function zclib.Inventory.SpawnItem(SlotData,pos,ply)

    local ent = ents.Create(SlotData.Class)
    if not IsValid(ent) then return end

    // NOTE This is requiered for scaling to work correct
    ent.Model = SlotData.Model

    // Assign any custom data
    zclib.ItemDefinition.SetData(ent,SlotData)

    ent:SetModel(SlotData.Model)
    ent:SetPos(pos)
    ent:Spawn()
    ent:Activate()

    zclib.Inventory.ApplyItemVisuals(ent,SlotData)

    if IsValid(ply) then
        zclib.Player.SetOwner(ent, ply)
    end

    return ent
end

// Drops the item on the floor
util.AddNetworkString("zclib_Inventory_DropToFloor")
net.Receive("zclib_Inventory_DropToFloor", function(len,ply)
    zclib.Debug_Net("zclib_Inventory_DropToFloor", len)

    if zclib.Player.Timeout(nil,ply) == true then return end

    local from = net.ReadEntity()
    local SlotID = net.ReadUInt(16)

    if not IsValid(from) then return end

    if zclib.util.InDistance(from:GetPos(), ply:GetPos(), 500) == false then return end

    // Check if the from Entity is owned by the player who send the netMessage
    if zclib.Inventory.CanInteract(from, ply) == false then
        return
    end

    // Is there even is a item on the start entity
    local SlotData = zclib.Inventory.GetSlotData(from,SlotID)
    if SlotData.Class == nil then return end

    // Prevents the player from droping this Item on the ground
    local ItemDefinition = zclib.ItemDefinition.Get(SlotData.Class)
    if ItemDefinition and ItemDefinition.PreventDrop then return end

    // If the Item has no model and we wanna place it on the floor in the world then stop
    if SlotData.Model == nil then
        zclib.Notify(ply, "You cant place this on the floor!", 1)
        return
    end

    // Remove it
    zclib.Inventory.ClearSlot(from, SlotID)

    local spawnPos = ply:GetPos() + Vector(0,0,50) + ply:GetForward() * 100

    // Drop the item instead
    local item_ent = zclib.Inventory.SpawnItem(SlotData,spawnPos,ply)
    if not IsValid(item_ent) then return end
    item_ent:Activate()
    item_ent:PhysWake()
    item_ent:DropToFloor()
    item_ent:SetPos(spawnPos)

    hook.Run("zclib_Inventory_ItemDrop",spawnPos,SlotID,SlotData,item_ent)
end)

// Throws the item from one inventory to another or on the floor
local throw_distance = 1000
util.AddNetworkString("zclib_Inventory_Throw")
net.Receive("zclib_Inventory_Throw", function(len,ply)
    zclib.Debug_Net("zclib_Inventory_Throw", len)

    if zclib.Player.Timeout(nil,ply) == true then return end

    local from = net.ReadEntity()
    local target = net.ReadEntity()
    local target_pos = net.ReadVector()
    local SlotID = net.ReadUInt(16)

    if not IsValid(from) then return end
    //if not IsValid(target) then return end

    if zclib.util.InDistance(from:GetPos(), ply:GetPos(), throw_distance) == false then return end

    // Check if the from Entity is owned by the player who send the netMessage
    if zclib.Inventory.CanInteract(from, ply) == false then
        return
    end

    // Is there even is a item on the start entity
    local SlotData = zclib.Inventory.GetSlotData(from,SlotID)
    if SlotData.Class == nil then return end

    // Prevents the player from droping this Item on the ground
    local ItemDefinition = zclib.ItemDefinition.Get(SlotData.Class)
    if ItemDefinition and ItemDefinition.PreventDrop then return end

    // If the Item has no model and we wanna place it on the floor in the world then stop
    if SlotData.Model == nil and not IsValid(target) then
        zclib.Notify(ply, "You cant place this on the floor!", 1)
        return
    end

    if IsValid(target) then
        target_pos = target:GetPos()
    else
        target_pos = target_pos + Vector(0,0,25)
    end

    if zclib.util.InDistance(target_pos, ply:GetPos(), 500) == false then
        return
    end

    // Remove it
    zclib.Inventory.ClearSlot(from, SlotID)

    // A small delay should prevent exploits which comes from code being run at the same time
    local traveltime = zclib.Inventory.GetThrowTime(from:GetPos(),target_pos)
    timer.Simple(traveltime,function()

        local slot = zclib.Inventory.FindFreeSlot(target)

        if slot then
            zclib.Inventory.SetSlotData(target, slot,SlotData)
            zclib.Inventory.Synch(target)
            hook.Run("zclib_Inventory_ItemThrow",from,target or target_pos,slot,SlotData)
        else

            // Drop the item instead
            local item_ent = zclib.Inventory.SpawnItem(SlotData,target_pos,ply)
            if not IsValid(item_ent) then return end

            item_ent:Activate()
            item_ent:PhysWake()
            item_ent:DropToFloor()

            hook.Run("zclib_Inventory_ItemDrop",target or target_pos,SlotID,SlotData,item_ent)
        end
    end)
end)

// Destroyes the specified item
util.AddNetworkString("zclib_Inventory_Destroy")
net.Receive("zclib_Inventory_Destroy", function(len, ply)
    zclib.Debug("zclib_Inventory_Destroy len: " .. len)
    if not IsValid(ply) then return end
    if zclib.Player.Timeout("default", ply) then return end

    local ent = net.ReadEntity()
    local slotID = net.ReadInt(10)

    if not IsValid(ent) then return end
    if slotID == nil then return end
    if zclib.util.InDistance(ent:GetPos(), ply:GetPos(), 500) == false then return end

    // Check if the from Entity is owned by the player who send the netMessage
    if zclib.Inventory.CanInteract(ent, ply) == false then
        return
    end

    local SlotData = zclib.Inventory.GetSlotData(ent,slotID)
    if SlotData == nil then return end
    if SlotData.Class == nil then return end

    local ItemData = zclib.ItemDefinition.Get(SlotData.Class)
    if ItemData and ItemData.OnDestroy then
        ItemData.OnDestroy(ply)
    end

    zclib.Inventory.ClearSlot(ent, slotID)
end)

// Uses the specified item
util.AddNetworkString("zclib_Inventory_Use")
net.Receive("zclib_Inventory_Use", function(len, ply)
    zclib.Debug("zclib_Inventory_Use len: " .. len)
    if not IsValid(ply) then return end
    if zclib.Player.Timeout("default", ply) then return end

    local ent = net.ReadEntity()
    local slotID = net.ReadInt(10)

    if not IsValid(ent) then return end
    if slotID == nil then return end
    if zclib.util.InDistance(ent:GetPos(), ply:GetPos(), 500) == false then return end

    // Check if the from Entity is owned by the player who send the netMessage
    if zclib.Inventory.CanInteract(ent, ply) == false then
        return
    end

    local SlotData = zclib.Inventory.GetSlotData(ent,slotID)
    if SlotData == nil then return end
    if SlotData.Class == nil then return end

    local ItemData = zclib.ItemDefinition.Get(SlotData.Class)
    if ItemData then

        if ItemData.OnUse then
            ItemData.OnUse(ply)
        end

        if SlotData.Model or ItemData.Model then
            local item_ent = zclib.Inventory.SpawnItem(SlotData,ply:GetPos() + Vector(0,50,10),ply)
            if not IsValid(item_ent) then return end
            item_ent:Use(ply, ply, USE_ON, 0)
        end
    end

    zclib.Inventory.ClearSlot(ent, slotID)
end)

// Equipts the specified item
util.AddNetworkString("zclib_Inventory_Equipt")
net.Receive("zclib_Inventory_Equipt", function(len, ply)
    zclib.Debug("zclib_Inventory_Equipt len: " .. len)
    if not IsValid(ply) then return end
    if zclib.Player.Timeout("default", ply) then return end

    local ent = net.ReadEntity()
    local slotID = net.ReadInt(10)

    if not IsValid(ent) then return end
    if slotID == nil then return end
    if zclib.util.InDistance(ent:GetPos(), ply:GetPos(), 500) == false then return end

    // Check if the from Entity is owned by the player who send the netMessage
    if zclib.Inventory.CanInteract(ent, ply) == false then
        return
    end

    local SlotData = zclib.Inventory.GetSlotData(ent,slotID)
    if SlotData == nil then return end
    if SlotData.Class == nil then return end

    // Give the player that weapon
    ply:Give( SlotData.Class )

    zclib.Inventory.ClearSlot(ent, slotID)
end)

// Takes a item from a inventory and places it in the players inventory
util.AddNetworkString("zclib_Inventory_Collect")
net.Receive("zclib_Inventory_Collect", function(len,ply)
    zclib.Debug_Net("zclib_Inventory_Collect", len)

    if zclib.Player.Timeout(nil,ply) == true then return end

    local from = net.ReadEntity()
    local SlotID = net.ReadUInt(16)

    if not IsValid(from) then return end

    if zclib.util.InDistance(from:GetPos(), ply:GetPos(), throw_distance) == false then return end

    // Check if the from Entity is owned by the player who send the netMessage
    if zclib.Inventory.CanInteract(from, ply) == false then
        return
    end

    // Is there even is a item on the start entity
    local SlotData = zclib.Inventory.GetSlotData(from,SlotID)
    if SlotData.Class == nil then return end

    // Prevents the player from droping this Item on the ground
    local ItemDefinition = zclib.ItemDefinition.Get(SlotData.Class)
    if ItemDefinition and ItemDefinition.PreventDrop then return end

    local slot = zclib.Inventory.FindFreeSlot(ply)

    if slot == false then
        zclib.Notify(ply, "No free slot found!", 1)
        return
    end

    zclib.Sound.EmitFromPosition(ply:GetPos(),"inv_add")

    // Remove it
    zclib.Inventory.ClearSlot(from, SlotID)

    // Place it in the player inventory
    zclib.Inventory.SetSlotData(ply, slot,SlotData)
    zclib.Inventory.Synch(ply)
end)

// Performs a custom function on the specified slot item
util.AddNetworkString("zclib_Inventory_CustomOption")
net.Receive("zclib_Inventory_CustomOption", function(len, ply)
    zclib.Debug("zclib_Inventory_CustomOption len: " .. len)
    if not IsValid(ply) then return end
    if zclib.Player.Timeout("default", ply) then return end

    local ent = net.ReadEntity()
    local slotID = net.ReadInt(10)
	local SlotOption = net.ReadString()

	if not SlotOption then return end
    if not IsValid(ent) then return end
    if not slotID then return end
    if zclib.util.InDistance(ent:GetPos(), ply:GetPos(), 500) == false then return end

    // Check if the from Entity is owned by the player who send the netMessage
    if zclib.Inventory.CanInteract(ent, ply) == false then
        return
    end

    local SlotData = zclib.Inventory.GetSlotData(ent,slotID)
    if SlotData == nil then return end
    if SlotData.Class == nil then return end

	local ItemDefinition = zclib.ItemDefinition.Get(SlotData.Class)
	if not ItemDefinition then return end
	if not ItemDefinition.CustomOptions then return end

	local Options = ItemDefinition.CustomOptions(SlotData)
	if not Options then return end

	local Option = Options[SlotOption]
	if not Option then return end
	if not Option.func then return end

	local RemoveItem = Option.func(ply,ent,slotID)
	if RemoveItem then
    	zclib.Inventory.ClearSlot(ent, slotID)
	end
end)


local function AddGiveCommand(list, command, default, OnCall)
    local function AutoComplete(cmd, stringargs)
        local tbl = {}
        stringargs = string.Trim(stringargs)
        stringargs = string.lower(stringargs)

        for k, v in pairs(list) do
            if string.find(string.lower(v.Class), stringargs) then
                table.insert(tbl, command .. " " .. v.Class)
            end
        end

        return tbl
    end

    local function SpawnFunc(ply, cmd, args)
        if zclib.Player.IsAdmin(ply) then
            local class = args[1]
            if class == nil then return end

            if class == nil then
                class = default
            end

            pcall(OnCall, class, ply)
        end
    end

    concommand.Add(command, SpawnFunc, AutoComplete)
end

AddGiveCommand(zclib.ItemDefinition.List, "zclib_inventory_giveself", "item_healthkit", function(class, ply)
    zclib.Inventory.GiveClass(ply, class)
end)

AddGiveCommand(zclib.ItemDefinition.List, "zclib_inventory_give", "item_healthkit", function(class, ply)
    local tr = ply:GetEyeTrace()
    if tr == nil or not IsValid(tr.Entity) then return end
    if tr.Entity.zclib_inv == nil then return end

    zclib.Inventory.GiveClass(tr.Entity, class)
end)
