STATE.NoFootsteps = true

STATE.Speed = 800

function STATE:IsIdle(pl)
	return false
end

function STATE:Started(pl, oldstate)
	pl.m_BerserkerSwordEyeAngles = nil
	if SERVER then pl:EmitSound("npc/env_headcrabcanister/incoming.wav") end
end

function STATE:Ended(pl, newstate)
	pl.m_BerserkerSwordEyeAngles = nil
	if 0 < pl:Health() then
		pl:CallWeaponFunction("BerserkerSwordDashEnded", newstate)
	end
end

function STATE:Move(pl, move)
	local speed = math.Clamp((pl:GetStateEnd() - CurTime()) * 10, 0, 1) * math.max(pl:GetMaxSpeed(), self.Speed)

	move:SetSideSpeed(0)
	move:SetMaxSpeed(speed)
	move:SetMaxClientSpeed(speed)
	move:SetForwardSpeed(speed)
	move:SetVelocity(pl:SyncAngles():Forward() * speed)

	return MOVE_STOP
end

function STATE:CalcMainActivity(pl, velocity)
	return ACT_MP_SWIM, -1
end

function STATE:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	pl:SetPlaybackRate(0)
	pl:SetCycle(0.1)

	return true
end

if not CLIENT then return end

function STATE:CreateMove(pl, cmd)
	local maxdiff = FrameTime() * 90
	local mindiff = -maxdiff
	local originalangles = pl.m_BerserkerSwordEyeAngles or pl:EyeAngles()
	local viewangles = cmd:GetViewAngles()

	local diff = math.AngleDifference(viewangles.yaw, originalangles.yaw)
	if diff > maxdiff or diff < mindiff then
		viewangles.yaw = math.NormalizeAngle(originalangles.yaw + math.Clamp(diff, mindiff, maxdiff))
	end

	pl.m_BerserkerSwordEyeAngles = viewangles

	cmd:SetViewAngles(viewangles)
end

function STATE:ShouldDrawFadeTrail(pl)
	pl.FadeTrailAmount = 1
	return true
end

local function CreateParticles(emitter, pos)
	local particle = emitter:Add("effects/fire_cloud"..math.random(2), pos)
	particle:SetDieTime(math.Rand(1, 1.25))
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(math.Rand(1, 6))
	particle:SetEndSize(0)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-10, 10))
end
function STATE:PostPlayerDraw(pl)
	local emitter = ParticleEmitter(pl:GetPos())
	emitter:SetNearClip(24, 32)

	local boneindex = pl:LookupBone("valvebiped.bip01_l_foot")
	if boneindex then
		local pos, ang = pl:GetBonePositionMatrixed(boneindex)
		if pos then
			CreateParticles(emitter, pos)
		end
	end

	boneindex = pl:LookupBone("valvebiped.bip01_r_foot")
	if boneindex then
		local pos, ang = pl:GetBonePositionMatrixed(boneindex)
		if pos then
			CreateParticles(emitter, pos)
		end
	end

	local weaponstatus = pl:GetActiveWeapon()
	if IsValid(weaponstatus) then
		local mins, maxs = weaponstatus:OBBMins(), weaponstatus:OBBMaxs()
		for i=1, 6 do
			CreateParticles(emitter, weaponstatus:LocalToWorld(Vector(math.Rand(mins.x, maxs.x), math.Rand(mins.y, maxs.y), math.Rand(mins.z, maxs.z))))
		end
	end

	emitter:Finish()
end
