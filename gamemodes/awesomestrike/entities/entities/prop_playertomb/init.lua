AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_c17/gravestone004a.mdl")
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetUseType(SIMPLE_USE)

	self:SetSpawnTime(CurTime())
end

function ENT:UseTarget(pl)
	if self:GetUseStart() ~= 0 or not pl:Alive() then return end

	local revivee = self:GetRevivePlayer()
	if not revivee:IsValid() then self:Remove() return end

	if revivee:Team() == pl:Team() and pl:GetUseTarget() == self then
		self:SetUseStart(CurTime())
		self:SetUsePlayer(pl)
		self:EmitSound("items/smallmedkit1.wav")
	end
end

function ENT:Think()
	local revivee = self:GetRevivePlayer()
	if not revivee:IsValid() or revivee:Alive() then self:Remove() return end

	if self:GetAutoSpawnTime() > 0 and CurTime() >= self:GetAutoSpawnTime() then
		revivee:Spawn()
		if revivee.HotSpawn and CurTime() < revivee.HotSpawn + 1 then
			revivee:SetState(STATE_SPAWNPROTECTION, 1)
		else
			revivee:SetState(STATE_SPAWNPROTECTION, 5)
		end

		self:SetUseStart(0)
		self:Remove()

		return
	end

	local start = self:GetUseStart()
	if start == 0 then return end

	local reviver = self:GetUsePlayer()
	if reviver:IsValid() and reviver:Alive() and reviver:GetUseTarget() == self and reviver:KeyDown(IN_USE) then
		if CurTime() >= start + self.UseDuration then
			revivee.GraveSpawn = true
			revivee:Spawn()
			revivee.GraveSpawn = nil
			if reviver:GetSkill() == SKILL_MEDICALMASTERY then
				revivee:SetHealth(revivee:GetMaxHealthEx())
			else
				revivee:SetHealth(revivee:GetMaxHealthEx() * 0.5)
			end
			revivee:SetPos(self:GetPos())

			if not revivee.RevivedThisRound then
				reviver:AddPoints(1)
			end

			revivee.RevivedThisRound = true

			umsg.Start("AwesomeStrikePlayerRevived")
				umsg.Entity(revivee)
				umsg.Entity(reviver)
			umsg.End()

			self:SetUseStart(0)
			self:Remove()
		end

		self:NextThink(CurTime())
		return true
	else
		self:SetUsePlayer(NULL)
		self:SetUseStart(0)
	end
end
