----------------------------------------------------------------
-- Freeze
----------------------------------------------------------------
local Plugin = {}
Plugin.Name = "Freeze"
Plugin.Author = "Divran"
Plugin.Description = "Freeze someone in place."
Plugin.Commands = { "Freeze", "Unfreeze" }

Plugin.Help = {}
Plugin.Help["Freeze"] = "[player(s)]"
Plugin.Help["Unfreeze"] = "[player(s)]"

Plugin.Category = "Punishment"

Plugin.Privs = table.Copy( Plugin.Commands )

function Plugin:Freeze(ply,args)
	if (LA:CheckAllowed( ply, Plugin, "Freeze" )) then
		if (#args>0) then
			local Targets = LA:FindPlayers( args )
			if (#Targets>0) then
				local frozen = {}
				for k,v in ipairs( Targets ) do
					if (!v:IsFrozen()) then
						v:Freeze(true)
						table.insert( frozen, v )
					end
				end
				if (#frozen>0) then
					LA:Message( LA.Colors.Green, ply, LA.Colors.White, " froze ", LA.Colors.Blue, LA:GetNameList( frozen ), LA.Colors.White, "." )
				else
					LA:Message( ply, LA.Colors.Red, "All the targets are already frozen." )
				end
			else
				LA:Message( ply, unpack( LA.NoPlayersFound ) )
			end
		else
			if (!ply:IsFrozen()) then
				ply:Freeze(true)
				LA:Message( LA.Colors.Green, ply, LA.Colors.White, " froze themself." )
			else
				LA:Message( ply, LA.Colors.Red, "You are already frozen." )
			end
		end
	else
		LA:Message( ply, unpack( LA.NotAllowed ) )
	end
end

function Plugin:Unfreeze(ply,args)
	if (LA:CheckAllowed( ply, Plugin, "Unfreeze" )) then
		if (#args>0) then
			local Targets = LA:FindPlayers( args )
			if (#Targets>0) then
				local unfrozen = {}
				for k,v in ipairs( Targets ) do
					if (v:IsFrozen()) then
						v:Freeze(false)
						table.insert( unfrozen, v )
					end
				end
				
				if (#unfrozen>0) then
					LA:Message( LA.Colors.Green, ply, LA.Colors.White, " unfroze ", LA.Colors.Blue, LA:GetNameList( unfrozen ), LA.Colors.White, "." )
				else
					LA:Message( ply, LA.Colors.Red, "None of the targets are frozen." )
				end
			else
				LA:Message( ply, unpack( LA.NoPlayersFound ) )
			end
		else
			if (v:IsFrozen()) then
				ply:Freeze(false)
				LA:Message( LA.Colors.Green, ply, LA.Colors.White, " unfroze themself." )
			else
				LA:Message( ply, LA.Colors.Red, "You are not frozen." )
			end
		end
	else
		LA:Message( ply, unpack( LA.NotAllowed ) )
	end
end

LA:AddPlugin(Plugin)