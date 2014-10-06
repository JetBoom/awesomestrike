--STATE.NoJumping = true

function STATE:IsIdle(pl)
	return false
end

function STATE:Started(pl, oldstate)
	local effectdata = EffectData()
		effectdata:SetOrigin(pl:GetPos())
		effectdata:SetEntity(pl)
	util.Effect("bswordspin", effectdata)

	if SERVER then pl:EmitSound("npc/manhack/grind"..math.random(5)..".wav") end

	--pl:ResetJumpPower()
end

--[[function STATE:Ended(pl, newstate)
	pl:ResetJumpPower(true)
end]]

function STATE:Move(pl, move)
	move:SetMaxSpeed(move:GetMaxSpeed() / 3)
	move:SetMaxClientSpeed(move:GetMaxClientSpeed() / 3)
end

function STATE:ShouldBlockBullet(pl, bullet, tr)
	return tr.Normal:Dot(pl:GetAimVector()) <= -0.5 --and tr.HitPos.z - pl:GetPos().z >= pl:OBBMaxs().z / 3
end

--[[function STATE:OnHitWithBullet(pl, bullet, tr, prehit)
	if self:ShouldBlockBullet(pl, bullet, tr) then
		bullet.ForceShielded = true

		local bulletowner = bullet:GetOwner()

		bullet:SetOwner(pl)
		bullet:StoreAttackerState(pl)
		if bulletowner:IsValid() and bulletowner:IsPlayer() and bulletowner:GetStateEntity() == bullet then
			bulletowner:SetStateEntity(NULL)
		end
		bullet.BulletFilter = pl:GetAttackFilter()
		bullet:SetColor(team.GetColor(pl:Team()) or color_white)

		local phys = bullet:GetPhysicsObject()
		if phys:IsValid() then
			local newdir = (pl:GetAimVector() * 2 + VectorRand():GetNormalized()) / 3
			sound.Play("weapons/fx/rics/ric"..math.random(1, 5)..".wav", tr.HitPos, 70, math.random(100, 110))
			bullet.LastPosition = tr.HitPos + newdir * 0.5
			if not prehit then phys:SetPos(bullet.LastPosition) end
			phys:SetVelocityInstantaneous(newdir * bullet.Speed)
		end

		return 1
	end
end]]

if SERVER then
function STATE:Think(pl)
	pl:ForceUnDuck2()
end
end

if not CLIENT then return end

function STATE:Think(pl)
	pl:SetLuaAnimation("bswordspin")
	pl:ForceUnDuck2()
end

function STATE:ThinkOther(pl)
	pl:SetLuaAnimation("bswordspin")
end
