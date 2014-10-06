AddCSLuaFile()

if CLIENT then
	SWEP.ViewModelFlip = false

	SWEP.SprintViewRR = 80
	SWEP.SprintViewRU = 0
	SWEP.SprintViewRF = 0
	SWEP.SprintViewMR = 0
	SWEP.SprintViewMU = -24
	SWEP.SprintViewMF = 2
end

SWEP.Slot = 0 --SWEP.Slot = 1

SWEP.PrintName = "Six Shooter"

SWEP.HoldType = "pistol"

SWEP.Base = "weapon_as_base"

SWEP.ViewModel = "models/weapons/v_357.mdl"
SWEP.WorldModel = "models/weapons/w_357.mdl"

SWEP.Primary.Sound = Sound("Weapon_357.Single")
SWEP.Primary.ClipSize = 6
SWEP.BulletDamage = 16
SWEP.Primary.Delay = 0.5
SWEP.Primary.BusyTime = 0.6666
SWEP.ReloadSound = Sound("Weapon_357.OpenLoader")

SWEP.BulletSpeed = 3500
SWEP.BulletClass = "projectile_sixshooterbullet"

SWEP.MuzzleFlashEffect = "muzzleflash1"

--SWEP.LuaAnim_Idle = "idle_pistol_heavypistol"

SWEP.Cone = 0.8

SWEP.WalkSpeed = SPEED_FAST

function SWEP:GetKillAction(pl, attacker, dmginfo)
	return KILLACTION_SIXSHOOTER, nil
end
