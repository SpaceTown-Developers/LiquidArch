----------------------------------------------------------------
-- Jail
----------------------------------------------------------------
local Plugin = {}
Plugin.Name = "Jail"
Plugin.Author = "Divran"
Plugin.Description = "Jail, cage, unjail, or uncage someone."
Plugin.Commands = { "Jail", "Unjail", "Cage", "Uncage" }

Plugin.Help = {}
Plugin.Help["Jail"] = "[player(s)]"
Plugin.Help["Unjail"] = "[player(s)]"
Plugin.Help["Cage"] = "[player(s)]"
Plugin.Help["Uncage"] = "[player(s)]"

Plugin.Category = "Punishment"

Plugin.Privs = { "Jail", "Cage", "Unjail and cage" }

function Plugin:PlayerSpawn( ply )
	if (ply.LA_JailPos != nil) then
		ply:SetPos( ply.LA_JailPos )
		timer.Simple( 0.05, function() ply:StripWeapons() end )
	end
end

function Plugin:ImprisonTarget( Target, JailPos, SpawnCage )
	if (JailPos) then 
		Target:SetPos( JailPos ) 
		Target.LA_JailPos = JailPos
		Target:SetNWBool( "LA.Jailed", true )
	end
	if (SpawnCage) then 
		self:SpawnCage( Target, Target:GetPos() ) 
		Target.LA_JailPos = Target:GetPos()
		Target:SetNWBool( "LA.Jailed", true )
	end
	Target:StripWeapons()
end

function Plugin:UnJailAndCage( Target )
	GAMEMODE:PlayerLoadout( Target )
	Target.LA_JailPos = nil
	Target:SetNWBool( "LA.Jailed", false )
	self:SpawnCage( Target )
end

Plugin.CageTbl = {}
Plugin.CageTbl.Pos = {Vector(0,-65,60),Vector(0,65,60),Vector(65,0,60),Vector(-65,0,60),Vector(0,0,125),Vector(0,0,-5)}
Plugin.CageTbl.Ang = {Angle(0,90,0),Angle(0,90,0),Angle(0,0,0),Angle(0,0,0),Angle(90,0,0),Angle(90,0,0)}

function Plugin:SpawnCage( ply, Pos )
	if (Pos and type(Pos) == "Vector") then
		for i=1, #self.CageTbl.Pos do
			local CurPos = Pos + self.CageTbl.Pos[i]
			local Ang = self.CageTbl.Ang[i]
			if (!ply.Cage) then ply.Cage = {} end
			ply.Cage[i] = ents.Create("prop_physics")
			ply.Cage[i].LA_IsCage = true
			ply.Cage[i]:SetModel("models/props_wasteland/interior_fence002c.mdl")
			ply.Cage[i]:SetPos(CurPos)
			ply.Cage[i]:SetAngles(Ang)
			ply.Cage[i]:Spawn()
			local phys = ply.Cage[i]:GetPhysicsObject()
			phys:EnableMotion(false)
			phys:Wake()
		end
	else
		if (ply.Cage and #ply.Cage>0) then
			for k,v in ipairs( ply.Cage ) do
				v:Remove()
			end
			ply.Cage = nil
		end
	end
end

function Plugin:PlayerSpawnObject( ply ) -- Prop/Ragdoll/Effect
	if (ply.LA_JailPos) then return false end
end
function Plugin:PlayerSpawnSENT( ply ) -- Entity
	if (ply.LA_JailPos) then return false end
end
function Plugin:PlayerSpawnSWEP( ply ) -- Weapon
	if (ply.LA_JailPos) then return false end
end
function Plugin:PlayerSpawnNPC( ply ) -- NPC
	if (ply.LA_JailPos) then return false end
end
function Plugin:PlayerSPawnVehicle( ply ) -- Vehicle
	if (ply.LA_JailPos) then return false end
end
function Plugin:PhysgunPickup( ply, ent ) -- Don't allow people to pick up the jail pieces
	if (ent.LA_IsCage) then return false end
end
function Plugin:CanTool( ply, ent ) -- Don't allow people to use the toolgun on the jail pieces
	if (ent.LA_IsCage) then return false end
end
function Plugin:PlayerNoClip( ply ) -- Don't allow jailed people to noclip
	if (ply:GetMoveType() == MOVETYPE_WALK) then
		if (ply.LA_JailPos) then return false end
	end
end

function Plugin:Jail( ply, args )
	if (LA:CheckAllowed( ply, Plugin, "Jail" )) then
		if (#args>0) then
			local Targets = LA:FindPlayers( args )
			if (#Targets>0) then
				local jailed = {}
				for k,v in ipairs( Targets ) do
					if (!v.LA_JailPos) then
						self:ImprisonTarget( v, ply:GetEyeTrace().HitPos, false )
						table.insert( jailed,v )
					end
				end
				LA:Message( LA.Colors.Green, ply, LA.Colors.White, " jailed ", LA.Colors.Blue, LA:GetNameList( jailed ), LA.Colors.White, "." )
			else
				LA:Message( ply, unpack( LA.NoPlayersFound ) )
			end
		else
			self:ImprisonTarget( ply, ply:GetEyeTrace().HitPos, false )
			LA:Message( LA.Colors.Green, ply, LA.Colors.White, " jailed ", LA.Colors.Blue, " themself." )
		end
	else
		LA:Message( ply, unpack( LA.NotAllowed ) )
	end
end

function Plugin:Unjail( ply, args )
	if (LA:CheckAllowed( ply, Plugin, "Unjail and cage" )) then
		if (#args>0) then
				local Targets = LA:FindPlayers( args )
				if (#Targets>0) then
					local unjailed = {}
					for k,v in ipairs( Targets ) do
						if (v.LA_JailPos) then
							self:UnJailAndCage( v )
							table.insert( unjailed,v )
						end
					end
					LA:Message( LA.Colors.Green, ply, LA.Colors.White, " unjailed ", LA.Colors.Blue, LA:GetNameList( unjailed ), LA.Colors.White, "." )
				else
					LA:Message( ply, unpack( LA.NoPlayersFound ) )
				end
		else
			self:UnJailAndCage( ply )
			LA:Message( LA.Colors.Green, ply, LA.Colors.White, " unjailed ",LA.Colors.Blue,"themself.")
		end
	else
		LA:Message( ply, unpack( LA.NotAllowed ) )
	end
end

function Plugin:Uncage( ply, args ) self:Unjail( ply, args ) end

function Plugin:Cage( ply, args )
	if (LA:CheckAllowed( ply, Plugin, "Cage" )) then
		if (#args>0) then
			local Targets = LA:FindPlayers( args )
			if (#Targets>0) then
				local caged = {}
				for k,v in ipairs( Targets ) do
					if (!v.LA_JailPos) then
						self:ImprisonTarget( v, nil, true )
						table.insert( caged,v )
					end
				end
				LA:Message( LA.Colors.Green, ply, LA.Colors.White, " caged ", LA.Colors.Blue, LA:GetNameList( caged ), LA.Colors.White, "." )
			else
				LA:Message( ply, unpack( LA.NoPlayersFound ) )
			end
		else
			self:ImprisonTarget( ply, nil, true )
			LA:Message( LA.Colors.Green, ply, LA.Colors.White, " caged ", LA.Colors.Blue, " themself." )
		end
	else
		LA:Message( ply, unpack( LA.NotAllowed ) )
	end
end

LA:AddPlugin( Plugin )