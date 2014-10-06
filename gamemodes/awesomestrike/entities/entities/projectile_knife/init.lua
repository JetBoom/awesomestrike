AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetModel("models/weapons/w_knife_t.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:SetMass(5)
		phys:Wake()
	end

	self.Created = CurTime()
end

function ENT:GetDamage()
	return math.Clamp((CurTime() - self.Created) * 50 + 40, 40, 200)
end

function ENT:Use(activator)
	if not self.Stuck then return end

	local wep = activator:Give("weapon_as_knife")
	if wep:IsValid() then
		if wep:GetOwner() == activator then
			self:Remove()
		else
			wep:Remove()
		end
	end
end

function ENT:Stick()
	self.Stuck = true
	self:SetOwner(NULL)
	self:EmitSound("physics/metal/sawblade_stick"..math.random(3)..".wav", 70, 140)
	self:Fire("kill", "", 30)
end

function ENT:Think()
	if self.Hit then return end
	local data = self.HitData
	if not data then return end

	self.Hit = true

	self:SetPos(data.HitPos - data.HitNormal * 6)
	local ang = data.OurOldVelocity:Angle()
	ang:RotateAroundAxis(ang:Right(), 270)
	self:SetAngles(ang)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)

	local hitent = data.HitEntity
	if hitent and hitent:IsValid() and not hitent:IsWorld() then
		if hitent:IsPlayer() or hitent:IsNPC() then
			hitent:EmitSound("physics/flesh/flesh_impact_bullet"..math.random(5)..".wav")
		end

		hitent:TakeSpecialDamage(self:GetDamage(), DMG_SLASH, self:GetOwner(), self, data.HitPos)
		if hitent:IsPlayer() and hitent:Health() <= 0 then
			local wep = ents.Create("weapon_as_knife")
			if wep:IsValid() then
				wep:SetPos(self:GetPos())
				wep:SetAngles(self:GetAngles())
				wep:Spawn()
				local phys = wep:GetPhysicsObject()
				if phys:IsValid() then
					phys:SetVelocityInstantaneous(data.OurOldVelocity)
				end
			end
		end

		if hitent:GetMoveType() == MOVETYPE_VPHYSICS then
			self:SetParent(hitent)
			self:SetOwner(hitent)
			self:Stick()
		else
			self:Remove()
		end
	else
		self:Stick()
	end
end

function ENT:PhysicsCollide(data, physobj)
	self.HitData = data
	self:NextThink(CurTime())
end
