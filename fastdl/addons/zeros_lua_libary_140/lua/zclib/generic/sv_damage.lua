if not SERVER then return end
zclib = zclib or {}
zclib.Damage = zclib.Damage or {}

// Creates a util.Effect
function zclib.Damage.Effect(ent,effect)
	local vPoint = ent:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart(vPoint)
	effectdata:SetOrigin(vPoint)
	effectdata:SetScale(1)
	util.Effect(effect, effectdata)
end

function zclib.Damage.Repair(entity)
	entity:SetHealth(entity:GetMaxHealth())
	zclib.Sound.EmitFromEntity("zapp", entity)
	local effectdata = EffectData()
	effectdata:SetOrigin(entity:LocalToWorld(vector_origin))
	effectdata:SetMagnitude(2)
	effectdata:SetScale(1)
	effectdata:SetRadius(3)
	util.Effect("cball_bounce", effectdata)
	entity:SetColor(Color(255, 255, 255, 255))
end

// Causes damage to any player in distance
function zclib.Damage.Explosion(attacker, pos, radius, dmg_type, dmg_amount,player_only)
	for k, v in pairs(ents.FindInSphere(pos, radius)) do
		if IsValid(v) then
			if player_only and v:IsPlayer() == false then continue end
			local d = DamageInfo()
			d:SetDamage(dmg_amount)
			d:SetAttacker(attacker)
			d:SetDamageType(dmg_type)
			v:TakeDamageInfo(d)
		end
	end
end
