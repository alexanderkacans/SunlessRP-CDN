local PANEL = {}

function PANEL:Init()
    hook.Add( "BRS.Hooks.ConfigReceived", self, function()
        if( IsValid( self ) and self.loadedPreviously ) then
            self:FillPanel()
        else
            hook.Remove( "BRS.Hooks.ConfigReceived", self )
        end
    end )
end

function PANEL:FillPanel()
    self.loadedPreviously = true
    self:Clear()

    self.colSheet = vgui.Create( "bricks_server_colsheet_left", self )
    self.colSheet:Dock( FILL )
    self.colSheet.OnNavCollapse = function( name, collapsed )
        BRICKS_SERVER.Func.SetClientCookie( name, "bool", collapsed )
    end
    self.colSheet.OnSheetChange = function( name )
        BRICKS_SERVER.Func.SetClientCookie( "configpage", "string", name )
    end

    self.colSheet:CreateSearchBar()

    BS_ConfigCopyTable = table.Copy( BRICKS_SERVER.CONFIG )
    BS_ConfigsChanged = {}

    local sortedConfig = table.Copy( BRICKS_SERVER.ConfigPages )

    table.SortByMember( sortedConfig, 1, true )

    for k, v in pairs( sortedConfig ) do
        if( v[4] and not v[4]() ) then continue end

        local addonTable = BRICKS_SERVER.DLCMODULES[v[3] or ""] or {}

        local adminConfigPage = vgui.Create( v[2], self.colSheet )
        if( not IsValid( adminConfigPage ) ) then continue end
        adminConfigPage:Dock( FILL )
        adminConfigPage:DockMargin( (adminConfigPage.margin or 10), (adminConfigPage.margin or 10), (adminConfigPage.margin or 10), (adminConfigPage.margin or 10) )
        if( adminConfigPage.FillPanel ) then
            self.colSheet:AddSheet( v[1], adminConfigPage, false, function() 
                adminConfigPage:FillPanel()
            end, addonTable.Name, addonTable.Color )

            hook.Add( "BRS.Hooks.RefreshConfig", "BRS.Hooks.RefreshConfig." .. tostring( adminConfigPage ), function()
                if( IsValid( adminConfigPage ) and adminConfigPage.RefreshPanel ) then
                    adminConfigPage.RefreshPanel()
                end
            end )
        else
            self.colSheet:AddSheet( v[1], adminConfigPage, false, false, addonTable.Name, addonTable.Color )
        end
    end

    self.colSheet:FinishAddingSheets()

    for k, v in pairs( self.colSheet.Categories ) do
        if( BRICKS_SERVER.Func.GetClientCookie( v:GetLabel(), "bool" ) ) then
            v:SetExpanded( false )
        end
    end

    self.colSheet:SetActiveSheet( BRICKS_SERVER.Func.GetClientCookie( "configpage", "string" ) )
end

function PANEL:Paint( w, h )
    
end

vgui.Register( "bricks_server_config", PANEL, "bricks_server_colsheet_left" )