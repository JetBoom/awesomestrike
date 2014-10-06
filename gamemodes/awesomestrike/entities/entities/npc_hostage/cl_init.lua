include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:DrawTranslucent()
	local carry = self:GetCarry()
	if carry:IsValid() then
		local ang = carry:SyncAngles()
		self:SetPos(carry:GetPos())
		self:SetAngles(carry:GetAngles() + ang:Forward() * -12 + ang:Up() * 24)

		self:DrawModel()
	end
end

function ENT:Think()
	if self:GetCarry():IsValid() then
		self:SetPos(self:GetCarry():GetPos())

		self:NextThink(CurTime())
		return true
	end
end

function ENT:BuildBonePositions(NumBones, NumPhysBones)
end

function ENT:SetRagdollBones(bIn)
	self.m_bRagdollSetup = bIn
end

function ENT:DoRagdollBone(PhysBoneNum, BoneNum)
end
