STATE.NoDefusing = true
STATE.NoFootsteps = true
STATE.CantUseWeapons = true

STATE.GetUpTime = 0.45
--STATE.DizzyTime = 1

function STATE:IsIdle(pl)
	return false
end

function STATE:ProcessDamage(pl, dmginfo)
	local attacker = dmginfo:GetAttacker()
	if pl.KnockDownStartTime and CurTime() ~= pl.KnockDownStartTime and attacker:IsValid() and attacker:IsPlayer() and dmginfo:GetDamageType() ~= DMG_BLAST then
		if pl:StandingOnSomething() then
			dmginfo:SetDamage(dmginfo:GetDamage() * 0.6666)
		else
			pl:SetVelocity(Vector(math.Clamp(dmginfo:GetDamage() ^ 2, 0, 256)))
		end
	end
end

function STATE:Started(pl, oldstate)
	pl.KnockDownStartTime = CurTime()
	pl.HitGroundTime = nil

	pl:CallWeaponFunction("OnKnockedDown", oldstate)

	if SERVER then
		pl:Freeze(true)
	end
end

function STATE:Ended(pl, newstate)
	if SERVER then
		pl:Freeze(false)
	end

	pl.KnockDownImmunity = CurTime() + 0.5
end

function STATE:OnPlayerHitGround(pl, inwater, hitfloater, fallspeed)
	return true
end

function STATE:ShouldDrawLocalPlayer(pl)
	return true
end

if SERVER then

function STATE:Think(pl)
	local endtime = pl:GetStateEnd()
	if endtime == 0 and (pl:StandingOnSomething() or pl:WaterLevel() >= 2) then
		if not pl.HitGroundTime then
			pl.HitGroundTime = CurTime()
			pl:EmitSound("physics/body/body_medium_impact_hard"..math.random(6)..".wav")
		end

		if CurTime() >= pl.HitGroundTime + 0.25 and pl:GetVelocity():Length() < 128 then
			--pl:SetState(STATE_DIZZY, self.DizzyTime)
			pl:SetStateEnd(CurTime() + self.GetUpTime)
			pl:EmitSound("physics/nearmiss/whoosh_huge2.wav", 75, math.Rand(235, 255))
		end
	end
end

end

function STATE:Move(pl, move)
	move:SetMaxSpeed(0)
	move:SetMaxClientSpeed(0)

	if CurTime() % 1 < 0.75 then
		pl:SetGroundEntity(NULL)
	end

	return MOVE_STOP
end

if not CLIENT then return end

function STATE:Think(pl)
	if pl:GetStateEnd() ~= 0 then
		pl:SetLuaAnimation("gettingup")
		pl:StopLuaAnimation("onground", 0.1)
		pl:StopLuaAnimation("thrown", 0.1)
	elseif pl:OnGround() then
		pl:SetLuaAnimation("onground")
		pl:StopLuaAnimation("thrown", 0.1)
	else
		pl:SetLuaAnimation("thrown")
		pl:StopLuaAnimation("onground", 0.1)
	end
end
STATE.ThinkOther = STATE.Think

function STATE:DontDrawWeaponHUD(wep)
	return true
end

function STATE:PreDrawViewModel(pl, viewmodel)
	return true
end

local undo = false
function STATE:PrePlayerDraw(pl)
	if pl:GetStateEnd() ~= 0 then
		cam.Start3D(EyePos() + Vector(0, 0, CosineInterpolation(0, 1, math.Clamp((pl:GetStateEnd() - (CurTime() - 0.25)) / self.GetUpTime, 0, 1)) * 34), EyeAngles())
		undo = true
	elseif pl:OnGround() then
		cam.Start3D(EyePos() + Vector(0, 0, 34), EyeAngles())
		undo = true
	end
end

function STATE:PostPlayerDraw(pl)
	if undo then
		undo = false
		cam.End3D()
	end
end

