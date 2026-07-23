local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel()
    function self.RefreshPanel()
        self:Clear()

        self.slots = nil
        if( self.grid and IsValid( self.grid ) ) then
            self.grid:Remove()
        end

        BRICKS_SERVER.Func.FillVariableConfigs( self, "GENERAL", "GENERAL", { ["Admin Permissions"] = { function()
            BRICKS_SERVER.Func.CreateGroupEditor( (BS_ConfigCopyTable.GENERAL.AdminPermissions or {}), function( userGroups ) 
                BS_ConfigCopyTable.GENERAL.AdminPermissions = userGroups or {}
                self.RefreshPanel()
                BRICKS_SERVER.Func.ConfigChange( "GENERAL" )
            end, function() end, true )
        end, BRICKS_SERVER.Func.L( "xAdminGroups", table.Count( BS_ConfigCopyTable.GENERAL.AdminPermissions or {} ) ) } } )
    end
    self.RefreshPanel()
end

function PANEL:Paint( w, h )
    
end

vgui.Register( "bricks_server_config_general", PANEL, "bricks_server_scrollpanel" )