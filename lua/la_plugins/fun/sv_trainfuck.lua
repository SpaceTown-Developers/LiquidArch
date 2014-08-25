----------------------------------------------------------------
-- Trainfuck
----------------------------------------------------------------
local Plugin = {}
Plugin.Name = "Trainfuck"
Plugin.Author = "Divran"
Plugin.Description = "Trainfuck a player"
Plugin.Commands = { "Trainfuck" }

Plugin.Help = {}
Plugin.Help["Trainfuck"] = "[player(s)]"

Plugin.Category = "Fun"

Plugin.Privs = table.Copy( Plugin.Commands )

function Plugin:Trainfuck( ply, args )
	if (LA:CheckAllowed( ply, Plugin, "Trainfuck" )) then
		if (#args>0) then
			local Targets = LA:FindPlayers( args )
			if (#Targets>0) then
				for _, v in ipairs( Targets ) do
					v:SetMoveType(MOVETYPE_WALK)
					local Pos = v:GetPos() + v:GetForward() * 1000 + Vector(0,0,50)
					local Dir = v:GetForward() * -1
					self:SpawnTrain( Pos, Dir )
				end
				LA:Message( LA.Colors.Green, ply, LA.Colors.White, " trainfucked ", LA.Colors.Blue, LA:GetNameList( Targets ), LA.Colors.White, "." )
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

function Plugin:SpawnTrain( Pos, Direction )
	local train = ents.Create( "prop_physics" )
	train:SetModel("models/props_combine/CombineTrain01a.mdl")
	train:SetAngles( Direction:Angle() )
	train:SetPos( Pos )
	train:Spawn()
	train:Activate()
	train:EmitSound( "ambient/alarms/train_horn2.wav", 100, 100 )
	train:GetPhysicsObject():SetVelocity( Direction * 50000 )
	
	timer.Create( "LA_TrainFuck_"..CurTime().."_"..tostring(train), 8, 1, function( ) train:Remove() end )
end

LA:AddPlugin( Plugin )