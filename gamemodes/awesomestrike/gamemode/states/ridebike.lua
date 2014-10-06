STATE.CantUseWeapons = true
STATE.NoDefusing = true

STATE.MaxSpeed = 1200
STATE.MaxTurnRate = 120
STATE.IdealSpeed = STATE.MaxSpeed / 2
STATE.Acceleration = 300

function STATE:Move(pl, move)
	move:SetSideSpeed(0)
	move:SetForwardSpeed(0)
	move:SetMaxSpeed(0)
	move:SetMaxClientSpeed(0)

	local ent = pl:GetStateEntity()
	if ent:IsValid() then
		move:SetOrigin(ent:GetPos())
	end

	return MOVE_OVERRIDE

	--[[move:SetSideSpeed(0)
	move:SetForwardSpeed(0)
	move:SetMaxSpeed(0)
	move:SetMaxClientSpeed(0)

	pl:SetGroundEntity(NULL)

	if pl:StandingOnSomething() then
		local newvel = move:GetVelocity()
		if pl:KeyDown(IN_FORWARD) then
			newvel = newvel + self.Acceleration * FrameTime() * pl:GetForward()
		elseif pl:KeyDown(IN_BACK) then
			newvel = newvel - self.Acceleration * FrameTime() * 0.2 * pl:GetForward()
		end

		if newvel:Length() >= self.MaxSpeed then newvel = newvel:GetNormalized() * self.MaxSpeed end
		move:SetVelocity(newvel)
	end

	return MOVE_STOP]]
end

function STATE:ShouldDrawLocalPlayer(pl)
	return true
end

function STATE:Started(pl, oldstate)
	if SERVER then
		local ent = ents.Create("prop_bike")
		if ent:IsValid() then
			ent:SetOwner(pl)
			ent:SetPos(pl:GetPos())
			ent:Spawn()
			pl:SetStateEntity(ent)
		end
	end
end

function STATE:Ended(pl, newstate)
	if SERVER then
		for _, ent in pairs(ents.FindByClass("prop_bike")) do
			if ent:GetOwner() == pl then ent:Remove() end
		end
	end
end

if SERVER then
function STATE:Think(pl)
	local ent = pl:GetStateEntity()
	if not ent:IsValid() then
		pl:EndState()
		return
	end
end
end

--[[
if not CLIENT then return end

local ang0 = Angle(0, 0, 0)
function STATE:CreateMove(pl, cmd)
	local ent = pl:GetStateEntity()
	if not ent.m_Angles then
		ent.m_Angles = pl:SyncAngles()
	end

	local maxdiff = FrameTime() * (1 - math.abs(200 - self.IdealSpeed) / self.IdealSpeed) * self.MaxTurnRate
	local mindiff = -maxdiff
	local originalangles = ent.m_Angles or pl:SyncAngles()
	local viewangles = cmd:GetViewAngles()

	local diff = math.AngleDifference(viewangles.yaw, originalangles.yaw)
	if diff > maxdiff or diff < mindiff then
		viewangles.yaw = math.NormalizeAngle(originalangles.yaw + math.Clamp(diff, mindiff, maxdiff))
	end
	diff = math.AngleDifference(viewangles.pitch, originalangles.pitch)
	if diff > maxdiff or diff < mindiff then
		viewangles.pitch = math.NormalizeAngle(originalangles.pitch + math.Clamp(diff, mindiff, maxdiff))
	end

	ent.m_Angles = viewangles

	cmd:SetViewAngles(viewangles)
end]]
