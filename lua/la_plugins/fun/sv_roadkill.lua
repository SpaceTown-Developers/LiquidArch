----------------------------------------------------------------
-- Teleport
----------------------------------------------------------------
local Plugin = {}
Plugin.Name = "RoadKill"
Plugin.Author = "Divran"
Plugin.Description = "Roadkill a player"
Plugin.Commands = { "Roadkill" }

Plugin.Help = {}
Plugin.Help["Roadkill"] = "[player(s)]"

Plugin.Category = "Fun"

Plugin.Privs = table.Copy( Plugin.Commands )

function Plugin:Roadkill( ply, args )
	if (LA:CheckAllowed( ply, Plugin, "Roadkill" )) then
		if (#args>0) then
			local Targets = LA:FindPlayers( args )
			if (#Targets>0) then
				for _, v in ipairs( Targets ) do
					v:SetMoveType(MOVETYPE_WALK)
					local Pos = v:GetPos() + v:GetForward() * 1000 + Vector(0,0,50)
					local Dir = v:GetForward() * -1
					self:SpawnAPC( Pos, Dir )
				end
				LA:Message( LA.Colors.Green, ply:Nick(), LA.Colors.White, " roadkilled ", LA.Colors.Blue, LA:GetNameList( Targets ), LA.Colors.White, "." )
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

function Plugin:SpawnAPC( Pos, Direction )
	local apc = ents.Create( "prop_physics" )
	apc:SetModel("models/combine_apc.mdl")
	apc:SetAngles( Direction:Angle() + Angle(0,90,0) )
	apc:SetPos( Pos )
	apc:Spawn()
	apc:Activate()
	apc:EmitSound( "vehicles/APC/apc_cruise_loop3.wav", 100, 100 )
	apc:GetPhysicsObject():SetVelocity( Direction * 10000 )
	
	timer.Create( "LA_RoadKill_"..CurTime().."_"..tostring(apc), 5, 1, function( ) apc:Remove() end )
end

LA:AddPlugin( Plugin )