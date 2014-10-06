function STATE:Started(pl, oldstate)
	pl:SetAnimation(PLAYER_JUMP)
	pl:SetGroundEntity(NULL)
	pl.WallJumpInAir = true

	pl:ViewPunch(Angle(-5, 0, 0))

	if SERVER then
		local ent = pl:GetStateEntity()
		if ent:IsValid() then
			if ent:IsPlayer() then
				if ent:Team() ~= pl:Team() then
					ent:SetGroundEntity(NULL)
					ent:KnockDown()
					local vel = pl:GetStateAngles():Forward() * -600
					vel.z = vel.z * -1
					ent:SetVelocity(vel)
					ent:SetLastAttacker(pl)
				end
			elseif ent:GetMoveType() == MOVETYPE_VPHYSICS then
				local phys = ent:GetPhysicsObject()
				if phys:IsValid() and phys:IsMoveable() then
					local vel = pl:GetVelocity() * -1
					vel.z = vel.z * -0.5
					phys:ApplyForceOffset(pl:GetPhysicsObject():GetMass() * vel, (ent:NearestPoint(pl:GetStateVector()) + ent:GetPos() * 2) / 3)
					ent:SetPhysicsAttacker(pl)
				end
			end
		end

		if pl.WallJumpHitPos then
			local effectdata = EffectData()
				effectdata:SetOrigin(pl.WallJumpHitPos)
				effectdata:SetNormal(pl.WallJumpHitNormal)
			util.Effect("walljump", effectdata)
		end
	end
end

function STATE:Move(pl, move)
	local dir = pl:GetStateAngles():Forward()
	pl:SetGroundEntity(NULL)
	move:SetVelocity(dir * 500 + Vector(0, 0, 400))
	pl:SetStateEnd(1)

	return MOVE_STOP
end
