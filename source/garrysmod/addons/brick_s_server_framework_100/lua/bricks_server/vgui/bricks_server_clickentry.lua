local PANEL = {}

function PANEL:Init()

	self:SetTall( 40 )
	self:Clear()
	self:SetText( "" )

end

function PANEL:CreateStringEntry()
	if( IsValid( self.valueEntry ) ) then return end

	self.looseFocusCooldown = CurTime()+0.1

	self.valueEntry = vgui.Create( "bricks_server_textentry", self )
	self.valueEntry:Dock( FILL )
	self.valueEntry:SetKeyboardInputEnabled( true )
	self.valueEntry:RequestFocus()
	self.valueEntry.OnChange = function()
		self:SetValue( self.valueEntry:GetValue() )
	end
	self.valueEntry.OnEnter = function()
		if( self.OnEnter ) then
			self.OnEnter( self.valueEntry:GetValue() )
		end
	end
end

function PANEL:CreateNumberEntry()
	if( IsValid( self.valueEntry ) ) then return end

	self.looseFocusCooldown = CurTime()+0.1

	self.valueEntry = vgui.Create( "DNumberWang", self )
	self.valueEntry:Dock( FILL )
	self.valueEntry:SetKeyboardInputEnabled( true )
	self.valueEntry:RequestFocus()
	self.valueEntry.OnChange = function()
		self:SetValue( self.valueEntry:GetValue() )
	end
	self.valueEntry.OnEnter = function()
		if( self.OnEnter ) then
			self.OnEnter( self.valueEntry:GetValue() )
		end
	end
end

function PANEL:SetDataType( dataType )
	if( dataType == "string"  or dataType == "integer" or dataType == "color" ) then
		self.dataType = dataType
	else
		self.dataType = "string"
	end
end

function PANEL:GetDataType()
	return self.dataType or "string"
end

function PANEL:SetValue( value )
	if( self:GetDataType() == "string" ) then
		self.value = tostring( value )
	elseif( self:GetDataType() == "integer" ) then
		self.value = tonumber( value )
	else
		self.value = value
	end

	if( self.OnChange ) then
		self.OnChange( value )
	end
end

function PANEL:GetValue()
	if( self:GetDataType() == "string" ) then
		return tostring( self.value or "none" )
	elseif( self:GetDataType() == "integer" ) then
		return tonumber( self.value or 0 )
	else
		return self.value
	end
end

function PANEL:SetTitle( strValue )
	self.title = strValue
end

function PANEL:GetTitle()
	return self.title or ""
end

function PANEL:DoClick()
	if( self:GetDataType() == "string" ) then
		self:CreateStringEntry()
	elseif( self:GetDataType() == "integer" ) then
		self:CreateNumberEntry()
	elseif( self:GetDataType() == "color" ) then
		BRICKS_SERVER.Func.ColorRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "newColorQuery" ), self:GetValue(), function( color ) 
			self:SetValue( color or Color( 255, 255, 255 ) )
		end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ) )
	end
end

function PANEL:Think()
	if( IsValid( self.valueEntry ) and not self.valueEntry:HasFocus() and CurTime() >= self.looseFocusCooldown ) then
		self.valueEntry:Remove()
	end
end

local Alpha = 0
local color1 = BRICKS_SERVER.Func.GetTheme( 2 )
function PANEL:Paint( w, h )
	if( IsValid( self.valueEntry ) ) then
		Alpha = math.Clamp( Alpha+5, 0, 100 )
	else
		Alpha = math.Clamp( Alpha-5, 0, 100 )
	end

	draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
	draw.RoundedBox( 5, 0, 0, w, h, Color( color1.r, color1.g, color1.b, Alpha ) )

	if( not IsValid( self.valueEntry ) ) then
		if( self:GetDataType() != "color" ) then
			draw.SimpleText( self:GetTitle() .. ": " .. tostring( self:GetValue() ), "BRICKS_SERVER_Font20", w/2, h/2, Color( 255, 255, 255, 20 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		else
			draw.SimpleText( self:GetTitle(), "BRICKS_SERVER_Font20", w/2, h/2, Color( 255, 255, 255, 20 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	else

	end
end

derma.DefineControl( "bricks_server_clickentry", "", PANEL, "DButton" )