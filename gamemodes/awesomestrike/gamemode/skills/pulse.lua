SKILL_PULSE = 11

SKILL.Name = "Pulse"
SKILL.Description = "Active\n\nAllows the user to emit a powerful shockwave that knocks away nearby enemies and objects."
SKILL.Index = SKILL_PULSE

SKILL.DrawEnergy = true

SKILL.Radius = 512
SKILL.Force = 1024

function SKILL:KeyPress(pl, key)
	if key == IN_WALK and pl:IsIdle() and pl:GetEnergy() >= pl:GetMaxEnergy() then
		pl:SetEnergy(0, nil, true)

		local pos = pl:GetPos()

		if SERVER then
			local teamid = pl:Team()
			for _, ent in pairs(ents.FindInSphere(pos, self.Radius)) do
				if not ent:IsWorld() and not ent.ImmuneToPulse and not (ent:IsPlayer() and ent:Team() == teamid) then
					local nearest = ent:NearestPoint(pos)
					if TrueVisible(nearest, pos) then
						if ent:IsPlayer() then ent:SetLastAttacker(pl) end
						ent:ThrowFromPositionSetZ(pos, ((1 - (pos:Distance(nearest) / self.Radius)) + 1) / 2 * self.Force, 0.5, true)
					end
				end
			end

			local effectdata = EffectData()
				effectdata:SetOrigin(pl:LocalToWorld(pl:OBBCenter()))
				effectdata:SetEntity(pl)
			util.Effect("pulse", effectdata, true, true)
		end
	end
end

function SKILL:PlayerSpawn(pl)
	pl:SetEnergyRegeneration(ENERGY_DEFAULT_REGENERATION * 0.75, true)
end

function SKILL:ChangedTo(pl)
	pl:SetEnergyRegeneration(ENERGY_DEFAULT_REGENERATION * 0.75, true)
end

function SKILL:ChangedFrom(pl)
	pl:SetEnergyRegeneration(ENERGY_DEFAULT_REGENERATION, true)
end
