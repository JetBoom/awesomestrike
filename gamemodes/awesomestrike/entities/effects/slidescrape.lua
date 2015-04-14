function EFFECT:Init(data)
	self.Owner = data:GetEntity()
	self.AmbientSound = CreateSound(self.Owner:IsValid() and self.Owner or self.Entity, "physics/body/body_medium_scrape_smooth_loop1.wav")
end

function EFFECT:Think()
	local owner = self.Owner
	if owner:IsValid() and owner:GetState() == STATE_SLIDE then
		self.Entity:SetPos(owner:GetPos())

		if owner:OnGround() then
			local speedpower = math.Clamp(owner:GetVelocity():Length() / 600, 0.4, 1)
			self.AmbientSound:PlayEx(speedpower / 2, speedpower * 200)
		else
			self.AmbientSound:Stop()
		end

		return true
	end

	self.AmbientSound:Stop()

	return false
end

local vecgrav = Vector(0, 0, 20)
function EFFECT:Render()
	local owner = self.Owner
	if owner:IsValid() and owner:GetState() == STATE_SLIDE and owner:OnGround() then
		local pos = owner:GetPos()
		local vel = owner:GetVelocity()
		local speed = vel:Length()
		local dir = vel:GetNormalized()
		local right = dir:Angle():Right()
		local velspeed = speed * 0.1
		local start = pos + dir * 20 + Vector(0, 0, 4)

		local emitter = ParticleEmitter(start)
		emitter:SetNearClip(24, 32)

		for i=1, 8 do
			local particle = emitter:Add("particle/smokestack", start)
			particle:SetVelocity(math.Rand(0.8, 1.2) * velspeed * (dir + right * (math.random(1, 2) == 1 and -1 or 1)))
			particle:SetDieTime(math.Rand(0.86, 1.26))
			particle:SetStartAlpha(70)
			particle:SetEndAlpha(0)
			particle:SetStartSize(4)
			particle:SetEndSize(6)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-5, 5))
			particle:SetColor(140, 140, 140)
			particle:SetCollide(true)
			particle:SetBounce(0.1)
			particle:SetAirResistance(20)
			particle:SetGravity(vecgrav)
		end

		emitter:Finish()
	end
end
