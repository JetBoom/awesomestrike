AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_phx/misc/soccerball.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMass(200)
		phys:EnableDrag(false)
		phys:Wake()
	end

	self:EmitSound("weapons/stinger_fire1.wav", 76, 100)

	self.DeathTime = self.DeathTime or CurTime() + 10
end

function ENT:Use(activator, caller)
	if activator:Alive() and activator:HasWeapon("weapon_as_dodgeball") then
		activator:SelectWeapon("weapon_as_dodgeball")
		local wep = activator:GetWeapon("weapon_as_dodgeball")
		if wep and wep:IsValid() and CurTime() < wep:GetReloadEnd() and wep:GetReloadEnd() > 0 then
			wep:SetReloadEnd(0)
			self:Remove()
		end
	end
end

function ENT:Think()
	local data = self.HitData
	if data then
		self.HitData = nil
		self:SetOwner(NULL)
		if data.Speed >= 256 then
			local hitent = data.HitEntity
			if hitent and hitent:IsValid() and hitent:IsPlayer() and (hitent:Team() ~= self.m_Team or hitent == self.Thrower) then
				local mul = math.Clamp(data.Speed / 512, 0.5, 2)
				hitent:ThrowFromPositionSetZ(data.HitPos, 200 * mul)
				hitent:TakeSpecialDamage(20 * mul, DMG_CLUB, self.Thrower, self)
			end
		end

		return
	end

	if not self.DeathTime or CurTime() < self.DeathTime then return end

	self.DeathTime = 0
	self:Remove()
end

function ENT:PhysicsCollide(data, phys)
	if 30 < data.Speed and 0.2 < data.DeltaTime then
		self:EmitSound("physics/metal/metal_canister_impact_hard"..math.random(3)..".wav", 78, 80)
	end

	self.HitData = data

	self:NextThink(CurTime())
end
