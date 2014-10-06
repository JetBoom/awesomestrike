local meta = FindMetaTable("Player")
if not meta then return end

function meta:GetState() return self:GetDTInt(0) end
function meta:GetStateTable() return STATES[self:GetState()] end
function meta:GetSkill() return self:GetDTInt(1) end
function meta:GetSkillTable() return SKILLS[self:GetSkill()] end
function meta:GetStateStart() return self:GetDTFloat(0) end
function meta:GetStateEnd() return self:GetDTFloat(1) end
function meta:GetStateNumber() return self:GetDTFloat(2) end
function meta:GetStateEntity() return self:GetDTEntity(0) end
function meta:GetStateVector() return self:GetDTVector(0) end
function meta:GetStateAngles() return self:GetDTAngle(0) end
function meta:GetSkillVector() return self:GetDTVector(1) end
function meta:GetSkillAngle() return self:GetDTAngle(1) end
function meta:GetStateBool() return self:GetDTBool(0) end
function meta:GetDiedThisRound() return self:GetDTBool(1) end
meta.DiedThisRound = meta.GetDiedThisRound
function meta:GetKills() return self:GetDTInt(3) end
meta.Kills = meta.GetKills
function meta:SetKills(kills) self:SetDTInt(3, kills) end
function meta:AddKills(kills) self:SetKills(self:GetKills() + kills) end

function meta:SetState(state, duration, ent, nocallended)
	local oldstate = self:GetState()
	if oldstate ~= state and not nocallended then
		self:CallForcedStateFunction(oldstate, "Ended", state)
	end
	self:SetDTInt(0, state)
	self:SetStateStart(CurTime())
	if duration then
		self:SetStateEnd(CurTime() + duration)
	else
		self:SetStateEnd(0)
	end
	if ent then
		self:SetStateEntity(ent)
	else
		self:SetStateEntity(NULL)
	end

	if oldstate ~= state then
		self:CallForcedStateFunction(state, "Started", oldstate)
	end
end
function meta:SetSkill(skill)
	local oldskill = self:GetSkill()
	self:SetDTInt(1, skill)
	if oldskill ~= skill then
		self:CallForcedSkillFunction(skill, "ChangedTo", state)
		self:CallForcedSkillFunction(skill, "ChangedFrom", oldskill)
	end
end
function meta:SetStateStart(time) self:SetDTFloat(0, time) end
function meta:SetStateEnd(time) self:SetDTFloat(1, time) end
function meta:SetStateNumber(num) self:SetDTFloat(2, num) end
function meta:SetStateEntity(ent) self:SetDTEntity(0, ent) end
function meta:SetStateVector(vec) self:SetDTVector(0, vec) end
function meta:SetStateAngles(ang) self:SetDTAngle(0, ang) end
function meta:SetSkillVector(vec) self:SetDTVector(1, vec) end
function meta:SetSkillAngle(ang) self:SetDTAngle(1, ang) end
function meta:SetStateBool(bool) self:SetDTBool(0, bool) end
function meta:SetDiedThisRound(died) self:SetDTBool(1, died) end
function meta:SetTomb(ent) self.m_Tomb = ent end

function meta:KnockDown(force)
	if not self:AllowHostileStateChanges() then return end

	if force or not self.KnockDownImmunity or CurTime() > self.KnockDownImmunity then
		self:SetState(STATE_KNOCKEDDOWN)
	end
end

function meta:Flinch()
	if not self:AllowHostileStateChanges() or self:GetState() == STATE_KNOCKEDDOWN then return end

	self:SetState(STATE_FLINCH, STATES[STATE_FLINCH].Time)
end

function meta:AllowHostileStateChanges()
	return not self:GetStateTable().NoHostileStateChanges
end

function meta:FakeJump()
	self:SetVelocity(Vector(0, 0, self:GetJumpPower()))
end

function meta:GetEnergy()
	return math.Clamp(self.Energy + self.EnergyRegeneration * (CurTime() - self.EnergyBase), 0, self:GetMaxEnergy())
end

function meta:SetEnergyRegeneration(regeneration, send)
	self:SetEnergy(self:GetEnergy(), regeneration, send)
end

function meta:GetMaxEnergy()
	return ENERGY_DEFAULT
end

function meta:GetNextRespawn()
	return self.m_RespawnTime or 0
end

