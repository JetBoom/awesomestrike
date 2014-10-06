util.PrecacheSound("physics/glass/glass_sheet_break1.wav")
util.PrecacheSound("physics/glass/glass_sheet_break2.wav")
util.PrecacheSound("physics/glass/glass_sheet_break3.wav")

function EFFECT:Init(data)
	self.Owner = data:GetEntity()
	self.Death = CurTime() + 2.5
	self.Threshold = 0
	self:SetRenderBounds(Vector(-128,-128,-128), Vector(128, 128, 128))
end

function EFFECT:Think()
	local ent = self.Owner

	if not (ent and ent:IsValid() and not ent:Alive()) then
		self.Threshold = self.Threshold + FrameTime()
		return self.Threshold < 2
	end

	ent = ent:GetRagdollEntity()

	if ent then
		if not self.Frozen then
			self.Frozen = true
			ent.Frozen = true
			ent:SetMaterial("models/shiny")

			local bones = ent:GetPhysicsObjectCount()

			for bone = 0, bones do
				local phys = ent:GetPhysicsObjectNum(bone)
				if phys and phys:IsValid() then
					phys:SetVelocity(Vector(0, 0, -8))
					phys:SetDragCoefficient(64)
					if bone ~= 0 then
						phys:EnableGravity(false)
					end
				end
			end
		elseif self.Death < CurTime() then
			ent:SetColor(Color(255, 255, 255, 0))
			ent:EmitSound("physics/glass/glass_sheet_break"..math.random(1, 3)..".wav")

			local bones = ent:GetPhysicsObjectCount()
			local emitter = ParticleEmitter(ent:GetPos())
			for bone = 0, bones do
				local phys = ent:GetPhysicsObjectNum(bone)
				if phys and phys:IsValid() then
					local pos = phys:GetPos()

					for i=1, 12 do
						local particle = emitter:Add("particles/balloon_bit", pos + VectorRand():GetNormalized() * 2)
						particle:SetVelocity(VectorRand():GetNormalized() * math.Rand(48, 90))
						particle:SetLifeTime(0)
						particle:SetDieTime(math.Rand(3, 5))
						particle:SetStartAlpha(255)
						particle:SetEndAlpha(100)
						local Size = math.Rand(1, 5)
						particle:SetStartSize(Size)
						particle:SetEndSize(Size * 0.25)
						particle:SetRoll(math.Rand(0, 360))
						particle:SetRollDelta(math.Rand(-2, 2))
						particle:SetGravity(Vector(0, 0, -400))
						local RandDarkness = math.Rand(0.8, 1.0)
						particle:SetColor(230 * RandDarkness, 240 * RandDarkness, 255 * RandDarkness)
						particle:SetCollide(true)
						particle:SetAngleVelocity(Angle(math.Rand(-160, 160), math.Rand(-160, 160), math.Rand(-160, 160)))
						particle:SetBounce(0.9)
					end
				end
			end
			emitter:Finish()

			return false
		end
	else
		self.Threshold = self.Threshold + FrameTime()
		return self.Threshold < 2
	end

	return true
end

function EFFECT:Render()
end
