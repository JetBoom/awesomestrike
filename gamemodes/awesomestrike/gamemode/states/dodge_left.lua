--[[STATE.Speed = 500
STATE.Duration = 0.4
STATE.Delay = 0.35
STATE.SlowDownThreshold = 0.15]]

STATE.Speed = 490
STATE.Duration = 0.5
STATE.Delay = 0.35
STATE.SlowDownThreshold = 0.15

function STATE:IsIdle(pl)
	return true
end

function STATE:Move(pl, move)
	local delta = pl:GetStateEnd() - CurTime()
	if delta > 0 then
		local speedmul = pl:GetSkill() == SKILL_SPEEDMASTERY and 1.25 or 1
		local basespeed = self.Speed * math.Clamp(delta / self.SlowDownThreshold, 0.2, 1)
		local vel = math.max(pl:GetMaxSpeed(), basespeed * speedmul) * pl:GetStateVector() -- -1 * pl:GetRight()
		vel.z = math.Clamp(move:GetVelocity().z, -800, 256)

		pl:SetGroundEntity(NULL)
		move:SetVelocity(vel)
	end
end

function STATE:Started(pl, oldstate)
	pl:SetStateVector(pl:GetRight() * -1)
	pl:ResetDodgeDelay(self.Duration + self.Delay)
	pl:ViewPunch(Angle(0, 0, -8))
	if SERVER then pl:EmitSound("awesomestrike/dodge.wav", 70, 210) end
end

function STATE:Ended(pl, newstate)
	local myvel = pl:GetVelocity()
	local newvel = pl:GetStateVector() * math.min(myvel:Length2D(), pl:GetMaxSpeed() * 2) --pl:GetRight() * -math.min(myvel:Length2D(), pl:GetMaxSpeed() * 2)
	newvel.z = myvel.z
	pl:SetNextMoveVelocity(newvel)

	pl:ResetDodgeDelay(self.Delay)
end

function STATE:KeyPress(pl, key)
	if key == IN_JUMP then
		if pl:StandingOnSomething() then
			if pl:NullStrafeKeys() then
				pl:EndState()
				local vel = pl:GetVelocity()
				if vel:Length2D() >= pl:GetMaxSpeed() then
					vel = vel:GetNormalized() * pl:GetMaxSpeed()
				end
				pl:SetNextMoveVelocity(vel + Vector(0, 0, pl:GetJumpPower()))
				pl:ResetDodgeDelay(self.Delay)
			end
		elseif pl:NullStrafeKeys() then
			pl:EndState()
			local vel = pl:GetVelocity()
			vel.x = 0
			vel.y = 0
			pl:SetNextMoveVelocity(vel)
			pl:ResetDodgeDelay(self.Delay)
		end
	end
end

function STATE:CalcMainActivity(pl, velocity)
	return pl:OnGround() and not pl:Crouching() and ACT_MP_SWIM or ACT_MP_CROUCHWALK, -1
end

function STATE:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	pl:SetPlaybackRate(0.05)

	return true
end

if not CLIENT then return end

function STATE:ShouldDrawFadeTrail(pl)
	pl.FadeTrailAmount = 1
	return true
end
