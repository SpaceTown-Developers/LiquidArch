----------------------------------------------------------------
-- Slap
----------------------------------------------------------------
Plugin = {}
Plugin.Name = "Slap"
Plugin.Author = "Goluch"
Plugin.Description = "Slap yourself or another player to Kingdome Kome."
Plugin.Commands = { "Slap","Whip" }

Plugin.Help = {}
Plugin.Help["Slap"] = "[player(s)] [damage] or [damage]"
Plugin.Help["Whip"] = "[player(s)] [damage] or [damage]"

Plugin.Category = "Fun"

Plugin.Privs = table.Copy( Plugin.Commands )

function Plugin:Toslap(ply,mult)
	mult = math.Clamp(mult,0,10) or 5
	local max = mult * 500
	local vel = Vector( math.random( max*-1,max), math.random( max*-1,max), math.random( max*-1,max) )
	ply:SetVelocity( vel )
	ply:SetHealth( ply:Health() - mult )
	if ply:Health() <= 0 then ply:Kill() return true end
end

function Plugin:Slap( ply, args )
	if (LA:CheckAllowed( ply, Plugin, "Slap" )) then
		if (#args>0) then
			local damage = tonumber( table.remove( args, #args ) ) or 0
			
			if (#args == 0) then
				self:Toslap( ply, damage )
			elseif (#args>0) then
				local Targets = LA:FindPlayers( args )
				if (#Targets>0) then
					for k,v in ipairs( Targets ) do
						self:Toslap(v,damage)
					end
					LA:Message( LA.Colors.Green, ply, LA.Colors.White, " slapped ", LA.Colors.Blue, LA:GetNameList(Targets), LA.Colors.White, " with ", LA.Colors.Blue, tostring(damage), LA.Colors.White, " damage." )
				else
					LA:Message( ply, unpack( LA.NoPlayersFound ) )
				end
			end
		else
			self:Toslap(ply,100)
			LA:Message( LA.Colors.Green, ply, LA.Colors.White, " slapped themself with ", LA.Colors.Blue, "100", LA.Colors.White, " damage" )
		end
	end
end

function Plugin:Towhip(ply,times,mult)
	times = math.Clamp(times,2,100) or 2
	timer.Create("whip_"..ply:UniqueID(), times , 1, function( )
		if self:Toslap(ply,mult) then timer.Destroy("whip:"..ply:UniqueID()) end
	end )
end

function Plugin:Whip( ply, args )
	if (LA:CheckAllowed( ply, Plugin, "Whip" )) then
		if (#args>0) then
			local amount = tonumber( table.remove(args, #args) ) or 0
			
			if (#args==0) then 
				self:Towhip( ply, amount, 100 )
				LA:Message( LA.Colors.Green, ply, LA.Colors.White, " whipped themself ", LA.Colors.Blue, tostring(amount), LA.Colors.Blue, " times with ", LA.Colors.Blue, "100", LA.Colors.White, " damage." )
			elseif (#args>0) then
				local damage = tonumber(table.remove(args, #args))
				
				if (#args==0) then
					self:Towhip( ply, amount, damage )
					LA:Message( LA.Colors.Green, ply, LA.Colors.White, " whipped themself ", LA.Colors.Blue, tostring(amount), LA.Colors.Blue, " times with ", LA.Colors.Blue, tostring(damage), LA.Colors.White, " damage." )
				elseif (#args>0) then
					local Targets = LA:FindPlayers( args )
					if (#Targets>0) then
						for k,v in ipairs( Targets ) do
							self:Towhip( v, amount, damage )
						end
						LA:Message( LA.Colors.Green, ply, LA.Colors.White, " whipped ", LA.Colors.Blue, LA:GetNameList( Targets ) .. " " .. amount, LA.Colors.White, " times with ", LA.Colors.Blue, tostring(damage), LA.Colors.White, " damage." )
					else
						LA:Message( ply, unpack( LA.NoPlayersFound ) )
					end
				end
			end
		else
			LA:Message( ply, unpack( LA.NoNameEntered ) )
		end
	else
		LA:Message( ply, unpack( LA.NotAllowed ) )
	end
end

LA:AddPlugin( Plugin )