----------------------------------------------------------------
-- LA Init
----------------------------------------------------------------
_R = debug.getregistry( )
AddCSLuaFile( "includes/modules/von.lua" )
require( "von" )

----------------------------------------------------------------
-- Load Plugins

function LA:Initialize( )
	self.Plugins = { }
	self.PluginInfo = { }
	self:LoadDirectory( "la_plugins" )
	
	for K, V in ipairs( self.Plugins ) do
		table.insert( self.PluginInfo, { Commands = V.Commands or { }, Help = V.Help or { }, Category = V.Category or "Other" } )
	end
	
	Msg( "\n--------------------------------------------------------\n")
	Msg( "-------------         LIQUID ARCH         --------------\n")
	Msg( "-------------         Initialized         --------------\n")
	Msg( "--------------------------------------------------------\n\n")
	
	hook.Call( "LiquidArchInstalled", GAMEMODE )
end

function LA:LoadDirectory( Dir )
	local Entries, _ = file.Find( Dir .. "/*.lua", "LUA" )
	for _, Entry in ipairs( Entries ) do
		if ( string.sub( Entry, -4 ) ) then
			local Prefix = string.sub( Entry, 1, 3 )
				
			if ( SERVER ) then
				
				if ( Prefix == "sv_" ) then 
					LA:PCall( "[LA] E1 Including File", include, Dir .. "/" .. Entry )
				elseif ( Prefix == "sh_" ) then
					LA:PCall( "[LA] E2 Adding CS File", AddCSLuaFile, Dir .. "/" .. Entry )
					LA:PCall( "[LA] E1 Including File", include, Dir .. "/" .. Entry )
				elseif ( Prefix == "cl_" ) then
					LA:PCall( "[LA] E2 Adding CS File", AddCSLuaFile, Dir .. "/" .. Entry )
				end
			elseif ( Prefix == "sh_" or Prefix == "cl_" ) then
				LA:PCall( "[LA] E1 Including File", include, Dir .. "/" .. Entry )
			end
		end
	end

	local _, Entries = file.Find( Dir .. "/*", "LUA" )
	for _, Entry in ipairs( Entries ) do	
		self:LoadDirectory( Dir .. "/" .. Entry )	
	end
end

function LA:AddPlugin( Plugin )	
	if ( !Plugin.Name ) then return ErrorNoHalt( "[LA] Failed to load unanmed plugin " .. self:GetTraceBack( ) ) end
	if ( Plugin.CanDisable == nil ) then Plugin.CanDisable = true end
	if ( Plugin.Enabled == nil ) then Plugin.Enabled = true end
	
	table.insert( self.Plugins, Plugin )
	
	if ( Plugin.FilePlugin ) then table.insert( self.FilePlugins, Plugin.Name) end
end

if ( SERVER ) then
	util.AddNetworkString( "LA_PluginInfo" )
	
	function LA:PlayerInitialSpawn( Ply )
		net.Start( "LA_PluginInfo" )
			net.WriteTable( self.PluginInfo )
		net.Send( Ply )
	end
else
	net.Receive( "LA_PluginInfo", function( Bytes )
		LA.PluginInfo = net.ReadTable( )
	end)
end

----------------------------------------------------------------
-- Get Plugin

function LA:GetPlugin( Name )
	for K, V in ipairs( self.Plugins ) do
		if ( V.Name == Name ) then
			return V
		end
	end
end

----------------------------------------------------------------
-- Server Information Save System

