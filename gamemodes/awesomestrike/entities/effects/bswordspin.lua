util.PrecacheSound("npc/combine_gunship/engine_rotor_loop1.wav")

function EFFECT:Init(data)
	self.Owner = data:GetEntity()
	self.AmbientSound = CreateSound(self.Owner:IsValid() and self.Owner or self.Entity, "npc/combine_gunship/engine_rotor_loop1.wav")
	self.Emitter = ParticleEmitter(data:GetOrigin())
	self.Emitter:SetNearClip(24, 32)
end

function EFFECT:Think()
	local owner = self.Owner
	if owner:IsValid() and owner:GetState() == STATE_BERSERKERSWORDGUARD then
		self.Entity:SetPos(owner:GetPos())
		self.Emitter:SetPos(owner:GetPos())

		self.AmbientSound:PlayEx(75, 100 + CurTime() % 1)

		return true
	end

	self.AmbientSound:Stop()
	--self.Emitter:Finish()

	return false
end

function EFFECT:Render()
end
