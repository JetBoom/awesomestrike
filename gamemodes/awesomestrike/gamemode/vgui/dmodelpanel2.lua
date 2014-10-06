local PANEL = {}

function PANEL:GetModel()
	if IsValid(self.Entity) then
		return self.Entity:GetModel()
	end

	return "models/error.mdl"
end

function PANEL:AutoCam(axis)
	if not self.Entity then return end

	local maxs, mins = self.Entity:GetRenderBounds()
	local dist = mins:Distance(maxs) + 8
	local center = (mins + maxs) / 2
	self:SetLookAt(center)
	if axis then
		local x = 0
		local y = 0
		local z = 0
		if axis == 1 then
			x = dist
			y = dist
		elseif axis == 2 then
			y = dist
		elseif axis == 3 then
			x = -dist
			y = dist
		elseif axis == 4 then
			x = dist
		elseif axis == 6 then
			x = -dist
		elseif axis == 7 then
			x = dist
			y = -dist
		elseif axis == 8 then
			y = -dist
		elseif axis == 9 then
			x = -dist
			y = -dist
		end
		self:SetCamPos(center + Vector(x, y, z))
	else
		local x = maxs.x - mins.x
		local y = maxs.y - mins.y
		local z = maxs.z - mins.z
		if z > x and z > y then
			self:SetCamPos(center + Vector(0, -dist, 0)) -- Look to the front of the entity.
		elseif y > x then
			self:SetCamPos(center + Vector(0, dist, 0)) -- Look to the right on the entity.
		else
			self:SetCamPos(center + Vector(0, 0, dist)) -- Look down on the entity.
		end
	end
end

function PANEL:SetMaterial(str)
	if self.Entity and self.Entity:IsValid() then self.Entity:SetMaterial(str) end
end

function PANEL:SetSkin(skin)
	if self.Entity and self.Entity:IsValid() then self.Entity:SetSkin(skin) end
end

function PANEL:GetRotateRate()
	return self.m_RotateRate or 0
end

function PANEL:SetRotateRate(rate)
	self.m_RotateRate = rate
end

function PANEL:LayoutEntity(Entity)
	if self.bAnimated then
		self:RunAnimation()
	end

	local rate = self:GetRotateRate()
	if rate ~= 0 then
		Entity:SetAngles(Angle(0, CurTime() * rate, 0))
	end
end

derma.DefineControl("DModelPanel2", "An expanded DModelPanel", PANEL, "DModelPanel")