if ( SERVER ) then
	LA.ServerInfo = {}
	LA.PlayerInfo = {}
	LA.FilePlugins = {}
	
	function LA:LiquidArchInstalled( ) //Will AutoHook!
		local Selected = file.Read( "la/file_plugin.txt" ) --Redeffined save plugin
		
		if (!Selected or Selected == "" or !self:GetPlugin( Selected ) ) then
			ErrorNoHalt( "[LA] No prefered file plugin found.\n[LA]Attempting to load default.")
			Selected = self.DeafultFilePlugin --Default save plugin
		end
		
		if ( !Selected or Selected == "" or !self:GetPlugin( Selected ) ) then
			if (self.FilePlugins[1] and self:GetPlugin( self.FilePlugins[1] ) ) then
				Selected = self.FilePlugins[1] --This plugin is a life saver!
				ErrorNoHalt( "[LA] Error finding default file plugin.\n[LA] using '" .. Selected .. "' instead." )
			else --This is seriously bad!!!!!
				ErrorNoHalt( "[LA] THERE IS NO FILE PLUGIN!!\nThis is seriously bad you must install one!" )
				timer.Create( "[LA] NO FILE PLUGIN",1,0,function( )
					LA:Message( LA.Colors.Red, "[LA] WARNING: ", LA.Colors.White, "No 'File Plugin' has been found this has broken LA." )
				end)
				return
			end
		end
		
		LA.FilePlugin = Selected
		
		local Plugin = self:GetFilePlugin( ) //Quicker Access
		Plugin:LoadServerInfo( )
		Plugin:LoadPlayerInfo( )
	end
	
	function LA:GetFilePlugin( )
		return self:GetPlugin( self.FilePlugin )
	end
	
	//File Functions
	LA.File = {}
	
	function LA.File.Save( Id, Var ) LA:GetFilePlugin( ):Save( Id, Var ) end
	function LA.File.Load( Id ) return LA:GetFilePlugin( ):Load( Id ) end
	function LA.File.SavePlayerVar( Ply, Id, Var ) LA:GetFilePlugin( ):SavePlayerVar( Ply, Id, Var ) end
	function LA.File.LoadPlayerVar( Ply, Id ) return LA:GetFilePlugin( ):LoadPlayerVar( Ply, Id ) end
	
	//Banning
	LA.Bans = { }
	
	function LA:BanPlayer( Target, Time, Reason, Ply)
		LA.Bans[ Target:SteamID( ) ] = { Who = Ply, Start = os.time( ), End = os.time( ) + Time, Why = Reason }
		LA:GetFilePlugin( ):SaveServerInfo( )
	end
	
	function LA:Unban( Steam )
		LA.Bans[ Target:SteamID( ) ] = nil
		LA:GetFilePlugin( ):SaveServerInfo( )
	end
	
	function LA:CheckPassword( SteamID, IP, ServerPassword, ClientPassword, PlayerName )
		local Ban = LA.Bans[ SteamID ]
		
		if Ban then
			if Ban.End > os.time( ) then
				self:UnBan( SteamID )
			elseif Ban.End == 0 then
				return false, "You've been perma banned (" .. Ban.Why .. ")"
			else
				return false, "You've still banned for " .. LA:FormatTime( os.time( ) - Ban.End ) .. " (" .. Ban.Why .. ")"
			end
		end
	end
	
end

----------------------------------------------------------------
-- Debug System
function LA:GetTraceBack(Level)
	local Info = debug.getinfo(1 + (Level || 0), "Sln")
	
	if (Info.what == "C") then
		return "C++ Error"
	else
		return  info.short_src .. ":" .. info.currentline
	end
end

----------------------------------------------------------------
-- Players

