AddCSLuaFile()

if CLIENT then
	SWEP.ViewModelFlip = false
end

SWEP.Slot = 0

SWEP.PrintName = "Defender"

SWEP.HoldType = "shotgun"

SWEP.Base = "weapon_as_base"

SWEP.ViewModel = "models/weapons/v_rif_galil.mdl"
SWEP.WorldModel = "models/weapons/w_rif_galil.mdl"

SWEP.Primary.Sound = Sound("Weapon_Galil.Single")
SWEP.BulletDamage = 8
SWEP.Primary.NumShots = 2
SWEP.Primary.Delay = 0.22
SWEP.Primary.BusyTime = SWEP.Primary.Delay + 0.1
SWEP.ReloadSound = Sound("Weapon_Galil.ClipOut")
SWEP.Primary.ClipSize = 16

SWEP.Cone = 3.5
SWEP.ConeVariance = 0.5

SWEP.WalkSpeed = SPEED_NORMAL
