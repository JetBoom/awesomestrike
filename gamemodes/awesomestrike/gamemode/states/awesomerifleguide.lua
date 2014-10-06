function STATE:IsIdle()
	return false
end

function STATE:ShouldDrawLocalPlayer(pl)
	return true
end

if SERVER then
function STATE:Think(pl)
	local wep = pl:GetActiveWeapon()
	if not wep:IsValid() or wep:GetClass() ~= "weapon_as_awesomerifle" or not pl:GetStateEntity():IsValid() or pl:KeyDown(IN_ATTACK2) then
		pl:EndState()
	end
end
end

function STATE:Move(pl, move)
	move:SetMaxSpeed(0)
	move:SetMaxClientSpeed(0)
end

function STATE:AdjustMouseSensitivity(pl)
	return 0.5
end

function STATE:Started(pl, oldstate)
	pl:SetStateAngles(Angle(0, 0, 0))
end

if not CLIENT then return end

local ang0 = Angle(0, 0, 0)
function STATE:CreateMove(pl, cmd)
	local bullet = pl:GetStateEntity()
	if pl:GetStateAngles() ~= ang0 and pl:GetStateAngles() ~= bullet.m_AwesomeRifleBounceAngles then
		bullet.m_AwesomeRifleEyeAngles = pl:GetStateAngles()
		bullet.m_AwesomeRifleBounceAngles = bullet.m_AwesomeRifleEyeAngles
	end

	local maxdiff = FrameTime() * 45
	local mindiff = -maxdiff
	local originalangles = bullet.m_AwesomeRifleEyeAngles or pl:EyeAngles()
	local viewangles = cmd:GetViewAngles()

	local diff = math.AngleDifference(viewangles.yaw, originalangles.yaw)
	if diff > maxdiff or diff < mindiff then
		viewangles.yaw = math.NormalizeAngle(originalangles.yaw + math.Clamp(diff, mindiff, maxdiff))
	end
	diff = math.AngleDifference(viewangles.pitch, originalangles.pitch)
	if diff > maxdiff or diff < mindiff then
		viewangles.pitch = math.NormalizeAngle(originalangles.pitch + math.Clamp(diff, mindiff, maxdiff))
	end

	bullet.m_AwesomeRifleEyeAngles = viewangles

	cmd:SetViewAngles(viewangles)
end

function STATE:HUDPaint()
	GAMEMODE:DrawHUDDistortion()
end

function STATE:DrawSpeedTrailEntity(pl)
	local bullet = pl:GetStateEntity()
	if bullet:IsValid() then
		return bullet
	end
end
