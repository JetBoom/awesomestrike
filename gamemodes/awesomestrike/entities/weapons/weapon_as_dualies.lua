AddCSLuaFile()

if CLIENT then
	SWEP.SprintViewRU = 0
end

SWEP.Slot = 0 --SWEP.Slot = 1

SWEP.PrintName = "Dualies"

SWEP.HoldType = "duel"

SWEP.Base = "weapon_as_base"

SWEP.ViewModel = "models/weapons/v_pist_elite.mdl"
SWEP.WorldModel = "models/weapons/w_pist_elite.mdl"

SWEP.Primary.Sound = Sound("Weapon_ELITE.Single")
SWEP.BulletDamage = 10
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.14
SWEP.Primary.BusyTime = SWEP.Primary.Delay + 0.1
SWEP.ReloadSound = Sound("Weapon_ELITE.ClipOut")
SWEP.Primary.ClipSize = 24

SWEP.Cone = 1.75
SWEP.ConeVariance = 0.5

SWEP.WalkSpeed = SPEED_NORMAL

SWEP.MuzzleFlashEffect = false

function SWEP:SendWeaponAnimation()
	self:SendWeaponAnim(self:Clip1() % 2 == 0 and ACT_VM_PRIMARYATTACK or ACT_VM_SECONDARYATTACK)
end