function meta:NullKeys()
	return self:NullStrafeKeys() and self:NullMovementKeys()
end

function meta:NullStrafeKeys()
	return not self:KeyDown(IN_MOVELEFT) and not self:KeyDown(IN_MOVERIGHT)
end

function meta:NullMovementKeys()
	return not self:KeyDown(IN_FORWARD) and not self:KeyDown(IN_BACK)
end

function meta:NullKeyPressed(key)
	return self:KeyPressed(key) and self:NullKeys()
end

function meta:NullStrafeKeyPressed(key)
	return self:KeyPressed(key) and self:NullStrafeKeys()
end

function meta:NullMovementKeyPressed(key)
	return self:KeyPressed(key) and self:NullMovementKeys()
end

function meta:NullKeyDown(key)
	return self:KeyDown(key) and self:NullKeys()
end

function meta:NullStrafeKeyDown(key)
	return self:KeyDown(key) and self:NullStrafeKeys()
end

function meta:NullMovementKeyDown(key)
	return self:KeyDown(key) and self:NullMovementKeys()
end

function meta:GetCombo()
	if self.ComboEndTime and CurTime() >= self.ComboEndTime then return 0 end

	return self.Combo or 0
end

function meta:AddCombo(send)
	self:SetCombo(self:GetCombo() + 1, send)
end

function meta:ThinkShared()
	if self:GetState() == STATE_NONE then
		if self:KeyDown(IN_FORWARD) and self:KeyDown(IN_SPEED) and self:IsIdle() then
			if self:OnGround() then
				--[[if self:CanSprint() then
					self:SetState(STATE_SPRINT)
				end]]
			else
				local hitpos, hitnormal = self:GetWallRunSurface()
				if hitpos then
					self:SetState(STATE_WALLRUN)
				end
			end
		end
	elseif self:GetStateEnd() > 0 and CurTime() >= self:GetStateEnd() and not self:CallStateFunction("GoToNextState") then
		self:EndState()
	end

	local obs = self:GetObserverMode()
	if obs ~= OBS_MODE_CHASE and obs ~= OBS_MODE_IN_EYE then
		self:CallStateFunction("Think")
		self:CallSkillFunction("Think")
	end
end

--[[function meta:CanSprint()
	return not self:Crouching() and self:WaterLevel() < 2 and self:GetState() == STATE_NONE
end]]

function meta:CheckSlideCollide(nocheckother)
	local vel = self:GetVelocity()
	local speed = vel:Length()
	local start = self:GetPos()
	local maxs = self:OBBMaxs()
	maxs.z = 8
	local tr = util.TraceHull({start = start, endpos = start + vel * FrameTime(), mask = MASK_PLAYERSOLID, filter = self:GetAttackFilter(), mins = self:OBBMins(), maxs = maxs})
	local ent = tr.Entity
	if ent:IsValid() then
		if ent:IsPlayer() then
			ent:SetGroundEntity(NULL)
			local newvel = vel * 1.25
			newvel.z = newvel.z + speed / 2
			ent:SetLocalVelocity(newvel)
			ent:SetLastAttacker(self)

			ent:EmitSound("physics/body/body_medium_impact_hard"..math.random(1, 6)..".wav")
			self:EmitSound("npc/antlion_guard/shove1.wav")
			ent:ViewPunch(VectorRand():Angle() * (math.random(0, 1) == 0 and -1 or 1) * 0.15)

			if not nocheckother and ent:GetState() == STATE_SLIDE then
				ent:CheckSlideCollide(true)
			end
		elseif ent:GetMoveType() == MOVETYPE_VPHYSICS then
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() and phys:IsMoveable() and not ent.NoThrowFromPosition then
				ent:EmitSound("physics/body/body_medium_impact_hard"..math.random(1, 6)..".wav")
				self:EmitSound("npc/antlion_guard/shove1.wav")

				local newvel = vel * 1.25
				newvel.z = newvel.z + speed / 2
				phys:ApplyForceOffset(self:GetPhysicsObject():GetMass() * vel, (ent:NearestPoint(tr.HitPos) + ent:GetPos() * 2) / 3)
				ent:SetPhysicsAttacker(self)
			end
		elseif ent:GetClass() == "prop_door_rotating" and not ent:HasSpawnFlags(2048) then
			local physprop = ents.Create("prop_physics")
			if physprop:IsValid() then
				ent:Fire("open", "", 0)
				ent:Fire("break", "", 0.01)
				ent:SetSolid(SOLID_NONE)

				physprop:SetPos(ent:GetPos())
				physprop:SetAngles(ent:GetAngles())
				physprop:SetSkin(ent:GetSkin() or 0)
				physprop:SetMaterial(ent:GetMaterial())
				physprop:SetModel(ent:GetModel())
				physprop:Spawn()
				physprop:SetPhysicsAttacker(self)
				local phys = physprop:GetPhysicsObject()
				if phys:IsValid() then
					phys:SetVelocityInstantaneous((physprop:NearestPoint(self:EyePos()) - self:EyePos()):GetNormalized() * 500)
				end
				physprop._doorsmash = CurTime() + 3

				self:EmitSound("physics/body/body_medium_impact_hard"..math.random(1, 6)..".wav")
				ent:EmitSound("npc/zombie/zombie_pound_door.wav")
			end
		end
	end
