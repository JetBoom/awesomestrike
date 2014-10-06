SET_MALE = 1
SET_FEMALE = 2
SET_MONK = 3
SET_BARNEY = 4
SET_COMBINE = 5
SET_ALYX = 6

VOICEGROUP_PAIN_LIGHT = 1
VOICEGROUP_PAIN_MED = 2
VOICEGROUP_PAIN_HEAVY = 3
VOICEGROUP_DEATH = 4
VOICEGROUP_IDLE = 5
VOICEGROUP_TALK = 6
VOICEGROUP_ATTACK = 7

local VoiceSets = {}

VoiceSets[SET_MALE] = {
	[VOICEGROUP_PAIN_LIGHT] = {
		Sound("vo/npc/male01/ow01.wav"),
		Sound("vo/npc/male01/ow02.wav"),
		Sound("vo/npc/male01/pain01.wav"),
		Sound("vo/npc/male01/pain02.wav"),
		Sound("vo/npc/male01/pain03.wav")
	},
	[VOICEGROUP_PAIN_MED] = {
		Sound("vo/npc/male01/pain04.wav"),
		Sound("vo/npc/male01/pain05.wav"),
		Sound("vo/npc/male01/pain06.wav")
	},
	[VOICEGROUP_PAIN_HEAVY] = {
		Sound("vo/npc/male01/pain07.wav"),
		Sound("vo/npc/male01/pain08.wav"),
		Sound("vo/npc/male01/pain09.wav")
	},
	[VOICEGROUP_DEATH] = {
		Sound("vo/npc/male01/no02.wav"),
		Sound("ambient/voices/citizen_beaten1.wav"),
		Sound("ambient/voices/citizen_beaten3.wav"),
		Sound("ambient/voices/citizen_beaten4.wav"),
		Sound("ambient/voices/citizen_beaten5.wav"),
		Sound("vo/npc/male01/pain07.wav"),
		Sound("ambient/voices/m_scream1.wav"),
		Sound("vo/npc/male01/pain08.wav")
	}
}

VoiceSets[SET_BARNEY] = {
	[VOICEGROUP_PAIN_LIGHT] = {
		Sound("vo/npc/Barney/ba_pain02.wav"),
		Sound("vo/npc/Barney/ba_pain07.wav"),
		Sound("vo/npc/Barney/ba_pain04.wav")
	},
	[VOICEGROUP_PAIN_MED] = {
		Sound("vo/npc/Barney/ba_pain01.wav"),
		Sound("vo/npc/Barney/ba_pain08.wav"),
		Sound("vo/npc/Barney/ba_pain10.wav")
	},
	[VOICEGROUP_PAIN_HEAVY] = {
		Sound("vo/npc/Barney/ba_pain05.wav"),
		Sound("vo/npc/Barney/ba_pain06.wav"),
		Sound("vo/npc/Barney/ba_pain09.wav")
	},
	[VOICEGROUP_DEATH] = {
		Sound("vo/npc/Barney/ba_ohshit03.wav"),
		Sound("vo/npc/Barney/ba_no01.wav"),
		Sound("vo/npc/Barney/ba_no02.wav"),
		Sound("vo/npc/Barney/ba_pain03.wav")
	}
}

VoiceSets[SET_FEMALE] = {
	[VOICEGROUP_PAIN_LIGHT] = {
		Sound("vo/npc/female01/pain01.wav"),
		Sound("vo/npc/female01/pain02.wav"),
		Sound("vo/npc/female01/pain03.wav")
	},
	[VOICEGROUP_PAIN_MED] = {
		Sound("vo/npc/female01/pain04.wav"),
		Sound("vo/npc/female01/pain05.wav"),
		Sound("vo/npc/female01/pain06.wav")
	},
	[VOICEGROUP_PAIN_HEAVY] = {
		Sound("vo/npc/female01/pain07.wav"),
		Sound("vo/npc/female01/pain08.wav"),
		Sound("vo/npc/female01/pain09.wav")
	},
	[VOICEGROUP_DEATH] = {
		Sound("vo/npc/female01/no01.wav"),
		Sound("vo/npc/female01/ow01.wav"),
		Sound("vo/npc/female01/ow02.wav"),
		Sound("vo/npc/female01/mygut02.wav"),
		Sound("vo/npc/female01/goodgod.wav"),
		Sound("ambient/voices/citizen_beaten2.wav")
	}
}

VoiceSets[SET_ALYX] = {
	[VOICEGROUP_PAIN_LIGHT] = {
		Sound("vo/npc/Alyx/gasp03.wav"),
		Sound("vo/npc/Alyx/hurt08.wav"),
		Sound("vo/npc/Alyx/uggh01.wav")
	},
	[VOICEGROUP_PAIN_MED] = {
		Sound("vo/npc/Alyx/hurt04.wav"),
		Sound("vo/npc/Alyx/hurt06.wav"),
		Sound("vo/Citadel/al_struggle07.wav"),
		Sound("vo/Citadel/al_struggle08.wav"),
		Sound("vo/npc/Alyx/uggh02.wav")
	},
	[VOICEGROUP_PAIN_HEAVY] = {
		Sound("vo/npc/Alyx/hurt05.wav"),
		Sound("vo/npc/Alyx/hurt06.wav")
	},
	[VOICEGROUP_DEATH] = {
		Sound("vo/npc/Alyx/no01.wav"),
		Sound("vo/npc/Alyx/no02.wav"),
		Sound("vo/npc/Alyx/no03.wav"),
		Sound("vo/Citadel/al_dadgordonno_c.wav"),
		Sound("vo/Streetwar/Alyx_gate/al_no.wav")
	}
}

