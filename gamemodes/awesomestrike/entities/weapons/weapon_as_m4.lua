AddCSLuaFile()

SWEP.Slot = 0

SWEP.PrintName = "M4 Carbine"

SWEP.HoldType = "ar2"

SWEP.Base = "weapon_as_base"

SWEP.ViewModel = "models/weapons/v_rif_m4a1.mdl"
SWEP.WorldModel = "models/weapons/w_rif_m4a1.mdl"

SWEP.Primary.Sound = Sound("Weapon_m4a1.Single")
SWEP.BulletDamage = 9
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.13
SWEP.Primary.BusyTime = SWEP.Primary.Delay + 0.1
SWEP.ReloadSound = Sound("Weapon_m4a1.Clipout")
SWEP.Primary.ClipSize = 25

SWEP.Cone = 1.1
SWEP.ConeVariance = 1.25

SWEP.WalkSpeed = SPEED_NORMAL
