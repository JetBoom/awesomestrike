CreateConVar("as_roundtime", "240", FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY)
CreateConVar("as_roundtime_ctf", "600", FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY)
CreateConVar("as_intermissiontime", "7", FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY)
CreateConVar("as_votetime", "30", FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY)
CreateConVar("as_freezetime", "6", FCVAR_ARCHIVE + FCVAR_NOTIFY)
CreateConVar("as_numrounds", "15", FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY)
CreateConVar("as_numrounds_ctf", "6", FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY)
CreateConVar("as_autobalancethresh", "2", FCVAR_ARCHIVE + FCVAR_NOTIFY)
CreateConVar("as_scrambleteams", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY)
CreateConVar("as_balanceteams", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY)
CreateConVar("as_eventeams", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY)

GM.RespawnTime = CreateConVar("as_respawntime", "10", FCVAR_ARCHIVE + FCVAR_NOTIFY + FCVAR_REPLICATED, "Respawn time."):GetInt()
cvars.AddChangeCallback("as_respawntime", function(cvar, oldvalue, newvalue)
	GAMEMODE.RespawnTime = tonumber(newvalue) or 10
end)

--SPEED_BONUS_SPRINT = 175
SPEED_SLOW = 380
SPEED_NORMAL = 390
SPEED_FAST = 400
SPEED_VERYFAST = 410

GRAVITY_DEFAULT = 4 / 3
ENERGY_DEFAULT = 100
ENERGY_DEFAULT_REGENERATION = 10

MOVE_NONE = 0
MOVE_STOP = 1
MOVE_OVERRIDE = 2

JUMPPOWER_DEFAULT = 340

KILLACTION_GENERIC = 0
KILLACTION_BULLET = 1
KILLACTION_BULLETHEADSHOT = 2
KILLACTION_STAB = 3
KILLACTION_SLASH = 4
KILLACTION_BASH = 5
KILLACTION_EXPLOSION = 6
KILLACTION_BURN = 7
KILLACTION_SHOCK = 8
KILLACTION_FREEZE = 9
KILLACTION_DISSOLVE = 10
KILLACTION_ENVIRONMENT = 11
KILLACTION_PHYSICS = 12
KILLACTION_AWESOMERIFLE = 13
KILLACTION_AWESOMERIFLEGUIDED = 14
KILLACTION_PLANTEDBOMB = 15
KILLACTION_AWESOMELAUNCHERGUIDED = 16
KILLACTION_AWESOMELAUNCHER = 17
KILLACTION_DETONATED = 18
KILLACTION_DINKIED = 19
KILLACTION_SMARTRIFLED = 20
KILLACTION_SPRAYED = 21
KILLACTION_MINIGUNNED = 22
KILLACTION_QUICKSILVERED = 23
KILLACTION_CROSSFIRED = 24
KILLACTION_BEATUP = 25
KILLACTION_DOORSMASH = 26
KILLACTION_DESERTEAGLE = 27
KILLACTION_RAILGUN = 28
KILLACTION_THROWNKNIFE = 29
KILLACTION_HOOKED = 30
KILLACTION_TAGGED = 31
KILLACTION_HOSTAGE = 32
KILLACTION_SHOCKWAVEBAT = 33
KILLACTION_SAWARANG = 34
KILLACTION_FLAG = 35
KILLACTION_SIXSHOOTER = 36
KILLACTION_BEEHIVE = 37
KILLACTION_REDBARRELONASTICK = 38
KILLACTION_DODGEBALL = 39

KILLACTION2_SLIDE = 2^0
KILLACTION2_WALLRUN = 2^1
KILLACTION2_WALLJUMP = 2^2
KILLACTION2_MIDAIR = 2^3
KILLACTION2_ANTIAIR = 2^4
KILLACTION2_BULLETBOUNCE = 2^5
KILLACTION2_DEFLECTED = 2^6
KILLACTION2_DISTANT = 2^7
KILLACTION2_FROMTHEGRAVE = 2^8
KILLACTION2_EFFICIENT = 2^9
KILLACTION2_BLINK = 2^10
KILLACTION2_GHOST = 2^11
KILLACTION2_FLYBY = 2^12
KILLACTION2_2XKILL = 2^13
KILLACTION2_3XKILL = 2^14
KILLACTION2_4XKILL = 2^15
KILLACTION2_5XKILL = 2^16
KILLACTION2_JUGGLE = 2^17
KILLACTION2_SEIZURESLAYER = 2^18

