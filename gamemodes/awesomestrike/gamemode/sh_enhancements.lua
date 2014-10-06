-- TODO: All generation is on a separate server. Messing with this stuff won't do much for you.

if SERVER then
	AddCSLuaFile("enhancements/global_itemserver.lua")
	AddCSLuaFile("enhancements/global_enhancementlist.lua")
	AddCSLuaFile("enhancements/global_namedchiplist.lua")
	AddCSLuaFile("enhancements/sh_namedchips.lua")
end

include("enhancements/global_itemserver.lua")
include("enhancements/global_enhancementlist.lua")
include("enhancements/global_namedchiplist.lua")
include("enhancements/sh_namedchips.lua")

if SERVER then
	include("enhancements/sv_itemserverclient.lua")
end
