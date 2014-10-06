function EFFECT:Think()
	return false
end

function EFFECT:Render()
end

function EFFECT:Init(data)
	local pos = data:GetOrigin()

	sound.Play("ambient/fire/gascan_ignite1.wav", pos, 70, math.Rand(95, 105))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(16, 32)
	for i=1, 300 do
		local heading = VectorRand()
		heading:Normalize()
		local particle = emitter:Add("particles/smokey", pos + heading * 4)
		particle:SetVelocity((math.Rand(0, 1) ^ 2 * 32) * heading)
		particle:SetDieTime(math.Rand(4, 7))
		particle:SetStartAlpha(240)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(4, 5))
		particle:SetEndSize(math.Rand(8, 9))
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-2, 2))
		particle:SetAirResistance(32)
		particle:SetColor(255, 255, 0)
		particle:SetLighting(true)
	end

	emitter:Finish()
end