COLID_DEFAULT = 0
COLID_RED = 1
COLID_GREEN = 2
COLID_BLUE = 3
COLID_YELLOW = 4
COLID_WHITE = 5

GM.roundstart = GetConVarNumber("as_intermissiontime")
GM.endroundtime = 60 + GetConVarNumber("as_freezetime")
SetGlobalFloat("endroundtime", GM.endroundtime)

GM.CaptureTime = 20
GM.CaptureWinTime = 10

GM.ComboTime = 10
GM.ComboLevels = {
	"GOOD!",
	"GREAT!",
	"AMAZING!",
	"FANTASTIC!",
	"SPECTACULAR!",
	"UNBELIEVABLE!"
}

WEAPONTYPE_ASSAULT = 1
WEAPONTYPE_LIGHT = 2
WEAPONTYPE_DEFENSE = 3
WEAPONTYPE_MELEE = 4
WEAPONTYPE_SPECIAL = 5

GM.WeaponTypes = {
	[WEAPONTYPE_ASSAULT] = "Assault",
	[WEAPONTYPE_LIGHT] = "Light",
	[WEAPONTYPE_DEFENSE] = "Defense",
	[WEAPONTYPE_MELEE] = "Melee",
	[WEAPONTYPE_SPECIAL] = "Special"
}

