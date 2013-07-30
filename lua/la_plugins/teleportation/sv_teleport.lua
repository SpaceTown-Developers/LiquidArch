----------------------------------------------------------------
-- Teleport
----------------------------------------------------------------
local Plugin = {}
Plugin.Name = "Teleport"
Plugin.Author = "Divran"
Plugin.Description = "Teleport yourself or another player to where you are aiming."
Plugin.Commands = { "Tp", "Teleport" }

Plugin.Help = {}
Plugin.Help["Tp"] = "[player(s)] or [nil]"
Plugin.Help["Teleport"] = "[player(s)] or [nil]"

Plugin.Category = "Teleportation"

Plugin.Privs = { "Teleport" }

function Plugin:GetAimPos( ply, HullTrace )
	if (HullTrace) then
		local tr = {}
		tr.start = ply:GetShootPos()
		tr.endpos = ply:GetShootPos() + ply:GetAimVector() * 99999999
		tr.filter = ply
		return util.TraceEntity( tr, ply ).HitPos
	else
		return ply:GetEyeTrace().HitPos
	end
end

function Plugin:Tele( ply, args, HullTrace )
	if (LA:CheckAllowed( ply, Plugin, "Teleport" )) then
		if (args[1]) then
			local Targets = LA:FindPlayers( args )
			if (#Targets>0) then
				local Pos = self:GetAimPos( ply, HullTrace )
				for k,v in ipairs( Targets ) do
					v:SetPos( Pos + Vector(0,0,1 + (k-1) * 73) )
					v:SetLocalVelocity( Vector(0,0,0) )
				end
				LA:Message( LA.Colors.Green, ply, LA.Colors.White, " teleported ", LA.Colors.Blue, LA:GetNameList(Targets), LA.Colors.White, "." )
			else
				LA:Message( ply, LA.Colors.Red, "No players named '", LA.Colors.Blue, args[1], LA.Colors.Red, "' found." )
			end
		else
			local Pos = self:GetAimPos( ply, HullTrace )
			ply:SetPos( Pos + Vector(0,0,1) )
			ply:SetLocalVelocity( Vector(0,0,0) )
			LA:Message( LA.Colors.Green, ply:Nick(), LA.Colors.White, " teleported." )
		end
	else
		LA:Message( ply, unpack( LA.NotAllowed ) )
	end
end

-- Teleport to where you are aiming with a hull trace
function Plugin:Tp( ply, args )
	self:Tele( ply, args, true )
end

-- Teleport to where you are aiming with a normal trace
function Plugin:Teleport( ply, args ) 	
	self:Tele( ply, args, false )
end

LA:AddPlugin( Plugin )