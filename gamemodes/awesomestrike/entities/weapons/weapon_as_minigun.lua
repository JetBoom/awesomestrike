AddCSLuaFile()

if CLIENT then
	SWEP.ViewModelFlip = false
end

SWEP.Slot = 0

SWEP.PrintName = "Minigun"

SWEP.HoldType = "shotgun"
SWEP.SprintHoldType = "passive"

SWEP.Base = "weapon_as_base"

SWEP.ViewModel = "models/weapons/v_mach_m249para.mdl"
SWEP.WorldModel = "models/weapons/w_mach_m249para.mdl"

SWEP.Primary.Sound = Sound("Weapon_m249.Single")
SWEP.ReloadSound = Sound("Weapon_m249.Boxout")
SWEP.BulletDamage = 9
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.12
SWEP.Primary.BusyTime = 0.5
SWEP.Primary.ClipSize = 50

SWEP.Cone = 5.5
SWEP.ConeVariance = 2

SWEP.WalkSpeed = SPEED_SLOW

local vecDown = Vector(0, 0, -1)
function SWEP:Move(move)
	if self:IsShooting() and not self.Owner:OnGround() then
		local aimvec = self.Owner:GetAimVector()
		move:SetVelocity(move:GetVelocity() - math.max(0, aimvec:Dot(vecDown)) * 300 * (self.Owner:GetGravity() / GRAVITY_DEFAULT) * FrameTime() * aimvec)
	end
end

function SWEP:GetKillAction(pl, attacker, dmginfo)
	return KILLACTION_MINIGUNNED, nil
end

function SWEP:IsIdle()
	return self.BaseClass.IsIdle(self)
end