-- Just a warning that this structure must be maintaned! If adding any new weapons, add it to the END of the table. If removing, add Disabled = true to its table.
GM.Buyables = {
{
	[TEAM_CT] = {Name = "M4 Carbine", Type = WEAPONTYPE_ASSAULT, SWEP = "weapon_as_m4", Description = "Preferred weapon of special operations agents. Has good stopping power and accuracy."},
	[TEAM_T] = {Name = "AK-47", Type = WEAPONTYPE_ASSAULT, SWEP = "weapon_as_ak47", Description = "Preferred weapon of terrorist agents. Has good stopping power and speed."},
},
{Name = "Smart Rifle", Type = WEAPONTYPE_ASSAULT, SWEP = "weapon_as_smartrifle", Description = "The latest in computer-assisted weaponry. Aim directly at an enemy and this gun will compensate for thier velocity, reducing the need to lead shots."},
{Name = "Submachine Gun", ShortName = "SMG", Type = WEAPONTYPE_ASSAULT, SWEP = "weapon_as_smg", Description = "An all around average weapon with nothing special about it. Has no weaknesses but no notable strengths either."},
{Name = "Uzi", Type = WEAPONTYPE_ASSAULT, SWEP = "weapon_as_uzi", Description = "The very high rate of fire makes the gun harder to control. Perfect for short to medium range and suppression fire."},
{Name = "Crossfire", Type = WEAPONTYPE_ASSAULT, SWEP = "weapon_as_crossfire", Description = "Fires lines of bullets in an alternating pattern. Ideal for short range but loses effectiveness at long range as bullet trajectory is easily predicted."},
{Name = "Minigun", Type = WEAPONTYPE_ASSAULT, SWEP = "weapon_as_minigun", Description = "Very innacurate but spews bullets fast enough to propel the user backwards, potentially making them float in the air. Stay stationary to greatly reduce spread."},
{Name = "Awesome Rifle", Type = WEAPONTYPE_SPECIAL, SWEP = "weapon_as_awesomerifle", Description = "Extremely powerful rifle with guided shots.\n\nMove your mouse after firing to guide the bullet.\n\nPress ALT FIRE to shoot without guiding or to stop guiding."},
{Name = "Awesome Launcher", ShortName = "A. Launcher", Type = WEAPONTYPE_SPECIAL, SWEP = "weapon_as_awesomelauncher", Description = "Fires remote controlled explosive orbs. Ideal for both enclosed areas and long range assaults. The orb must touch a surface before being able to detonate.\n\nUse movement keys to guide the orb.\n\nPress FIRE to detonate.\n\nPress ALT FIRE to shoot without guiding or to stop guiding."},
{Name = "Berserker Sword", ShortName = "B. Sword", Type = WEAPONTYPE_MELEE, SWEP = "weapon_as_berserkersword", Description = "Powerful, technologically-enhanced sword. The light-weight material makes this enourmous sword easy to swing, deserving it the title \"Berserker Sword\".\n\nPress and hold FIRE to deal rapid slashes.\n\nPress ALT FIRE to use an uppercut. Enemies thrown in the air can be shot to juggle them."},
{Name = "Defender", Type = WEAPONTYPE_DEFENSE, SWEP = "weapon_as_defender", Description = "A double-barreled rifle, first of its kind. Its inacurracy makes it perfect for anything, as long as that anything is near you."},
{Name = "Rail Gun", Type = WEAPONTYPE_SPECIAL, SWEP = "weapon_as_railgun", Description = "By passing a projectile through a magnetic field, this gun's bullet speed is made near instantaneous. Although the damage is low compared to the Awesome Rifle, it has a high knock back.\n\nRequires charge up time to do any kind of serious damage. Press ALT FIRE to begin charging."},

{Name = "Dinky Gun", Type = WEAPONTYPE_LIGHT, SWEP = "weapon_as_dinkygun", Description = "Hand gun designed by Dr. T.R. Dinky. Has a surprisingly high stopping power and a decent rate of fire.\n\n\"Not so dinky\""},
{Name = "Desert Eagle", Type = WEAPONTYPE_LIGHT, SWEP = "weapon_as_deagle", Description = "This hand gun was created by a renowned scientist and bird watcher. The bullets look like scale models of desert eagles."},
{Name = "Dualies", Type = WEAPONTYPE_LIGHT, SWEP = "weapon_as_dualies", Description = "What you can't make up for in quality, make it up in quantity. Alone, these old models don't hold a candle to the current generation of weaponry. You still look cool and there's two of them. Two times the cool."},
{Name = "Quick Silver", Type = WEAPONTYPE_LIGHT, SWEP = "weapon_as_quicksilver", Description = "Its modified firing mechanisms enable it to fire at blinding speeds. A model with a larger clip size is apparently in development."},

{Name = "Knife", Type = WEAPONTYPE_MELEE, SWEP = "weapon_as_knife", Description = "Very fast and deals triple damage in the back.\n\nCan be thrown. Thrown damage is based directly on time in the air."},
{Name = "Detonation Pack", ShortName = "D. Pack", Type = WEAPONTYPE_DEFENSE, SWEP = "weapon_as_detpack", Description = "Plant a remote explosive and detonate it when you want to.\n\nHold FIRE to arm the pack. Press FIRE again to detonate."},
{Name = "Heal Ray", Type = WEAPONTYPE_DEFENSE, SWEP = "weapon_as_medray", Description = "Allows the healing of team members even at a range.\n\nHold FIRE to heal.\n\nHold RELOAD to restore healing energy."},
{Name = "Grapple Chain", Type = WEAPONTYPE_SPECIAL, SWEP = "weapon_as_grapplechain", Description = "Allows you to grapple on to anything solid and reel yourself in. Can also be used as a melee weapon."},
{Name = "Concussion Grenade", ShortName = "Conc. Grenade", Type = WEAPONTYPE_SPECIAL, SWEP = "weapon_as_grenade_cnc", Description = "Any enemies caught in the blast of this grenade will be knocked down and blown back.\n\nPerfect for tossing in a room before storming it or just knocking someone off a cliff."},
{Name = "Seizure Grenade", ShortName = "Seiz. Grenade", Type = WEAPONTYPE_SPECIAL, SWEP = "weapon_as_grenade_sz", Description = "Send someone you love a seizure today! Contains enough lights to make anyone an epileptic."},

{Name = "Six Shooter", Type = WEAPONTYPE_LIGHT, SWEP = "weapon_as_sixshooter", Description = "Although it is gets less of a damage-to-bullet ratio than other pistols, this side-arm fires shots that travel faster.\nEach successful hit increases the force applied by its shots."},
{Name = "B.E.E. Hive", Type = WEAPONTYPE_DEFENSE, SWEP = "weapon_as_grenade_bh", Description = "Explodes in to a swarm of angry, electronic bees that chase after any enemies that come too close."},
{Name = "Shockwave Bat", Type = WEAPONTYPE_MELEE, SWEP = "weapon_as_shockwavebat", Description = "A massive bat with the power of creating shockwaves. It's slow and cumbersome but packs a big punch.\n\nPress FIRE to do a basic swing.\n\nPress ALTERNATE FIRE to do a lunging ground slam."},
{Name = "Red Barrel on a Stick", ShortName = "RBOAS", Type = WEAPONTYPE_SPECIAL, SWEP = "weapon_as_redbarrelonastick", Description = "Who in their right mind would hit anything with this?!"},
{Name = "Dodge Ball", Type = WEAPONTYPE_SPECIAL, SWEP = "weapon_as_dodgeball", Description = "Give someone a good hit and they'll go flying a good mile.\n\nIf you can dodge a ball, you can dodge a soccer ball made of concrete!"}
}

