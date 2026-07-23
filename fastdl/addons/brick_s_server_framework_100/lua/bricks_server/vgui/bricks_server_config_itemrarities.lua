local PANEL = {}

function PANEL:Init()
    self.margin = 0
end

function PANEL:FillPanel()
    self.panelWide, self.panelTall = ScrW()*0.6-BRICKS_SERVER.DEVCONFIG.MainNavWidth, ScrH()*0.65-40

    self.topBar = vgui.Create( "DPanel", self )
    self.topBar:Dock( TOP )
    self.topBar:SetTall( 60 )
    self.topBar.Paint = function( self, w, h ) 
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
        surface.DrawRect( 0, 0, w, h )
    end 

    self.searchBar = vgui.Create( "bricks_server_searchbar", self.topBar )
    self.searchBar:Dock( LEFT )
    self.searchBar:DockMargin( 25, 10, 10, 10 )
    self.searchBar:SetWide( ScrW()*0.2 )
    self.searchBar:SetBackColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
    self.searchBar:SetHighlightColor( BRICKS_SERVER.Func.GetTheme( 0 ) )
    self.searchBar.OnChange = function()
        self:Refresh()
    end

    self.scrollPanel = vgui.Create( "bricks_server_scrollpanel_bar", self )
    self.scrollPanel:Dock( FILL )
    self.scrollPanel:DockMargin( 25, 25, 25, 25 )
    self.scrollPanel.Paint = function( self, w, h ) end 

    self.spacing = 5
    local gridWide = self.panelWide-50-10-self.spacing
    local wantedSlotSize = 125*(ScrW()/2560)
    self.slotsWide = math.floor( gridWide/wantedSlotSize )
    self.slotSize = (gridWide-((self.slotsWide-1)*self.spacing))/self.slotsWide

    self.grid = vgui.Create( "DIconLayout", self.scrollPanel )
    self.grid:Dock( TOP )
    self.grid:SetSpaceY( self.spacing )
    self.grid:SetSpaceX( self.spacing )

    self:Refresh()
end

function PANEL:Refresh()
    self.grid:Clear()

    local sortedItems = {}
    local rarityItems = BRICKS_SERVER.Func.GetRarityItems() or {}
    for k, v in pairs( rarityItems ) do
        if( self.searchBar:GetValue() != "" and not string.find( string.lower( v[1] or "" ), string.lower( self.searchBar:GetValue() ) ) ) then
            continue
        end

        local rarityInfo, rarityKey = {}, 0
        if( BS_ConfigCopyTable.INVENTORY.ItemRarities[k] ) then
            rarityInfo, rarityKey = BRICKS_SERVER.Func.GetRarityInfo( BS_ConfigCopyTable.INVENTORY.ItemRarities[k] )
        end

        local itemTable = table.Copy( v )
        itemTable.Key = k
        itemTable.Rarity = rarityKey or 0
        itemTable.RarityInfo = rarityInfo

        table.insert( sortedItems, itemTable )
    end

    table.sort( sortedItems, function( a, b ) return ((a or {}).Rarity or 0) > ((b or {}).Rarity or 0) end )

    local loadingIcon = Material( "materials/bricks_server/loading.png" )

    local modelsToLoad = {}
    for k, v in pairs( sortedItems ) do
        local slotBack = self.grid:Add( "DPanel" )
        slotBack:SetSize( self.slotSize, self.slotSize )
        local changeAlpha = 0
        slotBack.Paint = function( self2, w, h )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
            
            if( IsValid( self2.itemModel ) ) then
                if( self2.itemModel:IsDown() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 125 )
                elseif( self2.itemModel:IsHovered() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 95 )
                else
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
                end
            else
                surface.SetDrawColor( 255, 255, 255, 255 )
                surface.SetMaterial( loadingIcon )
                local size = 32
                surface.DrawTexturedRectRotated( w/2, h/2, size, size, -(CurTime() % 360 * 250) )
            end

            surface.SetAlphaMultiplier( changeAlpha/255 )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
            surface.SetAlphaMultiplier( 1 )

            draw.SimpleText( (v[1] or BRICKS_SERVER.Func.L( "nil" )), "BRICKS_SERVER_Font17", w/2, h-5, ((v.RarityInfo and BRICKS_SERVER.Func.GetRarityColor( v.RarityInfo )) or BRICKS_SERVER.Func.GetTheme( 6 )), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
        end

        table.insert( modelsToLoad, { slotBack, v.Key } )
    end

    local function loadModel( k )
        if( not modelsToLoad[k] ) then return end

        local parent, itemKey = modelsToLoad[k][1], modelsToLoad[k][2]
        local model, color = rarityItems[itemKey][2], rarityItems[itemKey][3]

        if( not IsValid( parent ) ) then return end

        if( model ) then
            parent.itemModel = vgui.Create( "DModelPanel", parent )
            parent.itemModel:Dock( FILL )
            parent.itemModel:SetModel( model )
            function parent.itemModel:LayoutEntity( Entity ) return end
            if( parent.itemModel.Entity and IsValid( parent.itemModel.Entity ) ) then
                local mn, mx = parent.itemModel.Entity:GetRenderBounds()
                local size = 0
                size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
                size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
                size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )
    
                parent.itemModel:SetFOV( 70 )
                parent.itemModel:SetCamPos( Vector( size, size, size ) )
                parent.itemModel:SetLookAt( (mn + mx) * 0.5 )
            end

            if( color ) then
                parent.itemModel:SetColor( color )
            end
        else
            parent.itemModel = vgui.Create( "DButton", parent )
            parent.itemModel:Dock( FILL )
            parent.itemModel:SetText( "" )
            parent.itemModel.Paint = function() end
        end

        parent.itemModel.DoClick = function()
            local options = {}
            for k, v in pairs( BS_ConfigCopyTable.GENERAL.Rarities ) do
                options[k] = v[1] or BRICKS_SERVER.Func.L( "nil" )
            end

            if( table.Count( options ) <= 0 ) then 
                notification.AddLegacy( BRICKS_SERVER.Func.L( "needToAddRarity" ), 1, 5 )
                return 
            end

            BRICKS_SERVER.Func.ComboRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "whatRarityItem" ), BRICKS_SERVER.Func.L( "none" ), options, function( value, data ) 
                if( BS_ConfigCopyTable.GENERAL.Rarities[data] ) then
                    BS_ConfigCopyTable.INVENTORY.ItemRarities[itemKey] = value
                    self:Refresh()
                    BRICKS_SERVER.Func.ConfigChange( "INVENTORY" )
                else
                    notification.AddLegacy( BRICKS_SERVER.Func.L( "invalidRarity" ), 1, 3 )
                end
            end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ) )
        end

        timer.Simple( 0.02, function()
            if( not IsValid( self ) ) then return end
            
            loadModel( k+1 )
        end )
    end

    timer.Simple( 0.02, function()
        if( not IsValid( self ) ) then return end

        loadModel( 1 )
    end )
end

function PANEL:Paint( w, h )
    
end

vgui.Register( "bricks_server_config_itemrarities", PANEL, "DPanel" )