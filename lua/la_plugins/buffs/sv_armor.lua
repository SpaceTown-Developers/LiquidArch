----------------------------------------------------------------
-- Armor
----------------------------------------------------------------
local Plugin = {}
Plugin.Name = "Armor"
Plugin.Author = "Divran"
Plugin.Description = "Change the armor of a player."
Plugin.Commands = { "Armor" }

Plugin.Help = {}
Plugin.Help["Armor"] = "[player(s)] [armor] or [armor]"

Plugin.Category = "Buffs"

Plugin.Privs = { "Armor" }

function Plugin:Armor( ply, args )
	if (LA:CheckAllowed( ply, Plugin, "Armor" )) then
		if (#args>0) then
			local armor = math.Clamp( tonumber(args[#args]), 1, 99999 )
			table.remove( args, #args )
			if (#args>0) then
				local Targets = LA:FindPlayers( args )
				if (#Targets>0) then
					for k,v in ipairs( Targets ) do
						v:SetArmor( armor )
					end
					LA:Message( LA.Colors.Green, ply, LA.Colors.White, " set the armor of ", LA.Colors.Blue, LA:GetNameList( Targets ), LA.Colors.White, " to ", LA.Colors.Blue, tostring(armor), LA.Colors.White, "." )
				else
					LA:Message( ply, unpack( LA.NoPlayersFound ) )
				end
			else
				ply:SetArmor( armor )
				LA:Message( LA.Colors.Green, ply, LA.Colors.White, " set their armor to ", LA.Colors.Blue, tostring(armor), LA.Colors.White, "." )
			end
		else
			LA:Message( ply, unpack( LA.NoNameEntered ) )
		end
	else
		LA:Message( ply, unpack( LA.NotAllowed ) )
	end
end

LA:AddPlugin( Plugin )