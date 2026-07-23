local PANEL = { }

local draw = draw
local gui = gui
local vgui = vgui
local math = math

local font = KVS.GetFont
local config = KVS.GetConfig

KVS:AccessorFunc( PANEL, 'FocusColor', 'FocusColor' )
KVS:AccessorFunc( PANEL, 'TextColor', 'TextColor' )
KVS:AccessorFunc( PANEL, 'TabBackgroundColor', 'TabBackgroundColor' )
KVS:AccessorFunc( PANEL, 'SeparationColor', 'SeparationColor' )

--[[
	TODO : MAKE COLORS CONFIGURABLE
]]

local function ClearCurrentPanel( oParent )
    if IsValid( oParent ) and IsValid( oParent:GetCanvas() ) then
        for k, oChild in pairs( oParent:GetCanvas():GetChildren() or {} ) do
            if IsValid( oChild ) then 
                oChild:Remove()
            end
        end
    end
end

function PANEL:Init()
	local this = self

	local dPanelSections = vgui.Create( "KVS.Panel", self )
    dPanelSections:Dock( TOP )
    dPanelSections:SetHeight( 30 )
    dPanelSections:InvalidateParent( true )

	function dPanelSections:OnSizeChanged()
		this:RebuildTabs()
	end

	self.panelSections = dPanelSections

    local dPanelContent = vgui.Create( "KVS.ScrollPanel", self )
    dPanelContent:Dock( FILL )
    dPanelContent:InvalidateParent( true )

	self.panelContent = dPanelContent

	self.Tabs = {}

	self:SetFocusColor( config( "vgui.color.primary" ) )
	self:SetTextColor( color_white )
	self:SetTabBackgroundColor( config( "vgui.color.medium_black" ) )
    self:SetContentBackgroundColor( config( "vgui.color.medium_black" ) )
    self:SetSeparationColor( config( "vgui.color.black" ) )

end

function PANEL:SetContentBackgroundColor( oColor )
	if IsValid( self:GetPanelContent() ) then
		self:GetPanelContent():SetBackgroundColor( oColor )
	end
end

function PANEL:SeSectionsBackgroundColor( oColor )
	if IsValid( self:GetPanelSections() ) then
		self:GetPanelSections():SetBackgroundColor( oColor )
	end
end

function PANEL:SetTabsHeight( iValue )
	self:GetPanelSections():SetHeight( iValue )
    self:GetPanelSections():InvalidateParent( true )
end

function PANEL:GetPanelSections()
	return self.panelSections
end

function PANEL:GetPanelContent()
	return self.panelContent
end

function PANEL:AddTab( sText, sFont, fOnClick, sTooltip, ... )
	local iIndex = table.insert( self.Tabs, {
		text = sText,
		font = sFont,
		onClick = fOnClick,
		tooltip = sTooltip,
		arguments = { ... }
	} )

	self:RebuildTabs()

	return iIndex
end

function PANEL:RemoveTab( iIndex )
	self.Tabs[ iIndex ] = nil

	local newTab = {}
	for _, tTab in pairs( self.Tabs or {} ) do 
		table.insert( newTab, tTab )
	end

	self.Tabs = newTab

	self:RebuildTabs()
end

function PANEL:GetSections()
	return self.Tabs or {}
end 

function PANEL:GetSectionTable( iIndex )
	if not self.Tabs or not self.Tabs[ iIndex ] or not IsValid( self.Tabs[ iIndex ].Section ) then return end

	return self.Tabs[ iIndex ]
end

function PANEL:SelectTab( iIndex )
	if not self.Tabs or not self.Tabs[ iIndex ] or not IsValid( self.Tabs[ iIndex ].Section ) then return end

	self.Tabs[ iIndex ].Section:DoClick( true )
end 

-- Equivalent to DPropertySheet
function PANEL:SetActiveTab( iIndex )
	self:SelectTab( iIndex )
