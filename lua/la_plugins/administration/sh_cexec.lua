----------------------------------------------------------------
-- Cexec
----------------------------------------------------------------
local Plugin = {}
Plugin.Name = "Cexec"
Plugin.Author = "Divran"
Plugin.Description = "Execute console commands on a player."
Plugin.Commands = { "Cexec" }

Plugin.Help = {}
Plugin.Help["Cexec"] = "[player] [command]"

Plugin.Category = "Administration"

Plugin.Privs = table.Copy( Plugin.Commands )

if (SERVER) then
	function Plugin:Cexec( ply, args )
		if (LA:CheckAllowed( ply, Plugin, "Cexec" )) then
			if (#args>0) then
				local Target = LA:FindPlayer( args[1], true )
				if (Target) then
					table.remove( args, 1 )
					if (#args) then
						local str = table.concat( args, " " )
						--Target:ConCommand( str )
						umsg.Start( "LA_Cexec", Target )
							umsg.String( str )
						umsg.End()
						LA:Message( LA.Colors.Green, ply, LA.Colors.White, " executed '", LA.Colors.Blue, str, LA.Colors.White, "' on ", LA.Colors.Blue, Target:Nick(), LA.Colors.White, "." )
					else
						LA:Message( ply, LA.Colors.Red, "No command entered." )
					end
				else
					LA:Message( ply, unpack( LA.NoPlayersFound ) )
				end
			else
				LA:Message( ply, unpack( LA.NoNameEntered ) )
			end
		else
			LA:Message( ply, unpack( LA.NotAllowed ) )
		end
	end
else
	usermessage.Hook( "LA_Cexec", function( um )
		local str = um:ReadString()
		if (str and str != "") then 	
			local args = {str}
			if (string.find( str, " ")) then
				args = string.Explode( str, " ") -- since it's client side, who cares if it's a bit slow :)
			end
			RunConsoleCommand( unpack( args ) )
		end
	end)
end

LA:AddPlugin( Plugin )