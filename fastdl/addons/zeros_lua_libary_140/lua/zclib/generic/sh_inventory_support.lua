zclib = zclib or {}
zclib.Inventory = zclib.Inventory or {}

function zclib.Inventory.GetItems(ply)
    local inv = {}
    if itemstore then
        if SERVER then
            inv = table.Copy(ply.Inventory:GetItems())
        else
            if LocalPlayer().InventoryID and itemstore.containers.Active[LocalPlayer().InventoryID] and itemstore.containers.Active[LocalPlayer().InventoryID].Items then
                inv = table.Copy(itemstore.containers.Active[LocalPlayer().InventoryID].Items)
            end
        end
    end
    return inv
end

if SERVER then
    // Trys to pickup the specified enttiy in to the players Inventory, returns false otherwhise
    function zclib.Inventory.Pickup(ply,ent,class)
        local success = false
        if itemstore then
            local item = itemstore.Item(class)
            if item == nil then return false end
            local con = itemstore.config.PickupsGotoBank and ply.Bank or ply.Inventory
            if con == nil then return false end
            if con:CanFit(item) then
                ply:PickupItem(ent)
                success = true
            end
        elseif XeninInventory then

            local inv = ply:XeninInventory()
            local amt = table.Count(inv:GetInventory())
            local slots = inv:GetSlots()
            if (amt >= slots) then return false end
            if ply:XeninInventory():Pickup(ent) == true then
                success = true
            end
        elseif idinv then
            local inv = ply:GetInventory()
            if inv then
                idinv.item:Create(ent, nil, function(item, id)
                    inv:addItem(id)
                end)
            end
        elseif BRICKS_SERVER then

            if IsValid(ent) then

				if not ply.GetInventory then
					zclib.ErrorPrint("Could not find Bricks inventory player meta function > ply:GetInventory()")
					return
				end

                local inventoryTable = ply:GetInventory()
                if (table.Count(inventoryTable) >= BRICKS_SERVER.Func.GetInventorySlots(ply)) then
                    return
                end

                local itemData = BRICKS_SERVER.Func.GetEntTypeField(ent:GetClass(), "GetItemData")(ent)
                ply:BRS_InventoryAdd(itemData, 1)

                ent:Remove()
                success = true
            end
        elseif engine.ActiveGamemode() == "underdone" then
            ply:AddItem(class,1)
        end

        return success
    end

    // Takes the specified amount
    function zclib.Inventory.Take(ply,typecheck,amount)
        local success = false
        if itemstore then
            ply.Inventory:Suppress( function()
                for k, v in pairs( ply.Inventory:GetItems() ) do
                    if typecheck() then
                        v:SetAmount( v:GetAmount() - amount )

                        if v:GetAmount() <= 0 then
                            ply.Inventory:SetItem( k, nil )
                        end

                        success = true
                    end
                end
                return true
            end )
        end
        return success
    end
end
