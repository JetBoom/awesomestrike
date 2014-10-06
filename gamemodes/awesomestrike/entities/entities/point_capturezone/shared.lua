ENT.Type = "anim"

function ENT:SetTeam(teamid) self:SetDTInt(0, teamid) end
function ENT:GetTeam() return self:GetDTInt(0) end
function ENT:SetCaptureStart(time) self:SetDTFloat(0, time) end
function ENT:GetCaptureStart() return self:GetDTFloat(0) end
function ENT:GetCaptureEnd() return self:GetCaptureStart() + GAMEMODE.CaptureTime end
function ENT:SetCapturedTime(time) self:SetDTFloat(1, time) end
function ENT:GetCapturedTime() return self:GetDTFloat(1) end
function ENT:SetCapturingTeam(teamid) self:SetDTInt(1, teamid) end
function ENT:GetCapturingTeam() return self:GetDTInt(1) end

function ENT:SetTCount(count) self:SetDTInt(2, count) end
function ENT:GetTCount() return self:GetDTInt(2) end
function ENT:SetCTCount(count) self:SetDTInt(3, count) end
function ENT:GetCTCount() return self:GetDTInt(3) end

function ENT:ShouldBeLastChance()
	return self:GetCapturingTeam() > 0 or CurTime() < self.m_LastCapturingTime + 3
end

function ENT:GetCapturingPlayers()
	local t, ct = {}, {}

	local mypos = self:GetPos()
	for _, ent in pairs(ents.FindInSphere(mypos, self:BoundingRadius())) do
		if ent:IsValid() and ent:IsPlayer() and ent:Alive() and MaskVisible(ent:NearestPoint(mypos), mypos, MASK_SOLID_BRUSHONLY) then
			if ent:Team() == TEAM_T then
				table.insert(t, ent)
			elseif ent:Team() == TEAM_CT then
				table.insert(ct, ent)
			end
		end
	end

	return t, ct
end
