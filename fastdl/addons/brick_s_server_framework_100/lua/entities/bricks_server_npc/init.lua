AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel( "models/breen.mdl" )

	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_BBOX )
	self:SetCollisionGroup( COLLISION_GROUP_PLAYER )
end

function ENT:SetNPCKey( NPCKey )
	self:SetNPCKeyVar( NPCKey )

	local configTable = BRICKS_SERVER.CONFIG.NPCS[NPCKey]
	if( configTable and configTable.Model ) then
		self:SetModel( configTable.Model )
	else
		self:SetModel( "models/breen.mdl" )
	end

	if( configTable ) then
		local typeTable = BRICKS_SERVER.DEVCONFIG.NPCTypes[configTable.Type or ""]
		if( typeTable and typeTable.OnSpawn ) then
			typeTable.OnSpawn( self, NPCKey )
		end
	end
end

function ENT:AcceptInput(ply, caller)
	if( (caller.BRS_NPC_COOLDOWN or 0) > CurTime() ) then return end
	caller.BRS_NPC_COOLDOWN = CurTime()+1

	if( not self:GetNPCKeyVar() or not BRICKS_SERVER.CONFIG.NPCS[self:GetNPCKeyVar()] ) then return end

	local NPCTable = BRICKS_SERVER.CONFIG.NPCS[self:GetNPCKeyVar()]
	local typeTable = BRICKS_SERVER.DEVCONFIG.NPCTypes[NPCTable.Type or ""]

	if( typeTable and typeTable.UseFunction ) then
		typeTable.UseFunction( caller, self, self:GetNPCKeyVar() )
	else
		BRICKS_SERVER.Func.SendNotification( caller, 1, 5, BRICKS_SERVER.Func.L( "invalidNPC" ) )
	end
end

function ENT:OnTakeDamage( dmgInfo )
	return 0
end