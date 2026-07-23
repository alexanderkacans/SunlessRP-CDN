
function EFFECT:Init( data )
	local pos = data:GetOrigin()
	local dir = data:GetNormal()
	local len = data:GetRadius()
	local color = data:GetAngles()
	local emitter = ParticleEmitter( pos )

	local number_lol = 1

	if ( !emitter ) then return end

	for i = 0, len / number_lol do
		local pos2 = pos + dir * ( len - i * number_lol )
		--local particle = emitter:Add( "effects/muzzleflash"..math.random(1,4), pos2 )
		local particle = emitter:Add( "wos/lightsabers/effects/anzati/christmas", pos2 )
		if ( particle ) then
			particle:SetLifeTime( 0 )
			particle:SetDieTime( 0.3 )

			particle:SetGravity( Vector( 0, 0, math.random( 32, 128 ) ) )
			particle:SetVelocity( Vector( math.random( -8, 8 ), math.random( -8, 8 ), math.random( -8, 8 ) ) )

			particle:SetStartSize( 1 )
			particle:SetEndSize( 0 )

			particle:SetStartAlpha( math.random( 100, 200 ) )
			particle:SetEndAlpha( 0 )

			particle:SetColor( color.p, color.y, color.r )
			particle:SetAngleVelocity( Angle( math.Rand( -180, 180 ), math.Rand( -180, 180 ), math.Rand( -180, 180 ) ) )
			//particle:SetLighting( true )
		end
	end

	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
