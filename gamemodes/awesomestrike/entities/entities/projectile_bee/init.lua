AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.LifeTime = 15
ENT.SeekLifeTime = 5
ENT.MaxSpeed = 512
ENT.Acceleration = 2048
ENT.ScanRange = 128
ENT.MaxRange = 320
ENT.BaseRange = 256
ENT.Damage = 4

ENT.DieTime = -1
ENT.BasePos = Vector(0, 0, 0)
function ENT:Initialize()
	self:DrawShadow(false)
	self:PhysicsInitSphere(2)
	self:SetTrigger(true)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMaterial("metal")
		phys:SetMass(2)
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:Wake()
	end

	self.Target = NULL
	self.DieTime = math.max(self.DieTime, CurTime() + self.LifeTime * math.Rand(0.8, 1))
	self.BasePos = self:GetPos()

	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
end

function ENT:Think()
	if self.HitAlready or CurTime() >= self.DieTime then
		self:Remove()
		return
	end

	if not self.MadeTrail then
		self.MadeTrail = true
		util.SpriteTrail(self, 0, team.GetColor(self:GetTeam()) or color_white, false, 4, 4, 0.1, 0.2, "trails/laser.vmt")
	end

	local ent = self.HitEnt
	if ent and ent:IsValid() then
		self:Hit(ent)
		return
	end

	local phys = self:GetPhysicsObject()
	if not phys:IsValid() then return end

	local myteam = self:GetTeam()
	local mypos = self:GetPos()

	if self.Target:IsValid() then
		if not self.Target:IsPlayer() or not self.Target:Alive() then self.Target = NULL end
	end

	if not self.Target:IsValid() then
		for _, ent in pairs(ents.FindInSphere(mypos, self.ScanRange)) do
			if ent:IsPlayer() and ent:Alive() and ent:Team() ~= myteam then
				self.Target = ent
				self.DieTime = CurTime() + self.SeekLifeTime
				break
			end
		end
	end

	if self.Target:IsValid() then
		local nearest = self.Target:NearestPoint(mypos)
		if nearest:Distance(mypos) > self.MaxRange then
			self.Target = NULL
		else
			self:SeekTo(nearest)
		end
	else
		self:SeekTo(self.BasePos + VectorRand():GetNormalized() * math.Rand(-self.BaseRange, self.BaseRange))
	end

	self:NextThink(CurTime())
	return true
end

function ENT:SeekTo(pos)
	local phys = self:GetPhysicsObject()
	local newvel = phys:GetVelocity() + FrameTime() * self.Acceleration * (pos - self:GetPos()):GetNormalized()
	newvel = newvel:GetNormalized() * math.min(newvel:Length(), self.MaxSpeed)
	phys:SetVelocityInstantaneous(newvel)
end

function ENT:Touch(ent)
	if ent:IsValid() and ent:IsPlayer() and ent:Team() ~= self:GetTeam() then
		self.HitEnt = ent
		self:NextThink(CurTime())
	end
end

function ENT:Hit(ent)
	if self.HitAlready then return end
	self.HitAlready = true

	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	ent:TakeSpecialDamage(self.Damage, DMG_ACID, owner, self)
	self:EmitSound("physics/flesh/flesh_impact_bullet"..math.random(5)..".wav")
end
