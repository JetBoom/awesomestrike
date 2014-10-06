STATE.NoFootsteps = true

function STATE:Started(pl, oldstate)
	if oldstate == STATE_NONE then --if oldstate == STATE_SPRINT then
		pl:SetVelocity(pl:GetVelocity() * 0.25)
	end

	pl:SetStateAngles(pl:EyeAngles())

	local effectdata = EffectData()
		effectdata:SetOrigin(pl:GetPos())
		effectdata:SetEntity(pl)
	util.Effect("slidescrape", effectdata)
end

function STATE:Think(pl)
	--if not pl:Crouching() or pl:GetVelocity():Length() < 256 then
	if not pl:KeyDown(IN_DUCK) or pl:GetVelocity():Length() < 256 then
		pl:EndState()
	elseif SERVER and pl:OnGround() then
		pl:CheckSlideCollide()
	end
end

function STATE:Move(pl, move)
	pl:SetGroundEntity(NULL)
	move:SetSideSpeed(0)
	move:SetForwardSpeed(0)
	move:SetVelocity(move:GetVelocity() * (1 - FrameTime() * 0.2))
	if pl:KeyPressed(IN_JUMP) then
		move:SetVelocity(move:GetVelocity() + Vector(0, 0, pl:GetJumpPower() + 48))
		pl:EndState()
	end
end

function STATE:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	if pl:OnGround() then
		pl:SetPlaybackRate(0)
		pl:SetCycle(0.25)

		pl:SetPoseParameter("move_yaw", math.NormalizeAngle((velocity:Angle().yaw - pl:EyeAngles().yaw)--[[ + 180]]))
	end

	return true
end

function STATE:CalcMainActivity(pl, velocity)
	return ACT_MP_SWIM, -1
end

function STATE:CreateMove(pl, cmd)
	local originalangles = pl:GetStateAngles()
	local viewangles = cmd:GetViewAngles()
	local diff = math.AngleDifference(viewangles.yaw, originalangles.yaw)
	if diff > 90 or diff < -90 then
		viewangles.yaw = math.NormalizeAngle(originalangles.yaw + math.Clamp(diff, -90, 90))
		cmd:SetViewAngles(viewangles)
	end
end

function STATE:AdjustMouseSensitivity(pl)
	return 0.5
end

function STATE:ShouldDrawFadeTrail(pl)
	return true
end
