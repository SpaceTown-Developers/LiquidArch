----------------------------------------------------------------
-- Menu
----------------------------------------------------------------
local Plugin = {}
Plugin.Name = "Menu"
Plugin.Author = "Rusketh"
Plugin.Description = "Powerful menu interface."
Plugin.Commands = {"Menu"}
Plugin.Category = "Menu"

if SERVER then
	resource.AddSingleFile( "materials/gui/fugue/arrow-return-180-left.png" )
	resource.AddSingleFile( "materials/gui/fugue/chevron-small-expand.png" )

	function Plugin:Menu( ply, args )
		if (LA:CheckAllowed( ply, Plugin, "Menu" )) then
			umsg.Start("LA_OpenMenu", ply ) umsg.End()	
		else
			LA:Message( ply, unpack( LA.NotAllowed ) )
		end
	end

	return LA:AddPlugin( Plugin )
end

----------------------------------------------------------------
-- Panel Modifier
----------------------------------------------------------------
local MenuSpeed = 15

local function SlideTo( self, X, Y, Visibility )
	self.HorizontalMovment = X
	self.VerticalMovment = Y
	self.MovmentVisibility = Visibility 
end

local function SlideThink( self )
	local X, Y = self:GetPos( )
	
	if self.VerticalMovment and self.VerticalMovment ~= Y then
		Y = Y + math.Clamp( self.VerticalMovment - Y, -MenuSpeed, MenuSpeed )
		return self:SetPos( X, Y )
	elseif self.HorizontalMovment and self.HorizontalMovment ~= X then
		X = X + math.Clamp( self.HorizontalMovment - X, -MenuSpeed, MenuSpeed )
		return self:SetPos( X, Y )
	elseif self.MovmentVisibility ~= nil then
		self:SetVisible( self.MovmentVisibility )
	end

	self.VerticalMovment = nil
	self.HorizontalMovment = nil
	self.MovmentVisibility = nil
end

function Plugin:MakeSlidingPanel( Element, Parent )
	local Pnl = vgui.Create( Element, Parent )
	hook.Add( "Think", Pnl, SlideThink )
	Pnl.SlideTo = SlideTo
	return Pnl
end

----------------------------------------------------------------
-- Constants
----------------------------------------------------------------
local MenuWidth = 300
local MenuHeight = 500

----------------------------------------------------------------
-- Menu Creation Helper
----------------------------------------------------------------
function Plugin:BuildMenu( )
	if IsValid( self.MainPanel ) then return end --self.MainPanel:Remove( ) end

	local Frame = self:MakeSlidingPanel( "DFrame" )
	Frame:SetSize( MenuWidth, MenuHeight )
	Frame:SetTitle( "Liquid Arch Menu" )
	Frame:SetDraggable( false )
	Frame:SetSizable( false )
	Frame:SetDeleteOnClose( false )
	
	Frame.btnMaxim:SetVisible( false )
	Frame.btnMinim:SetVisible( false )

	Frame.BtnOpts = vgui.Create( "DImageButton", Frame )
	Frame.BtnOpts:SetImage( "/gui/fugue/chevron-small-expand.png" )
	Frame.BtnOpts:SetPos( Frame:GetWide( ) - 55, 2 )
	Frame.BtnOpts:SetSize( 25, 25 )
	
	Frame.BtnOpts.DoClick = function( ) Plugin:ShowOptions( ) end

	Frame:MakePopup( )
	Frame:SetVisible( false )
	Frame:SetPos( -MenuWidth, (ScrH( ) - MenuHeight) * 0.5 )
	
	Frame.Close = function( )
		self:CloseMenu( )
	end

	self.MainPanel = Frame

	hook.Run( "LA_BuildMenu", self )

	self:BuildWidgets( Frame )
end

----------------------------------------------------------------
-- GetMenu
----------------------------------------------------------------
function Plugin:GetMenu( )
	if IsValid( self.MainPanel ) then return self.MainPanel end

	self:BuildMenu( )

	return self.MainPanel
