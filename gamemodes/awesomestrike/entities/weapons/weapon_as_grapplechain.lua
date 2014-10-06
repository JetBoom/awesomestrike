AddCSLuaFile()

if CLIENT then
	SWEP.Help = {"Left click: Latch chain.", "Jump while reeling: stop reeling"}

	SWEP.ForceThirdPerson = true

	function SWEP:DrawWorldModel()
	end
	SWEP.DrawWorldModelTranslucent = SWEP.DrawWorldModel
end

SWEP.Slot = 0 --SWEP.Slot = 2

SWEP.PrintName = "Grapple Chain"

SWEP.HoldType = "grenade"

SWEP.WorldModel = "models/props_junk/meathook001a.mdl"

SWEP.Base = "weapon_as_base"

SWEP.IsMelee = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 0

SWEP.Secondary.Delay = 0.75
SWEP.Secondary.Automatic = true
SWEP.Secondary.Damage = 15

SWEP.Cone = 0.5
SWEP.ConeVariance = 0

SWEP.WalkSpeed = SPEED_FAST

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	local owner = self.Owner
	local tr = owner:TraceHull(1280, MASK_SOLID_BRUSHONLY, 1)
	if tr.Hit and not tr.HitSky then
		owner:InterruptSpecialMoves()
		owner:DoAttackEvent()
		owner:SetStateVector(tr.HitPos)
		owner:SetState(STATE_CHAIN)
		self:SetDTBool(3, true)
		self:SetNextPrimaryAttack(CurTime() + 9999)
	end
end

function SWEP:SecondaryAttack()
	if not self:CanSwing() then return end
	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)

	local owner = self.Owner

	owner:InterruptSpecialMoves()
	owner:DoAttackEvent()

	self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav")

	owner:LagCompensation(true)
	local traces = self:GetSwingTraces()
	owner:LagCompensation(false)

	local startpos = owner:GetShootPos()
	for _, trace in pairs(traces) do
		if not trace.Hit or trace.HitPos:Distance(startpos) > self:GetSwingDistance() + 16 then continue end

		if trace.MatType == MAT_FLESH or trace.MatType == MAT_BLOODYFLESH or trace.MatType == MAT_ANTLION or trace.MatType == MAT_ALIENFLESH then
			self:EmitSound("npc/roller/blade_cut.wav")
			util.Decal("Blood", trace.HitPos + trace.HitNormal * 8, trace.HitPos - trace.HitNormal * 8)
		else
			self:EmitSound("physics/metal/metal_solid_impact_bullet"..math.random(4)..".wav")
			util.Decal("ManhackCut", trace.HitPos + trace.HitNormal * 8, trace.HitPos - trace.HitNormal * 8)
		end

		local ent = trace.Entity
		if ent and ent:IsValid() and not ent:IsWorld() then
			local blocked = ent.OnHitWithMelee and ent:OnHitWithMelee(owner, self, trace)

			if not blocked then
				ent:TakeSpecialDamage(self.Secondary.Damage, DMG_SLASH, owner, self, trace.HitPos)
			end
		end
	end
end

function SWEP:Deploy()
	local ret = self.BaseClass.Deploy(self)
	if ret and self.Owner:OnGround() then
		self:OnPlayerHitGround()
	end

	return ret
end

function SWEP:OnHolster()
	if self.Owner:IsValid() then
		return self.Owner:GetState() ~= STATE_CHAIN
	end

	return true
end

function SWEP:GetSwingTraces()
	return self.Owner:PenetratingTraceHull(self:GetSwingDistance(), MASK_SOLID, 8, self.Owner:GetMeleeAttackFilter(self))
end

function SWEP:GetSwingDistance()
	return 60
end

function SWEP:IsIdle()
	return CurTime() >= self:GetNextPrimaryAttack() and CurTime() >= self:GetNextSecondaryAttack()
end

function SWEP:CanSwing()
	return CurTime() >= self:GetNextSecondaryAttack() and self.Owner:GetState() ~= STATE_CHAIN
end

function SWEP:CanPrimaryAttack()
	return CurTime() >= self:GetNextPrimaryAttack() and self.Owner:GetState() ~= STATE_CHAIN and not self:GetDTBool(3) and not self.Owner:GetStateTable().CantUseWeapons
end

function SWEP:OnPlayerHitGround()
	if self:GetDTBool(3) then
		self:SetDTBool(3, false)
		self:SetNextPrimaryAttack(CurTime())
	end
end

function SWEP:GetKillAction(pl, attacker, dmginfo)
	return KILLACTION_HOOKED
end

RegisterWeaponStatus("weapon_as_grapplechain", Vector(0, -1, 8), Angle(180, 180, 0), nil, Vector(0.5, 0.5, 0.5), nil, {["ShouldDraw"] = function(self, owner) return owner:GetState() ~= STATE_CHAIN and owner:GetActiveWeapon():IsValid() and owner:GetActiveWeapon():CanPrimaryAttack() end})
