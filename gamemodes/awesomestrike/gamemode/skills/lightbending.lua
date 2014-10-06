SKILL_LIGHTBENDING = 5

SKILL.Name = "Light Bending"
SKILL.ShortName = "L. Bending"
SKILL.Description = "Active\n\nAllows the user to become invisible.\n\nVisibility is based on movement and light level. Move slow and stay in the dark to lower visibility. Energy drains over time."
SKILL.Index = SKILL_LIGHTBENDING

SKILL.DrawEnergy = true

function SKILL:KeyPress(pl, key)
	if key == IN_WALK then
		if pl:GetState() == STATE_LIGHTBENDING then
			pl:EndState()
		elseif pl:IsIdle() and pl:GetEnergy() >= 10 and not pl:KeyDown(IN_ATTACK) and not pl:KeyDown(IN_ATTACK2) then
			pl:SetState(STATE_LIGHTBENDING)
		end
	end
end
