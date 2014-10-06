STATE.NoFootsteps = true
STATE.NoJumping = true

function STATE:IsIdle(pl)
	return false
end

function STATE:Started(pl, oldstate)
	pl:ResetJumpPower()
end

function STATE:Ended(pl, newstate)
	pl:ResetJumpPower(true)
end

function STATE:Move(pl, move)
	move:SetMaxSpeed(0)
	move:SetMaxClientSpeed(0)

	return MOVE_STOP
end
