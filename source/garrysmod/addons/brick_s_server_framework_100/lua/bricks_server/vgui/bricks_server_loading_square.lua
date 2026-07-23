local PANEL = {}

function PANEL:Init()
    self.loadingDuration = 0.6
    self.finishFadeDuration = 0.5

    self:SetSize( BRICKS_SERVER.Func.Repeat( BRICKS_SERVER.Func.ScreenScale( 50 ), 2 ) )
    self.boxPositions = {}
    self.loadingX, self.loadingY = 0, 0
    self.oldX, self.oldY = 0, 0
    self.targetBox = 1
    self.loadingStart = 0
end

function PANEL:BeginAnimation()
    local size = (self:GetWide()-BRICKS_SERVER.UI.Margin5)/2

    for i = 1, 4 do
        local loadingBox = vgui.Create( "DPanel", self )
        loadingBox:SetSize( BRICKS_SERVER.Func.Repeat( size, 2 ) )
        loadingBox:SetPos( i % 2 == 0 and size+BRICKS_SERVER.UI.Margin5 or 0, i > 2 and size+BRICKS_SERVER.UI.Margin5 or 0 )
        loadingBox.index = i
        loadingBox.Paint = function( self2, w, h ) 
            surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
            surface.DrawRect( 0, 0, w, h )

            if( self.finished ) then 
                surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 4, (CurTime()-self.finishTime)/self.finishFadeDuration*255 ) )
                surface.DrawRect( 0, 0, w, h )
                return 
            end

            surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 4 ) )
            local x, y = self2:ScreenToLocal( self:LocalToScreen( self.loadingX, self.loadingY ) )
            surface.DrawRect( x, y, w, h )
        end

        table.insert( self.boxPositions, { loadingBox:GetPos() } )
    end

    self:MoveLoadingBox( 2 )
end

function PANEL:MoveLoadingBox( target )
    self.targetBox = target > 4 and 1 or target
    self.oldX, self.oldY = self.loadingX, self.loadingY
    self.loadingStart = CurTime()

    timer.Simple( self.loadingDuration, function()
        if( not IsValid( self ) ) then return end
        self:MoveLoadingBox( (self.targetBox == 1 and 2) or (self.targetBox == 2 and 4) or (self.targetBox == 4 and 3) or 1 )
    end )
end

function PANEL:FinishLoading()
    self.finishTime = CurTime()
    self.finished = true
    self:SizeTo( 0, 0, 0.2, self.finishFadeDuration+0.2, -1, function()
        self:Remove()
    end )
end

function PANEL:OnSizeChanged( w, h )
    if( not self.finished ) then return end
    self:SetPos( self.centerX-w/2, self.centerY-h/2 )

    local size = (self:GetWide()-PROJECT0.UI.Margin5)/2
    for k, v in ipairs( self:GetChildren() ) do
        v:SetSize( BRICKS_SERVER.Func.Repeat( size, 2 ) )
        v:SetPos( k % 2 == 0 and size+PROJECT0.UI.Margin5 or 0, k > 2 and size+PROJECT0.UI.Margin5 or 0 )
    end
end

function PANEL:PerformLayout( width, height )
    if( self.finished ) then return end
    self.centerX, self.centerY = self:GetX()+width/2, self:GetY()+height/2
end

function PANEL:Think()
    local percent = math.Clamp( (CurTime()-self.loadingStart)/self.loadingDuration, 0, 1 )
    self.loadingX, self.loadingY = Lerp( percent, self.oldX, self.boxPositions[self.targetBox][1] ), Lerp( percent, self.oldY, self.boxPositions[self.targetBox][2] )
end

vgui.Register( "bricks_server_loading_square", PANEL, "Panel" )