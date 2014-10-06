STATE.NoJumping = true

function STATE:IsIdle(pl)
	return false
end

function STATE:Move(pl, mv)
	mv:SetMaxSpeed(0)
	mv:SetMaxClientSpeed(0)
end

function STATE:Started(pl)
	pl:ResetLuaAnimation("kick1")

	pl:ResetJumpPower()
end

function STATE:Ended(pl)
	pl:ResetJumpPower(true)
end

RegisterLuaAnimation('kick1', {
	FrameData = {
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = -90
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = 50
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = -45
				},
				['ValveBiped.Bip01_L_Clavicle'] = {
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = -130
				},
				['ValveBiped.Bip01_Spine4'] = {
					RF = -11
				},
				['ValveBiped.Bip01_R_Foot'] = {
				},
				['ValveBiped.Bip01_Spine2'] = {
					RF = -10
				},
				['ValveBiped.Bip01_R_Calf'] = {
					RU = 33
				},
				['ValveBiped.Bip01_Head1'] = {
					RF = 27
				},
				['ValveBiped.Bip01_L_Thigh'] = {
					RR = -8,
					RF = -30
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
					RU = -18
				},
				['ValveBiped.Bip01_Spine1'] = {
					RF = -12
				},
				['ValveBiped.Bip01_Spine'] = {
				},
				['ValveBiped.Bip01_L_Foot'] = {
					RU = 7,
					RR = 17,
					RF = 11
				},
				['ValveBiped.Bip01_Pelvis'] = {
				},
				['ValveBiped.Bip01_R_Toe0'] = {
				},
				['ValveBiped.Bip01_R_Hand'] = {
				},
				['ValveBiped.Bip01_L_Calf'] = {
				},
				['ValveBiped.Bip01_R_Thigh'] = {
					RU = 19,
					RF = 31
				}
			},
			FrameRate = 7.5
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = -42
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = 50
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = 17
				},
				['ValveBiped.Bip01_L_Clavicle'] = {
					RU = 5
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = -142
				},
				['ValveBiped.Bip01_Spine4'] = {
					RF = 2
				},
				['ValveBiped.Bip01_R_Foot'] = {
				},
				['ValveBiped.Bip01_Spine2'] = {
					RF = 13
				},
				['ValveBiped.Bip01_Spine'] = {
					RU = -16,
					RF = 26
				},
				['ValveBiped.Bip01_Pelvis'] = {
				},
				['ValveBiped.Bip01_L_Thigh'] = {
					RR = -1,
					RF = -30
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
					RU = -18
				},
				['ValveBiped.Bip01_L_Calf'] = {
				},
				['ValveBiped.Bip01_L_Foot'] = {
					RU = 7,
					RR = 17,
					RF = 11
				},
				['ValveBiped.Bip01_Head1'] = {
					RU = -17,
					RR = -20,
					RF = -43
				},
				['ValveBiped.Bip01_R_Calf'] = {
					RU = -1
				},
				['ValveBiped.Bip01_R_Toe0'] = {
				},
				['ValveBiped.Bip01_R_Hand'] = {
				},
				['ValveBiped.Bip01_Spine1'] = {
					RF = 7
				},
				['ValveBiped.Bip01_R_Thigh'] = {
					RU = -90,
					RR = 13,
					RF = -13
				}
			},
			FrameRate = 7.5
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = -42
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = 50
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = 17
				},
				['ValveBiped.Bip01_L_Clavicle'] = {
					RU = 5
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = -77
				},
				['ValveBiped.Bip01_Spine4'] = {
					RF = 2
				},
				['ValveBiped.Bip01_R_Foot'] = {
					RR = 22
				},
				['ValveBiped.Bip01_Spine2'] = {
					RF = 13
				},
				['ValveBiped.Bip01_R_Calf'] = {
					RU = -2
				},
				['ValveBiped.Bip01_Head1'] = {
					RU = -17,
					RR = -20,
					RF = -43
				},
				['ValveBiped.Bip01_L_Foot'] = {
					RU = 7,
					RR = 17,
					RF = 11
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
					RU = -18
				},
				['ValveBiped.Bip01_Spine'] = {
					RU = -16,
					RF = 26
				},
				['ValveBiped.Bip01_Spine1'] = {
					RF = 7
				},
				['ValveBiped.Bip01_L_Thigh'] = {
					RF = -30
				},
				['ValveBiped.Bip01_L_Calf'] = {
				},
				['ValveBiped.Bip01_R_Toe0'] = {
					RU = -28
				},
				['ValveBiped.Bip01_Pelvis'] = {
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RU = 24
				},
				['ValveBiped.Bip01_R_Thigh'] = {
					RU = -78,
					RR = 13,
					RF = -13
				}
			},
			FrameRate = 6
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = -42
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = -4
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = 17,
					RR = 26
				},
				['ValveBiped.Bip01_L_Clavicle'] = {
					RU = 5
				},
				['ValveBiped.Bip01_Spine1'] = {
				},
				['ValveBiped.Bip01_Spine4'] = {
				},
				['ValveBiped.Bip01_R_Foot'] = {
				},
				['ValveBiped.Bip01_Spine2'] = {
				},
				['ValveBiped.Bip01_R_Calf'] = {
				},
				['ValveBiped.Bip01_Pelvis'] = {
				},
				['ValveBiped.Bip01_R_Hand'] = {
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
					RU = -18
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = -123
				},
				['ValveBiped.Bip01_L_Foot'] = {
					RU = 7,
					RR = 17,
					RF = 11
				},
				['ValveBiped.Bip01_L_Thigh'] = {
					RR = -12
				},
				['ValveBiped.Bip01_Head1'] = {
				},
				['ValveBiped.Bip01_R_Toe0'] = {
				},
				['ValveBiped.Bip01_Spine'] = {
				},
				['ValveBiped.Bip01_L_Calf'] = {
				},
				['ValveBiped.Bip01_R_Thigh'] = {
				}
			},
			FrameRate = 9
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = -42
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = -4
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = 17,
					RR = 26
				},
				['ValveBiped.Bip01_L_Clavicle'] = {
					RU = 5
				},
				['ValveBiped.Bip01_Spine1'] = {
				},
				['ValveBiped.Bip01_Spine4'] = {
				},
				['ValveBiped.Bip01_R_Foot'] = {
				},
				['ValveBiped.Bip01_Spine2'] = {
				},
				['ValveBiped.Bip01_R_Calf'] = {
				},
				['ValveBiped.Bip01_Pelvis'] = {
				},
				['ValveBiped.Bip01_R_Hand'] = {
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
					RU = -18
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = -123
				},
				['ValveBiped.Bip01_L_Foot'] = {
					RU = 7,
					RR = 17,
					RF = 11
				},
				['ValveBiped.Bip01_L_Thigh'] = {
					RR = -12
				},
				['ValveBiped.Bip01_Head1'] = {
				},
				['ValveBiped.Bip01_R_Toe0'] = {
				},
				['ValveBiped.Bip01_Spine'] = {
				},
				['ValveBiped.Bip01_L_Calf'] = {
				},
				['ValveBiped.Bip01_R_Thigh'] = {
				}
			},
			FrameRate = 1
		}
	},
	RestartFrame = 5,
	Type = TYPE_SEQUENCE,
	ShouldPlay = function(pl, sGestureName, tGestureTable, iCurFrame, tFrameData, fFrameDelta, fPower) -- This just automatically stops the sequence when it's done.
		return iCurFrame < #tGestureTable.FrameData
	end
})
