ENT.Type = "brush"

function ENT:Initialize()
end

function ENT:Think()
end

function ENT:StartTouch(ent)
	if ent:IsPlayer() then
		ent.CanRescueHostage = self
		ent:SendLua("CanRescueHostage="..self:EntIndex())

		if ent:GetState() == STATE_CARRYHOSTAGE then
			local hostage = ent:GetStateEntity()
			if hostage:IsValid() and hostage:GetClass() == "npc_hostage" and not hostage.Rescued then
				hostage.Rescued = true

				team.AddNotice(TEAM_CT, "A hostage has been rescued!~sradio/rescued.wav", nil, COLID_BLUE)
				team.AddNotice(TEAM_T, "A hostage has been rescued!~sradio/rescued.wav", nil, COLID_RED)

				ent:AddPoints(2)

				local shouldend = true
				for _, otherhostage in pairs(ents.FindByClass("npc_hostage")) do
					if not otherhostage.Rescued then
						shouldend = false
					end
				end

				if shouldend then
					gamemode.Call("EndRound", TEAM_CT, false, 3)
				end

				hostage:EndCarry(nil, true)
				hostage:Remove()
			end
		end
	end
end

function ENT:EndTouch(ent)
	if ent.CanRescueHostage == self then
		ent.CanRescueHostage = nil
		ent:SendLua("CanRescueHostage=nil")
	end
end

function ENT:Touch(ent)
end
