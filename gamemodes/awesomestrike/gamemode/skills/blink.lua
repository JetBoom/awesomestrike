SKILL_BLINK = 6

SKILL.Name = "Blink"
SKILL.Description = "Active\n\nBy using dimensional tears, the user can teleport.\n\nPress WALK (LAlt) to mark a location. Press it again to teleport there.\n\nYou must teleport before your energy runs out."
SKILL.Index = SKILL_BLINK

SKILL.DrawEnergy = true

function SKILL:KeyPress(pl, key)
	if key == IN_WALK then
		if pl:GetSkillVector() ~= vector_origin then
			pl:SetState(STATE_BLINK, STATES[STATE_BLINK].BlinkTime)
			pl:SetStateVector(pl:GetSkillVector())
			pl:SetStateAngles(pl:GetSkillAngle())
			pl:SetEnergy(0, ENERGY_DEFAULT_REGENERATION, true)
		end

		if pl:GetEnergy() < pl:GetMaxEnergy() or pl:Crouching() then return end

		pl:SetSkillVector(pl:GetPos())
		pl:SetSkillAngle(pl:SyncAngles())
		pl:SetEnergyRegeneration(-20, true)
		if SERVER then
			pl:EmitSound("npc/scanner/scanner_scan4.wav")
		end
	end
end

if not SERVER then return end

function SKILL:PlayerSpawn(pl)
	pl:SetSkillVector(Vector(0, 0, 0))
	pl:SetSkillAngle(Angle(0, 0, 0))
end

function SKILL:Think(pl)
	if pl:GetEnergy() == 0 then
		pl:SetSkillVector(Vector(0, 0, 0))
		pl:SetSkillAngle(Angle(0, 0, 0))
		pl:SetEnergyRegeneration(ENERGY_DEFAULT_REGENERATION, true)
	end
end