RegisterLuaAnimation('onground', {
	FrameData = {
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Forearm'] = {
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RR = 88,
					RF = 73
				},
				['ValveBiped.Bip01_Pelvis'] = {
					RF = -90
				},
				['ValveBiped.Bip01_L_Thigh'] = {
					RU = -43,
					RR = -27
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RR = -41,
					RF = -90
				},
				['ValveBiped.Bip01_R_Calf'] = {
					RU = 40
				},
				['ValveBiped.Bip01_Head1'] = {
					RU = -14,
					RF = 12
				},
				['ValveBiped.Bip01_Spine4'] = {
					RU = 11
				},
				['ValveBiped.Bip01_R_Forearm'] = {
				},
				['ValveBiped.Bip01_L_Calf'] = {
				},
				['ValveBiped.Bip01_R_Foot'] = {
					RU = 53,
					RR = 3
				},
				['ValveBiped.Bip01_Spine1'] = {
					RU = 17
				},
				['ValveBiped.Bip01_Spine2'] = {
					RU = 16
				},
				['ValveBiped.Bip01_Spine'] = {
				},
				['ValveBiped.Bip01_R_Thigh'] = {
					RU = -37,
					RR = 31,
					RF = 14
				}
			},
			FrameRate = 8
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Forearm'] = {
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RR = 88,
					RF = 73
				},
				['ValveBiped.Bip01_Pelvis'] = {
					RF = -90
				},
				['ValveBiped.Bip01_L_Thigh'] = {
					RR = -27
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RR = -41,
					RF = -90
				},
				['ValveBiped.Bip01_R_Calf'] = {
					RU = 40
				},
				['ValveBiped.Bip01_Head1'] = {
					RU = 13,
					RR = 28,
					RF = 70
				},
				['ValveBiped.Bip01_Spine4'] = {
				},
				['ValveBiped.Bip01_Spine1'] = {
				},
				['ValveBiped.Bip01_L_Calf'] = {
				},
				['ValveBiped.Bip01_R_Foot'] = {
					RU = 53,
					RR = 3
				},
				['ValveBiped.Bip01_Spine'] = {
				},
				['ValveBiped.Bip01_Spine2'] = {
				},
				['ValveBiped.Bip01_R_Forearm'] = {
				},
				['ValveBiped.Bip01_R_Thigh'] = {
					RU = -24,
					RR = 31,
					RF = 14
				}
			},
			FrameRate = 8
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Forearm'] = {
					RR = 33
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RR = 79,
					RF = 73
				},
				['ValveBiped.Bip01_Pelvis'] = {
					RF = -90
				},
				['ValveBiped.Bip01_L_Thigh'] = {
					RU = -9,
					RR = -27
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RR = -41,
					RF = -90
				},
				['ValveBiped.Bip01_R_Calf'] = {
					RU = 13
				},
				['ValveBiped.Bip01_Head1'] = {
					RU = -7,
					RR = -2,
					RF = 40
				},
				['ValveBiped.Bip01_Spine4'] = {
				},
				['ValveBiped.Bip01_Spine1'] = {
				},
				['ValveBiped.Bip01_L_Calf'] = {
					RU = 13
				},
				['ValveBiped.Bip01_R_Foot'] = {
					RU = 53,
					RR = 3
				},
				['ValveBiped.Bip01_Spine'] = {
				},
				['ValveBiped.Bip01_Spine2'] = {
				},
				['ValveBiped.Bip01_R_Forearm'] = {
				},
				['ValveBiped.Bip01_R_Thigh'] = {
					RU = -8,
					RR = 31,
					RF = 14
				}
			},
			FrameRate = 0.5
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Forearm'] = {
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RR = 88,
					RF = 73
				},
				['ValveBiped.Bip01_Pelvis'] = {
					RF = -90
				},
				['ValveBiped.Bip01_L_Thigh'] = {
					RR = -27
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RR = -41,
					RF = -90
				},
				['ValveBiped.Bip01_R_Calf'] = {
					RU = 40
				},
				['ValveBiped.Bip01_Spine'] = {
				},
				['ValveBiped.Bip01_Spine4'] = {
				},
				['ValveBiped.Bip01_R_Forearm'] = {
				},
				['ValveBiped.Bip01_L_Calf'] = {
				},
				['ValveBiped.Bip01_R_Foot'] = {
					RU = 53,
					RR = 3
				},
				['ValveBiped.Bip01_Head1'] = {
					RU = 13,
					RR = 28,
					RF = 70
				},
				['ValveBiped.Bip01_Spine2'] = {
				},
				['ValveBiped.Bip01_Spine1'] = {
				},
				['ValveBiped.Bip01_R_Thigh'] = {
					RU = -23,
					RR = 31,
					RF = 14
				}
			},
			FrameRate = 0.5
		}
	},
	RestartFrame = 3,
	Type = TYPE_SEQUENCE,
	ShouldPlay = function(pl, sGestureName, tGestureTable, iCurFrame, tFrameData)
		return pl:GetState() == STATE_KNOCKEDDOWN
	end
})

