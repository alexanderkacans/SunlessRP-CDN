local PANEL = {}

function PANEL:Init()
    self:SetSize( ScrW(), ScrH() )
    self:Center()
    self:MakePopup()
    self:SetTitle( "" )
    self:SetDraggable( false )
    self:ShowCloseButton( false )

    self.mainPanel = vgui.Create( "DPanel", self )
    self.mainPanel:SetSize( (ScrW()*0.6)-BRICKS_SERVER.DEVCONFIG.MainNavWidth, ScrH()*0.65-50 )
    self.mainPanel:Center()
    self.mainPanel.headerHeight = 40
    self.mainPanel:DockPadding( 0, self.mainPanel.headerHeight, 0, 0 )
    self.mainPanel.Paint = function( self2, w, h )
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
        draw.RoundedBoxEx( 5, 0, 0, w, self.mainPanel.headerHeight, BRICKS_SERVER.Func.GetTheme( 0 ), true, true, false, false )
    
        local requestedPly = player.GetBySteamID64( self.requestedID64 or "" )
        if( requestedPly and IsValid( requestedPly ) ) then 
            draw.SimpleText( BRICKS_SERVER.Func.L( "profileView" ) .. " - " .. requestedPly:Nick(), "BRICKS_SERVER_Font30", 10, (self.mainPanel.headerHeight or 40)/2-2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
        else
            draw.SimpleText( BRICKS_SERVER.Func.L( "profileView" ), "BRICKS_SERVER_Font30", 10, (self.mainPanel.headerHeight or 40)/2-2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
        end
    end

    local closeButton = vgui.Create( "DButton", self.mainPanel )
	local size = 24
	closeButton:SetSize( size, size )
	closeButton:SetPos( self.mainPanel:GetWide()-size-((self.mainPanel.headerHeight-size)/2), (self.mainPanel.headerHeight/2)-(size/2) )
	closeButton:SetText( "" )
    local CloseMat = Material( "materials/bricks_server/close.png" )
    local textColor = BRICKS_SERVER.Func.GetTheme( 6 )
	closeButton.Paint = function( self2, w, h )
		if( self2:IsHovered() and !self2:IsDown() ) then
			surface.SetDrawColor( textColor.r*0.6, textColor.g*0.6, textColor.b*0.6 )
		elseif( self2:IsDown() || self2.m_bSelected ) then
			surface.SetDrawColor( textColor.r*0.8, textColor.g*0.8, textColor.b*0.8 )
		else
			surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
		end

		surface.SetMaterial( CloseMat )
		surface.DrawTexturedRect( 0, 0, w, h )
	end
    closeButton.DoClick = function()
        self:Remove()
    end

    self.contentsPanel = vgui.Create( "DPanel", self.mainPanel )
    self.contentsPanel:Dock( FILL )
    self.contentsPanel:DockMargin( 10, 10, 10, 10 )
    self.contentsPanel.Paint = function( self, w, h ) end 

    local loadingPanel = vgui.Create( "DPanel", self.contentsPanel )
    loadingPanel:Dock( FILL )
    local loadingIcon = Material( "materials/bricks_server/loading.png" )
    loadingPanel.Paint = function( self, w, h ) 
        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( loadingIcon )
        local size = 32
        surface.DrawTexturedRectRotated( w/2, h/2, size, size, -(CurTime() % 360 * 250) )

        draw.SimpleText( BRICKS_SERVER.Func.L( "loading" ), "BRICKS_SERVER_Font20", w/2, h/2+(size/2)+5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
    end 
end

function PANEL:RefreshProfile( requestedID64, profileTable )
    self.requestedID64 = requestedID64

    self.contentsPanel:Clear()

    local requestedPly = player.GetBySteamID64( requestedID64 or "" )
    if( not requestedPly or not IsValid( requestedPly ) ) then return end

    local profileSheet = vgui.Create( "bricks_server_colsheet_top", self.contentsPanel )
    profileSheet:Dock( FILL )
    profileSheet:DockMargin( 0, 0, 0, 0 )
    profileSheet.rounded = true
    profileSheet.pageClickFunc = function( page )
        self.page = page
    end

    local refreshButton = vgui.Create( "DButton", profileSheet.navigationBack )
    refreshButton:Dock( RIGHT )
    refreshButton:SetWide( profileSheet.navigationBack:GetTall() )
    refreshButton:SetText( "" )
    local changeAlpha = 0
    local refreshMat = Material( "materials/bricks_server/refresh.png" )
    refreshButton.Paint = function( self2, w, h ) 
        if( self2:IsDown() ) then
            changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
        elseif( self2:IsHovered() ) then
            changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
        else
            changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
        end
        
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
        surface.DrawRect( 0, 0, w, h )

        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

        surface.SetAlphaMultiplier( changeAlpha/255 )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 4 ) )
        surface.SetAlphaMultiplier( 1 )

        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
        surface.SetMaterial( refreshMat )
        local iconSize = 24
        surface.DrawTexturedRect( (h-iconSize)/2, (h/2)-(iconSize/2), iconSize, iconSize )
    end
    refreshButton.DoClick = function()
        net.Start( "BRS.Net.ProfileAdminRequest" )
            net.WriteString( requestedID64 )
        net.SendToServer()
    end

    local refreshCover = vgui.Create( "DPanel", profileSheet.navigationBack )
    refreshCover:Dock( RIGHT )
    refreshCover:SetWide( profileSheet.navigationBack:GetTall() )
    refreshCover.Paint = function( self2, w, h ) 
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
        surface.DrawRect( 0, 0, w, h )

        draw.RoundedBoxEx( 5, 0, 0, w-5, h, BRICKS_SERVER.Func.GetTheme( 3 ), false, true, false, true )
    end

    local profileMain = vgui.Create( "DPanel", profileSheet )
    profileMain:Dock( FILL )
    profileMain.Paint = function( self, w, h ) end 
    profileSheet:AddSheet( BRICKS_SERVER.Func.L( "statistics" ), profileMain )

    local profileModelBack = vgui.Create( "DPanel", profileMain )
    profileModelBack:Dock( LEFT )
    profileModelBack:DockMargin( 0, 0, 5, 0 )
    profileModelBack:SetWide( (self.mainPanel:GetWide()-20-5)/2 )
    local plyName = requestedPly:Nick() or BRICKS_SERVER.Func.L( "nil" )
    surface.SetFont( "BRICKS_SERVER_Font25" )
    local textX, textY = surface.GetTextSize( plyName )
    local donationRank
    for k, v in pairs( BRICKS_SERVER.CONFIG.GENERAL.Groups ) do
        if( BRICKS_SERVER.Func.IsInGroup( requestedPly, v[1] ) ) then
            donationRank = k
            break
        end
    end
    surface.SetFont( "BRICKS_SERVER_Font20" )
    local donationTextX, donationTextY = surface.GetTextSize( (BRICKS_SERVER.CONFIG.GENERAL.Groups[donationRank] or {})[1] or "" )
    donationTextX = donationTextX+10
    local totalW = textX+donationTextX+5
    profileModelBack.Paint = function( self2, w, h )
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

        draw.SimpleText( plyName, "BRICKS_SERVER_Font25", (w/2)-(totalW/2), h-(h/10), BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )

        if( BRICKS_SERVER.CONFIG.GENERAL.Groups[donationRank] ) then
            draw.RoundedBox( 5, (w/2)-(totalW/2)+textX+5, h-(h/10)-(donationTextY/2)+1.5, donationTextX, donationTextY, (BRICKS_SERVER.CONFIG.GENERAL.Groups[donationRank][3] or BRICKS_SERVER.Func.GetTheme( 5 )) )
            draw.SimpleText( BRICKS_SERVER.CONFIG.GENERAL.Groups[donationRank][1], "BRICKS_SERVER_Font20", (w/2)-(totalW/2)+textX+5+(donationTextX/2), h-(h/10), BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
    end

    local profileModelBack = vgui.Create( "DModelPanel", profileModelBack )
    profileModelBack:Dock( FILL )
    profileModelBack:DockMargin( 10, 10, 10, 10 )
    profileModelBack:SetModel( requestedPly:GetModel() or "" )
    function profileModelBack:LayoutEntity( Entity ) return end

    local dataToShow = {
        [1] = { BRICKS_SERVER.Func.L( "name" ), requestedPly:Nick() },
        [2] = { BRICKS_SERVER.Func.L( "steamID64" ), requestedID64 },
        [3] = { BRICKS_SERVER.Func.L( "donationRank" ), (BRICKS_SERVER.CONFIG.GENERAL.Groups[donationRank] or {})[1] or BRICKS_SERVER.Func.L( "none" ) },
        [4] = { BRICKS_SERVER.Func.L( "staffRank" ), BRICKS_SERVER.Func.GetAdminGroup( requestedPly ) }
    }

    if( DarkRP ) then
        table.insert( dataToShow, { BRICKS_SERVER.Func.L( "currentJob" ), requestedPly:getDarkRPVar( "job" ) or BRICKS_SERVER.Func.L( "none" ) } )
        table.insert( dataToShow, { BRICKS_SERVER.Func.L( "wallet" ), DarkRP.formatMoney( requestedPly:getDarkRPVar( "money" ) or 0 ) } )
    end

    if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
        table.insert( dataToShow, { BRICKS_SERVER.Func.L( "level" ), profileTable.level or 0 } )
        table.insert( dataToShow, { BRICKS_SERVER.Func.L( "experience" ), string.Comma( math.Round( profileTable.experience or 0 ) ) } )
    end

    if( BRICKS_SERVER.Func.IsSubModuleEnabled( "default", "currencies" ) ) then
        for k, v in pairs( BRICKS_SERVER.CONFIG.CURRENCIES or {} ) do
            if( not BRICKS_SERVER.DEVCONFIG.Currencies["custom_" .. k] ) then continue end

            local currencyTable = BRICKS_SERVER.DEVCONFIG.Currencies["custom_" .. k]

            table.insert( dataToShow, { v.Name, currencyTable.formatFunction( (profileTable.currencies or {})[k] or 0 ) } )
        end
    end
    
    local profileInfoBack = vgui.Create( "DPanel", profileMain )
    profileInfoBack:Dock( FILL )
    local initialSpacer = 50
    local spacing = 30
    profileInfoBack.Paint = function( self2, w, h )
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

        for k, v in ipairs( dataToShow ) do
            local pos = k
            if( k % 2 == 0 ) then
                pos = k-1
                draw.SimpleText( v[1], "BRICKS_SERVER_Font25", (w/4)*3, initialSpacer+(spacing*(pos-1)), BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                draw.SimpleText( v[2], "BRICKS_SERVER_Font20", (w/4)*3, initialSpacer+(spacing*(pos-1))+20, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            else
                draw.SimpleText( v[1], "BRICKS_SERVER_Font25", (w/4)*1, initialSpacer+(spacing*(pos-1)), BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                draw.SimpleText( v[2], "BRICKS_SERVER_Font20", (w/4)*1, initialSpacer+(spacing*(pos-1))+20, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end
        end
    end

    if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "logging" ) ) then    
        local profileLogs = vgui.Create( "bricks_server_scrollpanel", profileSheet )
        profileLogs:Dock( FILL )
        profileLogs.Paint = function( self, w, h ) end 
        profileSheet:AddSheet( BRICKS_SERVER.Func.L( "playerLogs" ), profileLogs, ((self.page or "") == BRICKS_SERVER.Func.L( "playerLogs" ) ) )

        function self.FillLogs()
            profileLogs:Clear()

            local logsRequest = vgui.Create( "DButton", profileLogs )
            logsRequest:Dock( TOP )
            logsRequest:DockMargin( 0, 0, 0, 5 )
            logsRequest:SetTall( 65 )
            logsRequest:DockPadding( 0, 0, 30, 0 )
            logsRequest:SetText( "" )
            local changeAlpha = 0
            logsRequest.Paint = function( self2, w, h ) 
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

                draw.SimpleText( BRICKS_SERVER.Func.L( "deleteLogs" ), "BRICKS_SERVER_Font33", 15, 5, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                draw.SimpleText( BRICKS_SERVER.Func.L( "xLogs", (#(profileTable.logs or {}) or 0) ), "BRICKS_SERVER_Font20", 18, 32, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )

                if( self2:IsDown() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 125 )
                elseif( self2:IsHovered() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 95 )
                else
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
                end

                surface.SetAlphaMultiplier( changeAlpha/255 )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
                surface.SetAlphaMultiplier( 1 )
            end
            logsRequest.DoClick = function()
                net.Start( "BRS.Net.DeleteLogsAdmin" )
                    net.WriteString( requestedID64 )
                net.SendToServer()
            end

            local sortedLogs = table.Copy( profileTable.logs or {} )
            table.sort( sortedLogs, function(a, b) return a[1] > b[1] end )

            for k, v in pairs( sortedLogs or {} ) do
                if( not BRICKS_SERVER.DEVCONFIG.LogTypes[v[2] or ""] ) then continue end

                local entryBack = vgui.Create( "DPanel", profileLogs )
                entryBack:Dock( TOP )
                entryBack:DockMargin( 0, 0, 0, 5 )
                entryBack:SetTall( 65 )
                entryBack:DockPadding( 0, 0, 30, 0 )
                local dateTime = os.date( "%H:%M:%S - %d/%m/%Y" , v[1] )
                local text = ""
                if( BRICKS_SERVER.DEVCONFIG.LogTypes[v[2] or ""].FormatInfo ) then
                    text = BRICKS_SERVER.DEVCONFIG.LogTypes[v[2] or ""].FormatInfo( v[3] )
                end
                entryBack.Paint = function( self2, w, h )
                    draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

                    draw.SimpleText( dateTime, "BRICKS_SERVER_Font33", 15, 5, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                    draw.SimpleText( text, "BRICKS_SERVER_Font20", 18, 32, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                end
            end
        end
        self.FillLogs()
    end
end

function PANEL:Paint( w, h )
    BRICKS_SERVER.Func.DrawBlur( self, 4, 4 )
end

vgui.Register( "bricks_server_admin_profile", PANEL, "DFrame" )