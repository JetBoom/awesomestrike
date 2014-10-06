GM.Name = "Awesome Strike: Source"
GM.Author = "JetBoom"
GM.Email = "williammoodhe@gmail.com"
GM.Website = "http://www.noxiousnet.com"

include("buffthefps.lua")
include("nixthelag.lua")

include("sh_teams.lua")

include("sh_globals.lua")
include("sh_states.lua")
include("sh_skills.lua")
include("sh_voicesets.lua")
include("sh_bullets.lua")
include("sh_statushook.lua")

include("obj_entity_extend.lua")
include("obj_player_extend.lua")
include("obj_weapon_extend.lua")

include("workshopfix.lua")

local validmodels = player_manager.AllValidModels()
validmodels["tf01"] = nil
validmodels["tf02"] = nil

function GM:GetRoundTime()
	if self:GetIsCTF() then
		return GetConVarNumber("as_roundtime_ctf")
	end

	return GetConVarNumber("as_roundtime")
end

function GM:GetNumRounds()
	if self:GetIsCTF() then
		return GetConVarNumber("as_numrounds_ctf")
	end

	return GetConVarNumber("as_numrounds")
end

function GM:SetRoundEnded(roundend)
	SetGlobalBool("roundend", roundend)
end

function GM:IsRoundEnded()
	return GetGlobalBool("roundend", true)
end
GM.GetRoundEnded = GM.IsRoundEnded

GM.IsCTF = false
function GM:GetIsCTF()
	return self.IsCTF
end

function GM:SetNumBombTargets(targets)
	SetGlobalInt("NumBombTargets", targets)
end

function GM:GetNumBombTargets()
	return GetGlobalInt("NumBombTargets", 0)
end

function GM:GetCaptureHolders()
	local tzones = 0
	local ctzones = 0
	local numzones = 0
	for _, ent in pairs(ents.FindByClass("point_capturezone")) do
		numzones = numzones + 1
		if ent:GetTeam() == TEAM_T then
			tzones = tzones + 1
		elseif ent:GetTeam() == TEAM_CT then
			ctzones = ctzones + 1
		end
	end

	if numzones > 0 then
		if tzones == numzones then
			return TEAM_T
		elseif ctzones == numzones then
			return TEAM_CT
		end
	end

	return 0
end

function GM:GetCaptureEndTime()
	local maxcapturetime = 0
	for _, ent in pairs(ents.FindByClass("point_capturezone")) do
		if ent:GetTeam() > 0 then
			maxcapturetime = math.max(maxcapturetime, ent:GetCapturedTime())
		end
	end

	if maxcapturetime > 0 then
		return maxcapturetime + self.CaptureWinTime
	end

	return 0
end

function GM:SetNumHostages(hostages)
	SetGlobalInt("NumHostages", hostages)
end

function GM:GetNumHostages()
	return GetGlobalInt("NumHostages", 0)
end

function GM:MapHasObjective()
	return self:GetNumBombTargets() > 0 or self:GetNumHostages() > 0 or self:GetIsCTF()
end

function GM:GetRound()
	return GetGlobalInt("round", 1)
end

function GM:SetRound(round)
	SetGlobalInt("round", round)
end

function GM:GetBuyable(pl, id)
	local buyable = self.Buyables[id]
	if buyable and not buyable.Disabled then
		if buyable.Type then
			return buyable
		end

		local subtype = buyable[pl:Team()]
		if subtype and not subtype.Disabled then return subtype end
	end
end

function GM:KillMessageMainTypeToString(id)
	return self.KillMessageMainTypeStrings[id] or self.KillMessageMainTypeStrings[KILLACTION_GENERIC]
end

function GM:GetKillAction2Points(bits)
	local points = 0

	for action, extrapoints in pairs(self.KillAction2ExtraPoints) do
		if bit.band(bits, action) ~= 0 then
			points = points + extrapoints
		end
	end

	return points
end

function GM:KillAction2ToBits(actions)
	local bits = 0

	for _, action in pairs(actions) do
		bits = bit.bor(bits, action)
	end

	return bits
end

function GM:BitsToKillAction2(bits)
	local actions = {}

	for action in pairs(self.KillMessageSubTypeStrings) do
		if bit.band(bits, action) ~= 0 then
			table.insert(actions, action)
		end
	end

	return actions
end

function GM:PlayerCanHearPlayersVoice(listen, talk)
	return listen:Team() == talk:Team() or listen:Team() == TEAM_SPECTATOR or self:GetRoundEnded(), false
end