RegisterLuaAnimation('thrown', {
	FrameData = {
		{
			BoneInfo = {
				['ValveBiped.Bip01_R_Calf'] = {
					RU = 16
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = -106,
					RR = 31
				},
				['ValveBiped.Bip01_Head1'] = {
				},
				['ValveBiped.Bip01_L_Foot'] = {
					RU = 58,
					RR = 15
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = -63,
					RR = -20
				},
				['ValveBiped.Bip01_L_Hand'] = {
					RF = -5
				},
				['ValveBiped.Bip01_L_Thigh'] = {
					RU = -77,
					RR = -15
				},
				['ValveBiped.Bip01_Spine1'] = {
					RU = 17
				},
				['ValveBiped.Bip01_R_Forearm'] = {
				},
				['ValveBiped.Bip01_L_Calf'] = {
					RU = 19
				},
				['ValveBiped.Bip01_R_Foot'] = {
					RU = 42
				},
				['ValveBiped.Bip01_Spine4'] = {
					RU = 16
				},
				['ValveBiped.Bip01_Spine2'] = {
					RU = 7
				},
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = -39
				},
				['ValveBiped.Bip01_R_Thigh'] = {
					RU = -90,
					RR = 21
				}
			},
			FrameRate = 10
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_R_Calf'] = {
					RU = -2
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = -88,
					RR = 44
				},
				['ValveBiped.Bip01_Head1'] = {
					RU = 11,
					RF = -9
				},
				['ValveBiped.Bip01_L_Thigh'] = {
					RU = -89,
					RR = -15
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = -104,
					RR = -16
				},
				['ValveBiped.Bip01_L_Hand'] = {
					RF = -5
				},
				['ValveBiped.Bip01_L_Foot'] = {
					RU = 36,
					RR = 15
				},
				['ValveBiped.Bip01_Spine1'] = {
					RU = 17
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RR = -31
				},
				['ValveBiped.Bip01_Spine4'] = {
					RU = 16
				},
				['ValveBiped.Bip01_R_Foot'] = {
					RU = 6,
					RR = -22
				},
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = -22
				},
				['ValveBiped.Bip01_Spine2'] = {
					RU = 7
				},
				['ValveBiped.Bip01_L_Calf'] = {
					RU = -3
				},
				['ValveBiped.Bip01_R_Thigh'] = {
					RU = -74,
					RR = 21
				}
			},
			FrameRate = 1
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_R_Calf'] = {
					RU = 16
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = -106,
					RR = 31
				},
				['ValveBiped.Bip01_Head1'] = {
				},
				['ValveBiped.Bip01_L_Thigh'] = {
					RU = -77,
					RR = -15
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = -63,
					RR = -20
				},
				['ValveBiped.Bip01_L_Hand'] = {
					RF = -5
				},
				['ValveBiped.Bip01_L_Foot'] = {
					RU = 58,
					RR = 15
				},
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = -39
				},
				['ValveBiped.Bip01_Spine1'] = {
					RU = 17
				},
				['ValveBiped.Bip01_L_Calf'] = {
					RU = 19
				},
				['ValveBiped.Bip01_R_Foot'] = {
					RU = 42
				},
				['ValveBiped.Bip01_Spine4'] = {
					RU = 16
				},
				['ValveBiped.Bip01_Spine2'] = {
					RU = 7
				},
				['ValveBiped.Bip01_R_Forearm'] = {
				},
				['ValveBiped.Bip01_R_Thigh'] = {
					RU = -90,
					RR = 21
				}
			},
			FrameRate = 1
		}
	},
	RestartFrame = 2,
	Type = TYPE_SEQUENCE,
	ShouldPlay = function(pl, sGestureName, tGestureTable, iCurFrame, tFrameData)
		return pl:GetState() == STATE_KNOCKEDDOWN
	end
})

