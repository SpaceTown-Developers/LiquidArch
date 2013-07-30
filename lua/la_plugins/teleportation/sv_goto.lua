----------------------------------------------------------------
-- Goto
----------------------------------------------------------------
local Plugin = {}
Plugin.Name = "Goto"
Plugin.Author = "Divran"
Plugin.Description = "Goto or bring a player, or send a player to another player."
Plugin.Commands = { "Goto", "Bring", "Send" }

Plugin.Help = {}
Plugin.Help["Goto"] = "[player]"
Plugin.Help["Bring"] = "[player(s)]"
Plugin.Help["Send"] = "[player(s)] [player]"

Plugin.Category = "Teleportation"

Plugin.Privs = table.Copy( Plugin.Commands )

-- These three plugins are related because they all need to use the FindSpot function. That is why they are all in the same file and not seperate.

Plugin.SearchSpots = {}
for i=0,360,45 do table.insert( Plugin.SearchSpots, Vector(math.cos(i),math.sin(i),0) ) end -- Around
table.insert( Plugin.SearchSpots, Vector(0,0,1) ) -- Above

function Plugin:FindSpot( ply, Target )
	-- Player
	local Size = ply:OBBMaxs() - ply:OBBMins()

	-- Target Player
	local TargetSize = Target:OBBMaxs() - Target:OBBMins()
	local Vec = Target:GetPos()

	-- If player is in noclip, return pos
	if (ply:GetMoveType() == MOVETYPE_NOCLIP) then
		return Vec + Target:GetForward() * (sqrt(Size.x^2+Size.y^2)/2+sqrt(TargetSize.x^2+TargetSize.y^2)/2)
	else
		local StartPos = Vec + Vector(0,0,TargetSize.z / 2)
		for _,v in ipairs( self.SearchSpots ) do
			-- Calculate mul
			local Mul1 = (v*Size):Length()
			local Mul2 = (v*TargetSize):Length()
			local Mul = (Mul1+Mul2) * 0.55
			
			-- Calculate pos
			local Pos = StartPos + v * Mul
			
			-- Check if pos is free
			local tr = {}
			tr.start = Pos
			tr.endpos = Pos
			tr.mins = Size/2*-1
			tr.maxs = Size/2
			local trace = util.TraceHull( tr )
			
			-- If free, return pos
			if (!trace.Hit) then
				return Pos - Vector(0,0,TargetSize.z / 2)
			end
		end
	end
	return false
end

function Plugin:Goto( ply, args ) 
	if (LA:CheckAllowed( ply, Plugin, "Goto" )) then
		if (args[1]) then
			local Target = LA:FindPlayer( args[1], true )
			if (Target) then
				local Pos = self:FindSpot( ply, Target )
				if (Pos) then
					ply:SetPos( Pos )
					ply:SetVelocity( Vector(0,0,0) )
					LA:Message( LA.Colors.Green, ply, LA.Colors.White, " teleported to ", LA.Colors.Blue, Target:Nick(), LA.Colors.White, "." )
				else
					LA:Message( ply, LA.Colors.Red, "No position found. ", LA.Colors.White, "Noclip to force goto." )
				end
			else
				LA:Message( ply, LA.Colors.Red, "No player named '", LA.Colors.Blue, args[1], LA.Colors.Red, "' found." )
			end
		else
			LA:Message( ply, unpack( LA.NoNameEntered ) )
		end
	else
		LA:Message( ply, unpack( LA.NotAllowed ) )
	end
end

function Plugin:Bring( ply, args )
	if (LA:CheckAllowed( ply, Plugin, "Bring" )) then
		if (args[1]) then
			local Targets = LA:FindPlayers( args )
			if (#Targets>0) then
				local brought = {}
				for k,v in ipairs( Targets ) do
					if (v:InVehicle()) then
						LA:Message( v, LA.Colors.Green, ply, LA.Colors.White, " tried to bring you, but you are in a vehicle." )
					else
						local Pos = self:FindSpot( v, ply )
						if (Pos) then
							v:SetPos( Pos )
							v:SetVelocity( Vector(0,0,0) )
							table.insert( brought, v )
						else
							LA:Message( v, LA.Colors.Green, ply, LA.Colors.White, " tried to bring you, but no position was found. Noclip to force bring." )
						end
					end
				end
				if (#brought>0) then
					LA:Message( LA.Colors.Green, ply, LA.Colors.White, " brought ", LA.Colors.Blue, LA:GetNameList( brought ), LA.Colors.White, "." )
				else
					LA:Message( ply, LA.Colors.Red, "No positions were found for any of the targets." )
				end
			else
				LA:Message( ply, unpack( LA.NoPlayersFound ) )
			end
		else
			LA:Message( ply, unpack( LA.NoNameEntered ) )
		end
	else
		LA:Message( ply, unpack( LA.NotAllowed ) )
	end
end

function Plugin:Send( ply, args )
	if (LA:CheckAllowed( ply, Plugin, "Send" )) then
		if (args[1]) then
		
			-- Find target
			local Target = LA:FindPlayer( args[#args], true )
			if (Target) then
				table.remove( args, #args )
				
				-- Find other targets
				local Targets = LA:FindPlayers( args )
				
				-- Send players to target
				if (#Targets>0) then
					local sent = {}
					for k,v in ipairs( Targets ) do
						local Pos = self:FindSpot( v, Target )
						if (Pos) then
							v:SetPos( Pos )
							v:SetVelocity( Vector(0,0,0) )
							table.insert( sent, v )
						else
							LA:Message( v, LA.Colors.Green, ply, LA.Colors.White, " tried to send you to ", LA.Colors.Blue, Target:Nick(), LA.Colors.White, ", but no position was found. Noclip to force send." )
						end
					end
					LA:Message( LA.Colors.Green, ply, LA.Colors.White, " sent ", LA.Colors.Blue, LA:GetNameList( sent ), LA.Colors.White, " to ", LA.Colors.Blue, Target:Nick(), LA.Colors.White, "." )
				else
					LA:Message( ply, unpack( LA.NoPlayersFound ) )
				end
			else
				LA:Message( ply, LA.Colors.Red, "No player named '", LA.Colors.Blue, args[#args], LA.Colors.Red, "' found." )
			end
		else
			LA:Message( ply, unpack( LA.NoNameEntered ) )
		end
	else
		LA:Message( ply, unpack( LA.NotAllowed ) )
	end
end


LA:AddPlugin( Plugin )