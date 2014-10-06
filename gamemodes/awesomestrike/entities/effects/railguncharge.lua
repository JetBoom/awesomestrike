function EFFECT:Init(data)
	local owner = data:GetEntity()
	if owner and owner:IsValid() then
		self.AmbientSound = CreateSound(owner, "weapons/physcannon/energy_sing_loop4.wav")
		owner.RailGunCharge = self
	end

	self.Owner = owner
end

function EFFECT:Think()
	local owner = self.Owner
	if owner:IsValid() and owner:GetState() == STATE_RAILGUNCHARGE and owner:Alive() and owner.RailGunCharge == self.Entity then
		local charge = owner:CallStateFunction("GetRailGunCharge") or 0
		if self.AmbientSound then
			self.AmbientSound:PlayEx(0.5 + charge * 0.3, 60 + charge * 100)
		end

		return true
	end

	if self.AmbientSound then
		self.AmbientSound:Stop()
	end

	return false
end

function EFFECT:Render()
end
