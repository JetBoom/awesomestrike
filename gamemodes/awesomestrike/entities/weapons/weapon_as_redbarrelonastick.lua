AddCSLuaFile()

if CLIENT then
	SWEP.ForceThirdPerson = true
	SWEP.DrawCrosshair = false
	SWEP.ConeCrosshair = false

	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_docks/dock02_pole02a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.319, 1.212, -12.888), angle = Angle(0, 0, 0), size = Vector(0.1, 0.1, 0.1), color = Color(255, 255, 255, 255)},
		["barrel"] = { type = "Model", model = "models/props_c17/oildrum001_explosive.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(11.093, 0, -12.575), angle = Angle(90, 0, 0), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255)}
	}
end

SWEP.Slot = 0 --SWEP.Slot = 2

SWEP.PrintName = "Red Barrel on a Stick"

SWEP.HoldType = "melee2"

SWEP.WorldModel = "models/props_c17/oildrum001_explosive.mdl"

SWEP.Base = "weapon_as_base"

SWEP.IsMelee = true

SWEP.Primary.Delay = 0.7
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.WalkSpeed = SPEED_FAST

SWEP.SwingDuration = 0.15

function SWEP:GetSwingEnd() return self:GetDTFloat(3) end
function SWEP:SetSwingEnd(time) self:SetDTFloat(3, time) end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	local owner = self.Owner
	owner:InterruptSpecialMoves()

	self:Swing()

	self:SetNextPrimaryAttack(CurTime() + self.Primary.Delay)
end

function SWEP:SecondaryAttack()
end

function SWEP:Swing(duration)
	duration = duration or self.SwingDuration
	self.Owner:DoAttackEvent()
	self:EmitSound("npc/zombie/claw_miss1.wav", 75, math.Rand(85, 95) * (self.SwingDuration / duration))
	self:SetSwingEnd(CurTime() + duration)
end

function SWEP:GetSwingTrace()
	return self.Owner:TraceHull(self:GetSwingDistance(), MASK_SOLID, 16, self.Owner:GetMeleeAttackFilter(self))
end

function SWEP:GetSwingDistance()
	return 56
end

function SWEP:OnKnockedDown(oldstate)
	self:SetNextPrimaryAttack(0)
	self:SetSwingEnd(0)
end
SWEP.OnFlinched = SWEP.OnKnockedDown

local function GetKillAction(self, pl, attacker, dmginfo, plstate)
	return KILLACTION_REDBARRELONASTICK, nil
end

function SWEP:CreateBarrel(owner, attacker)
	if CLIENT or self.CreatedBarrel then return end

	self.CreatedBarrel = true

	local ent = ents.Create("prop_physics")
	if ent:IsValid() then
		ent:SetModel("models/props_c17/oildrum001_explosive.mdl")
		ent:SetPos(owner:GetPos())
		ent:SetOwner(owner)
		ent.GetKillAction = GetKillAction
		ent:Spawn()
		ent:SetPhysicsAttacker(owner)
		if attacker then
			owner:TakeSpecialDamage(200, DMG_BLAST, attacker, ent)
		end
		ent:Fire("break", "", 0)
	end
end

function SWEP:ProcessDamage(dmginfo)
	local attacker = dmginfo:GetAttacker()
	if (dmginfo:IsBulletDamage() or dmginfo:IsExplosionDamage()) and (not (attacker:IsValid() and attacker:IsPlayer() and attacker:Team() == self.Owner:Team()) or attacker == self.Owner) then
		timer.SimpleEx(0, self.CreateBarrel, self, self.Owner, attacker)
	end
end

function SWEP:Swung()
	if CLIENT then return end

	local owner = self.Owner

	owner:LagCompensation(true)
	local trace = self:GetSwingTrace()
	owner:LagCompensation(false)

	if trace.Hit and trace.HitPos:Distance(owner:GetShootPos()) <= self:GetSwingDistance() + 16 then
		timer.SimpleEx(0, self.CreateBarrel, self, owner)
		self:Remove()
	end
end

function SWEP:Think()
	if self:GetSwingEnd() > 0 and CurTime() >= self:GetSwingEnd() then
		self:SetSwingEnd(0)
		self:Swung()
	end
end

function SWEP:OnHolster()
	return CurTime() >= self:GetNextPrimaryAttack()
end

function SWEP:IsIdle()
	return CurTime() >= self:GetNextPrimaryAttack()
end

function SWEP:CanPrimaryAttack()
	return CurTime() >= self:GetNextPrimaryAttack() and not self.Owner:GetStateTable().CantUseWeapons
end

function SWEP:GetKillAction(pl, attacker, dmginfo)
	return KILLACTION_REDBARRELONASTICK, nil
end
