----------------------------------------------------------------
-- Noclip Control
----------------------------------------------------------------
local Plugin = {}
Plugin.Name = "NoclipControl"
Plugin.Author = "Divran"
Plugin.Description = "This plugin works like ULX's Uclip."
Plugin.Commands = nil
Plugin.Enabled = false -- This plugin does not work yet

function Plugin:PlayerNoClip(ply)
	if (ply:GetMoveType() == MOVETYPE_WALK) then
		ply:SetMoveType(MOVETYPE_FLY)
	elseif (ply:GetMoveType() == MOVETYPE_FLY) then
		ply:SetMoveType(MOVETYPE_WALK)
	end
	return false
end

function Plugin:SlidePos( Velocity, Normal )
	local Length = Velocity:Length()
	local dotProduct = Normal:DotProduct( Velocity:GetNormal() ) * 0.1
	local reflected = (Velocity:GetNormal() - 2 * math.Clamp( dotProduct, -1, 1 ) * Normal):GetNormal()
	return reflected * Length
	
	--print("normal: ",Normal)
	--local VecA = Normal:Cross(Velocity)
	--local PlayerNewVec = VecA:Cross(Normal)
	--return PlayerNewVec
	--return (WallNormal:Cross(Velocity:GetNormal())):Cross(WallNormal)
end

function Plugin:Move(ply,move)
	if (ply:GetMoveType() == MOVETYPE_FLY) then
		-- Time to fake noclip
		vel = Vector(0,0,0)
		if (ply:KeyDown( IN_FORWARD )) then vel = vel + Vector( 500,0,0 ) end
		if (ply:KeyDown( IN_BACK )) then vel = vel + Vector( -500,0,0 ) end
		if (ply:KeyDown( IN_LEFT )) then vel = vel + Vector( 0,-500,0 ) end
		if (ply:KeyDown( IN_RIGHT )) then vel = vel + Vector( 0,500,0 ) end

		vel = ply:GetForward() * vel.x + ply:GetRight() * vel.y
		--vel:Rotate(ply:EyeAngles())
		
		if (ply:KeyDown( IN_JUMP )) then vel = vel + Vector( 0,0,500 ) end
		if (ply:KeyDown( IN_RUN )) then vel = vel * 3 end
		
		if (vel == Vector(0,0,0)) then move:SetVelocity( vel ) return end
		
		local tr = {}
		tr.start = ply:GetPos()
		tr.endpos = ply:GetPos() + vel:GetNormal() * FrameTime() * 1.1
		tr.filter = ply
		trace = util.TraceEntity( tr, ply )
		
		if (trace.Hit) then
			vel = self:SlidePos( vel, trace.HitNormal )
		end
		
		move:SetVelocity(vel)
	end
end

--[[

-- In case you're wondering why I'm setting the player's move type to MOVETYPE_WALK, it's because
-- Garry has fucked up the Move hook, so that it no longer works in noclip.

function Plugin:SlidePos( Velocity, Normal )
	--local Length = Velocity:Length()
	--local dotProduct = Normal:DotProduct( Velocity:GetNormal() ) * 0.1
	--local reflected = (Velocity:GetNormal() - 2 * math.Clamp( dotProduct, -1, 1 ) * Normal):GetNormal()
	--return reflected * Length
	
	print("normal: ",Normal)
	local VecA = Normal:Cross(Velocity)
	local PlayerNewVec = VecA:Cross(Normal)
	return PlayerNewVec
	--return (WallNormal:Cross(Velocity:GetNormal())):Cross(WallNormal)
end

function Plugin:CalculateNewVel( ply, move )
	local trace
	
	if (ply.LA_AffectedByClipControl == true) then
		if (ply:GetMoveType() != MOVETYPE_FLY) then ply:SetMoveType(MOVETYPE_FLY) end
		-- Time to fake noclip
		vel = Vector(0,0,0)
		if (ply:KeyDown( IN_FORWARD )) then vel = vel + Vector( 500,0,0 ) end
		if (ply:KeyDown( IN_BACK )) then vel = vel + Vector( -500,0,0 ) end
		if (ply:KeyDown( IN_LEFT )) then vel = vel + Vector( 0,-500,0 ) end
		if (ply:KeyDown( IN_RIGHT )) then vel = vel + Vector( 0,500,0 ) end
		if (ply:KeyDown( IN_JUMP )) then vel = vel + Vector( 0,0,500 ) end
		if (ply:KeyDown( IN_RUN )) then vel = vel * 3 end
		
		if (vel == Vector(0,0,0)) then return false end
		
		vel:Rotate(ply:EyeAngles())
		
		local tr = {}
		tr.start = ply:GetPos()
		tr.endpos = ply:GetPos() + vel:GetNormal() * FrameTime() * 1.1
		tr.filter = ply
		trace = util.TraceEntity( tr, ply )
		
		if (trace.Hit) then
			local newvel = self:SlidePos( vel, trace.HitNormal )
			
			move:SetSideSpeed( 0 )
			move:SetForwardSpeed( 0 )
			move:SetUpSpeed( 0 )
			move:SetVelocity( newvel )
			
			if (SERVER) then print("vel modified from ",vel," to ",newvel) end		
		end
		return trace.Hit, trace
	else
		local vel = move:GetVelocity()
		local tr = {}
		tr.start = ply:GetPos()
		tr.endpos = ply:GetPos() + vel:GetNormal() * FrameTime() * 2
		tr.filter = ply
		trace = util.TraceEntity( tr, ply )
	end
	
	return trace.Hit, trace
end

function Plugin:Move( ply, move )
	--if (move:GetVelocity() != Vector(0,0,0) or ply:GetMoveType() == MOVETYPE_FLY) then print("CALLED! Fly: ",MOVETYPE_FLY, " Movetype: ",ply:GetMoveType()) end
	if (ply.LA_AffectedByClipControl) then -- If the player is currently affected by this plugin
		local hit = self:CalculateNewVel( ply, move ) -- Move the player
		if (!hit) then -- If the trace did not hit something
			ply.LA_AffectedByClipControl = nil -- Put them back into noclip
			ply:SetMoveType(MOVETYPE_NOCLIP)
			if (SERVER) then ply:ChatPrint("EXITED FAKE NOCLIP.") end
		end
	else
		if (ply:GetMoveType() == MOVETYPE_NOCLIP) then -- If the player is flying
			local hit, trace = self:CalculateNewVel( ply, move )
			if (hit) then
				if (SERVER) then ply:ChatPrint("ENTERED FAKE NOCLIP.") end
				ply.LA_AffectedByClipControl = true
				ply:SetMoveType(MOVETYPE_FLY)
				--ply:SetPos( trace.HitPos )
			end
		end
	end
end

]]

LA:AddPlugin( Plugin )