end

local function nocollidetimer(self, timername)
	for _, e in pairs(ents.FindInBox(self:WorldSpaceAABB())) do
		if e:IsPlayer() and e ~= self and GAMEMODE:ShouldCollide(self, e) then
			return
		end
	end

	self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
	timer.Destroy(timername)
end
function meta:TemporaryNoCollide(force)
	if self:GetCollisionGroup() ~= COLLISION_GROUP_PLAYER and not force then return end

	for _, e in pairs(ents.FindInBox(self:WorldSpaceAABB())) do
		if e:IsPlayer() and e ~= self and GAMEMODE:ShouldCollide(self, e) then
			self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

			local timername = "TemporaryNoCollide"..self:UniqueID()
			timer.CreateEx(timername, 0, 0, nocollidetimer, self, timername)

			return
		end
	end
end

function meta:GetBlinkPos()
	local attachid = self:LookupAttachment("eyes")
	if attachid > 0 then
		local attach = self:GetAttachment(attachid)
		if attach then
			return attach.Pos + attach.Ang:Right() * 2
		end
	end

	return self:EyePos() + self:EyeAngles():Right() * 2
end

function meta:TraceLine(distance, mask, filter)
	local vStart = self:GetShootPos()
	return util.TraceLine({start = vStart, endpos = vStart + self:GetAimVector() * distance, filter = filter or self, mask = mask})
end

function meta:TraceHull(distance, mask, size, filter)
	local vStart = self:GetShootPos()
	return util.TraceHull({start = vStart, endpos = vStart + self:GetAimVector() * distance, filter = filter or self, mask = mask, mins = Vector(-size, -size, -size), maxs = Vector(size, size, size)})
end

