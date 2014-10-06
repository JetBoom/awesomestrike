AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.Radius = 350
ENT.Duration = 5

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

	self.DeathTime = self.DeathTime or CurTime() + 1.5
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
	util.Effect("seizureexplosion", effectdata)

	for _, ent in pairs(ents.FindInSphere(explodepos, self.Radius)) do
		if ent:IsPlayer() and ent:Alive() and (ent:Team() ~= teamid or ent == owner) then
			local nearest = ent:NearestPoint(explodepos)
			if TrueVisible(nearest, explodepos) and ent:AllowHostileStateChanges() then
				if ent:IsPlayer() and ent ~= owner then
					ent:SetLastAttacker(owner)
				end
				ent:SetState(STATE_SEIZURE, ((1 - (nearest:Distance(explodepos) / self.Radius)) * 0.5 + 0.5) * self.Duration)
			end
		end
	end

	self:Remove()
end

