util.PrecacheSound("awesomestrike/airburst.wav")

function EFFECT:Init(data)
	local ent = data:GetEntity()

	if not ent or not ent:IsValid() then return end

	ent:EmitSound("awesomestrike/airburst.wav")

	local ang = data:GetAngles()
	ang:RotateAroundAxis(ang:Up(), -60)
	pos = ent:EyePos()

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)
	for i=1, 24 do
		ang:RotateAroundAxis(ang:Up(), 5)
		local dir = ang:Forward()

		for i=1, 5 do
			local particle = emitter:Add("effects/fire_cloud"..math.random(2), pos + dir * 8)
			particle:SetVelocity(1000 * i * dir)
			particle:SetDieTime(0.5 + i * 0.25)
			particle:SetStartAlpha(240)
			particle:SetEndAlpha(0)
			particle:SetStartSize(i * 4)
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-10, 10))
			particle:SetAirResistance(1800)
		end
	end

	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