end

----------------------------------------------------------------
-- Menu: Open / close
----------------------------------------------------------------
function Plugin:OpenMenu( )
	if self.MenuOpen then return end

	self.MenuOpen = true
	self:GetMenu( ):SetVisible( true )
	self:GetMenu( ):SlideTo( 5, nil, nil )
	hook.Run( "LA_OpenMenu", self )
end

function Plugin:CloseMenu( )
	if !self.MenuOpen then return end

	self.MenuOpen = false
	self:GetMenu( ):SlideTo( -MenuWidth, nil, false )
	hook.Run( "LA_CloseMenu", self )
end

----------------------------------------------------------------
-- Menu: Widgets
----------------------------------------------------------------
Plugin.Widgets = { }

function Plugin:AddWidget( Icon, Name, Function, Element )
	self.Widgets[Name] = { Icon = Icon, Name = Name, Build = Function, Element = Element or "DPanel" }
end

function Plugin:BuildWidgets( Frame )
	local Wide, Tall = MenuWidth - 10, MenuHeight - 34

	Frame.Canvas = vgui.Create( "DPanel", Frame )
	Frame.Canvas:SetPos( 5, 25 + 5 )
	Frame.Canvas:SetSize( Wide, Tall )
	Frame.Canvas:SetPaintBackground( false )

	for _, Widget in pairs( self.Widgets ) do
		Widget.Pnl = self:MakeSlidingPanel( Widget.Element, Frame.Canvas )
		Widget.Build( Widget.Pnl, Wide, Tall )
		Widget.Pnl:SetSize( Wide, Tall )
		Widget.Pnl:SetPos( -Wide, 0 )
	end
end

function Plugin:GetCanvas( )
	return self:GetMenu( ).Canvas
end

function Plugin:GetActiveWidget( )
	if !IsValid( self.ActiveWidget ) then return end
	return self.ActiveWidget.Widget
end

function Plugin:SetActiveWidget( Name, NoSlide )
	if IsValid( self.ActiveWidget ) then
		if !NoSlide then
			self.ActiveWidget:SlideTo( self:GetCanvas( ):GetWide( ), nil, nil )
		else
			self.ActiveWidget:SetPos( self:GetCanvas( ):GetWide( ), 0 )
		end
	end
	
	local Widget = self.Widgets[Name]
	self.ActiveWidget = nil

	if !Widget or !IsValid( Widget.Pnl ) then return end

	if !NoSlide then
		Widget.Pnl:SetPos( -self:GetCanvas( ):GetWide( ), 0 )
		Widget.Pnl:SlideTo( 0, nil, nil )
	else
		Widget.Pnl:SetPos( 0, 0 )
		Widget.Pnl:SlideTo( nil, nil, nil )
	end

	self.ActiveWidget = Widget.Pnl
end

function Plugin:ShowOptions( )
	local Menu = DermaMenu( )

	for _, Widget in pairs( self.Widgets ) do
		if Widget.Name == "Actions" then continue end
		Menu:AddOption( Widget.Name, function( ) Plugin:SetActiveWidget( Widget.Name ) end )
	end

	Menu:Open( )
end

----------------------------------------------------------------
-- Player List
----------------------------------------------------------------
Plugin:AddWidget( "", "Players", function( Pnl, Wide, Tall )
	local function Build( Pnl )
		DScrollPanel.Clear( Pnl )

		local Categorys = { }

		for _, Rank in pairs( LA.Ranks ) do
			Categorys[Rank.Name] = Pnl:Add( Rank.Name .. "('s)" )
		end

		for _, Target in pairs( player.GetAll( ) ) do
			local Category = Categorys[ LA:GetRank( Target ).Name ]

			local Btn = Category:Add( "DButton" )
			Btn:SetTall( 30 )
			Btn:SetText( Target:Name( ) )

			Btn.m_Image = Btn:Add( "AvatarImage" )
			Btn.m_Image:SetPlayer( Target )
			Btn.m_Image:SetSize( 26, 26 )
			Btn:InvalidateLayout( )

			Btn.DoClick = function( )
				Plugin:ShowCommands( Target )
			end
		end

		for _, Category in pairs( Categorys ) do
			if Category:ChildCount( ) == 1 then
				Category:Remove( )
			end
		end

		Pnl:InvalidateLayout( true )

		Plugin:SetActiveWidget( "Players", true )
	end

	hook.Add( "LA_OpenMenu", Pnl, Build )

	Build( Pnl )

end, "DCategoryList" )


