----------------------------------------------------------------
-- Chat
----------------------------------------------------------------
local Plugin = {}
Plugin.Name = "Chat"
Plugin.Author = "Divran"
Plugin.Description = "This plugin takes care of chat and console commands."
Plugin.CanDisable = false

function Plugin:Explode( message )
	local ret = { }
	local skip = true
	local temp
	for word in message:gmatch( "%S+" ) do
		if (skip) then skip = false else
			if (word:find( '^"' )) then -- If the word starts with a "
				if (word:find( '"$' )) then -- If the word also ends with a "
					table.insert( ret, word )
				else
					temp = word
				end
			elseif (word:find( '"$' )) then -- If the word ends with a "
				table.insert( ret, temp.." "..word ) -- Insert word
				temp = nil -- Stop adding to temp
			else -- If the word does not contain a "
				if (temp) then -- If we are currently getting words with " " in it
					temp = temp.." "..word
				else
					table.insert( ret, word )
				end
			end
		end
	end
	return ret
end

function Plugin:upperfirst( word )
	return word:Left(1):upper() .. word:Right(-2):lower()
end

function Plugin:PlayerSay( ply, message )
	if (string.Left( message, 1 ) == "!") then
		-- Get the command
		local command = string.match( message, "%w+" )
		
		if (command and #command > 0) then
			
			command = self:upperfirst( command ) -- Lower all except first
			
			-- Get the arguments
			local args = self:Explode( message )
			
			local found = self:RunPlug( ply, command, args )
			
			if (!found) then
				LA:Message( ply, LA.Colors.Red, "Unknown command '" .. command .. "'." )
			else
				return ""
			end
			
		end
	end
end

function Plugin:RunPlug( ply, command, args )
	for k,v in ipairs( LA.Plugins ) do
		-- Is the plugin enabled?
		if (v.Enabled == true) then
			-- Does the plugin have any commands?
			if (v.Commands) then
				-- Does the plugin have the command?
				for k2,v2 in ipairs( v.Commands ) do
					if (command == self:upperfirst( v2 )) then
						-- Does the plugin have the function?
						if (v[command]) then
							LA:CallHook( v[command], v, ply, args )
							return true
						end
					end
				end
			end
		end
	end
	return false
end

function Plugin:ConsoleCommand( ply, args )
	local command = args[1]
	if (command and #command > 0) then
		command = self:upperfirst( command )
	
		table.remove( args, 1)
		local found = self:RunPlug( ply, command, args )
		if (!found) then
			LA:Message( ply, LA.Colors.Red, "Unknown command '" .. command .. "'." )
		end
	end
end
concommand.Add("la", function( ply, cmd, args ) Plugin:ConsoleCommand( ply, args ) end)

LA:AddPlugin( Plugin )