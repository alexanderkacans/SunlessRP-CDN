local PANEL = {}

function PANEL:Init()

	self.movePanel = vgui.Create( "DPanel", self )
	self.movePanel:SetPos( 0, 0 )
	self.movePanel.Paint = function( self2, w, h )
		local movePanelX, movePanelY = self2:GetPos()

		BRICKS_SERVER.Func.DrawRoundedMask( (self.cornerRadius or 5), -movePanelX+(self.roundedBoxX or 0), -movePanelY+(self.roundedBoxY or 0), (self.roundedBoxW or self:GetWide()), (self.roundedBoxH or self:GetTall()), function()
			if( not BRICKS_SERVER.CONFIG.GENERAL["Use Textured Gradients (Better FPS)"] ) then
				if( self.direction != 1 ) then
					BRICKS_SERVER.Func.DrawGradientBox( 0, 0, self.animSize, h, self.direction, unpack( self.colors ) )
					BRICKS_SERVER.Func.DrawGradientBox( self.animSize, 0, self.animSize, h, self.direction, unpack( table.Reverse( self.colors ) ) )
					BRICKS_SERVER.Func.DrawGradientBox( self.animSize*2, 0, self.animSize, h, self.direction, unpack( self.colors ) )
				else
					BRICKS_SERVER.Func.DrawGradientBox( 0, 0, w, self.animSize, self.direction, unpack( self.colors ) )
					BRICKS_SERVER.Func.DrawGradientBox( 0, self.animSize, w, self.animSize, self.direction, unpack( table.Reverse( self.colors ) ) )
					BRICKS_SERVER.Func.DrawGradientBox( 0, self.animSize*2, w, self.animSize, self.direction, unpack( self.colors ) )
				end
			else
				if( self.direction != 1 ) then
					BRICKS_SERVER.Func.DrawTexturedGradientBox( 0, 0, self.animSize, h, self.direction, unpack( self.colors ) )
					BRICKS_SERVER.Func.DrawTexturedGradientBox( self.animSize, 0, self.animSize, h, self.direction, unpack( table.Reverse( self.colors ) ) )
					BRICKS_SERVER.Func.DrawTexturedGradientBox( self.animSize*2, 0, self.animSize, h, self.direction, unpack( self.colors ) )
				else
					BRICKS_SERVER.Func.DrawTexturedGradientBox( 0, 0, w, self.animSize, self.direction, unpack( self.colors ) )
					BRICKS_SERVER.Func.DrawTexturedGradientBox( 0, self.animSize, w, self.animSize, self.direction, unpack( table.Reverse( self.colors ) ) )
					BRICKS_SERVER.Func.DrawTexturedGradientBox( 0, self.animSize*2, w, self.animSize, self.direction, unpack( self.colors ) )
				end
			end
		end )
	end

	self:SetColors( Color( 255, 255, 255 ), Color( 0, 0, 0 ) )
	self:SetDirection( 0 )
	self:SetAnimTime( 2 )
end

function PANEL:StartAnim()
	self.movePanel:MoveTo( ((self.direction != 1 and -(self.animSize*2)) or 0), ((self.direction == 1 and -(self.animSize*2)) or 0), self.animTime, 0, 1, function()
		self.movePanel:SetPos( 0, 0 )
		self:StartAnim()
	end )
end

function PANEL:OnSizeChanged( w, h )
	if( self.direction != 1 ) then
		self.movePanel:SetTall( h )
	else
		self.movePanel:SetWide( w )
	end

	self:SetAnimSize( (self.direction != 1 and w) or h )
end

function PANEL:SetAnimSize( animSize )
	self.animSize = animSize
	
	if( self.direction != 1 ) then
		self.movePanel:SetWide( self.animSize*3 )
	else
		self.movePanel:SetTall( self.animSize*3 )
	end
end

function PANEL:SetColors( ... )
	self.colors = { ... }
end

function PANEL:SetCornerRadius( cornerRadius )
    self.cornerRadius = cornerRadius
end

function PANEL:SetAnimTime( animTime )
    self.animTime = animTime
end

function PANEL:SetDirection( direction )
	self.direction = direction

	self:SetAnimSize( (self.direction != 1 and self:GetWide()) or self:GetTall() )
end

function PANEL:SetRoundedBoxDimensions( roundedBoxX, roundedBoxY, roundedBoxW, roundedBoxH )
    self.roundedBoxX, self.roundedBoxY, self.roundedBoxW, self.roundedBoxH = roundedBoxX, roundedBoxY, roundedBoxW, roundedBoxH
end

function PANEL:TasteTheRainbow()
    self:SetAnimTime( 5 )
    self:SetAnimSize( ((self.direction != 1 and self:GetWide()) or self:GetTall())*6 )

    local rainbowColors, range = {}, 10
    for i = 1, range do
        table.insert( rainbowColors, HSVToColor( (i/range)*360, 1, 1 ) )
	end

    self:SetColors( unpack( rainbowColors ) )
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_gradientanim", PANEL, "DPanel" )