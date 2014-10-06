local meta = FindMetaTable("Player")
if not meta then return end

function meta:SetNextRespawn(time)
	umsg.Start("respawntime", self)
		umsg.Float(time)
	umsg.End()

	self.m_RespawnTime = time
end

function meta:ChangeTeam(teamid, forced, noannounce)
	local oldteam = self:Team()
	self:RemoveTomb()
	self:SetTeam(teamid)
	self:SetDiedThisRound(true)
	self:SetDesiredSkill()
	self:StripWeapons()
	if not forced then
		if self:Alive() then
			self:Kill()
		else
			self:Spawn()
		end
	end

	if teamid == TEAM_T or teamid == TEAM_CT then
		self.KeyPressedThisRound = true

		if not noannounce then
			if NDB then
				local col = team.GetColor(teamid)
				PrintMessage(HUD_PRINTTALK, self:NoParseName().." has joined the <c="..col.r..","..col.g..","..col.b..">"..team.GetName(teamid).."</c>.")
			else
				PrintMessage(HUD_PRINTTALK, self:Name().." is joining the "..team.GetName(teamid)..".")
			end
		end
	end

	if not forced and (teamid == TEAM_SPECTATOR and (oldteam == TEAM_T or oldteam == TEAM_CT) or teamid == TEAM_T and oldteam == TEAM_CT or teamid == TEAM_CT and oldteam == TEAM_T) then
		GAMEMODE:EndWinStreak(self)
		GAMEMODE:EndKillStreak(self)
	end

	if oldteam ~= self:Team() then
		self:RemoveAllProjectiles()
	end

	timer.SimpleEx(0.1, gamemode.Call, "CheckRoundStatus")
end

function meta:SetMaxHealthEx(maxhealth)
	self:SetMaxHealth(maxhealth)
	self:SetDTInt(2, maxhealth)
end

function meta:GetMaxHealthEx()
	return self:GetMaxHealth()
end

function meta:SwitchToBestWeapon(oldwep)
	local weps = self:GetWeapons()

	for i = 0, 6 do
		for _, wep in pairs(weps) do
			if wep.Slot == i and oldwep ~= wep then
				self:SelectWeapon(wep:GetClass())

				return wep
			end
		end
	end
end

function meta:SetEnergy(energy, regeneration, send)
	self.Energy = energy
	self.EnergyRegeneration = regeneration or self.EnergyRegeneration
	self.EnergyBase = CurTime()
	if send then
		umsg.Start("setenergy", self)
			umsg.Float(self.Energy)
			umsg.Float(self.EnergyRegeneration)
			umsg.Float(self.EnergyBase)
		umsg.End()
	end
end

function meta:SetCombo(combo, send)
	self.Combo = combo
	self.ComboEndTime = CurTime() + GAMEMODE.ComboTime
	if send then
		umsg.Start("setcombo", self)
			umsg.Short(self.Combo)
			umsg.Float(self.ComboEndTime)
		umsg.End()
	end
end

function meta:GiveValidLoadout()
	local slots = {}

	for i=1, 3 do
		local buyable = GAMEMODE:GetBuyable(self, tonumber(self:GetInfo("awesomestrike_weapon"..i)) or 0)

		if buyable and not self:HasWeapon(buyable.SWEP) then
			local slot = i - 1
			for _, curwep in pairs(self:GetWeapons()) do
				if curwep.Slot == slot then
					self:StripWeapon(curwep:GetClass())
					break
				end
			end

			self:Give(buyable.SWEP)

			slots[i] = buyable.SWEP
		end

		slots[i] = slots[i] or "weapon_as_unarmed"
	end

	if not self:HasWeapon("weapon_as_unarmed") then self:Give("weapon_as_unarmed") end

	net.Start("as_weaponbindslots")
		net.WriteString(slots[1])
		net.WriteString(slots[2])
		net.WriteString(slots[3])
	net.Send(self)
end

local vecoffset1 = Vector(0, 0, 1)
function meta:Think()
	if CurTime() >= self.NextHealthRegen and CurTime() >= self.LastDamaged + 4 and self:Alive() and self:Health() < self:GetMaxHealth() then
		self.NextHealthRegen = CurTime() + 0.5
		self:SetHealth(self:Health() + 1)
	end

	self:ThinkShared()

	local obs = self:GetObserverMode()
	if obs == OBS_MODE_CHASE or obs == OBS_MODE_IN_EYE then
		local target = self:GetObserverTarget()
		if target and target:IsValid() then
			self:SetPos(target:GetPos() + vecoffset1)
		end
	end
end

function meta:StartFakeAnimations(mdl)
	self:EndFakeAnimations()

	local status = self:GiveStatus("fakeanimations")
	if status:IsValid() then
		self.m_PreFakeAnimModel = self:GetModel()
		status:SetModel(self.m_PreFakeAnimModel)
		self:SetModel(mdl)
	end
end

