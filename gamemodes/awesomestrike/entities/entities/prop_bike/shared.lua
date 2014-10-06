ENT.Type = "anim"

ENT.Model = Model("models/props_junk/bicycle01a.mdl")

function ENT:AlignToPlayer()
	local ent = self:GetOwner()
	if ent:IsValid() then
		self:SetPos(ent:GetPos() + ent:GetUp() * 24)
		self:SetAngles(ent:SyncAngles())
	end
end
