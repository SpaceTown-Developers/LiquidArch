----------------------------------------------------------------
-- Player Info
----------------------------------------------------------------
local Plugin = {}
Plugin.Name = "BasicPlayerInfo"
Plugin.Author = "Divran"
Plugin.Description = "Saves and shows information about players such as their last join date and name."
Plugin.CanDisable = false

function Plugin:PlayerInitialSpawn( Ply )
	if ( LA.PlayerInfo[Ply:UniqueID()] ) then
		local oldname = LA.File.LoadPlayerVar( Ply, "Name" ) or "unknown"
		local oldtime = LA.File.LoadPlayerVar( Ply, "JoinTime" ) or 0
		local rank = LA.File.LoadPlayerVar( Ply, "Rank" ) or "unknown"
		
		LA:Message( LA.Colors.Green, Ply:Name( ), LA.Colors.White, " last joined at ", LA.Colors.Red, LA:FormatTime( os.time( ) - oldtime ), LA.Colors.White, " as ", LA.Colors.Blue, oldname, LA.Colors.White, "." )
		-- os.date( "%c", oldtime )
		
		LA.File.SavePlayerVar( Ply, "Name", Ply:Nick() )
		LA.File.SavePlayerVar( Ply, "JoinTime", os.time() )
		LA.File.SavePlayerVar( Ply, "SteamID", Ply:SteamID() )
	else
		LA:Message( LA.Colors.Green, Ply:Name( ), LA.Colors.White, " has joined for the first time. ")
		
		LA.File.SavePlayerVar( Ply, "PlayTime", 0 )
		LA.File.SavePlayerVar( Ply, "Name", Ply:Nick() )
		LA.File.SavePlayerVar( Ply, "JoinTime", os.time() )
		LA.File.SavePlayerVar( Ply, "SteamID", Ply:SteamID() )
	end
end

function Plugin:EverySecond( )
	for _, Ply in pairs( player.GetAll( ) ) do
		LA.File.SavePlayerVar( Ply, "PlayTime", (LA.File.LoadPlayerVar( Ply, "PlayTime" ) or 0) + 1 )
	end
end

LA:AddPlugin( Plugin )