if SERVER then return end
zclib = zclib or {}
zclib.Inventory = zclib.Inventory or {}

/*

    This inventory system does not get saved and is only used to temporarly store items

*/

/*
    Opens the players inventory vgui
*/
net.Receive("zclib_player_open", function(len)
    zclib.Debug_Net("zclib_player_open",len)

    local entInv = net.ReadEntity()

    // If we currently removing / placing something then stop
    zclib.PointerSystem.Stop()

    zclib.vgui.Page("Your Inventory",function(main,top)

        main:SetWide(650 * zclib.wM)

        local close_btn = zclib.vgui.ImageButton(940 * zclib.wM,10 * zclib.hM,50 * zclib.wM, 50 * zclib.hM,top,zclib.Materials.Get("close"),function()
            main:Close()
        end,false)
        close_btn:Dock(RIGHT)
        close_btn:DockMargin(10 * zclib.wM,0 * zclib.hM,0 * zclib.wM,0 * zclib.hM)
        close_btn.IconColor = zclib.colors["red01"]

        local seperator = zclib.vgui.AddSeperator(top)
        seperator:SetSize(5 * zclib.wM, 50 * zclib.hM)
        seperator:Dock(RIGHT)
        seperator:DockMargin(10 * zclib.wM,0 * zclib.hM,0 * zclib.wM,0 * zclib.hM)

        // Build Inventory
        local inv = zclib.Inventory.VGUI({
            parent = main,
            inv_ent = entInv,
            ExtraData = {
                SizeW = 80,
                SizeH = 80,
            },

            CanSelect = function(ItemData ,slot_data) return true end,

            OnDragDrop = function(DragPanel,ReceiverPanel) end
        })
        inv:SetSize(650 * zclib.wM, 370 * zclib.hM)

        main.OnInventoryChanged = function()

            // Do we already have the inventory build?
            if not IsValid(main.Inventory) then return end

            // Update the inventory
            main.Inventory:Update(zclib.Inventory.Get(entInv))
        end
    end)
end)



/*
    Gets called from server to send the new inventory data to the client
*/
net.Receive("zclib_Inventory_Sync", function(len)
    zclib.Debug_Net("zclib_Inventory_Sync", len)
    local dataLength = net.ReadUInt(16)
    local dataDecompressed = util.Decompress(net.ReadData(dataLength))
    local inv = util.JSONToTable(dataDecompressed)
    local ent = net.ReadEntity()
    local ent_index = net.ReadUInt(16)

	if not inv then zclib.ErrorPrint("zclib_Inventory_Sync > Inventory Data invalid!") return end

    zclib.InventoryCache[ent_index] = table.Copy(inv)

    if IsValid(ent) then
        ent.zclib_inv = table.Copy(inv)

        hook.Run("zclib_OnInventorySynch",ent)
    end
    ent.InventoryChanged = true

	// Is the interface currently open?
	if not IsValid(zclib_main_panel) then return end

	// Is the entity which inventory got synched the current ActiveVGUIEntity or the LocalPlayer
	if (ent ~= zclib.vgui.ActiveEntity and ent ~= LocalPlayer()) then return end

	// Did the inventory change?
    if not zclib_main_panel.OnInventoryChanged then return end

	zclib_main_panel:OnInventoryChanged()
end)


/*
    Draw the Pickup indicator
*/
local function DrawPickupIndicator()
    local tr = LocalPlayer():GetEyeTrace()
    if tr == nil then return end
    local ent = tr.Entity
    if not IsValid(ent) then return end
    if zclib.Inventory.CanPickup(ent:GetClass()) == false then return end

    local pos = ent:GetPos()
    pos = pos:ToScreen()

    local am = zclib.ItemDefinition.GetAmount(ent:GetClass(),ent)
    if am > 1 then am = "x" .. am else am = nil end

    local he = ent:Health()
    if he and he > 0 then he = (1 / ent:GetMaxHealth()) * ent:Health() else he = nil end
    zclib.util.DrawInfoBox(pos,{
        txt01 = zclib.Inventory.GetEntityName(ent),
        txt02 = "[ALT + E]",
        txt03 = am,
        color = zclib.colors["green01"],
        bar_fract = he,
        bar_col01 = zclib.colors["red01"],
        bar_col02 = zclib.colors["green01"],
    })
