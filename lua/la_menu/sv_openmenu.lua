----------------------------------------------------------------
-- Open Menu
----------------------------------------------------------------
local Plugin = {}
Plugin.Name = "OpenMenu"
Plugin.Author = "Divran"
Plugin.Description = "Opens the menu"
Plugin.Commands = {"Menu"}

Plugin.Category = "Menu"

function Plugin:Menu( ply, args )
	if (LA:CheckAllowed( ply, Plugin, "Menu" )) then
		umsg.Start("LA_OpenMenu", ply ) umsg.End()	
	else
		LA:Message( ply, unpack( LA.NotAllowed ) )
	end
end

LA:AddPlugin( Plugin )