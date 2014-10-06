AddCSLuaFile()

SWEP.Slot = 0 --SWEP.Slot = 1

SWEP.PrintName = "Dinky Gun"

SWEP.HoldType = "pistol"

SWEP.Base = "weapon_as_base"

SWEP.ViewModel = "models/weapons/v_pist_p228.mdl"
SWEP.WorldModel = "models/weapons/w_pist_p228.mdl"

SWEP.Primary.Sound = Sound("Weapon_P228.Single")
SWEP.BulletDamage = 19
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.28
SWEP.Primary.BusyTime = SWEP.Primary.Delay + 0.1
SWEP.ReloadSound = Sound("Weapon_P228.ClipOut")
SWEP.Primary.ClipSize = 12

SWEP.Cone = 1.25

SWEP.WalkSpeed = SPEED_FAST

function SWEP:GetKillAction(pl, attacker, dmginfo)
	return KILLACTION_DINKIED, nil
end
