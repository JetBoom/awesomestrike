AddCSLuaFile()

if CLIENT then
	SWEP.DrawAmmo = false
	SWEP.ViewModelFOV = 70
	SWEP.ViewModelFlip = false
	SWEP.Help = {"Left click: Stab", "Hold right click: Throwing mode"}

	SWEP.ForceThirdPerson = true
	SWEP.DrawCrosshair = false
	SWEP.ConeCrosshair = true

	SWEP.Cone = 0.01
	SWEP.ConeVariance = 0

	GAMEMODE:SetupCoolDownWeapon(SWEP)
end

SWEP.Slot = 0

SWEP.PrintName = "Knife"

SWEP.Base = "weapon_as_base"

SWEP.ViewModel = "models/weapons/v_knife_t.mdl"
SWEP.WorldModel = "models/weapons/w_knife_t.mdl"

SWEP.Primary.ClipSize = -1
SWEP.Primary.Damage = 19
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 0.55

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Delay = 10
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.IsMelee = true

SWEP.IdleTime = 0.75

SWEP.WalkSpeed = SPEED_VERYFAST

SWEP.SprintHoldType = "grenade"
SWEP.HoldType = "knife"

--SWEP.CoolDown = 10

function SWEP:Think()
	if SERVER or CLIENT and MySelf == self.Owner then
		if self:GetThrowMode() then
			if not self.Owner:KeyDown(IN_ATTACK2) then
				self:SetThrowMode(false)
			end
		elseif self.Owner:KeyDown(IN_ATTACK2) then
			self:SetThrowMode(true)
		end
	end
end

function SWEP:TranslateActivity(act)
	if self:GetThrowMode() then
		return self.ActivityTranslateSprint[act]
	end

	if self.ActivityTranslate[act] ~= nil then
		return self.ActivityTranslate[act]
	end

	return -1
end

function SWEP:GetSwingDistance()
	return 60
end

function SWEP:GetSwingTraces()
	return self.Owner:PenetratingTraceHull(self:GetSwingDistance(), MASK_SOLID, 8, self.Owner:GetMeleeAttackFilter(self))
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.IdleTime)

	local owner = self.Owner

	owner:InterruptSpecialMoves()
	owner:DoAttackEvent()

	if self:GetThrowMode() then
		self:EmitSound("weapons/slam/throw.wav")

		owner:SetState(STATE_THIRDPERSON, 0.5)

		if CLIENT then return end

		local ent = ents.Create("projectile_knife")
		if ent:IsValid() then
			ent:SetPos(owner:GetShootPos())
			ent:SetAngles(owner:EyeAngles())
			ent:SetOwner(owner)
			ent:Spawn()
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:Wake()
				phys:SetVelocityInstantaneous(owner:GetAimVector() * 1000)
				phys:AddAngleVelocity(Vector(0, 500, 0))
			end
			ent:SetPhysicsAttacker(owner)

			util.SpriteTrail(ent, 0, color_white, false, 8, 0, 0.5, 0.02, "trails/tube.vmt")

			owner:StripWeapon(self:GetClass())
			--self:ResetCoolDown()
			--owner:SwitchToBestWeapon(self)
		end
	else
		self:EmitSound("weapons/knife/knife_slash"..math.random(1, 2)..".wav")

		owner:LagCompensation(true)
		local traces = self:GetSwingTraces()
		owner:LagCompensation(false)

		local startpos = owner:GetShootPos()
		for _, trace in pairs(traces) do
			if not trace.Hit or trace.HitPos:Distance(startpos) > self:GetSwingDistance() + 16 then continue end

			if trace.MatType == MAT_FLESH or trace.MatType == MAT_BLOODYFLESH or trace.MatType == MAT_ANTLION or trace.MatType == MAT_ALIENFLESH then
				self:EmitSound("weapons/knife/knife_hit"..math.random(4)..".wav")
				util.Decal("Blood", trace.HitPos + trace.HitNormal * 8, trace.HitPos - trace.HitNormal * 8)
			else
				self:EmitSound("weapons/knife/knife_hitwall1.wav")
				util.Decal("ManhackCut", trace.HitPos + trace.HitNormal * 8, trace.HitPos - trace.HitNormal * 8)
			end

			local ent = trace.Entity
			if ent and ent:IsValid() then
				local blocked = ent.OnHitWithMelee and ent:OnHitWithMelee(owner, self, trace)

				if not blocked then
					ent:TakeSpecialDamage(self.Primary.Damage, DMG_SLASH, owner, self, trace.HitPos)
				end
			end
		end
	end
end

function SWEP:SecondaryAttack()
end

function SWEP:CanPrimaryAttack()
	return CurTime() >= self:GetNextPrimaryFire() and not self.Owner:GetStateTable().CantUseWeapons and CurTime() >= self:GetCoolDown()
end

function SWEP:Reload()
	return false
end

function SWEP:GetKillAction(pl, attacker, dmginfo)
	return KILLACTION_STAB
end

function SWEP:OnHolster()
	return CurTime() >= self:GetNextPrimaryAttack()
end

function SWEP:IsIdle()
	return CurTime() >= self:GetNextPrimaryAttack() and CurTime() >= self:GetNextSecondaryAttack()
end

function SWEP:SetThrowMode(mode)
	self:SetDTBool(3, mode)
end
function SWEP:GetThrowMode() return self:GetDTBool(3) end

util.PrecacheSound("weapons/knife/knife_hit1.wav")
util.PrecacheSound("weapons/knife/knife_hit2.wav")
util.PrecacheSound("weapons/knife/knife_hit3.wav")
util.PrecacheSound("weapons/knife/knife_hit4.wav")
util.PrecacheSound("weapons/knife/knife_slash1.wav")
util.PrecacheSound("weapons/knife/knife_slash2.wav")
util.PrecacheSound("weapons/knife/knife_hitwall1.wav")
util.PrecacheSound("weapons/knife/knife_stab.wav")
