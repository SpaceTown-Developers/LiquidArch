----------------------------------------------------------------
-- Reload
----------------------------------------------------------------
local Plugin = {}
Plugin.Name = "Reload"
Plugin.Author = "Divran"
Plugin.Description = "Reloads the map"
Plugin.Commands = { "Reload" }

Plugin.Category = "Administration"

Plugin.Privs = table.Copy( Plugin.Commands )

function Plugin:Reload( ply, args )
	if (LA:CheckAllowed( ply, Plugin, "Reload" )) then
		LA:Message( LA.Colors.Green, ply:Nick(), LA.Colors.White, " has reloaded the map." )
		timer.Simple( 1, function( ) RunConsoleCommand( "changelevel", game.GetMap( ) ) end )
	else
		LA:Message( ply, unpack( LA.NotAllowed ) )
	end
end

LA:AddPlugin( Plugin )