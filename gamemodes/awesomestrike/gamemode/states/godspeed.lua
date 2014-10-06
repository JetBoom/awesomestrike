STATE.NoDefusing = true

STATE.NoFootsteps = true

function STATE:IsIdle(pl)
	return true
end

function STATE:Move(pl, move)
	move:SetSideSpeed(move:GetSideSpeed() * 1.25)
	move:SetForwardSpeed(move:GetForwardSpeed() * 1.25)
	move:SetMaxSpeed(move:GetMaxSpeed() * 1.25)
	move:SetMaxClientSpeed(move:GetMaxClientSpeed() * 1.25)
end

function STATE:ShouldDrawLocalPlayer(pl)
	return true
end

function STATE:Started(pl, oldstate)
	if SERVER then
		pl:SetEnergy(0, 0, true)
		pl:EmitSound("ambient/levels/citadel/portal_beam_shoot6.wav", 65, 120)
	end
end

function STATE:Ended(pl, newstate)
	pl:SetEnergyRegeneration(ENERGY_DEFAULT_REGENERATION / 2, true)

	if SERVER then
		pl:EmitSound("ambient/levels/citadel/portal_beam_shoot1.wav", 65, 120)
	end
end

if SERVER then
function STATE:Think(pl)
	if not pl:IsIdle() or pl:KeyDown(IN_ATTACK) or pl:KeyDown(IN_ATTACK2) then
		pl:EndState()
	end
end
end

function STATE:CalcMainActivity(pl, velocity)
	return velocity:Length() > 0.5 and ACT_MP_RUN or ACT_MP_IDLE, -1
end

function STATE:ShouldDodgeBullet(pl, bullet, tr)
	return true
end

function STATE:ShouldDodgeMelee(pl, attacker, inflictor)
	return true
end

if not CLIENT then return end

function STATE:ShouldDrawFadeTrail(pl)
	pl.FadeTrailAmount = 1
	return true
end

local matRefract = Material("refract_ring")
function STATE:PrePlayerDraw(pl)
	local basetime = CurTime() * 5
	local basepos = pl:GetPos()

	render.UpdateRefractTexture()
	matRefract:SetFloat("$refractamount", 0.04)

	render.SetMaterial(matRefract)
	for i=1, pl:GetBoneCount() - 1 do
		local pos, ang = pl:GetBonePositionMatrixed(i)
		if pos and pos ~= basepos then
			local time = basetime + i
			ang:RotateAroundAxis(ang:Forward(), time)
			render.DrawSprite(pos + math.sin(time) * 5 * ang:Up(), 32, 32)
		end
	end
end
