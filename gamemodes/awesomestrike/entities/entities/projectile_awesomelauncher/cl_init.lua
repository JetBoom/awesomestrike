include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

util.PrecacheSound("weapons/physcannon/energy_sing_loop4.wav")

function ENT:Initialize()
	self.AmbientSound = CreateSound(self, "weapons/physcannon/energy_sing_loop4.wav")
	self:PlayAmbientSound()
end

function ENT:PlayAmbientSound()
	self.AmbientSound:PlayEx(0.75, math.Clamp(self:GetVelocity():Length() * 0.2, 80, 255))
end

function ENT:Think()
	self:PlayAmbientSound()
end

function ENT:OnRemove()
	self.AmbientSound:Stop()
end

function ENT:DrawTranslucent()
	self:SetModelScale(0.475 - math.abs(math.sin(CurTime() * 8)) * 0.25, 0)
	self:DrawModel()

	self:SetModelScale(1, 0)
	render.SetBlend(0.5)
		self:DrawModel()
	render.SetBlend(1)
end
