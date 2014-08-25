----------------------------------------------------------------
-- Autocomplete
----------------------------------------------------------------
local Plugin = {}
Plugin.Name = "Autocomplete"
Plugin.Author = "Divran"
Plugin.Description = "Displays hints as you type commands."

-- Credits to Overv

Plugin.Prints = {}
Plugin.Chatting = false
Plugin.Timer = 0

------------------------
-- Changeable variables
------------------------
-- BG
Plugin.Background = surface.GetTextureID( "vgui/gradient_down" )

-- Pos
local x, y = chat.GetChatBoxPos()
Plugin.X = x + ScrW() * 0.03875

local add = ScrH() / 4 + 5
Plugin.StartY = y + add / 2
Plugin.Y = add / 2

-- Width/Height
Plugin.W = 550 
Plugin.H = 95

-- Alpha
Plugin.StartA = 50
Plugin.A = 205

------------------------
-- Draw it:
------------------------

function Plugin:DrawPanel()
	local X = self.X
	local Y = self.StartY + self.Timer / 100 * self.Y
	local W = self.W
	local H = self.H--self.Timer / 100 * self.H
	local A = self.StartA + self.Timer / 100 * self.A
	
	surface.SetFont("ChatFont")
	surface.SetTexture(self.Background)
	surface.SetDrawColor( 0,0,0,A )
	surface.DrawOutlinedRect( X, Y, W, H )
	surface.SetDrawColor( 0,0,0, A / 1.45 )
	surface.DrawTexturedRect( X, Y, W, H )
	if (#self.Prints > 0) then
		for k,v in ipairs( self.Prints ) do
			surface.SetTextColor( LA.Colors.Gold )
			surface.SetTextPos( X + 10, Y + (k-1) * 16.5 + 3)
			surface.DrawText( v )
		end
	end
end

------------------------
-- HUDPaint
------------------------

function Plugin:HUDPaint()
	if (self.Chatting and #self.Prints>0) then
		if (self.Timer < 100) then 
			self.Timer = math.Clamp(self.Timer + RealFrameTime() * 400,0,100)
		end
		self:DrawPanel()
	elseif (!self.Chatting or #self.Prints == 0) then
		if (self.Timer > 0) then 
			self.Timer = math.Clamp(self.Timer - RealFrameTime() * 400,0,100)
			self:DrawPanel()
		end
	end
end

function Plugin:ChatTextChanged( text )
	self.Prints = {}
	if (string.Left( text, 1 ) == "!") then
		local command = string.match( text, "%w+" )
		if (#LA.PluginInfo>0 and command and #command>0) then
			for k,v in ipairs( LA.PluginInfo ) do
				if (v.Commands) then
					for _,v2 in ipairs( v.Commands ) do
						if (string.Left( string.lower(v2), #command ) == string.lower(command) ) then
							local help = ""
							if (v.Help and v.Help[v2]) then help = v.Help[v2] end
							table.insert( self.Prints, "!" .. v2 .. " " .. help )
							if (#self.Prints >= 5) then break end
						end
					end
					if (#self.Prints >= 5) then break end
				end
			end
		end
		
		/* Maybe...
		table.sort( self.Prints, function( a, b )
			local cmd1 = string.match(a, "%w+" )
			local cmd2 = string.match(a, "%w+" )
			return cmd1 < cmd2
		end )
		*/
	end
end

function Plugin:StartChat() self.Chatting = true end
function Plugin:FinishChat() self.Chatting = false end

LA:AddPlugin( Plugin )