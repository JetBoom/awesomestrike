STATE.CantUseWeapons = true
STATE.NoDefusing = true
STATE.NoJumping = true

function STATE:IsIdle(pl)
	return false
end

function STATE:Started(pl, oldstate)
	if SERVER then
		pl:CreateRagdoll()
	end

	pl:SetDSP(24)
	pl:ResetJumpPower()
end

function STATE:Ended(pl, newstate)
	if 0 < pl:Health() then
		local rag = pl:GetRagdollEntity()
		if rag and rag:IsValid() then
			rag:Remove()
		end
	end

	pl:SetDSP(0)
	pl:ResetJumpPower(true)
end

function STATE:GoToNextState(pl)
	pl:SetState(STATE_THIRDPERSON, 0.5)

	return true
end

function STATE:ShouldDrawLocalPlayer(pl)
	return true
end

function STATE:DontCreateRagdoll(pl, dmginfo)
	return true
end

function STATE:Move(pl, move)
	move:SetMaxSpeed(move:GetMaxSpeed() * 0.7)
	move:SetMaxClientSpeed(move:GetMaxClientSpeed() * 0.7)
end

if not CLIENT then return end

function STATE:GetFadeIn(pl)
	local ct = CurTime()
	return math.Clamp(math.min(pl:GetStateEnd() - ct, ct - pl:GetStateStart()) ^ 0.5, 0, 1)
end

function STATE:GetRGB()
	local time = CurTime() * 510
	return time % 255, (time + 64) % 255, (time + 128) % 255
end

function STATE:RenderScreenspaceEffects(pl)
	local r, g, b = self:GetRGB()
	DrawBloom(1 - self:GetFadeIn(pl) * 0.9, 0.5, 3, 3, 2, 3, r / 255, g / 255, b / 255)
end

function STATE:HUDPaint(pl)
	local r, g, b = self:GetRGB()
	surface.SetDrawColor(r, g, b, self:GetFadeIn(pl) * 60)
	surface.DrawRect(0, 0, ScrW(), ScrH())
end

function STATE:PrePlayerDraw(pl)
	return true
end

local Bones = {
	["ValveBiped.Bip01_Spine4"] = true,
	["ValveBiped.Bip01_Spine3"] = true,
	["ValveBiped.Bip01_Spine1"] = true,
	["ValveBiped.Bip01_Spine"] = true,
	["ValveBiped.Bip01_R_Thigh"] = true,
	["ValveBiped.Bip01_R_Calf"] = true,
	["ValveBiped.Bip01_R_Foot"] = true,
	["ValveBiped.Bip01_R_Toe0"] = true,
	["ValveBiped.Bip01_L_Thigh"] = true,
	["ValveBiped.Bip01_L_Calf"] = true,
	["ValveBiped.Bip01_L_Foot"] = true,
	["ValveBiped.Bip01_L_Toe0"] = true
}

local ShadowParams = {secondstoarrive = 0.0001, maxangular = 1000, maxangulardamp = 10000, maxspeed = 32000, maxspeeddamp = 1024, dampfactor = 0.5, teleportdistance = 32}
function STATE:Think(pl)
	local rag = pl:GetRagdollEntity()
	if not IsValid(rag) then return end

	local p = rag:GetPhysicsObject()
	if p:IsValid() then p:Wake() end

	ShadowParams.deltatime = FrameTime()

	for i = 0, rag:GetPhysicsObjectCount() do
		local translate = pl:TranslatePhysBoneToBone(i)
		if translate and 0 < translate and Bones[pl:GetBoneName(translate)] then
			local pos, ang = pl:GetBonePositionMatrixed(translate)
			if pos and ang then
				local phys = rag:GetPhysicsObjectNum(i)
				if phys and phys:IsValid() then
					ShadowParams.pos = pos
					ShadowParams.angle = ang

					phys:Wake()
					phys:ComputeShadowControl(ShadowParams)
				end
			end
		end
	end
end
STATE.ThinkOther = STATE.Think

function STATE:DontDrawWeaponHUD(wep)
	return true
end

function STATE:PreDrawViewModel(pl, viewmodel)
	return true
end
