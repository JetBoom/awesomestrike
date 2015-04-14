local Sounds = {
	Sound("ambient/machines/teleport1.wav"),
	Sound("ambient/machines/teleport3.wav"),
	Sound("ambient/machines/teleport4.wav")
}

EFFECT.LifeTime = 1

EFFECT.NextEmit = 0

function EFFECT:Init(data)
	self.Ent = data:GetEntity()
	self.Pos = data:GetOrigin()

	local snd = Sounds[math.random(#Sounds)]
	if self.Ent:IsValid() then
		self.Ent:EmitSound(snd, 70, 100)
	else
		sound.Play(snd, self.Pos, 70, 100)
	end

	self.DieTime = CurTime() + self.LifeTime
end

function EFFECT:Think()
	return CurTime() < self.DieTime
end

function EFFECT:GetDelta()
	return (self.DieTime - CurTime()) / self.LifeTime
end

function EFFECT:Render()
	if CurTime() < self.NextEmit then return end
	self.NextEmit = CurTime() + 0.05

	local delta = self:GetDelta()

	local emitter = ParticleEmitter(self.Pos)
	emitter:SetNearClip(24, 32)

	local particle = emitter:Add("effects/yellowflare", self.Pos)
	particle:SetDieTime(delta ^ 2 + 0.5)
	particle:SetStartAlpha(200 + delta * 50)
	particle:SetEndAlpha(0)
	particle:SetStartSize(1)
	particle:SetEndSize(delta * 256)
	particle:SetRollDelta(delta * 360)

	emitter:Finish()
end
