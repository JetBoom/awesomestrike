STATE.CantUseWeapons = true

STATE.Time = 0.5

function STATE:Started(pl, oldstate)
	math.randomseed(pl:EntIndex() + CurTime())
	pl:SetStateNumber(math.random(1, 4))

	pl:ViewPunch(Angle(math.Rand(-15, 15), math.Rand(-15, 15), math.Rand(-20, 20)))

	pl:CallWeaponFunction("OnFlinched", oldstate)
end

function STATE:IsIdle(pl)
	return false
end

if not CLIENT then return end

function STATE:Think(pl)
	pl:SetLuaAnimation("flinch"..pl:GetStateNumber())
end
STATE.ThinkOther = STATE.Think

local function ShouldPlay(pl, sGestureName, tGestureTable, iCurFrame, tFrameData)
	return pl:GetState() == STATE_FLINCH
end

RegisterLuaAnimation('flinch1', {
	FrameData = {
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Clavicle'] = {
					RR = 16
				},
				['ValveBiped.Bip01_Spine1'] = {
					RU = -17,
					RR = -7
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = 36
				},
				['ValveBiped.Bip01_Head1'] = {
					RR = -9,
					RF = 7
				},
				['ValveBiped.Bip01_Spine4'] = {
					RF = 16
				},
				['ValveBiped.Bip01_Spine2'] = {
					RU = -15,
					RR = 10,
					RF = -28
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = 54,
					RF = -27
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = 30,
					RR = 23
				}
			},
			FrameRate = 10
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Clavicle'] = {
					RR = 16
				},
				['ValveBiped.Bip01_Spine1'] = {
					RU = -17,
					RR = -7
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = 36
				},
				['ValveBiped.Bip01_Head1'] = {
					RR = -9,
					RF = 7
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = 30,
					RR = 23
				},
				['ValveBiped.Bip01_Spine2'] = {
					RU = -15,
					RR = 10,
					RF = -28
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = 54,
					RF = -27
				},
				['ValveBiped.Bip01_Spine4'] = {
					RF = 16
				}
			},
			FrameRate = 10
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Clavicle'] = {
				},
				['ValveBiped.Bip01_Spine1'] = {
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
				},
				['ValveBiped.Bip01_Head1'] = {
				},
				['ValveBiped.Bip01_Spine4'] = {
				},
				['ValveBiped.Bip01_Spine2'] = {
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
				},
				['ValveBiped.Bip01_R_Forearm'] = {
				}
			},
			FrameRate = 3
		}
	},
	Type = TYPE_GESTURE,
	ShouldPlay = ShouldPlay,
	Group = "flinch"
})

RegisterLuaAnimation('flinch2', {
	FrameData = {
		{
			BoneInfo = {
				['ValveBiped.Bip01_Spine'] = {
					RU = 16
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = 27,
					RR = 10
				},
				['ValveBiped.Bip01_Head1'] = {
					RU = -36,
					RR = 18
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RF = 72
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = 30,
					RR = -3,
					RF = -19
				},
				['ValveBiped.Bip01_L_Clavicle'] = {
					RR = 32
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = 41
				},
				['ValveBiped.Bip01_Spine4'] = {
					RU = 18,
					RR = -9,
					RF = -5
				},
				['ValveBiped.Bip01_Spine2'] = {
					RU = -13,
					RR = 17
				},
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = 47
				}
			},
			FrameRate = 10
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_Spine'] = {
					RU = 16
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = 27,
					RR = 10
				},
				['ValveBiped.Bip01_Head1'] = {
					RU = -36,
					RR = 18
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RF = 72
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = 30,
					RR = -3,
					RF = -19
				},
				['ValveBiped.Bip01_L_Clavicle'] = {
					RR = 32
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = 41
				},
				['ValveBiped.Bip01_Spine4'] = {
					RU = 18,
					RR = -9,
					RF = -5
				},
				['ValveBiped.Bip01_Spine2'] = {
					RU = -13,
					RR = 17
				},
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = 47
				}
			},
			FrameRate = 10
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_Spine'] = {
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
				},
				['ValveBiped.Bip01_Head1'] = {
				},
				['ValveBiped.Bip01_R_Hand'] = {
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
				},
				['ValveBiped.Bip01_L_Clavicle'] = {
				},
				['ValveBiped.Bip01_R_Forearm'] = {
				},
				['ValveBiped.Bip01_Spine4'] = {
				},
				['ValveBiped.Bip01_Spine2'] = {
				},
				['ValveBiped.Bip01_L_Forearm'] = {
				}
			},
			FrameRate = 3
		}
	},
	Type = TYPE_GESTURE,
	ShouldPlay = ShouldPlay,
	Group = "flinch"
})

