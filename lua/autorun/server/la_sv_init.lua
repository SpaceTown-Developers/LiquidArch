----------------------------------------------------------------
-- LA Serverside Init
----------------------------------------------------------------
LA = { }

AddCSLuaFile("autorun/client/la_cl_init.lua")
AddCSLuaFile("la_init.lua")
include("la_init.lua")

LA.Installed = true