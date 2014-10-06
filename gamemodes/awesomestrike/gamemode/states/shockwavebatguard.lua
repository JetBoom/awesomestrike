--STATE.NoJumping = true

function STATE:IsIdle(pl)
	return false
end

--[[function STATE:Started(pl, oldstate)
	pl:ResetJumpPower()
end

function STATE:Ended(pl, newstate)
	pl:ResetJumpPower(true)
end]]

function STATE:Move(pl, move)
	move:SetMaxSpeed(move:GetMaxSpeed() * 0.75)
	move:SetMaxClientSpeed(move:GetMaxClientSpeed() * 0.75)
end

--[[function STATE:ShouldBlockBullet(pl, bullet, tr)
	return tr.Normal:Dot(pl:GetAimVector()) <= -0.5 --and tr.HitPos.z - pl:GetPos().z >= pl:OBBMaxs().z / 3
end]]

function STATE:ShouldBlockMelee(pl, attacker, inflictor, tr, isstrong)
	return not isstrong and tr.Normal:Dot(pl:GetAimVector()) <= -0.5
end

if SERVER then
function STATE:Think(pl)
	pl:ForceUnDuck2()
end
end

if not CLIENT then return end

function STATE:Think(pl)
	pl:SetLuaAnimation("swbguard")
	pl:ForceUnDuck2()
end

function STATE:ThinkOther(pl)
	pl:SetLuaAnimation("swbguard")
end
