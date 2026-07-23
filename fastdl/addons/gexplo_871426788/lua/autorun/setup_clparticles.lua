

PrecacheParticleSystem("har_explosion_a")
PrecacheParticleSystem("har_explosion_b")
PrecacheParticleSystem("har_explosion_c")
PrecacheParticleSystem("har_explosion_a_air")
PrecacheParticleSystem("har_explosion_b_air")
PrecacheParticleSystem("har_explosion_c_air")



if (CLIENT) then 
	game.AddParticles( "particles/harry_explosion.pcf" )

end


if (SERVER) then 

	TRACKING_EXPLOSIVES_GLOBAL = {} 
	TRACKING_CB_GLOBAL = {} 
	TRACKING_DYNAMITES_GLOBAL = {}
--


	function CreateCBExplosion(pos, timelapsed)
	
	
		
		
		ParticleEffect(table.Random({"har_cb_explosion_a","har_cb_explosion_b"}), pos, Angle(0,0,0), nil)

		sound.Play( "hd/new_grenadeexplo.mp3", pos, 100, math.random(250,255), 1)
		
		for i=0, 9 do 
			timer.Simple(i/8 + (math.random() * 0.1), function()
				sound.Play("ambient/energy/newspark0"..i..".wav", pos, 100, math.random(250,255), 1)

			end)
		end
		
	end
	
	function CreateGrenadeExplosion(pos, elapsed_time)
		--if elapsed_time <= 2 then this check is invalid because we now have grenades, rpgs and other shit 

		local tr = util.TraceLine( {
			start  = pos,
			endpos = pos - Vector(0,0,60),
			mask   = MASK_SOLID_BRUSHONLY
		} )

		if tr.HitWorld then 
			ParticleEffect(table.Random({"har_explosion_a","har_explosion_b","har_explosion_c"}), pos, Angle(0,math.random(0,360),0), nil)

		else
			ParticleEffect(table.Random({"har_explosion_a_air","har_explosion_b_air","har_explosion_c"}), pos, Angle(0,math.random(0,360),0), nil)

		end
		
		sound.Play( "hd/new_grenadeexplo.mp3", pos, 100, math.random(90,110), 1)
		
	
		
	end
	
	function CheckForDynamite()
		
		local dynamites = ents.FindByClass("gmod_dynamite") 
	
		for k, v in pairs(dynamites) do 
			if not(TRACKING_DYNAMITES_GLOBAL[v]) then 
				TRACKING_DYNAMITES_GLOBAL[v] = {true, v:GetPos(), CurTime()}
				-- print("grenade spawned, time to overwrite its explode function")
				
				local ent = v 
				
								
				function ent:Explode( delay, ply )

					if ( !IsValid( self ) ) then return end

					ply = ply or self.Entity

					local _delay = delay or self:GetDelay()
					
					
					
					if ( _delay == 0 ) then

						local radius = 300
						CreateGrenadeExplosion(self:GetPos(), -1)
						util.BlastDamage( self, ply, self:GetPos(), radius, math.Clamp( self:GetDamage(), 0, 1500 ) )
					
						

						if ( self:GetShouldRemove() ) then self:Remove() return end
						if ( self:GetMaxHealth() > 0 && self:Health() <= 0 ) then self:SetHealth( self:GetMaxHealth() ) end

					else

						timer.Simple( _delay, function() if ( !IsValid( self ) ) then return end self:Explode( 0, ply ) end )

					end

				end
				
			else 
				-- nope, grenade is still in the table, but let's still update whatever shit needs to be updated
				TRACKING_DYNAMITES_GLOBAL[v][1] = true
				TRACKING_DYNAMITES_GLOBAL[v][2] = v:GetPos()
				

				
			end
		end
		
		for k, v in pairs(TRACKING_DYNAMITES_GLOBAL) do 
			if not(k:IsValid()) then				
				TRACKING_DYNAMITES_GLOBAL[k] = nil 		
			else
				-- send nudes 
			end
		end
	
	end
	
	
	function CheckForCB()
		
		local cb = ents.FindByClass("prop_combine_ball") 

		
		
		
		for k, v in pairs(cb) do 
			if not(TRACKING_CB_GLOBAL[v]) then 
				TRACKING_CB_GLOBAL[v] = {true, v:GetPos(), CurTime()}
				-- print("grenade spawned")
			else 
				-- nope, grenade is still in the table, but let's still update whatever shit needs to be updated
				TRACKING_CB_GLOBAL[v][1] = true
				TRACKING_CB_GLOBAL[v][2] = v:GetPos()
				

				
			end
		end
		
		for k, v in pairs(TRACKING_CB_GLOBAL) do 
			if not(k:IsValid()) then 
				print("it's not valid, prob gone")
				
				local pos, elapsed_time = v[2], (CurTime() - v[3])
				CreateCBExplosion(pos, elapsed_time)
				
				
				TRACKING_CB_GLOBAL[k] = nil 
				
			else
				-- send nudes 
			end
		end
	
	end
	
	
	function CheckForGrenadesAndRockets()
		
		local grenades = ents.FindByClass("npc_grenade_frag") 
		local rpgs     = ents.FindByClass("rpg_missile")
		
		table.Merge(grenades, rpgs)
		
		for k, v in pairs(grenades) do 
			if not(TRACKING_EXPLOSIVES_GLOBAL[v]) then 
				TRACKING_EXPLOSIVES_GLOBAL[v] = {true, v:GetPos(), CurTime()}
				-- print("grenade spawned")
			else 
				-- nope, grenade is still in the table, but let's still update whatever shit needs to be updated
				TRACKING_EXPLOSIVES_GLOBAL[v][1] = true
				TRACKING_EXPLOSIVES_GLOBAL[v][2] = v:GetPos()
				

				
			end
		end
		
		for k, v in pairs(TRACKING_EXPLOSIVES_GLOBAL) do 
			if not(k:IsValid()) then 
				print("it's not valid, prob gone")
				
				local pos, elapsed_time = v[2], (CurTime() - v[3])
				CreateGrenadeExplosion(pos, elapsed_time)
				
				
				TRACKING_EXPLOSIVES_GLOBAL[k] = nil 
				
			else
				-- send nudes 
			end
		end
	
	end
	
	if file.Exists( "autorun/gexplo_autorun.lua", "LUA" ) then 
	
	else
		
		hook.Add("Tick", "CheckForDynamite", CheckForDynamite)
		hook.Add("Think", "CheckForGrenadesAndRockets", CheckForGrenadesAndRockets)
	
	end
	
	hook.Add("Tick", "CheckForCB", CheckForCB)

	
end
