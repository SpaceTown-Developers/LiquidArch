----------------------------------------------------------------
-- Simple Func Commands!
----------------------------------------------------------------
LA:AddCommand( "Hax", "Fun" )
LA:AddCommand( "Bombard", "Fun" )
LA:AddCommand( "Roadkill", "Fun" )
LA:AddCommand( "Trainfuck", "Fun" )

----------------------------------------------------------------
-- Rainbow Chat
-- TODO: Make this not require a selexted player =D
----------------------------------------------------------------
LA:AddCommand( "Rainbow Chat", "Fun", function( MenuPlugin, CmdList )
	local Btn = MenuPlugin:AddMenuButton( "Rainbowchat", function( Pnl, Wide, Close )
		local Txt = vgui.Create( "DTextEntry", Pnl )
		Txt:SetPos( 5, 5 )
		Txt:SetSize( Wide - 50, 20 )
		
		function Txt:OnEnter( )
			RunConsoleCommand( "la", "rbc", self:GetValue( ) )
		end
		
		local Snd = vgui.Create( "DButton", Pnl )
		Snd:SetPos( Wide - 45, 5 )
		Snd:SetSize( 40, 20 )
		Snd:SetText( "Send" )
		
		function Snd:DoClick( )
			RunConsoleCommand( "la", "rbc", Txt:GetValue( ) )
			Close( )
		end
		
		return 30 -- This is how tall we want the menu =D
	end )
	
	CmdList:AddItem( Btn )
end)

----------------------------------------------------------------
-- Slap and Wip
----------------------------------------------------------------
LA:AddCommand( "Slap", "Fun", function( MenuPlugin, CmdList )
	local Slap = MenuPlugin:AddMenuButton( "Slap", function( Pnl, Wide, Close )
		local Lbl = vgui.Create( "DLabel", Pnl )
		Lbl:SetText( "Power:" )
		Lbl:SizeToContents( )
		Lbl:SetPos( 5, 5 )
		
		local Sld = vgui.Create( "Slider", Pnl )
		Sld:SetPos( 5, 25 )
		Sld:SetSize( Wide - 45, 20 )
		Sld:SetMin( 0 )
		Sld:SetMax( 100 )
		Sld:SetValue( 10 )
		Sld:SetDecimals( 0 )

		local Snd = vgui.Create( "DButton", Pnl )
		Snd:SetPos( Wide - 45, 25 )
		Snd:SetSize( 40, 20 )
		Snd:SetText( "Slap" )
		
		function Snd:DoClick( )
			local Args = MenuPlugin:GetSteamIDs( )
			table.insert( Args, Sld:GetValue( ) )
			RunConsoleCommand( "la", "slap", unpack( Args ) )
			Close( )
		end
		
		return 50 -- This is how tall we want the menu =D
	end )
	
	local Whip = MenuPlugin:AddMenuButton( "Whip", function( Pnl, Wide, Close )
		local Lbl1 = vgui.Create( "DLabel", Pnl )
		Lbl1:SetText( "Power:" )
		Lbl1:SizeToContents( )
		Lbl1:SetPos( 5, 5 )
		
		local Sld1 = vgui.Create( "Slider", Pnl )
		Sld1:SetPos( 5, 25 )
		Sld1:SetSize( Wide - 54, 20 )
		Sld1:SetMin( 0 )
		Sld1:SetMax( 100 )
		Sld1:SetValue( 10 )
		Sld1:SetDecimals( 0 )
		
		local Lbl2 = vgui.Create( "DLabel", Pnl )
		Lbl2:SetText( "Power:" )
		Lbl2:SizeToContents( )
		Lbl2:SetPos( 5, 45 )
		
		local Sld2 = vgui.Create( "Slider", Pnl )
		Sld2:SetPos( 5, 65 )
		Sld2:SetSize( Wide - 45, 20 )
		Sld2:SetMin( 0 )
		Sld2:SetMax( 100 )
		Sld2:SetValue( 5 )
		Sld2:SetDecimals( 0 )
		
		local Snd = vgui.Create( "DButton", Pnl )
		Snd:SetPos( Wide - 45, 65 )
		Snd:SetSize( 40, 20 )
		Snd:SetText( "Slap" )
		
		function Snd:DoClick( )
			local Args = MenuPlugin:GetSteamIDs( )
			table.insert( Args, Sld1:GetValue( ) )
			table.insert( Args, Sld2:GetValue( ) )
			RunConsoleCommand( "la", "whip", unpack( Args ) )
			Close( )
		end
		
		return 90 -- This is how tall we want the menu =D
	end )
	
	CmdList:AddItem( MenuPlugin:SortButtons( CmdList, Slap, Whip ) )
end)

----------------------------------------------------------------
-- Punishment
----------------------------------------------------------------
LA:AddCommand( "Slay", "Punishment" )

LA:AddCommand( "Explode", "Punishment", function( MenuPlugin, CmdList )
	CmdList:AddItem( MenuPlugin:SortButtons( CmdList, MenuPlugin:AddCmdButton( "Explode" ), MenuPlugin:AddCmdButton( "Rocket" ) ) )
end)

LA:AddCommand( "Freeze", "Punishment", function( MenuPlugin, CmdList )
	CmdList:AddItem( MenuPlugin:SortButtons( CmdList, MenuPlugin:AddCmdButton( "Freeze" ), MenuPlugin:AddCmdButton( "Unfreeze" ) ) )
end)

LA:AddCommand( "Jail", "Punishment", function( MenuPlugin, CmdList )
	CmdList:AddItem( MenuPlugin:SortButtons( CmdList, MenuPlugin:AddCmdButton( "Jail" ), MenuPlugin:AddCmdButton( "Unjail" ) ) )
end)

----------------------------------------------------------------
-- Teleoprt
----------------------------------------------------------------
LA:AddCommand( "Teleport", "Teleportation", function( MenuPlugin, CmdList )
	CmdList:AddItem( MenuPlugin:SortButtons( CmdList, MenuPlugin:AddCmdButton( "TP" ), MenuPlugin:AddCmdButton( "Goto" ), MenuPlugin:AddCmdButton( "Bring" ) ) )
end)