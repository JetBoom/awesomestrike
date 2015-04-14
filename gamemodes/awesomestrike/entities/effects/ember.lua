function EFFECT:Init(data)
	local dir = data:GetNormal()
	local speed = data:GetScale() * 100

	local max = Vector(3,3,3)
	local min = max * -1
	self.Entity:PhysicsInitBox(min,max)
	self.Entity:SetCollisionBounds(min,max) 
	self.Entity:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	local phys = self.Entity:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
		phys:ApplyForceCenter(dir * math.random(speed * 0.25, speed))
	end
	self.Living = CurTime() + 4	
end

function EFFECT:Think()
	local tr = util.TraceLine({start = self.Entity:GetPos(), endpos = self.Entity:GetPos() + self.Entity:GetVelocity():GetNormalized() * 16, mask = MASK_NPCWORLDSTATIC})
	if tr.Hit then
		self.Living = -5
	end

	if self.Living < CurTime() then
		local pos = self.Entity:GetPos()

		local emitter = ParticleEmitter(pos)
		emitter:SetNearClip(32, 48)

		local particle = emitter:Add("effects/fire_cloud1", pos)
		particle:SetDieTime(0.75)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(20)
		particle:SetStartSize(13)
		particle:SetEndSize(2)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-5, 5))
		particle:SetColor(255, 255, 255)

		emitter:Finish()

		return false
	end

	return true
end

function EFFECT:Render()
	local pos = self.Entity:GetPos()

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(32, 48)

	local particle = emitter:Add("effects/fire_cloud1", pos + VectorRand() * 4)
	particle:SetDieTime(0.3)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(200)
	particle:SetStartSize(5)
	particle:SetEndSize(1)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-1, 1))
	particle:SetColor(255, 220, 100)

	emitter:Finish()
end
