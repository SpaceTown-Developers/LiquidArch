----------------------------------------------------------------
-- Message
----------------------------------------------------------------
local Plugin = {}
Plugin.Name = "Message"
Plugin.Author = "Divran"
Plugin.Description = "Manages the pretty colored chat messages."
Plugin.CanDisable = false

if ( SERVER ) then
	util.AddNetworkString( "LA_Message" )
end

function Plugin:Run( First, ... )
	if ( SERVER ) then
		if type( First ) == "Player" then
			net.Start( "LA_Message" )
				net.WriteTable( { ... } )
			net.Send( First )
		else
			net.Start( "LA_Message" )
				net.WriteTable( { First, ... } )
			net.Broadcast( )
		end
	else
		chat.AddText( First, ... )
	end
end

if (CLIENT) then
	net.Receive("LA_Message", function( Bytes )
		chat.AddText( LA.Colors.Gold, "[LA] ", unpack( net.ReadTable( ) ) )
	end )
	
	function Plugin:OnPlayerChat( Ply, Txt, TeamChat, IsDead )
		local Msg = { }
		
		-- Dead?
		if (IsDead) then
			table.insert( Msg, Color( 255, 30, 40 ))
			table.insert( Msg, "*DEAD* " )
		end
		
		-- Team Chat
		if (TeamChat) then
			table.insert( Msg, Color( 30, 160, 40 ) )
			table.insert( Msg, "(TEAM) " )
		end
		
		-- Rank
		local rank = Ply:GetNWString( "LA_Rank", false )
		if (rank) then
			table.insert( Msg, LA.Colors.Blue )
			table.insert( Msg, "[" .. rank .. "] " )
		end
			
		-- Console?
		if ( IsValid( Ply ) ) then 
			table.insert( Msg, team.GetColor( Ply:Team( ) ) )
			table.insert( Msg, Ply:Nick() )
		else
			table.insert( Msg, Color( 100, 100, 100) )
			table.insert( Msg, "Console")
		end
		
		-- The message
		table.insert( Msg, LA.Colors.White )
		table.insert( Msg, ": " .. Txt )
		
		chat.AddText( unpack( Msg ) )
		
		return true
	end
end


----------------------------------------------------------------
-- Message Shortcut (Shorter than "LA:GetPlugin("Message"):Run( args )")

LA.Colors = { }
LA.Colors.Red = Color( 136,0,21,255 )
LA.Colors.Blue = Color( 63,72,204,255 )
LA.Colors.Green = Color( 27,137,60,255 )
LA.Colors.White = Color( 255,255,255,255 )
LA.Colors.Gold = Color( 187,173,0,255 )

LA.NotAllowed = { LA.Colors.Red, "You are not allowed to do that." }
LA.NoNameEntered = { LA.Colors.Red, "You must enter a target player name." }
LA.NoPlayersFound = { LA.Colors.Red, "No players found." }
LA.TargetImune = { LA.Colors.Red, "Selected target over powers you." }

function LA:Message( ... )
	if (SERVER) then
		local plug = Plugin
		if (plug) then
			self:CallHook( plug.Run, plug, ... )
		else
			for K, V in ipairs( player.GetAll( ) ) do V:ChatPrint( "[LA] - ERROR. MESSAGE PLUGIN DOES NOT EXIST." ) end
		end
	else
		chat.AddText( ... )
	end
end

LA:AddPlugin( Plugin )