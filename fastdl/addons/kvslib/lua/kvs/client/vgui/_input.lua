local PANEL = {}

local config = KVS.GetConfig
local font = KVS.GetFont
local strAllowedNumericCharacters = "1234567890.-"

KVS:AccessorFunc( PANEL, "m_bNumeric", "Numeric", FORCE_BOOL )

function PANEL:InitVar( )
	self.BackgroundColor = config( 'vgui.color.black' )
end

function PANEL:Init()
	self:InitVar( )

	self:SetFont( font( 'Vegur', 20 ) )
	self:SetTextColor( config( 'vgui.color.white' ) )
	self:SetCursorColor( config( 'vgui.color.white' ) )
	self:SetHistoryEnabled(false)
end

function PANEL:Paint( w, h )
	if self:GetPlaceholderText( ) and string.len( self:GetPlaceholderText( ) ) > 0 and #string.Trim( self:GetText( ) ) == 0 then
		local old_text = self:GetText( )
		self:SetText( self:GetPlaceholderText( ) )
		self:DrawTextEntryText( KVS:GetDarkenColor( self:GetTextColor( ), 0.5 ), self:GetHighlightColor( ), self:GetCursorColor( ) )
		self:SetText( old_text )
	else
		self:DrawTextEntryText( self:GetTextColor( ), self:GetHighlightColor( ), self:GetCursorColor( ) )
	end
end

function PANEL:SetPlaceHolder( text, color )
	self:SetPlaceholderText( text )
	if color and IsColor( color ) then
		self:SetPlaceholderColor( color )
	end
	return self
end

function PANEL:OnKeyCodeTyped( code )
	if not self:OnKeyCode( code ) then
		return
	end

	if code == KEY_ENTER then
		self:FocusNext( )
		self:OnEnter( )
	end
end

--[[
	SetNumeric functions
]]

function PANEL:CheckNumeric( strValue )

	-- Not purely numeric, don't run the check
	if ( !self:GetNumeric() ) then return false end

	-- God I hope numbers look the same in every language
	if ( !string.find( strAllowedNumericCharacters, strValue, 1, true ) ) then

		-- Noisy Error?
		return true

	end

	return false

end

function PANEL:AllowInput( strValue )

	-- This is layed out like this so you can easily override and
	-- either keep or remove this numeric check.
	if ( self:CheckNumeric( strValue ) ) then return true end

end

--[[-------------------------------------------------------------------------
 * Disable
 * SetValue
 * Handle focus state
 * Prepend text or icon
 * Character limit
 * Type password with hidden char '*'
 * Handle Docking
 * Placeholder
 * Handle hover state
 * Handle Autocompletion system :AddAutoComplete( table or string or function )
 	* Handle directionnal arrows to select some result 
 * Handle main color
 * Ability to add disallow character with predifined pattern SetPattern( NUMERIC, ALPHA_NUMERIC, ALPHABETIC, '[A-Za-Z -.]+' )
 	* SetPatternErrorMessage( 'This is not allow for the text entry enculé' )
 * Handle error state witch set the color to red (border red, text red, icon red )
 	* Show error message in little under the input
 * SetRequired() -> Add a little start a the left of the input
 * AddLabel( string label, enum TOP|LEFT )
 	* Add a label at the designed position above the input or a the left of the input
 * AppendButton() -> Append a button a the right of the input wich can be bind an action
 * OnValueChange()
 * GetValue()
 * OnFocus -> Bind hook on pass panel as parameter
 * OnLostFocus -> Bind hook on pass panel as parameter
 * Change context menu
---------------------------------------------------------------------------]]

derma.DefineControl( 'KVS._Input', nil, PANEL, 'DTextEntry' )
