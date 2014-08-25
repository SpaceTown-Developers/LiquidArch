----------------------------------------------------------------
-- Health
----------------------------------------------------------------
local Plugin = {}
Plugin.Name = "Health"
Plugin.Author = "Divran"
Plugin.Description = "Change the health of a player."
Plugin.Commands = { "Hp", "Health" }

Plugin.Help = {}
Plugin.Help["Hp"] = "[player(s)] [health] or [health]"
Plugin.Help["Health"] = "[player(s)] [health] or [health]"

Plugin.Category = "Buffs"

Plugin.Privs = { "Health" }

function Plugin:Hp( ply, args )
	if (LA:CheckAllowed( ply, Plugin, "Health" )) then
		if (#args>0) then
			local hp = math.Clamp( tonumber(args[#args]), 1, 99999 )
			table.remove( args, #args )
			if (#args>0) then
				local Targets = LA:FindPlayers( args )
				if (#Targets>0) then
					for k,v in ipairs( Targets ) do
						v:SetHealth( hp )
					end
					LA:Message( LA.Colors.Green, ply, LA.Colors.White, " set the health of ", LA.Colors.Blue, LA:GetNameList( Targets ), LA.Colors.White, " to ", LA.Colors.Blue, tostring(hp), LA.Colors.White, "." )
				else
					LA:Message( ply, unpack( LA.NoPlayersFound ) )
				end
			else
				ply:SetHealth( hp )
				LA:Message( LA.Colors.Green, ply, LA.Colors.White, " set their health to ", LA.Colors.Blue, tostring(hp), LA.Colors.White, "." )
			end
		else
			LA:Message( ply, unpack( LA.NoNameEntered ) )
		end
	else
		LA:Message( ply, unpack( LA.NotAllowed ) )
	end
end

Plugin.Health = Plugin.Hp

LA:AddPlugin( Plugin )