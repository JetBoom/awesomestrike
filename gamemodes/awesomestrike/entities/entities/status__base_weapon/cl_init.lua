include("shared.lua")

ENT.RenderBounds = Vector(64, 64, 64)

function ENT:Initialize()
	self:DrawShadow(false)
	--self:SetModel(self.Model)
	if self.RenderBounds then
		--self:SetRenderBoundsNumber(self.RenderBounds)
		self:SetRenderBounds(self.RenderBounds * -1, self.RenderBounds)
	end

	self:GetOwner().WeaponStatus = self
end

function ENT:ShouldDraw(owner)
	return true
end

function ENT:Draw()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	if not self:ShouldDraw(owner) then return end

	local rag = owner:GetRagdollEntity()
	if rag then
		owner = rag
	elseif not owner:Alive() then return end

	local col = owner:GetColor()
	col.r = 255
	col.g = 255
	col.b = 255

	local pos, ang

	if self.AnimAttachment then
		local posang = owner:GetAttachment(owner:LookupAttachment(self.AnimAttachment))
		if posang then
			pos, ang = posang.Pos, posang.Ang
		end
	elseif self.BoneName then
		pos, ang = owner:GetBonePositionMatrixed(owner:LookupBone(self.BoneName))
	end

	if pos then
		if self.Move then
			pos = pos + ang:Up() * self.Move.z + ang:Forward() * self.Move.x + ang:Right() * self.Move.y
		end
		self:SetPos(pos)
		if self.Rotate then
			ang:RotateAroundAxis(ang:Up(), self.Rotate.yaw)
			ang:RotateAroundAxis(ang:Right(), self.Rotate.pitch)
			ang:RotateAroundAxis(ang:Forward(), self.Rotate.roll)
		end
		self:SetAngles(ang)
	end

	local vis = owner:IsPlayer() and owner:CallStateFunction("GetVisibility")
	if vis then
		col.a = math.max(1, vis ^ 2 * 255)
	else
		col.a = math.max(1, col.a)
	end
	self:SetColor(col)
	if self.ModelScale then
		self:SetModelScaleVector(self.ModelScale)
	end
	self:DrawModel()
end
