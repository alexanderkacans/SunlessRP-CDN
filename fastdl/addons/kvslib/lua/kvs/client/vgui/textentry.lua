local PANEL = {}

local config = KVS.GetConfig
local font = KVS.GetFont

local strAllowedNumericCharacters = "1234567890.-"

function PANEL:InitVar()
	KVS:MakeChainableMethod( self, { 'SetPos', 'SetSize', 'Dock', 'SetTall', 'SetWide', 'DockMargin', 'DockPadding', 'SetNumeric', 'SetText' } )
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

	self:SetTall( 30 )
	self:SetFont( font( 'Vegur', 20 ) )
	self:SetTextColor( config( 'vgui.color.white' ) )
	self:SetCursorColor( config( 'vgui.color.white' ) )

	self.Input = self
end


function PANEL:Init()
	local this = self

	self:InitVar()
	self:SetDrawLanguageID( false )
	self:SetCursor( 'beam' )
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
	if self:HasFocus() then
		local isOpenMenu = not IsValid( self.Menu )
		draw.RoundedBoxEx( self.BorderRadius, 0, 0, w, h, self.MainColor, true, true, isOpenMenu, isOpenMenu )
		draw.RoundedBoxEx( self.BorderRadius, self.FocusBorderThickness, self.FocusBorderThickness, w - self.FocusBorderThickness * 2, h - self.FocusBorderThickness * 2, self.BackgroundColor, true, true, isOpenMenu, isOpenMenu )
	elseif self:IsHovered() or self:IsHovered() then
		draw.RoundedBoxEx( self.BorderRadius, 0, 0, w, h, KVS:GetDarkenColor( self.MainColor, 0.4 ), true, true, true, true )
		draw.RoundedBoxEx( self.BorderRadius, self.FocusBorderThickness, self.FocusBorderThickness, w - self.FocusBorderThickness * 2, h - self.FocusBorderThickness * 2, self.BackgroundColor, true, true, true, true )
	else
		draw.RoundedBoxEx( self.BorderRadius, 0, 0, w, h, self.BackgroundColor, true, true, true, true )
	end

	if self:GetPlaceholderText() and string.len( self:GetPlaceholderText() ) > 0 and #string.Trim( self:GetText() ) == 0 then
		local old_text = self:GetText()
		self:SetText( self:GetPlaceholderText() )
		self:DrawTextEntryText( KVS:GetDarkenColor( self:GetTextColor(), 0.5 ), self:GetHighlightColor(), self:GetCursorColor() )
		self:SetText( old_text )
	else
		self:DrawTextEntryText( self:GetTextColor(), self:GetHighlightColor(), self:GetCursorColor() )
	end
end

function PANEL:OnKeyCode( code )
	if IsValid( self.Menu ) then
		if code == KEY_ENTER then
			self.Menu:GetChild( self.AliasSelected ):OnMousePressed()
			return false
		end

		if code == KEY_UP then
			self.AliasSelected = self.AliasSelected - 1
			self:UpdateAliasSelected()
		end

		if code == KEY_DOWN then
			self.AliasSelected = self.AliasSelected + 1
			self:UpdateAliasSelected()
		end
	elseif self.OnKeyCodePressed then
		self:OnKeyCodePressed( code )
	end
end

function PANEL:UpdateAliasSelected()
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

function PANEL:ReplaceLastWord( suggestion )
	local text = self:GetText()
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

	self:OnValueChange( new_text )
	self:SetText( new_text )
	self:OnValueChanged( new_text )
end

function PANEL:RemoveAliasesMenu()
	if IsValid( self.Menu ) then
		self.Menu:Remove()
		self.Menu = nil
		self.AliasSelected = 0
		self:RequestFocus()
	end
end

function PANEL:OnTextChanged()

	local text = self:GetText()
	if not text or #text < 0 then return end

	self:OnValueChange( text )
	self:OnValueChanged( text )

	local words =  string.Explode( ' ', text )
	if words[#words] == '' then return end

	local suggestions = self:SearchAliases( words[#words] )

	self:RemoveAliasesMenu()

	if #suggestions > 0 then
		self.Menu = vgui.Create( 'KVS.ComboBoxMenu', self )
		for _, suggestion in pairs( suggestions ) do
			self.Menu:AddOption( suggestion, function()
				self:ReplaceLastWord( suggestion )
				self:RemoveAliasesMenu()
				self:RequestFocus()
				self:SetCaretPos( string.len( self:GetText() ) )
			end)
		end

		self.AliasSelected = 1
		self:UpdateAliasSelected()

		local x, y = self:LocalToScreen( 0, self:GetTall() )
		self.Menu:SetMinimumWidth( self:GetWide() )
		self.Menu:Open( x, y, true, self )
		self.Menu:SetPos( x, y )
		self.Menu:SetMaxHeight( ( ScrH() - y ) - 10 )
	end
end

function PANEL:SetPlaceHolder( text, color )
	self:SetPlaceholderText( text )
	if color and IsColor( color ) then
		self:SetPlaceholderColor( color )
	end
	return self
end

function PANEL:Prepend( text, icon, color, onclick )
	if self.PrependItem and IsValid( self.PrependItem ) then
		self.PrependItem:Remove()
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
		self.AppendItem:Remove()
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

function PANEL:OnValueChange( text )
	-- Override
end

function PANEL:OnValueChanged( text )
	-- Override
end

derma.DefineControl( 'KVS.TextEntry', nil, PANEL, 'DTextEntry' )