end 

function PANEL:RebuildTabs()
	self.Sections = self.Sections or {}

	local this = self

	for _, dSection in pairs( self.Sections or {} ) do
		if IsValid( dSection ) then dSection:Remove() end
	end

	self.Sections = {}
	local tCategories = self.Tabs or {}

	local widePercentage = 0.9 / ( #tCategories )
	local marginBorders = 1
	for iID, tData in ipairs( tCategories or {} ) do
		self.CurrentSelection = self.CurrentSelection or iID
		local bIsSelected = self.CurrentSelection == iID
		local sTooltip = tData.tooltip
		local dPanelSections = self:GetPanelSections()

		local dSection = vgui.Create( "KVS.Button", dPanelSections )
		dSection:Dock( LEFT )
		if sTooltip then 
			dSection:AddTooltip( sTooltip )
		end
		dSection:SetBorder( false, false, false, false )

		local bIsBorder = ( iID == 1 or iID == #tCategories )
		if bIsSelected then
			dSection:SetWide( ( widePercentage + 0.1 ) * dPanelSections:GetWide() + ( -marginBorders * ( bIsBorder and 0 or 2 ) ) )
			dSection:DockMargin( iID ~= 1 and marginBorders or 0, 0, iID ~= #tCategories and marginBorders or 0, 0 )
		else 
			dSection:SetWide( widePercentage * dPanelSections:GetWide() + ( -marginBorders * ( bIsBorder and 0 or 2 ) ) )
			dSection:DockMargin( iID ~= 1 and marginBorders or 0, 5, iID ~= #tCategories and marginBorders or 0, 0 )
		end
		self.Sections[ iID or -1 ] = dSection
		self.Tabs[ iID ].Section = dSection

		function dSection:Paint( w, h )
			draw.RoundedBoxEx( 5, 0, 0, w, h, this:GetTabBackgroundColor(), true, true, false, false )
			draw.SimpleText( tData.text or "", font( tData.font or 'Rajdhani', h * 0.5, 'extended' ), w / 2, h / 2, this:GetTextColor(), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			if this.CurrentSelection == iID then
				draw.RoundedBox( 0, 0, h - 3, w, 3, this:GetFocusColor() )
			else
				draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 28, 29, 31, 255 ) )
			end
		end
		function dSection:DoClick( bForceUpdate )
			if not bForceUpdate and this.CurrentSelection == iID then
			    return
			end
			ClearCurrentPanel( this:GetPanelContent() )

			if isfunction( tData.onClick ) then 
				tData.onClick( this:GetPanelContent(), unpack( tData.arguments or {} ) )
			end

			if this.Sections and IsValid( this.Sections[ this.CurrentSelection ] ) then
				local dSection = this.Sections[ this.CurrentSelection ]
				local bIsBorder = ( this.CurrentSelection == 1 or this.CurrentSelection == #tCategories )
				dSection:SetWide( widePercentage * dPanelSections:GetWide() + ( -marginBorders * ( bIsBorder and 0 or 2 ) ) )
				dSection:DockMargin( this.CurrentSelection ~= 1 and marginBorders or 0, 5, this.CurrentSelection ~= #tCategories and marginBorders or 0, 0 )
			end

			this.CurrentSelection = iID or 1
			
			local bIsBorder = ( iID == 1 or iID == #tCategories )
			self:SetWide( ( widePercentage + 0.1 ) * dPanelSections:GetWide() + ( -marginBorders * ( bIsBorder and 0 or 2 ) ) )
			self:DockMargin( iID ~= 1 and marginBorders or 0, 0, iID ~= #tCategories and marginBorders or 0, 0 )

			this:GetPanelContent():CanvasToScroll()
		end
		if bIsSelected then
			dSection:DoClick( true )
		end
	end
end

derma.DefineControl( 'KVS.Tabs' , nil, PANEL, 'KVS.Panel' )
