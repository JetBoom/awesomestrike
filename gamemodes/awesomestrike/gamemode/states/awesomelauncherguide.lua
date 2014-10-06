function STATE:IsIdle()
	return false
end

function STATE:ShouldDrawLocalPlayer(pl)
	return true
end

if SERVER then
function STATE:Think(pl)
	local wep = pl:GetActiveWeapon()
	if not wep:IsValid() or wep:GetClass() ~= "weapon_as_awesomelauncher" or not pl:GetStateEntity():IsValid() or pl:KeyDown(IN_ATTACK2) then
		pl:EndState()
	end
end
end

function STATE:Move(pl, move)
	move:SetMaxSpeed(0)
	move:SetMaxClientSpeed(0)
end

if CLIENT then

function STATE:HUDPaint()
	GAMEMODE:DrawHUDDistortion()
end

function STATE:DrawSpeedTrailEntity(pl)
	local bullet = pl:GetStateEntity()
	if bullet:IsValid() then
		return bullet
	end
end

end
