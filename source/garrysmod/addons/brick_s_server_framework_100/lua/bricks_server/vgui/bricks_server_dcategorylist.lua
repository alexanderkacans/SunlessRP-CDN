
local PANEL = {}

function PANEL:Init()

	self.pnlCanvas:DockPadding( 0, 0, 0, 0 )

end

function PANEL:AddItem( item )

	item:Dock( TOP )
	DScrollPanel.AddItem( self, item )
	self:InvalidateLayout()

end

function PANEL:Add( name, backColor, fillBackColor )

	local Category = vgui.Create( "bricks_server_dcollapsiblecategory", self )
	Category:SetLabel( "" )
	Category:SetList( self )
	Category.backColor = backColor
	Category.headerText = name
	Category.fillBackColor = fillBackColor

	self:AddItem( Category )

	return Category

end

function PANEL:Paint( w, h )

end

function PANEL:UnselectAll()

	for k, v in pairs( self:GetChildren() ) do

		if ( v.UnselectAll ) then
			v:UnselectAll()
		end

	end

end

derma.DefineControl( "bricks_server_dcategorylist", "", PANEL, "bricks_server_scrollpanel" )
