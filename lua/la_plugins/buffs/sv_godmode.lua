----------------------------------------------------------------
-- Godmode
----------------------------------------------------------------
local Plugin = {}
Plugin.Name = "Godmode"
Plugin.Author = "Divran"
Plugin.Description = "Grant someone godly powers."
Plugin.Commands = { "God", "Ungod" }

Plugin.Help = {}
Plugin.Help["God"] = "[player(s)] or [nil]"
Plugin.Help["Ungod"] = "[player(s)] or [nil]"

Plugin.Category = "Buffs"

Plugin.Privs = table.Copy( Plugin.Commands )

function Plugin:God( ply, args )
	if (LA:CheckAllowed( ply, Plugin, "God" )) then
		local Targets = LA:FindPlayers( args )
		if (#Targets>0) then
			local tbl = {}
			for k,v in ipairs( Targets ) do
				if (!v.LA_Godmode) then
					v.LA_Godmode = true
					v:GodEnable()
					table.insert( tbl, v )
				end
			end
			if (#tbl>0) then
				LA:Message( LA.Colors.Green, ply, LA.Colors.White, " enabled godmode for ", LA.Colors.Blue, LA:GetNameList( tbl ), LA.Colors.White, "." )
			else
				LA:Message( ply, LA.Colors.Red, "All targets already have godmode." )
			end			
		else
			if (ply.LA_Godmode) then
				ply.LA_Godmode = true
				ply:GodEnable()
				LA:Message( LA.Colors.Green, ply, LA.Colors.White, " enabled godmode for themself." )
			else
				LA:Message( ply, LA.Colors.Red, "You already have godmode enabled." )
			end
		end
	else
		LA:Message( ply, unpack( LA.NotAllowed ) )
	end
end

function Plugin:Ungod( ply, args )
	if (LA:CheckAllowed( ply, Plugin, "Ungod" )) then
		local Targets = LA:FindPlayers( args )
		if (#Targets>0) then
			local tbl = {}
			for k,v in ipairs( Targets ) do
				if (v.LA_Godmode) then
					v.LA_Godmode = nil
					v:GodDisable()
					table.insert( tbl, v )
				end
			end
			if (#tbl>0) then
				LA:Message( LA.Colors.Green, ply, LA.Colors.White, " disabled godmode ", LA.Colors.Blue, LA:GetNameList( tbl ), LA.Colors.White, "." )
			else
				LA:Message( ply, LA.Colors.Red, "None of the targets have godmode." )
			end			
		else
			if (!ply.LA_Godmode) then
				ply.LA_Godmode = nil
				ply:GodDisable()
				LA:Message( LA.Colors.Green, ply, LA.Colors.White, " disabled godmode for themself." )
			else
				LA:Message( ply, LA.Colors.Red, "You don't have godmode enabled." )
			end
		end
	else
		LA:Message( ply, unpack( LA.NotAllowed ) )
	end
end

function Plugin:PlayerSpawn( ply )
	if (ply.LA_Godmode) then ply:GodEnable() end
end

LA:AddPlugin( Plugin )