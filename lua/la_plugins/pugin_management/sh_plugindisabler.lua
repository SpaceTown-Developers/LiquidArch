----------------------------------------------------------------
-- Plugin Disabler
----------------------------------------------------------------
local Plugin = {}
Plugin.Name = "PluginDisabler"
Plugin.Author = "Divran"
Plugin.Description = "Disable or enable individual plugins."
Plugin.Commands = { "Disable", "Enable", "Cldisable", "Clenable" }
Plugin.CanDisable = false

Plugin.Help = {}
Plugin.Help["Disable"] = "[plugin(s)]"
Plugin.Help["Enable"] = "[plugin(s)]"
Plugin.Help["Cldisable"] = "[plugin(s)]"
Plugin.Help["Clenable"] = "[plugin(s)]"

Plugin.Category = "Plugin Management"

Plugin.Privs = { "Plugin Enable", "Plugin Disable" }

function Plugin:SetStatus( ply, PlugName, Bool )
	local Plug = LA:GetPlugin( PlugName )
	if (Plug) then
		if (Plug.CanDisable == false) then return false end -- No. This plugin is locked.
		if (Plug.Enabled != Bool) then
			if (Plug.EnableToggle) then
				LA:CallHook( Plug.EnableToggle, Plug, ply, Bool )
			end
			Plug.Enabled = Bool
			return true, Plug.Name
		end
	end
	return false
end

function Plugin:GetPluginNameList( Table )
	if (#Table == #LA.Plugins) then
		return "all plugins"
	elseif (#Table == 1) then
		return Table[1]
	else
		local ret = {}
		for k,v in ipairs( Table ) do
			if (k == #Table - 1) then
				table.insert( ret, v .. ", and " )
			elseif (k < #Table - 1) then
				table.insert( ret, v .. ", " )
			end
		end
		return ret
	end
end

if (SERVER) then
	function Plugin:Disable( ply, args )
		if (LA:CheckAllowed( ply, Plugin, "Plugin Disable" )) then
			if (#args > 0) then
				local tbl = {}
				for k,v in ipairs( args ) do
					local ret, Name = self:SetStatus( ply, v, false )
					if (ret) then table.insert( tbl, Name )	end
				end
				
				if (#tbl>0) then
					LA:Message( LA.Colors.Green, ply, LA.Colors.White, " disabled ", LA.Colors.Blue, self:GetPluginNameList( tbl ), LA.Colors.White, "." )
				else
					LA:Message( ply, LA.Colors.Red, "No plugins found, or all plugins were already disabled." )
				end
			end
		end
	end
	
	function Plugin:Enable( ply, args )
		if (LA:CheckAllowed( ply, Plugin, "Plugin Enable" )) then
			if (#args > 0) then
				local tbl = {}
				for k,v in ipairs( args ) do
					local ret, Name = self:SetStatus( ply, v, true )
					if (ret) then table.insert( tbl, Name )	end
				end
				
				if (#tbl>0) then
					LA:Message( LA.Colors.Green, ply, LA.Colors.White, " enabled ", LA.Colors.Blue, self:GetPluginNameList( tbl ), LA.Colors.White, "." )
				else
					LA:Message( ply, LA.Colors.Red, "No plugins found, or all plugins were already enabled." )
				end
			end
		end
	end
else
	function Plugin:Cldisable( ply, args )
		if (#args > 0) then
			local tbl = {}
			for k,v in ipairs( args ) do
				local ret, Name = self:SetStatus( ply, v, false )
				if (ret) then table.insert( tbl, Name )	end
			end
			
			if (#tbl>0) then
				LA:Message( ply, "You disabled the client side plugins ", LA.Colors.Blue, self:GetPluginNameList( tbl ), LA.Colors.White, "." )
			else
				LA:Message( ply, LA.Colors.Red, "No plugins found, or all plugins were already disabled." )
			end
		end
	end
	-- This concommand is a special case, because the other console command system is server side only.
	concommand.Add("la_cldisable", function( ply, cmd, args ) Plugin:Cldisable( ply, args ) end)
	
	function Plugin:Clenable( ply, args )
		if (#args > 0) then
			local tbl = {}
			for k,v in ipairs( args ) do
				local ret, Name = self:SetStatus( ply, v, true )
				if (ret) then table.insert( tbl, Name )	end
			end
			
			if (#tbl>0) then
				LA:Message( ply, "You enabled the client side plugins ", LA.Colors.Blue, self:GetPluginNameList( tbl ), LA.Colors.White, "." )
			else
				LA:Message( ply, LA.Colors.Red, "No plugins found, or all plugins were already enabled." )
			end
		end
	end
	concommand.Add("la_clenable", function( ply, cmd, args ) Plugin:Clenable( ply, args ) end)
end

LA:AddPlugin( Plugin )