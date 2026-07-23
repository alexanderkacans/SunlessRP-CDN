local PANEL = {}

local config = KVS.GetConfig

local strAllowedNumericCharacters = "1234567890.-"

function PANEL:InitVar( )
	KVS:MakeChainableMethod( self, { 'SetPos', 'SetSize', 'Dock', 'SetTall', 'SetWide', 'DockMargin', 'DockPadding' } )
	self.BackgroundColor = config( 'vgui.color.black' )
	self.BorderRadius = 5 -- TODO
	self.FocusBorderThickness = 1 -- TODO
	self.MainColor = config( 'vgui.color.primary' ) -- TODO

	self.Menu = nil
	self.Aliases = { }
	self.AliasSelected = 0
	self.CaseSensitive = false

	self.PrependItem = nil
	self.AppendItem = nil
end


function PANEL:Init()
	local this = self

	self:InitVar( )

	self.Input = self:Add('KVS._Input')
	self.Input:SetDrawLanguageID( false )
	self.Input:Dock( FILL )
	self.Input:DockMargin( 5, 0, 1, 0 )

	self:SetTall( 40 )
	self:SetCursor( 'beam' )

	function self.Input:OnChange( )
		this:OnTextChanged( )
	end

	function self.Input:OnGetFocus()
		this:OnTextChanged( )
		this:OnGetFocus()
		this:OnFocus()
	end

	function self.Input:OnLoseFocus()
		this:RemoveAliasesMenu( )
		this:OnLoseFocus()
	end

	function self.Input:OnKeyCode( code )
		this:OnKeyCode( code )
	end
end

function PANEL:OnFocus()
end

function PANEL:OnGetFocus()
end

function PANEL:SetPlaceholderText( text )
	self.Input:SetPlaceholderText( text )
end

function PANEL:GetPlaceholderText( )
	return self.Input:GetPlaceholderText( )
end

function PANEL:SetCaseSensitive( sensitive )
	self.CaseSensitive = sensitive
	return self
end

function PANEL:SetBorderRadius( border )
	self.BorderRadius = border
	self:InvalidateLayout( true )
	return self
end

function PANEL:Paint( w, h )
	if self.Input:HasFocus( ) then
		local isOpenMenu = not IsValid( self.Menu )
		draw.RoundedBoxEx( self.BorderRadius, 0, 0, w, h, self.MainColor, true, true, isOpenMenu, isOpenMenu )
		draw.RoundedBoxEx( self.BorderRadius, self.FocusBorderThickness, self.FocusBorderThickness, w - self.FocusBorderThickness * 2, h - self.FocusBorderThickness * 2, self.BackgroundColor, true, true, isOpenMenu, isOpenMenu )
	elseif self:IsHovered( ) or self.Input:IsHovered( ) then
		draw.RoundedBoxEx( self.BorderRadius, 0, 0, w, h, KVS:GetDarkenColor( self.MainColor, 0.4 ), true, true, true, true )
		draw.RoundedBoxEx( self.BorderRadius, self.FocusBorderThickness, self.FocusBorderThickness, w - self.FocusBorderThickness * 2, h - self.FocusBorderThickness * 2, self.BackgroundColor, true, true, true, true )
	else
		draw.RoundedBoxEx( self.BorderRadius, 0, 0, w, h, self.BackgroundColor, true, true, true, true )
	end
end

function PANEL:OnKeyCode( code )
	if IsValid( self.Menu ) then
		if code == KEY_ENTER then
			self.Menu:GetChild( self.AliasSelected ):OnMousePressed( )
			return false
		end

		if code == KEY_UP then
			self.AliasSelected = self.AliasSelected - 1
			self:UpdateAliasSelected( )
		end

		if code == KEY_DOWN then
			self.AliasSelected = self.AliasSelected + 1
			self:UpdateAliasSelected( )
		end
	elseif self.OnKeyCodePressed then
		self:OnKeyCodePressed( code )
	end
end

function PANEL:UpdateAliasSelected( )
	local pos = self.AliasSelected
	local num = self.Menu:ChildCount()

	self.Menu:ClearHighlights()

	if pos < 0 then pos = num end
	if pos > num then pos = 0 end

	local item = self.Menu:GetChild( pos )
	if not item then
		self.AliasSelected = pos
		return
	end

	self.Menu:HighlightItem( item )
	self.AliasSelected = pos
end

function PANEL:OnMousePressed( )
	self.Input:RequestFocus( )
	return self
end

function PANEL:OnLoseFocus()
	return self
end

function PANEL:RequestFocus( )
	self.Input:RequestFocus( )
	return self
end

function PANEL:HasFocus( )
	return self.Input:HasFocus( )
end

function PANEL:SetPlaceHolder( text )
	self.Input:SetPlaceHolder( text )
	return self
end

function PANEL:GetValue( )
	return self.Input:GetValue( )
end

function PANEL:SetFont( font_name )
	self.Input:SetFont( font_name )
	return self
end

function PANEL:SetTextColor( color )
	self.Input:SetTextColor( color )
	return self
end

function PANEL:SetNumeric( bool )
	self.Input:SetNumeric( bool )
	return self
end

function PANEL:GetNumeric()
	self.Input:GetNumeric()
	return self
end

function PANEL:AddAlias( aliases, matches )
	if not istable( aliases ) then
		aliases = { aliases }
	end

	for _, alias in pairs( aliases ) do
	 	if not self.Aliases[ alias ] then self.Aliases[ alias ] = alias end

		if istable( matches ) then
			for _, v in pairs( matches ) do
				if isstring( v ) and not self.Aliases[ v ] then
					self.Aliases[ v ] = alias
				end
			end
		end

		if isstring( matches ) and not self.Aliases[ matches ] then
			self.Aliases[ matches ] = alias
		end
	end

	return self
