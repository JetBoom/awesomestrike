AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/weapons/w_c4_planted.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
end

function ENT:OnTakeDamage(dmginfo)
	local attacker = dmginfo:GetAttacker()
	if attacker:IsValid() and attacker:IsPlayer() and attacker:Team() ~= self:Team() then
		self.ForceExplode = true
		self:NextThink(CurTime())
	end
end

function ENT:Think()
	if self.Exploded then
		self:Remove()
	elseif self.ForceExplode then
		self:Explode()
	elseif self.ForceExplodeTime then
		if CurTime() >= self.ForceExplodeTime then
			self:Explode()
		end
	else
		local owner = self:GetOwner()
		if owner:IsValid() and owner:IsPlayer() and not owner:Alive() then
			self.ForceExplodeTime = CurTime() + 3
			self:EmitSound("ambient/alarms/klaxon1.wav", 80, 120)
		end
	end
end

function ENT:Explode()
	if self.Exploded then return end
	self.Exploded = true

	local pos = self:GetPos()

	self:EmitSound("npc/env_headcrabcanister/explosion.wav", 85, 100)
	timer.SimpleEx(0, ParticleEffect, "dusty_explosion_rockets", pos, Angle(0, 0, 0))
	util.ScreenShake(pos, 58, 128, 3, 650)
	util.BlastDamage(self, self:GetOwner(), pos, 325, 60)

	self:NextThink(CurTime())
end
