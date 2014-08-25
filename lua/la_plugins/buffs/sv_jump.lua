----------------------------------------------------------------
-- Jump
----------------------------------------------------------------
local Plugin = {}
Plugin.Name = "Jump"
Plugin.Author = "Divran"
Plugin.Description = "Change the jump strength of a player."
Plugin.Commands = { "Jump", "Resetjump" }

Plugin.Help = {}
Plugin.Help["Jump"] = "[player(s)] [power] or [power]"
Plugin.Help["Resetjump"] = "[player(s)] or [nil]"

Plugin.Category = "Buffs"

Plugin.Privs = { "Jump" }

function Plugin:Jump( ply, args )
	if (LA:CheckAllowed( ply, Plugin, "Jump" )) then
		if (#args>0) then
			local jump = math.Clamp( tonumber(args[#args]), 1, 1000000 )
			table.remove( args, #args )
			if (#args>0) then
				local Targets = LA:FindPlayers( args )
				if (#Targets>0) then
					for k,v in ipairs( Targets ) do
						v:SetJumpPower( jump )
					end
					LA:Message( LA.Colors.Green, ply, LA.Colors.White, " set the jump strength of ", LA.Colors.Blue, LA:GetNameList( Targets ), LA.Colors.White, " to ", LA.Colors.Blue, tostring(jump), LA.Colors.White, "." )
				else
					LA:Message( ply, unpack( LA.NoPlayersFound ) )
				end
			else
				ply:SetJumpPower( jump )
				LA:Message( LA.Colors.Green, ply, LA.Colors.White, " set their jump strength to ", LA.Colors.Blue, tostring(jump), LA.Colors.White, "." )
			end
		else
			LA:Message( ply, unpack( LA.NoNameEntered ) )
		end
	else
		LA:Message( ply, unpack( LA.NotAllowed ) )
	end
end

function Plugin:Resetjump( ply, args )
	if (#args>0 and tonumber(args[#args]) > 0) then table.remove( args, #args ) end
	table.insert( args, "200" )
	if (#args == 1) then table.insert( args, '"' .. ply:Nick() .. '"', 1 ) end
	self:Jump( ply, args )
end

LA:AddPlugin( Plugin )