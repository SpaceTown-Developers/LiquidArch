hook.Add( "LA_BuildMenu", "LA.AddMenuCommands", function( Plugin )

----------------------------------------------------------------
-- Simple Func Commands!
----------------------------------------------------------------
	Plugin:AddSimpleCommand( "Fun", "Hax" )
	Plugin:AddSimpleCommand( "Fun", "Bombard" )
	Plugin:AddSimpleCommand( "Fun", "Roadkill" )
	Plugin:AddSimpleCommand( "Fun", "Trainfuck" )

----------------------------------------------------------------
-- Slap and Wip
----------------------------------------------------------------
	
	Plugin:AddCommand( "Fun", function( Btn, Wide, GetPlayer, Close )
		local PowerSld = Btn:Add( "DNumberWang" )
		PowerSld:SetWide( Wide * 0.25 )
		PowerSld:Dock( RIGHT )
		PowerSld:SetValue( 10 )
		PowerSld:SetMinMax( 0, 100 )
		PowerSld:SetToolTip( "Power" )

		Btn:SetText( "Slap" )
		Btn.DoClick = function( )
			Close( )
			RunConsoleCommand( "la", "slap", GetPlayer( ):SteamID( ), math.ceil( PowerSld:GetValue( ) ) )
		end
	end )

	Plugin:AddCommand( "Fun", function( Btn, Wide, GetPlayer, Close )
		local CountSld = Btn:Add( "DNumberWang" )
		CountSld:SetWide( Wide * 0.25 )
		CountSld:Dock( RIGHT )
		CountSld:SetValue( 10 )
		CountSld:SetMinMax( 2, 100 )
		CountSld:SetToolTip( "Count" )

		local PowerSld = Btn:Add( "DNumberWang" )
		PowerSld:SetWide( Wide * 0.25 )
		PowerSld:Dock( RIGHT )
		PowerSld:SetValue( 5 )
		PowerSld:SetMinMax( 0, 100 )
		PowerSld:SetToolTip( "Power" )

		Btn:SetText( "Whip" )
		Btn.DoClick = function( )
			Close( )
			RunConsoleCommand( "la", "whip", GetPlayer( ):SteamID( ), math.ceil( CountSld:GetValue( ) ), math.ceil( PowerSld:GetValue( ) ) )
		end
	end )

----------------------------------------------------------------
-- Punishment
----------------------------------------------------------------
	Plugin:AddSimpleCommand( "Punishment", "Slay" )

	Plugin:AddSimpleCommand( "Punishment", "Explode" )

	Plugin:AddCommand( "Punishment", function( Pnl, Wide, GetPlayer, Close )
		Pnl:SetText( "Gagged" )

		local CheckBox = Pnl:Add( "DCheckBox" )
		CheckBox:Dock( RIGHT )

		hook.Add( "LA_ShowCommands", Pnl, function( _, Ply ) 
			CheckBox:SetValue( Ply:GetNWBool( "LA.Gagged", false ) )
		end )

		CheckBox.OnChange = function( _, Val )
			--Close( )
			RunConsoleCommand( "la", Val and "gag" or "ungag", GetPlayer( ):SteamID( ) )
		end
	end, "DPanel" )

	Plugin:AddCommand( "Punishment", function( Pnl, Wide, GetPlayer, Close )
		Pnl:SetText( "Jailed" )

		local CheckBox = Pnl:Add( "DCheckBox" )
		CheckBox:Dock( RIGHT )

		hook.Add( "LA_ShowCommands", Pnl, function( _, Ply ) 
			CheckBox:SetValue( Ply:GetNWBool( "LA.Jailed", false ) )
		end )

		CheckBox.OnChange = function( _, Val )
			--Close( )
			RunConsoleCommand( "la", Val and "jail" or "unjail", GetPlayer( ):SteamID( ) )
		end
	end, "DPanel" )

	Plugin:AddCommand( "Punishment", function( Pnl, Wide, GetPlayer, Close )
		Pnl:SetText( "Froze" )

		local CheckBox = Pnl:Add( "DCheckBox" )
		CheckBox:Dock( RIGHT )

		hook.Add( "LA_ShowCommands", Pnl, function( _, Ply ) 
			CheckBox:SetValue( Ply:GetNWBool( "LA.Froze", false ) )
		end )

		CheckBox.OnChange = function( _, Val )
			--Close( )
			RunConsoleCommand( "la", Val and "freeze" or "unfreeze", GetPlayer( ):SteamID( ) )
		end
	end, "DPanel" )

----------------------------------------------------------------
-- Teleoprt
----------------------------------------------------------------
	
	Plugin:AddSimpleCommand( "Teleport", "Goto" )
	Plugin:AddSimpleCommand( "Teleport", "Bring" )
	Plugin:AddSimpleCommand( "Teleport", "Teleport to aim position", "TP" )

----------------------------------------------------------------
-- Administration
----------------------------------------------------------------
	
	Plugin:AddCommand( "Administration", function( Btn, Wide, GetPlayer, Close )
		local Reason = Btn:Add( "DTextEntry" )
		Reason:SetWide( Wide * 0.5 )
		Reason:Dock( RIGHT )

		Btn:SetText( "Kick" )
		Btn.DoClick = function( )
			Close( )
			RunConsoleCommand( "la", "kick", GetPlayer( ):SteamID( ), Reason:GetValue( ) )
		end
	end )

	Plugin:AddCommand( "Administration", function( Btn, Wide, GetPlayer, Close )
		local Reason = Btn:Add( "DTextEntry" )
		Reason:SetWide( Wide * 0.5 )
		Reason:Dock( RIGHT )

		Btn:SetText( "Perm Ban" )
		Btn.DoClick = function( )
			Close( )
			RunConsoleCommand( "la", "ban", GetPlayer( ):SteamID( ), 0, Reason:GetValue( ) )
		end
	end )


	Plugin:AddCommand( "Administration", function( Pnl, Wide, GetPlayer, Close )
		Pnl:SetText( "No Limits" )

		local CheckBox = Pnl:Add( "DCheckBox" )
		CheckBox:Dock( RIGHT )

		hook.Add( "LA_ShowCommands", Pnl, function( _, Ply ) 
			CheckBox:SetValue( Ply:GetNWBool( "LA.NoLimits", false ) )
		end )

		CheckBox.OnChange = function( _, Val )
			--Close( )
			RunConsoleCommand( "la", Val and "nolimits" or "limits", GetPlayer( ):SteamID( ) )
		end
	end, "DPanel" )

	Plugin:AddCommand( "Administration", function( Pnl, Wide, GetPlayer, Close )
		Pnl:SetText( "Can't Noclip" )

		local CheckBox = Pnl:Add( "DCheckBox" )
		CheckBox:Dock( RIGHT )

		hook.Add( "LA_ShowCommands", Pnl, function( _, Ply ) 
			CheckBox:SetValue( Ply:GetNWBool( "LA.CantNoclip", false ) )
		end )

		CheckBox.OnChange = function( _, Val )
			--Close( )
			RunConsoleCommand( "la", Val and "unnoclip" or "noclip", GetPlayer( ):SteamID( ) )
		end
	end, "DPanel" )


	Plugin:AddCommand( "Administration", function( Btn, Wide, GetPlayer, Close )
		Btn:SetText( "Rank" )

		local Combo = Btn:Add( "DComboBox" )
		Combo:Dock( RIGHT )

		hook.Add( "LA_ShowCommands", Btn, function( _, Ply ) 
			Combo:Clear( )

			for _, Rank in pairs( LA.Ranks ) do Combo:AddChoice( Rank.Name ) end

			Combo:SetValue( LA:GetRank( Ply ).Name )
		end )

		Btn.DoClick = function( _ )
			Close( )
			RunConsoleCommand( "la", "rank", GetPlayer( ):SteamID( ), Combo:GetText( ) )
		end

	end, "DButton" )


end )