RegisterLuaAnimation('gettingup', {
	FrameData = {
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Forearm'] = {
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RR = 88,
					RF = 73
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RR = -41,
					RF = -90
				},
				['ValveBiped.Bip01_Neck1'] = {
				},
				['ValveBiped.Bip01_L_Clavicle'] = {
				},
				['ValveBiped.Bip01_R_Forearm'] = {
				},
				['ValveBiped.Bip01_Spine4'] = {
				},
				['ValveBiped.Bip01_R_Foot'] = {
					RU = 53,
					RR = 3
				},
				['ValveBiped.Bip01_Spine2'] = {
				},
				['ValveBiped.Bip01_Spine'] = {
				},
				['ValveBiped.Bip01_Head1'] = {
					RU = 15,
					RR = 15,
					RF = 70
				},
				['ValveBiped.Bip01_L_Thigh'] = {
					RR = -27
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
				},
				['ValveBiped.Bip01_L_Hand'] = {
				},
				['ValveBiped.Bip01_Pelvis'] = {
					RF = -90
				},
				['ValveBiped.Bip01_Spine1'] = {
				},
				['ValveBiped.Bip01_R_Calf'] = {
					RU = 40
				},
				['ValveBiped.Bip01_L_Calf'] = {
				},
				['ValveBiped.Bip01_R_Toe0'] = {
				},
				['ValveBiped.Bip01_R_Hand'] = {
				},
				['ValveBiped.Bip01_L_Foot'] = {
				},
				['ValveBiped.Bip01_R_Thigh'] = {
					RU = -23,
					RR = 31,
					RF = 14
				}
			},
			FrameRate = 17
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Forearm'] = {
					RR = -110
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RR = 70
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RR = -70
				},
				['ValveBiped.Bip01_Neck1'] = {
				},
				['ValveBiped.Bip01_L_Clavicle'] = {
					RR = -60
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RR = 110
				},
				['ValveBiped.Bip01_L_Calf'] = {
				},
				['ValveBiped.Bip01_R_Foot'] = {
				},
				['ValveBiped.Bip01_Spine2'] = {
					RU = 12
				},
				['ValveBiped.Bip01_Spine'] = {
					RU = 10
				},
				['ValveBiped.Bip01_Head1'] = {
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RU = 70
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
					RR = 60
				},
				['ValveBiped.Bip01_L_Hand'] = {
					RU = 70
				},
				['ValveBiped.Bip01_Spine4'] = {
					RU = -11
				},
				['ValveBiped.Bip01_L_Thigh'] = {
					RU = -40
				},
				['ValveBiped.Bip01_Pelvis'] = {
					RF = -119
				},
				['ValveBiped.Bip01_Spine1'] = {
					RU = 6
				},
				['ValveBiped.Bip01_R_Toe0'] = {
				},
				['ValveBiped.Bip01_R_Calf'] = {
				},
				['ValveBiped.Bip01_L_Foot'] = {
				},
				['ValveBiped.Bip01_R_Thigh'] = {
					RU = -40
				}
			},
			FrameRate = 5
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Forearm'] = {
					RR = -110
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RR = 70
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RR = -70
				},
				['ValveBiped.Bip01_Neck1'] = {
				},
				['ValveBiped.Bip01_L_Clavicle'] = {
					RR = -60
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RR = 110
				},
				['ValveBiped.Bip01_L_Calf'] = {
					RU = 26
				},
				['ValveBiped.Bip01_R_Foot'] = {
					RU = -25
				},
				['ValveBiped.Bip01_Spine2'] = {
					RU = -6
				},
				['ValveBiped.Bip01_Spine'] = {
					RU = -17
				},
				['ValveBiped.Bip01_Head1'] = {
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RU = 70
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
					RR = 60
				},
				['ValveBiped.Bip01_L_Hand'] = {
					RU = 70
				},
				['ValveBiped.Bip01_Pelvis'] = {
					RF = -29
				},
				['ValveBiped.Bip01_Spine1'] = {
					RU = -20
				},
				['ValveBiped.Bip01_Spine4'] = {
					RU = -24
				},
				['ValveBiped.Bip01_L_Thigh'] = {
					RU = 12
				},
				['ValveBiped.Bip01_R_Toe0'] = {
				},
				['ValveBiped.Bip01_R_Calf'] = {
					RU = 26
				},
				['ValveBiped.Bip01_L_Foot'] = {
					RU = -25
				},
				['ValveBiped.Bip01_R_Thigh'] = {
					RU = 9
				}
			},
			FrameRate = 12
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = -35
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = -27
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = 15
				},
				['ValveBiped.Bip01_Neck1'] = {
				},
				['ValveBiped.Bip01_L_Clavicle'] = {
					RF = 46
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = -32
				},
				['ValveBiped.Bip01_L_Calf'] = {
				},
				['ValveBiped.Bip01_R_Foot'] = {
					RU = 25
				},
				['ValveBiped.Bip01_Spine2'] = {
					RU = 17
				},
				['ValveBiped.Bip01_Spine'] = {
				},
				['ValveBiped.Bip01_Head1'] = {
					RU = 36
				},
				['ValveBiped.Bip01_L_Foot'] = {
					RU = 13
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
					RU = 3
				},
				['ValveBiped.Bip01_L_Hand'] = {
					RU = 53
				},
				['ValveBiped.Bip01_Pelvis'] = {
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RU = 19,
					RR = 24
				},
				['ValveBiped.Bip01_L_Thigh'] = {
					RU = -12,
					RR = -2,
					RF = -9
				},
				['ValveBiped.Bip01_Spine4'] = {
					RU = 9
				},
				['ValveBiped.Bip01_R_Toe0'] = {
					RU = -34
				},
				['ValveBiped.Bip01_Spine1'] = {
					RU = 7,
					RR = 1
				},
				['ValveBiped.Bip01_R_Calf'] = {
				},
				['ValveBiped.Bip01_R_Thigh'] = {
					RU = 19,
					RF = 23
				}
			},
			FrameRate = 12
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = -35
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = -27
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = 15
				},
				['ValveBiped.Bip01_Neck1'] = {
				},
				['ValveBiped.Bip01_L_Clavicle'] = {
					RF = 46
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = -32
				},
				['ValveBiped.Bip01_L_Calf'] = {
				},
				['ValveBiped.Bip01_R_Foot'] = {
					RU = 25
				},
				['ValveBiped.Bip01_Spine2'] = {
					RU = 17
				},
				['ValveBiped.Bip01_Spine'] = {
				},
				['ValveBiped.Bip01_Head1'] = {
					RU = 36
				},
				['ValveBiped.Bip01_L_Foot'] = {
					RU = 13
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
					RU = 3
				},
				['ValveBiped.Bip01_L_Hand'] = {
					RU = 53
				},
				['ValveBiped.Bip01_Pelvis'] = {
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RU = 19,
					RR = 24
				},
				['ValveBiped.Bip01_L_Thigh'] = {
					RU = -12,
					RR = -2,
					RF = -9
				},
				['ValveBiped.Bip01_Spine4'] = {
					RU = 9
				},
				['ValveBiped.Bip01_R_Toe0'] = {
					RU = -34
				},
				['ValveBiped.Bip01_Spine1'] = {
					RU = 7,
					RR = 1
				},
				['ValveBiped.Bip01_R_Calf'] = {
				},
				['ValveBiped.Bip01_R_Thigh'] = {
					RU = 19,
					RF = 23
				}
			},
			FrameRate = 2
		}
	},
	RestartFrame = 5,
	Type = TYPE_SEQUENCE,
	ShouldPlay = function(pl, sGestureName, tGestureTable, iCurFrame, tFrameData)
		return pl:GetState() == STATE_KNOCKEDDOWN
	end
})
