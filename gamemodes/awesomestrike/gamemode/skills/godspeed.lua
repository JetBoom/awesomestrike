SKILL_GODSPEED = 10

SKILL.Name = "Godspeed"
SKILL.Description = "Active\n\nAllows the user to momentarily boost their reflexes to blinding speeds, dodging everything except for explosives."
SKILL.Index = SKILL_GODSPEED

SKILL.DrawEnergy = true

SKILL.Time = 4

function SKILL:KeyPress(pl, key)
	if key == IN_WALK then
		if pl:GetState() == STATE_GODSPEED then
			pl:EndState()
		elseif pl:IsIdle() and pl:GetEnergy() >= pl:GetMaxEnergy() and not pl:KeyDown(IN_ATTACK) and not pl:KeyDown(IN_ATTACK2) then
			pl:SetState(STATE_GODSPEED, self.Time)
		end
	end
end

function SKILL:PlayerSpawn(pl)
	pl:SetEnergyRegeneration(ENERGY_DEFAULT_REGENERATION / 2, true)
end

function SKILL:ChangedTo(pl)
	pl:SetEnergyRegeneration(ENERGY_DEFAULT_REGENERATION / 2, true)
end

function SKILL:ChangedFrom(pl)
	pl:SetEnergyRegeneration(ENERGY_DEFAULT_REGENERATION, true)
end
