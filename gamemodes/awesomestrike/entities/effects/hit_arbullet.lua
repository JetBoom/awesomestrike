function EFFECT:Init(data)
	self.Dir = data:GetNormal() * -1
	self.Pos = data:GetOrigin() + self.Dir * 0.5
	self.TeamID = math.Round(data:GetMagnitude())
	local col = team.GetColor(self.TeamID) or color_white
	self.Color = col

	self.DieTime = CurTime() + 0.5

	sound.Play("weapons/fx/rics/ric"..math.random(1,5)..".wav", self.Pos, 74, math.Rand(130, 170))
	sound.Play("weapons/physcannon/energy_sing_explosion2.wav", self.Pos, 78, math.Rand(130, 148))
end

function EFFECT:Think()
	return CurTime() <= self.DieTime
end

local matRefraction	= Material("refract_ring")
local matGlow = Material("sprites/glow04_noz")
function EFFECT:Render()
	local ct = CurTime()
	local col = self.Color

	if not self.EndParticles then
		self.EndParticles = true

		local r, g, b = col.r, col.g, col.b

		local emitter = ParticleEmitter(self.Pos)
		emitter:SetNearClip(24, 32)

		for i=1, 16 do
			local particle = emitter:Add("sprites/glow04_noz", self.Pos)
			particle:SetDieTime(math.Rand(0.5, 0.75))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(1)
			particle:SetEndSize(16)
			particle:SetVelocity((VectorRand():GetNormalized() + self.Dir):GetNormalized() * math.Rand(500, 1500))
			particle:SetAirResistance(1000)
			particle:SetColor(r, g, b)
		end

		emitter:Finish()
	end

	local delta = math.max(0, self.DieTime - ct)

	local size1 = delta * 256
	render.SetMaterial(matGlow)
	render.DrawSprite(self.Pos, size1, size1, col)
	render.SetMaterial(matGlow)
	render.DrawQuadEasy(self.Pos + self.Dir * 0.1, self.Dir, size1, size1, col)

	local size2 = (((0.5 - delta) / 0.5) ^ 1.2) * 768
	matRefraction:SetFloat("$refractamount", delta * 0.5)
	render.SetMaterial(matRefraction)
	render.UpdateRefractTexture()
	render.DrawQuadEasy(self.Pos, self.Dir, size2, size2, color_white, 0)
	render.DrawQuadEasy(self.Pos, self.Dir * -1, size2, size2, color_white, 0)
end
