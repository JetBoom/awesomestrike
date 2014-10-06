AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.HP = 30

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetModel("models/hunter/misc/sphere1x1.mdl")
	self:PhysicsInitSphere(11.25)
	self:SetMaterial("models/shiny")
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:SetMass(10)
		phys:Wake()
	end

	self:StartMotionController()

	self.ResetCollisionTime = CurTime() + 0.333
	self.Created = CurTime()
end

function ENT:OnTakeDamage(dmginfo)
	local attacker = dmginfo:GetAttacker()
	if attacker:IsValid() and attacker:IsPlayer() then
		local owner = self:GetOwner()
		if not owner:IsValid() or not owner:IsPlayer() or owner:Team() ~= attacker:Team() then
			if dmginfo:IsExplosionDamage() then
				self.HP = 0
			else
				self.HP = self.HP - dmginfo:GetDamage()
			end

			if self.HP <= 0 then
				self.ForceExplode = true
				self:NextThink(CurTime())
			end
		end
	end
end

function ENT:PhysicsSimulate(phys, frametime)
	phys:Wake()

	if self:OwnerShouldGuide() then
		local owner = self:GetOwner()
		local eyeangles = owner:EyeAngles()
		eyeangles.pitch = 0
		local vel = Vector(0, 0, 0)
		if owner:KeyDown(IN_FORWARD) then vel = vel + eyeangles:Forward() end
		if owner:KeyDown(IN_BACK) then vel = vel - eyeangles:Forward() end
		if owner:KeyDown(IN_MOVERIGHT) then vel = vel + eyeangles:Right() end
		if owner:KeyDown(IN_MOVELEFT) then vel = vel - eyeangles:Right() end

		phys:AddVelocity(frametime * 300 * vel)
	end

	return SIM_NOTHING
end

function ENT:Think()
	if self.Exploded then return end

	if self.ResetCollisionTime and CurTime() >= self.ResetCollisionTime then
		self.ResetCollisionTime = nil
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
	end

	if self.ForceExplode then
		self:Explode()
	elseif self:OwnerShouldGuide() then
		local owner = self:GetOwner()
		if owner:KeyDown(IN_ATTACK) then
			if self.BounceTime and CurTime() >= self.BounceTime then
				owner:SetStateVector(self:GetPos())
				self:Explode()
				owner:SetState(STATE_AWESOMELAUNCHEREND, 0.5)
			end
		end
	elseif self.BounceTime and CurTime() >= self.BounceTime then
		self:Explode()
	end

	self:NextThink(CurTime())
	return true
end

function ENT:Explode()
	local pos = self:GetPos()

	self:EmitSound("npc/env_headcrabcanister/explosion.wav", 85, 100)
	util.ScreenShake(pos, 50, 128, 3, 512)
	util.BlastDamage(self, self:GetOwner(), pos, 256, 40)
	ParticleEffect("dusty_explosion_rockets", pos, Angle(0, 0, 0))

	self:Remove()
end

function ENT:PhysicsCollide(data, physobj)
	if 20 < data.Speed and 0.2 < data.DeltaTime then
		self:EmitSound("physics/metal/metal_canister_impact_hard"..math.random(1,3)..".wav", 80, math.random(137, 143))
	end

	if not self.BounceTime then
		self.BounceTime = CurTime() + 1.25
		self.ResetCollisionTime = 0
	end
end

function ENT:OwnerShouldGuide()
	local owner = self:GetOwner()
	return owner:IsValid() and owner:IsPlayer() and owner:Alive() and owner:GetState() == STATE_AWESOMELAUNCHERGUIDE and owner:GetStateEntity() == self
end
