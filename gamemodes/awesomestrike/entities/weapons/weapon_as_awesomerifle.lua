AddCSLuaFile()

if CLIENT then
	SWEP.VElements = {
		["1"] = { type = "Model", model = "models/props_c17/substation_circuitbreaker01a.mdl", bone = "v_weapon.awm_parent", rel = "base", pos = Vector(-0.069, 3.5, -11.5), angle = Angle(90, 90, 0), size = Vector(0.014, 0.014, 0.009)},
		["3++"] = { type = "Model", model = "models/props_phx/construct/windows/window_angle90.mdl", bone = "v_weapon.awm_parent", rel = "base", pos = Vector(-1, 0, 10), angle = Angle(0, -45, 0), size = Vector(0.039, 0.039, 0.039)},
		["3"] = { type = "Model", model = "models/props_phx/construct/windows/window_angle90.mdl", bone = "v_weapon.awm_parent", rel = "base", pos = Vector(0, 1.5, 10), angle = Angle(0, 45, 0), size = Vector(0.039, 0.039, 0.039)},
		["2"] = { type = "Model", model = "models/props_c17/tv_monitor01.mdl", bone = "v_weapon.awm_parent", rel = "base", pos = Vector(-1.3, -0.782, -10.969), angle = Angle(260, 0, 90), size = Vector(0.1, 0.1, 0.1)},
		["3+"] = { type = "Model", model = "models/props_phx/construct/windows/window_angle90.mdl", bone = "v_weapon.awm_parent", rel = "base", pos = Vector(0, -1.5, 10), angle = Angle(0, 225, 0), size = Vector(0.039, 0.039, 0.039)},
		["base"] = { type = "Model", model = "models/props_phx/construct/metal_wire_angle360x2.mdl", bone = "v_weapon.awm_parent", rel = "", pos = Vector(0, 3.4, 16), angle = Angle(0, 0, 0), size = Vector(0.019, 0.019, 0.1)},
		["3+++"] = { type = "Model", model = "models/props_phx/construct/windows/window_angle90.mdl", bone = "v_weapon.awm_parent", rel = "base", pos = Vector(1, 0, 10), angle = Angle(0, 135, 0), size = Vector(0.039, 0.039, 0.039)}
	}

	SWEP.WElements = {
		["1"] = { type = "Model", model = "models/props_c17/substation_circuitbreaker01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(-0.069, 4.15, -18.164), angle = Angle(90, 90, 0), size = Vector(0.014, 0.014, 0.009)},
		["3++"] = { type = "Model", model = "models/props_phx/construct/windows/window_angle90.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(-1, 0, 10), angle = Angle(0, -45, 0), size = Vector(0.039, 0.039, 0.039)},
		["3"] = { type = "Model", model = "models/props_phx/construct/windows/window_angle90.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 1.5, 10), angle = Angle(0, 45, 0), size = Vector(0.039, 0.039, 0.039)},
		["2"] = { type = "Model", model = "models/props_c17/tv_monitor01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(-1.3, -0.782, -22.355), angle = Angle(260, 0, 90), size = Vector(0.1, 0.1, 0.1)},
		["3+"] = { type = "Model", model = "models/props_phx/construct/windows/window_angle90.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, -1.5, 10), angle = Angle(0, 225, 0), size = Vector(0.039, 0.039, 0.039)},
		["base"] = { type = "Model", model = "models/props_phx/construct/metal_wire_angle360x2.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(30, 1.5, -3), angle = Angle(0, 90, 90), size = Vector(0.019, 0.019, 0.1)},
		["3+++"] = { type = "Model", model = "models/props_phx/construct/windows/window_angle90.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(1, 0, 10), angle = Angle(0, 135, 0), size = Vector(0.039, 0.039, 0.039)}
	}
end

SWEP.Slot = 0

SWEP.PrintName = "Awesome Rifle"

SWEP.HoldType = "ar2"
SWEP.SprintHoldType = "passive"

SWEP.Base = "weapon_as_base"

SWEP.ViewModel = "models/weapons/v_snip_awp.mdl"
SWEP.WorldModel = "models/weapons/w_snip_awp.mdl"

SWEP.Primary.Sound = Sound("Weapon_AWP.Single")
SWEP.BulletDamage = 75
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 1.5
SWEP.Primary.BusyTime = 0.5
SWEP.ReloadSound = Sound("Weapon_AWP.ClipOut")

SWEP.Primary.ClipSize = 2
SWEP.Primary.Automatic = false
SWEP.Secondary.Automatic = false

SWEP.Cone = 0.01

SWEP.WalkSpeed = SPEED_SLOW

SWEP.BulletSpeed = 1100

SWEP.BulletClass = "projectile_arbullet"

SWEP.MuzzleFlashEffect = "muzzleflash3"

function SWEP:CanReload()
	return self.Owner:GetState() ~= STATE_AWESOMERIFLEGUIDE
end

if SERVER then
function SWEP:DoShoot()
	local owner = self.Owner

	if owner:KeyPressed(IN_ATTACK2) then
		owner:ViewPunch(Angle(-30, math.Rand(-5, 5), math.Rand(-5, 5)))
	end

	local bullet = CreateBullet(owner:GetShootPos(), owner:GetAimVector(), owner, self, self.BulletDamage, self.BulletSpeed, self.BulletClass, true)
	if bullet and bullet:IsValid() then
		if not owner:KeyDown(IN_ATTACK2) then
			owner:SetState(STATE_AWESOMERIFLEGUIDE, nil, bullet)
		end
		util.SpriteTrail(bullet, 0, team.GetColor(owner:Team()) or color_white, false, 8, 0, 0.75, 0.02, "trails/smoke.vmt")
	end
end
end

function SWEP:SecondaryAttack()
	if self.Owner:GetState() == STATE_AWESOMERIFLEGUIDE or self.Owner:GetState() == STATE_AWESOMERIFLEEND then return end

	self:PrimaryAttack()
end

function SWEP:GetKillAction(pl, attacker, dmginfo)
	return (attacker:GetState() == STATE_AWESOMERIFLEGUIDE or attacker:GetState() == STATE_AWESOMERIFLEEND) and KILLACTION_AWESOMERIFLEGUIDED or KILLACTION_AWESOMERIFLE, nil
end
