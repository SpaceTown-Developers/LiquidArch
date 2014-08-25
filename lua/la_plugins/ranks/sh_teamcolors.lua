----------------------------------------------------------------
-- Teamcolors
----------------------------------------------------------------
local Plugin = {}
Plugin.Name = "Teamcolors"
Plugin.Author = "Divran"
Plugin.Description = "Makes ranks/teams have colors."
Plugin.CanDisable = false

Plugin.RankIndexes = {}

function Plugin:LA_RanksLoaded()
	-- Create temp table
	local temp = {}
	for k,v in pairs( LA.Ranks ) do table.insert( temp, {Clr = v.Color or Color(255,255,255,255), Pow = v.Power or 50, Name = v.Name} )	end
	-- Sort table by power
	table.sort( temp, function( a, b ) return (a.Pow<b.Pow)	end )
	
	-- Set up teams and create RankIndexes table
	for k,v in ipairs( temp ) do
		self.RankIndexes[v.Name] = k
		team.SetUp( k, v.Name, v.Clr )
	end
	
	-- If it's a listen server or single player, the host may have spawned already:
	if (SERVER) then
		if (#player.GetAll()>0) then
			for k,v in ipairs( player.GetAll() ) do
				v:SetTeam( self.RankIndexes[ v.LA_Rank or "" ] or 1 )
			end
		end
	end
end

if (CLIENT) then
	function Plugin:LA_NewRank( Rank )
		team.SetUp( table.Count(LA.Ranks) + 1, Rank.Name, Rank.Color )
	end
end

function Plugin:PlayerSpawn( ply ) -- I tried PlayerInitialSpawn and it didn't work.
	ply:SetTeam( self.RankIndexes[ ply.LA_Rank or "" ] or 1 )
end

function Plugin:LA_RankChanged( ply, Rank )
	ply:SetTeam( self.RankIndexes[Rank or ""] or 1 )
end
LA:AddPlugin( Plugin )