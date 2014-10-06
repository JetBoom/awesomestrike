function STATE:Started(pl, oldstate)
	if SERVER and pl:KeyPressed(IN_SPEED) then pl:EmitSound("awesomestrike/sprint.wav", 60, 125) end

	pl:SetGravity(0.25)
end

function STATE:Ended(pl, newstate)
	pl:SetGravity(GRAVITY_DEFAULT)
end

function STATE:KeyRelease(pl, key)
	if key == IN_SPEED or key == IN_FORWARD then
		pl:EndState()
	end
end

function STATE:Think(pl)
	if pl:OnGround() or pl:GetVelocity():Length2D() < 64 then
		pl:EndState()
	end

	if CLIENT then
		if not pl:ShouldDrawLocalPlayer() then pl:CreateFootParticles() end
		self:Footsteps(pl)
	end
end

function STATE:Move(pl, move)
	local hitpos, hitnormal = pl:GetWallRunSurface()
	if hitpos then
		local speed = pl:GetMaxSpeed() --+ 175
		--[[move:SetMaxSpeed(speed)
		move:SetMaxClientSpeed(speed)]]
		move:SetSideSpeed(0)
		move:SetForwardSpeed(speed)

		local oldz = move:GetVelocity().z
		local newvel = pl:GetForward() * speed
		newvel.z = math.max(-128, newvel.z + oldz)
		move:SetVelocity(newvel)
	else
		pl:EndState()
	end
end

function STATE:CalcMainActivity(pl, velocity)
	return ACT_MP_RUN, -1
end

function STATE:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	pl:SetPlaybackRate(1)

	return true
end

if not CLIENT then return end

function STATE:Footsteps(pl)
	if CurTime() >= (pl.NextWallRunFootSound or 0) then
		pl.NextWallRunFootSound = CurTime() + GAMEMODE:PlayerStepSoundTime(pl, STEPSOUNDTIME_NORMAL, false) / 500
		pl.WallRunFootAlt = not pl.WallRunFootAlt
		if pl.WallRunFootAlt then
			pl:EmitSound("Default.StepRight")
		else
			pl:EmitSound("Default.StepLeft")
		end
	end
end

function STATE:ThinkOther(pl)
	self:Footsteps(pl)
end

function STATE:PrePlayerDraw(pl)
	local hitpos, hitnormal = pl:GetWallRunSurface()
	if hitpos then
		pl.WallRunAmount = math.Approach(pl.WallRunAmount, math.AngleDifference(pl:GetVelocity():Angle().yaw, hitnormal:Angle().yaw) < 0 and -1 or 1, FrameTime())
	end
end

function STATE:PostPlayerDraw(pl)
	pl:CreateFootParticles()
end

function STATE:ShouldDrawFadeTrail(pl)
	return true
end