VoiceSets[SET_COMBINE] = {
	[VOICEGROUP_PAIN_LIGHT] = {
		Sound("npc/combine_soldier/pain1.wav"),
		Sound("npc/combine_soldier/pain2.wav"),
		Sound("npc/combine_soldier/pain3.wav")
	},
	[VOICEGROUP_PAIN_MED] = {
		Sound("npc/metropolice/pain1.wav"),
		Sound("npc/metropolice/pain2.wav")
	},
	[VOICEGROUP_PAIN_HEAVY] = {
		Sound("npc/metropolice/pain3.wav"),
		Sound("npc/metropolice/pain4.wav")
	},
	[VOICEGROUP_DEATH] = {
		Sound("npc/combine_soldier/die1.wav"),
		Sound("npc/combine_soldier/die2.wav"),
		Sound("npc/combine_soldier/die3.wav")
	}
}

VoiceSets[SET_MONK] = {
	[VOICEGROUP_PAIN_LIGHT] = {
		Sound("vo/ravenholm/monk_pain01.wav"),
		Sound("vo/ravenholm/monk_pain02.wav"),
		Sound("vo/ravenholm/monk_pain03.wav"),
		Sound("vo/ravenholm/monk_pain05.wav")
	},
	[VOICEGROUP_PAIN_MED] = {
		Sound("vo/ravenholm/monk_pain04.wav"),
		Sound("vo/ravenholm/monk_pain06.wav"),
		Sound("vo/ravenholm/monk_pain07.wav"),
		Sound("vo/ravenholm/monk_pain08.wav")
	},
	[VOICEGROUP_PAIN_HEAVY] = {
		Sound("vo/ravenholm/monk_pain09.wav"),
		Sound("vo/ravenholm/monk_pain10.wav"),
		Sound("vo/ravenholm/monk_pain12.wav")
	},
	[VOICEGROUP_DEATH] = {
		Sound("vo/ravenholm/monk_death07.wav")
	}
}

local meta = FindMetaTable("Player")
if not meta then return end

function meta:PlayVoiceGroup(group)
	local voiceset = self.VoiceSet
	if voiceset and VoiceSets[voiceset] then
		local tab = VoiceSets[voiceset][group]
		if tab then
			local snd = tab[math.random(1, #tab)]
			self:EmitSound(snd)
			return snd
		end
	end
end

function meta:PlayDeathSound()
	self:PlayVoiceGroup(VOICEGROUP_DEATH)
end

function meta:PlayPainSound()
	if CurTime() < self.NextPainSound then return end
	local frac = self:Health() / self:GetMaxHealthEx()

	local snd
	if frac <= 0.33 then
		snd = self:PlayVoiceGroup(VOICEGROUP_PAIN_HEAVY)
	elseif frac <= 0.66 then
		snd = self:PlayVoiceGroup(VOICEGROUP_PAIN_MED)
	else
		snd = self:PlayVoiceGroup(VOICEGROUP_PAIN_LIGHT)
	end

	self.NextPainSound = CurTime() + SoundDuration(snd) - 0.1
end

local VoiceSetTranslate = {}
VoiceSetTranslate["models/player/alyx.mdl"] = SET_ALYX
VoiceSetTranslate["models/player/barney.mdl"] = SET_BARNEY
VoiceSetTranslate["models/player/monk.mdl"] = SET_MONK
VoiceSetTranslate["models/player/mossman.mdl"] = SET_FEMALE
VoiceSetTranslate["models/player/police.mdl"] = SET_COMBINE
VoiceSetTranslate["models/police.mdl"] = VoiceSetTranslate["models/player/police.mdl"]
VoiceSetTranslate["models/player/brsp.mdl"] = SET_FEMALE
VoiceSetTranslate["models/player/moe_glados_p.mdl"] = SET_FEMALE
VoiceSetTranslate["models/grim.mdl"] = SET_COMBINE
VoiceSetTranslate["models/jason278-players/gabe_3.mdl"] = SET_MONK

function meta:RefreshVoiceSet(mdl)
	if not mdl then mdl = string.lower(self:GetModel()) end

	if VoiceSetTranslate[mdl] then
		self.VoiceSet = VoiceSetTranslate[mdl]
	elseif string.find(mdl, "female", 1, true) then
		self.VoiceSet = SET_FEMALE
	elseif string.find(mdl, "combine", 1, true) then
		self.VoiceSet = SET_COMBINE
	else
		self.VoiceSet = SET_MALE
	end
end
