function EFFECT:Think()
	return false
end

function EFFECT:Render()
end

function EFFECT:Init(data)
	local pos = data:GetOrigin()

	sound.Play("ambient/machines/floodgate_stop1.wav", pos, 75, math.Rand(180, 190))
	sound.Play("ambient/explosions/explode_8.wav", pos, 80, math.Rand(230, 250))

	local grav = Vector(0, 0, 128)

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(16, 24)
	for i=1, math.random(512, 768) do
		local heading = VectorRand()
		heading.z = math.abs(heading.z / 2)
		heading:Normalize()

		local particlepos = pos + VectorRand():GetNormalized() * math.Rand(-256, 256)
		heading = (heading + (particlepos - pos):GetNormalized()) / 2

		local particle = emitter:Add("sprites/glow04_noz", particlepos)
		particle:SetVelocity(heading * 1024)
		particle:SetDieTime(math.Rand(4, 6))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(8)
		particle:SetEndSize(math.Rand(16, 24))
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-30, 30))
		particle:SetAirResistance(256)
		particle:SetGravity(grav)
		local ran = math.random(4)
		if ran == 1 then
			particle:SetColor(30, 255, 30)
		elseif ran == 2 then
			particle:SetColor(20, 40, 255)
		elseif ran == 3 then
			particle:SetColor(255, 20, 20)
		else
			particle:SetColor(math.random(160, 255), math.random(160, 255), math.random(160, 255))
		end
	end

	local particle = emitter:Add("effects/select_ring", pos)
	particle:SetDieTime(0.5)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(2)
	particle:SetEndSize(300)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(180)
	particle:SetAngles(Angle(0, 0, 0))
	particle:SetColor(255, 0, 255)

	local particle = emitter:Add("effects/select_ring", pos)
	particle:SetDieTime(0.5)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(2)
	particle:SetEndSize(300)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(180)
	particle:SetAngles(Angle(90, 0, 0))
	particle:SetColor(0, 255, 255)

	local particle = emitter:Add("effects/select_ring", pos)
	particle:SetDieTime(0.5)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(2)
	particle:SetEndSize(300)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(180)
	particle:SetAngles(Angle(90, 90, 0))
	particle:SetColor(255, 255, 0)

	emitter:Finish()
end