RegisterLuaAnimation('flinch3', {
	FrameData = {
		{
			BoneInfo = {
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = 23
				},
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = 40
				},
				['ValveBiped.Bip01_Spine4'] = {
					RU = -12
				},
				['ValveBiped.Bip01_Head1'] = {
					RU = 25,
					RR = 19
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = 19
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = 41
				},
				['ValveBiped.Bip01_Spine2'] = {
					RU = -7
				},
				['ValveBiped.Bip01_Spine1'] = {
					RU = -10
				}
			},
			FrameRate = 10
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_Spine1'] = {
					RU = -10
				},
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = 40
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = 23
				},
				['ValveBiped.Bip01_Head1'] = {
					RU = 25,
					RR = 19
				},
				['ValveBiped.Bip01_Spine2'] = {
					RU = -7
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = 41
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = 19
				},
				['ValveBiped.Bip01_Spine4'] = {
					RU = -12
				}
			},
			FrameRate = 10
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_Spine4'] = {
				},
				['ValveBiped.Bip01_Spine1'] = {
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
				},
				['ValveBiped.Bip01_Head1'] = {
				},
				['ValveBiped.Bip01_R_Forearm'] = {
				},
				['ValveBiped.Bip01_Spine2'] = {
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
				},
				['ValveBiped.Bip01_L_Forearm'] = {
				}
			},
			FrameRate = 5
		}
	},
	Type = TYPE_GESTURE,
	ShouldPlay = ShouldPlay,
	Group = "flunch"
})

RegisterLuaAnimation('flinch4', {
	FrameData = {
		{
			BoneInfo = {
				['ValveBiped.Bip01_Spine'] = {
					RU = -23
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RR = 25
				},
				['ValveBiped.Bip01_Head1'] = {
					RU = -35,
					RF = 14
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
					RU = 12
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = 35,
					RR = 7
				},
				['ValveBiped.Bip01_Spine4'] = {
					RR = 8,
					RF = -8
				},
				['ValveBiped.Bip01_Spine2'] = {
					RU = -7,
					RR = 9,
					RF = -16
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = 56
				},
				['ValveBiped.Bip01_Spine1'] = {
					RU = -10,
					RF = -9
				}
			},
			FrameRate = 10
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_Spine'] = {
					RU = -23
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RR = 25
				},
				['ValveBiped.Bip01_Head1'] = {
					RU = -35,
					RF = 14
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
					RU = 12
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = 35,
					RR = 7
				},
				['ValveBiped.Bip01_Spine4'] = {
					RR = 8,
					RF = -8
				},
				['ValveBiped.Bip01_Spine2'] = {
					RU = -7,
					RR = 9,
					RF = -16
				},
				['ValveBiped.Bip01_Spine1'] = {
					RU = -10,
					RF = -9
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = 56
				}
			},
			FrameRate = 10
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_Spine'] = {
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
				},
				['ValveBiped.Bip01_Head1'] = {
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
				},
				['ValveBiped.Bip01_R_Forearm'] = {
				},
				['ValveBiped.Bip01_Spine4'] = {
				},
				['ValveBiped.Bip01_Spine2'] = {
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
				},
				['ValveBiped.Bip01_Spine1'] = {
				}
			},
			FrameRate = 5
		}
	},
	Type = TYPE_GESTURE,
	ShouldPlay = ShouldPlay,
	Group = "flinch"
})
