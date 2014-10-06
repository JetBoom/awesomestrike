AddCSLuaFile()

if CLIENT then
	SWEP.ViewModelFlip = false

	SWEP.SprintViewMF = -16
end

SWEP.Slot = 0

SWEP.PrintName = "Awesome Launcher"

SWEP.HoldType = "rpg"
SWEP.SprintHoldType = "passive"

SWEP.Base = "weapon_as_base"

SWEP.ViewModel = "models/weapons/v_rpg.mdl"
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"

SWEP.Primary.Sound = Sound("npc/env_headcrabcanister/launch.wav")
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 3.5
SWEP.Primary.BusyTime = 0.5
SWEP.Primary.ClipSize = 1
SWEP.ReloadSound = Sound("Weapon_RPG.Reload")

SWEP.Primary.Automatic = false
SWEP.Secondary.Automatic = false

SWEP.Cone = 0.5

SWEP.WalkSpeed = SPEED_SLOW

SWEP.BulletSpeed = 900

function SWEP:CanReload()
	return self.Owner:GetState() ~= STATE_AWESOMELAUNCHERGUIDE
end

if SERVER then
function SWEP:DoShoot()
	local owner = self.Owner

	owner:ViewPunch(Angle(-30, math.Rand(-5, 5), math.Rand(-5, 5)))

	local tr = owner:TraceHull(32, MASK_SOLID, 8)
	local pos = tr.Hit and tr.HitPos + tr.HitNormal * 16 or owner:GetShootPos()
	local dir = owner:GetAimVector()
	local vel = dir * self.BulletSpeed

	local bullet = ents.Create("projectile_awesomelauncher")
	if bullet:IsValid() then
		bullet:SetPos(pos)
		bullet:SetAngles(dir:Angle())
		bullet:SetOwner(owner)
		bullet:StoreAttackerState(owner)

		bullet.Inflictor = self

		bullet:SetVelocity(vel)

		bullet:Spawn()

		local phys = bullet:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetVelocityInstantaneous(vel)
		end

		if not owner:KeyDown(IN_ATTACK2) then
			owner:SetState(STATE_AWESOMELAUNCHERGUIDE, nil, bullet)
		end

		local col = team.GetColor(owner:Team()) or color_white
		bullet:SetColor(Color((col.r + 255) / 2, (col.g + 255) / 2, (col.b + 255) / 2, 255))
		util.SpriteTrail(bullet, 0, col, false, 24, 0, 1.5, 0.02, "trails/plasma.vmt")
	end
end
end

function SWEP:SecondaryAttack()
	if self.Owner:GetState() == STATE_AWESOMELAUNCHERGUIDE or self.Owner:GetState() == STATE_AWESOMELAUNCHEREND then return end

	self:PrimaryAttack()
end

function SWEP:GetKillAction(pl, attacker, dmginfo)
	return (attacker:GetState() == STATE_AWESOMELAUNCHERGUIDE or attacker:GetState() == STATE_AWESOMELAUNCHEREND) and KILLACTION_AWESOMELAUNCHERGUIDED or KILLACTION_AWESOMELAUNCHER, nil
end
