/* __     __     _      _   _     __    _   _
  / _\   /  \   | |    | | | |   / _\  | |_| |
 ( |_n  ( () )  | |_   | |_| |  ( |_   |  _  |
  \__/   \__/   |___|  |_____|   \__/  |_| |_|

	Chat Display Box:
		Provides a loverly chat box.
	Features:
		Icons
		Highlight
		Copy/Paste
		Fade animations
*/

PANEL = {}

/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:Init()

	//
	// We're going to draw these ourselves in 
	// the skin system - so disable them here.
	// This will leave it only drawing text.
	//
	self:SetPaintBorderEnabled( false )
	self:SetPaintBackgroundEnabled( false )
	
	//
	// These are Lua side commands
	// Defined above using AccessorFunc
	//
	self:SetDrawBorder( false )
	self:SetDrawBackground( false )
	self:SetEnterAllowed( false )
	self:SetUpdateOnType( false )
	self:SetNumeric( false )
	self:SetMultiline( true )
	
	// Nicer default height
	self:SetTall( 20 )
	
	// Clear keyboard focus when we click away
	self.m_bLoseFocusOnClickAway = true
	
	// Beam Me Up Scotty
	self:SetCursor( "beam" )
	
	// SetSpecial Entry
	self.Entry = ""
	
	self:AllowInput( false )
	
	// Colors
	self.m_colHighlight = Color(0,0,0,150);
	
	// Show all
	self.ShowAll = false;
	self.Fades = {};
end


/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:OnKeyCodeTyped( code )
	return;
end

/*---------------------------------------------------------
   Name: Exploder
---------------------------------------------------------*/
function PANEL:Exploder( STR )
	local Out = {};
	local Pocket = "";
	local Phase;
	for L in string.gmatch( STR, "." ) do
		if ( L == "[" ) then
			table.insert( Out , Pocket );
			Phase = true;
			Pocket = L;
		elseif ( L == "]" ) and ( Phase ) then
			Pocket = Pocket .. L;
			table.insert( Out , Pocket );
			Pocket = "";
			Phase = nil;
		else
			Pocket = Pocket .. L;
		end
	end
	table.insert( Out , Pocket );
	return Out;
end

/*---------------------------------------------------------
   Name: SetEntry
---------------------------------------------------------*/
function PANEL:SetEntry( STR )
	local Value = "";
	for __,Word in pairs ( self:Exploder( STR ) ) do
		local Command, Perams = string.match( Word, "%[(.+)=(.+)%]" );
		if ( Command ) and ( Perams ) then
			local ToReplaceWith = "";
			if ( Command == "icon" ) then
				ToReplaceWith = "     "; --Space * 5 aka W=16
			end
			local NewWord = string.gsub( Word , "%[(.+)=(.+)%]" , ToReplaceWith );
			Value = Value .. NewWord;
		else
			Value = Value .. Word .. " ";
		end
	end
	self:SetText( Value );
	self.Entry = STR;
end

/*---------------------------------------------------------
   Name: AddText
---------------------------------------------------------*/
function PANEL:AddText( STR )
	return self:SetEntry( self.Entry .. "\n" .. STR );
end

/*---------------------------------------------------------
   Name: AddTable
---------------------------------------------------------*/
function PANEL:AddTable( Table )

	local STR = "";
	for _ , V in pairs (Table) do
		local T = string.lower( type(V) )
		if ( T == "string" ) then
			STR = STR .. V;
			
		elseif ( T == "table" ) then --Color
			local A = V.a or 255;
			STR = STR .. "[color="  .. V.r .. "," .. V.g .. "," .. V.b .. "," .. A .. "]";
			
		elseif ( T == "player" ) then
			local A = V.a or 255;
			STR = STR .. V:Nick();
			
		end
	end
	return self:AddText( STR );
	
end

/*---------------------------------------------------------
   Name: AddSomthing
---------------------------------------------------------*/
function PANEL:AddSomthing( ... )
	return self:AddTable( { ... } );
end

