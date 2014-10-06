function STATE:IsIdle(pl)
	return false
end

function STATE:Think(pl)
	if pl:KeyDown(IN_ATTACK2) then pl:EndState() end
end

function STATE:ShouldDrawLocalPlayer(pl)
	return true
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
