STATE.Speed = 520
STATE.Duration = 0.5
STATE.Delay = 0.75

function STATE:IsIdle(pl)
	return true
end

function STATE:Move(pl, move)
	local delta = pl:GetStateEnd() - CurTime()
	if delta > 0 then
		local speedmul = pl:GetSkill() == SKILL_SPEEDMASTERY and 1.25 or 1
		local basespeed = self.Speed * math.Clamp(delta / self.Duration, 0, 1) ^ 0.2
		local vel = basespeed * speedmul * pl:GetRight()
		vel.z = 0

		pl:SetGroundEntity(NULL)
		move:SetVelocity(vel)
	end
end

function STATE:Started(pl, oldstate)
	pl:ResetAirDodgeDelay(self.Duration + self.Delay)
	pl:ViewPunch(Angle(0, 0, 8))
	if SERVER then pl:EmitSound("awesomestrike/dodge.wav", 70, 160) end
end

function STATE:Ended(pl, newstate)
	local myvel = pl:GetVelocity()
	local newvel = pl:GetRight() * math.min(myvel:Length2D(), self.Speed)
	newvel.z = myvel.z
	pl:SetNextMoveVelocity(newvel)

	pl:ResetAirDodgeDelay(self.Delay)
end

function STATE:CalcMainActivity(pl, velocity)
	return ACT_MP_SWIM, -1
end

function STATE:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	pl:SetPlaybackRate(0.1)

	return true
end

if not CLIENT then return end

function STATE:ShouldDrawFadeTrail(pl)
	pl.FadeTrailAmount = 1
	return true
end
