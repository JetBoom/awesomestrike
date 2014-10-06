util.PrecacheModel("models/hunter/misc/sphere1x1.mdl")

-- TODO: Add that strider muzzle thing here.

EFFECT.LifeTime = 0.75

function EFFECT:Init(data)
	self.Entity:SetRenderBounds(Vector(-512, -512, -512), Vector(512, 512, 512))
	self.Entity:SetModel("models/hunter/misc/sphere1x1.mdl")

	sound.Play("weapons/physcannon/energy_sing_explosion2.wav", data:GetOrigin(), 75, 100)

	self.DieTime = CurTime() + self.LifeTime
end

function EFFECT:Think()
	return CurTime() < self.DieTime
end

local matRefractSprite = Material("Effects/strider_bulge_dudv")
local matRefract = Material("models/spawn_effect")
function EFFECT:Render()
	local delta = (self.DieTime - CurTime()) / self.LifeTime

	render.UpdateRefractTexture()
	matRefract:SetFloat("$refractamount", delta * 0.05)
	matRefractSprite:SetFloat("$refractamount", delta * 0.64)

	local size = (1 - delta) ^ 0.5 * 7 + 1

	render.SetMaterial(matRefractSprite)
	render.DrawSprite(self.Entity:GetPos(), size * 32, size * 32)

	self:SetModelScale(size * -1, 0)
	render.MaterialOverride(matRefract)
	self:DrawModel()
	self:SetModelScale(size, 0)
	self:DrawModel()
	render.MaterialOverride()
end
