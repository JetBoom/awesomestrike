include("shared.lua")

util.PrecacheSound("thrusters/Rocket04.wav")

function ENT:Initialize()
	self:SetModelScale(2.5, 0)
	self.AmbientSound = CreateSound(self, "thrusters/Rocket04.wav")
	self:PlayAmbientSound()

	self.BaseClass.Initialize(self)
end

function ENT:PlayAmbientSound()
	self.AmbientSound:PlayEx(0.7, 100 + math.sin(CurTime()))
end

function ENT:Think()
	self:PlayAmbientSound()

	self.BaseClass.Think(self)
end

function ENT:OnRemove()
	self.AmbientSound:Stop()

	self.BaseClass.OnRemove(self)
end

function ENT:Draw()
	self:SetupAngles(self:GetVelocity())

	self:DrawModel()

	self:DoColors()
	self:DrawGlow()
	self:EmitParticles()
end
