STATE.NoFootsteps = true
STATE.NoJumping = true

function STATE:IsIdle(pl)
	return false
end

function STATE:Started(pl, oldstate)
	pl:SetStateBool(false)
	pl:ResetJumpPower()
	pl:ResetLuaAnimation("shockwavebatjumpattack")
	pl:SetGravity(GRAVITY_DEFAULT * 3)
	if SERVER then pl:EmitSound("npc/env_headcrabcanister/incoming.wav") end
end

function STATE:Ended(pl, newstate)
	pl:ResetJumpPower(true)
	pl:SetGravity(GRAVITY_DEFAULT)
	if 0 < pl:Health() and newstate == STATE_SHOCKWAVEBATSLAMATTACKEND then
		pl:CallWeaponFunction("ShockWaveBatSlamEnded", newstate)
	end
end

function STATE:GoToNextState(pl)
	pl:SetState(STATE_SHOCKWAVEBATSLAMATTACKEND, 0.5)

	return true
end

function STATE:Think(pl)
	pl:SetGravity(GRAVITY_DEFAULT * 3)

	if not pl:GetStateBool() and CurTime() >= pl:GetStateStart() + 0.25 then
		pl:SetStateBool(true)
		pl:SetGroundEntity(NULL)
		pl:SetNextMoveVelocity(pl:SyncAngles():Forward() * 320 + Vector(0, 0, 900))
	end
end

function STATE:Move(pl, move)
	move:SetMaxSpeed(0)
	move:SetMaxClientSpeed(0)

	return MOVE_STOP
end

if not CLIENT then return end

function STATE:ShouldDrawFadeTrail(pl)
	pl.FadeTrailAmount = 1
	return true
end
