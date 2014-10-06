AddCSLuaFile()

if CLIENT then
	SWEP.Help = {"Left click: Slash.", "Right click: Dimension slash."}

	SWEP.ForceThirdPerson = true
	SWEP.DrawCrosshair = false
	SWEP.ConeCrosshair = false

	function SWEP:DrawWorldModel()
	end
	SWEP.DrawWorldModelTranslucent = SWEP.DrawWorldModel
end

SWEP.Slot = 0

SWEP.PrintName = "Dimension Blade"

SWEP.HoldType = "melee2"

SWEP.WorldModel = "models/peanut/conansword.mdl"

SWEP.Base = "weapon_as_base"

SWEP.IsPrimary = true
SWEP.IsMelee = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

-- Basic slash
SWEP.MeleeDelay = 1
SWEP.MeleeDamage = 20
SWEP.SwingDuration = 0.15

-- STATE that makes the player move what their velocity was when they started * 1 / stateduration. Immune to melee and bullets. The velocity's Z is clamped >= 0 and velocity length is clamped >= 256 (if they're not moving then just stay put).
SWEP.DimensionSlashSwingDuration = 0.1
SWEP.DimensionSlashAfterDelay = 1
SWEP.DimensionSlashDamage = 45
SWEP.DimensionSlashForce = 400

-- Kind of like Vergil's air slash in DMC.
SWEP.DischargeDelay = 1
SWEP.DischargeAfterDelay = 1
SWEP.DischargeDamage = 20
SWEP.DischargeMaxRepeat = 3
SWEP.DischargeRepeatDelay = 0.35

SWEP.WalkSpeed = SPEED_VERYFAST

function SWEP:GetSwingEnd() return self:GetDTFloat(3) end
function SWEP:SetSwingEnd(time) self:SetDTFloat(3, time) end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	local owner = self.Owner
	owner:InterruptSpecialMoves()

	self:Swing()

	self:SetNextPrimaryAttack(CurTime() + self.MeleeDelay)
end

function SWEP:SecondaryAttack()
	if not self:CanPrimaryAttack() then return end
	local owner = self.Owner
	if not owner:IsIdle() or not owner:OnGround() then return end

	owner:InterruptSpecialMoves()

	local ang = owner:EyeAngles()
	ang.pitch = 0
	owner:SetStateAngles(ang)
	owner:SetState(STATE_BERSERKERSWORDDASH, 0.5)
	self:SetNextPrimaryAttack(owner:GetStateEnd() - 0.1)
end

function SWEP:Swing(duration)
	duration = duration or self.SwingDuration
	self.Owner:DoAttackEvent()
	self:EmitSound("npc/zombie/claw_miss1.wav", 75, math.Rand(75, 80) * (self.SwingDuration / duration))
	self:SetSwingEnd(CurTime() + duration)
end

function SWEP:SwingDimensionSlash()
	self:Swung(true)
end

function SWEP:GetSwingTrace(powerattack)
	return self.Owner:TraceHull(powerattack and 80 or 56, MASK_SOLID, powerattack and 12 or 8, self.Owner:GetMeleeAttackFilter(self))
end

function SWEP:Swung(powerattack)
	if not IsFirstTimePredicted() then return end

	local owner = self.Owner

	if powerattack then
		if SERVER then SuppressHostEvents(owner) end
		local effectdata = EffectData()
			effectdata:SetOrigin(owner:EyePos())
			effectdata:SetAngles(owner:EyeAngles())
			effectdata:SetEntity(owner)
		util.Effect("dimensionbladepowerattack", effectdata)
		if SERVER then SuppressHostEvents(NULL) end
	end

	owner:LagCompensation(true)

	local trace = self:GetSwingTrace(powerattack)
	if trace.Hit then
		local decalstart = trace.HitPos + trace.HitNormal * 8
		local decalend = trace.HitPos - trace.HitNormal * 8
		if trace.MatType == MAT_FLESH or trace.MatType == MAT_BLOODYFLESH or trace.MatType == MAT_ANTLION or trace.MatType == MAT_ALIENFLESH then
			if powerattack then
				self:EmitSound("physics/body/body_medium_break"..math.random(2, 4)..".wav")
			else
				self:EmitSound("ambient/machines/slicer"..math.random(4)..".wav")
			end
			
			util.Decal("Blood", decalstart, decalend)
		else
			self:EmitSound("physics/metal/metal_solid_impact_bullet"..math.random(4)..".wav")
		end
		util.Decal("ManhackCut", decalstart, decalend)

		local ent = trace.Entity
		if ent and ent:IsValid() then
			if SERVER then
				ent:ThrowFromPositionSetZ(owner:GetPos(), powerattack and 400 or 80)
			end
			ent:TakeSpecialDamage(self.MeleeDamage * (powerattack and 1.5 or 1), DMG_SLASH, owner, self, trace.HitPos)
		end
	end

	owner:LagCompensation(false)
end

local function IsValidPlayer(pl)
	return pl and pl:IsValid() and pl:IsPlayer()
end
function SWEP:Think()
	if self:GetSwingEnd() > 0 and CurTime() >= self:GetSwingEnd() then
		self:SetSwingEnd(0)
		self:Swung()
	elseif self.Owner:GetState() == STATE_BERSERKERSWORDDASH then
		if CurTime() >= self:GetNextPrimaryAttack() and self:GetSwingEnd() == 0 then
			self:Swing(0, true)
			self:SetNextPrimaryAttack(CurTime() + 1.5)
		end
	end
end

function SWEP:OnHolster()
	return CurTime() >= self:GetNextPrimaryAttack()
end

function SWEP:CanPrimaryAttack()
	return self.Owner:GetState() ~= STATE_BERSERKERSWORDDASH and CurTime() >= self:GetNextPrimaryAttack() and not self.Owner:GetStateTable().CantUseWeapons
end

RegisterWeaponStatus("weapon_as_dimensionblade", Vector(0, 1, 1), Angle(0, 90, 180))
