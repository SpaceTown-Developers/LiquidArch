//LA LIST Panel
local PANEL = {}
function PANEL:Rebuild()

	local Offset = 0

	if ( self.Horizontal ) then

		local x, y = self.Padding, self.Padding;
		for k, panel in pairs( self.Items ) do
		
			if ( panel:IsVisible() ) then
			
				local w = panel:GetWide()
				local h = panel:GetTall()
				
				if ( x + w  > self:GetWide() ) then
				
					x = self.Padding
					y = y + h + self.Spacing
				
				end
				
				panel:SetPos( x, y )
				
				x = x + w + self.Spacing
				Offset = y + h + self.Spacing
			
			end
		
		end

	else

		for k, panel in pairs( self.Items ) do
		
			if ( panel:IsVisible() ) then
				
				if ( self.m_bNoSizing ) then
					panel:SizeToContents()
					panel:SetPos( (self:GetCanvas():GetWide() - panel:GetWide()) * 0.5, self.Padding + Offset )
				else
					--panel:SetSize( self:GetCanvas():GetWide() - self.Padding * 2, panel:GetTall() )
					--Yes this entire file is jsut so i can comment out the above line :)
					--FUCK YOU GARRY!
					panel:SetPos( self.Padding, self.Padding + Offset )
				end
				
				// Changing the width might ultimately change the height
				// So give the panel a chance to change its height now, 
				// so when we call GetTall below the height will be correct.
				// True means layout now.
				panel:InvalidateLayout( true )
				
				Offset = Offset + panel:GetTall() + self.Spacing
				
			end
		
		end
		
		Offset = Offset + self.Padding
		
	end

	self:GetCanvas():SetTall( Offset + (self.Padding) - self.Spacing ) 

	// This is a quick hack, ideally this setting will position the panels from the bottom upwards
	// This back just aligns the panel to the bottom
	if ( self.m_bBottomUp ) then
		self:GetCanvas():AlignBottom( self.Spacing )
	end

	// Although this behaviour isn't exactly implied, center vertically too
	if ( self.m_bNoSizing && self:GetCanvas():GetTall() < self:GetTall() ) then

		self:GetCanvas():SetPos( 0, (self:GetTall()-self:GetCanvas():GetTall()) * 0.5 )

	end
end
vgui.Register( "LAListPanel", PANEL, "DPanelList" )