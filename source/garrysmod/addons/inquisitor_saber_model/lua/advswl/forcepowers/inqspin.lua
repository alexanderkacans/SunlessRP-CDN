wOS.ForcePowers:RegisterNewPower({
        name = "Inquisitor's Spin Toggle",
        icon = "IS",
        image = "wos/forceicons/repulse.png",
        description = "SPIN TO WIN",
        think = function( self )
            if ( self:GetNextSecondaryFire() > CurTime() ) then return end
            if ( !self.Owner:KeyDown( IN_ATTACK2 ) ) then if self:GetSequence() != 0 then self:SetSequence(0) end return end
            if self:GetSequence() == 0 then
                self:SetSequence( self:LookupSequence( "spin" ) )
            end
            self:SetCycle( self:GetCycle() + 0.04 )
            if self:GetCycle() >= 1 then
                self:SetCycle( 0 )
            end    
        end,
})

wOS.ForcePowers:RegisterNewPower({
        name = "Inquisitor's Spin",
        icon = "IS",
        image = "wos/forceicons/repulse.png",
        description = "You spin me right round..",
        action = function( self )
            if not self._SPINME then self._SPINME = false end
            self._SPINME = !self._SPINME
            if !self._SPINME then
                self:SetSequence(0)
            else
                self:SetSequence( self:LookupSequence( "spin" ) )
            end
        end,
        think = function( self )
            if not self._SPINME then self._SPINME = false return end
            self:SetCycle( self:GetCycle() + 0.04 )
            if self:GetCycle() >= 1 then
                self:SetCycle( 0 )
            end    
        end,
})