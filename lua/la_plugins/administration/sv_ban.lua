local Plugin = {}
Plugin.Name = "Ban"
Plugin.Author = "Rusketh"
Plugin.Description = "Ban a player."
Plugin.Commands = { "Ban" }

Plugin.Help = {}
Plugin.Help["Ban"] = "[player] [time] [reason]"

Plugin.Category = "Administration"

Plugin.Privs = { "Ban", "PermBan" }

function Plugin:Ban( Ply, Args )

	if !LA:CheckAllowed( Ply, Plugin, "Ban" ) then
		return LA:Message( Ply, unpack( LA.NotAllowed) )
	elseif !Args[1] then
		return LA:Message( Ply, unpack( LA.NoNameEntered ) )
	end
	
	local Named = table.remove( Args, 1 )
	local Target = LA:FindPlayer( Named, true )
	
	if type( Target ) == "table" then
		Target = Target[1]
	end
	
	if !IsValid( Target ) then
		return LA:Message( Ply, LA.Colors.Red, "No player named ", LA.Colors.Blue, Named, LA.Colors.Red, " found." )
	elseif !LA:PlyVsPly( Ply, Target, true ) then
		return LA:Message( Ply, unpack( LA.TargetImune ) )
	end
	
	local Time = LA:StringToTime( table.remove( Args ) )
	
	if !Time then
		LA:Message( Ply, LA.Colors.Red, "Malformed time given (eg: d3w1h5m2)." )
	elseif Time <= 0 and !LA:CheckAllowed( Ply, Plugin, "PermBan" ) then
		return LA:Message( Ply, unpack( LA.NotAllowed) )
	end
	
	local Reason = table.concat( Args, " " )
	
	if !Reason or Reason == "" then
		Reason = "No reason"
	end
	
	LA.File.SavePlayerVar( Target, "Banned", true )
	LA:BanPlayer( Target, Time, Reason, Ply)
	
	Target:Kick( Reason )
	
	-- Remove all props owned by the player
	if LA.PlayerEnts[tostring(Target)] and #LA.PlayerEnts[tostring(Target)] > 0 then
		for k,v in ipairs( LA.PlayerEnts[tostring(Target)] ) do
			if v and v:IsValid() then
				v:Remove()
			end
		end
	end
		
	LA:Message( LA.Colors.Green, Ply:Nick(), LA.Colors.White, " banned ", LA.Colors.Blue, Target:Nick( ), LA.Colors.White, " for " .. LA:FormatTime( Time ) .. " (" .. Reason .. ")." )
end

LA:AddPlugin( Plugin )