GM.KillActionBasePoints = {
	[KILLACTION_GENERIC] = 2, -- Don't remove this line.
	[KILLACTION_DOORSMASH] = 4,
	[KILLACTION_BEATUP] = 4,
	[KILLACTION_PHYSICS] = 3,
	[KILLACTION_AWESOMELAUNCHER] = 2,
	[KILLACTION_AWESOMELAUNCHERGUIDED] = 3,
	[KILLACTION_AWESOMERIFLE] = 2,
	[KILLACTION_AWESOMERIFLEGUIDED] = 3,

	[KILLACTION_STAB] = 3,
	[KILLACTION_SLASH] = 3,
	[KILLACTION_SHOCKWAVEBAT] = 3,
	[KILLACTION_THROWNKNIFE] = 3,
	[KILLACTION_HOOKED] = 3,
	[KILLACTION_HOSTAGE] = 3,
	[KILLACTION_FLAG] = 4
}
GM.KillAction2ExtraPoints = {
	[KILLACTION2_SLIDE] = 1,
	[KILLACTION2_WALLRUN] = 3,
	[KILLACTION2_WALLJUMP] = 1,
	[KILLACTION2_BULLETBOUNCE] = 3,
	[KILLACTION2_MIDAIR] = 2,
	[KILLACTION2_ANTIAIR] = 1,
	[KILLACTION2_DEFLECTED] = 3,
	[KILLACTION2_DISTANT] = 1,
	[KILLACTION2_FROMTHEGRAVE] = 1,
	[KILLACTION2_EFFICIENT] = 1,
	[KILLACTION2_GHOST] = 1,
	[KILLACTION2_BLINK] = 1,
	[KILLACTION2_FLYBY] = 1,
	[KILLACTION2_2XKILL] = 1,
	[KILLACTION2_3XKILL] = 1,
	[KILLACTION2_4XKILL] = 2,
	[KILLACTION2_5XKILL] = 3,
	[KILLACTION2_JUGGLE] = 2,
	[KILLACTION2_SEIZURESLAYER] = 1
}

GM.KillMessageMainTypeStrings = {
[KILLACTION_GENERIC] = "killed",
[KILLACTION_BULLET] = "shot",
[KILLACTION_BULLETHEADSHOT] = "head shotted",
[KILLACTION_STAB] = "stabbed",
[KILLACTION_SLASH] = "cut up",
[KILLACTION_BASH] = "bashed",
[KILLACTION_EXPLOSION] = "blew up",
[KILLACTION_BURN] = "burned",
[KILLACTION_SHOCK] = "shocked",
[KILLACTION_FREEZE] = "froze",
[KILLACTION_DISSOLVE] = "dissolved",
[KILLACTION_ENVIRONMENT] = "obliterated",
[KILLACTION_PHYSICS] = "physics killed",
[KILLACTION_AWESOMERIFLE] = "awesome rifle shotted",
[KILLACTION_AWESOMERIFLEGUIDED] = "guide shotted",
[KILLACTION_PLANTEDBOMB] = "bombed",
[KILLACTION_AWESOMELAUNCHERGUIDED] = "guide launchered",
[KILLACTION_AWESOMELAUNCHER] = "awesome launchered",
[KILLACTION_DETONATED] = "detonated",
[KILLACTION_DINKIED] = "dinkied",
[KILLACTION_SMARTRIFLED] = "smart rifled",
[KILLACTION_SPRAYED] = "sprayed",
[KILLACTION_MINIGUNNED] = "minigunned",
[KILLACTION_QUICKSILVERED] = "quick silvered",
[KILLACTION_CROSSFIRED] = "crossfired",
[KILLACTION_BEATUP] = "beat up",
[KILLACTION_DOORSMASH] = "smashed a door in to",
[KILLACTION_DESERTEAGLE] = "desert eagled",
[KILLACTION_RAILGUN] = "railed",
[KILLACTION_THROWNKNIFE] = "threw a knife at",
[KILLACTION_HOOKED] = "hooked",
[KILLACTION_TAGGED] = "tagged",
[KILLACTION_HOSTAGE] = "hostage bashed",
[KILLACTION_SHOCKWAVEBAT] = "shockwave batted",
[KILLACTION_SAWARANG] = "sawaranged",
[KILLACTION_FLAG] = "flag bashed",
[KILLACTION_SIXSHOOTER] = "six shootered",
[KILLACTION_BEEHIVE] = "b.e.e. hived",
[KILLACTION_REDBARRELONASTICK] = "red barreled",
[KILLACTION_DODGEBALL] = "dodge balled"
}

