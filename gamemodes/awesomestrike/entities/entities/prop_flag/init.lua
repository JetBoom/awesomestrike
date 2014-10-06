AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/Roller_Spikes.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMass(100)
	end

	self:SetHomePosition(self:GetPos())
	self:SetState(FLAGSTATE_HOME, true)
	self:SetToHome()

	GAMEMODE.IsCTF = true
end

ENT.NextNotice = 0
function ENT:NoticeAntiSpam()
	if CurTime() >= self.NextNotice then
		self.NextNotice = CurTime() + 0.5
		return true
	end

	return false
end

function ENT:EnablePhysics()
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(true)
		phys:Wake()
	end
end

function ENT:DisablePhysics()
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
		phys:Wake()
	end
end

function ENT:EnableCollisions()
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
end

function ENT:DisableCollisions()
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
end

function ENT:Use(pl, caller)
	if not pl:Alive() or pl:Team() == TEAM_SPECTATOR or GAMEMODE:GetRoundEnded() then return end

	if pl:Team() ~= self:GetTeam() and self:GetState() ~= FLAGSTATE_CARRY and pl:IsIdle() and pl:GetState() == STATE_NONE then
		if team.NumPlayers(self:GetTeam()) == 0 then
			pl:PrintMessage(HUD_PRINTCENTER, "You can't take the flag of a team with no players!")
		else
			self:PickUp(pl)
		end
	end
end

function ENT:PickUp(pl)
	if self:GetState() == FLAGSTATE_CARRY then return end

	if self:NoticeAntiSpam() then
		if pl and pl:IsValid() then
			team.AddNotice(self:GetOppositeTeam(), pl:Name().." picked up the enemy flag!", nil, COLID_GREEN)
			team.AddNotice(self:GetTeam(), pl:Name().." picked up your flag!", nil, COLID_RED)
			team.AddNotice(TEAM_SPECTATOR, pl:Name().." picked up the "..team.GetName(self:GetTeam()).." flag!")
		else
			team.AddNotice(self:GetOppositeTeam(), "The enemy flag was picked up!", nil, COLID_GREEN)
			team.AddNotice(self:GetTeam(), "Your flag was picked up!", nil, COLID_RED)
			team.AddNotice(TEAM_SPECTATOR, "The "..team.GetName(self:GetTeam()).." flag was picked up!")
		end
	end

	self:SetState(FLAGSTATE_CARRY)
	self:SetCarry(pl)
	pl:SetState(STATE_CARRYFLAG, nil, self)
end

function ENT:Drop(pl)
	if self:GetState() ~= FLAGSTATE_CARRY then return end

	if self:NoticeAntiSpam() then
		if pl and pl:IsValid() then
			team.AddNotice(self:GetOppositeTeam(), pl:Name().." dropped the enemy flag!", nil, COLID_RED)
			team.AddNotice(self:GetTeam(), pl:Name().." dropped your flag!", nil, COLID_GREEN)
			team.AddNotice(TEAM_SPECTATOR, pl:Name().." dropped the "..team.GetName(self:GetTeam()).." flag!")
		else
			team.AddNotice(self:GetOppositeTeam(), "The enemy flag was dropped!", nil, COLID_GREEN)
			team.AddNotice(self:GetTeam(), "Your flag was dropped!", nil, COLID_RED)
			team.AddNotice(TEAM_SPECTATOR, "The "..team.GetName(self:GetTeam()).." flag was dropped!")
		end
	end

	if pl and pl:IsValid() then
		self:SetPos(pl:LocalToWorld(pl:OBBCenter()))
	end

	self:SetState(FLAGSTATE_DROPPED)
end

function ENT:Return(pl, far)
	if self:GetState() == FLAGSTATE_HOME then return end

	team.AddNotice(self:GetOppositeTeam(), "The enemy flag was returned to base!", nil, COLID_RED)
	team.AddNotice(self:GetTeam(), "Your flag was returned to base!", nil, COLID_GREEN)
	team.AddNotice(TEAM_SPECTATOR, "The "..team.GetName(self:GetTeam()).." flag was returned to base!")

	self:SetToHome()
end

function ENT:SetToHome()
	self.AutoReturnPlayer = nil
	self:SetState(FLAGSTATE_HOME)
	self:SetPos(self:GetHomePosition())
end

function ENT:Capture(pl)
	if self:GetState() ~= FLAGSTATE_CARRY then return end

	if pl and pl:IsValid() then
		pl:AddPoints(10)

		team.AddNotice(self:GetOppositeTeam(), pl:Name().." captured the enemy flag!!~svo/coast/odessa/male01/nlo_cheer0"..math.random(1, 4)..".wav", 7, COLID_GREEN)
		team.AddNotice(self:GetTeam(), pl:Name().." captured your flag!!~snpc/dog/dog_on_dropship.wav", 7, COLID_RED)
		team.AddNotice(TEAM_SPECTATOR, pl:Name().." captured the "..team.GetName(self:GetTeam()).." flag!!~svo/coast/odessa/male01/nlo_cheer0"..math.random(1, 4)..".wav", 7)
	else
		team.AddNotice(self:GetOppositeTeam(), "The enemy flag was captured!!~svo/coast/odessa/male01/nlo_cheer0"..math.random(1, 4)..".wav", 7, COLID_GREEN)
		team.AddNotice(self:GetTeam(), "Your flag was captured!!~snpc/dog/dog_on_dropship.wav", 7, COLID_RED)
		team.AddNotice(TEAM_SPECTATOR, "The "..team.GetName(self:GetTeam()).." flag was captured!!~svo/coast/odessa/male01/nlo_cheer0"..math.random(1, 4)..".wav", 7)
	end

	gamemode.Call("EndRound", self:GetOppositeTeam())

	self:SetToHome()
end

function ENT:Think()
	local state = self:GetState()
	if state == FLAGSTATE_HOME then return end

	if state == FLAGSTATE_DROPPED then
		if self:GetAutoReturn() ~= 0 and self:GetAutoReturn() <= CurTime() then
			self:Return(self.AutoReturnPlayer, true)
			return
		end
	elseif state == FLAGSTATE_CARRY then
		local carry = self:GetCarry()
		if not carry:IsValid() then
			self:Drop()
			return
		end

		if not carry:Alive() then
			self:Drop(carry)
			return
		end

		if self.BeCaptured then
			self.BeCaptured = nil
			self:Capture(carry)
			return
		end

		self:AlignToCarrier()

		self:NextThink(CurTime())
		return true
	end
end

function ENT:PhysicsCollide(data, phys)
	local ent = data.HitEntity
	if ent and ent:IsValid() and ent:IsPlayer() and self:GetState() == FLAGSTATE_HOME and ent:GetState() == STATE_CARRYFLAG then
		local otherflag = ent:GetStateEntity()
		if otherflag:IsValid() and otherflag:GetState() == FLAGSTATE_CARRY and otherflag:GetCarry() == ent then
			otherflag.BeCaptured = true
		end
	end

	if 50 < data.Speed and 0.3 < data.DeltaTime and phys:IsMotionEnabled() then
		self:EmitSound("npc/turret_floor/click1.wav")
	end
end

function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "team" then
		value = string.lower(value or "")
		if value == "t" or value == tostring(TEAM_T) then
			self:SetTeam(TEAM_T)
		elseif value == "ct" or value == tostring(TEAM_CT) then
			self:SetTeam(TEAM_CT)
		end
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end
