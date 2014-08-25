----------------------------------------------------------------
-- Nolimits
----------------------------------------------------------------
local Plugin = {}
Plugin.Name = "Nolimits"
Plugin.Author = "Divran"
Plugin.Description = "Enables players to spawn an infinite number of anything."
Plugin.Commands = { "Nolimits", "Limits" }

Plugin.Help = {}
Plugin.Help["Nolimits"] = "[player(s)]"
Plugin.Help["Limits"] = "[player(s)]"

Plugin.Category = "Administration"

Plugin.Privs = table.Copy( Plugin.Commands )

function Plugin:Nolimits( ply, args )
	if (LA:CheckAllowed( ply, Plugin, "Nolimits" )) then
		local Targets = LA:FindPlayers( args )
		if (#Targets>0) then
			local tbl = {}
			for k,v in ipairs( Targets ) do
				if (!v.LA_Nolimits) then
					v.LA_Nolimits = true
					table.insert( tbl, v )
					v:SetNWBool( "LA.NoLimits", true )
				end
			end
			if (#tbl>0) then
				LA:Message( LA.Colors.Green, ply, LA.Colors.White, " disabled limits for ", LA.Colors.Blue, LA:GetNameList( tbl ), LA.Colors.White, "." )
			else
				LA:Message( ply, LA.Colors.Red, "All targets already have limits disabled." )
			end			
		else
			LA:Message( ply, unpack( LA.NoPlayersFound ) )
		end
	else
		LA:Message( ply, unpack( LA.NotAllowed ) )
	end
end

function Plugin:Limits( ply, args )
	if (LA:CheckAllowed( ply, Plugin, "Limits" )) then
		local Targets = LA:FindPlayers( args )
		if (#Targets>0) then
			local tbl = { }
			for k,v in ipairs( Targets ) do
				if (v.LA_Nolimits) then
					v.LA_Nolimits = nil
					table.insert( tbl, v )
					v:SetNWBool( "LA.NoLimits", false )
				end
			end
			if (#tbl>0) then
				LA:Message( LA.Colors.Green, ply, LA.Colors.White, " enabled limits for ", LA.Colors.Blue, LA:GetNameList( tbl ), LA.Colors.White, "." )
			else
				LA:Message( ply, LA.Colors.Red, "None of the targets have limits disabled." )
			end			
		else
			LA:Message( ply, unpack( LA.NoPlayersFound ) )
		end
	else
		LA:Message( ply, unpack( LA.NotAllowed ) )
	end
end

function Plugin.CheckLimit( Ply, Str )
	
	if ( Ply.LA_Nolimits ) then return true end
	
	-- Below is copied from sandbox
	if ( game.SinglePlayer( ) ) then return true end

	local C = GetConVarNumber( "sbox_max" .. Str, 0 )
	
	if ( Ply:GetCount( Str ) < C or C < 0 ) then return true end 
	
	Ply:LimitHit( Str ) 
	
	return false
end

function Plugin:Initialize( )
	function GAMEMODE:PlayerSpawnProp( ply, mdl ) return Plugin.CheckLimit( ply, "props" ) end
	function GAMEMODE:PlayerSpawnVehicle( ply, mdl ) return Plugin.CheckLimit( ply, "vehicles" ) end
	function GAMEMODE:PlayerSpawnNPC( ply, mdl ) return Plugin.CheckLimit( ply, "npcs" ) end
	function GAMEMODE:PlayerSpawnEffect( ply, mdl ) return Plugin.CheckLimit( ply, "effects" ) end
	function GAMEMODE:PlayerSpawnRagdoll( ply, mdl ) return Plugin.CheckLimit( ply, "ragdolls" ) end 
	
	_R.Player.CheckLimit = Plugin.CheckLimit
end

LA:AddPlugin( Plugin )