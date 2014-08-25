----------------------------------------------------------------
-- File Saving
----------------------------------------------------------------
local Plugin = {}
Plugin.Name = "Basic File Saving"
Plugin.Author = "Divran"
Plugin.Description = "Saves information localy via save files"
Plugin.CanDisable = false
Plugin.FilePlugin = true

require("von")
file.CreateDir( "la" )

--------------
-- Server Info

function Plugin:SaveServerInfo( )
	if ( LA.ServerInfo ) then
		file.Write( "la/serverinfo.txt", von.serialize( LA.ServerInfo ) )
	end
	
	if ( LA.Bans ) then
		file.Write( "la/bans.txt", von.serialize( LA.Bans ) )
	end
end

function Plugin:LoadServerInfo( )
	if !file.Exists( "la/serverinfo.txt", "DATA" ) then
		return file.Write( "la/serverinfo.txt" )
	end
	
	local Str = file.Read( "la/serverinfo.txt" )
	
	if (Str and Str != "") then
		LA.ServerInfo = von.deserialize( Str )
	end
	
	if !file.Exists( "la/bans.txt", "DATA" ) then
		return file.Write( "la/bans.txt" )
	end
	
	local Str = file.Read( "la/bans.txt" )
	
	if (Str and Str != "") then
		LA.Bans = von.deserialize( Str )
	end
end

function Plugin:Save( Id, Var )
	LA.ServerInfo[Id] = Var
	self:SaveServerInfo( )
end

function Plugin:Load( Id )
	return LA.ServerInfo[Id]
end


--------------
-- Player Info

function Plugin:SavePlayerInfo( )
	if ( LA.PlayerInfo ) then
		file.Write( "la/playerinfo.txt", von.serialize( LA.PlayerInfo ) )
	end
end

function Plugin:LoadPlayerInfo( )
	if (!file.Exists( "la/playerinfo.txt", "DATA" )) then file.Write( "la/playerinfo.txt" ) return end
	local Str = file.Read( "la/playerinfo.txt", "DATA")
	if ( Str and Str != "" ) then
		LA.PlayerInfo = von.deserialize( Str )
	end
end

function Plugin:SavePlayerVar( Ply, Id, Var )
	if (!LA.PlayerInfo[Ply:UniqueID( )]) then LA.PlayerInfo[Ply:UniqueID( )] = {} end
	LA.PlayerInfo[Ply:UniqueID( )][Id] = Var
	self:SavePlayerInfo( )
end

function Plugin:LoadPlayerVar( Ply, Id )
	if ( !LA.PlayerInfo[Ply:UniqueID( )] ) then return false end
	return LA.PlayerInfo[Ply:UniqueID( )][Id]
end

LA:AddPlugin( Plugin )

LA.DeafultFilePlugin = "Basic File Saving"