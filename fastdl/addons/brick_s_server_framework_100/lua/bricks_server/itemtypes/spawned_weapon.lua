local ITEM = BRICKS_SERVER.Func.CreateItemType( "spawned_weapon" )

ITEM.GetItemData = function( ent )
    local itemData = { "spawned_weapon", ent:GetModel(), (ent.GetWeaponClass and ent:GetWeaponClass()) or "nil" }
    
    if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "swepupgrader" ) ) then
        itemData[4] = ent:GetNW2Int( "BRS_Upgrades", 0 )
    end

    if( ent:GetNW2Bool( "BRS_IsPermanent" ) ) then
        itemData[5] = true
    end

    return itemData, (ent.Getamount and ent:Getamount()) or 1
end

ITEM.CanDropMultiple = true

ITEM.OnSpawn = function( ply, pos, itemData, itemAmount )
    local ent = ents.Create( "spawned_weapon" )
    if( not IsValid( ent ) ) then return end
    ent:SetPos( pos )
    ent:SetWeaponClass( itemData[3] )
    ent:Setamount( itemAmount or 1 )
    ent:SetModel( itemData[2] or "" )
    ent:Spawn()
    
    if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "swepupgrader" ) and isnumber( itemData[4] or 0 ) and (itemData[4] or 0) > 0 ) then
        ent:SetNW2Int( "BRS_Upgrades", (itemData[4] or 0) )
        function ent:StartTouch( touchEnt ) 
            BRICKS_SERVER.Func.MergeWeapons( self, touchEnt )
        end
    end

    if( itemData[5] ) then
        ent:SetNW2Bool( "BRS_IsPermanent", true )
    end
end

ITEM.OnUse = function( ply, itemData )
    if( not itemData[3] ) then return false end

    ply:Give( itemData[3], true )

    if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "swepupgrader" ) and isnumber( itemData[4] or 0 ) and (itemData[4] or 0) > 0 ) then
        timer.Simple( 0.2, function()
            local newWeaponEnt = ply:GetWeapon( itemData[3] )

            if( IsValid( newWeaponEnt ) ) then
                newWeaponEnt:BRS_SetWeaponTier( (itemData[4] or 0), ply )
            end
        end )
    end
end

ITEM.CanUse = function( ply, itemData )
    if( itemData[5] ) then return false end

    return true
end

ITEM.Equip = function( ply, itemData )
    ply:Give( itemData[3], true )
end

ITEM.CanEquip = function( ply, itemData )
    if( not itemData[5] ) then return false end
    
    for k, v in pairs( ply:BRS():GetInventory() ) do
        if( v[3] and v[2] and v[2][3] == itemData[3] ) then return false end
    end

    return true
end

ITEM.UnEquip = function( ply, itemData )
    ply:StripWeapon( itemData[3] )
end

ITEM.CanUnEquip = function( ply, itemData )
    if( not itemData[5] ) then return false end

    return true
end

ITEM.ModelDisplay = function( Panel, itemData )
    if( not Panel.Entity or not IsValid( Panel.Entity ) ) then return end

    local mn, mx = Panel.Entity:GetRenderBounds()
    local size = 0
    size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
    size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
    size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

    Panel:SetFOV( 50 )
    Panel:SetCamPos( Vector( size, size, size ) )
    Panel:SetLookAt( (mn + mx) * 0.5 )
end

ITEM.GetInfo = function( itemData )
    local itemName = "Unknown"
    if( (list.Get( "Weapon" ) or {})[(itemData[3] or "")] and (list.Get( "Weapon" ) or {})[(itemData[3] or "")].PrintName ) then
        itemName = (list.Get( "Weapon" ) or {})[(itemData[3] or "")].PrintName
    end

    local itemDescription = BRICKS_SERVER.Func.L( "shootyStick" )
    if( BRICKS_SERVER.ESSENTIALS and BRICKS_SERVER.ESSENTIALS.LUACFG.ItemDescriptions and BRICKS_SERVER.ESSENTIALS.LUACFG.ItemDescriptions[(itemData[3] or "")] ) then
        itemDescription = BRICKS_SERVER.ESSENTIALS.LUACFG.ItemDescriptions[(itemData[3] or "")]
    end

    if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "swepupgrader" ) and isnumber( itemData[4] or 0 ) and (itemData[4] or 0) > 0 ) then
        return { itemName .. " " .. BRICKS_SERVER.Func.L( "tierX", (itemData[4] or 0) ), itemDescription, (BRICKS_SERVER.CONFIG.INVENTORY.ItemRarities or {})[itemData[3] or ""], (itemData[5] and BRICKS_SERVER.Func.L( "permanent" )) }
    else
        return { itemName, itemDescription, (BRICKS_SERVER.CONFIG.INVENTORY.ItemRarities or {})[itemData[3] or ""], (itemData[5] and BRICKS_SERVER.Func.L( "permanent" )) }
    end
end

ITEM.GetItemKey = function( itemData )
    return itemData[3] or ""
end

ITEM.GetPotentialItems = function()
    local potentialItems = {}
    for k, v in pairs( BRICKS_SERVER.Func.GetList( "weapons" ) ) do
        local weaponModel = BRICKS_SERVER.Func.GetWeaponModel( k ) or ""
        if( GAMEMODE.Config.DisallowDrop[k] or weaponModel == "" ) then continue end

        potentialItems[k] = {
            Name = v,
            Model = weaponModel,
            ItemKey = k
        }
    end

    return potentialItems
end

ITEM.CanCombine = function( itemData1, itemData2 )
    if( itemData1[5] or itemData2[5] ) then return false end

    if( itemData1[1] == itemData2[1] and itemData1[3] and itemData2[3] and itemData1[3] == itemData2[3] ) then
        if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "swepupgrader" ) ) then
            if( (itemData1[4] or 0) == (itemData2[4] or 0) ) then
                return true
            end
        else
            return true
        end
    end

    return false
end

ITEM:Register()