----------------------------------------------------------------
-- Player Ents
----------------------------------------------------------------
local Plugin = {}
Plugin.Name = "PlayerEnts"
Plugin.Author = "Divran"
Plugin.Description = "This plugin keeps track of who has spawned what. Used in other plugins."
Plugin.CanDisable = false

LA.PlayerEnts = {}
function Plugin:PlayerInitialSpawn( ply )
	LA.PlayerEnts[tostring(ply)] = {}
end

timer.Simple(1, function()
	if (!LA.HasPlayerEntsFunction) then -- This is to stop it from overwriting itself twice if you use "lua_run LA:Initialize()" in console
		LA.HasPlayerEntsFunction = true
		local OldFunc = _R.Player.AddCount
		function _R.Player:AddCount( what, ent )
			if (self and self:IsPlayer() and self:IsValid()) then
				if (!LA.PlayerEnts[tostring(self)]) then LA.PlayerEnts[tostring(self)] = {} end
				table.insert( LA.PlayerEnts[tostring(self)], ent )
			end
			OldFunc( self, what, ent )
		end
	end
end)

function Plugin:EntityRemoved( ent )
	local removes = {} -- The extra table & loop is necessary because we can't use table.remove on the table which is currently being iterated.
	for k,v in pairs( LA.PlayerEnts ) do
		for k2,v2 in pairs( v ) do
			if (v2 == ent) then
				table.insert( removes, { k, k2 } )
			end
		end
	end
	for k,v in ipairs( removes ) do
		table.remove( LA.PlayerEnts[v[1]], v[2] )
	end
end

LA:AddPlugin( Plugin )