GM.KillMessageSubTypeStrings = {
[KILLACTION2_SLIDE] = "sliding",
[KILLACTION2_WALLRUN] = "wall running",
[KILLACTION2_WALLJUMP] = "wall jumping",
[KILLACTION2_MIDAIR] = "mid-air",
[KILLACTION2_ANTIAIR] = "anti-air",
[KILLACTION2_BULLETBOUNCE] = "bullet bouncing",
[KILLACTION2_DEFLECTED] = "deflected",
[KILLACTION2_DISTANT] = "distant",
[KILLACTION2_FROMTHEGRAVE] = "from the grave",
[KILLACTION2_EFFICIENT] = "efficient",
[KILLACTION2_BLINK] = "blinker",
[KILLACTION2_GHOST] = "ghost",
[KILLACTION2_FLYBY] = "fly by",
[KILLACTION2_2XKILL] = "double kill",
[KILLACTION2_3XKILL] = "triple kill",
[KILLACTION2_4XKILL] = "super kill",
[KILLACTION2_5XKILL] = "awesome kill",
[KILLACTION2_JUGGLE] = "juggle",
[KILLACTION2_SEIZURESLAYER] = "seizure slayer"
}

GM.Tips = {
	"Lead your shots! Bullets take time to travel.",
	"The Smart Rifle and Smart Targeting skill will lead shots for you.",
	"There are no head shots or damage bonuses for different body parts.",
	"Press right click with the Awesome Rifle or Awesome Launcher to fire an unguided shot.",
	"The Knife does triple damage in the back.",
	"You will receive points for healing and reviving your team members.",
	"Thrown knives deal damage based on time in the air.",
	"Use the B.E.E. Hive to protect vital areas such as hostages, capture zones, and doors.",
	"Walls can be climbed by wall jumping and then dodging in to the wall repeatedly.",
	"You receive bonus points for killing someone right after using Blink.",
	"Attacking while dodging will cancel the dodge.",
	"Sliding in to props can bash them in to other players, potentially killing them.",
	"Hostages can't be killed no matter how much you beat on them.",
	"You can revive team members by holding USE on their grave stone.",
	"The Six Shooter's bullets travel faster than normal.",
	"You get bonus points for bouncing your bullets.",
	"Mechanical Mastery halves the cooldown time on things like grenades and detonation packs.",
	"You receive more points for skill shots.",
	"Enemies hit while in the air can be juggled. Use the Berserker Sword's uppercut and then shoot them in the air!",
	"You receive bonus points for killing someone right after you stop using Light Bending.",
	"Speed Mastery enhances all of your special moves.",
	"You get big time points for killing people immediately after killing someone else.",
	"The Force Shield skill can reflect bullets.",
	"The Rail Gun can hit multiple targets with a single beam.",
	"Use Medical Mastery to heal your team members faster and revive them with full health.",
	"Sliding in to a door will blow it off its hinges.",
	"You receive double points while on a kill streak or a win streak.",
	"Every point you earn will immediately give you 3 points of health.",
	"Use the Awesome Rifle or Awesome Launcher to hit targets hiding around corners.",
	"The Six Shooter will knock back targets with each hit.",
	"Use the Quick Silver for extreme burst damage.",
	"Use the Detonation Pack to guard important places.",
	"The Pulse skill can be used to throw objects in to nearby enemies.",
	"Siezure Grenades are great to use before a direct assault.",
	"Use the Concussion Grenade to toss enemies away from capture zones or off of a cliff."
}
