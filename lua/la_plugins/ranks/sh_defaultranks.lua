----------------------------------------------------------------
-- Default Ranks
----------------------------------------------------------------
local Plugin = {}
Plugin.Name = "DefaultRanks"
Plugin.Author = "Divran"
Plugin.Description = "Creates the default ranks."
Plugin.CanDisable = false

function Plugin:InheritPriv( From, To )
	if (!self.Ranks[To].Priv) then self.Ranks[To].Priv = {} end
	if (!self.Ranks[From].Priv) then return false end
	local copy = table.Copy(self.Ranks[From].Priv)
	table.Add( self.Ranks[To].Priv, copy )
	return true
end

Plugin.Ranks = {}

Plugin.Ranks.Guest = {}
Plugin.Ranks.Guest.Name = "Guest"
Plugin.Ranks.Guest.CanRemove = false
Plugin.Ranks.Guest.Power = 0
Plugin.Ranks.Guest.Priv = { "Rainbow Chat" }
Plugin.Ranks.Guest.Color = Color(100,100,255,255) -- Dark Blue
Plugin.Ranks.Guest.Promote = { Rank = "Respected", Time = { Hours = 5 } }

Plugin.Ranks.Respected = {}
Plugin.Ranks.Respected.Name = "Respected"
Plugin.Ranks.Respected.Power = 10
Plugin.Ranks.Respected.Priv = { "Teleport", "Goto", "God", "Ungod", "Bring", "Send", "Menu" }
Plugin:InheritPriv( "Guest", "Respected" )
Plugin.Ranks.Respected.Color = Color( 255,127,39,255 ) -- Orange
Plugin.Ranks.Respected.Promote = { Rank = "VIP", Time = { Days = 5 } }

Plugin.Ranks.VIP = {}
Plugin.Ranks.VIP.Name = "VIP"
Plugin.Ranks.VIP.Power = 20
Plugin.Ranks.VIP.Priv = { "Armor", "Health", "Jump", "Speed", "Slay", "Slap", "Noclip", "Unnoclip" }
Plugin:InheritPriv( "Respected", "VIP" )
Plugin.Ranks.VIP.Color = Color( 200,200,200,255 ) -- White

Plugin.Ranks.Moderator = {}
Plugin.Ranks.Moderator.Name = "Moderator"
Plugin.Ranks.Moderator.Power = 30
Plugin.Ranks.Moderator.Priv = { "Kick", "Explode", "Whip" }
Plugin:InheritPriv( "VIP", "Moderator" )
Plugin.Ranks.Moderator.Color = Color(100,200,100,255) -- Dark Green

Plugin.Ranks.Admin = {}
Plugin.Ranks.Admin.Name = "Admin"
Plugin.Ranks.Admin.Power = 70
Plugin.Ranks.Admin.Priv = { "Kick", "Ban", "Reload", "Freeze", "Trainfuck", "Freeze", "Unfreeze", "Jail", "Cage", "Unjail and cage", "Uncage", "Rocket", "Hax", "Roadkill", "Bombard", "Ban" }
Plugin:InheritPriv( "Moderator", "Admin" )
Plugin.Ranks.Admin.Color = Color(200,80,80,255) -- Dark Red

Plugin.Ranks.SuperAdmin = {}
Plugin.Ranks.SuperAdmin.Name = "Super Admin"
Plugin.Ranks.SuperAdmin.Power = 90
Plugin.Ranks.SuperAdmin.Priv = { "Rank", "Cexec", "Rcon", "PermBan" }
Plugin:InheritPriv( "Admin", "SuperAdmin" )
Plugin.Ranks.SuperAdmin.Color = Color(255,200,0,255) -- Gold


Plugin.Ranks.Owner = {}
Plugin.Ranks.Owner.Name = "Owner"
Plugin.Ranks.Owner.Power = 100
Plugin.Ranks.Owner.Priv = {}
Plugin:InheritPriv( "SuperAdmin", "Owner" )
Plugin.Ranks.Owner.Locked = true
Plugin.Ranks.Owner.CanRemove = false
Plugin.Ranks.Owner.Color = Color(50,50,50,255) -- Black

for k,v in pairs( Plugin.Ranks ) do
	if (v.CanRemove == nil) then v.CanRemove = true end
	if (v.Locked == nil) then v.Locked = false end
end

LA:AddPlugin( Plugin )