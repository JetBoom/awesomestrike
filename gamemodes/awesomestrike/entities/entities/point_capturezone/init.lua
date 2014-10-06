AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetTrigger(true)

	self:SetModel("models/weapons/w_c4_planted.mdl")
end

function ENT:InitializeCaptureZone(boundingradius)
	self:PhysicsInitSphere(boundingradius)
	self:SetCollisionBounds(Vector() * -boundingradius, Vector() * boundingradius)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableCollisions(false)
		phys:EnableMotion(false)
	end

	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	self:SetNotSolid(true)
end

function ENT:ResetCapture()
	self:SetCaptureStart(0)
	self:SetCapturingTeam(0)
end

function ENT:Capture(teamid)
	self:SetTeam(teamid)
	self:SetCapturedTime(CurTime())
	self:ResetAndCheck()

	gamemode.Call("ZoneCaptured", teamid)
end

function ENT:Explode()
	if self.Exploded then return end
	self.Exploded = true

	local Position = self:GetPos() + self:GetUp() * 64

	local effect = EffectData()
		effect:SetOrigin(Position)
	util.Effect("bomb_explode", effect)

	util.ScreenShake(Position, 64, 1024, 6, 8192)

	for _, ent in pairs(ents.FindInSphere(Position, 1024)) do
		if ent:IsValid() and ent:IsPlayer() then
			ent:ClearLastAttacker()
			ent:TakeSpecialDamage(200, DMG_DISSOLVE)
		end
	end

	util.BlastDamage(self, self, Position, 1024, 600)

	local bombtarget = self.m_BombTarget
	if bombtarget and bombtarget:IsValid() then
		bombtarget:FireOutput("bombexplode", bombtarget, bombtarget, 0)
	end
end

function ENT:ResetAndCheck()
	self:ResetCapture()
	self:CheckCaptureStatus()
end

ENT.m_LastCapturingTime = 0

function ENT:Think()
	self:Remove()
	--[[self:CheckCaptureStatus()

	self:NextThink(CurTime() + 0.25)
	return true]]
end

function ENT:CheckCaptureStatus()
	local t, ct = self:GetCapturingPlayerCounts()
	if self:GetTCount() ~= t then self:SetTCount(t) end
	if self:GetCTCount() ~= ct then self:SetCTCount(ct) end

	local captureteam = self:GetCapturingTeam()
	if captureteam == 0 then
		if t == ct then return end

		if t > ct then
			if self:GetTeam() ~= TEAM_T then
				self:SetCaptureStart(CurTime())
				self:SetCapturingTeam(TEAM_T)
				self.m_LastCapturingTime = CurTime()
			end
		elseif ct > t then
			if self:GetTeam() ~= TEAM_CT then
				self:SetCaptureStart(CurTime())
				self:SetCapturingTeam(TEAM_CT)
				self.m_LastCapturingTime = CurTime()
			end
		end
	elseif captureteam == TEAM_T and t == 0 or captureteam == TEAM_CT and ct == 0 then
		self:ResetCapture()
	else
		self.m_LastCapturingTime = CurTime()
		if CurTime() >= self:GetCaptureEnd() then
			self:Capture(captureteam)
		end
	end
end

function ENT:GetCapturingPlayerCounts()
	local t, ct = 0, 0

	for _, ent in pairs(ents.FindInSphere(self:GetPos(), self:BoundingRadius())) do
		if ent:IsValid() and ent:IsPlayer() and ent:Alive() then
			if ent:Team() == TEAM_T then
				t = t + 1

				if not self.TSpot and not ent:Crouching() then
					self.TSpot = ent:GetPos()
				end
			elseif ent:Team() == TEAM_CT then
				ct = ct + 1

				if not self.CTSpot and not ent:Crouching() then
					self.CTSpot = ent:GetPos()
				end
			end
		end
	end

	return t, ct
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end
