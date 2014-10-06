EFFECT.LifeTime = 0.25

function EFFECT:Init(data)
	self.Pos = data:GetOrigin()
	local normal = data:GetNormal()
	self.Normal = normal
	self.Size = 32 + data:GetMagnitude() * 3
	self.Seed = math.Rand(0, 360)

	self.DieTime = CurTime() + self.LifeTime

	sound.Play("physics/metal/metal_solid_impact_bullet"..math.random(4)..".wav", self.Pos, 70, math.Rand(90, 110))
end

function EFFECT:Think()
	return CurTime() <= self.DieTime
end

local matRefraction	= Material("refract_ring")
local matFlash = Material("effects/muzzleflash4")
local colSprite = Color(255, 255, 255, 255)
function EFFECT:Render()
	local delta = (self.DieTime - CurTime()) / self.LifeTime
	local rot = self.Seed
	local size = delta * self.Size
	local hsize = size * 0.1
	local pos = self.Pos

	local norm = self.Normal
	local normr = self.Normal * -1

	render.SetMaterial(matFlash)
	render.DrawQuadEasy(pos, norm, size, hsize, colSprite, rot)
	render.DrawQuadEasy(pos, normr, size, hsize, colSprite, rot)
	render.DrawQuadEasy(pos, norm, size, hsize, colSprite, rot + 90)
	render.DrawQuadEasy(pos, normr, size, hsize, colSprite, rot + 90)

	render.DrawSprite(pos, size * 0.25, size * 0.25, colSprite)

	local size2 = (1 - delta) ^ 1.2 * 48
	matRefraction:SetFloat("$refractamount", delta)
	render.SetMaterial(matRefraction)
	render.UpdateRefractTexture()
	render.DrawSprite(pos, size2, size2, colSprite)
	render.DrawQuadEasy(pos, norm, size2, size2, colSprite)
	render.DrawQuadEasy(pos, normr, size2, size2, colSprite)
end
