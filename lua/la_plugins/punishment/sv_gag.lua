----------------------------------------------------------------
-- Gag
----------------------------------------------------------------
local Plugin = {}
Plugin.Name = "Gag"
Plugin.Author = "Divran"
Plugin.Description = "Allows you to gag players, making them unable to use the chat."
Plugin.Commands = { "Gag", "Ungag" }

Plugin.Help = {}
Plugin.Help["Gag"] = "[player(s)]"
Plugin.Help["Ungag"] = "[player(s)]"

Plugin.Category = "Punishment"

Plugin.Privs = table.Copy( Plugin.Commands )

function Plugin:Gag( ply, args )
	if (LA:CheckAllowed( ply, Plugin, "Gag" )) then
		if (#args>0) then
			local Targets = LA:FindPlayers( args )
			if (#Targets > 0) then
				local gagged = {}
				for k,v in ipairs( Targets ) do
					v.LA_Gagged = true
					table.insert( gagged, v )
					v:SetNWBool( "LA.Gagged", true )
				end
				if (#gagged>0) then
					LA:Message( LA.Colors.Green, ply, LA.Colors.White, " gagged ", LA.Colors.Blue, LA:GetNameList( gagged ), LA.Colors.White, "." )
				else
					LA:Message( ply, LA.Colors.Red, "All targets are already gagged." )
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

function Plugin:Ungag( ply, args )
	if (LA:CheckAllowed( ply, Plugin, "Ungag" )) then
		if (#args>0) then
			local Targets = LA:FindPlayers( args )
			if (#Targets > 0) then
				local ungagged = {}
				for k,v in ipairs( Targets ) do
					v.LA_Gagged = nil
					table.insert( ungagged, v )
					v:SetNWBool( "LA.Gagged", false )
				end
				if (#ungagged>0) then
					LA:Message( LA.Colors.Green, ply, LA.Colors.White, " ungagged ", LA.Colors.Blue, LA:GetNameList( ungagged ), LA.Colors.White, "." )
				else
					LA:Message( ply, LA.Colors.Red, "No targets are gagged." )
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

function Plugin:PlayerSay( ply )
	if (ply.LA_Gagged) then return "" end
end

LA:AddPlugin( Plugin )