function GM:KeyPress(pl, key)
	pl.KeyPressedThisRound = true

	if pl:GetObserverMode() ~= OBS_MODE_NONE then
		return self:SpectatorKeyPress(pl, key)
	end

	if not pl:Alive() then return end

	if key == IN_FORWARD or key == IN_BACK or key == IN_MOVELEFT or key == IN_MOVERIGHT then
		pl:ResetJumpPower()
	end

	if key == IN_USE then
		local ent = pl:GetUseTarget()
		if ent and ent:IsValid() and ent.UseTarget then
			ent:UseTarget(pl)
		end
	end

	if pl:CallStateFunction("KeyPress", key) or pl:CallSkillFunction("KeyPress", key) then return end

	if key == IN_JUMP then
		if pl:IsIdle() and not pl:IsDodging() and not pl:KeyDown(IN_FORWARD) and not pl:KeyDown(IN_BACK) then
			if pl:OnGround() then
				if CurTime() >= pl.NextDodge then
					if pl:KeyDown(IN_MOVELEFT) then
						pl:SetState(STATE_DODGE_LEFT, STATES[STATE_DODGE_LEFT].Duration)
						return
					elseif pl:KeyDown(IN_MOVERIGHT) then
						pl:SetState(STATE_DODGE_RIGHT, STATES[STATE_DODGE_RIGHT].Duration)
						return
					end
				end
			elseif CurTime() >= pl.NextAirDodge then
				if pl:KeyDown(IN_MOVELEFT) then
					pl:SetState(STATE_AIRDODGE_LEFT, STATES[STATE_AIRDODGE_LEFT].Duration)
					return
				elseif pl:KeyDown(IN_MOVERIGHT) then
					pl:SetState(STATE_AIRDODGE_RIGHT, STATES[STATE_AIRDODGE_RIGHT].Duration)
					return
				end
			end
		end

		if not pl:OnGround() and pl.NextWallJump <= CurTime() then
			local hitpos, hitnormal, hitentity = pl:GetWallJumpSurface()
			if hitpos then
				local speedmastery = pl:GetSkill() == SKILL_SPEEDMASTERY

				pl.NextWallJump = CurTime() + (speedmastery and 0.15 or 0.2)

				pl:InterruptSpecialMoves()

				pl:SetStateVector(hitpos)
				local forward = pl:GetForward()
				pl:SetStateAngles((2 * hitnormal * hitnormal:Dot(forward * -1) + forward):Angle())
				pl:SetState(STATE_WALLJUMP, speedmastery and 0.1 or 0.15, hitentity)

				pl.WallJumpHitPos = hitpos
				pl.WallJumpHitNormal = hitnormal
			end
		end
	end
end

function CosineInterpolation(y1, y2, mu)
	local mu2 = (1 - math.cos(mu * math.pi)) / 2
	return y1 * (1 - mu2) + y2 * mu2
end

function GM:KeyRelease(pl, key)
	if key == IN_FORWARD or key == IN_MOVEBACK or key == IN_MOVERIGHT or key == IN_MOVELEFT then
		pl:ResetJumpPower()
	end

	pl:CallStateFunction("KeyRelease", key)
end

function GM:PlayerShouldTakeDamage(pl, attacker)
	local owner = attacker:GetOwner()
	if owner:IsValid() then attacker = owner end

	return pl:GetMoveType() ~= MOVETYPE_OBSERVER and (pl == attacker or not attacker:IsPlayer() or attacker:Team() ~= pl:Team())
end

function GM:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	if pl:CallStateFunction("UpdateAnimation", velocity, maxseqgroundspeed) then return end

	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.UpdateAnimation and wep:UpdateAnimation(pl, velocity, maxseqgroundspeed) then return end

	return self.BaseClass.UpdateAnimation(self, pl, velocity, maxseqgroundspeed)
end

function GM:CalcMainActivity(pl, velocity)
	local a, b = pl:CallStateFunction("CalcMainActivity", velocity)
	if a then return a, b end

	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.CalcMainActivity then
		local a, b = wep:CalcMainActivity(pl, velocity)
		if a then return a, b end
	end

	return self.BaseClass.CalcMainActivity(self, pl, velocity)
end

function GM:PlayerShouldTaunt(pl, actid)
	return pl:IsIdle()
end

function GM:Move(pl, move)
	if not pl:Alive() then return end

	local nextvel = pl:GetNextMoveVelocity()
	if nextvel then
		pl:SetGroundEntity(NULL)
		move:SetVelocity(nextvel)
		pl:SetNextMoveVelocity(nil)
		return
	end

	local ret = pl:CallStateFunction("Move", move)
	if ret then
		if ret == MOVE_STOP then return end
		if ret == MOVE_OVERRIDE then return true end
	end

	local ret2 = pl:CallSkillFunction("Move", move)
	if ret2 then
		if ret2 == MOVE_STOP then return end
		if ret2 == MOVE_OVERRIDE then return true end
	end

	-- Less air control
	if not pl:OnGround() and pl:WaterLevel() < 2 then
		move:SetMaxSpeed(move:GetMaxSpeed() * 0.5)
		move:SetMaxClientSpeed(move:GetMaxClientSpeed() * 0.5)
	end

	-- Less speed going backwards.
	if move:GetForwardSpeed() < 0 then
		move:SetMaxSpeed(move:GetMaxSpeed() * 0.6)
		move:SetMaxClientSpeed(move:GetMaxClientSpeed() * 0.6)
	-- Less speed strafing but not going forward.
	elseif move:GetForwardSpeed() == 0 then
		move:SetMaxSpeed(move:GetMaxSpeed() * 0.8)
		move:SetMaxClientSpeed(move:GetMaxClientSpeed() * 0.8)
	end

	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.Move then return wep:Move(move) end
