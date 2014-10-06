STATE.NoHostileStateChanges = true
STATE.NoDefusing = true

function STATE:ProcessDamage(pl, dmginfo)
	local attacker = dmginfo:GetAttacker()
	if attacker:IsValid() and attacker:IsPlayer() then
		dmginfo:SetDamage(0)
		dmginfo:ScaleDamage(0)
	end
end

function STATE:ShouldDodgeBullet(pl, bullet, tr)
	return true
end

function STATE:ShouldDodgeMelee(pl, attacker, inflictor)
	return true
end

if SERVER then
function STATE:Think(pl)
	if pl:KeyDown(IN_ATTACK) or pl:KeyDown(IN_ATTACK2) or pl:KeyDown(IN_SPEED) or pl:KeyDown(IN_RELOAD) then pl:EndState() end
end
end

if not CLIENT then return end

function STATE:GetBrightness(pl)
	return math.abs(math.sin(CurTime() * 10)) * math.Clamp((pl:GetStateEnd() - CurTime()) ^ 0.5, 0, 1)
end

function STATE:HUDPaint(pl)
	surface.SetDrawColor(255, 255, 255, self:GetBrightness(pl) * 45)
	surface.DrawRect(0, 0, ScrW(), ScrH())
end

function STATE:PrePlayerDraw(pl)
	render.SetBlend(1 - self:GetBrightness(pl) * 0.8)
end

function STATE:PostPlayerDraw(pl)
	render.SetBlend(1)
end

STATE.PreDrawViewModel = STATE.PrePlayerDraw
STATE.PostDrawViewModel = STATE.PostPlayerDraw
