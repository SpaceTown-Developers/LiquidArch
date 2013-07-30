-- Rocket trail, made by Divran

function EFFECT:Init( data )
	local Pos = data:GetOrigin()
	
	local emitter = ParticleEmitter( Pos )
	
	local particle = emitter:Add( "particles/smokey", Pos + VectorRand() * 40 )
	if (particle) then
		particle:SetLifeTime( 0 )
		particle:SetDieTime( 2.5 )
		particle:SetStartAlpha( 255 )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( 75 )
		particle:SetEndSize( 0 )
		particle:SetColor( 200,200,200 )
		particle:SetGravity( Vector(0,0,-200) )
		particle:SetAirResistance( 50 )
	end
	particle = emitter:Add( "particles/flamelet"..math.random(1,5), Pos + VectorRand() * 20 )
	if (particle) then
		particle:SetLifeTime( 0 )
		particle:SetVelocity( Vector(0,0,-1000) )
		particle:SetDieTime( 2.5 )
		particle:SetStartAlpha( 255 )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( 25 )
		particle:SetEndSize( 5 )
		particle:SetRoll( math.random(-1,1) )
		particle:SetColor( 255,255,255 )
		particle:SetAirResistance( 200 )
	end
	
	emitter:Finish()
end

function EFFECT:Think( )
	return false
end

function EFFECT:Render()
end
