include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-128, -128, -128), Vector(128, 128, 128))

	self:GetOwner().MedRayReload = self

	self.AmbientSound = CreateSound(self, "items/suitcharge1.wav")

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(20, 32)

	self.DieTime = CurTime() + 3
end

function ENT:Think()
	self.AmbientSound:PlayEx(0.75, math.min(255, 255 - (self.DieTime - CurTime()) * 80))

	local owner = self:GetOwner()
	if owner:IsValid() then
		self.Emitter:SetPos(owner:EyePos())
	end
end

function ENT:OnRemove()
	self.AmbientSound:Stop()
	--self.Emitter:Finish()
	self:GetOwner().MedRayReload = nil
end

local function partthink(particle)
	local delta = math.max(0, particle.Death - CurTime())
	local sat = delta * 500
	particle:SetColor(sat, 255, sat)
	particle:SetRollDelta(delta * 14)

	if particle.Owner:IsValid() then
		particle:SetVelocity(particle.BaseVelocity + particle.Owner:GetVelocity())
	end

	particle:SetNextThink(CurTime() + 0.025)
end

function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	local startpos
	local wep = owner:GetActiveWeapon()
	if wep:IsValid() then
		local attach
		if owner == MySelf and not NOX_VIEW then
			attach = owner:GetViewModel():GetAttachment(1)
		else
			attach = wep:GetAttachment(1)
		end
		if attach then
			startpos = attach.Pos
		end
	end	

	startpos = startpos or owner:GetShootPos()

	local eyeangles = owner:EyeAngles()
	eyeangles:RotateAroundAxis(eyeangles:Forward(), math.Rand(0, 360))

	local up = eyeangles:Up()

	self.Emitter:SetPos(startpos)
	local particle = self.Emitter:Add("sprites/glow04_noz", startpos + up * 100)
	particle.BaseVelocity = up * -200
	particle.Owner = owner
	particle:SetVelocity(owner:GetVelocity() + particle.BaseVelocity)
	local die = math.Rand(0.39, 0.45)
	particle.Death = CurTime() + die
	particle:SetDieTime(die)
	particle:SetStartSize(0)
	particle:SetEndSize(38)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetThinkFunction(partthink)
	particle:SetNextThink(CurTime() + 0.025)
end
