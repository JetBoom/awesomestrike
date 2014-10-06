AddCSLuaFile()

if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.Help = {"Left click: Fire bullets in an alternating cross."}

	
	SWEP.ViewModelBoneMods = {
		["Python"] = { scale = Vector(0.01, 0.01, 0.01), pos = Vector(0, 0, 0.325), angle = Angle(0, 0, 0) }
	}
	SWEP.VElements = {
		["glow1"] = { type = "Sprite", sprite = "sprites/glow04", bone = "Base", rel = "python", pos = Vector(0, -1.857, -0.788), size = { x = 1.347, y = 1.347 }, color = Color(255, 177, 0, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
		["deco1"] = { type = "Model", model = "models/Items/battery.mdl", bone = "Python", rel = "python", pos = Vector(0.063, -0.288, -2.289), angle = Angle(-45, 90, 0), size = Vector(0.15, 0.15, 0.15), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["cross"] = { type = "Model", model = "models/props_c17/playground_teetertoter_stan.mdl", bone = "Base", rel = "python", pos = Vector(0, -0.5, 11), angle = Angle(180, 0, 0), size = Vector(0.25, 0.25, 0.1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["cross+"] = { type = "Model", model = "models/props_c17/playground_teetertoter_stan.mdl", bone = "Base", rel = "python", pos = Vector(0, -0.5, 11), angle = Angle(180, 90, 0), size = Vector(0.25, 0.25, 0.1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["python"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "Python", rel = "", pos = Vector(0, 0, -1.3), angle = Angle(0, 0, 0), size = Vector(0.1, 0.1, 0.075), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	SWEP.WElements = {
		["glow1"] = { type = "Sprite", sprite = "sprites/glow04", bone = "ValveBiped.Bip01_R_Hand", rel = "python", pos = Vector(0, -1.857, -0.788), size = { x = 1.347, y = 1.347 }, color = Color(255, 177, 0, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
		["deco1"] = { type = "Model", model = "models/Items/battery.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "python", pos = Vector(0.063, -0.288, -2.289), angle = Angle(-45, 90, 0), size = Vector(0.15, 0.15, 0.15), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["cross"] = { type = "Model", model = "models/props_c17/playground_teetertoter_stan.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "python", pos = Vector(0, -0.5, 11), angle = Angle(180, 0, 0), size = Vector(0.25, 0.25, 0.1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["python"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(6.025, 1.031, -3.863), angle = Angle(180, 90, 90), size = Vector(0.1, 0.1, 0.075), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["cross+"] = { type = "Model", model = "models/props_c17/playground_teetertoter_stan.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "python", pos = Vector(0, -0.5, 11), angle = Angle(180, 90, 0), size = Vector(0.25, 0.25, 0.1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

SWEP.Slot = 0

SWEP.PrintName = "Crossfire"

SWEP.HoldType = "pistol"

SWEP.Base = "weapon_as_base"

SWEP.ViewModel = "models/weapons/v_357.mdl"
SWEP.WorldModel = "models/weapons/w_357.mdl"

SWEP.Primary.Sound = Sound("awesomestrike/crossfire_single.wav") --Sound("Weapon_M3.Single")
SWEP.Primary.ClipSize = 6
SWEP.BulletDamage = 7
SWEP.Primary.Delay = 0.85
SWEP.Primary.BusyTime = 0.5
SWEP.Primary.NumBullets = 5
SWEP.ReloadSound = Sound("Weapon_357.OpenLoader")

SWEP.Cone = 1.35
SWEP.ConeVariance = 0

SWEP.WalkSpeed = SPEED_NORMAL

function SWEP:DoShoot()
	local fCone = self:GetCone()
	local owner = self.Owner
	local ang = owner:EyeAngles()
	local rot = self:GetDTBool(2) and ang:Up() or ang:Right()

	ang:RotateAroundAxis(rot, fCone * self.Primary.NumBullets * -0.5)

	local shootpos = owner:GetShootPos()
	for i = 1, self.Primary.NumBullets do
		ang:RotateAroundAxis(rot, fCone)
		CreateBullet(shootpos, ang:Forward(), owner, self, self.BulletDamage, self.BulletSpeed, self.BulletClass, true)
	end

	self:SetDTBool(2, not self:GetDTBool(2))
end

function SWEP:GetKillAction(pl, attacker, dmginfo)
	return KILLACTION_CROSSFIRED, nil
end
