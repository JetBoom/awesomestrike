AddCSLuaFile()

if CLIENT then
	SWEP.SprintViewRR = 80
	SWEP.SprintViewRU = 0
	SWEP.SprintViewRF = 0
	SWEP.SprintViewMR = 0
	SWEP.SprintViewMU = -16
	SWEP.SprintViewMF = 2
end

SWEP.Slot = 0

SWEP.PrintName = "Desert Eagle"

SWEP.HoldType = "pistol"

SWEP.Base = "weapon_as_base"

SWEP.BulletClass = "projectile_debullet"

SWEP.ViewModel = "models/weapons/v_pist_deagle.mdl"
SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl"

SWEP.Primary.Sound = Sound("Weapon_Deagle.Single")
SWEP.BulletDamage = 24
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.42
SWEP.Primary.BusyTime = 0.5
SWEP.ReloadSound = Sound("Weapon_Deagle.ClipOut")

SWEP.Primary.ClipSize = 7

SWEP.Cone = 1.25
SWEP.ConeVariance = 1.25

SWEP.WalkSpeed = SPEED_NORMAL

SWEP.MuzzleFlashEffect = "muzzleflash1"

--[[SWEP.LuaAnim_Idle = "idle_pistol_heavypistol"

RegisterLuaAnimation("idle_pistol_heavypistol", {
	TimeToArrive = 0.2,
	FrameData = {
		{
			BoneInfo = {
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = -36
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RF = 18
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RU = -20,
					RR = 44,
					RF = -7
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
					RR = -24
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = -23
				},
				['ValveBiped.Bip01_L_Forearm'] = {
					RR = 30,
					RU = -8
				}
			},
			FrameRate = 1
		}
	},
	Type = TYPE_POSTURE,
	PreCallback = function(pl, sGestureName, tGestureTable, iCurFrame, tFrameData, fFrameDelta)
		local wep = pl:GetActiveWeapon()
		tGestureTable.Power = math.Approach(tGestureTable.Power, wep:IsValid() and not wep:IsShooting() and not wep:IsReloading() and 1 or 0, FrameTime() * 5)
	end,
	ShouldPlay = function(pl, sGestureName, tGestureTable, iCurFrame, tFrameData)
		local wep = pl:GetActiveWeapon()
		return wep:IsValid() and wep.LuaAnim_Idle == "idle_pistol_heavypistol"
	end
})]]