function meta:PenetratingTraceLine(distance, mask, filter, maxpenetrate, noworldifhitent)
	local t = {}

	local vStart = self:GetShootPos()
	local trace = {start = vStart, endpos = vStart + self:GetAimVector() * distance, filter = filter or {self}, mask = mask}
	local worldtrace
	while not maxpenetrate or #t < maxpenetrate do
		local tr = util.TraceLine(trace)
		local ent = tr.Entity
		if ent and ent:IsValid() then
			table.insert(t, tr)
			table.insert(trace.filter, ent)
		else
			worldtrace = tr
			break
		end
	end

	if worldtrace and not (noworldifhitent and #t > 0) then
		table.insert(t, worldtrace)
	end

	return t
end

function meta:PenetratingTraceHull(distance, mask, size, filter, maxpenetrate, noworldifhitent)
	local t = {}

	local vStart = self:GetShootPos()
	local trace = {start = vStart, endpos = vStart + self:GetAimVector() * distance, filter = filter or {self}, mask = mask, mins = Vector(-size, -size, -size), maxs = Vector(size, size, size)}
	local worldtrace
	while not maxpenetrate or #t < maxpenetrate do
		local tr = util.TraceHull(trace)
		local ent = tr.Entity
		if ent and ent:IsValid() then
			table.insert(t, tr)
			table.insert(trace.filter, ent)
		else
			worldtrace = tr
			break
		end
	end

	if worldtrace and not (noworldifhitent and #t > 0) then
		table.insert(t, worldtrace)
	end

	return t
end

function meta:TraceHull(distance, mask, size, filter)
	local vStart = self:GetShootPos()
	return util.TraceHull({start = vStart, endpos = vStart + self:GetAimVector() * distance, filter = filter or self, mask = mask, mins = Vector(-size, -size, -size), maxs = Vector(size, size, size)})
end

function meta:SetDesiredSkill()
	local skill = tonumber(self:GetInfo("awesomestrike_skill")) or 0
	self:SetSkill(SKILLS[skill] ~= nil and skill or 0)
end

local STATES = STATES
function meta:CallStateFunction(name, ...)
	local statetab = STATES[self:GetState()]
	local func = statetab[name]
	if func then
		return func(statetab, self, ...)
	end
end

function meta:CallForcedStateFunction(state, name, ...)
	local statetab = STATES[state]
	local func = statetab[name]
	if func then
		return func(statetab, self, ...)
	end
end

local SKILLS = SKILLS
function meta:CallSkillFunction(name, ...)
	local skilltab = SKILLS[self:GetSkill()]
	local func = skilltab[name]
	if func then
		return func(skilltab, self, ...)
	end
end

function meta:CallForcedSkillFunction(skill, name, ...)
	local skilltab = SKILLS[skill]
	local func = skilltab[name]
	if func then
		return func(skilltab, self, ...)
	end
end

function meta:CallWeaponFunction(name, ...)
	local wep = self:GetActiveWeapon()
	if wep:IsValid() then
		local func = wep[name]
		if func then
			return func(wep, ...)
		end
	end
end

function meta:GetAttackFilter()
	local tab = team.GetPlayers(self:Team())
	table.Add(self.BulletFilter, ents.FindByClass("npc_hostage"))
	table.Add(self.BulletFilter, ents.FindByClass("prop_playertomb"))
	return tab
end

function meta:GetBulletAttackFilter(wep)
	local tab = self:GetAttackFilter()
	for _, ent in pairs(player.GetAll()) do
		if ent:CallStateFunction("ShouldDodgeBullet", self, wep) or ent:CallSkillFunction("ShouldDodgeBullet", self, wep) then
			table.insert(tab, ent)
		end
	end
	return tab
end

function meta:GetMeleeAttackFilter(wep)
	local tab = self:GetAttackFilter()
	for _, ent in pairs(player.GetAll()) do
		if ent:CallStateFunction("ShouldDodgeMelee", self, wep) or ent:CallSkillFunction("ShouldDodgeMelee", self, wep) then
			table.insert(tab, ent)
		end
	end

	return tab
end

function meta:ResetDodgeDelay(extratime)
	self.NextDodge = CurTime() + (extratime or 0)
end

function meta:ResetAirDodgeDelay(extratime)
	self.NextAirDodge = CurTime() + (extratime or 0)
end

function meta:SetNextMoveVelocity(vel)
	self.m_NextMoveVelocity = vel
end

function meta:GetNextMoveVelocity()
	return self.m_NextMoveVelocity
end

function meta:ProcessDamage(dmginfo)
	self:CallStateFunction("ProcessDamage", dmginfo)
	self:CallSkillFunction("ProcessDamage", dmginfo)
	self:CallWeaponFunction("ProcessDamage", dmginfo)

	local attacker = dmginfo:GetAttacker()
	if attacker:IsValid() and attacker:IsPlayer() then
		attacker:CallStateFunction("ProcessOtherDamage", self, dmginfo)
		attacker:CallSkillFunction("ProcessOtherDamage", self, dmginfo)
		attacker:CallWeaponFunction("ProcessOtherDamage", self, dmginfo)
	end

	local amount = dmginfo:GetDamage()
	if amount > 0 then
		if amount >= 40 or dmginfo:GetInflictor().IsMelee or dmginfo:IsExplosionDamage() then
			self:Flinch()
		end

		local bloodamount = math.min(100, amount)
		self:BloodSpray(self:NearestPoint(dmginfo:GetDamagePosition()), bloodamount * 0.25, (dmginfo:GetDamagePosition() - self:LocalToWorld(self:OBBCenter())):GetNormalized(), bloodamount * 2.5)
	end
end

function meta:OnHitWithBullet(bullet, tr, prehit)
	local ret = self:CallStateFunction("OnHitWithBullet", bullet, tr)
	if ret then
		return ret
	end

	if self:CallStateFunction("ShouldDodgeBullet", bullet, tr) or self:CallSkillFunction("ShouldDodgeBullet", bullet, tr) then return true end

	if self:CallStateFunction("ShouldBlockBullet", bullet, tr) or self:CallSkillFunction("ShouldBlockBullet", bullet, tr) then
		if bullet.BulletHitEffectBlocked then
			bullet.BulletHitEffect = bullet.BulletHitEffectBlocked
		end

		return true
	end
end

function meta:OnHitWithMelee(attacker, inflictor, trace, isstrong)
	local blocked
	if isstrong then
		if self:CallStateFunction("ShouldBlockStrongMelee", attacker, inflictor, trace) or self:CallSkillFunction("ShouldBlockStrongMelee", attacker, inflictor, trace) then
			blocked = true
		end
	elseif self:CallStateFunction("ShouldBlockMelee", attacker, inflictor, trace) or self:CallSkillFunction("ShouldBlockMelee", attacker, inflictor, trace) then
		blocked = true
	end

	if blocked then
		local effectdata = EffectData()
			effectdata:SetOrigin(trace and trace.HitPos or self:EyePos())
			effectdata:SetEntity(self)
		util.Effect("meleeguard", effectdata)

		self:SetLastAttacker(attacker)
	end

	return blocked
end

local ViewHullMins = Vector(-8, -8, -8)
local ViewHullMaxs = Vector(8, 8, 8)
function meta:GetThirdPersonCameraPos(origin, angles)
	local allplayers = player.GetAll()
	local tr = util.TraceHull({start = origin, endpos = origin + angles:Forward() * -92, mask = MASK_SHOT, filter = allplayers, mins = ViewHullMins, maxs = ViewHullMaxs})
	return tr.HitPos + tr.HitNormal * 3
end

function meta:GetWallRunSurface()
	local start = self:GetPos()
	local right = self:GetRight() * (self:OBBMaxs().y + 10)

	local tr = util.TraceLine({start = start, endpos = start + right, mask = MASK_SOLID_BRUSHONLY})
	if tr.Hit and not tr.HitSky and string.upper(tr.HitTexture) ~= "TOOLS/TOOLSNODRAW" then
		return tr.HitPos, tr.HitNormal
	end

	local tr2 = util.TraceLine({start = start, endpos = start - right, mask = MASK_SOLID_BRUSHONLY})
	if tr2.Hit and not tr2.HitSky and string.upper(tr2.HitTexture) ~= "TOOLS/TOOLSNODRAW" then
		return tr2.HitPos, tr2.HitNormal
	end
end

local walljumpmask = bit.bor(MASK_PLAYERSOLID, CONTENTS_PLAYERCLIP)
function meta:GetWallJumpSurface()
	local start = self:GetPos()
	local tr = util.TraceLine({start = start, endpos = start + self:GetForward() * (self:OBBMaxs().x + 16), mask = walljumpmask, filter = self})
	if tr.Hit and not tr.HitSky and (not tr.HitWorld or math.abs(tr.HitNormal.z) < 0.32) and string.upper(tr.HitTexture) ~= "TOOLS/TOOLSNODRAW" then
		return tr.HitPos, tr.HitNormal, tr.Entity
	end
end

function meta:ResetJumpPower(ignorestate)
	if not ignorestate and self:GetStateTable().NoJumping then
		self:SetJumpPower(0)
	elseif self:KeyDown(IN_FORWARD) or self:KeyDown(IN_BACK) or not (self:KeyDown(IN_MOVELEFT) or self:KeyDown(IN_MOVERIGHT)) then
		self:SetJumpPower(JUMPPOWER_DEFAULT)
	else
		self:SetJumpPower(0)
	end
end

local checktrace = {mask = MASK_SOLID_BRUSHONLY}
function meta:ForceUnDuck()
	if self:Crouching() and not self:OnGround() then
		checktrace.start = self:GetPos()
		checktrace.endpos = checktrace.start + self:SyncAngles():Forward() * 24
		if not util.TraceLine(checktrace).Hit then
			self:ConCommand("-duck")
		end
	end
end

function meta:ForceUnDuck2()
	if self:Crouching() then
		self:ConCommand("-duck")
	end
end

function meta:GetUseTarget()
	local teamplayers = team.GetPlayers(self:Team())
	local filter = table.Copy(teamplayers)
	table.Add(filter, ents.FindByClass("prop_playertomb"))
	local ent1 = self:TraceLine(64, nil, filter).Entity
	if ent1:IsValid() then
		return ent1
	end

	return self:TraceLine(64, nil, teamplayers).Entity
end

function meta:GetDefaultFOV()
	return math.Clamp(tonumber(self:GetInfo("fov_desired") or 0), 60, 200)
end

function meta:GetToGroundTrace(distance, pos)
	distance = distance or 16000
	pos = pos or self:GetPos()
	return util.TraceHull({start = pos, endpos = pos + Vector(0, 0, -distance), mins = self:OBBMins() * 0.75, maxs = self:OBBMaxs() * 0.75, mask = MASK_SOLID_BRUSHONLY})
end

function meta:StandingOnSomething()
	if self:OnGround() then return true end

	local pos = self:GetPos()
	return util.TraceHull({start = pos, endpos = pos + Vector(0, 0, -8), mins = self:OBBMins() * 0.75, maxs = self:OBBMaxs() * 0.75, mask = MASK_PLAYERSOLID, filter = team.GetPlayers(self:Team())}).Hit
end

function meta:InterruptSpecialMoves()
	--self:StopSprinting()
	self:StopDodging()
end

--[[function meta:IsSprinting()
	return self:GetState() == STATE_SPRINT
end]]

function meta:IsDodging()
	return self:GetState() == STATE_DODGE_LEFT or self:GetState() == STATE_DODGE_RIGHT or self:GetState() == STATE_AIRDODGE_LEFT or self:GetState() == STATE_AIRDODGE_RIGHT
end

--[[function meta:StopSprinting()
	if self:IsSprinting() then self:EndState() end
end]]

function meta:StopDodging()
	if self:IsDodging() then self:EndState() end
end

function meta:IsKnockedDown()
	return self:GetState() == STATE_KNOCKEDDOWN
end

function meta:GetBackUp()
	if self:IsKnockedDown() then self:SetStateEnd(CurTime() + 0.65) end
end

function meta:GetTeamName()
	return team.GetName(self:Team()) or "None"
end

function meta:ConvertNet()
	return ConvertNet(self:SteamID())
end

function meta:TraceLine(distance, _mask, filter)
	local vStart = self:GetShootPos()
	filter = filter or {}
	table.insert(filter, self)
	return util.TraceLine({start = vStart, endpos = vStart + self:GetAimVector() * distance, filter = filter or self, mask = _mask})
end

function meta:Stun(tim, noeffect)
	if noeffect then
		self:GiveStatus("stun_noeffect", tim):SetColor(Color(tim, 255, 255, 255))
	else
		self:GiveStatus("stun", tim):SetColor(Color(tim, 255, 255, 255))
	end
end

function meta:GetLastAttacker()
	local ent = self.LastAttacker
	if ent and ent:IsValid() then
		if ent:Team() ~= self:Team() and CurTime() <= self.LastAttacked + 10 then
			return ent
		end

		self:ClearLastAttacker()
	end

	return NULL
end

function meta:SetLastAttacker(ent)
	if ent then
		if ent ~= self then
			self.LastAttacker = ent
			self.LastAttacked = CurTime()
		end
	else
		self:ClearLastAttacker()
	end
end

function meta:ClearLastAttacker()
	self.LastAttacker = NULL
	self.LastAttacked = 0
end

function meta:IsIdle()
	local wep = self:GetActiveWeapon()
	if self:IsFrozen() or not self:Alive() or wep:IsValid() and wep.IsIdle and not wep:IsIdle() then return false end

	local ret = self:CallStateFunction("IsIdle")
	return ret or ret == nil
end

local oldalive = meta.Alive
function meta:Alive()
	if self:GetMoveType() == MOVETYPE_OBSERVER or self:Team() == TEAM_SPECTATOR then return false end

	return oldalive(self)
end

-- Override these because they're different in 1st person and on the server.
function meta:SyncAngles()
	local ang = self:EyeAngles()
	ang.pitch = 0
	ang.roll = 0
	return ang
end
meta.GetAngles = meta.SyncAngles

function meta:GetForward()
	return self:SyncAngles():Forward()
end

function meta:GetUp()
	return self:SyncAngles():Up()
end

function meta:GetRight()
	return self:SyncAngles():Right()
end