----------------------------------------------------------------
-- Player Command List
----------------------------------------------------------------
Plugin.GetPlayer = function( ) return Plugin.Player end
Plugin.Categories = { }

function Plugin:AddCommand( Cat, Function, Element )
	local Category = self.Categories[Cat]
	
	if !Category then
		Category = { }
		self.Categories[Cat] = Category
	end

	table.insert( Category, { Build = Function, Element = Element or "DButton" } )
end

function Plugin:AddSimpleCommand( Cat, Name, Action, ... )
	local Extra = { ... }
	self:AddCommand( Cat, function( Btn, Wide, GetPlayer, Close )
		Btn:SetText( Name )
		Btn.DoClick = function( )
			Close( )
			RunConsoleCommand( "la", Action or Name, GetPlayer( ):SteamID( ), unpack( Extra ) )
		end
	end )
end

----------------------------------------------------------------
-- Command Widget
----------------------------------------------------------------
Plugin:AddWidget( "", "Actions", function( Pnl, Wide, Tall )
	Plugin.CmdList = Pnl

	Pnl.Close = Pnl:Add( "DImageButton" )
	Pnl.Close:SetImage( "gui/fugue/arrow-return-180-left.png" )
	Pnl.Close:SetToolTip( "Return to players." )
	Pnl.Close.DoClick = function( ) Plugin:SetActiveWidget( "Players" ) end
	
	Pnl.Label = Pnl:Add( "DLabel" )
	Pnl.Label:SetTextColor( Color( 0, 0, 0, 255 ) )

	Pnl.SetTitle = function( _, Text ) Pnl.Label:SetText( Text ) end
	Pnl:SetTitle( "Actions" )
	Pnl:DockPadding( 5, 24 + 5, 5, 5 )

	function Pnl.PerformLayout( )
		Pnl.Label:SetPos( 8, 2 )
		Pnl.Label:SetSize( Pnl:GetWide( ) - 25, 20 )
		Pnl.Close:SetSize( 20, 20 )
		Pnl.Close:SetPos( Pnl:GetWide( ) - 35, 5 )
	end

	local CatList = vgui.Create( "DCategoryList", Pnl )
	CatList:Dock( FILL )

	for Cat, Cmds in pairs( Plugin.Categories ) do
		local List = CatList:Add( Cat )
		List:SetWide( Wide )

		for _, CmdTbl in pairs( Cmds ) do
			CmdTbl.Pnl = List:Add( CmdTbl.Element )
			CmdTbl.Build( CmdTbl.Pnl, Wide, Plugin.GetPlayer, Pnl.Close.DoClick )
		end
	end

end, "DPanel" )

function Plugin:ShowCommands( Player )
	self.Player = Player
	self.CmdList:SetTitle( "Actions: " .. Player:Name( ) )
	self:SetActiveWidget( "Actions" )
	hook.Run( "LA_ShowCommands", Player )
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
concommand.Add( "+la_menu", function( ) Plugin:OpenMenu( ) end )
concommand.Add( "-la_menu", function( ) Plugin:CloseMenu( ) end )

----------------------------------------------------------------
-- Chat command message!
----------------------------------------------------------------
usermessage.Hook( "LA_OpenMenu", function( ) Plugin:OpenMenu( ) end )

LA:AddPlugin( Plugin )