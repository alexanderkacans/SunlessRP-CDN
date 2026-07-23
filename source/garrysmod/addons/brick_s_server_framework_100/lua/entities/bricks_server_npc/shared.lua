ENT.Base = "base_ai" 
ENT.Type = "ai"
 
ENT.PrintName		= "Shop"
ENT.Category		= "Bricks Server"
ENT.Author			= "Brick Wall"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable		= false

function ENT:SetupDataTables()
    self:NetworkVar( "Int", 0, "NPCKeyVar" )
end