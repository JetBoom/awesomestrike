include('shared.lua')

ENT.NextSound = 0

function ENT:Initialize()
	self:DrawShadow(false)

	self.AmbientSound = CreateSound(self, "ambient/machines/combine_shield_touch_loop1.wav")
	self:PlayAmbientSound()

	self.NextSound = CurTime() + math.Rand(0.25, 3)
end

function ENT:Think()
	self:PlayAmbientSound()

	if CurTime() >= self.NextSound then
		self.NextSound = CurTime() + math.Rand(1, 3)
		self:EmitSound("ambient/creatures/flies"..math.random(5)..".wav", 65, 100)
	end
end

function ENT:OnRemove()
	self.AmbientSound:Stop()
end

function ENT:PlayAmbientSound()
	self.AmbientSound:PlayEx(0.65, math.Clamp(100 + self:GetVelocity():Length() * 0.15, 100, 200))
end

local matGlow = Material("sprites/light_glow02_add")
function ENT:Draw()
	local pos = self:GetPos()

	render.SetMaterial(matGlow)
	render.DrawSprite(pos, 16, 16, team.GetLocalColor(self:GetTeam()))
	render.DrawSprite(pos, math.Rand(6, 12), math.Rand(6, 12), color_white)
end
