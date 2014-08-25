-------------------------------
--Plugin
-------------------------------
local Plugin = {};
Plugin.Name = "ChatBox";
Plugin.Author = "Goluch";
Plugin.Description = "This plugin creates a whole new chat box.";
Plugin.CanDisable = false;

-------------------------------
--Create Display
-------------------------------
function Plugin:Initialize()

	local Width , Height = 500 , 250;
	self.ChatDisplay = vgui.Create( "LAChatDisplay" );
	self.ChatDisplay:SetSize( Width , Height );
	self.ChatDisplay:SetPos( chat.GetChatBoxPos( ) );
	self.ChatDisplay:SetVisible( true );
	--self.ChatDisplay:EnableVerticalScrollbar( true );

end

-------------------------------
--ShowChat
-------------------------------
function Plugin:ShowChat( BOOL )
	self.ChatDisplay:SetShowAll( BOOL );
end

-------------------------------
--OpenChat Bind
-------------------------------
function Plugin:PlayerBindPress(  player,  bind,  pressed ) 
	if ( string.find( bind , "messagemode") ) then
		self:ShowChat( true );
		return true
	end
end
	
-------------------------------
--AddText
-------------------------------
function chat.AddText( ... )
	
	Plugin.ChatDisplay:AddSomthing( ... );
	Plugin.ChatDisplay:SizeToContents();
	--Plugin.ChatDisplay.VBar:SetScroll(99999999999999999999999999);
	
end

-------------------------------
--Print / Anti Join Leave
-------------------------------
function Plugin:ChatText( Ply, Name, Text, Type )
	if Type == "none" then
		chat.AddText( Color( 200 , 200 , 255 ) , Text)
	end
	return true
end

-------------------------------
--Register Plugin
-------------------------------
LA:AddPlugin( Plugin )