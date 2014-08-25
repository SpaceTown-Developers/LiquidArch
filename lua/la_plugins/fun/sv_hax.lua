----------------------------------------------------------------
-- Teleport
----------------------------------------------------------------
local Plugin = {}
Plugin.Name = "Hax"
Plugin.Author = "Goluch"
Plugin.Description = "Be like DR.Hax and chuck a monitor at a player"
Plugin.Commands = { "Hax" }

Plugin.Help = {}
Plugin.Help["Hax"] = "[player(s)]"

Plugin.Category = "Fun"

Plugin.Privs = table.Copy( Plugin.Commands )

function Plugin:Hax( ply, args )
	if (LA:CheckAllowed( ply, Plugin, "Hax" )) then
		if (#args>0) then
			local Targets = LA:FindPlayers( args )
			if (#Targets>0) then
				for _, v in ipairs( Targets ) do
					v:SetMoveType(MOVETYPE_WALK)
					local Pos = v:GetPos() + v:GetForward() * 2000 + Vector(0,0,80)
					local Dir = v:GetForward() * -1
					self:SpawnHAX( Pos, Dir )
				end
				LA:Message( LA.Colors.Green, ply:Nick(), LA.Colors.White, " PWNED ", LA.Colors.Blue, LA:GetNameList( Targets ), LA.Colors.White, "." )
			else
				LA:Message( ply, unpack( LA.NoPlayersFound ) )
			end
		else
			LA:Message( ply, unpack( LA.NoNameEntered ) )
		end
	else
		LA:Message( ply, unpack( LA.NotAllowed) )
	end
end

function Plugin:SpawnHAX( Pos, Direction )
	local hax = ents.Create( "prop_physics" )
	hax:SetModel("models/props_lab/monitor02.mdl")
	hax:SetAngles( Direction:Angle() )
	hax:SetPos( Pos )
	hax:Spawn()
	hax:Activate()
	hax:GetPhysicsObject():SetMass( 50000 )
	hax:EmitSound( "vo/npc/male01/hacks01.wav", 100, 100 )
	hax:GetPhysicsObject():SetVelocity( Direction * 5000 )

	timer.Create("LA_HAXE_"..CurTime()..tostring(hax), 3 , 0.05, function( )
		local Effect = EffectData()
		Effect:SetOrigin( hax:GetPos() )
		util.Effect( "la_rocket_trail", Effect )
	end)
	
	timer.Create( "LA_HAX_"..CurTime().."_"..tostring(hax), 3, 1, function( )
		local Effect = EffectData()
		Effect:SetOrigin( hax:GetPos() )
		Effect:SetStart( hax:GetPos() )
		Effect:SetMagnitude(1024)
		Effect:SetScale(256)
		util.Effect("Explosion", Effect)
		hax:Remove()
	end )
end

LA:AddPlugin( Plugin )