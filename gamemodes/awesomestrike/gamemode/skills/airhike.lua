SKILL_AIRHIKE = 12

SKILL.Name = "Air Hike"
SKILL.Description = "Active\n\nAllows the user to insantly change directions while in the air."
SKILL.Index = SKILL_AIRHIKE

SKILL.DrawEnergy = true

function SKILL:KeyPress(pl, key)
	if key == IN_WALK and pl:IsIdle() and pl:GetEnergy() >= pl:GetMaxEnergy() and not pl:StandingOnSomething() then
		local dir
		if pl:KeyDown(IN_FORWARD) and not pl:KeyDown(IN_BACK) then
			dir = pl:GetForward()
			pl:ViewPunch(Angle(30, 0, 0))
		elseif pl:KeyDown(IN_BACK) and not pl:KeyDown(IN_FORWARD) then
			dir = pl:GetForward() * -1
			pl:ViewPunch(Angle(-30, 0, 0))
		elseif pl:KeyDown(IN_MOVELEFT) and not pl:KeyDown(IN_MOVERIGHT) then
			dir = pl:GetRight() * -1
			pl:ViewPunch(Angle(0, 0, -30))
		elseif pl:KeyDown(IN_MOVERIGHT) and not pl:KeyDown(IN_MOVELEFT) then
			dir = pl:GetRight()
			pl:ViewPunch(Angle(0, 0, 30))
		end

		if not dir then return end

		pl:SetEnergy(0, nil, true)

		pl:SetStateVector(dir)
		pl:SetState(STATE_AIRHIKE, STATES[STATE_AIRHIKE].Duration)
	end
end
