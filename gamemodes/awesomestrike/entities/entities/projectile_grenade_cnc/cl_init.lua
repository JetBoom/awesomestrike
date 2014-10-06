include("shared.lua")

function ENT:Initialize()
	self:SetRenderBounds(Vector(-64, -64, -64), Vector(64, 64, 64))

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)
end

function ENT:Think()
	self.Emitter:SetPos(self:GetPos())
end

function ENT:OnRemove()
	--self.Emitter:Finish()
end

function ENT:Draw()
	self:DrawModel()

	local particle = self.Emitter:Add("particles/smokey", self:GetPos())
	particle:SetVelocity(VectorRand():GetNormalized() * math.Rand(1, 4))
	particle:SetDieTime(1.5)
	particle:SetStartAlpha(160)
	particle:SetEndAlpha(0)
	particle:SetStartSize(0)
	particle:SetEndSize(math.Rand(4, 6))
	particle:SetRollDelta(math.Rand(-1.5, 1.5))
	particle:SetRoll(math.Rand(0, 360))
	particle:SetColor(255, 255, 0)
	particle:SetLighting(true)
end
