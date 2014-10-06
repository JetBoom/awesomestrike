local function CDDrawWorldModel(self)
	if not self:GetOwner():IsValid() or CurTime() >= self:GetCoolDown() then
		self:DrawModel()
	end
end

local function CDGetViewModelPosition(self, pos, ang)
	if CurTime() < self:GetCoolDown() then
		pos = pos + 64 * ang:Up()
	end

	return self.BaseClass.GetViewModelPosition(self, pos, ang)
end

function GM:SetupCoolDownWeapon(wep)
	if not wep.WElements and not wep.VElements then
		wep.DrawWorldModel = CDDrawWorldModel
		wep.DrawWorldModelTranslucent = wep.DrawWorldModel
		wep.GetViewModelPosition = CDGetViewModelPosition
	end
end

local meta = FindMetaTable("Weapon")
if not meta then return end

meta.GetNextPrimaryAttack = meta.GetNextPrimaryFire
meta.GetNextSecondaryAttack = meta.GetNextSecondaryFire
meta.SetNextPrimaryAttack = meta.SetNextPrimaryFire
meta.SetNextSecondaryAttack = meta.SetNextSecondaryFire

function meta:SetShootingEnd(time)
	self:SetDTFloat(1, time)
end

function meta:GetShootingEnd()
	return self:GetDTFloat(1)
end

function meta:SetReloadEnd(time)
	self:SetDTFloat(0, time)
end
meta.SetReloadingEnd = meta.SetReloadEnd

function meta:GetReloadEnd()
	return self:GetDTFloat(0)
end
meta.GetReloadingEnd = meta.GetReloadEnd

meta.SetCoolDown = meta.SetReloadEnd
meta.GetCoolDown = meta.GetReloadEnd

function meta:ResetCoolDown()
	self:SetCoolDown(CurTime() + (self.CoolDown or 0) * (self.Owner:GetSkill() == SKILL_MECHANICALMASTERY and 0.5 or 1))
end

function meta:IsShooting()
	return CurTime() < self:GetShootingEnd()
end

function meta:IsReloading()
	return CurTime() < self:GetReloadEnd()
end

function meta:SetNextStart(time)
	self.m_ReloadStart = time
end

function meta:GetReloadStart()
	return self.m_ReloadStart or 0
end

function meta:IsBusy()
	return self.IsIdle and not self:IsIdle() 
end

function AngleCone(ang, fCone)
	ang:RotateAroundAxis(ang:Up(), math.Rand(-fCone, fCone))
	ang:RotateAroundAxis(ang:Right(), math.Rand(-fCone, fCone))
	return ang
end
function meta:ShootBullet(fDamage, iNumber, fCone)
	local owner = self.Owner
	for i=1, (iNumber or 1) do
		local pos = owner:GetShootPos()
		local ang = fCone == 0 and owner:EyeAngles() or AngleCone(owner:EyeAngles(), fCone)
		local nocompensation = false
		if self.AlterBulletAngles then
			local a, n = self:AlterBulletAngles(pos, ang)
			if a ~= nil then ang = a end
			if n ~= nil then nocompensation = n end
		end
		CreateBullet(pos, ang:Forward(), owner, self, fDamage, self.BulletSpeed, self.BulletClass, true, nocompensation)
	end
end

function meta:SetupForWeaponStatus()
	if self:UseWeaponStatus() then
		self:HideViewAndWorldModel()
	end
end

function meta:HideViewAndWorldModel()
	self:HideViewModel()
	self:HideWorldModel()
end
meta.HideWorldAndViewModel = meta.HideViewAndWorldModel

if SERVER then
	function meta:HideWorldModel()
		self:DrawShadow(false)
	end

	function meta:HideViewModel()
	end
end

if CLIENT then
	local function empty() end
	local function DrawWorldModel(self) if not self.Owner:IsValid() then self:DrawModel() end end
	local function NULLViewModelPosition(self, pos, ang)
		return pos + ang:Forward() * -256, ang
	end
	function meta:HideWorldModel()
		self:DrawShadow(false)
		self.DrawWorldModel = DrawWorldModel
		self.DrawWorldModelTranslucent = DrawWorldModel
	end
	function meta:HideViewModel()
		self.GetViewModelPosition = NULLViewModelPosition
	end
end

function meta:UseWeaponStatus()
	return scripted_ents.GetStored("status_"..self:GetClass())
end

function meta:GiveWeaponStatus()
	if self.Owner and self.Owner:IsValid() and self:UseWeaponStatus() then
		local class = self:GetClass()
		self.Owner:RemoveStatus("weapon_*", false, true, class)
		self.Owner:GiveStatus(class)
	end
end

function meta:RemoveWeaponStatus()
	if self.Owner and self.Owner:IsValid() then
		self.Owner:RemoveStatus(self:GetClass(), false, true)
	end
end
