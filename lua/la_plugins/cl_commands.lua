----------------------------------------------------------------
-- Helper for Check Boxes
----------------------------------------------------------------
local function CreateCheckBox( Pnl, NetBool, On, Off, GetPlayer )
	local CB = Pnl:Add( "DButton" )
	CB:SetSize( 15, 15 )
	CB:SetText( "" )
	CB:Dock( RIGHT )

	Derma_Hook( CB, "Paint", "Paint", "CheckBox" )

	CB.GetChecked = function( )
		local Ply = GetPlayer( )
		if !IsValid( Ply ) then return false end
		return Ply:GetNWBool( NetBool, false )
	end

	CB.DoClick = function( )
		RunConsoleCommand( "la", !CB:GetChecked( ) and On or Off, GetPlayer( ):SteamID( ) )
	end

	return CB
end

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
		CreateCheckBox( Pnl, "LA.Gagged", "gag", "ungag", GetPlayer )
	end, "DPanel" )

	Plugin:AddCommand( "Punishment", function( Pnl, Wide, GetPlayer, Close )
		Pnl:SetText( "Jailed" )
		CreateCheckBox( Pnl, "LA.Jailed", "jail", "unjail", GetPlayer )
	end, "DPanel" )

	Plugin:AddCommand( "Punishment", function( Pnl, Wide, GetPlayer, Close )
		Pnl:SetText( "Frozen" )
		CreateCheckBox( Pnl, nil, "freeze", "unfreeze", GetPlayer ).GetChecked = function( )
			local Ply = GetPlayer( )
			if !IsValid( Ply ) then return false end
			return Ply:IsFrozen( ) 
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
		CreateCheckBox( Pnl, "LA.NoLimits", "nolimits", "limits", GetPlayer )
	end, "DPanel" )

	Plugin:AddCommand( "Administration", function( Pnl, Wide, GetPlayer, Close )
		Pnl:SetText( "Can't Noclip" )
		CreateCheckBox( Pnl, "LA.CantNoclip", "unnoclip", "noclip", GetPlayer )
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