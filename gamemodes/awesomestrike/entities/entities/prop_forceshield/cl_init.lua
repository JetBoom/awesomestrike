include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetModel(self.BaseModel)

	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
end

local matWireFrame = Material("models/wireframe")
local matRefract = Material("models/spawn_effect")
local matGlow = Material("sprites/glow04_noz")
function ENT:DrawTranslucent()
	self:AlignToOwner()

	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	local power = CosineInterpolation(0, 1, math.Clamp((CurTime() - owner:GetStateStart()) / STATES[STATE_FORCESHIELD].PrepTime, 0, 1))
	local col = team.GetColor(owner:Team()) or color_white

	local pos = self:GetPos()

	local dlight = DynamicLight(self:EntIndex())
	if dlight then
		dlight.Pos = pos
		dlight.r = (col.r + 255) / 2
		dlight.g = (col.g + 255) / 2
		dlight.b = (col.b + 255) / 2
		dlight.Brightness = power * 4
		local size = power * 128
		dlight.Size = size
		dlight.Decay = size * 2
		dlight.DieTime = CurTime() + 0.5
	end

	render.SetMaterial(matGlow)
	render.DrawSprite(pos, power * 92, power * 92, col)

	render.UpdateRefractTexture()
	matRefract:SetFloat("$refractamount", power * 0.05)

	self:SetModelScale(power * 1.1, 0)

	render.MaterialOverride(matRefract)
		self:DrawModel()
	render.MaterialOverride()
end
