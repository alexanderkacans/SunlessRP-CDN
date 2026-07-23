local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel( f4Panel, sheetButton )
    if( not IsValid( f4Panel ) ) then return end

    function f4Panel.FillProfile()
        if( not IsValid( self ) ) then return end
        
        self:Clear()
        
        local profileModelBack = vgui.Create( "DPanel", self )
        profileModelBack:Dock( LEFT )
        profileModelBack:DockMargin( 0, 0, 5, 0 )
        profileModelBack:SetWide( (f4Panel:GetWide()-BRICKS_SERVER.DEVCONFIG.MainNavWidth-20-5)/2 )
        local plyName = LocalPlayer():Nick()
        surface.SetFont( "BRICKS_SERVER_Font25" )
        local textX, textY = surface.GetTextSize( plyName )
        local donationRank
        for k, v in pairs( BRICKS_SERVER.CONFIG.GENERAL.Groups ) do
            if( BRICKS_SERVER.Func.IsInGroup( LocalPlayer(), v[1] ) ) then
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
                draw.RoundedBox( 5, (w/2)-(totalW/2)+textX+5, h-(h/10)-(donationTextY/2)+1.5, donationTextX, donationTextY, (BRICKS_SERVER.CONFIG.GENERAL.Groups[donationRank][3] or BRICKS_SERVER.Func.GetTheme( 5 ))  )
                draw.SimpleText( BRICKS_SERVER.CONFIG.GENERAL.Groups[donationRank][1], "BRICKS_SERVER_Font20", (w/2)-(totalW/2)+textX+5+(donationTextX/2), h-(h/10), BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end
        end

        local profileModelBack = vgui.Create( "DModelPanel", profileModelBack )
        profileModelBack:Dock( FILL )
        profileModelBack:DockMargin( 10, 10, 10, 10 )
        profileModelBack:SetModel( LocalPlayer():GetModel() or "" )
        function profileModelBack:LayoutEntity( Entity ) return end

        local dataToShow = {
            [1] = { BRICKS_SERVER.Func.L( "name" ), LocalPlayer():Nick() },
            [2] = { BRICKS_SERVER.Func.L( "steamID64" ), LocalPlayer():SteamID64() },
            [3] = { BRICKS_SERVER.Func.L( "donationRank" ), (BRICKS_SERVER.CONFIG.GENERAL.Groups[donationRank] or {})[1] or BRICKS_SERVER.Func.L( "none" ) },
            [4] = { BRICKS_SERVER.Func.L( "staffRank" ), BRICKS_SERVER.Func.GetAdminGroup( LocalPlayer() ) }
        }

        if( DarkRP ) then
            table.insert( dataToShow, { BRICKS_SERVER.Func.L( "currentJob" ), LocalPlayer():getDarkRPVar( "job" ) or BRICKS_SERVER.Func.L( "none" ) } )
            table.insert( dataToShow, { BRICKS_SERVER.Func.L( "wallet" ), DarkRP.formatMoney( LocalPlayer():getDarkRPVar( "money" ) or 0 ) } )
        end
    
        if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
            table.insert( dataToShow, { BRICKS_SERVER.Func.L( "level" ), BRS_LEVEL or 0 } )
            table.insert( dataToShow, { BRICKS_SERVER.Func.L( "experience" ), string.Comma( math.Round( BRS_EXPERIENCE or 0 ) ) } )
        end

        if( BRICKS_SERVER.Func.IsSubModuleEnabled( "default", "currencies" ) ) then
            for k, v in pairs( BRICKS_SERVER.CONFIG.CURRENCIES or {} ) do
                if( not BRICKS_SERVER.DEVCONFIG.Currencies["custom_" .. k] ) then continue end

                local currencyTable = BRICKS_SERVER.DEVCONFIG.Currencies["custom_" .. k]

                table.insert( dataToShow, { v.Name, currencyTable.formatFunction( currencyTable.getFunction( LocalPlayer() ) or 0 ) } )
            end
        end
        
        local profileInfoBack = vgui.Create( "DPanel", self )
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
    end
    f4Panel.FillProfile()

    hook.Add( "OnPlayerChangedTeam", "BRS.OnPlayerChangedTeam.F4Profile", function()
        timer.Simple( 1, function()
            if( f4Panel.FillProfile ) then
                f4Panel.FillProfile()
            end
        end )
    end )
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_profile", PANEL, "DPanel" )