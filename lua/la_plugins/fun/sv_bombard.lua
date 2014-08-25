----------------------------------------------------------------
-- Bombard
----------------------------------------------------------------
local Plugin = {}
Plugin.Name = "bombard"
Plugin.Author = "Goluch"
Plugin.Description = "Bombard a player"
Plugin.Commands = { "Bombard" }

Plugin.Help = {}
Plugin.Help["Bombard"] = "[player(s)]"

Plugin.Category = "Fun"

Plugin.Privs = table.Copy( Plugin.Commands )

function Plugin:Bombard( Ply, args )
	if (LA:CheckAllowed( Ply, Plugin, "Bombard" )) then
		if (#args>0) then
			local Targets = LA:FindPlayers( args )
			if (#Targets>0) then
				for _, v in ipairs( Targets ) do
					self:NPCKill( v )
				end
				LA:Message( LA.Colors.Green, Ply:Nick(), LA.Colors.White, " is bombarding ", LA.Colors.Blue, LA:GetNameList( Targets ), LA.Colors.White, "." )
			else
				LA:Message( Ply, unpack( LA.NoPlayersFound ) )
			end
		else
			LA:Message( Ply, unpack( LA.NoNameEntered ) )
		end
	else
		LA:Message( Ply, unpack( LA.NotAllowed) )
	end
end

function Plugin:NPCKill( Ply )
	Ply:SetMoveType(MOVETYPE_WALK)
	Ply:GodDisable( )
	Ply:Freeze(true)
	
	local NPCS = { }
	
	for i = 1 , 8 do
		local pos = Ply:GetForward( ) * 300
		pos:Rotate( Angle(0, i * 45, 0) )
		pos = pos + Ply:GetShootPos( )
		
		local NPC = ents.Create( "NPC_manhack" )
		NPC:SetPos( pos )
		NPC:SetAngles((Ply:GetShootPos()-NPC:GetPos()):Angle())
		NPC:Spawn( )
		NPC:Activate( )
		
		for _,V in pairs( player.GetAll( ) ) do
			NPC:AddEntityRelationship(V, D_NU, 99 )
		end
		
		NPC:Give( "ai_weapon_rpg" )
		NPC:AddEntityRelationship( Ply, D_HT, 99 )
		NPC:SetEnemy( Ply )
		NPC:SetSchedule( SCHED_RANGE_ATTACK1 )
		
		table.insert( NPCS, NPC )
	end
	
	timer.Simple( 10, function( )
		for _, NPC in pairs( NPCS ) do
			NPC:Remove( )
		end
		
		Ply:Freeze( false )
	end )
	
end

LA:AddPlugin( Plugin )