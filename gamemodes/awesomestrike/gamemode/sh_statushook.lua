-- Use the meta functions, the two below are all deprecated.
function WeaponHook(hookname, pl, ...)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep[hookname] then
		return wep[hookname](wep, ...)
	end
end

function StatusHook(hookname, pl, ...)
	for _, ent in pairs(ents.FindByClass("status_*")) do
		if ent[hookname] and ent:GetOwner() == pl then
			local ret = ent[hookname](ent, ...)
			if ret ~= nil then return ret end
		end
	end
end

local WeaponHook = WeaponHook
local StatusHook = StatusHook

function StatusWeaponHook(hookname, pl, ...)
	local ret = WeaponHook(hookname, pl, ...)
	if ret ~= nil then return ret end
	return StatusHook(hookname, pl, ...)
end

local gmcall = gamemode.Call

function GlobalHook(hookname, pl, ...)
	local ret = StatusWeaponHook(hookname, pl, ...)
	if ret ~= nil then return ret end
	return gmcall(hookname, pl, ...)
end

local meta = FindMetaTable("Player")
if not meta then return end

function meta:WeaponHook(hookname, ...)
	local wep = self:GetActiveWeapon()
	if wep:IsValid() and wep[hookname] then
		return wep[hookname](wep, ...)
	end
end

function meta:StatusHook(hookname, ...)
	for _, ent in pairs(ents.FindByClass("status_*")) do
		if ent:GetOwner() == self and ent[hookname] then
			local ret = ent[hookname](ent, ...)
			if ret ~= nil then return ret end
		end
	end
end

function meta:StatusWeaponHook(hookname, ...)
	local ret = self:WeaponHook(hookname, ...)
	if ret ~= nil then return ret end
	return self:StatusHook(hookname, ...)
end

function meta:GlobalHook(hookname, ...)
	local ret = self:StatusWeaponHook(hookname, ...)
	if ret ~= nil then return ret end
	return gmcall(hookname, self, ...)
end
