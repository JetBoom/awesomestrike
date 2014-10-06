if SERVER then
	AddCSLuaFile()
end

SWEP.Slot = 0

SWEP.PrintName = "Smart Rifle"

SWEP.HoldType = "ar2"

SWEP.Base = "weapon_as_base"

SWEP.ViewModel = "models/weapons/v_rif_sg552.mdl"
SWEP.WorldModel = "models/weapons/w_rif_sg552.mdl"

SWEP.Primary.Sound = Sound("Weapon_SG552.Single")
SWEP.ReloadSound = Sound("Weapon_SG552.Clipout")
SWEP.BulletDamage = 7
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.14
SWEP.Primary.BusyTime = SWEP.Primary.Delay + 0.1
SWEP.Primary.ClipSize = 25

SWEP.Cone = 1

SWEP.WalkSpeed = SPEED_NORMAL

SWEP.SmartTarget = true
SWEP.SmartTargetSize = 8

function SWEP:GetKillAction(pl, attacker, dmginfo)
	return KILLACTION_SMARTRIFLED, nil
end