end

zclib.Hook.Add("HUDPaint", "zclib_player_inventory", function() if zclib.config.Inventory.ShowItemPickup then DrawPickupIndicator() end end)



// TODO Implement a language system in to zclib and connect it here

function zclib.Inventory.Slot(ItemData,GotSelected,CanSelect,OnSelect,PreDraw,PostDraw)
    local main_pnl = vgui.Create("zclib_inventory_slot")
    main_pnl:SetSize(200 * zclib.wM, 200 * zclib.hM)

    function main_pnl:PreDraw(w, h)
        if PreDraw then pcall(PreDraw,w,h,self,self.ItemData) end
    end

    function main_pnl:PostDraw(w, h)
        if PostDraw then pcall(PostDraw,w,h,self,self.ItemData) end
    end

    function main_pnl:CanSelect()
        local _,canselect = xpcall( CanSelect, function() end, self.ItemData )
        return canselect
    end

    function main_pnl:OnSelect()
        pcall(OnSelect,self.ItemData)
    end

    function main_pnl:GotSelected()
        local _,isselect = xpcall( GotSelected, function() end, self.ItemData )
        return isselect
    end

    return main_pnl
end

/*
zclib.Inventory.VGUI({
    parent = parent,

    // The entity who has the inventory
    inv_ent = entity,

    CanSelect = function(ItemData ,slot_data)
    end,

    OnSelect = function(slot_id)
    end,

    PreDraw = function(w,h,s,ItemData)
    end,

    PostDraw = function(w,h,s,ItemData)
    end,

    // This can be used to modify the inventory item panel
    OnItemUpdate = function(slot_id,slot_data,item_pnl)
    end,

    // Gets called when one item is dragged on another one
    // Return true to prevent one item being switched with the other one
    OnDragDrop = function(DragPanel,ReceiverPanel)

    end
})
*/

// Keeps track on which slot panel is currently selected
zclib.Inventory.SelectedSlot = nil

