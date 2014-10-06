EFFECT.Gravity = Vector(0, 0, 60)

function EFFECT:Init(data)
	local wep = data:GetEntity()
	if not wep:IsValid() then return end

	local owner = wep:GetOwner()
	if not owner:IsValid() then return end

	local scale = 1
	--[[if owner == MySelf and not owner:ShouldDrawLocalPlayer() then
		scale = scale / 2
		wep = owner:GetViewModel():IsValid() and owner:GetViewModel() or wep
	end]]

	local attach = wep:GetAttachment(1)
	if not attach then return end

	local pos = attach.Pos
	local dir = owner:GetAimVector()

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(8, 16)

	for i=1, 48 do
		local particle = emitter:Add("particles/smokey", pos)
		particle:SetVelocity((dir + VectorRand() * 0.2):GetNormalized() * math.Rand(256, 768))
		particle:SetDieTime(math.Rand(0.5, 1))
		particle:SetStartSize(4 * scale)
		particle:SetEndSize(16 * scale)
		particle:SetStartAlpha(220)
		particle:SetEndAlpha(0)
		particle:SetAirResistance(256)
		particle:SetGravity(self.Gravity)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-10, 10))
		particle:SetColor(120, 120, 120)
		particle:SetLighting(true)
	end

	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
