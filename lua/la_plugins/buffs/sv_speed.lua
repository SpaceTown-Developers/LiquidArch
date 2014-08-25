----------------------------------------------------------------
-- Speed
----------------------------------------------------------------
local Plugin = {}
Plugin.Name = "Speed"
Plugin.Author = "Divran"
Plugin.Description = "Change the movement speed of a player."
Plugin.Commands = { "Speed", "Resetspeed" }

Plugin.Help = {}
Plugin.Help["Speed"] = "[player(s)] [speed] or [speed]"
Plugin.Help["Resetspeed"] = "[player(s)] or [nil]"

Plugin.Category = "Buffs"

Plugin.Privs = { "Speed" }

function Plugin:Speed( ply, args )
	if (LA:CheckAllowed( ply, Plugin, "Speed" )) then
		if (#args>0) then
			local speed = math.Clamp( tonumber(args[#args]), 1, 1000000 )
			table.remove( args, #args )
			if (#args>0) then
				local Targets = LA:FindPlayers( args )
				if (#Targets>0) then
					for k,v in ipairs( Targets ) do
						v:SetRunSpeed( speed * 2 )
						v:SetWalkSpeed( speed )
					end
					LA:Message( LA.Colors.Green, ply, LA.Colors.White, " set the movement speed of ", LA.Colors.Blue, LA:GetNameList( Targets ), LA.Colors.White, " to ", LA.Colors.Blue, tostring(speed), LA.Colors.White, "." )
				else
					LA:Message( ply, unpack( LA.NoPlayersFound ) )
				end
			else
				ply:SetRunSpeed( speed * 2 )
				ply:SetWalkSpeed( speed )
				LA:Message( LA.Colors.Green, ply, LA.Colors.White, " set their movement speed to ", LA.Colors.Blue, tostring(speed), LA.Colors.White, "." )
			end
		else
			LA:Message( ply, unpack( LA.NoNameEntered ) )
		end
	else
		LA:Message( ply, unpack( LA.NotAllowed ) )
	end
end

function Plugin:Resetspeed( ply, args )
	if (#args>0 and tonumber(args[#args]) > 0) then table.remove( args, #args ) end
	table.insert( args, "250" )
	if (#args == 1) then table.insert( args, '"' .. ply:Nick() .. '"', 1 ) end
	self:Speed( ply, args )
end

LA:AddPlugin( Plugin )