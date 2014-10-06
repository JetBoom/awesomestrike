AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.Bees = 10

function ENT:Initialize()
	self:SetModel("models/weapons/w_eq_flashbang_thrown.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMass(5)
		phys:EnableDrag(false)
		phys:Wake()
	end

	self.DeathTime = self.DeathTime or CurTime() + 2
end

function ENT:Think()
	if not self.DeathTime or CurTime() < self.DeathTime then return end
	self.DeathTime = 0

	local explodepos = self:GetPos()
	local owner = self:GetOwner()
	local teamid = -1
	if owner:IsValid() and owner:IsPlayer() then
		teamid = owner:Team()
	end

	local effectdata = EffectData()
		effectdata:SetOrigin(explodepos)
	util.Effect("beehiveexplosion", effectdata)

	for i=1, self.Bees do
		local heading = VectorRand()
		heading:Normalize()
		local ent = ents.Create("projectile_bee")
		if ent:IsValid() then
			ent:SetPos(explodepos + heading * 4)
			ent:SetOwner(owner)
			ent:SetTeam(teamid)
			ent:Spawn()
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:SetVelocityInstantaneous(heading * math.Rand(92, 128))
			end
		end
	end

	self:Remove()
end

