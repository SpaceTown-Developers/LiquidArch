----------------------------------------------------------------
-- Ranks
----------------------------------------------------------------
local Plugin = {}
Plugin.Name = "Ranks"
Plugin.Author = "Divran"
Plugin.Description = "Manages ranks."
Plugin.Commands = { "Rank" }
Plugin.CanDisable = false

LA.Ranks = {}

Plugin.Help = {}
Plugin.Help["Rank"] = "[player(s)] [rank]"

Plugin.Privs = table.Copy( Plugin.Commands )

---------------------
-- Chat command
if ( SERVER ) then
	function Plugin:Rank( Ply, Args )
		if ( LA:CheckAllowed( Ply, Plugin, "Rank" ) ) then
			if ( #Args > 0 ) then
				local Rank = Args[#Args]
				local RealRank = self:GetRank( Rank )
				if ( RealRank ) then
					table.remove( Args )
					if ( #Args > 0 ) then
						local Targets = LA:FindPlayers( Args )
						if (#Targets>0) then
							for k,v in ipairs( Targets ) do
								self:SetRank( v, RealRank.Name )
							end
							LA:Message( LA.Colors.Green, Ply, LA.Colors.White, " set the rank of ", LA.Colors.Blue, LA:GetNameList( Targets ), LA.Colors.White, " to ", LA.Colors.Blue, RealRank.Name, LA.Colors.White, "." )
						else
							LA:Message( Ply, unpack( LA.NoPlayersFound ) )
						end
					else
						LA:Message( Ply, unpack( LA.NoNameEntered ) )
					end
				else
					LA:Message( Ply, LA.Colors.Red, "Rank named ", LA.Colors.Blue, Rank, LA.Colors.Red, " not found." )
				end			
			else
				LA:Message( Ply, unpack( LA.NoNameEntered ) )
			end
		else
			LA:Message( Ply, unpack( LA.NotAllowed ) )
		end
	end
end

----------------------
-- Set rank on spawn

if ( SERVER ) then
	util.AddNetworkString( "LA_RanksTable" )

	function Plugin:PlayerInitialSpawn( Ply ) -- Check rank
		if ( LA.Ranks ) then
			net.Start( "LA_RanksTable" )
				net.WriteTable( LA.Ranks )
			net.Send( Ply )
		end
		
		local Rank = LA.File.LoadPlayerVar( Ply, "Rank" )
		
		if ( Rank ) then
			LA:Message( Ply, LA.Colors.White, "You are a(n) ",LA.Colors.Blue, Rank, LA.Colors.White, " on this server." )
		else
			if ( game.SinglePlayer( ) or Ply:IsListenServerHost( ) ) then
				Rank = "Owner"
			elseif ( Ply:IsSuperAdmin() ) then
				Rank = "SuperAdmin"
			elseif ( Ply:IsAdmin() ) then
				Rank = "Admin"
			end
		end
		
		timer.Simple( 0.5, function( ) self:SetRank( Ply, Rank, true ) end )
		
	end

elseif (CLIENT) then
	 net.Receive( "LA_RanksTable", function( Bytes )
		LA.Ranks = net.ReadTable( )
		hook.Call( "LA_RanksLoaded", { } )
	end)
end

function Plugin:SetRank( Ply, NamedRank, Exact )
	local Rank = self:GetRank( NamedRank, Exact or false )
	
	if ( Rank ) then
		Ply.LA_Rank = Rank.Name
		Ply:SetNWString( "LA_Rank", Rank.Name )
		LA.File.SavePlayerVar( Ply, "Rank", Rank.Name )
		
		local Power = Rank.Power
		
		if ( Power < 50 ) then
			Ply:SetUserGroup("guest")
		elseif ( Power >= 50 and Power < 70) then
			Ply:SetUserGroup("admin")
		elseif ( Power >= 70 ) then
			Ply:SetUserGroup("superadmin")
		end
		
		hook.Call("LA_RankChanged", { }, Ply, Rank)
		
		return true
	end
	
	return false
end

-------------------------
-- Load ranks on server load

function Plugin:LoadRanks() -- Load ranks
	local tempranks = LA.File.Load( "Ranks" )
	
	if (!tempranks) then
		local Plug = LA:GetPlugin( "DefaultRanks" )
		
		if ( Plug ) then
			LA.Ranks = table.Copy( Plug.Ranks )
			hook.Call( "LA_RanksLoaded", { } )
		else
			LA:Message( LA.Colors.Red, "ERROR! NO RANKS LOADED." )
		end
	else
		LA.Ranks = tempranks
		
		hook.Call( "LA_RanksLoaded", { } )
	end
end

function Plugin:Initialize()
	if ( SERVER ) then
		self:LoadRanks()
	end
end

-- Save ranks

function Plugin:SaveRanks()
	LA.File.Save( "Ranks", LA.Ranks )
end

-----------------------------
-- Create new rank

if (SERVER) then
	function Plugin:CheckNameAvailable( Name, Nr, Ret ) -- If a rank with that name already exists, add "(nr)" to the end of it.
		local OldName = Name
		Name = Name .. "(" .. Nr .. ")"
		
		for K, V in pairs( LA.Ranks ) do
			if ( V.Name and V.Name == Name ) then
				Nr = Nr + 1
				return self:CheckNameAvailable( Name, Nr, true )
			end
		end
		
		if ( Ret == false ) then
			return OldName
		else
			return Name
		end
	end
	
	util.AddNetworkString( "LA_NewRank" )
	
	function Plugin:NewRank( Name, Power, Clr, Priv )
		local Rank = {}
		
		Name = self:CheckNameAvailable( Name, 1 )
		Rank.Name = Name or "Unknown"
		Rank.Power = math.Clamp(Power,0,100) or 50
		Rank.Color = Clr or Color(255,255,255,255)
		Rank.Priv = Priv or self:GetPrivs( "Guest" )
		
		table.Add( LA.Ranks, Rank )
		
		hook.Call( "LA_NewRank", { }, Rank )
		
		net.Start( "LA_NewRank" )
			net.WriteTable( Rank )
		net.Broadcast( )
		
		self:SaveRanks( )
	end 
else
	net.Receive( "LA_NewRank", function( Bytes )
		local Rank = net.ReadTable( )
		table.Add( LA.Ranks, Rank )
		hook.Call("LA_NewRank", { }, Rank )
	end)
end

----------------------------
-- GetRank
function Plugin:GetRank( Name, Exact )
	if ( type( Name ) == "Player" ) then 
		Name = Name:GetNWString( "LA_Rank" )
		Exact = false
	end
	
	if ( Exact ) then
		return LA.Ranks[Name]
	else
		for K, V in pairs( LA.Ranks ) do
			if ( V.Name ) then
				if ( string.find( string.lower( V.Name ), string.lower( Name ) ) ) then
					return V
				end
			end
		end
	end
end

----------------------------
-- Allowance check

function Plugin:GetPrivs( Name )
	if ( !LA.Ranks[Name] ) then return { } end
	return LA.Ranks[Name].Priv or { }
end

function Plugin:HasPriv( Ply, Priv )
	if ( Ply:IsConsole( ) ) then
		return true
	elseif ( Ply:GetNWString("LA_Rank",false) ) then
		local Privs = self:GetPrivs( Ply:GetNWString( "LA_Rank" ) )
		
		if ( Privs ) then
			return table.HasValue( Privs, Priv )
		else
			return false
		end
	end
	
	return false
end

function Plugin:PlyVsPly( Ply, Target, Greater )
	if Ply:IsConsole( ) then
		return true
	elseif Greater then
		return LA.Ranks[Ply.LA_Rank].Power > LA.Ranks[Target.LA_Rank].Power
	else
		return LA.Ranks[Ply.LA_Rank].Power >= LA.Ranks[Target.LA_Rank].Power
	end
end

-- Shortcuts
function LA:HasPriv( Ply, Priv ) return Plugin:HasPriv( Ply, Priv ) end
function LA:GetPrivs( Name ) return Plugin:GetPrivs( Name ) end
function LA:SetRank( Ply, Name ) return Plugin:SetRank( Ply, Name ) end
function LA:NewRank( Name, Power, Clr, Priv ) Plugin:NewRank( Name, Power, Clr, Priv ) end
function LA:GetRank( Name, Exact ) return Plugin:GetRank( Name, Exact ) end
function LA:PlyVsPly( Ply, Target, Greater ) return Plugin:PlyVsPly( Ply, Target, Greater ) end

/*-------------------------------------------------------------------------------------------------------------------------
	Console
-------------------------------------------------------------------------------------------------------------------------*/
local _R = debug.getregistry()
function _R.Entity:Name( ) if ( !self:IsValid( ) ) then return "Console" end end
function _R.Entity:Nick( ) if ( !self:IsValid( ) ) then return "Console" end end
function _R.Entity:IsAdmin( ) if ( !self:IsValid( ) ) then return true end end
function _R.Entity:IsSuperAdmin( ) if ( !self:IsValid( ) ) then return true end end
function _R.Entity:UniqueID( ) if ( !self:IsValid( ) ) then return 0 end end
function _R.Entity:IsConsole( ) if ( !self:IsValid( ) ) then return true end end
function _R.Player:IsConsole( ) return false end

-- Override default CheckAllowed
function LA:CheckAllowed( Ply, Plugin, Priv )
	return LA:HasPriv( Ply, Priv )
end

LA:AddPlugin( Plugin )