STATE.NoDefusing = true

STATE.PrepTime = 0.5

STATE.MoveSpeed = 100

function STATE:IsIdle(pl)
	return true
end

function STATE:Move(pl, move)
	move:SetSideSpeed(math.Clamp(move:GetSideSpeed() * 100, -self.MoveSpeed, self.MoveSpeed))
	move:SetForwardSpeed(math.Clamp(move:GetForwardSpeed() * 100, -self.MoveSpeed, self.MoveSpeed))
	move:SetMaxSpeed(self.MoveSpeed)
	move:SetMaxClientSpeed(self.MoveSpeed)
end

function STATE:CalcMainActivity(pl, velocity)
	return velocity:Length2D() >= 0.5 and ACT_MP_CROUCHWALK or ACT_MP_CROUCH_IDLE, -1 --return 0, 55
end

function STATE:ShouldDrawLocalPlayer(pl)
	return true
end

function STATE:Started(pl, oldstate)
	if SERVER then
		pl:SetEnergy(pl:GetEnergy() - 10, -5, true)
		pl:EmitSound("awesomestrike/forceshieldon.wav", 65, 80)

		local ent = ents.Create("prop_forceshield")
		if ent:IsValid() then
			ent:SetOwner(pl)
			ent:SetPos(pl:EyePos())
			ent:Spawn()
			ent:AlignToOwner()
		end
	end
end

function STATE:Ended(pl, newstate)
	pl:SetEnergyRegeneration(ENERGY_DEFAULT_REGENERATION, true)

	if SERVER then
		pl:EmitSound("awesomestrike/forceshieldoff.wav", 65, 100)

		for _, ent in pairs(ents.FindByClass("prop_forceshield")) do
			if ent:GetOwner() == pl then ent:Remove() end
		end
	end
end

if SERVER then
function STATE:Think(pl)
	if pl:GetEnergy() <= 0 or not pl:IsIdle() or pl:KeyDown(IN_ATTACK) or pl:KeyDown(IN_ATTACK2) or not pl:OnGround() or pl:GetSkill() ~= SKILL_FORCESHIELD then
		pl:EndState()
	end
end
end
