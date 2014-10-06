AddCSLuaFile()

SWEP.Slot = 0

SWEP.PrintName = "Uzi"

SWEP.HoldType = "pistol"

SWEP.Base = "weapon_as_base"

SWEP.ViewModel = "models/weapons/v_smg_mac10.mdl"
SWEP.WorldModel = "models/weapons/w_smg_mac10.mdl"

SWEP.Primary.Sound = Sound("Weapon_MAC10.Single")
SWEP.ReloadSound = Sound("Weapon_MAC10.ClipOut")
SWEP.BulletDamage = 7
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.09
SWEP.Primary.BusyTime = SWEP.Primary.Delay + 0.1
SWEP.Primary.ClipSize = 35

SWEP.Cone = 3
SWEP.ConeVariance = 0.75

SWEP.WalkSpeed = SPEED_NORMAL

function SWEP:GetKillAction(pl, attacker, dmginfo)
	return KILLACTION_SPRAYED, nil
end
