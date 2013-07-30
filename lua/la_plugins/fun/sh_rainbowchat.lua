----------------------------------------------------------------
-- Rainbow Chat
----------------------------------------------------------------
local Plugin = {}
Plugin.Name = "Rainbow Chat"
Plugin.Author = "Divran"
Plugin.Description = "PRETTY COLORS!"
Plugin.Commands = { "Rbc", "Rainbowchat" }

Plugin.Help = {}
Plugin.Help["Rbc"] = "[message]"
Plugin.Help["Rainbowchat"] = "[message]"

Plugin.Category = "Fun"

Plugin.Privs = { "Rainbow Chat" }

if (SERVER) then
	function Plugin:Rbc( ply, args )
		if (LA:CheckAllowed( ply, Plugin, "Rainbow Chat" )) then
			local msg = table.concat( args, " " )
			umsg.Start("LA_RainbowChat")
				umsg.Char(ply:EntIndex()-128)
				umsg.String(msg)
			umsg.End()
		end
	end
	
	function Plugin:Rainbowchat( ply, args ) self:Rbc( ply, args ) end
else
	local function RecieveRainbow( um )
		local tbl = {}
		local ply = player.GetByID(um:ReadChar()+128) -- Get the player
		
		table.insert( tbl, team.GetColor( ply:Team() ) ) -- Get the player's team
		table.insert( tbl, ply:Nick() ) -- Name
		table.insert( tbl, LA.Colors.White )
		table.insert( tbl, ": " )

		local msg = um:ReadString()
		local len = string.len(msg)
		local num = 0
		
		-- Loop through the letters and add a color in between each
		for match in msg:gmatch( "." ) do
			num = num + 360/len
			local col = HSVToColor( num, 1, 1 )
			table.insert( tbl, col )
			table.insert( tbl, match )
		end
		
		chat.AddText( unpack( tbl ) )
	end
	usermessage.Hook( "LA_RainbowChat", RecieveRainbow )
end

LA:AddPlugin( Plugin )