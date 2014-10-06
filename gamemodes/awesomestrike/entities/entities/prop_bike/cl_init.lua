include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetModel(self.Model)
end

--[[function ENT:Think()
	self:AlignToPlayer()

	self:NextThink(CurTime())
	return true
end]]

function ENT:DrawTranslucent()
	--self:AlignToPlayer()
	self:DrawModel()
end
