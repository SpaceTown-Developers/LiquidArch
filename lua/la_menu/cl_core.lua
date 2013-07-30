----------------------------------------------------------------
-- Menu
----------------------------------------------------------------
local Plugin = {}
Plugin.Name = "Menu"
Plugin.Author = "Goluch & Divran"
Plugin.Description = "Powerful menu interface."

----------------------------------------------------------------
-- Constants
----------------------------------------------------------------
Plugin.Commands = { }
Plugin.Categories = { }

-- Menu sizes
Plugin.Width = 700
Plugin.Height = 500
Plugin.TopBar = 22
Plugin.Border = 4


----------------------------------------------------------------
-- Useful Functions
----------------------------------------------------------------
function Plugin:Slide( Control )
	local Repos = false
	local X, Y = Control:GetPos( )
	local Speed = Control.SlideSpeed or 5
	
	if ( Control.TargetX ) then
		if ( Control.TargetX == X ) then
			Control.TargetX = nil
		else
			Repos = true
			X = X + math.Clamp( Control.TargetX - X, -Speed, Speed )
		end
	end
	
	if ( Control.TargetY ) then
		if ( Control.TargetY == Y ) then
			Control.TargetY = nil
		else
			Repos = true
			Y = Y + math.Clamp( Control.TargetY - Y, -Speed, Speed )
		end
	end
	
	if ( Repos ) then
		Control:SetPos( X, Y )
	end
end

function Plugin:ReSize( Control )
	local Speed = Control.SlideSpeed or 5
	local Rescale, Wide, Tall = false, Control:GetSize( )
	
	if ( Control.TargetW ) then
		if ( Control.TargetW == Wide ) then
			Control.TargetW = nil
		else
			Rescale = true
			Wide = Wide + math.Clamp( Control.TargetW - Wide, -Speed, Speed )
		end
	end
	
	if ( Control.TargetH ) then
		if ( Control.TargetH == Tall ) then
			Control.TargetH = nil
		else
			Rescale = true
			Tall = Tall + math.Clamp( Control.TargetH - Tall, -Speed, Speed )
		end
	end
	
	if ( Rescale ) then
		Control:SetSize( Wide, Tall )
	end
end

----------------------------------------------------------------
-- Create Menu
----------------------------------------------------------------
function Plugin:Initialize()
	self.Frame = vgui.Create( "DFrame" )
	self.Frame:SetSize( 0,0 )
	self.Frame:SetTitle( "Liquid Arch Menu" )
	self.Frame:SetDraggable( false )
	self.Frame:SetSizable( false )
	self.Frame:SetDeleteOnClose( false )
	self.Frame.btnMaxim:SetVisible( false )
	self.Frame.btnMinim:SetVisible( false )
	
	function self.Frame:Close( )
		Plugin:CloseMenu( )
	end
	
	self.Frame:MakePopup( )
	self.Frame:SetVisible( false )
	self.Frame.SlideSpeed = 10
	
	function self.Frame:Think( )
		Plugin:ReSize( self )
		Plugin:Slide( self )
	end
	
	self:PopulateMenu( )
end

----------------------------------------------------------------
-- Populate
----------------------------------------------------------------
function Plugin:PopulateMenu( )
	self:PlayerList( )
	self:CmdMenu( )
	self:TabControl( )
	self:SliderButton( )
end

----------------------------------------------------------------
-- Player List
----------------------------------------------------------------
local PlyLK = { }
local SelectedPly = { }
Plugin.SelectedPlayers = SelectedPly

local function UnSelect( Ply )
	if ( PlyLK[ Ply ] ) then
		PlyLK[ Ply ] = nil
		
		for I = 1, #SelectedPly do
			if SelectedPly[I] == Ply then
				return table.remove( SelectedPly, I )
			end
		end
	end
end
	