function zclib.Inventory.VGUI(data)
    zclib.Debug("zclib.Inventory.VGUI")

    if IsValid(data.parent.Inventory) then data.parent.Inventory:Remove() end

    local title = (data.ExtraData and data.ExtraData.title) and data.ExtraData.title //or "Inventory"//zclib.language["Inventory:"]
    local main = zclib.vgui.Panel(data.parent, title)
    main:SetSize(600 * zclib.wM, 300 * zclib.hM)

    // This mainly checks if the player has left / rightclicked on something that isnt a option box and removes the optionbox if its active
    main.Think = function() zclib.Inventory.ClickLogic(vgui.GetHoveredPanel()) end
    data.parent.Inventory = main



    // Keep track on the inventory entity
    main.inv_ent = data.inv_ent

    // Store the SlotOptions in the inventory panel
    main.SlotOptions = data.SlotOptions

    local list,scroll = zclib.vgui.List(main)
    list:DockMargin(0 * zclib.wM,0 * zclib.hM,-15 * zclib.wM,0 * zclib.hM)
    scroll:DockMargin(10 * zclib.wM,10 * zclib.hM,0 * zclib.wM,0 * zclib.hM)
    scroll.Paint = function(s, w, h)
        //draw.RoundedBox(5, 0, 0, w, h, zclib.colors["red01"])
    end

    local itmW,itmH = 100, 100
    local ItemSize
    if data.ExtraData then
        if data.ExtraData.ItemSize then ItemSize = data.ExtraData.ItemSize end
        if data.ExtraData.SizeW then itmW = data.ExtraData.SizeW end
        if data.ExtraData.SizeH then itmH = data.ExtraData.SizeH end
    end

    main.Items = {}
    main.UpdateItem = function(self,slot_id,slot_data)
        if slot_data == nil then return end

        local item_pnl = main.Items[slot_id]

        if not IsValid(item_pnl) then

            local fitmW = (ItemSize or itmW) * zclib.wM
            local fitmH = (ItemSize or itmH) * zclib.hM

            item_pnl = vgui.Create("zclib_inventory_slot")
            item_pnl:SetSize(fitmW, fitmH)
            item_pnl:SetPos( fitmW * slot_id, fitmH )

            function item_pnl:PreDraw(w, h)
                if data.PreDraw then pcall(data.PreDraw,w,h,self,self.ItemData) end
            end

            function item_pnl:PostDraw(w, h)
                if data.PostDraw then pcall(data.PostDraw,w,h,self,self.ItemData) end
            end

            function item_pnl:CanSelect()
                if data.CanSelect == nil then return false end
                if zclib.Inventory.SlotIsEmpty(data.inv_ent,slot_id) == true then
                    return false
                else
                    local _,canselect = xpcall( data.CanSelect, function() end, itmDat ,slot_data)
                    return canselect
                end
            end

            function item_pnl:OnSelect()
                zclib.Inventory.SelectedSlot = self

                zclib.Inventory.RemoveSlotOptions()
                zclib.Inventory.SlotOptions(self,slot_id)

                if data.OnSelect then pcall(data.OnSelect,slot_id,item_pnl) end
            end

            function item_pnl:OnClick()
                if data.OnClick then pcall(data.OnClick,slot_id,item_pnl) end
            end


            function item_pnl:GotSelected()
                return zclib.Inventory.SelectedSlot == self
            end

            list:Add(item_pnl)

            if main.Items == nil then main.Items = {} end
            main.Items[slot_id] = item_pnl
        end

        // Tell the slot which inventory he listens too
        item_pnl.Inventory = main

        // Tell the slot which entity his inventory belongs to
        item_pnl.inv_ent = data.inv_ent

        // If the item has no price value then lets give it one
        // TODO Not sure if this is still needed
        if slot_data and table.Count(slot_data) > 0 and slot_data.Price == nil then slot_data.Price = zclib.ItemDefinition.GetPrice(slot_data.Class,slot_data) end

        // Tell the panel what its id and data is
        item_pnl.slot_id = slot_id
        item_pnl.slot_data = slot_data

        // Send the slot panel its data so it can display / render the image of the item
        item_pnl:Update(slot_data)

        // Call inventory function should we wanna call anything else
        if data.OnItemUpdate then pcall(data.OnItemUpdate,slot_id,slot_data,item_pnl) end


        ///////////////// DRAG LOGIC
        // We make the DragBase id unique to the entity which prevents items being draged from one inventory to another one
        local DragBaseID = "zcLibDragBase_" .. data.inv_ent:EntIndex()

        // If the slot is not empty then it can be drag/dropped
        if item_pnl.slot_data and table.IsEmpty(item_pnl.slot_data) == false then
            item_pnl:Droppable( DragBaseID )
        end

        // Tell the panel it can receiver other panels being dropped on it
        item_pnl:Receiver(DragBaseID, function(s, panels, bDoDrop, Command, x, y)
            if bDoDrop and data.OnDragDrop then
                local rec = s
                for k, v in pairs(panels) do
                    local dra = v
                    if dra == nil then continue end
                    if dra == rec then continue end

                    // Play drop animation and sound
                    dra:OnDrop()

                    // If the Drag/Drop function returns true then stop here and dont perform the item switch
                    if data.OnDragDrop(dra, rec) == true then break end

                    zclib.Inventory.Drag(dra.inv_ent,rec.inv_ent,dra.slot_id,rec.slot_id,dra,rec)
                    break
                end
            end
        end)

        // Checks if the player is currently over the DropToFloor area on the interface
        local function OnDropToFloor()
            if not IsValid(zclib_main_panel) then return false end
            local mX,mY = input.GetCursorPos()

            local pX,pY = zclib_main_panel:GetPos()

            local maxX, maxY = pX - 10 * zclib.wM,pY + zclib_main_panel:GetTall()
            local minX, minY = pX - 110 * zclib.wM,pY

            if mX > minX and mX < maxX and mY > minY and mY < maxY then
                return true
            else
                return false
            end
        end

        item_pnl.OnStartDragging = function()
            zclib.Hook.Add("HUDPaint", "zclib_player_inventory_droptofloor", function()
                if IsValid(item_pnl) and IsValid(zclib_main_panel) then

                    local slotPnl = vgui.GetHoveredPanel()
                    if IsValid(slotPnl) then
                        slotPnl.LastHoveredByDragPanel = CurTime()
                    end

                    local x,y = zclib_main_panel:GetPos()
                    draw.RoundedBox(5, x - 110 * zclib.wM, y, 100 * zclib.hM, zclib_main_panel:GetTall(), zclib.colors["black_a200"])
                    if OnDropToFloor() then
                        zclib.util.DrawOutlinedBox(x - 110 * zclib.wM, y, 100 * zclib.hM, zclib_main_panel:GetTall(), 2, zclib.colors["green01"])
                    end
                    draw.SimpleText("DROP", zclib.GetFont("zclib_font_medium"), x - 60 * zclib.wM, y + (zclib_main_panel:GetTall() / 2), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                else
                    zclib.Hook.Remove("HUDPaint", "zclib_player_inventory_droptofloor")
                end
            end)
        end

        item_pnl.OnStopDragging = function()
            zclib.Hook.Remove("HUDPaint", "zclib_player_inventory_droptofloor")

            // If we drag the item on nothing then that means we want to drop the item from the inventory
            local pnl = vgui.GetHoveredPanel()
            if OnDropToFloor() and (pnl == nil or pnl:GetClassName() == "CGModBase") then
                zclib.Inventory.DropToFloor(data.inv_ent,item_pnl.slot_id)
            end
        end
        /////////////////
    end



    main.Update = function(s,inv) for slot_id, slot_data in pairs(inv) do main:UpdateItem(slot_id,slot_data) end end
    main:Update(zclib.Inventory.Get(data.inv_ent))

    scroll:InvalidateLayout(true)
    scroll:SizeToChildren(false, true)

    list:InvalidateLayout(true)
    list:SizeToChildren(false, true)

    main:InvalidateLayout(true)
    main:SizeToChildren(false, true)

    return main
end

// This needs to be called when the player clicks on a inventory slot which has a item
function zclib.Inventory.SlotOptions(pnl,slot)

    if pnl.Inventory.SlotOptions and table.Count(pnl.Inventory.SlotOptions) <= 0 then return end

    local SlotData = zclib.Inventory.GetSlotData(pnl.Inventory.inv_ent,slot)
    if SlotData == nil then return end
    if SlotData.Class == nil then return end

    local ItemDefinition = zclib.ItemDefinition.Get(SlotData.Class)

    local bg_pnl = vgui.Create("DPanel",pnl.Inventory)
    bg_pnl:Dock(FILL)
    bg_pnl.Paint = function(s, w, h)
        if input.IsKeyDown(KEY_ESCAPE) then s:Remove() end
        zclib.util.DrawBlur(s, 1, 5)
        draw.RoundedBox(5, 0, 0, w, h, zclib.colors["black_a100"])
    end
    zclib.vgui.SlotOptionPanel = bg_pnl
    bg_pnl:InvalidateLayout( true )
    bg_pnl:InvalidateParent(true)

    local main_pnl = vgui.Create("DPanel",bg_pnl)
    main_pnl:SetSize(300 * zclib.wM, 500 * zclib.hM)
    main_pnl:Center()
    main_pnl.Paint = function(s, w, h)
        //if input.IsKeyDown(KEY_ESCAPE) then s:Remove() end
        draw.RoundedBox(5, 0,0, w, h , zclib.colors["ui00"])

        draw.SimpleText("Options", zclib.GetFont("zclib_font_medium"), w / 2, 5 * zclib.hM, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        draw.RoundedBox(0, 5 * zclib.wM,40 * zclib.hM, w - (10 * zclib.wM), 4 * zclib.hM , zclib.colors["ui02"])
    end
    //main_pnl:MoveToFront()

    main_pnl:DockPadding(5 * zclib.wM, 50 * zclib.hM, 5 * zclib.wM, 5 * zclib.hM)

    // Keep refrence of which slot of the inventory got clicked on
    main_pnl.slot = slot

    local function OptionButton(color_overwrite,txt,tooltip,action)
        local bttn_pnl = vgui.Create("DButton", main_pnl)
        bttn_pnl:Dock(TOP)
        bttn_pnl:DockMargin( 0, 0, 0, 5  * zclib.hM )
        bttn_pnl:SetSize(main_pnl:GetWide(), 30 * zclib.hM)
        bttn_pnl:SetAutoDelete(true)
        bttn_pnl:SetText("")
        bttn_pnl.IsOptionBoxButton = true

        local desc = string.Replace(tooltip or txt,"$ItemName",pnl.slot_data.Name)
        if pnl.slot_data.Price then desc = string.Replace(desc,"$ItemPrice",zclib.Money.Display(pnl.slot_data.Price)) end

        bttn_pnl:SetTooltip(desc)
        bttn_pnl.Paint = function(s, w, h)
            draw.RoundedBox(0, 0, 0, w, h, zclib.colors["ui02"])
            draw.SimpleText(txt, zclib.GetFont("zclib_font_small"), w / 2, h / 2, color_overwrite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            if s:IsHovered() then
                draw.RoundedBox(0, 0, 0, w, h, zclib.colors["white_a15"])
            end
        end
        bttn_pnl.DoClick = function()
            pcall(action)
        end
    end

    // If we have custom slotOptions then use them instead
    if pnl.Inventory.SlotOptions then
        for k,v in ipairs(pnl.Inventory.SlotOptions) do
            OptionButton(v.color,v.name,v.desc,function()
                v.func(slot,pnl)
                zclib.Inventory.RemoveSlotOptions()
            end)
        end
    else

        // Use option
        if ItemDefinition and ItemDefinition.OnUse then
            OptionButton(zclib.colors["blue01"],"Use","Uses $ItemName.",function()
                zclib.Inventory.UseItem(pnl.Inventory.inv_ent,slot)
            end)
        end

        // Equipt option for weapons
        if zclib.ItemDefinition.IsWeapon(SlotData.Class,SlotData) then
            OptionButton(zclib.colors["blue01"],"Equipt","Equipt $ItemName.",function()
                zclib.Inventory.EquiptItem(pnl.Inventory.inv_ent,slot)
                zclib.vgui.ForceClose()
            end)
        end

        // If the Item has a model or a Drop function then we allow it to be drop
        if (ItemDefinition == nil or ItemDefinition.PreventDrop == nil) and pnl.Inventory.inv_ent ~= LocalPlayer() and ItemDefinition.PreventCollect == nil then
            OptionButton(zclib.colors["text01"],"Collect","Collects $ItemName and places it in your inventory.",function()
                zclib.Inventory.CollectItem(pnl.Inventory.inv_ent,slot)
            end)
        end

        // If the Item has a model or a Drop function then we allow it to be drop
        if ItemDefinition == nil or ItemDefinition.PreventDrop == nil then
            OptionButton(zclib.colors["text01"],"Place","Places $ItemName in the world or send to some inventory.",function()
                zclib.Inventory.ThrowItem(pnl.Inventory.inv_ent,slot)
            end)
        end

		if ItemDefinition.CustomOptions then
			for k, v in pairs(ItemDefinition.CustomOptions(SlotData) or {}) do
				OptionButton(v.color, v.name, v.name .. " $ItemName.", function()

					v.func(LocalPlayer(),pnl.Inventory.inv_ent,slot,pnl)

					zclib.Inventory.CustomOption(pnl.Inventory.inv_ent, slot, k)
				end)
			end
		end

        // Destroy options
        OptionButton(zclib.colors["red01"],"Destroy","Destroy $ItemName.",function()
            zclib.Inventory.DestroyItem(pnl.Inventory.inv_ent,slot)
        end)


    end

    main_pnl:InvalidateLayout( true )
    main_pnl:SizeToChildren( false, true )
    main_pnl:Center()
    return main_pnl
end

// Removes the item options
function zclib.Inventory.RemoveSlotOptions()
    zclib.Inventory.SelectedSlot = nil
    if IsValid(zclib.vgui.SlotOptionPanel) then
        zclib.vgui.SlotOptionPanel:Remove()
    end
end

local RightClickIsDown = false
local LefClickIsDown = false
function zclib.Inventory.ClickLogic(pnl)

    // If the player RightClicks on something thats not a item slot panel then close the Item Option panel if its open
    if (input.IsMouseDown(MOUSE_RIGHT) and not RightClickIsDown) or (input.IsMouseDown(MOUSE_LEFT) and not LefClickIsDown) then
        if not IsValid(pnl) then
            zclib.Inventory.RemoveSlotOptions()
        else
            if pnl.IsOptionBoxButton then return end

            zclib.Inventory.RemoveSlotOptions()
        end
    end

    LefClickIsDown = input.IsMouseDown(MOUSE_LEFT)
    RightClickIsDown = input.IsMouseDown(MOUSE_RIGHT)
end


/*

    Slot Options

*/

// Drops the specified item on the floor
function zclib.Inventory.DropToFloor(ent,SlotID)
    net.Start("zclib_Inventory_DropToFloor")
    net.WriteEntity(ent)
    net.WriteInt(SlotID,16)
    net.SendToServer()
end

// Informs the server that one item got dragged on another one
function zclib.Inventory.Drag(DraggedEnt,ReceiverEnt,DraggedID,ReceiverID,DraggedPnl,ReceiverPnl)

    net.Start("zclib_Inventory_Drag")
    net.WriteEntity(DraggedEnt)
    net.WriteEntity(ReceiverEnt)
    net.WriteInt(DraggedID,10)
    net.WriteInt(ReceiverID,10)
    net.SendToServer()

    local ply = LocalPlayer()
    if not IsValid(DraggedEnt) then return end
    if not IsValid(ReceiverEnt) then return end
    if DraggedID == nil then return end
    if ReceiverID == nil then return end
    if zclib.util.InDistance(DraggedEnt:GetPos(), ply:GetPos(), 500) == false then return end

    local DraggedData = zclib.Inventory.GetSlotData(DraggedEnt,DraggedID)
    local ReceiverData = zclib.Inventory.GetSlotData(ReceiverEnt,ReceiverID)

    // Can be used to perform some other action when one item gets droped on another one
    local result01 = hook.Run("zclib_Inventory_OnDragDrop",ply,DraggedEnt,DraggedData,ReceiverData,DraggedPnl,ReceiverPnl)
    if result01 then return end

    // Can the item be used on the reciever item
    // Examble: A hammer can be used on a egg to crack it
    // The Dragged Item will not be removed or changed
    // The Receiver Item will be changed or removed
    local ModifiedReceiverData = hook.Run("zclib_Inventory_DragDrop_CanUse",ply,DraggedEnt,DraggedData,ReceiverData,DraggedPnl,ReceiverPnl)
    if ModifiedReceiverData then return end

    // Removes both items and creates a new one
    local ResultData = hook.Run("zclib_Inventory_DragDrop_CanCombine",ply,DraggedEnt,DraggedData,ReceiverData,DraggedPnl,ReceiverPnl)
    if ResultData then return end
end

// Moves a Item from one Inventory to another one instantly
function zclib.Inventory.CollectItem(ent,slot)
    net.Start("zclib_Inventory_Collect")
    net.WriteEntity(ent)
    net.WriteUInt(slot,16)
    net.SendToServer()

    zclib.Inventory.RemoveSlotOptions()
end

// Uses the item of the specified slot
function zclib.Inventory.UseItem(ent,slot)

    zclib.Inventory.RemoveSlotOptions()

    // Here we call the use function on client and stop any further call if it returns
    local Result
    local SlotData = zclib.Inventory.GetSlotData(ent,slot)
    if SlotData and SlotData.Class then
        local ItemDefinition = zclib.ItemDefinition.Get(SlotData.Class)
        if ItemDefinition and ItemDefinition.OnUse then
            Result = ItemDefinition.OnUse(LocalPlayer())
        end
    end
    if Result then return end

    net.Start("zclib_Inventory_Use")
    net.WriteEntity(ent)
    net.WriteInt(slot,10)
    net.SendToServer()
end

// Equipts the weapon of the specified slot
function zclib.Inventory.EquiptItem(ent,slot)

    zclib.Inventory.RemoveSlotOptions()

    net.Start("zclib_Inventory_Equipt")
    net.WriteEntity(ent)
    net.WriteInt(slot,10)
    net.SendToServer()
end

// Deletes the content of the specified slot
function zclib.Inventory.DestroyItem(ent,slot)
    net.Start("zclib_Inventory_Destroy")
    net.WriteEntity(ent)
    net.WriteInt(slot,10)
    net.SendToServer()

    zclib.Inventory.RemoveSlotOptions()
end

// Throws the content of the specified slot from one Inventory to another one
function zclib.Inventory.ThrowItem(from, SlotID)

    local SlotData = zclib.Inventory.GetSlotData(from,SlotID)
    if SlotData == nil or table.IsEmpty(SlotData) then
        return
    end

    zclib_main_panel:Close()

    zclib.PointerSystem.Start(from, function()
        // OnInit
        zclib.PointerSystem.Data.MainColor = zclib.colors["green01"]
        zclib.PointerSystem.Data.ActionName = "Throw"//zclib.language["Throw"]
        zclib.PointerSystem.Data.CancelName = "Cancel"//zclib.language["Cancel"]
    end, function()
        // OnLeftClick

        zclib.Inventory.SelectedSlot = nil

        SlotData = zclib.Inventory.GetSlotData(from,SlotID)
        if SlotData == nil or table.IsEmpty(SlotData) then
            zclib.PointerSystem.Stop()
            return
        end

        if SlotData.Model == nil and not IsValid(zclib.PointerSystem.Data.Target) then
            zclib.vgui.Notify("You cant place this on the floor!",NOTIFY_ERROR)
            return
        end


        if zclib.util.InDistance(zclib.PointerSystem.Data.Pos, LocalPlayer():GetPos(), 500) == false then
            zclib.vgui.Notify("Too far away!",NOTIFY_ERROR)
            return
        end

        // Send the target to the SERVER
        net.Start("zclib_Inventory_Throw")
        net.WriteEntity(from)
        net.WriteEntity(zclib.PointerSystem.Data.Target or NULL)
        net.WriteVector(zclib.PointerSystem.Data.Pos)
        net.WriteUInt(SlotID,16)
        net.SendToServer()

        local toPos = zclib.PointerSystem.Data.Pos
        if IsValid(zclib.PointerSystem.Data.Target) then
            toPos = zclib.PointerSystem.Data.Target:GetPos()
        end

        local traveltime = zclib.Inventory.GetThrowTime(from:GetPos(),toPos)
        zclib.ItemShooter.Add(from:GetPos() + Vector(0,0,25),toPos + Vector(0,0,25),traveltime,function(ent)

            zclib.Inventory.ApplyItemVisuals(ent,SlotData)

            // Can be used by other scripts to update the thrown items appearance
            hook.Run("zclib_Inventory_PreItemThrown",SlotID,ent,from,zclib.PointerSystem.Data.Target or toPos)
        end)

        zclib.PointerSystem.Stop()
    end, function()

        // Catch the Target
        if IsValid(zclib.PointerSystem.Data.HitEntity) and zclib.Inventory.IsThrowTarget(zclib.PointerSystem.Data.HitEntity,from,SlotID) then
            zclib.PointerSystem.Data.Target = zclib.PointerSystem.Data.HitEntity
        else
            zclib.PointerSystem.Data.Target = nil
        end

        if zclib.util.InDistance(zclib.PointerSystem.Data.Pos, LocalPlayer():GetPos(), 500) then
            zclib.PointerSystem.Data.MainColor = zclib.colors["green01"]
        else
            zclib.PointerSystem.Data.MainColor = zclib.colors["red01"]
        end

        // Update PreviewModel
        if IsValid(zclib.PointerSystem.Data.PreviewModel) then
            if IsValid(zclib.PointerSystem.Data.Target) then
                zclib.PointerSystem.Data.PreviewModel:SetColor(zclib.PointerSystem.Data.MainColor)
                zclib.PointerSystem.Data.PreviewModel:SetPos(zclib.PointerSystem.Data.Target:GetPos())
                zclib.PointerSystem.Data.PreviewModel:SetAngles(zclib.PointerSystem.Data.Target:GetAngles())
                zclib.PointerSystem.Data.PreviewModel:SetModel(zclib.PointerSystem.Data.Target:GetModel())
                zclib.PointerSystem.Data.PreviewModel:SetModelScale(zclib.PointerSystem.Data.Target:GetModelScale())
                zclib.PointerSystem.Data.PreviewModel:SetNoDraw(false)
            else
                zclib.PointerSystem.Data.PreviewModel:SetNoDraw(true)
            end
        end
    end,nil,function()
    end)
end

// Performs a custom function on the specified slot item
function zclib.Inventory.CustomOption(ent,slot,SlotOption)

    zclib.Inventory.RemoveSlotOptions()

    net.Start("zclib_Inventory_CustomOption")
    net.WriteEntity(ent)
    net.WriteInt(slot,10)
	net.WriteString(SlotOption)
    net.SendToServer()
end
