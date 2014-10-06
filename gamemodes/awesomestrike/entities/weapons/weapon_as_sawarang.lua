AddCSLuaFile()

if CLIENT then
	SWEP.ForceThirdPerson = true

	function SWEP:DrawWorldModel()
	end
	SWEP.DrawWorldModelTranslucent = SWEP.DrawWorldModel
end

SWEP.Slot = 0

SWEP.PrintName = "Sawarang"

SWEP.HoldType = "slam"

SWEP.WorldModel = "models/props_junk/meathook001a.mdl"

SWEP.Base = "weapon_as_base"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 0

SWEP.Secondary.Delay = 0.75
SWEP.Secondary.Automatic = true
SWEP.Secondary.Damage = 20

SWEP.Cone = 0.5
SWEP.ConeVariance = 0

SWEP.WalkSpeed = SPEED_FAST

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	-- Returns to user after some time if hitting something solid then it will "grind" at that spot to prevent being able to spam it. Goes through anything not hard. Resets its "already hit" table on the return trip. Strips weapon and gives it back on return.
end

function SWEP:SecondaryAttack()
	if not self:CanPrimaryAttack() then return end
	-- Dumb fire. Stick in wall. Strips weapon.
end

function SWEP:GetKillAction(pl, attacker, dmginfo)
	return KILLACTION_SAWARANG
end

RegisterWeaponStatus("weapon_as_sawarang", Vector(0, -1, 8), Angle(180, 180, 0))
