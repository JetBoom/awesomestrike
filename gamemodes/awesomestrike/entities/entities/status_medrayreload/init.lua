AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:PlayerSet(pPlayer, bExists)
	pPlayer.MedRayReload = self

	self.NextAmmoGive = CurTime() + 0.25
	self.Created = CurTime()
end

function ENT:OnRemove()
	local parent = self:GetParent()
	if parent:IsValid() then
		parent.MedRayReload = nil
	end
end

function ENT:Think()
	local owner = self:GetOwner()
	if not owner:IsValid() then self:Remove() return end

	local wep = owner:GetActiveWeapon()
	if not wep:IsValid() or wep:GetClass() ~= "weapon_as_medray" or wep:Clip1() >= wep.Primary.ClipSize or not owner:KeyDown(IN_RELOAD) or owner:KeyDown(IN_ATTACK) then
		self:Remove()
	elseif CurTime() >= self.NextAmmoGive then
		wep:SetClip1(wep:Clip1() + 1)
		self.NextAmmoGive = CurTime() + (1 - math.min(1, (CurTime() - self.Created) * 0.25))
		if wep:Clip1() >= wep.Primary.ClipSize then
			wep:SendWeaponAnim(ACT_VM_IDLE)
			self:Remove()
		end
	end

	self:NextThink(CurTime())
	return true
end
