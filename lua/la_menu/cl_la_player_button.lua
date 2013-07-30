local PANEL = { }

/*---------------------------------------------------------
	INIT
---------------------------------------------------------*/
function PANEL:Init()
	
	self:SetContentAlignment( 5 )
	self:SetMouseInputEnabled( true )
	self:SetKeyboardInputEnabled( true )
	self:SetCursor( "hand" )
	self:SetText( "" )
	
	self.Avatar = vgui.Create( "AvatarImage", self )
	self.Avatar:SetSize( 40, 40 )
	self.Avatar:SetPos( 5, 5 )
	self.Avatar:SetMouseInputEnabled( false )
	
	self.NLabel = vgui.Create( "DLabel", self )
	self.NLabel:SetFont( "chatfont" )
	self.NLabel:SetPos( 50, 5 )
	self.NLabel:SetText( "" )
	
	self.Icon = vgui.Create( "DImage", self )
	self.Icon:SetSize( 16, 16 )
	self.Icon:SetPos( 52, 27 )
	
	self.RLabel = vgui.Create( "DLabel", self )
	self.RLabel:SetFont( "Default" )
	self.RLabel:SetPos( 75, 30 )
	
	self:SetToolTip( "Click to select/unselect\nRight click for Actions." )
end

/*---------------------------------------------------------
	Rank
---------------------------------------------------------*/
function PANEL:SetPlayer( Ply )
	self.Player = Ply
	self.Avatar:SetPlayer( Ply )
	
	-- Name Label
	local Name = Ply:GetName( )
	if #Name > 15 then
		Name = string.sub( Name, 0, 15 ) .. "..." 
	end
	
	self.NLabel:SetText( Name )
	self.NLabel:SizeToContents( ) 
	
	local Rank = LA:GetRank( self.Player )
	self.NLabel:SetTextColor( Color( 50, 50, 255 ) ) -- Rank.Color )
	
	-- Rank Icon
	if ( Ply:GetNWString( "LA_Rank" ) == "Owner" ) then
		self.Icon:SetImage( "gui/silkicons/user_suit.png" )
	elseif ( Ply:IsSuperAdmin( ) ) then
		self.Icon:SetImage( "gui/silkicons/user_green.png" )
	elseif ( Ply:IsAdmin( ) ) then
		self.Icon:SetImage( "gui/silkicons/user_orange.png" )
	else
		self.Icon:SetImage( "materials/gui/silkicons/user.vtf" ) //user_red.png" )
	end
	
	
	self.RLabel:SetText( Rank.Name )
	self.RLabel:SizeToContents( ) 
	self.RLabel:SetTextColor( Rank.Color )
end

derma.DefineControl( "LAPlayerButton", "A standard Button", PANEL, "DButton" )