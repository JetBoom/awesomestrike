AddCSLuaFile()

SWEP.Slot = 0

SWEP.PrintName = "AK-47"

SWEP.HoldType = "shotgun"

SWEP.Base = "weapon_as_base"

SWEP.ViewModel = "models/weapons/v_rif_ak47.mdl"
SWEP.WorldModel = "models/weapons/w_rif_ak47.mdl"

SWEP.Primary.Sound = Sound("Weapon_ak47.Single")
SWEP.BulletDamage = 10
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.135
SWEP.Primary.BusyTime = SWEP.Primary.Delay + 0.1
SWEP.ReloadSound = Sound("Weapon_AK47.ClipOut")
SWEP.Primary.ClipSize = 25

SWEP.Cone = 1.6
SWEP.ConeVariance = 1.25

SWEP.WalkSpeed = SPEED_NORMAL
