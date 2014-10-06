ENT.Type = "anim"

ENT.ShouldCleanUp = true

ENT.UseDuration = 4

function ENT:SetUseStart(time) self:SetDTFloat(0, time) end
function ENT:GetUseStart() return self:GetDTFloat(0) end
function ENT:SetRevivePlayer(pl) self:SetOwner(pl) end
function ENT:GetRevivePlayer() return self:GetOwner() end
function ENT:SetUsePlayer(pl) self:SetDTEntity(1, pl) end
function ENT:GetUsePlayer() return self:GetDTEntity(1) end
function ENT:GetSpawnTime() return self:GetDTFloat(1) end
function ENT:SetSpawnTime(time) self:SetDTFloat(1, time) end
function ENT:GetAutoSpawnTime() return self:GetDTFloat(2) end
function ENT:SetAutoSpawnTime(time)
	self:SetDTFloat(2, time)

	-- Might be outside of PVS.
	if SERVER then
		local owner = self:GetRevivePlayer()
		if owner:IsValid() then
			owner:SendLua("TombSetAutoSpawnTime("..time..")")
		end
	end
end
function ENT:SetTeam(teamid) self:SetDTInt(0, teamid) end
function ENT:GetTeam() return self:GetDTInt(0) end
ENT.Team = ENT.GetTeam

function ENT:GetUseMessage()
	return "REVIVING"
end
