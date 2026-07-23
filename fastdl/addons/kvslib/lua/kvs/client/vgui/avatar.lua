local PANEL = {}

-- TODO
KVS:AccessorFunc(PANEL, '_vertices', 'Vertices',	FORCE_NUMBER) -- so you can call panel:SetVertices and panel:GetRotation
KVS:AccessorFunc(PANEL, '_rotation', 'Rotation', 	FORCE_NUMBER) -- so you can call panel:SetRotation and panel:GetRotation
KVS:AccessorFunc(PANEL, '_segments', 'Segments',	FORCE_NUMBER) -- so you can call panel:SetSegments and panel:GetSegments
KVS:AccessorFunc(PANEL, '_type', 'Type', 			FORCE_STRING) -- so you can call panel:SetType and panel:GetType

local function CalculatePolyCircle( pnl, _x, _y )
	local _x = _x / 2
	local _y = _y / 2
	local _r = _y

	local _points = pnl._segments or 40

	 local _u = ( _x + _r * 320 ) - _x
   local _v = ( _y + _r * 320 ) - _y
 
    local _slices = ( 2 * math.pi ) / _points
    local _poly = { }
    for i = 0, _points - 1 do
        local _angle = ( _slices * i ) % _points
        local x = _x + _r * math.cos( _angle )
        local y = _y + _r * math.sin( _angle )
        table.insert( _poly, { x = x, y = y, u = _u, v = _v } )
    end
 
    return _poly
end

local function CalculatePolyLosange( pnl, w, h )
	local poly = {}

	local x = w / 2
	local y = h / 2
	local radius = h / 2

	table.insert(poly, { x = x, y = y })

	for i = 0, pnl._vertices do
		local a = math.rad( (i / pnl._vertices ) * - 360 ) + pnl._rotation
		table.insert( poly, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius } )
	end

	local a = math.rad( 0 )
	table.insert( poly, { x = x + math.sin(a) * radius, y = y + math.cos(a) * radius } )

	return poly
end

local types = {
	['square'] = true,
	['circle'] = CalculatePolyCircle,
	['losange'] = CalculatePolyLosange
}

-- TODO : override the other functions with the new method
-- EDIT : maybe it's not necessary as it's herited from KVS.Panel, but i let you check it Kotus
function PANEL:Init( )
	local this = self

	self._rotation = 0
	self._vertices = 4
	self.Avatar = vgui.Create( 'AvatarImage', self:GetParent( ) )
	self.Avatar:SetPaintedManually( true )
	self.Avatar:SetZPos( self:GetZPos( ) - 1 )
	
	function self.Avatar:OnMousePressed( )
		if not IsValid( this ) or not this.OnMousePressed then return end
		this:OnMousePressed( )
	end
	function self.Avatar:OnMouseReleased( )
		if not IsValid( this ) or not this.OnMouseReleased then return end
		this:OnMouseReleased( )
	end
	self._type = 'square'
end

-- return the different types of AvatarImage
function PANEL:GetTypes( )
	return types
end

function PANEL:PerformLayout( )
	local wide, tall = self:GetWide( ), self:GetTall( )
	self.Avatar:SetSize( wide, tall )

	if not types[ self._type ] or not isfunction( types[ self._type ] ) then return end

	self._data = types[ self._type ]( self, wide, tall )
end

function PANEL:SetPlayer( ply, size )
	self.Avatar:SetPlayer( ply, size )
	return self
end

function PANEL:DrawPoly( w, h )
	if ( !self._data[ self._type ] ) then
		if not types[ self._type ] or not isfunction( types[ self._type ] ) then return end
		self._data = self._data or {}
		self._data[ self._type ] = types[ self._type ]( self, w, h )
	end

	surface.DrawPoly( self._data[ self._type ] )
end

function PANEL:OnSizeChanged( w, h )
	if w ~= h then
		self:SetSize( w, w )
	end
	self.Avatar:SetSize( w, w )
end

function PANEL:Paint( w, h )
	self.Avatar:SetPos( self:GetPos( ) )
	if not types[ self._type ] or not isfunction( types[ self._type ] ) then 
		self.Avatar:PaintManual( )
		return 
	end

	render.ClearStencil( )
	render.SetStencilEnable( true )

	render.SetStencilWriteMask( 1 )
	render.SetStencilTestMask( 1 )

	render.SetStencilFailOperation( STENCILOPERATION_REPLACE )
	render.SetStencilPassOperation( STENCILOPERATION_ZERO )
	render.SetStencilZFailOperation( STENCILOPERATION_ZERO )
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NEVER )
	render.SetStencilReferenceValue( 1 )

	draw.NoTexture( )
	surface.SetDrawColor( color_white )
	self:DrawPoly( w, h )

	render.SetStencilFailOperation( STENCILOPERATION_ZERO )
	render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
	render.SetStencilZFailOperation( STENCILOPERATION_ZERO )
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
	render.SetStencilReferenceValue( 1 )

	self.Avatar:PaintManual( )

	render.SetStencilEnable( false )
	render.ClearStencil( )
end

derma.DefineControl('KVS.AvatarImage', nil, PANEL, 'KVS.Panel')