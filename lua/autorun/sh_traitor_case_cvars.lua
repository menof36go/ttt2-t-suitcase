if SERVER then
	AddCSLuaFile()
	if file.Exists("scripts/sh_convarutil.lua", "LUA") then
		AddCSLuaFile("scripts/sh_convarutil.lua")
		print("[INFO][Traitor Case] Using the utility plugin to handle convars instead of the local version")
	else
		AddCSLuaFile("scripts/sh_convarutil_local.lua")
		print("[INFO][Traitor Case] Using the local version to handle convars instead of the utility plugin")
	end
end

if file.Exists("scripts/sh_convarutil.lua", "LUA") then
	include("scripts/sh_convarutil.lua")
else
	include("scripts/sh_convarutil_local.lua")
end

-- Must run before hook.Add
local cg = ConvarGroup("TraitorCase", "Traitor Case")
Convar(cg, true, "ttt_tc_ignore_not_buyable", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Grant weapons that are set to be not buyable in the TTT2 Shopeditor", "bool")
Convar(cg, true, "ttt_tc_max_credits", 4, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Grant weapons that cost less or equal to the amount set", "int", 1, 100)
--