function meta:EndFakeAnimations()
	self:RemoveStatus("fakeanimations", false, true)

	if self.m_PreFakeAnimModel then
		self:SetModel(self.m_PreFakeAnimModel)
		self.m_PreFakeAnimModel = nil
	end
end

function meta:RemoveAllProjectiles()
	for _, ent in pairs(ents.FindByClass("projectile_*")) do
		if ent:GetOwner() == self then
			ent:Remove()
		end
	end
end

function meta:AddPoints(points)
	if GAMEMODE:IsOnStreak(self) then
		points = points * 2
	end

	self:AddFrags(points)

	--[[if self:Alive() and points > 0 then
		self:SetHealth(math.min(self:GetMaxHealthEx(), self:Health() + points * 3))
	end]]

	gamemode.Call("AddedPoints", self, points)
end

function meta:EndState(nocallended)
	self:SetState(STATE_NONE, nil, nil, nocallended)
end

function meta:DropWeaponEx(wep)
	if wep and wep:IsValid() then
		wep:OnHolster()
	end

	return self:DropWeapon(wep)
end

function meta:AddNotice(message, lifetime, colid)
	GAMEMODE:AddNotice(message, lifetime, colid, self)
end

function meta:SpawnTomb(atspawn, attacker)
	self:RemoveTomb()

	local ent = ents.Create("prop_playertomb")
	if ent:IsValid() then
		local pos
		if atspawn then
			local teamid = self:Team() == TEAM_CT and TEAM_T or TEAM_CT
			local spawns = team.GetSpawnPoint(teamid)
			if #spawns > 0 then
				pos = spawns[math.random(#spawns)]:GetPos()
			else
				pos = self:GetPos()
			end
		else
			pos = self:GetPos()
		end
		ent:SetPos(pos)
		ent:Spawn()
		ent:SetTeam(self:Team())

		local tr = self:GetToGroundTrace(nil, pos)
		if tr.Hit then
			ent:SetPos(tr.HitPos + tr.HitNormal * 17)
			ent:SetAngles(Angle(0, self:GetAngles().yaw, 0))
			if tr.Entity and tr.Entity:IsValid() then
				ent:SetParent(tr.Entity)
				if tr.PhysicsBone ~= 0 then
					ent:SetParentPhysNum(tr.PhysicsBone)
				end
			end
		end
		
		ent:SetRevivePlayer(self)
		if GAMEMODE.RespawnTime > 0 then
			ent:SetAutoSpawnTime(CurTime() + GAMEMODE.RespawnTime)
		end
		ent.Attacker = attacker

		self:SetTomb(ent)
	end
end

function meta:RemoveTomb()
	local ent = self:GetTomb()
	if ent:IsValid() then ent:Remove() end
end

function meta:GetTomb()
	return self.m_Tomb or NULL
end

function meta:IsFrozen()
	return self.m_IsFrozen
end

meta.OldFreeze = meta.Freeze
function meta:Freeze(bFreeze)
	self.m_IsFrozen = bFreeze
	self:OldFreeze(bFreeze)
end

function meta:BloodSpray(pos, num, dir, force)
	if self.DisableBlood then return end

	local effectdata = EffectData()
		effectdata:SetOrigin(pos)
		effectdata:SetMagnitude(num)
		effectdata:SetNormal(dir)
		effectdata:SetScale(force)
		effectdata:SetEntity(self)
	util.Effect("bloodstream", effectdata, true, true)
end

function meta:RemoveAllStatus(bSilent, bInstant)
	if bInstant then
		for _, ent in pairs(ents.FindByClass("status_*")) do
			if not ent.NoRemoveOnDeath and ent:GetOwner() == self then
				ent:Remove()
			end
		end
	else
		for _, ent in pairs(ents.FindByClass("status_*")) do
			if not ent.NoRemoveOnDeath and ent:GetOwner() == self then
				ent.SilentRemove = bSilent
				ent:SetDie()
			end
		end
	end
end

function meta:RemoveStatus(sType, bSilent, bInstant)
	local removed
	for _, ent in pairs(ents.FindByClass("status_"..sType)) do
		if ent:GetOwner() == self then
			if bInstant then
				ent:Remove()
			else
				ent.SilentRemove = bSilent
				ent:SetDie()
			end
			removed = true
		end
	end
	return removed
end

function meta:GetStatus(sType)
	local ent = self["status_"..sType]
	if ent and ent:IsValid() and ent.Owner == self then return ent end
end

function meta:GiveStatus(sType, fDie)
	local cur = self:GetStatus(sType)
	if cur then
		if fDie then
			cur:SetDie(fDie)
		end
		cur:SetPlayer(self, true)
		return cur
	else
		local ent = ents.Create("status_"..sType)
		if ent:IsValid() then
			ent:Spawn()
			if fDie then
				ent:SetDie(fDie)
			end
			ent:SetPlayer(self)
			return ent
		end
	end
end

function meta:ForceRespawn()
	self:StripWeapons()
	self.LastDeath = CurTime()
	self:RemoveAllStatus(true, true)
	self:Spawn()
	self.SpawnTime = CurTime()
end
