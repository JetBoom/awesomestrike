function EFFECT:Init(data)
	local pos = data:GetOrigin()

	sound.Play("physics/metal/metal_sheet_impact_bullet1.wav", pos, 85, math.Rand(95, 105))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(30, 40)
	local grav = Vector(0, 0, -800)
	for i=1, math.random(30, 40) do
		local heading = VectorRand()
		heading:Normalize()
		local particle = emitter:Add("effects/spark", pos + heading * 4)
		particle:SetVelocity(heading * math.Rand(20, 380))
		particle:SetDieTime(math.Rand(0.6, 2))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)
		particle:SetStartSize(math.Rand(2, 8))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-90, 90))
		particle:SetBounce(0.9)
		particle:SetCollide(true)
		particle:SetGravity(grav)
	end
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
