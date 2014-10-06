local matBolt = Material("Effects/laser1")
function EFFECT:Init(data)
	local ent = data:GetEntity()
	if ent:IsValid() then
		self.Emitter = ParticleEmitter(data:GetOrigin())
		self.Emitter:SetNearClip(50, 60)
	end
	self.Owner = ent
	self.Threshhold = 0

	self.Death = CurTime() + 10

	self:SetRenderBounds(Vector(-128,-128,-128), Vector(128, 128, 128))
end

function EFFECT:Think()
	local ent = self.Owner

	if not (CurTime() < self.Death and ent:IsValid()) then
		if self.Emitter then
			--self.Emitter:Finish()
		end

		return false
	end

	local rag = ent:GetRagdollEntity()

	if rag then
		rag.Electricuted = true

		for i=1, rag:GetPhysicsObjectCount() do
			local phys = rag:GetPhysicsObjectNum(i)
			if phys and phys:IsValid() then
				phys:Wake()
				phys:ApplyForceCenter(VectorRand() * 350)
				if i == 1 then
					local entpos = phys:GetPos()
					self.Entity:SetPos(entpos)
					self.Emitter:SetPos(entpos)
				end
			end
		end

		return true
	else
		if self.Threshhold > 0.25 then
			if self.Emitter then
				--self.Emitter:Finish()
			end
			return false
		end

		self.Threshhold = self.Threshhold + FrameTime()

		return true
	end

	return true
end

function EFFECT:Render()
	if not self.Owner:IsValid() then return end

	local ent = self.Owner:GetRagdollEntity()

	if not ent then return end

	local emitter = self.Emitter
	for i=1, ent:GetPhysicsObjectCount() do
		local phys = ent:GetPhysicsObjectNum(i)
		if phys and phys:IsValid() then
			local pos = phys:GetPos()
			if math.random(1, 2) == 1 then
				local particle = emitter:Add("effects/spark", pos + VectorRand() * 6)
				particle:SetVelocity(VectorRand() * 32)
				particle:SetDieTime(math.Rand(0.3, 0.6))
				particle:SetStartAlpha(255)
				particle:SetEndAlpha(255)
				particle:SetStartSize(math.random(4, 8))
				particle:SetEndSize(0)
				particle:SetRoll(math.Rand(0, 359))
				particle:SetRollDelta(math.Rand(-20, 20))
				particle:SetColor(50, 100, 255)
				particle:SetAirResistance(10)
				particle:SetBounce(0.5)
				particle:SetCollide(true)

				render.SetMaterial(matBolt)
				for m=1, math.random(2, 3) do
					local bpos = pos
					local normal = VectorRand()
					local bpos2 = pos + normal * 4
					local xmax = math.random(2, 3)
					for x=1, xmax do
						if x == xmax then
							render.DrawBeam(bpos, bpos2, 8, 4, 4, COLOR_CYAN)
							render.DrawBeam(bpos, bpos2, 8, 2, 2, COLOR_BLUE)
						else
							render.DrawBeam(bpos, bpos2, 8, 6, 6, COLOR_CYAN)
							render.DrawBeam(bpos, bpos2, 8, 4, 4, COLOR_BLUE)
						end
						normal = (normal + VectorRand() * 0.3)
						normal:Normalize()
						bpos = bpos2
						bpos2 = bpos2 + normal * 4
					end
				end
			end
		end
	end
end
