AddCSLuaFile()

if CLIENT then
	SWEP.DrawAmmo = false
	SWEP.ViewModelFOV = 70
	SWEP.ViewModelFlip = true

	SWEP.Cone = 0.5
	SWEP.ConeVariance = 0

	GAMEMODE:SetupCoolDownWeapon(SWEP)
end

SWEP.Slot = 0 --SWEP.Slot = 2

SWEP.PrintName = "Concussion Grenade"

SWEP.Base = "weapon_as_base"

SWEP.ViewModel = "models/weapons/v_eq_flashbang.mdl"
SWEP.WorldModel = "models/weapons/w_eq_flashbang.mdl"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 0.5

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Delay = 10
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.IsGrenade = true

SWEP.WalkSpeed = SPEED_FAST

SWEP.SprintHoldType = "normal"
SWEP.HoldType = "grenade"

SWEP.CoolDown = 15

SWEP.GrenadeClass = "projectile_grenade_cnc"

function SWEP:Think()
	if self:GetFinishTime() ~= 0 then
		if CurTime() >= self:GetFinishTime() then
			self:SetThrowTime(0)
			self:SetFinishTime(0)
			self:ResetCoolDown()
			if SERVER then
				self.Owner:SwitchToBestWeapon()
			end
		end

		self:NextThink(CurTime())
		return true
	elseif self:GetThrowTime() ~= 0 then
		if CurTime() >= self:GetThrowTime() then
			self:Throw()
		end

		self:NextThink(CurTime())
		return true
	end
end

function SWEP:Throw()
	self:SetThrowTime(0)

	local owner = self.Owner

	owner:InterruptSpecialMoves()
	owner:DoAttackEvent()

	self:EmitSound("weapons/slam/throw.wav")

	self:SendWeaponAnim(ACT_VM_THROW)
	self:SetFinishTime(CurTime() + self:SequenceDuration())

	if CLIENT then return end

	local ent = ents.Create(self.GrenadeClass)
	if ent:IsValid() then
		ent:SetPos(owner:GetShootPos())
		ent:SetAngles(owner:EyeAngles())
		ent:SetOwner(owner)
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
			phys:SetVelocityInstantaneous(owner:GetAimVector() * 1000)
			phys:AddAngleVelocity(Vector(0, 500, 0))
		end
		ent:SetPhysicsAttacker(owner)
	end
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	self:SendWeaponAnim(ACT_VM_PULLPIN)
	self:SetThrowTime(CurTime() + self:SequenceDuration())

	self:NextThink(CurTime())
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
	return false
end

function SWEP:CanPrimaryAttack()
	return self:GetThrowTime() == 0 and self:GetFinishTime() == 0 and not self.Owner:GetStateTable().CantUseWeapons and CurTime() >= self:GetCoolDown()
end

function SWEP:IsIdle()
	return self:GetThrowTime() == 0 and self:GetFinishTime() == 0
end

function SWEP:OnHolster()
	if self:IsIdle() then
		self:SetThrowTime(0)
		return true
	end

	return false
end

function SWEP:SetThrowTime(time)
	self:SetDTFloat(2, time)
end

function SWEP:GetThrowTime()
	return self:GetDTFloat(2)
end

function SWEP:SetFinishTime(time)
	self:SetDTFloat(3, time)
end

function SWEP:GetFinishTime()
	return self:GetDTFloat(3)
end