end

function PANEL:SearchAliases( word )
	local suggestions = { }
	for suggestion, aliases in pairs( self.Aliases ) do
		local check = string.StartWith( string.lower( suggestion ), string.lower( word ) )
		if self.CaseSensitive then check = string.StartWith( suggestion, word ) end
		if check then
			table.insert( suggestions, aliases )
		end
	end

	return suggestions
end

function PANEL:GetText( )
	return self.Input:GetText( )
end

function PANEL:SetText( text )
	self.Input:SetText( text )
	return self
end

function PANEL:ReplaceLastWord( suggestion )
	local text = self.Input:GetText( )
	if not text or #text < 0 then return end
	local words =  string.Explode( ' ', text )
	local last_word = words[#words]
	if last_word == '' then return end
	table.remove( words, #words )

	local whitout_last_word = table.concat( words, ' ' )

	if string.sub( text, string.len( text ) - string.len( last_word ) ) then
		whitout_last_word = whitout_last_word .. ' '
	end

	local new_text = whitout_last_word .. suggestion

	self.Input:SetText( new_text )

	self:OnValueChange( new_text )
	self:OnValueChanged( new_text )
end

function PANEL:RemoveAliasesMenu( )
	if IsValid( self.Menu ) then
		self.Menu:Remove()
		self.Menu = nil
		self.AliasSelected = 0
		self.Input:RequestFocus()
	end
end

function PANEL:OnValueChange( text )
end

function PANEL:OnValueChanged( text )
end

function PANEL:OnTextChanged()

	local text = self.Input:GetText( )
	if not text or #text < 0 then return end

	self:OnValueChange( text )
	self:OnValueChanged( text )

	local words =  string.Explode( ' ', text )
	if words[#words] == '' then return end

	local suggestions = self:SearchAliases( words[#words] )

	self:RemoveAliasesMenu( )

	if #suggestions > 0 then
		self.Menu = vgui.Create( 'KVS.ComboBoxMenu', self )
		for _, suggestion in pairs( suggestions ) do
			self.Menu:AddOption( suggestion, function( )
				self:ReplaceLastWord( suggestion )
				self:RemoveAliasesMenu( )
				self.Input:RequestFocus( )
				self.Input:SetCaretPos( string.len( self.Input:GetText( ) ) )
			end)
		end

		self.AliasSelected = 1
		self:UpdateAliasSelected( )

		local x, y = self:LocalToScreen( 0, self:GetTall() )
		self.Menu:SetMinimumWidth( self:GetWide() )
		self.Menu:Open( x, y, true, self )
		self.Menu:SetPos( x, y )
		self.Menu:SetMaxHeight( ( ScrH() - y ) - 10 )
	end
end

function PANEL:Prepend( text, icon, color, onclick )
	if self.PrependItem and IsValid( self.PrependItem ) then
		self.PrependItem:Remove( )
	end

	if not isstring( text ) and IsValid( text ) and ispanel( text ) then
		self.PrependItem = text
		if self.PrependItem.SetParent then self.PrependItem:SetParent( self ) end
		if self.PrependItem.Dock then self.PrependItem:Dock( LEFT ) end
		if self.PrependItem.SetBorder then self.PrependItem:SetBorder( self.BorderRadius == 0 and false or true, false, self.BorderRadius == 0 and false or true, false ) end
	else
		self.PrependItem = vgui.Create( 'KVS.Button', self )
			:SetBorder( self.BorderRadius == 0 and false or true, false, self.BorderRadius == 0 and false or true, false )
			:SetColor( color and IsColor( color ) and color or self.MainColor )
			:SetAutoSize( true )
			:SetText( text )
		self.PrependItem:Dock( LEFT )

		if onclick and isfunction( onclick ) then
			self.PrependItem.DoClick = onclick
		else
			self.PrependItem:SetNoAnimation( true )
		end

		if istable( icon ) and icon.font and icon.unicode then
			self.PrependItem:WithIcon( icon.font, icon.unicode ):SetAutoSize( true )
		end
	end

	self:InvalidateLayout( true )
	return self
end

function PANEL:Append( text, icon, color, onclick )
	if self.AppendItem and IsValid( self.AppendItem ) then
		self.AppendItem:Remove( )
	end

	if not isstring( text ) and IsValid( text ) and ispanel( text ) then
		self.AppendItem = text
		if self.AppendItem.SetParent then self.AppendItem:SetParent( self ) end
		if self.AppendItem.Dock then self.AppendItem:Dock( RIGHT ) end
		if self.AppendItem.SetBorder then self.AppendItem:SetBorder( false, self.BorderRadius == 0 and false or true, false, self.BorderRadius == 0 and false or true ) end
	else
		self.AppendItem = vgui.Create( 'KVS.Button', self )
			:SetBorder( false, self.BorderRadius == 0 and false or true, false, self.BorderRadius == 0 and false or true )
			:SetColor( color and IsColor( color ) and color or self.MainColor )
			:SetAutoSize( true )
			:SetText( text )
		self.AppendItem:Dock( RIGHT )

		if onclick and isfunction( onclick ) then
			self.AppendItem.DoClick = onclick
		else
			self.AppendItem:SetNoAnimation( true )
		end

		if istable( icon ) and icon.font and icon.unicode then
			self.AppendItem:WithIcon( icon.font, icon.unicode )
		end
	end

	self:InvalidateLayout( true )
	return self
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

derma.DefineControl( 'KVS.Input', nil, PANEL, 'EditablePanel' )
