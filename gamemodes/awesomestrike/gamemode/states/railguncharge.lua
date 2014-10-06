STATE.ChargeTime = 3

function STATE:Started(pl, oldstate)
	pl.m_RailGunEyeAngles = nil

	if SERVER then SuppressHostEvents(pl) end
	local effectdata = EffectData()
		effectdata:SetOrigin(pl:GetShootPos())
		effectdata:SetEntity(pl)
	util.Effect("railguncharge", effectdata)
	if SERVER then SuppressHostEvents(NULL) end
end

function STATE:Ended(pl, oldstate)
	pl.m_RailGunEyeAngles = nil
end

function STATE:GetRailGunCharge(pl)
	return math.Clamp(CurTime() - pl:GetStateStart(), 0, self.ChargeTime) / self.ChargeTime
end

function STATE:IsIdle()
	return false
end

if SERVER then
function STATE:Think(pl)
	local wep = pl:GetActiveWeapon()
	if not wep:IsValid() or wep:GetClass() ~= "weapon_as_railgun" then
		pl:EndState()
	end
end
end

function STATE:Move(pl, move)
	local multiplier = 1 - self:GetRailGunCharge(pl) * 0.5
	move:SetMaxSpeed(move:GetMaxSpeed() * multiplier)
	move:SetMaxClientSpeed(move:GetMaxClientSpeed() * multiplier)
end

function STATE:AdjustMouseSensitivity(pl)
	return math.max(0.3, 1 - self:GetRailGunCharge(pl))
end

if not CLIENT then return end

function STATE:CreateMove(pl, cmd)
	local maxdiff = FrameTime() * self:AdjustMouseSensitivity(pl) * 90
	local mindiff = -maxdiff
	local originalangles = pl.m_RailGunEyeAngles or pl:EyeAngles()
	local viewangles = cmd:GetViewAngles()

	local diff = math.AngleDifference(viewangles.yaw, originalangles.yaw)
	if diff > maxdiff or diff < mindiff then
		viewangles.yaw = math.NormalizeAngle(originalangles.yaw + math.Clamp(diff, mindiff, maxdiff))
	end
	diff = math.AngleDifference(viewangles.pitch, originalangles.pitch)
	if diff > maxdiff or diff < mindiff then
		viewangles.pitch = math.NormalizeAngle(originalangles.pitch + math.Clamp(diff, mindiff, maxdiff))
	end

	pl.m_RailGunEyeAngles = viewangles

	cmd:SetViewAngles(viewangles)
end

local matGlow = Material("effects/rollerglow")
local matLaser = Material("trails/laser")
function STATE:DrawEffectAtPos(pl, pos)
	local col = team.GetColor(pl:Team()) or color_white
	local charge = self:GetRailGunCharge(pl)

	local eyeangles = pl:EyeAngles()
	eyeangles:RotateAroundAxis(eyeangles:Forward(), CurTime() * 360)

	local spritesize = math.abs(math.sin(CurTime() * 6)) * 6 + charge * 18
	render.SetMaterial(matGlow)
	render.DrawSprite(pos, spritesize, spritesize, col)

	local r, g, b = col.r, col.g, col.b
	local emitter = pl:ParticleEmitter()
	local curvel = pl:GetVelocity()
	for i=1, 4 do
		eyeangles:RotateAroundAxis(eyeangles:Forward(), 90)
		local dir = eyeangles:Up()

		local particle = emitter:Add("sprites/glow04_noz", pos + dir)
		particle:SetVelocity((charge + 1) * 72 * dir)
		particle:SetDieTime(0.25)
		particle:SetStartSize(1 + charge * 6)
		particle:SetEndSize(0)
		particle:SetStartAlpha(0)
		particle:SetEndAlpha(255)
		particle:SetAirResistance(8)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-8, 8))
		particle:SetColor(r, g, b)
	end

	local dlight = DynamicLight(pl:EntIndex() + 2048)
	if dlight then
		dlight.Pos = pos
		dlight.r = 0
		dlight.g = 255
		dlight.b = 255
		dlight.Brightness = 1
		local size = 128 + charge * 256
		dlight.Size = size
		dlight.Decay = size
		dlight.DieTime = CurTime() + 1
	end
end

function STATE:PreDrawViewModel(pl, viewmodel)
	if viewmodel.SkipDrawHooks then return end

	local startpos
	local attach = viewmodel:GetAttachment(1)
	if attach then
		startpos = attach.Pos
	else
		startpos = viewmodel:GetPos()
	end

	self:DrawEffectAtPos(pl, startpos)
end

function STATE:PostPlayerDraw(pl)
	local startpos
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() then
		local attach = wep:GetAttachment(1)
		if attach then
			startpos = attach.Pos
		end
	end

	self:DrawEffectAtPos(pl, startpos or pl:GetShootPos())
end
