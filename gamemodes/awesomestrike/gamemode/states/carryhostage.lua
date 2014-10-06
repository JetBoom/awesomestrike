function STATE:ShouldDrawLocalPlayer(pl)
	return true
end

function STATE:Move(pl, move)
	move:SetMaxSpeed(move:GetMaxSpeed() * 0.85)
	move:SetMaxClientSpeed(move:GetMaxClientSpeed() * 0.85)
end

if SERVER then
function STATE:Think(pl)
	if not pl:GetStateEntity():IsValid() then
		pl:EndState()
	end
end

function STATE:Started(pl, oldstate)
	pl:Give("weapon_as_hostage")
	pl:SelectWeapon("weapon_as_hostage")
end

function STATE:Ended(pl, newstate)
	local carry = pl:GetStateEntity()
	if carry:IsValid() then
		carry:EndCarry(true)
	end
	pl:StripWeapon("weapon_as_hostage")
end
end


