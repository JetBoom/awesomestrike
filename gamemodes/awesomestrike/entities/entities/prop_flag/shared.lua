ENT.Type = "anim"

util.PrecacheSound("npc/turret_floor/click1.wav")

ENT.NoThrowFromPosition = true

FLAGSTATE_HOME = 0
FLAGSTATE_CARRY = 1
FLAGSTATE_DROPPED = 2

function ENT:SetCarry(ent)
	self:SetDTEntity(0, ent)
end

function ENT:GetCarry()
	return self:GetDTEntity(0)
end

function ENT:SetHomePosition(pos)
	self:SetDTVector(0, pos)
end

function ENT:GetHomePosition()
	return self:GetDTVector(0)
end

function ENT:SetState(state, forcebehavior)
	local oldstate = self:GetState()

	self:SetDTInt(1, state)

	if not SERVER or state == oldstate and not forcebehavior then return end

	if state == FLAGSTATE_HOME then
		self:SetAutoReturn(0)
		self:SetCarry(NULL)
		self:EnableCollisions()
		self:DisablePhysics()
		self:SetSolid(SOLID_VPHYSICS)
	elseif state == FLAGSTATE_CARRY then
		self:SetAutoReturn(0)
		self:DisableCollisions()
		self:DisablePhysics()
		self:SetSolid(SOLID_NONE)
	elseif state == FLAGSTATE_DROPPED then
		self:SetAutoReturn(CurTime() + math.Clamp(GAMEMODE.RespawnTime, 5, 60))
		self:SetCarry(NULL)
		self:DisableCollisions()
		self:EnablePhysics()
		self:SetSolid(SOLID_VPHYSICS)
	end
end

function ENT:GetState()
	return self:GetDTInt(1)
end

function ENT:SetTeam(teamid)
	self:SetDTInt(0, teamid)

	local col = team.GetColor(teamid) or color_white
	if col then
		self:SetColor(col)
	end
end

function ENT:GetTeam()
	return self:GetDTInt(0)
end

function ENT:GetOppositeTeam()
	return self:GetTeam() == TEAM_T and TEAM_CT or TEAM_T
end

function ENT:SetAutoReturn(time)
	self:SetDTFloat(0, time)
end

function ENT:GetAutoReturn()
	return self:GetDTFloat(0)
end

function ENT:AlignToCarrier()
	local carry = self:GetCarry()
	if carry:IsValid() then
		local attachid = carry:LookupAttachment("anim_attachment_rh")
		if attachid and attachid > 0 then
			local attach = carry:GetAttachment(attachid)
			if attach then
				self:SetPos(attach.Pos)
				self:SetAngles(attach.Ang)
				return
			end
		end

		self:SetPos(carry:GetPos() + Vector(0, 0, carry:OBBMaxs().z / 2))
	end
end
