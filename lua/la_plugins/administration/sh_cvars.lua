local Plugin = { }
Plugin.Name = "Cvars"
Plugin.Author = "Rusketh"
Plugin.Description = "Lists and changes cvars."
Plugin.Commands = { "Cvar" }

Plugin.Help = {}
Plugin.Help["Cvar"] = "[cvar] [Value]"
Plugin.Category = "Administration"
Plugin.Privs = { "Change Cvars" }

----------------------------------------------------------------
-- Send List

if SERVER then
	resource.AddSingleFile( "materials/gui/fugue/arrow-retweet.png")
	util.AddNetworkString( "LA.Cvars" )

	function Plugin:SendConvars( Player )
		local SendTable = { }
		
		for Name, CVar in pairs( LA.Convars ) do
			SendTable[Name] = CVar:GetString( )
		end

		net.Start( "LA.Cvars" )
		net.WriteTable( SendTable )
		net.Send( Player )
	end

	concommand.Add( "la_requestcvars", function( Ply )
		if LA:CheckAllowed( Ply, Plugin, "Change Cvars" ) then
			Plugin:SendConvars( Ply )
		end
	end )

	function Plugin:Cvar( Ply, Args )
		if !LA:CheckAllowed( Ply, self, "Change Cvars" ) then
			return LA:Message( Ply, unpack( LA.NotAllowed) )
		elseif !Args[1] then
			return LA:Message( Ply, "No Cvar entered." )
		elseif !Args[2] then
			return LA:Message( Ply, "No value entered." )
		end

		RunConsoleCommand( Args[1], Args[2] ) 
	end

end

----------------------------------------------------------------
-- Menu

if CLIENT then
	function Plugin:LA_BuildMenu( MenuPlug )
		MenuPlug:AddWidget( "", "Convars", function( Pnl, Wide, Tall )
			Pnl.Refresh = Pnl:Add( "DImageButton" )
			Pnl.Refresh:SetImage( "gui/fugue/arrow-retweet.png" )
			Pnl.Refresh:SetToolTip( "Refresh convar list." )
			Pnl.Refresh:SetSize( 20, 20 )
			Pnl.Refresh:SetPos( Wide - 25, 5 )

			Pnl.Refresh.DoClick = function( )
				RunConsoleCommand( "la_requestcvars" )
			end
			
			Pnl.Label = Pnl:Add( "DLabel" )
			Pnl.Label:SetText( "Server Convars" )
			Pnl.Label:SizeToContents( )
			Pnl.Label:SetPos( 5, 5 )
			Pnl.Label:SetTextColor( Color( 0, 0, 0, 255 ) )
			
			Pnl:DockPadding( 5, 24 + 5, 5, 5 )
			Plugin.List = Pnl:Add( "DScrollPanel" )
			Plugin.List:Dock( FILL )
		end, "DPanel" )
	end

	net.Receive( "LA.Cvars", function( )
		local Tbl = net.ReadTable( )
		if !IsValid( Plugin.List ) then return MsgN( "No List?" ) end

		Plugin.List:Clear()

		for Name, Value in pairs( Tbl ) do
			local Btn = Plugin.List:Add( "DButton" )
			Btn:SetText( Name )
			Btn:SetWide( Plugin.List:GetWide() )

			local Input = Btn:Add( "DTextEntry" )
			Input:SetWide( 30 )
			Input:Dock( RIGHT )
			Input:SetValue( Value )
			Btn.DoClick = function( )
				RunConsoleCommand( "la", "cvar", Input:GetValue( ) )
			end
		end
	end )
end

LA:AddPlugin( Plugin )