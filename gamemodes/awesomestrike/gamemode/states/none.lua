function STATE:IsIdle(pl)
	return true
end

function STATE:Think(pl)
	if pl:OnGround() and pl:GetVelocity():Length() >= math.max(325, pl:GetMaxSpeed() * 0.75) then
		if pl:Crouching() then
			pl:SetState(STATE_SLIDE)
		elseif CLIENT and pl:ShouldDrawLocalPlayer() then
			pl:CreateFootParticles()
		end
	end
end

function STATE:ThinkOther(pl)
	if pl:OnGround() and pl:GetVelocity():Length() >= math.max(325, pl:GetMaxSpeed() * 0.75) then
		pl:CreateFootParticles()
	end
end
