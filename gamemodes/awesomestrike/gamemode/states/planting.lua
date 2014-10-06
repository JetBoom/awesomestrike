function STATE:IsIdle(pl)
	return false
end

function STATE:Move(pl, move)
	move:SetMaxSpeed(0)
	move:SetMaxClientSpeed(0)

	return MOVE_STOP
end

if not SERVER then return end

function STATE:Think(pl)
	local wep = pl:GetActiveWeapon()
	if not wep:IsValid() or wep:GetClass() ~= "weapon_as_bomb" then
		pl:EndState()
	end
end
