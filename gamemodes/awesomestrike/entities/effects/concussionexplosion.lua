util.PrecacheModel("models/hunter/misc/sphere1x1.mdl")

EFFECT.LifeTime = 0.5

function EFFECT:Init(data)
	self.Entity:SetRenderBounds(Vector(-512, -512, -512), Vector(512, 512, 512))
	self.Entity:SetModel("models/hunter/misc/sphere1x1.mdl")

	sound.Play("weapons/physcannon/energy_sing_explosion2.wav", data:GetOrigin(), 85, 100)

	self.DieTime = CurTime() + self.LifeTime
end

function EFFECT:Think()
	return CurTime() < self.DieTime
end

local matRefraction	= Material("refract_ring")
local matGlow = Material("sprites/glow04_noz")
local matRefract = Material("models/spawn_effect")
function EFFECT:Render()
	local delta = (self.DieTime - CurTime()) / self.LifeTime

	render.UpdateRefractTexture()
	matRefract:SetFloat("$refractamount", delta * 0.05)
	matRefraction:SetFloat("$refractamount", delta * 0.5)

	local pos = self:GetPos()
	local size = (1 - delta) ^ 2 * 15 + 1
	local spritesize = size * 64
	local ringsize = size * 128

	render.SetMaterial(matGlow)
	render.DrawSprite(pos, spritesize, spritesize)

	render.SetMaterial(matRefraction)
	render.DrawQuadEasy(pos, Vector(0, 0, 1), ringsize, ringsize)
	render.DrawQuadEasy(pos, Vector(0, 0, -1), ringsize, ringsize)
	render.DrawQuadEasy(pos, Vector(0, 1, 0), ringsize, ringsize)
	render.DrawQuadEasy(pos, Vector(0, -1, 0), ringsize, ringsize)
	render.DrawQuadEasy(pos, Vector(1, 0, 0), ringsize, ringsize)
	render.DrawQuadEasy(pos, Vector(-1, 0, 0), ringsize, ringsize)

	self:SetModelScale(size * -1, 0)
	render.MaterialOverride(matRefract)
	self:DrawModel()
	self:SetModelScale(size, 0)
	self:DrawModel()
	render.MaterialOverride(0)
end
