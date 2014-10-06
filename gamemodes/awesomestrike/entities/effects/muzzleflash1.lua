EFFECT.LifeTime = 0.2

function EFFECT:Init(data)
	self.Weapon = data:GetEntity()
	self.DieTime = CurTime() + self.LifeTime
	self.Rotation = math.Rand(0, 360)

	self.Entity:SetRenderBounds(Vector() * -128, Vector() * 128)
end

function EFFECT:Think()
	return CurTime() < self.DieTime
end

local matFlash = Material("effects/muzzleflash2")
function EFFECT:Render()
	local rt = CurTime()
	local delta = (self.DieTime - rt) / self.LifeTime
	if delta <= 0 then return end

	local wep = self.Weapon
	if not wep:IsValid() then return end

	local owner = wep:GetOwner()
	if not owner:IsValid() then return end

	if owner:IsFirstPersonEntity() then
		wep = owner:GetViewModel() or wep
		if not wep:IsValid() then return end
	end

	local attach = wep:GetAttachment(1)
	if not attach then return end

	local pos = attach.Pos
	local dir = owner:GetAimVector()
	local rdir = dir * -1
	local size = 24 * delta

	render.SetMaterial(matFlash)
	render.DrawQuadEasy(pos, dir, size * 0.5, size * 0.5, color_white, self.Rotation)
	render.DrawQuadEasy(pos, dir, size * 0.2, size, color_white, self.Rotation)
	render.DrawQuadEasy(pos, dir, size, size * 0.2, color_white, self.Rotation)
	render.DrawQuadEasy(pos, rdir, size * 0.5, size * 0.5, color_white, self.Rotation)
	render.DrawQuadEasy(pos, rdir, size * 0.2, size, color_white, self.Rotation)
	render.DrawQuadEasy(pos, rdir, size, size * 0.2, color_white, self.Rotation)
end
