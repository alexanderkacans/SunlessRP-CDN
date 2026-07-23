local PANEL = {}

function PANEL:Init()

end

function PANEL:SetRarityName( rarityName, direction, rarityInfo )
	self:Clear()

	self.rarityInfo = rarityInfo or BRICKS_SERVER.Func.GetRarityInfo( rarityName )

	if( not self.rarityInfo ) then return end

	self.rarityType = self.rarityInfo[2]

	if( (self.rarityType == "Gradient" or self.rarityType == "Fade") and (not self.rarityInfo[3] or #self.rarityInfo[3] <= 1) ) then
		self.rarityType = "SolidColor"
	end

	if( self.rarityType == "Gradient" or self.rarityType == "Rainbow" ) then
		self.colorPanel = vgui.Create( "bricks_server_gradientanim", self )
		self.colorPanel:SetPos( 0, 0 )
		self.colorPanel:SetSize( self:GetSize() )

		if( direction ) then
			self.colorPanel:SetDirection( direction )
		end
		
		if( self.rarityType == "Rainbow" ) then
			self.colorPanel:TasteTheRainbow()
		else
			self.colorPanel:SetColors( unpack( self.rarityInfo[3] ) )
		end

		self.colorPanel:StartAnim()
	else
		local panelColors
		if( self.rarityType == "Fade" ) then
			panelColors = self.rarityInfo[3]
		else
			panelColors = { self.rarityInfo[3] }
		end

		local fadeTime = 3
		local changeTime, currentColor, nextColor = CurTime()+fadeTime, 1, 2

		self.colorPanel = vgui.Create( "DPanel", self )
		self.colorPanel:SetPos( 0, 0 )
		self.colorPanel:SetSize( self:GetSize() )
		self.colorPanel.Paint = function( self2, w, h )
			local panelColor = panelColors[1]
			if( self.rarityType == "Fade" ) then
				if( CurTime() >= changeTime ) then
					changeTime, currentColor, nextColor = CurTime()+fadeTime, nextColor, ((panelColors[nextColor+1] and nextColor+1) or 1)
				end

				local curColor, nextColor = panelColors[currentColor], panelColors[nextColor]
				local percent = (fadeTime-(changeTime-CurTime()))/fadeTime

				panelColor = Color( Lerp( percent, curColor.r, nextColor.r ), Lerp( percent, curColor.g, nextColor.g ), Lerp( percent, curColor.b, nextColor.b ) )
			end
			
			if( self.cornerRadius > 0 ) then
				draw.RoundedBox( self.cornerRadius, (self.roundedBoxX or 0), (self.roundedBoxY or 0), (self.roundedBoxW or w), (self.roundedBoxH or h), panelColor )
			else
				surface.SetDrawColor( panelColor )
				surface.DrawRect( (self.roundedBoxX or 0), (self.roundedBoxY or 0), (self.roundedBoxW or w), (self.roundedBoxH or h) )
			end
		end
	end
end

function PANEL:SetRarityInfo( rarityInfo, direction )
	self:SetRarityName( false, direction, rarityInfo )
end

function PANEL:OnSizeChanged( w, h )
	if( IsValid( self.colorPanel ) ) then
		self.colorPanel:SetSize( w, h )
	end
end

function PANEL:SetCornerRadius( cornerRadius )
	self.cornerRadius = cornerRadius

	if( self.rarityType != "Gradient" and self.rarityType != "Rainbow" ) then return end

    self.colorPanel:SetCornerRadius( cornerRadius )
end

function PANEL:SetRoundedBoxDimensions( roundedBoxX, roundedBoxY, roundedBoxW, roundedBoxH )
	self.roundedBoxX, self.roundedBoxY, self.roundedBoxW, self.roundedBoxH = roundedBoxX, roundedBoxY, roundedBoxW, roundedBoxH

	if( self.rarityType != "Gradient" and self.rarityType != "Rainbow" ) then return end

	self.colorPanel:SetRoundedBoxDimensions( roundedBoxX, roundedBoxY, roundedBoxW, roundedBoxH )
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_raritybox", PANEL, "DPanel" )