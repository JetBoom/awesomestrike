EFFECT.LifeTime = 0.25

function EFFECT:Init(data)
	self.Pos = data:GetOrigin()
	local normal = data:GetNormal()
	self.Normal = normal
	self.Size = 32 + data:GetMagnitude() * 3
	self.Seed = math.Rand(0, 360)

	self.Sparks = {}
	for i=1, math.random(8, 16) do
		self.Sparks[i] = (normal + VectorRand():GetNormalized()) / 2
	end

	self.DieTime = CurTime() + self.LifeTime
end

function EFFECT:Think()
	return CurTime() <= self.DieTime
end

local matFlash = Material("effects/muzzleflash4")
local matSpark = Material("effects/spark")
local colSprite = Color(255, 255, 255, 255)
function EFFECT:Render()
	local delta = (self.DieTime - CurTime()) / self.LifeTime
	local rot = self.Seed
	local size = delta * self.Size
	local hsize = size * 0.1
	local beamlength = (1 - delta) * self.Size * 0.5
	local beamsize = 2 * delta
	local pos = self.Pos

	render.SetMaterial(matFlash)
	render.DrawQuadEasy(pos, self.Normal, size, hsize, colSprite, rot)
	render.DrawQuadEasy(pos, self.Normal * -1, size, hsize, colSprite, rot)
	render.DrawQuadEasy(pos, self.Normal, size, hsize, colSprite, rot + 45)
	render.DrawQuadEasy(pos, self.Normal * -1, size, hsize, colSprite, rot + 45)
	render.DrawQuadEasy(pos, self.Normal, size, hsize, colSprite, rot + 90)
	render.DrawQuadEasy(pos, self.Normal * -1, size, hsize, colSprite, rot + 90)
	render.DrawQuadEasy(pos, self.Normal, size, hsize, colSprite, rot + 135)
	render.DrawQuadEasy(pos, self.Normal * -1, size, hsize, colSprite, rot + 135)

	--[[render.DrawQuadEasy(pos, self.Normal, size, size * 0.2, colSprite, rot)
	render.DrawQuadEasy(pos, self.Normal, size * 0.2, size, colSprite, rot)
	render.DrawQuadEasy(pos, self.Normal * -1, size, size * 0.2, colSprite, rot)
	render.DrawQuadEasy(pos, self.Normal * -1, size * 0.2, size, colSprite, rot)]]
	render.DrawSprite(pos, size * 0.25, size * 0.25, colSprite)

	render.SetMaterial(matSpark)
	for _, dir in pairs(self.Sparks) do
		render.DrawBeam(pos, pos + beamlength * dir, beamsize, 0, 1, colSprite)
	end
end
