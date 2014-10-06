function STATE:Started(pl, oldstate)
	pl.NextWallJump = pl:GetStateEnd() + 0.1
	if SERVER then pl:EmitSound("weapons/physcannon/energy_sing_flyby"..math.random(2)..".wav", 70, 100, 0.9) end
end

function STATE:GoToNextState(pl)
	pl:SetState(STATE_WALLJUMPEND, 1, pl:GetStateEntity())

	return true
end

function STATE:Ended(pl, newstate)
	pl.NextWallJump = pl:GetStateEnd() + 0.1
	if newstate == STATE_NONE then
		pl:SetAnimation(PLAYER_JUMP)
		local dir = pl:GetStateAngles():Forward()
		pl:SetGroundEntity(NULL)
		pl:SetLocalVelocity(dir * 500 + Vector(0, 0, 400))
		pl.WallJumpInAir = true

		if SERVER then
			local ent = pl:GetStateEntity()
			if ent:IsValid() then
				if ent:IsPlayer() then
					if ent:Team() ~= pl:Team() then
						ent:SetGroundEntity(NULL)
						ent:KnockDown()
						local vel = dir * -600
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
		end
	end
end

function STATE:Move(pl, move)
	move:SetVelocity(Vector(0, 0, 0))

	return MOVE_OVERRIDE
end

function STATE:CalcMainActivity(pl, velocity)
	return ACT_MP_SWIM, -1
end

function STATE:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	pl:SetPlaybackRate(0)
	pl:SetCycle(0)

	pl:SetPoseParameter("move_yaw", math.NormalizeAngle(pl:GetStateAngles().yaw - pl:EyeAngles().yaw))

	return true
end