-- FindPlayer
-- Finds all players with the substring "Name". If "Name" is surrounded by quotation marks, it will find only the players with an exact matching name.
-- If OnlyOne is true, it will return only the first find.
function LA:FindPlayer( Name, OnlyOne )
	if (!Name or Name == "") then return end
	
	-- Everyone?
	if (Name == "*") then return player.GetAll( ) end
	
	-- Admins?
	if (Name == "@") then 
		local ret = {}
		for k,v in ipairs( player.GetAll( ) ) do
			if (v:IsAdmin( )) then
				table.insert( ret, v )
			end
		end
		return ret
	end
	
	-- Non-admins?
	if (Name == "!@") then
		local ret = {}
		for k,v in ipairs( player.GetAll( ) ) do
			if (!v:IsAdmin( )) then
				table.insert( ret, v )
			end
		end
		return ret
	end

	-- Quotation marks
	local exact = false
	if (string.Left(Name,1) == '"' and string.Right(Name,1) == '"') then 
		exact = true 
		Name = Name:sub(2,-2)
	end
	
	local ret = {}
	for k,v in ipairs( player.GetAll( ) ) do
		if ( v:SteamID( ):upper( ) == Name:upper( ) ) then
			if (OnlyOne) then return v end
			table.insert( ret, v )
		elseif (exact) then -- If the name is exact
			if (v:Nick( ) == Name) then -- Only add them if the name is a perfect match
				if (OnlyOne) then return v end
				table.insert( ret, v )
			end
		else
			if ( string.find( v:Nick( ):lower( ),Name:lower( ) ) ) then -- Else add them if we find part of the name
				if (OnlyOne) then return v end
				table.insert( ret, v )
			end
		end
	end
	return ret
end

function LA:FindPlayers( args )
	local ret = {}
	for k,v in ipairs( args ) do
		local pls = self:FindPlayer( v )
		if (#pls>0) then
			for k2,v2 in ipairs( pls ) do
				if (!table.HasValue( ret, v2 )) then
					table.insert( ret, v2 )
				end
			end
		end
	end
	return ret
end

function LA:GetNameList( Players )
	local ret = ""
	if (#Players == #player.GetAll( )) then -- Everyone?
		ret = "everyone"
	elseif (#Players == 1) then -- Just one person?
		ret = Players[1]:Nick( )
	else -- If not, make a list of all players
		for k,v in ipairs( Players ) do
			ret = ret .. v:Nick( )
			if (k == #Players - 1) then
				ret = ret .. ", and "
			elseif (k < #Players - 1) then
				ret = ret .. ", "
			end
		end
	end
	return ret
end

----------------------------------------------------------------
-- Calling Plugins

function LA:PCall(msg,func,...)
	local ok,callback = pcall( func,... )
	if ok == true then 
		return callback
	else 
		if ( LA.Message ) then LA:Message( LA.Colors.Red,"Error: " .. msg .. " - " .. callback ) end
		Msg( "\nLiquid-Arch-> Error: "..msg.." "..callback.."\n" ) 
	end
end



function LA:CallHook( func, ... ) --Used to replace hook.Call when we wana call gamemode only
	local callback = { LA:PCall( "[LA] E3 Calling Hook", func, ... ) }
	if callback[1] != nil and callback[2] then table.remove(callback,1)	end
	if callback[1] != nil then return unpack( callback ) end
end


local OldHook = hook.Call
function hook.Call( hookname, gm, ... )
	local EM = "[LA] E3 Calling Hook"
	if (LA[hookname]) then
		local callback = { LA:PCall( EM , LA[hookname], LA, ... ) }
		if callback[1] != nil and callback[2] then table.remove(callback,1)	end
		if callback[1] != nil then return unpack( callback ) end -- Framework took this hook.
	end
	if (LA.Plugins) then
		for _,v in ipairs( LA.Plugins ) do
			if (v.Enabled == true) then
				if (v[ hookname ]) then
					local callback = { LA:PCall( EM , v[hookname], v, ... ) }
					if callback[1] != nil and callback[2] then table.remove(callback,1)	end
					if callback[1] != nil then return unpack( callback ) end -- Plugin took this hook.
				end
			end
		end
	end
	callback = { OldHook( hookname, gm, ... ) } -- Gmod gets this hook
	if callback[1] != nil and callback[2] then table.remove(callback,1)	end
	if callback[1] != nil then return unpack( callback ) end
end

----------------------------------------------------------------
-- Convar Hacks

if SERVER then
	LA.Convars = { }

	local OldCreateConvar = CreateConVar

	function CreateConVar( Name, ... )
		local Cvar = OldCreateConvar( Name, ... )
		LA.Convars[Name] = Cvar
		return Cvar
	end
end