/*---------------------------------------------------------
   Name: GetMaterial
---------------------------------------------------------*/
PANEL.Materials = {};
function PANEL:GetMaterial( Mat )
	if (!Mat or #Mat == 0) then return end
	if (!self.Materials[Mat]) then
			local temp;
			if (#file.Find("../materials/"..Mat..".*") > 0) then
					 temp = surface.GetTextureID(Mat);
			end
			self.Materials[Mat] = temp;
	end
	return self.Materials[Mat];
end

/*---------------------------------------------------------
	ShowAll
---------------------------------------------------------*/
function PANEL:SetShowAll( BOOL )
	
	if ( !Bool ) then
		self.ShowAll = false;
		--Should auto fade everything in.
	else
		self.ShowAll = true;
		
		for K , V in pairs ( self.Fades ) do
			
			if ( V[1] < CurTime() ) then
				V[2] = 1;
			end --Anything that dosnt have a remain time will fade out instantly.
		
		end
	end

end

/*---------------------------------------------------------
	Fade
---------------------------------------------------------*/
function PANEL:GetFade( ID )

	--if ( self.ShowAll ) then
	--	return 1; --255 * 1 = 255;
	--end
	
	if( !self.Fades[ ID ] ) then
		self.Fades[ ID ] = { CurTime() + 10 , 0 };
		return 1; --Set it up to fade.
	end
	
	if ( self.Fades[ ID ][1] >= CurTime() ) or ( self.ShowAll ) then
		if ( self.Fades[ ID ][2] < 1 ) then
			self.Fades[ ID ][2] = self.Fades[ ID ][2] + 0.01;
		end --Fade in animation.
		
	elseif ( self.Fades[ ID ][2] > 0 ) then
		self.Fades[ ID ][2] = self.Fades[ ID ][2] - 0.01;
	end --Fade out animation.
	
	return self.Fades[ ID ][2];
end

/*---------------------------------------------------------
	Paint
---------------------------------------------------------*/
function PANEL:Paint()
	
	surface.SetFont( "Default" ); --Cant be changed or alignment fucks up!
	
	local Highlight = self.m_colHighlight;
	local Cursor = self.m_colCursor;
	
	if ( !self.ShowAll ) then
		Highlight.a = 0;
		Cursor.a = 0;
	end
	
	self:DrawTextEntryText( Color(0,0,0,0) , Highlight, Cursor )
	self:PaintText()

end

/*---------------------------------------------------------
   Name: PaintText
---------------------------------------------------------*/
function PANEL:PaintText()
	
	local _W , H = surface.GetTextSize( "I" );
	local SPACE , _H = surface.GetTextSize( " " );
	local X , Y = -3 , -H; --Perfect Alignment;
	for ID,Line in pairs( string.Explode ( "\n" , self.Entry ) ) do
		local Fade = self:GetFade( ID );
		local color = self.m_colText;
		color.a = ( color.a or 255 ) * Fade;
		local higlight = Color( 0 , 0 , 0 , 0  * Fade );
		for __,Word in pairs ( self:Exploder( Line ) ) do
			local Command, Perams = string.match( Word, "%[(.+)=(.+)%]" );
			if ( Command ) and ( Perams ) then
				local Args = {};
				local Args = string.Explode( "," , Perams );
				if ( Command == "color" ) then
					color = Color( tonumber(Args[1] or 255 ) , tonumber(Args[2] or 255 ) , tonumber(Args[3] or 255 ) , tonumber(Args[4] or 255 ) * Fade );
				elseif ( Command == "higlight" ) then
					higlight = Color( tonumber(Args[1] or 255 ) , tonumber(Args[2] or 255 ) , tonumber(Args[3] or 255 ) , tonumber(Args[4] or 255 ) * Fade );
				elseif ( Command == "icon" ) then
					surface.SetDrawColor( Color(255,255,255,255 * Fade) );
					surface.SetTexture( self:GetMaterial( Args[1] ) )
					local BoxSize = SPACE * 5; -- 16
					surface.DrawTexturedRect( X , Y , BoxSize , BoxSize );
					X = X + BoxSize;
				end
			else
				local W = surface.GetTextSize( Word );
				surface.SetDrawColor( higlight );
				surface.DrawRect( X , Y , W + SPACE, H );
				surface.SetTextColor( color );
				surface.SetTextPos( X , Y );
				surface.DrawText( Word );
				X = X + W + SPACE;
			end
		end
		Y = Y + H + 1;
		X = 3;
	end
end


derma.DefineControl( "LAChatDisplay", "", PANEL, "DTextEntry" )
