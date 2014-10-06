STATE.BlinkTime = 0.25

function STATE:IsIdle(pl)
	return false
end

function STATE:GetDelta(pl)
	return math.Clamp((pl:GetStateEnd() - CurTime()) / self.BlinkTime, 0, 1)
end

if not CLIENT then return end

function STATE:HUDPaint(pl)
	surface.SetDrawColor(255, 255, 255, (1 - math.Clamp((pl:GetStateEnd() - CurTime()) / self.BlinkTime, 0, 1)) * 255)
	surface.DrawRect(0, 0, ScrW(), ScrH())
end

function STATE:PrePlayerDraw(pl)
	if pl ~= MySelf then
		local delta = 1 - self:GetDelta(pl)
		if delta <= 0.5 then
			render.SetBlend(delta * 2)
		end
	end
end

local matGlow = Material("effects/yellowflare")
local colSprite = Color(255, 255, 255, 255)
function STATE:PostPlayerDraw(pl)
	render.SetBlend(1)

	local delta = 1 - self:GetDelta(pl)
	local pos = pl:GetBlinkPos()
	colSprite.a = (1 - delta) * 255

	render.SetMaterial(matGlow)
	render.DrawSprite(pos, delta * 256, delta * 128, colSprite)
	render.DrawSprite(pos, delta * 128, delta * 256, colSprite)
end
