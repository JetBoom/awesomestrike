AddCSLuaFile()

if CLIENT then
	local shootingpower = 0
	function SWEP:GetViewModelPosition(pos, ang)
		shootingpower = math.Approach(shootingpower, self:IsShooting() and 1 or 0, FrameTime() * 5)
		ang:RotateAroundAxis(ang:Forward(), shootingpower * 80)
		pos = pos + 4 * shootingpower * ang:Right()

		return self.BaseClass.GetViewModelPosition(self, pos, ang)
	end
end

SWEP.Slot = 0 --SWEP.Slot = 1

SWEP.PrintName = "Quick Silver"

SWEP.HoldType = "pistol"

SWEP.Base = "weapon_as_base"

SWEP.ViewModel = "models/weapons/v_pist_usp.mdl"
SWEP.WorldModel = "models/weapons/w_pist_usp.mdl"

SWEP.Primary.Sound = Sound("Weapon_USP.Single")
SWEP.Primary.NumShots = 1
SWEP.ReloadSound = Sound("Weapon_USP.ClipOut")
SWEP.Primary.ClipSize = 12
SWEP.BulletDamage = 80 / SWEP.Primary.ClipSize
SWEP.Primary.Delay = 0.6 / SWEP.Primary.ClipSize
SWEP.Primary.BusyTime = SWEP.Primary.Delay + 0.1

SWEP.Cone = 1.5
SWEP.ConeVariance = 0.75

SWEP.WalkSpeed = SPEED_FAST

function SWEP:GetKillAction(pl, attacker, dmginfo)
	return KILLACTION_QUICKSILVERED, nil
end
