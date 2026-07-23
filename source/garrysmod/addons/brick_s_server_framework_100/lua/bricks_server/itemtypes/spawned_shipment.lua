local ITEM = BRICKS_SERVER.Func.CreateItemType( "spawned_shipment" )

ITEM.GetItemData = function( ent )
    local itemData = { "spawned_weapon", ent:GetModel(), CustomShipments[ent:Getcontents()].entity }

    if( CustomShipments[ent:Getcontents()] and CustomShipments[ent:Getcontents()].model ) then
        itemData[2] = CustomShipments[ent:Getcontents()].model or ent:GetModel()
    end
    
    return itemData, (ent:Getcount() or 1)
end

ITEM.OnSpawn = function( ply, pos, itemData, itemAmount )
    local ent = ents.Create( "spawned_weapon" )
    if( not IsValid( ent ) ) then return end
    ent:SetPos( pos )
    ent:SetWeaponClass( itemData[3] )
    ent:Setamount( itemAmount or 1 )
    ent:SetModel( itemData[2] )
    ent:Spawn()
end

ITEM.GetInfo = function( itemData )
    return { (itemData[4] or "Unknown"), (itemData[5] or BRICKS_SERVER.Func.L( "someDescription" )), (BRICKS_SERVER.CONFIG.INVENTORY.ItemRarities or {})[itemData[3] or ""] }
end

ITEM:Register()