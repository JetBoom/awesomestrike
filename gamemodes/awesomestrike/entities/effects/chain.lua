function EFFECT:Init(data)
	local owner = data:GetEntity()
	if owner and owner:IsValid() then
		self.AmbientSound = CreateSound(owner, "weapons/tripwire/ropeshoot.wav")
		owner.Chain = self.Entity
	end

	self.Owner = owner

	self.Entity:SetModel("models/props_junk/meathook001a.mdl")
	self.Entity:SetModelScale(0.5, 0)
end

local vViewSpace = Vector(64, 64, 64)
function EFFECT:Think()
	local owner = self.Owner
	if owner:IsValid() and owner:GetState() == STATE_CHAIN and owner:Alive() and owner.Chain == self.Entity then
		self.Entity:SetPos(owner:GetShootPos())
		self.Entity:SetRenderBoundsWS(owner:GetShootPos(), owner:GetStateVector(), vViewSpace)

		if owner:CallStateFunction("IsReeling") then
			if self.AmbientSound then
				self.AmbientSound:Stop()
			end

			if not self.PlayedReelSounds then
				self.PlayedReelSounds = true

				local pitch = math.random(97, 103)
				sound.Play("ambient/machines/catapult_throw.wav", owner:GetStateVector(), 75, pitch)
				owner:EmitSound("ambient/machines/catapult_throw.wav", 75, pitch)

				owner:EmitSound("physics/nearmiss/whoosh_large4.wav", 75, math.Rand(115, 130))
			end
		elseif self.AmbientSound then
			self.AmbientSound:PlayEx(0.8, 100)
		end

		return true
	end

	if self.AmbientSound then
		self.AmbientSound:Stop()
	end

	return false
end

local matChain = Material("cable/rope")
function EFFECT:Render()
	local owner = self.Owner
	if not owner:IsValid() or owner:GetState() ~= STATE_CHAIN or not owner:Alive() or owner.Chain ~= self.Entity then return end

	local endpos
	local posang = owner:GetAttachment(owner:LookupAttachment("anim_attachment_RH"))
	local startpos = posang and posang.Pos or owner:GetShootPos()
	if owner:CallStateFunction("IsReeling") then
		endpos = owner:GetStateVector()
	else
		endpos = startpos + (owner:GetStateVector() - startpos) * (1 - math.max(0, (owner:GetStateNumber() - CurTime()) / (owner:GetStateNumber() - owner:GetStateStart())))
	end

	render.SetMaterial(matChain)
	render.DrawBeam(startpos, endpos, 3, 0, startpos:Distance(endpos) / 8, team.GetColor(owner:Team()) or color_white)

	self.Entity:SetPos(endpos)
	local ang = (owner:GetStateVector() - startpos):Angle()
	ang:RotateAroundAxis(ang:Right(), 90)
	ang:RotateAroundAxis(ang:Up(), 90)
	self.Entity:SetAngles(ang)
	self.Entity:DrawModel()
end
