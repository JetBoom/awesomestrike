AddCSLuaFile()

SWEP.Slot = 0

SWEP.PrintName = "Submachine Gun"

SWEP.HoldType = "smg"

SWEP.Base = "weapon_as_base"

SWEP.ViewModel = "models/weapons/v_smg_mp5.mdl"
SWEP.WorldModel = "models/weapons/w_smg_mp5.mdl"

SWEP.Primary.Sound = Sound("Weapon_MP5Navy.Single")
SWEP.ReloadSound = Sound("Weapon_MP5Navy.ClipOut")
SWEP.BulletDamage = 8
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.1
SWEP.Primary.BusyTime = SWEP.Primary.Delay + 0.1
SWEP.Primary.ClipSize = 30

SWEP.Cone = 1.75

SWEP.WalkSpeed = SPEED_NORMAL
