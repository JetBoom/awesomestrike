ENT.Type = "anim"

ENT.BaseModel = Model("models/hunter/tubes/circle2x2.mdl")
ENT.RingModel = Model("models/hunter/tubes/tube2x2x1.mdl")

function ENT:Think()
	self:AlignToOwner()

	self:NextThink(CurTime())
	return true
end

function ENT:AlignToOwner()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	local ang = owner:SyncAngles()
	self:SetPos(owner:GetPos() + Vector(0, 0, owner:OBBMaxs().z * 0.5) + ang:Forward() * 24)
	ang:RotateAroundAxis(ang:Right(), 90)
	self:SetAngles(ang)
end
