local PANEL = {}

function PANEL:Init()
    self.margin = 0

    local panelWide = ScrW()*0.6-BRICKS_SERVER.DEVCONFIG.MainNavWidth
    local panelTall = (ScrH()*0.65)-40

    local function CreateEditPopout( languageKey )
        if( IsValid( self.popout ) ) then
            self.popout:Remove()
        end

        local popoutClose = vgui.Create( "DPanel", self )
        popoutClose:SetSize( panelWide, panelTall )
        popoutClose:SetAlpha( 0 )
        popoutClose:AlphaTo( 255, 0.2 )
        popoutClose.Paint = function( self2, w, h )
            surface.SetDrawColor( 0, 0, 0, 150 )
            surface.DrawRect( 0, 0, w, h )
            BRICKS_SERVER.Func.DrawBlur( self2, 2, 2 )
        end

        local popoutWide, popoutTall = panelWide-panelWide*0.1, panelTall-panelWide*0.1

        self.popout = vgui.Create( "DPanel", self )
        self.popout:SetSize( 0, 0 )
        self.popout:SizeTo( popoutWide, popoutTall, 0.2 )
        self.popout.Paint = function( self2, w, h )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
        end
        self.popout.OnSizeChanged = function( self2 )
            self2:SetPos( (panelWide/2)-(self2:GetWide()/2), (panelTall/2)-(self2:GetTall()/2) )
        end
        self.popout.ClosePopout = function()
            if( IsValid( self.popout ) ) then
                self.popout:SizeTo( 0, 0, 0.2, 0, -1, function()
                    if( IsValid( self.popout ) ) then
                        self.popout:Remove()
                    end
                end )
            end

            popoutClose:AlphaTo( 0, 0.2, 0, function()
                if( IsValid( popoutClose ) ) then
                    popoutClose:Remove()
                end
            end )
        end

        local popoutCloseButton = vgui.Create( "DButton", self.popout )
        popoutCloseButton:Dock( BOTTOM )
        popoutCloseButton:SetTall( 40 )
        popoutCloseButton:SetText( "" )
        popoutCloseButton:DockMargin( 25, 0, 25, 25 )
        local changeAlpha = 0
        popoutCloseButton.Paint = function( self2, w, h )
            if( not self2:IsDown() and self2:IsHovered() ) then
                changeAlpha = math.Clamp( changeAlpha+10, 0, 75 )
            else
                changeAlpha = math.Clamp( changeAlpha-10, 0, 75 )
            end
            
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )
    
            surface.SetAlphaMultiplier( changeAlpha/255 )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 4 ) )
            surface.SetAlphaMultiplier( 1 )

            BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 4 ) )
            
            draw.SimpleText( BRICKS_SERVER.Func.L( "cancel" ), "BRICKS_SERVER_Font20", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
        popoutCloseButton.DoClick = self.popout.ClosePopout

        local originalLanguageTable = table.Copy( BRICKS_SERVER.Languages[languageKey] or {} )

        local topBar = vgui.Create( "DPanel", self.popout )
        topBar:Dock( TOP )
        topBar:SetTall( 40 )
        topBar:DockMargin( 25, 25, 25, 0 )
        topBar.Paint = function( self2, w, h ) end

        local buttons = {
            {
                Title = "Auto Fill",
                Color = Color( 46, 204, 113 ),
                DoClick = function()
                    local options = { 
                        ["af"] = "Afrikaans",
                        ["ga"] = "Irish",
                        ["sq"] = "Albanian",
                        ["it"] = "Italian",
                        ["ja"] = "Japanese",
                        ["az"] = "Azerbaijani",
                        ["kn"] = "Kannada",
                        ["eu"] = "Basque",
                        ["ko"] = "Korean",
                        ["bn"] = "Bengali",
                        ["la"] = "Latin",
                        ["be"] = "Belarusian",
                        ["lv"] = "Latvian",
                        ["bg"] = "Bulgarian",
                        ["ca"] = "Catalan",
                        ["mk"] = "Macedonian",
                        ["zh-CN"] = "Chinese Simplified",
                        ["ms"] = "Malay",
                        ["zh-TW"] = "Chinese Traditional",
                        ["mt"] = "Maltese",
                        ["hr"] = "Croatian",
                        ["no"] = "Norwegian",
                        ["cs"] = "Czech",
                        ["fa"] = "Persian",
                        ["da"] = "Danish",
                        ["pl"] = "Polish",
                        ["nl"] = "Dutch",
                        ["ro"] = "Romanian",
                        ["eo"] = "Esperanto",
                        ["ru"] = "Russian",
                        ["et"] = "Estonian",
                        ["sr"] = "Serbian",
                        ["tl"] = "Filipino",
                        ["sk"] = "Slovak",
                        ["fi"] = "Finnish",
                        ["sl"] = "Slovenian",
                        ["fr"] = "French",
                        ["es"] = "Spanish",
                        ["gl"] = "Galician",
                        ["sw"] = "Swahili",
                        ["ka"] = "Georgian",
                        ["de"] = "German",
                        ["ta"] = "Tamil",
                        ["el"] = "Greek",
                        ["te"] = "Telugu",
                        ["gu"] = "Gujarati",
                        ["th"] = "Thai",
                        ["ht"] = "Haitian Creole",
                        ["tr"] = "Turkish",
                        ["iw"] = "Hebrew",
                        ["uk"] = "Ukrainian",
                        ["hi"] = "Hindi",
                        ["ur"] = "Urdu",
                        ["hu"] = "Hungarian",
                        ["vi"] = "Vietnamese",
                        ["is"] = "Icelandic",
                        ["cy"] = "Welsh",
                        ["id"] = "Indonesian",
                        ["yi"] = "Yiddish"
                    }
                    for k, v in pairs( {} ) do
                        options[k] = k
                    end
                    
                    BRICKS_SERVER.Func.ComboRequest( BRICKS_SERVER.Func.L( "admin" ), "What language would you like to auto fill?", "None", options, function( value, data ) 
                        if( options[data] ) then
                            local stringsToTranslate = {}
                            for k, v in pairs( BRICKS_SERVER.Languages["english"] ) do
                                local textEntry = self.popout.textEntries[k]
        
                                if( not IsValid( textEntry ) ) then continue end
        
                                table.insert( stringsToTranslate, { k, v, textEntry } )
                            end
        
                            local function translateNext()
                                if( not IsValid( self ) or not self:IsVisible() ) then return end
        
                                if( #stringsToTranslate <= 0 ) then return end
        
                                local nextStringTable = stringsToTranslate[1]
        
                                if( not nextStringTable ) then return end
        
                                if( not IsValid( nextStringTable[3] ) ) then
                                    table.remove( stringsToTranslate, 1 )
                                    translateNext()
                                    return
                                end
        
                                nextStringTable[3]:GetParent().translating = true
        
                                BRICKS_SERVER.Func.GetTranslatedString( data, nextStringTable[2], function( translatedString, errorMsg )
                                    if( not translatedString or errorMsg or not IsValid( nextStringTable[3] ) ) then
                                        print( "TRANSLATING ERROR: " .. (errorMsg or "UNKNOWN") )
        
                                        BRICKS_SERVER.Func.Message( "Your IP has been temporarily blocked by Google, please try again later.", BRICKS_SERVER.Func.L( "admin" ), "Confirm" )
        
                                        nextStringTable[3]:GetParent().translating = nil
                                        return
                                    else
                                        nextStringTable[3]:SetValue( translatedString )
                                    end
        
                                    table.remove( stringsToTranslate, 1 )
        
                                    timer.Simple( 0.5, function() 
                                        if( IsValid( nextStringTable[3] ) ) then
                                            nextStringTable[3]:GetParent().translating = nil
                                        end
        
                                        translateNext() 
                                    end )
                                end )
                            end
                            translateNext()
                        else
                            notification.AddLegacy( BRICKS_SERVER.Func.L( "invalidType" ), 1, 3 )
                        end
                    end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), true )
                end
            },
            {
                Title = "Reset Changes",
                Color = Color( 231, 76, 60 ),
                DoClick = function()
                    if( not BS_ConfigCopyTable.LANGUAGE.Languages or not BS_ConfigCopyTable.LANGUAGE.Languages[languageKey] ) then return end
        
                    BS_ConfigCopyTable.LANGUAGE.Languages[languageKey][2] = {}
        
                    BRICKS_SERVER.Func.ConfigChange( "LANGUAGE" )
                    self.popout.RefreshLanguageStrings()
                end
            },
        }

        if( isnumber( languageKey ) ) then
            table.insert( buttons, {
                Title = "Delete",
                Color = Color( 231, 76, 60 ),
                DoClick = function()
                    if( not BS_ConfigCopyTable.LANGUAGE.Languages or not BS_ConfigCopyTable.LANGUAGE.Languages[languageKey] ) then return end
        
                    if( isnumber( languageKey ) ) then
                        BS_ConfigCopyTable.LANGUAGE.Languages[languageKey] = nil
                    end
        
                    BRICKS_SERVER.Func.ConfigChange( "LANGUAGE" )
                    self.popout.ClosePopout()

                    self.RefreshPanel()
                end
            } )

            table.insert( buttons, {
                Title = "Edit Name",
                Color = Color( 127, 140, 141 ),
                DoClick = function()
                    if( not BS_ConfigCopyTable.LANGUAGE.Languages or not BS_ConfigCopyTable.LANGUAGE.Languages[languageKey] ) then return end
        
                    if( isnumber( languageKey ) ) then
                        BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "newNameQuery" ), (BS_ConfigCopyTable.LANGUAGE.Languages[languageKey][1] or ""), function( text ) 
                            BS_ConfigCopyTable.LANGUAGE.Languages[languageKey][1] = text
                            self.RefreshPanel()
                            BRICKS_SERVER.Func.ConfigChange( "LANGUAGE" )
                        end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), false )
                    end
                end
            } )
        end

        for k, v in ipairs( buttons ) do
            surface.SetFont( "BRICKS_SERVER_Font20" )
            local textX, textY = surface.GetTextSize( v.Title )
    
            local button = vgui.Create( "DButton", topBar )
            button:Dock( RIGHT )
            button:DockMargin( 5, 0, 0, 0 )
            button:SetText( "" )
            button:SetWide( textX+20 )
            local changeAlpha = 0
            button.Paint = function( self2, w, h )
                if( self2:IsDown() or self2.m_bSelected ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 5, 50 )
                elseif( self2:IsHovered() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 5, 25 )
                else
                    changeAlpha = math.Clamp( changeAlpha-10, 5, 50 )
                end
        
                surface.SetAlphaMultiplier( changeAlpha/255 )
                draw.RoundedBox( 5, 0, 0, w, h, v.Color or BRICKS_SERVER.Func.GetTheme( 4 ) )
                surface.SetAlphaMultiplier( 1 )
        
                draw.SimpleText( v.Title, "BRICKS_SERVER_Font20", 10, h/2, (v.Color or BRICKS_SERVER.Func.GetTheme( 5 )), 0, TEXT_ALIGN_CENTER )
            end
            button.DoClick = v.DoClick
        end

        local searchBarBack = vgui.Create( "DPanel", topBar )
        searchBarBack:Dock( FILL )
        local search = Material( "materials/bricks_server/search.png" )
        local Alpha = 0
        local Alpha2 = 20
        local color1 = BRICKS_SERVER.Func.GetTheme( 2 )
        local searchBar
        searchBarBack.Paint = function( self2, w, h )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )
    
            if( searchBar:IsEditing() ) then
                Alpha = math.Clamp( Alpha+5, 0, 100 )
                Alpha2 = math.Clamp( Alpha2+20, 20, 255 )
            else
                Alpha = math.Clamp( Alpha-5, 0, 100 )
                Alpha2 = math.Clamp( Alpha2-20, 20, 255 )
            end
            
            draw.RoundedBox( 5, 0, 0, w, h, Color( color1.r, color1.g, color1.b, Alpha ) )
        
            surface.SetDrawColor( 255, 255, 255, Alpha2 )
            surface.SetMaterial(search)
            local size = 24
            surface.DrawTexturedRect( w-size-(h-size)/2, (h-size)/2, size, size )
        end
    
        searchBar = vgui.Create( "bricks_server_search", searchBarBack )
        searchBar:Dock( FILL )
        searchBar:SetFont( "BRICKS_SERVER_Font20" )

        local scrollPanel = vgui.Create( "bricks_server_scrollpanel_bar", self.popout )
        scrollPanel:Dock( FILL )
        scrollPanel:DockMargin( 25, 10, 25, 10 )

        function self.popout.RefreshLanguageStrings()
            scrollPanel:Clear()

            self.popout.textEntries = {}

            local languageTable = {}
            if( (BS_ConfigCopyTable.LANGUAGE.Languages or {})[languageKey] ) then
                table.Merge( languageTable, (BS_ConfigCopyTable.LANGUAGE.Languages or {})[languageKey][2] or {} )
            end

            local count = 0
            local languageStringCount = table.Count( BRICKS_SERVER.Languages["english"] )
            for k, v in pairs( BRICKS_SERVER.Languages["english"] ) do
                if( (searchBar:GetValue() or "") != "" and not string.find( string.lower( v ), string.lower( searchBar:GetValue() or "" ) ) and not string.find( string.lower( languageTable[k] or v ), string.lower( searchBar:GetValue() or "" ) ) ) then
                    continue
                end

                count = count+1

                local currentCount = count

                local languageBack = vgui.Create( "DPanel", scrollPanel )
                languageBack:Dock( TOP )
                languageBack:DockMargin( 0, 0, 10, 0 )
                languageBack:SetTall( 40 )
                languageBack.Paint = function( self2, w, h )
                    if( currentCount == 1 ) then
                        draw.RoundedBoxEx( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ), true, true, false, false )
                    elseif( currentCount >= languageStringCount ) then
                        draw.RoundedBoxEx( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ), false, false, true, true )
                    else
                        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
                        surface.DrawRect( 0, 0, w, h )
                    end

                    if( self2.translating ) then
                        if( currentCount == 1 ) then
                            draw.RoundedBoxEx( 5, w/2+1, 0, w/2-1, h, BRICKS_SERVER.Func.GetTheme( 3 ), false, true, false, false )
                        elseif( currentCount >= languageStringCount ) then
                            draw.RoundedBoxEx( 5, w/2+1, 0, w/2-1, h, BRICKS_SERVER.Func.GetTheme( 3 ), false, false, false, true )
                        else
                            surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3 ) )
                            surface.DrawRect( w/2+1, 0, w/2-1, h )
                        end
                    end

                    if( currentCount < languageStringCount ) then
                        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 0 ) )
                        surface.DrawRect( 0, h-1, w, 1 )
                    end

                    surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 0 ) )
                    surface.DrawRect( w/2, 0, 1, h )
        
                    draw.SimpleText( v, "BRICKS_SERVER_Font20", 10, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
                end

                local languageTextEntry = vgui.Create( "bricks_server_textentry", languageBack )
                languageTextEntry:Dock( RIGHT )
                languageTextEntry:DockMargin( 0, 0, 10, 0 )
                languageTextEntry:SetWide( (popoutWide-50-20-30)/2 )
                languageTextEntry:SetValue( languageTable[k] or v )
                languageTextEntry:SetFont( "BRICKS_SERVER_Font20" )
                languageTextEntry:SetUpdateOnType( true )
                languageTextEntry.OnValueChange = function( self2, value )
                    if( not BS_ConfigCopyTable.LANGUAGE.Languages ) then
                        BS_ConfigCopyTable.LANGUAGE.Languages = {}
                    end

                    if( not BS_ConfigCopyTable.LANGUAGE.Languages[languageKey] ) then
                        BS_ConfigCopyTable.LANGUAGE.Languages[languageKey] = { false, {} }
                    end

                    if( languageTextEntry:GetValue() != originalLanguageTable[k] ) then
                        BS_ConfigCopyTable.LANGUAGE.Languages[languageKey][2][k] = languageTextEntry:GetValue()
                    else
                        BS_ConfigCopyTable.LANGUAGE.Languages[languageKey][2][k] = nil
                    end
        
                    BRICKS_SERVER.Func.ConfigChange( "LANGUAGE" )
                end

                self.popout.textEntries[k] = languageTextEntry
            end
        end
        self.popout.RefreshLanguageStrings()

        searchBar.OnChange = function()
            self.popout.RefreshLanguageStrings()
        end
    end

    local scrollPanel = vgui.Create( "bricks_server_scrollpanel", self )
    scrollPanel:Dock( FILL )
    scrollPanel:DockMargin( 10, 10, 10, 10 )

    local languageSpacing = 10
    local gridWide = (ScrW()*0.6)-BRICKS_SERVER.DEVCONFIG.MainNavWidth-20
    local slotSize = 320
    local slotsWide = math.floor( gridWide/slotSize )
    local actualSlotSize = (gridWide-((slotsWide-1)*languageSpacing))/slotsWide

    local slotTall = 125
    local languageGrid = vgui.Create( "DIconLayout", scrollPanel )
    languageGrid:Dock( TOP )
    languageGrid:SetSpaceY( languageSpacing )
    languageGrid:SetSpaceX( languageSpacing )
    languageGrid:SetTall( slotTall )

    function self.RefreshPanel()
        languageGrid:Clear()

        local languages = {}
        for k, v in pairs( BRICKS_SERVER.Languages ) do
            local key = table.insert( languages, { k, table.Copy( v ) } )

            if( (BS_ConfigCopyTable.LANGUAGE.Languages or {})[k] ) then
                table.Merge( languages[key][2], (BS_ConfigCopyTable.LANGUAGE.Languages or {})[k][2] )
            end
        end

        for k, v in pairs( BS_ConfigCopyTable.LANGUAGE.Languages or {} ) do
            if( not v[1] ) then continue end

            table.insert( languages, { k, v[2], v[1] } )
        end

        for k, v in pairs( languages ) do
            languageGrid.slots = (languageGrid.slots or 0)+1
            local slots = languageGrid.slots
            local slotsTall = math.ceil( slots/slotsWide )
            languageGrid:SetTall( (slotsTall*slotTall)+((slotsTall-1)*languageSpacing) )

            local missingLanguageStrings = math.max( 0, table.Count( BRICKS_SERVER.Languages["english"] or {} ) - table.Count( v[2] ) )

            local languageBack = vgui.Create( "DPanel", languageGrid )
            languageBack:SetSize( actualSlotSize, slotTall )
            languageBack.Paint = function( self2, w, h )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

                draw.SimpleText( string.upper( v[3] or v[1] ), "BRICKS_SERVER_Font25", w/2, h/3, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )

                if( missingLanguageStrings > 0 ) then
                    draw.SimpleText( missingLanguageStrings .. " missing language strings", "BRICKS_SERVER_Font20", w/2, h/3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red, TEXT_ALIGN_CENTER, 0 )
                else
                    draw.SimpleText( missingLanguageStrings .. " missing language strings", "BRICKS_SERVER_Font20", w/2, h/3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Green, TEXT_ALIGN_CENTER, 0 )
                end
            end

            local languageEditButton = vgui.Create( "DButton", languageBack )
            languageEditButton:SetSize( 36, 36 )
            languageEditButton:SetPos( actualSlotSize-10-languageEditButton:GetWide(), 10 )
            languageEditButton:SetText( "" )
            local alpha = 0
            local editMat = Material( "materials/bricks_server/edit.png" )
            languageEditButton.Paint = function( self2, w, h )
                if( not self2:IsDown() and self2:IsHovered() ) then
                    alpha = math.Clamp( alpha+10, 0, 95 )
                else
                    alpha = math.Clamp( alpha-10, 0, 95 )
                end

                surface.SetAlphaMultiplier( alpha/255 )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
                surface.SetAlphaMultiplier( 1 )

                BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )

                surface.SetMaterial( editMat )
                local size = 24
                surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
                surface.DrawTexturedRect( (h-size)/2, (h-size)/2, size, size )
            end
            languageEditButton.DoClick = function()
                CreateEditPopout( v[1] )
            end

            local languageButton = vgui.Create( "DButton", languageBack )
            languageButton:Dock( BOTTOM )
            languageButton:DockMargin( 10, 10, 10, 10 )
            languageButton:SetTall( 40 )
            languageButton:SetText( "" )
            local alpha = 0
            languageButton.Paint = function( self2, w, h )
                local buttonText, buttonColor, buttonDownColor = BRICKS_SERVER.Func.L( "unselected" ), BRICKS_SERVER.Func.GetTheme( 2 ), BRICKS_SERVER.Func.GetTheme( 1 )

                if( (BS_ConfigCopyTable.LANGUAGE.Language or "english") == v[1] ) then
                    buttonText, buttonColor, buttonDownColor = BRICKS_SERVER.Func.L( "selected" ), BRICKS_SERVER.Func.GetTheme( 5 ), BRICKS_SERVER.Func.GetTheme( 4 )
                end

                if( not self2:IsDown() and self2:IsHovered() ) then
                    alpha = math.Clamp( alpha+5, 0, 200 )
                else
                    alpha = math.Clamp( alpha-5, 0, 255 )
                end

                draw.RoundedBox( 5, 0, 0, w, h, buttonColor )

                surface.SetAlphaMultiplier( alpha/255 )
                draw.RoundedBox( 5, 0, 0, w, h, buttonDownColor )
                surface.SetAlphaMultiplier( 1 )

                BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, buttonDownColor )

                draw.SimpleText( buttonText, "BRICKS_SERVER_Font20", w/2, h/2-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end
            languageButton.DoClick = function()
                if( (BS_ConfigCopyTable.LANGUAGE.Language or "") == v[1] ) then return end

                BS_ConfigCopyTable.LANGUAGE.Language = v[1]
                BRICKS_SERVER.Func.ConfigChange( "LANGUAGE" )
            end
        end

        -- Create new
        languageGrid.slots = (languageGrid.slots or 0)+1
        local slots = languageGrid.slots
        local slotsTall = math.ceil( slots/slotsWide )
        languageGrid:SetTall( (slotsTall*slotTall)+((slotsTall-1)*languageSpacing) )

        local createNewBack = vgui.Create( "DPanel", languageGrid )
        createNewBack:SetSize( actualSlotSize, slotTall )
        createNewBack.Paint = function( self2, w, h )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

            draw.SimpleText( BRICKS_SERVER.Func.L( "createNew" ), "BRICKS_SERVER_Font25", w/2, h/3, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )

            draw.SimpleText( BRICKS_SERVER.Func.L( "createNewLanguage" ), "BRICKS_SERVER_Font20", w/2, h/3, BRICKS_SERVER.Func.GetTheme( 5 ), TEXT_ALIGN_CENTER, 0 )
        end

        local createNewButton = vgui.Create( "DButton", createNewBack )
        createNewButton:Dock( BOTTOM )
        createNewButton:DockMargin( 10, 10, 10, 10 )
        createNewButton:SetTall( 40 )
        createNewButton:SetText( "" )
        local alpha = 0
        createNewButton.Paint = function( self2, w, h )
            if( not self2:IsDown() and self2:IsHovered() ) then
                alpha = math.Clamp( alpha+5, 0, 200 )
            else
                alpha = math.Clamp( alpha-5, 0, 255 )
            end

            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )

            surface.SetAlphaMultiplier( alpha/255 )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 4 ) )
            surface.SetAlphaMultiplier( 1 )

            BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 4 ) )

            draw.SimpleText( BRICKS_SERVER.Func.L( "create" ), "BRICKS_SERVER_Font20", w/2, h/2-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
        createNewButton.DoClick = function()
            if( not BS_ConfigCopyTable.LANGUAGE.Languages ) then
                BS_ConfigCopyTable.LANGUAGE.Languages = {}
            end

            table.insert( BS_ConfigCopyTable.LANGUAGE.Languages, { "New Language", {} } )
            self.RefreshPanel()

            BRICKS_SERVER.Func.ConfigChange( "LANGUAGE" )
        end
    end
    self.RefreshPanel()
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_config_languages", PANEL, "DPanel" )