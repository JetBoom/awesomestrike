ENT.Type = "anim"

ENT.ShouldCleanUp = true

util.PrecacheSound("weapons/c4/c4_explode1.wav")
util.PrecacheSound("weapons/c4/c4_exp_deb2.wav")

ENT.UseDuration = 7.5

function ENT:SetUseStart(time) self:SetDTFloat(0, time) end
function ENT:GetUseStart() return self:GetDTFloat(0) end
function ENT:SetRevivePlayer(pl)
	self:SetOwner(pl)
	if pl:IsValid() and pl:IsPlayer() then
		local col = team.GetColor(pl:Team()) or color_white
		self:SetColor(Color(col.r, col.g, col.b, 255))
	end
end
function ENT:GetRevivePlayer() return self:GetOwner() end
function ENT:SetUsePlayer(pl) self:SetDTEntity(1, pl) end
function ENT:GetUsePlayer() return self:GetDTEntity(1) end
function ENT:GetSpawnTime() return self:GetDTFloat(1) end
function ENT:SetSpawnTime(time) self:SetDTFloat(1, time) end
function ENT:SetBombTime(time) self:SetDTFloat(3, time) end
function ENT:GetBombTime() return self:GetDTFloat(3) end

function ENT:GetUseMessage()
	return "DEFUSING"
end

function ENT:GetUsePercent()
	local base = self:GetDTFloat(2)

	if self:GetUsePlayer():IsValid() then
		if self:GetUsePlayer():GetSkill() == SKILL_MECHANICALMASTERY then
			return base + ((CurTime() - self:GetUseStart()) * 1.333) / self.UseDuration
		else
			return base + (CurTime() - self:GetUseStart()) / self.UseDuration
		end
	end

	return base
end

function ENT:GetKillAction(pl, attacker, dmginfo)
	return KILLACTION_PLANTEDBOMB
end
