local PANEL = {}

function PANEL:Init()
    self:SetSize( ScrW()*0.6, ScrH()*0.65 )
    self:Center()
    self:SetHeader( BRICKS_SERVER.CONFIG.GENERAL["Server Name"] )
    self.removeOnClose = false
    self.centerOnSizeChanged = true

    self.onCloseFunc = function()
        if( BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) ) then
            BRICKS_SERVER.Func.SendAdminConfig()
        end
    end

    if( BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) ) then
		BS_ConfigCopyTable = table.Copy( BRICKS_SERVER.CONFIG )
	end
end

function PANEL:FillTabs()
    if( IsValid( self.sheet ) ) then
        if( IsValid( self.sheet.ActiveButton ) ) then
            self.previousSheet = self.sheet.ActiveButton.label
        end
        self.sheet:Remove()
    end

    local originalW, originalH = ScrW()*0.6, ScrH()*0.65 
    local newW = originalW+200

    self.sheet = vgui.Create( "bricks_server_colsheet", self )
    self.sheet:Dock( FILL )
    self.sheet.OnSheetChange = function( active )
        if( active.label == BRICKS_SERVER.Func.L( "config" ) and (self:GetWide() != newW or self:GetTall() != originalH) ) then
            self:SizeTo( newW, originalH, 0.2 )
        elseif( active.label != BRICKS_SERVER.Func.L( "config" ) and (self:GetWide() != originalW or self:GetTall() != originalH) ) then
            self:SizeTo( originalW, originalH, 0.2 )
        end
    end

    local donationRank
    for k, v in pairs( BRICKS_SERVER.CONFIG.GENERAL.Groups ) do
        if( BRICKS_SERVER.Func.IsInGroup( LocalPlayer(), v[1] ) ) then
            donationRank = k
            break
        end
    end

    local height = 55
    local avatarBackSize = height
    local textStartPos = 65
    
    local avatarBack = vgui.Create( "DPanel", self.sheet.Navigation )
    avatarBack:Dock( TOP )
    avatarBack:DockMargin( 10, 10, 0, 10 )
    avatarBack:SetTall( height )
    avatarBack.Paint = function( self2, w, h )
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
        draw.NoTexture()
        BRICKS_SERVER.Func.DrawCircle( (h-avatarBackSize)/2+(avatarBackSize/2), h/2, avatarBackSize/2, 45 )

        draw.SimpleText( LocalPlayer():Nick(), "BRICKS_SERVER_Font23", textStartPos, h/2+2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_BOTTOM )

        if( BRICKS_SERVER.CONFIG.GENERAL.Groups[donationRank] ) then
            draw.SimpleText( BRICKS_SERVER.CONFIG.GENERAL.Groups[donationRank][1], "BRICKS_SERVER_Font20", textStartPos, h/2-2, (BRICKS_SERVER.CONFIG.GENERAL.Groups[donationRank][3] or BRICKS_SERVER.Func.GetTheme( 5 )), 0, 0 )
        else
            draw.SimpleText( BRICKS_SERVER.Func.GetAdminGroup( LocalPlayer() ), "BRICKS_SERVER_Font20", textStartPos, h/2-2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
        end
    end

    local distance = 2

    local avatarIcon = vgui.Create( "bricks_server_circle_avatar" , avatarBack )
    avatarIcon:SetPos( (height-avatarBackSize)/2+distance, (height-avatarBackSize)/2+distance )
    avatarIcon:SetSize( avatarBackSize-(2*distance), avatarBackSize-(2*distance) )
    avatarIcon:SetPlayer( LocalPlayer(), 64 )

    local profilePage = vgui.Create( "bricks_server_profile", self.sheet )
    profilePage:Dock( FILL )
    profilePage:DockMargin( 10, 10, 10, 10 )
    profilePage:FillPanel( self )
    profilePage.Paint = function( self, w, h ) end 
    self.sheet:AddSheet( BRICKS_SERVER.Func.L( "profile" ), profilePage, false, "profile_24.png" )

    local settingsPage = vgui.Create( "bricks_server_settings", self.sheet )
    settingsPage:Dock( FILL )
    settingsPage:DockMargin( 10, 10, 10, 10 )
    settingsPage.Paint = function( self, w, h ) end 
    self.sheet:AddSheet( BRICKS_SERVER.Func.L( "settings" ), settingsPage, false, "settings_24.png" )

    self.adminCreated = nil
    
    function self.RefreshAdminPerms()
        if( BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) and not self.adminCreated ) then
            self.sheet:AddLinebreak()
            
            -- PLAYERS PAGE --
            local adminPlayersPanelBack = vgui.Create( "bricks_server_admin", self.sheet )
            adminPlayersPanelBack:Dock( FILL )
            adminPlayersPanelBack.Paint = function( self, w, h ) end 
            self.sheet:AddSheet( BRICKS_SERVER.Func.L( "players" ), adminPlayersPanelBack, false, "players_24.png" )

            -- MODULES PAGE --
            local adminModulesPanel = vgui.Create( "bricks_server_config_modules", self.sheet )
            adminModulesPanel:Dock( FILL )
            adminModulesPanel.Paint = function( self, w, h ) end 
            self.sheet:AddSheet( BRICKS_SERVER.Func.L( "modules" ), adminModulesPanel, function()
                adminModulesPanel:FillPanel() 
            end, "modules_24.png" )

            -- CONFIG PAGE --
            local adminConfigPanel = vgui.Create( "bricks_server_config", self.sheet )
            adminConfigPanel:Dock( FILL )
            adminConfigPanel.Paint = function( self, w, h ) end 
            self.sheet:AddSheet( BRICKS_SERVER.Func.L( "config" ), adminConfigPanel, function()
                adminConfigPanel:FillPanel() 
            end, "admin_24.png" )

            self.adminCreated = true
        end
    end
    self.RefreshAdminPerms()

    if( self.previousSheet ) then
        self.sheet:SetActiveSheet( self.previousSheet )
    end
end

vgui.Register( "bricks_server_menu", PANEL, "bricks_server_dframe" )