STATE.Speed = 1200
STATE.Duration = 0.5
STATE.SlowDownThreshold = 0.25

function STATE:IsIdle(pl)
	return true
end

function STATE:Move(pl, move)
	local delta = pl:GetStateEnd() - CurTime()
	if delta > 0 then
		pl:SetGroundEntity(NULL)
		move:SetVelocity(self.Speed * math.Clamp(delta / self.SlowDownThreshold, 0, 1) * pl:GetStateVector())
	end
end

function STATE:Started(pl, oldstate)
	if SERVER then pl:EmitSound("awesomestrike/dodge.wav", 70, 105) end
end

function STATE:Ended(pl, newstate)
	local myvel = pl:GetVelocity()
	local newvel = myvel:GetNormalized() * math.min(myvel:Length2D(), pl:GetMaxSpeed() * 1.5)
	newvel.z = myvel.z
	pl:SetNextMoveVelocity(newvel)

	pl:ResetDodgeDelay()
	pl:ResetAirDodgeDelay()
end

function STATE:CalcMainActivity(pl, velocity)
	return ACT_MP_SWIM, -1
end

function STATE:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	pl:SetPlaybackRate(0.25)

	return true
end

if not CLIENT then return end

function STATE:ShouldDrawFadeTrail(pl)
	pl.FadeTrailAmount = 1
	return true
end
