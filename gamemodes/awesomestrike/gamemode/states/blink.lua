STATE.BlinkTime = 0.25

function STATE:IsIdle(pl)
	return false
end

function STATE:GoToNextState(pl)
	if pl:Alive() then
		pl:SetPos(pl:GetStateVector())
		local ang = pl:GetStateAngles()
		ang.pitch = pl:EyeAngles().pitch
		pl:SetEyeAngles(ang)

		if SERVER then
			pl.LastBlinkExit = CurTime()

			pl:TemporaryNoCollide()

			local effectdata = EffectData()
				effectdata:SetOrigin(pl:GetBlinkPos())
				effectdata:SetEntity(pl)
			util.Effect("blinkexit", effectdata, true, true)
		end
	end

	pl:SetSkillVector(Vector(0, 0, 0))
	pl:SetSkillAngle(Angle(0, 0, 0))

	pl:SetState(STATE_BLINKEND, self.BlinkTime)

	return true
end

function STATE:Started(pl, oldstate)
	if SERVER then
		pl:EmitSound(")weapons/physcannon/superphys_launch"..math.random(2, 4)..".wav", 60, 250)
	end
end

function STATE:GetDelta(pl)
	return math.Clamp((pl:GetStateEnd() - CurTime()) / self.BlinkTime, 0, 1)
end

if not CLIENT then return end

function STATE:HUDPaint(pl)
	surface.SetDrawColor(255, 255, 255,  math.Clamp((pl:GetStateStart() - CurTime()) / self.BlinkTime, 0, 1) * 255)
	surface.DrawRect(0, 0, ScrW(), ScrH())
end

function STATE:PrePlayerDraw(pl)
	if pl ~= MySelf then
		local delta = self:GetDelta(pl)
		if delta <= 0.5 then
			render.SetBlend(delta * 2)
		end
	end
end

local matGlow = Material("effects/yellowflare")
local colSprite = Color(255, 255, 255, 255)
function STATE:PostPlayerDraw(pl)
	render.SetBlend(1)

	local delta = self:GetDelta(pl)
	local pos = pl:GetBlinkPos()
	colSprite.a = (1 - delta) * 255

	render.SetMaterial(matGlow)
	render.DrawSprite(pos, delta * 256, delta * 128, colSprite)
	render.DrawSprite(pos, delta * 128, delta * 256, colSprite)
end
