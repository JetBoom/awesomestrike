include("shared.lua")

function ENT:Initialize()
	self:SetRenderBounds(Vector(-64, -64, -64), Vector(64, 64, 64))
end

function ENT:Draw()
	self:DrawModel()

	local pos = self:GetPos()

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)

	local particle = emitter:Add("sprites/glow04_noz", pos)
	particle:SetVelocity(VectorRand():GetNormalized() * math.Rand(1, 4))
	particle:SetDieTime(1.5)
	particle:SetStartAlpha(160)
	particle:SetEndAlpha(0)
	particle:SetStartSize(2)
	particle:SetEndSize(math.Rand(4, 6))
	particle:SetRollDelta(math.Rand(-1.5, 1.5))
	particle:SetRoll(math.Rand(0, 360))
	particle:SetColor(math.random(200) + 55, math.random(200) + 55, math.random(200) + 55)

	emitter:Finish()
end
