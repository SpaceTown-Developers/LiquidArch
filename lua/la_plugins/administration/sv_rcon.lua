----------------------------------------------------------------
-- Rcon
----------------------------------------------------------------
local Plugin = {}
Plugin.Name = "Rcon"
Plugin.Author = "Divran"
Plugin.Description = "Execute console commands on the server."
Plugin.Commands = { "Rcon" }

Plugin.Help = {}
Plugin.Help["Rcon"] = "[command]"

Plugin.Category = "Administration"

Plugin.Privs = table.Copy( Plugin.Commands )

function Plugin:Rcon( ply, args )
	if (LA:CheckAllowed( ply, Plugin, "Rcon" )) then
		if (#args>0) then
			RunConsoleCommand( unpack( args ) )
			LA:Message( LA.Colors.Green, ply, LA.Colors.White, " ran '", LA.Colors.Blue, table.concat( args, " "), LA.Colors.White, "' on the server." )
		else
			LA:Message( ply, LA.Colors.Red, "No command entered." )
		end
	else
		LA:Message( ply, unpack( LA.NotAllowed ) )
	end
end

LA:AddPlugin( Plugin )