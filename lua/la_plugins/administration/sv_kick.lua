----------------------------------------------------------------
-- Kick
----------------------------------------------------------------
local Plugin = {}
Plugin.Name = "Kick"
Plugin.Author = "Divran"
Plugin.Description = "Kick a player."
Plugin.Commands = { "Kick" }

Plugin.Help = {}
Plugin.Help["Kick"] = "[player] [reason]"

Plugin.Category = "Administration"

Plugin.Privs = table.Copy( Plugin.Commands )

function Plugin:Kick( Ply, Args )

	if !LA:CheckAllowed( Ply, Plugin, "Kick" ) then
		return LA:Message( Ply, unpack( LA.NotAllowed) )
	end
	
	local Named = table.remove( Args, 1 )
	local Target = LA:FindPlayer( Named )
	
	if type( Target ) == "table" then
		Target = Target[1]
	end
	
	if !IsValid( Target ) then
		return LA:Message( Ply, LA.Colors.Red, "No player named ", LA.Colors.Blue, Named, LA.Colors.Red, " found." )
	elseif !LA:PlyVsPly( Ply, Target, true ) then
		return LA:Message( Ply, unpack( LA.TargetImune ) )
	end
	
	local Reason = table.concat( Args, " " )
	
	if !Reason or Reason == "" then
		Reason = "No reason"
	end
	
	LA:Message( LA.Colors.Green, Ply:Nick(), LA.Colors.White, " kicked ", LA.Colors.Blue, Target:Nick(), LA.Colors.White, " (" .. Reason .. ")." )

	Target:Kick( Reason )
	
	-- Remove all props owned by the player
	if LA.PlayerEnts[tostring(Target)] and #LA.PlayerEnts[tostring(Target)] > 0 then
		for k,v in ipairs( LA.PlayerEnts[tostring(Target)] ) do
			if v and v:IsValid() then
				v:Remove()
			end
		end
	end
		
	
end


LA:AddPlugin( Plugin )