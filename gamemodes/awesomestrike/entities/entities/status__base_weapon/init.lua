AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.WeaponClass = "_weapon_dummy"

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetModel(self.Model)
end

function ENT:PlayerSet(pPlayer, bExists)
	pPlayer.WeaponStatus = self
end

function ENT:Think()
	local owner = self:GetOwner()
	if not owner:IsValid() or not owner:GetActiveWeapon():IsValid() or owner:GetActiveWeapon():GetClass() ~= self.WeaponClass then
		self:Remove()
	end
end