function Plugin:PlayerList( )
	self.PlayerWidth = 200
	self.PlayerBorder = 2
	self.PlayerHeight = self.Height - self.TopBar - self.Border * 2
	
	self.PlayerPanel = vgui.Create( "DPanel", self.Frame )
	self.PlayerPanel:SetPos( self.Border, self.TopBar + self.Border )
	self.PlayerPanel:SetSize( self.PlayerWidth, self.PlayerHeight )
	
	self.PlayerPanel.List = vgui.Create( "DPanelList", self.PlayerPanel )
	local List = self.PlayerPanel.List
	List:SetPos( self.PlayerBorder, self.PlayerBorder )
	List:SetSize( self.PlayerWidth - self.PlayerBorder * 2, self.PlayerHeight - self.PlayerBorder * 3 - 20 )
	
	function List:CreatePlayerButtons( )
		self:Clear( )
		
		for _, Ply in ipairs( player.GetAll( ) ) do
			local Btn = vgui.Create( "LAPlayerButton" )
			Btn:SetSize( Plugin.PlayerWidth - Plugin.PlayerBorder * 2, 50 )
			Btn:SetPlayer( Ply )
			
			function Btn:DoClick( )
				if ( !PlyLK[ Ply ] ) then
					PlyLK[ Ply ] = true
					SelectedPly[ #SelectedPly + 1 ] = Ply
				else
					UnSelect( Ply )
				end
				
				Plugin.Ctr_Frm:SetTitle( "Actions (" .. #SelectedPly .. " players)." )
			end
			
			function Btn:DoRightClick( )
				PlyLK, SelectedPly = { [Ply] = true }, { Ply }
				self.SelectedPlayers = SelectedPly
				
				local PlyName = Ply:GetName( )
				if #PlyName > 15 then PlyName = string.sub( PlyName, 0, 15 ) .. "..." end
			
				Plugin.Ctr_Frm:SetTitle( "Actions (" .. PlyName .. ")." )
				Plugin.Ctr_Frm:Open( )
			end
			
			function Btn:Think()
				if ( !IsValid( Ply ) or !Ply:IsPlayer( ) ) then
					UnSelect( Ply )
					self:Remove( )
				end
			end
			
			function Btn:IsSelected( )
				return PlyLK[ Ply ]
			end
			
			List:AddItem( Btn )
		end
	end
end

function Plugin:GetSteamIDs( )
	local Ids = { }
		
	for _, Ply in pairs( SelectedPly ) do
		local ID = Ply:SteamID( )
		
		if ( ID == "NULL" ) then ID = "BOT" end
		
		Ids[ #Ids + 1 ] = ID
	end
	
	return Ids
end

----------------------------------------------------------------
-- Command Menu
----------------------------------------------------------------
function Plugin:CmdMenu( )
	-- Create Controls
		local Btn = vgui.Create( "DButton", self.PlayerPanel )
		local Ctr = vgui.Create( "DFrame", self.PlayerPanel )
		local Arg = vgui.Create( "DPanel", Ctr )
		local Cmd = vgui.Create( "DPanelList", Ctr )
	
	-- Btn: Opens Ctr (Player Controls)
		Btn:SetText( "Player Commands" )
		Btn:SetPos( self.PlayerBorder, self.PlayerHeight - 20 - self.PlayerBorder )
		Btn:SetSize( self.PlayerWidth - self.PlayerBorder * 2, 20 )
		
		function Btn:DoClick( )
			if ( #SelectedPly > 0 ) then
				Ctr:Open( )
			else
				Btn:SetText( "Select a player first!" )
				timer.Simple( 3, function( )
					Btn:SetText( "Player Commands" )
				end )
			end
		end
	
	-- Ctr: Organises the Commands and Args window
		Ctr._Open = false
		Ctr:SetPos( -self.PlayerWidth - self.PlayerBorder, self.PlayerBorder )
		Ctr:SetSize( self.PlayerWidth - (self.PlayerBorder * 2), self.PlayerHeight - (self.PlayerBorder * 2) - 22 )
	 
		Ctr:SetTitle( "Actions" )
		Ctr:SetDraggable( false )
		Ctr:SetSizable( false )
		Ctr:ShowCloseButton( true )
		Ctr.btnMaxim:SetVisible( false )
		Ctr.btnMinim:SetVisible( false )
		
		function Ctr:Think( )
			Plugin:Slide( self )
			Plugin:ReSize( Arg )
			Plugin:Slide( Cmd )
			Plugin:ReSize( Cmd )
		end
		
		function Ctr:Close( )
			self:HideArg( )
			self.TargetX = -Plugin.PlayerWidth - Plugin.PlayerBorder
		end
		
		function Ctr:Open( )
			self.TargetX = Plugin.PlayerBorder
		end
		
		function Ctr:ShowArg( Height )
			-- Rescale Arg
				Arg.TargetH = Height
				Arg:SetPos( Plugin.PlayerBorder, 22 + Plugin.PlayerBorder )
				
			-- Move and Rescale Cmd
				Cmd.TargetY = Height + 22 + ( Plugin.PlayerBorder * 2)
				Cmd.TargetH = self:GetTall( ) - Height - 22 - ( Plugin.PlayerBorder * 3)
				
			-- Menu is open =D
				self._Open = true
		end
		
		function Ctr:HideArg( )
			if ( self._Open ) then
				-- Rescale Arg
					Arg.TargetH = 0
				
				-- Move and Rescale Cmd
					Cmd.TargetY = 22 + ( Plugin.PlayerBorder * 2)
					Cmd.TargetH = self:GetTall( ) - 22 - ( Plugin.PlayerBorder * 3)
				
				-- Menu is closed =D
					self._Open = false
			end
		end
	
	-- Arg: Requests user input
		Arg:SetPos( self.PlayerBorder, 22 + self.PlayerBorder )
		Arg:SetSize( Plugin.PlayerWidth, 0 )
		
		function Arg:Paint( ) end
		
	-- Cmd: Lists avalible commands
		Cmd:SetSpacing( self.PlayerBorder )
		Cmd:EnableVerticalScrollbar( true )
		Cmd:SetPos( self.PlayerBorder, 22 + self.PlayerBorder )
		Cmd:SetSize( Ctr:GetWide( ) - (self.PlayerBorder * 2), Ctr:GetTall( ) - (22 + (Plugin.PlayerBorder * 2)) )
		
		function Cmd:CreateCommandButtons( )
			self:Clear( true )
			
			local Collapsibles = { } 
			Plugin.CategoryCollapsibles = Collapsibles
			
			-- Create a collapsible category for each category
				for Category, Tbl in pairs( Plugin.Categories ) do
					local Catg = vgui.Create( "DCollapsibleCategory", self )
					Catg:SetSize( self:GetWide( ) - Plugin.PlayerBorder * 2, 50 )
					Catg:SetExpanded( 0 )
					Catg:SetLabel( Category )
					
					Collapsibles[ #Collapsibles + 1 ] = Catg
					
					function Catg.Header:OnMousePressed( )
						for K, V in ipairs( Collapsibles ) do
							if ( V:GetExpanded( ) and V.Header != self ) then V:Toggle( ) end
							if ( !V:GetExpanded( ) and V.Header == self ) then V:Toggle( ) end
						end
					end
				
				-- Create a list inside each category
					local List = vgui.Create( "DPanelList" )
					List:SetWide( Catg:GetWide( ) )
					List:SetAutoSize( true )
					List:SetSpacing( 2 )
					List:EnableHorizontal( false )
					List:EnableVerticalScrollbar( false )
					
					for _, Cmd in pairs( Tbl ) do
						if ( !Cmd.Execute ) then
							local Btn = Plugin:AddCmdButton( Cmd.Command, Cmd.Command )
							List:AddItem( Btn )
						else
							Cmd.Execute( Plugin, List )
						end
					end
					
					Catg:SetContents( List )
					self:AddItem( Catg )
				end
		end
		
	-- Make accesible!
		self.Ctr_Frm = Ctr
		self.Ctr_Lst = Cmd
		self.Ctr_Arg = Arg
		self.Ctr_Btn = Btn
end

----------------------------------------------------------------
-- Slider Button
----------------------------------------------------------------
function Plugin:SliderButton( )
	self.MinWidth = self.PlayerWidth + self.Border * 3 + 20
	self.MaxWidth = self.Width
	
	-- Resize
	local Btn = vgui.Create( "DButton", self.Frame )
	
	Btn:SetText( ">" )
	Btn:SetPos( self.MinWidth - 20 - self.Border, self.Border + self.TopBar )
	Btn:SetSize( 20, self.Height - self.Border * 2 - self.TopBar )
	Btn.SlideSpeed = 10
	Btn.Open = false
	
	function Btn:DoClick()
		if (self.Open) then
			Plugin:CloseTabs( )
		else
			Plugin:OpenTabs( )
		end
	end
	
	function Btn:Think( )
		Plugin:Slide( self )
	end
	
	self.SliderButton = Btn
end

function Plugin:CloseTabs( )
	local Frm = self.Frame
	local Btn = self.SliderButton
	
	if ( !Btn.Target and Btn.Open ) then
		Btn.Open = false
		Btn:SetText( ">" )
		
		Frm.TargetW = self.MinWidth
		Btn.TargetX = self.MinWidth - 20 - self.Border
		
		timer.Simple( 0.5, function( )
			self.TabPanel:SetVisible( false )
		end )
	end
end

function Plugin:OpenTabs( )
	local Frm = self.Frame
	local Btn = self.SliderButton
	
	if ( !Btn.Target and !Btn.Open ) then
		Btn.Open = true
		Btn:SetText("<")
		
		Frm.TargetW = self.MaxWidth
		Btn.TargetX = self.MaxWidth - 20 - self.Border
		
		self.TabPanel:SetVisible( true )
	end
end

----------------------------------------------------------------
-- Commands
----------------------------------------------------------------
local function Close( )
	PlyLK, SelectedPly = { }, { }
	Plugin.Ctr_Frm:SetTitle( "Actions" )
	Plugin.Ctr_Frm:Close( )
	Plugin.Ctr_Frm:HideArg( )
end

function LA:AddCommand( Command, Category, Function )
	if ( Command and Category ) then
		local Tbl = { Command = Command, Category = Category, Execute = Function }
		
		local CatTbl = Plugin.Categories[Category]
		if ( !CatTbl ) then
			CatTbl = { }
			Plugin.Categories[Category] = CatTbl
		end
		
		CatTbl[ #CatTbl + 1 ] = Tbl
		Plugin.Commands[ #Plugin.Commands + 1 ] = Tbl
	end
end

function Plugin:AddButton( Name, Function, W, H )
	local Btn = vgui.Create("DButton")
	
	Btn:SetText( Name )
	Btn:SetSize( W or 48, H or 20 )
	
	function Btn:DoClick( )
		Function( Plugin, SelectedPly )
		Close( )
	end
	
	return Btn
end

function Plugin:AddCmdButton( Name, Command, W, H )
	return self:AddButton( Name, function( Plug, Players )
		RunConsoleCommand( "la", Command, unpack( Plugin:GetSteamIDs( ) ) )
	end , W, H )
end

function Plugin:AddMenuButton( Name, Function, W, H )
	local Wide, Tall = self.Ctr_Arg:GetWide( ) - (self.PlayerBorder * 2), 200
	
	local Panel = vgui.Create( "DPanel", self.Ctr_Arg )
	Panel:SetPos( Wide, 0 ) 
	Panel:SetSize( Wide, Tall )
	
	function Panel:Paint( ) end
	
	Tall = Function( Panel, Wide, Close ) or Tall -- Change the Height =D
	
	return self:AddButton( Name, function( Plugin, SteamIds )
		if ( Plugin.Ctr_Active ) then
			Plugin.Ctr_Active:SetPos( Plugin.Ctr_Arg:GetWide( ), 0 )
		end
		
		Panel:SetPos( 0, 0 )
		Panel:SetSize( Wide, Tall )
		
		Plugin.Ctr_Active = Panel
		Plugin.Ctr_Frm:ShowArg( Tall )
		
		local Count = #self.SelectedPlayers
		
		if ( Count == 1 ) then
			local PlyName = self.SelectedPlayers[1]:GetName( )
			if #PlyName > 15 then PlyName = string.sub( PlyName, 0, 15 ) .. "..." end
	
			Plugin.Ctr_Frm:SetTitle( Name .. " " .. PlyName )
		else
			Plugin.Ctr_Frm:SetTitle( Name .. " (" .. Count .. " Players)" )
		end
		
	end , W, H )
end

function Plugin:SortButtons( Parent, ... )
	local Pnl = vgui.Create( "DPanel", Parent )
	Pnl:SetSize( Parent:GetWide( ), 20 )
	Pnl:SetPos( 0, 0 )
	
	function Pnl:Paint( ) end
	
	local Children = {...}
	local MaxChildren = #Children
	
	for I = 1, MaxChildren do
		local Child = Children[I]		
		Child:SetParent( Pnl )
		Child:SetSize( Pnl:GetWide( ) / math.ceil( MaxChildren ), 20 )
		Child:SetPos( Pnl:GetWide( ) * ( math.ceil( I - 1 ) / math.ceil( MaxChildren ) ) + math.ceil( I ), 0 )
	end 
	
	return Pnl, Children
end

----------------------------------------------------------------
-- Tabs
----------------------------------------------------------------
function Plugin:TabControl( )
	self.TabPanel = vgui.Create( "DPanel", self.Frame )
	self.TabPanel:SetPos( self.PlayerWidth + self.Border * 2, self.Border + self.TopBar )
	self.TabPanel:SetSize( self.Width - self.PlayerWidth - self.Border * 4 - 20, self.Height - self.Border * 2 - self.TopBar )
	function self.TabPanel:Paint( ) end
	self.TabPanel:SetVisible( false )
	
	self.Tabs = vgui.Create( "DPropertySheet", self.TabPanel )
	self.Tabs:SetPos( 0, 0 )
	self.Tabs:StretchToParent( 2, 2, 2, 2 )
end

function LA:AddMenuTab( Name, Panel, Icon, NoStretchX, NoStretchY, Tooltip )
	if ( Panel ) then
		Plugin.Tabs:AddSheet( Name or "", Panel, Icon, NoStretchX, NoStretchY, Tooltip )
	end
end

-- REMOVE THIS LATER!!!!!!!!!
timer.Simple( 1, function() 
	LA:AddMenuTab( "Example Tab", vgui.Create("DPanel"), nil, false,false, "Example Tab" ) 
	LA:AddMenuTab( "Example Tab 2", vgui.Create("DPanel"), nil, false,false, "Example Tab 2" ) 	
end)

----------------------------------------------------------------
-- Opening & Closing
----------------------------------------------------------------
function Plugin:OpenMenu( )
	if ( !self.MenuOpen and LA:CheckAllowed( LocalPlayer( ), Plugin, "Menu" ) ) then
		-- Reload player buttons
		self.PlayerPanel.List:CreatePlayerButtons( )
		
		-- Reload command list
		self.Ctr_Lst:CreateCommandButtons( )
		
		-- Open the menu
		self:CloseTabs( )
		self.Ctr_Frm:Close( )
		self.Frame.TargetX = 50
		self.Frame:SetVisible(true)
		self.Frame:SetSize( Plugin.MinWidth, Plugin.Height )
		self.Frame:SetPos( -Plugin.MinWidth, (ScrH( ) - Plugin.Height) / 2 )
		
		--The menu has opened
		self.MenuOpen = true
	else
		LA:Message( unpack( LA.NotAllowed ) )
	end
end

function Plugin:CloseMenu( )
	if ( self.MenuOpen ) then
		self:CloseTabs( )
		self.MenuOpen = false
		self.Frame.TargetX = -self.Frame:GetWide( )
	
		timer.Simple( 0.25, function( )
			self.Frame:SetVisible( false )
		end )
	end
end

----------------------------------------------------------------
-- Console Commands
----------------------------------------------------------------
-- Toggle command
concommand.Add( "la_menu", function()
	if ( Plugin.MenuOpen ) then
		Plugin:CloseMenu()
	else
		Plugin:OpenMenu()
	end
end )

-- Hold Key
concommand.Add( "+la_menu", function() Plugin:OpenMenu() end )
concommand.Add( "-la_menu", function() Plugin:CloseMenu() end )

----------------------------------------------------------------
-- Chat command message!
----------------------------------------------------------------
usermessage.Hook( "LA_OpenMenu", function() Plugin:OpenMenu() end )

LA:AddPlugin( Plugin )