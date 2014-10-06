STATE.Speed = 1200

function STATE:IsIdle(pl)
	return false
end

function STATE:Think(pl)
	if pl:KeyPressed(IN_JUMP) then pl:EndState() end
end

function STATE:Started(pl, oldstate)
	local reeltime = pl:GetStateVector():Distance(pl:GetShootPos()) / self.Speed
	pl:SetStateNumber(CurTime() + reeltime)
	pl:SetStateEnd(CurTime() + reeltime * 2)

	if SERVER then SuppressHostEvents(pl) end
	local effectdata = EffectData()
		effectdata:SetOrigin(pl:GetShootPos())
		effectdata:SetEntity(pl)
	util.Effect("chain", effectdata)
	if SERVER then SuppressHostEvents(NULL) end
end

function STATE:IsReeling(pl)
	return pl:GetStateNumber() <= CurTime()
end

function STATE:Ended(pl, newstate)
	pl.ChainStartSound = nil

	if 0 < pl:Health() then
		pl:SetLocalVelocity(Vector(0, 0, pl:GetJumpPower() + 48))
	end
end

function STATE:Move(pl, move)
	move:SetSideSpeed(0)
	move:SetForwardSpeed(0)
	move:SetMaxSpeed(0)
	move:SetMaxClientSpeed(0)

	pl:SetGroundEntity(NULL)
	if self:IsReeling(pl) then
		move:SetVelocity((pl:GetStateVector() - pl:GetShootPos()):GetNormalized() * self.Speed)
	else
		move:SetVelocity(Vector(0, 0, 0))
	end

	return MOVE_STOP
end

function STATE:CalcMainActivity(pl, velocity)
	if self:IsReeling(pl) then
		return ACT_MP_SWIM, -1
	end
end

function STATE:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	if self:IsReeling(pl) then
		pl:SetPlaybackRate(0.2)

		return true
	end
end

if not CLIENT then return end

function STATE:ShouldDrawFadeTrail(pl)
	return self:IsReeling(pl)
end
