----------------------------------------------------------------
-- Explode
----------------------------------------------------------------
Plugin = {}
Plugin.Name = "Explode"
Plugin.Author = "Goluch"
Plugin.Description = "Explode yourself or another player in a burst of flames!"
Plugin.Commands = { "Explode","Rocket" }

Plugin.Help = {}
Plugin.Help["Explode"] = "[player(s)]"
Plugin.Help["Rocket"] = "[player(s)]"

Plugin.Category = "Fun"

Plugin.Privs = table.Copy( Plugin.Commands )

function Plugin:ExplodePlayer(ply)
	local Effect = EffectData()
	Effect:SetOrigin( ply:GetPos() )
	Effect:SetStart( ply:GetPos() )
	Effect:SetMagnitude(1024)
	Effect:SetScale(256)
	util.Effect("Explosion", Effect)
	timer.Simple(0.1, function() ply:Kill() end)
end

function Plugin:Explode( ply, args )
	if (LA:CheckAllowed( ply, Plugin, "Explode" )) then
		if (args[1]) then
			local Targets = LA:FindPlayers( args )
			if (#Targets) then
				for k,v in ipairs( Targets ) do
					self:ExplodePlayer(v)
				end
				LA:Message( LA.Colors.Green, ply, LA.Colors.White, " exploded ", LA.Colors.Blue, LA:GetNameList(Targets), LA.Colors.White, "." )
			else
				LA:Message( ply, unpack( LA.NoPlayersFound ) )
			end
		else
			self:ExplodePlayer(ply)
			LA:Message( LA.Colors.Green, ply, LA.Colors.White, " exploded themself." )
		end
	end
end

function Plugin:RocketPlayer(ply)
	ply:SetMoveType(MOVETYPE_WALK)
	ply:SetVelocity(Vector(0, 0, 2048))
	ply.LA_Rocket = true
	timer.Simple(3,function()
		self:ExplodePlayer(ply)
		ply.LA_Rocket = nil
		timer.Destroy("rocket_"..ply:UniqueID())
	end)
	
	timer.Create("rocket_"..ply:UniqueID(), 0.05 , 0, function()
		local Effect = EffectData()
		Effect:SetOrigin( ply:GetPos() )
		util.Effect( "la_rocket_trail", Effect )
	end )
end

function Plugin:PlayerNoClip(ply)
	if (ply.LA_Rocket) then return false end
end


function Plugin:Rocket( ply, args )
	if (LA:CheckAllowed( ply, Plugin, "Rocket" )) then
		if (args[1]) then
			local Targets = LA:FindPlayers( args )
			if (#Targets) then
				for k,v in ipairs( Targets ) do
					self:RocketPlayer(v)
				end
				LA:Message( LA.Colors.Green, ply, LA.Colors.White, " has rocketed ", LA.Colors.Blue, LA:GetNameList(Targets), LA.Colors.White, "." )
			else
				LA:Message( ply, unpack( LA.NoPlayersFound ) )
			end
		else
			self:RocketPlayer(ply)
			LA:Message( LA.Colors.Green, ply, LA.Colors.White, " has rocketed themself." )
		end
	end
end

LA:AddPlugin( Plugin )