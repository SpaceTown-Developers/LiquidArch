----------------------------------------------------------------
-- Noclip
----------------------------------------------------------------
local Plugin = {}
Plugin.Name = "Noclip"
Plugin.Author = "Divran"
Plugin.Description = "Toggle serverwide noclip, or send specific players into/out of noclip"
Plugin.Commands = { "Noclip", "Unnoclip" }
Plugin.ServerWideNoclip = true

Plugin.Help = {}
Plugin.Help["Noclip"] = "[player(s)] or [nil (for serverwide noclip)]"
Plugin.Help["Unnoclip"] = "[player(s)] or [nil (for serverwide noclip)]"

Plugin.Category = "Administration"

Plugin.Privs = table.Copy( Plugin.Commands )

LA:PCall("[E5] Error changing a ConVar", RunConsoleCommand,"sbox_noclip",1) --Otherwise plugin dies

function Plugin:PlayerNoClip( ply )
	if (self.ServerWideNoclip == false) then return false end
	return ply.LA_CanNoclip
end

function Plugin:NoclipPlayers( players, bool )
	for k,v in pairs( players ) do
		if (bool) then
			v.LA_CanNoclip = false
		else
			v.LA_CanNoclip = nil
		end
		if (v:GetMoveType() == MOVETYPE_NOCLIP) then
			v:SetMoveType(MOVETYPE_WALK)
		end
	end
end

function Plugin:Noclip( ply, args )
	if (LA:CheckAllowed( ply, Plugin, "Noclip" )) then
		if (#args > 0) then
			local Targets = LA:FindPlayers( args )
			if (#Targets>0) then
				self:NoclipPlayers( Targets )
				LA:Message( LA.Colors.Green, ply, LA.Colors.White, " gave ability noclip to ", LA.Colors.Blue, LA:GetNameList( Targets ), LA.Colors.White, "." )
			else
				LA:Message( ply, unpack( LA.NoPlayersFound ) )
			end
		else
			self.ServerWideNoclip = true
			LA:Message( LA.Colors.Green, ply, LA.Colors.White, " has ", LA.Colors.Blue, "enabled", LA.Colors.White, "serverwide noclip." )
		end
	else
		LA:Message( ply, unpack( LA.NotAllowed ) )
	end
end

function Plugin:Unnoclip( ply, args )
	if (LA:CheckAllowed( ply, Plugin, "Unnoclip" )) then
		if (#args > 0) then
			local Targets = LA:FindPlayers( args )
			if (#Targets>0) then
				self:NoclipPlayers( Targets, true )
				LA:Message( LA.Colors.Green, ply, LA.Colors.White, " revoked ability noclip from ", LA.Colors.Blue, LA:GetNameList( Targets ), LA.Colors.White, "." )
			else
				LA:Message( ply, unpack( LA.NoPlayersFound ) )
			end
		else
			self.ServerWideNoclip = false
			LA:Message( LA.Colors.Green, ply, LA.Colors.White, " has ", LA.Colors.Blue, "disabled", LA.Colors.White, "serverwide noclip." )
		end
	else
		LA:Message( ply, unpack( LA.NotAllowed ) )
	end
end

LA:AddPlugin( Plugin )