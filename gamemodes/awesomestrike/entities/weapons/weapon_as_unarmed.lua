AddCSLuaFile()

if CLIENT then
	SWEP.ForceThirdPerson = true
	SWEP.DrawCrosshair = false
	SWEP.ConeCrosshair = false

	function SWEP:DrawWorldModel()
	end
	SWEP.DrawWorldModelTranslucent = SWEP.DrawWorldModel
end

SWEP.Slot = 4

SWEP.PrintName = "Unarmed"

SWEP.HoldType = "fist"
SWEP.SprintHoldType = "normal"

SWEP.Base = "weapon_as_base"

SWEP.Undroppable = true
SWEP.IsMelee = true

SWEP.PunchDelay = 0.5
SWEP.PunchDamage = 8

SWEP.KickDelay = 0.75
SWEP.KickTime = 0.6
SWEP.KickDamage = 16

SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = "none"

SWEP.WalkSpeed = SPEED_FAST

local HitFleshSounds={"npc/vort/foot_hit.wav",
"weapons/crossbow/hitbod1.wav",
"weapons/crossbow/hitbod2.wav"}
local HitSolidSounds={"npc/vort/foot_hit.wav",
"weapons/crossbow/hitbod1.wav",
"weapons/crossbow/hitbod2.wav"}
function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	local owner = self.Owner
	owner:InterruptSpecialMoves()

	local owner = self.Owner

	self:EmitSound("npc/vort/claw_swing"..math.random(1, 2)..".wav", 65)

	owner:LagCompensation(true)

	local traces
	local damage
	local distance
	if owner:KeyDown(IN_BACK) and not owner:KeyDown(IN_FORWARD) then
		self:SetNextPrimaryAttack(CurTime() + self.KickDelay)
		owner:SetState(STATE_UNARMEDKICK1, self.KickTime)

		distance = 55
		damage = self.KickDamage		
	else
		self:SetNextPrimaryAttack(CurTime() + self.PunchDelay)
		owner:DoAttackEvent()

		distance = 48
		damage = self.PunchDamage
	end

	traces = self:GetSwingTraces(distance)

	owner:LagCompensation(false)

	local vel = owner:GetVelocity()
	vel.z = 0

	local startpos = owner:GetShootPos()
	for _, trace in pairs(traces) do
		if not trace.Hit or trace.HitPos:Distance(startpos) > distance + 16 then continue end

		local diff = trace.HitPos - owner:GetPos()
		diff.z = 0
		damage = damage * (1 + vel:Length() * 0.002) * math.max(0.5, vel:GetNormalized():Dot(diff:GetNormalized()))

		local decalstart = trace.HitPos + trace.HitNormal * 8
		local decalend = trace.HitPos - trace.HitNormal * 8
		if trace.MatType == MAT_FLESH or trace.MatType == MAT_BLOODYFLESH or trace.MatType == MAT_ANTLION or trace.MatType == MAT_ALIENFLESH then
			self:EmitSound(HitFleshSounds[math.random(#HitFleshSounds)])
			util.Decal("Impact.Flesh", decalstart, decalend)
		else
			self:EmitSound(HitSolidSounds[math.random(#HitSolidSounds)])
			util.Decal("Impact.Concrete", decalstart, decalend)
		end

		local ent = trace.Entity
		if ent and ent:IsValid() then
			local blocked = ent.OnHitWithMelee and ent:OnHitWithMelee(owner, self, trace)

			if SERVER then
				ent:ThrowFromPosition(owner:GetPos(), damage * (blocked and 0.5 or 1) ^ 1.75, true)
			end

			if not blocked then
				ent:TakeSpecialDamage(damage, DMG_CLUB, owner, self, trace.HitPos)
			end
		end
	end
end

function SWEP:SecondaryAttack()
end

function SWEP:GetSwingTraces(dist, radius)
	return self.Owner:PenetratingTraceHull(dist or 46, MASK_SOLID, radius or 6, self.Owner:GetMeleeAttackFilter(self))
end

function SWEP:Think()
end

function SWEP:OnHolster()
	return CurTime() >= self:GetNextPrimaryAttack()
end

function SWEP:Deploy()
	if SERVER then self.Owner:ShouldDropWeapon(false) end

	return self.BaseClass.Deploy(self)
end

function SWEP:CanPrimaryAttack()
	return CurTime() >= self:GetNextPrimaryAttack() and not self.Owner:GetStateTable().CantUseWeapons
end

function SWEP:GetKillAction(pl, attacker, dmginfo)
	return KILLACTION_BEATUP, nil
end
