----------------------------------------------------------------
-- Timed Rank Manager
----------------------------------------------------------------
local Plugin = {}
Plugin.Name = "Ranks"
Plugin.Author = "Rusketh"
Plugin.Description = "Time managed ranks."
Plugin.Commands = { "Temp" }
Plugin.CanDisable = false

Plugin.Help = {}
Plugin.Help["Temp"] = "[player(s)] [rank] [d<days>h<hours>m<minutes>]"

----------------------------------------------------------------
-- Chat Command
----------------------------------------------------------------
function Plugin:Temp( Ply, Args )
	if ( LA:CheckAllowed( Ply, Plugin, "Rank" ) ) then
		if ( #Args > 0 ) then
			
			local Time = LA:StringToTime( table.remove( Args ) )
			
			if ( Time ) then
				local Rank = table.remove( Args )
				local RealRank = LA:GetPlugin( "Ranks" ):GetRank( Rank )
			
				if ( RealRank ) then
					
					if ( #Args > 0 ) then
						local Targets = LA:FindPlayers( Args )
						
						if ( #Targets > 0 ) then
							
							for K, V in ipairs( Targets ) do
								self:SetTemporaryRank( V, RealRank.Name, Time )
							end
							
							LA:Message( LA.Colors.Green, Ply, LA.Colors.White, " set the rank of ", LA.Colors.Blue, LA:GetNameList( Targets ), LA.Colors.White, " to ", LA.Colors.Blue, realrank.Name, LA.Colors.White, " for ", LA.Colors.Blue, LA:FormatTime( Time ), LA.Colors.White, "." )
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
			LA:Message( Ply, LA.Colors.Red, "Malformed time given (eg: d3w1h5m2)." )
		end
	else
		LA:Message( Ply, unpack( LA.NotAllowed ) )
	end
end

----------------------------------------------------------------
-- Temporary Ranks
----------------------------------------------------------------
function Plugin:SetTemporaryRank( Ply, NamedRank, Time )
	local Plugin = LA:GetPlugin( "Ranks" )
	local Rank = Plugin:GetRank( NamedRank, false )
	
	if ( Rank ) then
		LA.File.SavePlayerVar( Ply, "TempRank", true )
		LA.File.SavePlayerVar( Ply, "RealRank", Ply.LA_Rank )
		LA.File.SavePlayerVar( Ply, "RankTime", os.time( ) + Time )
		
		Plugin:SetRank( Ply, NamedRank, false )
		
		return true
	end
	
	return false
end

----------------------------------------------------------------
-- TimeKeeper
----------------------------------------------------------------
function Plugin:EverySecond( )
	local Plugin = LA:GetPlugin( "Ranks" )
	
	for _, Ply in pairs( player.GetAll( ) ) do
		
		if ( LA.File.LoadPlayerVar( Ply, "TempRank" ) ) then
			
			if ( LA.File.LoadPlayerVar( Ply, "RankTime" ) > os.time( ) ) then
				local RealRank = LA.File.LoadPlayerVar( Ply, "RealRank" )
				
				if ( Plugin:SetRank( Ply, RealRank, true ) ) then
					LA:Message( LA.Colors.Blue, Ply, LA.Colors.White, " was restored to ", LA.Colors.Blue, RealRank, LA.Colors.White, " (end of temporary ranking)." )
				else
					LA:Message( Ply, LA.Colors.Red, "Failed to end temporary rank, ", LA.Colors.Blue, RealRank, LA.Colors.Red, " not found." )
				end
				
				LA.File.SavePlayerVar( Ply, "TempRank", nil )
				LA.File.SavePlayerVar( Ply, "RealRank", nil )
				LA.File.SavePlayerVar( Ply, "RankTime", nil )
			end
			
		else
			local Rank = Plugin:GetRank( Ply.LA_Rank, true )
			
			if ( Rank and Rank.Promote ) then
				
				local Time = LA:TableToTime( Rank.Promote.Time )
				
				if ( LA:TableToTime( Time or { } ) > LA.File.LoadPlayerVar( Ply, "PlayTime" ) ) then
					
					if ( Plugin:SetRank( Ply, Rank.Promote.Rank, true ) ) then
						LA:Message( LA.Colors.Blue, Ply, LA.Colors.White, " was promoted to ", LA.Colors.Blue, Rank.Promote.Rank, LA.Colors.White, " after ", LA.Colors.Blue, LA:FormatTime( Time ), LA.Colors.White, " of play time." )
					end
				end
				
			end
		end
	end
end