end

function GM:AddParticles()
	game.AddParticles("particles/vman_explosion.pcf")

	PrecacheParticleSystem("dusty_explosion_rockets")
end

function GM:OnPlayerHitGround(pl, inwater, hitfloater, fallspeed)
	pl:SetGravity(GRAVITY_DEFAULT)
	pl:ResetAirDodgeDelay()

	if CurTime() ~= pl.LastHitGround then
		pl.LastHitGround = CurTime()
		pl.WallJumpInAir = nil

		if not pl:CallStateFunction("OnPlayerHitGround", inwater, hitfloater, fallspeed) then
			if CurTime() >= (pl.NextJumpLandEffect or 0) then
				pl.NextJumpLandEffect = CurTime() + 0.2

				local effectdata = EffectData()
					effectdata:SetEntity(pl)
					effectdata:SetOrigin(pl:EyePos())
				util.Effect("jumpland", effectdata)
			end

			pl:CallWeaponFunction("OnPlayerHitGround", inwater, hitfloater, fallspeed)
		end
	end

	return true
end

function GM:SetPlayerSpeed(pl, walk)
	pl:SetWalkSpeed(walk)
	pl:SetRunSpeed(walk)
	pl:SetMaxSpeed(walk)
end

function GM:GetRagdollEyes(pl)
	local Ragdoll = pl:GetRagdollEntity()
	if not Ragdoll then return end

	local att = Ragdoll:GetAttachment(Ragdoll:LookupAttachment("eyes"))
	if att then
		att.Pos = att.Pos + att.Ang:Forward() * -1
		att.Ang = att.Ang

		return att.Pos, att.Ang
	end
end

function GM:ScalePlayerDamage(pl, hitgroup, dmginfo, virtual, noreduce)
	if hitgroup == HITGROUP_HEAD then
		dmginfo:SetDamage(dmginfo:GetDamage() * 1.5)
	end
end

function TrueVisible(posa, posb, mask)
	local filt = ents.FindByClass("projectile_*")
	filt = table.Add(filt, ents.FindByClass("item_*"))
	filt = table.Add(filt, ents.FindByClass("status_*"))
	filt = table.Add(filt, ents.FindByClass("prop_physics*"))
	filt = table.Add(filt, player.GetAll())

	return not util.TraceLine({start = posa, endpos = posb, filter = filt, mask = mask}).Hit
end

function MaskVisible(posa, posb, mask, filter)
	return not util.TraceLine({start = posa, endpos = posb, mask = mask, filter = filter}).Hit
end

function util.ToMinutesSeconds(seconds)
	local minutes = math.floor(seconds / 60)
	seconds = seconds - minutes * 60

    return string.format("%02d:%02d", minutes, math.floor(seconds))
end

function util.ToMinutesSecondsMilliseconds(seconds)
	local minutes = math.floor(seconds / 60)
	seconds = seconds - minutes * 60

	local milliseconds = math.floor(seconds % 1 * 100)

    return string.format("%02d:%02d.%02d", minutes, math.floor(seconds), milliseconds)
end

function timer.SimpleEx(delay, action, ...)
	if ... == nil then
		timer.Simple(delay, action)
	else
		local a, b, c, d, e, f, g, h, i, j, k = ...
		timer.Simple(delay, function() action(a, b, c, d, e, f, g, h, i, j, k) end)
	end
end

function timer.CreateEx(timername, delay, repeats, action, ...)
	if ... == nil then
		timer.Create(timername, delay, repeats, action)
	else
		local a, b, c, d, e, f, g, h, i, j, k = ...
		timer.Create(timername, delay, repeats, function() action(a, b, c, d, e, f, g, h, i, j, k) end)
	end
end

function RegisterWeaponStatus(name, move, rotate, attachmentname, modelscale, model, extras)
	model = model or SWEP.WorldModel

	local classname = "status_"..name
	local tab = {Type = "anim", Base = "status__base_weapon", Model = model, Move = move, Rotate = rotate, AnimAttachment = attachmentname, ModelScale = modelscale, WeaponClass = name}
	if extras then
		for k, v in pairs(extras) do
			tab[k] = v
		end
	end
	scripted_ents.Register(tab, classname)
	return scripted_ents.GetStored(classname)
end
