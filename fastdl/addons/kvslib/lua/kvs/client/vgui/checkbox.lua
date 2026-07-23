local PANEL = {}

local font = KVS.GetFont
local config = KVS.GetConfig

KVS:AccessorFunc( PANEL, 'm_bChecked', 'Checked', FORCE_BOOL )
KVS:AccessorFunc( PANEL, 'm_mainColor', 'MainColor' )

function PANEL:Init( )

	self:SetSize( 15, 15 )
	self:SetText( '' )
	self.m_mainColor = config( 'vgui.color.primary' )

end

function PANEL:Paint( w, h )
	draw.RoundedBox( 3, 0, 0, w, h, config( 'vgui.color.light_black' ) )

	if self:GetChecked( ) then
		draw.SimpleText( utf8.char( 0xf00c ), font( 'FAS', w - 2, 'extended' ), w / 2, h / 2, self:GetMainColor( ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
end

derma.DefineControl( 'KVS.CheckBox', 'Simple Checkbox', PANEL, 'DCheckBox' )