EFFECT.LifeTime = 1 / 3

function EFFECT:Init(data)
	self.Dir = data:GetNormal()
	self.Pos = data:GetOrigin() + self.Dir

	self.DieTime = CurTime() + self.LifeTime

	self.Entity:SetRenderBounds(Vector(-320, -320, -320), Vector(320, 320, 320))
end

function EFFECT:Think()
	return CurTime() <= self.DieTime
end

local matRefraction	= Material("refract_ring")
local matGlow = Material("sprites/glow04_noz")
function EFFECT:Render()
	local delta = math.max(0, self.DieTime - CurTime()) / self.LifeTime
	local size = (1 - delta) ^ (1 / 3) * 320

	matRefraction:SetFloat("$refractamount", delta * 0.5)
	render.SetMaterial(matRefraction)
	render.UpdateRefractTexture()
	render.DrawQuadEasy(self.Pos, self.Dir, size, size, color_white, 0)
	render.DrawQuadEasy(self.Pos, self.Dir * -1, size, size, color_white, 0)
end
