function STATE:ShouldDrawLocalPlayer(pl)
	return true
end

function STATE:Move(pl, move)
	move:SetMaxSpeed(move:GetMaxSpeed() * 0.85)
	move:SetMaxClientSpeed(move:GetMaxClientSpeed() * 0.85)
end

if SERVER then
function STATE:Think(pl)
	if not pl:GetStateEntity():IsValid() or not pl:GetActiveWeapon():IsValid() or pl:GetActiveWeapon():GetClass() ~= "weapon_as_flag" then
		pl:EndState()
	end
end

function STATE:Started(pl, oldstate)
	local wep = pl:Give("weapon_as_flag")
	if wep and wep:IsValid() and wep:GetOwner() == pl then
		pl:SelectWeapon("weapon_as_flag")
	else
		pl:EndState()
	end
end

function STATE:Ended(pl, newstate)
	local carry = pl:GetStateEntity()
	if carry:IsValid() then
		carry:Drop(pl)
	end
	pl:StripWeapon("weapon_as_flag")
end
end
