AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.BulletHitEffect = false

function ENT:Initialize()
	self.BaseClass.Initialize(self)

	self.GuideSpeed = self.GuideSpeed or self.Speed

	self:SetModelScale(2.5, 0)

	self:StartMotionController()
end

function ENT:GetSpeed()
	if self:OwnerShouldGuide() then
		local owner = self:GetOwner()
		if owner:KeyDown(IN_FORWARD) then return self.Speed * 1.333 end
		if owner:KeyDown(IN_BACK) then return self.Speed * 0.666 end
	end

	return self.GuideSpeed
end

function ENT:PhysicsSimulate(phys, frametime)
	phys:Wake()

	if self:OwnerShouldGuide() and not (self.GuideStun and CurTime() < self.GuideStun) then
		local owner = self:GetOwner()
		local newangles = owner:EyeAngles()
		self:SetAngles(newangles)
		self.GuideSpeed = math.Approach(self.GuideSpeed, self:GetSpeed(), frametime * 1024)
		phys:SetVelocityInstantaneous(newangles:Forward() * self.GuideSpeed)
	end

	return SIM_NOTHING
end

function ENT:OnHit(tr, prehit, bounce)
	local owner = self:GetOwner()

	local effectdata = EffectData()
		effectdata:SetOrigin(tr.HitPos)
		effectdata:SetNormal(tr.HitNormal)
		effectdata:SetMagnitude(owner:IsValid() and owner:IsPlayer() and owner:Team() or 0)
	util.Effect("hit_arbullet", effectdata)

	if self:OwnerShouldGuide() then
		if bounce then
			local newangles = bounce:Angle()
			owner:SetStateAngles(newangles)
			self:SetAngles(newangles)
			self:GetPhysicsObject():SetVelocityInstantaneous(bounce * self:GetSpeed())
			self.GuideStun = CurTime() + 0.1

			return true
		end

		owner:SetStateVector(tr.HitPos + tr.HitNormal * 2)
		owner:SetState(STATE_AWESOMERIFLEEND, 0.5)
	end
end

function ENT:OwnerShouldGuide()
	local owner = self:GetOwner()
	return owner:IsValid() and owner:IsPlayer() and owner:Alive() and owner:GetState() == STATE_AWESOMERIFLEGUIDE and owner:GetStateEntity() == self
end
