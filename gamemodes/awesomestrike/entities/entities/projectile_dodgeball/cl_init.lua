include("shared.lua")

function ENT:Initialize()
end

function ENT:Think()
end

function ENT:OnRemove()
end

local matGlow = Material("sprites/glow04_noz")
function ENT:Draw()
	self:DrawModel()

	render.SetMaterial(matGlow)
	render.DrawSprite(self:GetPos(), 32, 32, color_white)
end
