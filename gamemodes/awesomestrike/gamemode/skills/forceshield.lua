SKILL_FORCESHIELD = 9

SKILL.Name = "Force Shield"
SKILL.Description = "Active\n\nAllows the user to deflect certain projectiles such as bullets.\n\nEnergy drains over time and one-third of the damage deflected is also drained as energy."
SKILL.Index = SKILL_FORCESHIELD

SKILL.DrawEnergy = true

function SKILL:KeyPress(pl, key)
	if key == IN_WALK then
		if pl:GetState() == STATE_FORCESHIELD then
			pl:EndState()
		elseif pl:IsIdle() and pl:GetEnergy() >= 10 and not pl:KeyDown(IN_ATTACK) and not pl:KeyDown(IN_ATTACK2) and pl:OnGround() then
			pl:SetState(STATE_FORCESHIELD)
		end
	end
end
