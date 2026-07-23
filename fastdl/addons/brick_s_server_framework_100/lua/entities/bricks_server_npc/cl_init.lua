include('shared.lua')

local Padding = 10
function ENT:Draw()
	self:DrawModel()

	local ShopName = ((BRICKS_SERVER.CONFIG.NPCS or {})[(self:GetNPCKeyVar() or 0)] or {}).Name or self.PrintName

    local Pos = self:GetPos()
    local Ang = self:GetAngles()

    Ang:RotateAroundAxis(Ang:Up(), 90)
	Ang:RotateAroundAxis(Ang:Forward(), 90)

	local YPos = -(self:OBBMaxs().z*20)-5

	local Distance = LocalPlayer():GetPos():DistToSqr( self:GetPos() )

	if( Distance < BRICKS_SERVER.CONFIG.GENERAL["3D2D Display Distance"] ) then
		cam.Start3D2D(Pos + Ang:Up() * 0.5, Ang, 0.05)
		
			surface.SetFont("BRICKS_SERVER_Font45")
		
			local width, height = surface.GetTextSize( ShopName )
			width, height = width+20, height+15

			draw.RoundedBox( 5, -(width/2)-Padding, YPos-(height+(2*Padding)), width+(2*Padding), height+(2*Padding), BRICKS_SERVER.Func.GetTheme( 1 ) )		
			draw.RoundedBox( 5, -(width/2)-Padding, YPos-(height+(2*Padding)), 20, height+(2*Padding), BRICKS_SERVER.Func.GetTheme( 5 ) )	

			surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
			surface.DrawRect( -(width/2)-Padding+5, YPos-(height+(2*Padding)), 15, height+(2*Padding) )

			draw.SimpleText( ShopName, "BRICKS_SERVER_Font45", 0, YPos-((height+(2*Padding))/2), BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 1 )
			
		cam.End3D2D()
	end
end