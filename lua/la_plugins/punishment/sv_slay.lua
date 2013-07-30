----------------------------------------------------------------
-- Slay
----------------------------------------------------------------
local Plugin = {}
Plugin.Name = "Slay"
Plugin.Author = "Divran"
Plugin.Description = "Make people drop dead."
Plugin.Commands = { "Slay" }

Plugin.Help = {}
Plugin.Help["Slay"] = "[player(s)]"

Plugin.Category = "Punishment"

Plugin.Privs = table.Copy( Plugin.Commands )

function Plugin:Slay(ply,args)
	if (LA:CheckAllowed( ply, Plugin, "Slay" )) then
		if (#args>0) then
			local Targets = LA:FindPlayers( args )
			if (#Targets>0) then
				for k,v in ipairs( Targets ) do
					v:Kill()
				end
				LA:Message( LA.Colors.Green, ply, LA.Colors.White, " slayed ", LA.Colors.Blue, LA:GetNameList( Targets ), LA.Colors.White, "." )
			else
				LA:Message( ply, unpack( LA.NoPlayersFound ) )
			end
		else
			ply:Kill()
			LA:Message( LA.Colors.Green, ply, LA.Colors.White, " slayed themself." )
		end
	else
		LA:Message( ply, unpack( LA.NotAllowed ) )
	end
end

LA:AddPlugin(Plugin)