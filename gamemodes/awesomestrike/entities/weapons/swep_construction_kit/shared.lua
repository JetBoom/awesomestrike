
if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then

	SWEP.PrintName		= "SWEP Construction Kit"
	SWEP.Author			= "Clavus"
	SWEP.Contact		= "clavus@clavusstudios.com"
	SWEP.Purpose		= "Design SWEP ironsights and clientside models"
	SWEP.Instructions	= "http://tinyurl.com/swepkit"
	SWEP.Slot			= 5
	SWEP.SlotPos		= 10
	SWEP.ViewModelFlip	= false
	
	SWEP.DrawCrosshair	= false
	
	SWEP.ShowViewModel 	= true
	SWEP.ShowWorldModel = true
	
end

SWEP.HoldType = "pistol"
SWEP.HoldTypes = { "normal", "melee", "melee2", "fist", 
"knife", "smg", "ar2", "pistol", "rpg", "physgun", 
"grenade", "shotgun", "crossbow", "slam" }

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_pistol.mdl"
SWEP.WorldModel			= "models/weapons/w_pistol.mdl"
SWEP.CurWorldModel 		= "models/weapons/w_pistol.mdl" // this is where shit gets hacky 

SWEP.ViewModelFOV		= 70
SWEP.BobScale			= 0
SWEP.SwayScale			= 0

SWEP.Primary.Automatic	= false

SWEP.IronsightTime = 0.2

SWEP.IronSightsPos = Vector(0, 0, 0)
SWEP.IronSightsAng = Vector(0, 0, 0)

local sck_class = ""

function SWEP:Initialize()

	self:SetWeaponHoldType(self.HoldType)
	
	self:SetIronSights( true )
	self:ResetIronSights()
	
	if CLIENT then
		self:CreateWeaponWorldModel()
		self:ClientInit()
		if (not file.IsDir("swep_construction_kit", "DATA")) then
			file.CreateDir("swep_construction_kit")
		end
	end
	
	self.Dropped = false
	
	sck_class = self:GetClass()
	
end

function SWEP:Equip()

	self.Dropped = false

end

function SWEP:PrimaryAttack()

	self.Weapon:SetNextPrimaryFire(CurTime() + 0.2)

	if CLIENT then
		self:OpenMenu()
	end
	if game.SinglePlayer() then
		self.Owner:SendLua("LocalPlayer():GetActiveWeapon():OpenMenu()")
	end
	
end

function SWEP:SecondaryAttack()
	
	self.Weapon:SetNextSecondaryFire(CurTime() + 0.2)
	
	if CLIENT then
		self:OpenMenu()
	end
	if game.SinglePlayer() then
		self.Owner:SendLua("LocalPlayer():GetActiveWeapon():OpenMenu()")
	end
	
end


function SWEP:SetupDataTables()

	self:DTVar( "Bool", 0, "ironsights" )
	self:DTVar( "Bool", 1, "thirdperson" )
	
end

function SWEP:ToggleIronSights()
	self.dt.ironsights = !self.dt.ironsights
end

function SWEP:SetIronSights( b )
	self.dt.ironsights = b
end

function SWEP:GetIronSights()
	return self.dt.ironsights
end

function SWEP:ResetIronSights()
	RunConsoleCommand("_sp_ironsight_x", 0)
	RunConsoleCommand("_sp_ironsight_y", 0)
	RunConsoleCommand("_sp_ironsight_z", 0)
	RunConsoleCommand("_sp_ironsight_pitch", 0)
	RunConsoleCommand("_sp_ironsight_yaw", 0)
	RunConsoleCommand("_sp_ironsight_roll", 0)
end

function SWEP:ToggleThirdPerson()
	self.dt.thirdperson = !self.dt.thirdperson
	if (self.dt.thirdperson) then self.Owner:CrosshairDisable()
	else self.Owner:CrosshairEnable() end
end

function SWEP:SetThirdPerson( b )
	self.dt.thirdperson = b
	if (self.dt.thirdperson) then self.Owner:CrosshairDisable()
	else self.Owner:CrosshairEnable() end
end

function SWEP:GetThirdPerson()
	return self.dt.thirdperson
end

function SWEP:GetViewModelPosition(pos, ang)

	local bIron = self.dt.ironsights
	local fIronTime = self.fIronTime or 0

	if (not bIron and fIronTime < CurTime() - self.IronsightTime) then
		return pos, ang
	end
	
	self.IronSightsPos, self.IronSightsAng = self:GetIronSightCoordination()

	local Mul = 1.0

	if (fIronTime > CurTime() - self.IronsightTime) then
		Mul = math.Clamp((CurTime() - fIronTime) / self.IronsightTime, 0, 1)

		if not bIron then Mul = 1 - Mul end
	end

	local Offset	= self.IronSightsPos

	if (self.IronSightsAng) then
		ang = ang * 1
		ang:RotateAroundAxis(ang:Right(), 		self.IronSightsAng.x * Mul)
		ang:RotateAroundAxis(ang:Up(), 		self.IronSightsAng.y * Mul)
		ang:RotateAroundAxis(ang:Forward(), 	self.IronSightsAng.z * Mul)
	end

	local Right 	= ang:Right()
	local Up 		= ang:Up()
	local Forward 	= ang:Forward()

	pos = pos + Offset.x * Right * Mul
	pos = pos + Offset.y * Forward * Mul
	pos = pos + Offset.z * Up * Mul
	
	return pos, ang
end

SWEP.ir_x = CreateConVar( "_sp_ironsight_x", 0.0 )
SWEP.ir_y = CreateConVar( "_sp_ironsight_y", 0.0 )
SWEP.ir_z = CreateConVar( "_sp_ironsight_z", 0.0 )
SWEP.ir_p = CreateConVar( "_sp_ironsight_pitch", 0.0 )
SWEP.ir_yw = CreateConVar( "_sp_ironsight_yaw", 0.0 )
SWEP.ir_r = CreateConVar( "_sp_ironsight_roll", 0.0 )

function SWEP:GetIronSightCoordination()
	
	local vec = Vector( self.ir_x:GetFloat(), self.ir_y:GetFloat(), self.ir_z:GetFloat() )
	local ang = Vector( self.ir_p:GetFloat(), self.ir_yw:GetFloat(), self.ir_r:GetFloat() )
	return vec, ang
	
end

function SWEP:GetHoldTypes()
	return self.HoldTypes
end

SWEP.LastOwner = nil
/***************************
	Helper functions
***************************/
SWEP.IsSCK = true
local function GetSWEP( pl )
	local wep = pl:GetActiveWeapon()
	if (IsValid(wep) and wep.IsSCK) then
		return wep
	end
	//error("Not holding SWEP Construction Kit!")
	return NULL
end
	
/***********************************************
		SERVER CODE YEEEEEAAAAAHHH
***********************************************/
if SERVER then

	local function CanPickup( pl, wep )
		
		if (wep:GetClass() == sck_class) then
			return pl:KeyDown(IN_RELOAD) or !wep.Dropped
		end
		
	end
	hook.Add("PlayerCanPickupWeapon","SCKPickup",CanPickup)
		
	function SWEP:Deploy()
		self.LastOwner = self.Owner
	end

	function SWEP:OnDrop()
		if (IsValid(self.LastOwner)) then
			self.LastOwner:SendLua("Entity("..self:EntIndex().."):OnDropWeapon()")
		end
		self.LastOwner = nil
	end
	
	local function Cmd_SetHoldType( pl, cmd, args )

		local holdtype = args[1]
		local wep = GetSWEP( pl )
		if (IsValid(wep) and holdtype and table.HasValue( wep:GetHoldTypes(), holdtype )) then
			wep:SetWeaponHoldType( holdtype )
			wep.HoldType = holdtype
		end	

	end
	concommand.Add("swepck_setholdtype", Cmd_SetHoldType)

	local function Cmd_ToggleThirdPerson( pl, cmd, args )

		local wep = GetSWEP( pl )
		if (IsValid(wep)) then
			wep:ToggleThirdPerson()
		end

	end
	concommand.Add("swepck_togglethirdperson", Cmd_ToggleThirdPerson)
	
	local function Cmd_PlayAnimation( pl, cmd, args )

		local wep = GetSWEP( pl )
		if (IsValid(wep)) then
			local anim = tonumber(args[1] or 0)
			wep:ResetSequenceInfo()
			wep:SendWeaponAnim( anim )
		end
		
	end
	concommand.Add("swepck_playanimation", Cmd_PlayAnimation)
	
	local function Cmd_ToggleSights( pl, cmd, args )

		local wep = GetSWEP( pl )
		if (IsValid(wep)) then
			wep:ToggleIronSights()
		end

	end
	concommand.Add("swepck_toggleironsights", Cmd_ToggleSights)

	local function Cmd_ViewModelFOV( pl, cmd, args )

		local wep = GetSWEP( pl )
		if (IsValid(wep)) then
			wep.ViewModelFOV = tonumber(args[1] or wep.ViewModelFOV)
		end
		
	end
	concommand.Add("swepck_viewmodelfov", Cmd_ViewModelFOV)
	
	local function Cmd_ViewModel( pl, cmd, args )

		local wep = GetSWEP( pl )
		if (!IsValid(wep)) then return end
		local newmod = args[1] or wep.ViewModel
		newmod = newmod..".mdl"
		if !file.Exists (newmod, "GAME") then return end
		
		//util.PrecacheModel(newmod)
		wep.ViewModel = newmod
		pl:GetViewModel():SetWeaponModel(Model(newmod), wep)
		pl:SendLua([[LocalPlayer():GetActiveWeapon().ViewModel = "]]..newmod..[["]])
		//pl:SendLua([[LocalPlayer():GetViewModel():SetModel("]]..newmod..[[")]])
		pl:SendLua([[LocalPlayer():GetViewModel():SetWeaponModel(Model("]]..newmod..[["), Entity(]]..wep:EntIndex()..[[))]])
		
		local quickswitch = nil
		for k, v in pairs( pl:GetWeapons() ) do
			if (v:GetClass() != wep:GetClass()) then 
				quickswitch = v:GetClass()
				break
			end
		end
		
		if (quickswitch) then
			pl:SelectWeapon( quickswitch )
			pl:SelectWeapon( wep:GetClass() )
		else
			pl:ChatPrint("Switch weapons to make the new viewmodel show up")
		end
		
		//print("Changed viewmodel to \""..wep.ViewModel.."\"")
		
	end
	concommand.Add("swepck_viewmodel", Cmd_ViewModel)
	
	local function Cmd_WorldModel( pl, cmd, args )

		local wep = GetSWEP( pl )
		if (!IsValid(wep)) then return end
		local newmod = args[1] or wep.CurWorldModel
		newmod = newmod..".mdl"
		if !file.Exists (newmod, "GAME") then return end
		
		util.PrecacheModel(newmod)
		wep.CurWorldModel = newmod
		wep:SetModel(newmod)
		pl:SendLua([[LocalPlayer():GetActiveWeapon().CurWorldModel = "]]..newmod..[["]])
		pl:SendLua([[LocalPlayer():GetActiveWeapon():CreateWeaponWorldModel()]])
		//print("Changed worldmodel to \""..wep.CurWorldModel.."\"")
		
	end
	concommand.Add("swepck_worldmodel", Cmd_WorldModel)
	
	local function Cmd_DropWep( pl, cmd, args )

		local wep = GetSWEP( pl )
		if (IsValid(wep)) then
			wep.Dropped = true
			pl:DropWeapon(wep)
		end
		
	end
	concommand.Add("swepck_dropwep", Cmd_DropWep)
	
end

/***********************************************
		CLIENT CODE WHOOOOOOOOOOO
***********************************************/
if CLIENT then

	surface.CreateLegacyFont("Arial", 12, 500, true, false, "12ptFont")
	surface.CreateLegacyFont("Arial", 24, 500, true, false, "24ptFont")
	
	local tutorialURL = "http://www.facepunch.com/threads/1032378-SWEP-Construction-Kit-developer-tool-for-modifying-viewmodels-ironsights/"
	SWEP.useThirdPerson = false
	SWEP.thirdPersonAngle = Angle(0,-90,0)
	SWEP.thirdPersonDis = 100
	SWEP.mlast_x = ScrW()/2
	SWEP.mlast_y = ScrH()/2
	
	local playerBones = { "ValveBiped.Bip01_Head1", "ValveBiped.Bip01_Spine", "ValveBiped.Bip01_Pelvis", "ValveBiped.Bip01_Spine4",
	"ValveBiped.Anim_Attachment_RH", "ValveBiped.Bip01_R_Hand", "ValveBiped.Bip01_R_UpperArm", "ValveBiped.Bip01_R_Forearm",
	"ValveBiped.Bip01_R_Foot", "ValveBiped.Bip01_R_Thigh", "ValveBiped.Bip01_R_Calf", 
	"ValveBiped.Bip01_R_Clavicle",
	"ValveBiped.Anim_Attachment_LH", "ValveBiped.Bip01_L_Hand", "ValveBiped.Bip01_L_UpperArm", "ValveBiped.Bip01_L_Forearm",
	"ValveBiped.Bip01_L_Foot", "ValveBiped.Bip01_L_Thigh", "ValveBiped.Bip01_L_Calf", 
	"ValveBiped.Bip01_L_Clavicle" }
	
	SWEP.v_models = {}
	SWEP.v_panelCache = {}
	SWEP.v_modelListing = nil
	SWEP.v_bonemods = {}
	SWEP.v_modelbonebox = nil
	
	SWEP.w_models = {}
	SWEP.w_panelCache = {}
	SWEP.w_modelListing = nil
	
	SWEP.world_model = nil
	SWEP.cur_wmodel = nil
	
	SWEP.browser_callback = nil
	SWEP.modelbrowser = nil
	SWEP.modelbrowser_list = nil
	SWEP.matbrowser = nil
	SWEP.matbrowser_list = nil
	
	SWEP.save_data = {}
	local save_data_template = {
		ViewModel = SWEP.ViewModel,
		CurWorldModel = SWEP.CurWorldModel,
		w_models = {},
		v_models = {},
		v_bonemods = {},
		ViewModelFOV = SWEP.ViewModelFOV,
		HoldType = SWEP.HoldType,
		ViewModelFlip = SWEP.ViewModelFlip,
		IronSightsEnabled = true,
		IronSightsPos = SWEP.IronSightsPos,
		IronSightsAng = SWEP.IronSightsAng,
		ShowViewModel = true,
		ShowWorldModel = true
	}

	SWEP.ir_drag = {
		x = { true, "-x", 25 },
		y = { false, "y", 25 },
		z = { true, "y", 25 },
		pitch = { false, "y", 10 },
		yaw = { false, "x", 10 },
		roll = { false, "y", 10 }
	}
	local drag_modes = {
		["x / z"] = { "x", "z" },
		["y"] = { "y" },
		["pitch / yaw"] = { "pitch", "yaw" },
		["roll"] = { "roll" }	
	}
	SWEP.cur_drag_mode = "x / z"
	SWEP.Frame = nil
	
	local function PrintVec( vec )
		local px, py, pz = math.Round(vec.x, 4),math.Round(vec.y, 4),math.Round(vec.z, 4)
		return "Vector("..px..", "..py..", "..pz..")"
	end
	
	local function PrintAngle( angle )
		local pp, py, pr = math.Round(angle.p, 4),math.Round(angle.y, 4),math.Round(angle.r, 4)
		return "Angle("..pp..", "..py..", "..pr..")"
	end
	
	local function PrintColor( col )
		return "Color("..col.r..", "..col.g..", "..col.b..", "..col.a..")"
	end	

	function SWEP:ClientInit()
	
		// init view model bone build function
		self.BuildViewModelBones = function( s )
			if LocalPlayer():GetActiveWeapon() == self and self.v_bonemods then
				for k, v in pairs( self.v_bonemods ) do
					local bone = s:LookupBone(k)
					if (!bone) then continue end
					local m = s:GetBoneMatrix(bone)
					if (!m) then continue end
					m:Scale(v.scale)
					m:Rotate(v.angle)
					m:Translate(v.pos)
					s:SetBoneMatrix(bone, m)
				end
			end
		end
		
	end
	
	// Populates a DComboBox with all the bones of the specified entity
	// returns if it has a first option
	local function PopulateBoneList( choicelist, ent )
		if (!IsValid(choicelist)) then return false end
		if (!IsValid(ent)) then return end
		
		if (ent == LocalPlayer()) then
			// if the local player is in third person, his bone lookup is all messed up so
			// we just use the predefined playerBones table
			for k, v in pairs(playerBones) do
				choicelist:AddChoice(v)
			end
			
			return true
		else
			local hasfirstoption
			for i = 0, ent:GetBoneCount() - 1 do
				local name = ent:GetBoneName(i)
				if (ent:LookupBone(name)) then // filter out invalid bones
					choicelist:AddChoice(name)
					if (!firstoption) then hasfirstoption = true end
				end
			end
			
			return hasfirstoption
		end
	end
	
	local function GetWeaponPrintText( wep )
		
		str = ""
		str = str.."SWEP.HoldType = \""..wep.HoldType.."\"\n"
		str = str.."SWEP.ViewModelFOV = "..wep.ViewModelFOV.."\n"
		str = str.."SWEP.ViewModelFlip = "..tostring(wep.ViewModelFlip).."\n"
		str = str.."SWEP.ViewModel = \""..wep.ViewModel.."\"\n"
		str = str.."SWEP.WorldModel = \""..wep.CurWorldModel.."\"\n"
		str = str.."SWEP.ShowViewModel = "..tostring(wep.ShowViewModel).."\n"
		str = str.."SWEP.ShowWorldModel = "..tostring(wep.ShowWorldModel).."\n"
		str = str.."SWEP.ViewModelBoneMods = {"
		local i = 0
		local num = table.Count( wep.v_bonemods )
		for k, v in pairs( wep.v_bonemods ) do
			if !(v.scale == Vector(1,1,1) and v.pos == Vector(0,0,0) and v.angle == Angle(0,0,0)) then
				if (i == 0) then str = str.."\n" end
				i = i + 1
				str = str.."\t[\""..k.."\"] = { scale = "..PrintVec( v.scale )..", pos = "..PrintVec( v.pos )..", angle = "..PrintAngle( v.angle ).." }"
				
				if (i < num) then str = str.."," end
				str = str.."\n"
			end
		end
		str = str.."}"
		
		str = string.Replace(str,",\n}","\n}") // remove the last comma
		
		return str
		
	end
	
	local function GetIronSightPrintText( vec, ang )
		return "SWEP.IronSightsPos = "..PrintVec( vec ).."\nSWEP.IronSightsAng = "..PrintVec( ang )
	end
	
	local function GetVModelsText()
	
		local wep = GetSWEP( LocalPlayer() )
		if (!IsValid(wep)) then return "" end
		
		local str = ("SWEP.VElements = {\n")
		local i = 0
		local num = table.Count(wep.v_models)
		for k, v in pairs( wep.v_models ) do
		
			if (v.type == "Model") then
				str = str.."\t[\""..k.."\"] = { type = \"Model\", model = \""..v.model.."\", bone = \""..v.bone.."\", rel = \""..v.rel.."\", pos = "..PrintVec(v.pos)
				str = str..", angle = "..PrintAngle( v.angle )..", size = "..PrintVec(v.size)..", color = "..PrintColor( v.color )
				str = str..", surpresslightning = "..tostring(v.surpresslightning)..", material = \""..v.material.."\", skin = "..v.skin
				str = str..", bodygroup = {"
				local i = 0
				for k, v in pairs( v.bodygroup ) do
					if (v <= 0) then continue end
					if ( i != 0 ) then str = str..", " end
					i = 1
					str = str.."["..k.."] = "..v
				end
				str = str.."} }"
			elseif (v.type == "Sprite") then
				str = str.."\t[\""..k.."\"] = { type = \"Sprite\", sprite = \""..v.sprite.."\", bone = \""..v.bone.."\", rel = \""..v.rel.."\", pos = "..PrintVec(v.pos)
				str = str..", size = { x = "..v.size.x..", y = "..v.size.y.." }, color = "..PrintColor( v.color )..", nocull = "..tostring(v.nocull)
				str = str..", additive = "..tostring(v.additive)..", vertexalpha = "..tostring(v.vertexalpha)..", vertexcolor = "..tostring(v.vertexcolor)
				str = str..", ignorez = "..tostring(v.ignorez).."}"
			elseif (v.type == "Quad") then
				str = str.."\t[\""..k.."\"] = { type = \"Quad\", bone = \""..v.bone.."\", rel = \""..v.rel.."\", pos = "..PrintVec(v.pos)..", angle = "..PrintAngle( v.angle )
				str = str..", size = "..v.size..", draw_func = nil}"
			end
			
			if (v.type) then
				i = i + 1
				if (i < num) then str = str.."," end
				str = str.."\n"
			end
		end
		str = str.."}"
		return str
	end
	
	local function GetWModelsText()
	
		local wep = GetSWEP( LocalPlayer() )
		if (!IsValid(wep)) then return "" end
	
		local str = ("SWEP.WElements = {\n")
		local i = 0
		local num = table.Count(wep.w_models)
		for k, v in pairs( wep.w_models ) do
		
			if (v.type == "Model") then
				str = str.."\t[\""..k.."\"] = { type = \"Model\", model = \""..v.model.."\", bone = \""..v.bone.."\", rel = \""..v.rel.."\", pos = "..PrintVec(v.pos)
				str = str..", angle = "..PrintAngle( v.angle )..", size = "..PrintVec(v.size)..", color = "..PrintColor( v.color )
				str = str..", surpresslightning = "..tostring(v.surpresslightning)..", material = \""..v.material.."\", skin = "..v.skin
				str = str..", bodygroup = {"
				local i = 0
				for k, v in pairs( v.bodygroup ) do
					if (v <= 0) then continue end
					if ( i != 0 ) then str = str..", " end
					i = 1
					str = str.."["..k.."] = "..v
				end
				str = str.."} }"
			elseif (v.type == "Sprite") then
				str = str.."\t[\""..k.."\"] = { type = \"Sprite\", sprite = \""..v.sprite.."\", bone = \""..v.bone.."\", rel = \""..v.rel.."\", pos = "..PrintVec(v.pos)
				str = str..", size = { x = "..v.size.x..", y = "..v.size.y.." }, color = "..PrintColor( v.color )..", nocull = "..tostring(v.nocull)
				str = str..", additive = "..tostring(v.additive)..", vertexalpha = "..tostring(v.vertexalpha)..", vertexcolor = "..tostring(v.vertexcolor)
				str = str..", ignorez = "..tostring(v.ignorez).."}"
			elseif (v.type == "Quad") then
				str = str.."\t[\""..k.."\"] = { type = \"Quad\", bone = \""..v.bone.."\", rel = \""..v.rel.."\", pos = "..PrintVec(v.pos)..", angle = "..PrintAngle( v.angle )
				str = str..", size = "..v.size..", draw_func = nil}"
			end
			
			if (v.type) then
				i = i + 1
				if (i < num) then str = str.."," end
				str = str.."\n"
			end
		end
		str = str.."}"

		str = str.."\n\n"

		local i = 0
		for k, v in pairs( wep.w_models ) do
			if (v.type == "Model") then
				i = i + 1
				str = str.."c:AddModel(\""..v.model.."\", "..PrintVec(v.pos)..", "..PrintAngle(v.angle)..", ".. ((not v.rel or #v.rel == 0) and "\""..v.bone.."\"" or "nil") ..", "..(v.size.x == 1 and v.size.y == 1 and v.size.z == 1 and "nil" or v.size.x == v.size.y and v.size.x == v.size.z and math.Round(v.size.x, 4) or PrintVec(v.size))..", ".. (v.material and #v.material > 0 and "\""..v.material.."\"" or "nil") ..", "..(v.color.r == 255 and v.color.g == 255 and v.color.b == 255 and v.color.a == 255 and "nil" or PrintColor( v.color ))
				if v.rel and #v.rel > 0 then
					str = str..", 1"
				end
				str = str..")\n"
			end
		end

		return str
	end
	
	local function ClearViewModels()
	
		local wep = GetSWEP( LocalPlayer() )
	
		wep.v_models = {}
		if (wep.v_modelListing) then wep.v_modelListing:Clear() end
		for k, v in pairs( wep.v_panelCache ) do
			if (v) then 
				v:Remove()
			end
		end
		wep.v_panelCache = {}
	end
	
	local function RefreshViewModelBoneMods()
	
		local wep = GetSWEP( LocalPlayer() )
		if (!IsValid(wep)) then return end
		
		if (!IsValid(wep.v_modelbonebox)) then return end
		wep.v_bonemods = {}
		
		wep.v_modelbonebox:Clear()
		
		timer.Destroy("repop")
		
		timer.Create("repop", 1, 1, function()
			local option = PopulateBoneList( wep.v_modelbonebox, LocalPlayer():GetViewModel() )
			if (option) then
				wep.v_modelbonebox:ChooseOptionID(1)
			end
		end)
	
	end
	
	local function ClearWorldModels()
		
		local wep = GetSWEP( LocalPlayer() )
		if (!IsValid(wep)) then return end
	
		wep.w_models = {}
		if (wep.w_modelListing) then wep.w_modelListing:Clear() end
		for k, v in pairs( wep.w_panelCache ) do
			if (v) then 
				v:Remove()
			end
		end
		wep.w_panelCache = {}
	end
	
	function SWEP:CreateWeaponWorldModel()
		
		local model = self.CurWorldModel
		
		if ((!self.world_model or (IsValid(self.world_model) and self.cur_wmodel != model)) and 
			string.find(model, ".mdl") and file.Exists (model, "GAME") ) then
			
			if IsValid(self.world_model) then self.world_model:Remove() end
			self.world_model = ClientsideModel(model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
			if (IsValid(self.world_model)) then
				self.world_model:SetParent(self.Owner)
				self.world_model:SetNoDraw(true)
				self.cur_wmodel = model
				if (self.world_model:LookupBone( "ValveBiped.Bip01_R_Hand" )) then
					self.world_model:AddEffects(EF_BONEMERGE)
				end
			else
				self.world_model = nil
				self.cur_wmodel = nil
			end

		end
		
	end

	function SWEP:CreateModels( tab )
	
		// Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then
				
				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end
				
			elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then
				
				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				// make sure we create a unique name based on the selected options
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
				
			end
		end
		
	end
	
	function SWEP:Think()
		
		self:CreateModels( self.v_models )
		self:CreateModels( self.w_models )
		
		// Some hacky shit to get 3rd person view compatible with 
		// other addons that override CalcView
		self:CalcViewHookManagement()
		
		/************************
			Camera fiddling
		************************/
		self.useThirdPerson = self:GetThirdPerson()
		
		local mx, my = gui.MousePos()
		local diffx, diffy = (mx - self.mlast_x), (my - self.mlast_y)
		
		if (input.IsMouseDown(MOUSE_RIGHT) and !(diffx > 40 or diffy > 40) and self.Frame and self.Frame:IsVisible()) then // right mouse press without sudden jumps
		
			if (self.useThirdPerson) then
			
				if (input.IsKeyDown(KEY_E)) then
					self.thirdPersonDis = math.Clamp( self.thirdPersonDis + diffy, 10, 500 )
				else
					self.thirdPersonAngle = self.thirdPersonAngle + Angle( diffy/2, diffx/2, 0 )
				end
				
			else
				// ironsight adjustment
				for k, v in pairs( self.ir_drag ) do
					if (v[1]) then
						local temp = GetConVar( "_sp_ironsight_"..k ):GetFloat()
						if (v[2] == "x") then
							local add = -(diffx/v[3])
							if (self.ViewModelFlip) then add = add*-1 end
							RunConsoleCommand( "_sp_ironsight_"..k, temp + add )
						elseif (v[2] == "-x") then
							local add = diffx/v[3]
							if (self.ViewModelFlip) then add = add*-1 end
							RunConsoleCommand( "_sp_ironsight_"..k, temp + add )
						elseif (v[2] == "y") then
							RunConsoleCommand( "_sp_ironsight_"..k, temp - diffy/v[3] )
						end
					end
				end
			
			end
			
		end
		
		self.mlast_x, self.mlast_y = mx, my
	end
	
	function SWEP:RemoveModels()
		for k, v in pairs( self.v_models ) do
			if (IsValid( v.modelEnt )) then v.modelEnt:Remove() end
		end
		for k, v in pairs( self.w_models ) do
			if (IsValid( v.modelEnt )) then v.modelEnt:Remove() end
		end
		self.v_models = {}
		self.w_models = {}
		
		if (IsValid(self.world_model)) then
			self.world_model:Remove()
			self.world_model = nil
			self.cur_wmodel = nil
		end
	end

	function SWEP:GetBoneOrientation( basetab, name, ent, bone_override, buildup )
		
		local bone, pos, ang
		local tab = basetab[name]
		
		if (tab.rel and tab.rel != "") then

			local v = basetab[tab.rel]
			
			if (!v) then return end
			
			if (!buildup) then
				buildup = {}
			end
			
			table.insert(buildup, name)
			if (table.HasValue(buildup, tab.rel)) then return end
			
			// Technically, if there exists an element with the same name as a bone
			// you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation( basetab, tab.rel, ent, nil, buildup )
			
			if (!pos) then return end
			
			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
		else
		
			bone = ent:LookupBone(bone_override or tab.bone)

			if (!bone) then return end
			
			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end
			
			if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r // Fixes mirrored models
			end
		
		end
		
		return pos, ang
	end
	
	/********************************
		All viewmodel drawing magic
	*********************************/
	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn()
		
		local vm = self.Owner:GetViewModel()
		if !IsValid(vm) then return end
		
		if vm.BuildBonePositions ~= self.BuildViewModelBones then
			vm.BuildBonePositions = self.BuildViewModelBones
		end
	
		if (!self.vRenderOrder) then
			
			// we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}

			for k, v in pairs( self.v_models ) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end
			
		end

		for k, name in ipairs( self.vRenderOrder ) do
		
			local v = self.v_models[name]
			if (!v) then self.vRenderOrder = nil break end
		
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (!v.bone) then continue end
			
			local pos, ang = self:GetBoneOrientation( self.v_models, name, vm )
			
			if (!pos) then continue end
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				model:SetModelScaleVector(v.size)
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				for k, v in pairs( v.bodygroup ) do
					if (model:GetBodygroup(k) != v) then
						model:SetBodygroup(k, v)
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad") then
			
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					draw.RoundedBox( 0, -20, -20, 40, 40, Color(200,0,0,100) )
					surface.SetDrawColor( 255, 255, 255, 100 )
					surface.DrawOutlinedRect( -20, -20, 40, 40 )
					draw.SimpleTextOutlined("12pt arial","12ptFont",0, -12, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, Color(0,0,0,255))
					draw.SimpleTextOutlined("40x40 box","12ptFont",0, 2, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, Color(0,0,0,255))
					surface.SetDrawColor( 0, 255, 0, 230 )
					surface.DrawLine( 0, 0, 0, 8 )
					surface.DrawLine( 0, 0, 8, 0 )
				cam.End3D2D()

			end
			
		end
		
	end
	
	/********************************
		All worldmodel drawing science
	*********************************/
	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()
		
		local wm = self.world_model
		if !IsValid(wm) then return end
		
		if (!self.wRenderOrder) then

			self.wRenderOrder = {}

			for k, v in pairs( self.w_models ) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end

		end

		local bone_ent
		
		if (IsValid(self.Owner)) then
			self:SetColor(255,255,255,255)
			wm:SetNoDraw(true)
			if (self.Owner:GetActiveWeapon() != self.Weapon) then return end
			wm:SetParent(self.Owner)
			if (self.ShowWorldModel) then
				wm:DrawModel()
			end
			bone_ent = self.Owner
		else
			// this only happens if the weapon is dropped, which shouldn't happen normally.
			self:SetColor(255,255,255,0)
			wm:SetNoDraw(false) // else DrawWorldModel stops being called for some reason
			wm:SetParent(self)
			//wm:SetPos(opos)
			//wm:SetAngles(oang)
			if (self.ShowWorldModel) then
				wm:DrawModel()
			end
		
			// the reason that we don't always use this bone is because it lags 1 frame behind the player's right hand bone when held
			bone_ent = wm
		end
		
		/* BASE CODE FOR NEW SWEPS */
		/*self:DrawModel()
		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			// when the weapon is dropped
			bone_ent = self
		end*/
		
		for k, name in pairs( self.wRenderOrder ) do
		
			local v = self.w_models[name]
			if (!v) then self.wRenderOrder = nil break end
			
			local pos, ang
			
			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.w_models, name, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.w_models, name, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end
			
			if (!pos) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial

			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				model:SetModelScaleVector(v.size)
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				for k, v in pairs( v.bodygroup ) do
					if (model:GetBodygroup(k) != v) then
						model:SetBodygroup(k, v)
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad") then
			
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					draw.RoundedBox( 0, -20, -20, 40, 40, Color(200,0,0,100) )
					surface.SetDrawColor( 255, 255, 255, 100 )
					surface.DrawOutlinedRect( -20, -20, 40, 40 )
					draw.SimpleTextOutlined("12pt arial","12ptFont",0, -12, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, Color(0,0,0,255))
					draw.SimpleTextOutlined("40x40 box","12ptFont",0, 2, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, Color(0,0,0,255))
					surface.SetDrawColor( 0, 255, 0, 230 )
					surface.DrawLine( 0, 0, 0, 8 )
					surface.DrawLine( 0, 0, 8, 0 )
				cam.End3D2D()

			end
			
		end
		
	end
	
	function SWEP:Holster()
		self.useThirdPerson = false
		return true
	end
	
	local function DrawDot( x, y )
	
		surface.SetDrawColor(100, 100, 100, 255)
		surface.DrawRect(x - 2, y - 2, 4, 4)
		
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawRect(x - 1, y - 1, 2, 2)
		
	end
	
	function SWEP:DrawHUD()
		
		DrawDot( ScrW()/2, ScrH()/2 )
		DrawDot( ScrW()/2 + 10, ScrH()/2 )
		DrawDot( ScrW()/2 - 10, ScrH()/2 )
		DrawDot( ScrW()/2, ScrH()/2 + 10 )
		DrawDot( ScrW()/2, ScrH()/2 - 10 )
		
		if (self.Frame and self.Frame:IsVisible()) then
		
			local text = ""
			if (self.useThirdPerson) then
				text = "Hold right mouse and drag to rotate. Additionally hold E key to zoom."
			else
				text = "Hold right mouse and drag to adjust ironsights (mode: "..self.cur_drag_mode..")"
			end
			draw.SimpleTextOutlined(text, "DefaultFont", ScrW()/2, ScrH()/4, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, Color(20,20,20,255))
			
		end
	end
	
	/***************************
				Menu
	***************************/
	local function CreateMenu( preset )
		
		local wep = GetSWEP( LocalPlayer() )
		if !IsValid(wep) then return nil end
		
		wep.save_data = table.Copy(save_data_template)
		
		if (preset) then
			// use the preset
			for k, v in pairs( preset ) do
				wep.save_data[k] = v
			end
		end
		
		/****** Create model browser *****/

		// callback = function( selected_model )
		local function OpenBrowser( current, browse_type, callback )
			
			wep.browser_callback = callback
			wep.Frame:SetVisible( false )
			
			if (browse_type == "model" and wep.modelbrowser) then
				wep.modelbrowser:SetVisible(true)
				wep.modelbrowser:MakePopup()
				wep.modelbrowser_list.OnRowSelected(nil,nil,current)
				return
			elseif (browse_type == "material" and wep.matbrowser) then
				wep.matbrowser:SetVisible(true)
				wep.matbrowser:MakePopup()
				wep.matbrowser_list.OnRowSelected(nil,nil,current)
				return
			end
		
			local browser = vgui.Create("DFrame")
			browser:SetSize( 300, 580 )
			browser:SetPos( ScrW()/4 - 150, ScrH()/2 - 250 )
			browser:SetDraggable( true )
			browser:ShowCloseButton( false )
			browser:SetSizable( false )
			browser:SetDeleteOnClose( false )

			if (browse_type == "model") then
				browser:SetTitle( "Model browser" )
				wep.modelbrowser = browser
			elseif (browse_type == "material") then
				browser:SetTitle( "Material browser" )
				wep.matbrowser = browser
			end
			
			local tree = vgui.Create( "DTree", browser )
			tree:SetPos( 5, 30 )
			tree:SetSize( browser:GetWide() - 10, browser:GetTall()-355 )

			local nodelist = {}
			local filecache = {}
			local checked = {}
			
			local modlist = vgui.Create("DListView", browser)
			modlist:SetPos( 5, browser:GetTall() - 320 )
			modlist:SetSize( browser:GetWide() - 10, 200 )
			modlist:SetMultiSelect(false)
			modlist:SetDrawBackground(true)
			if (browse_type == "model") then
				modlist:AddColumn("Model")
			elseif (browse_type == "material") then
				modlist:AddColumn("Material")
			end
			
			local modzoom = 32
			local modview 
			
			if (browse_type == "model") then
				modview = vgui.Create("DModelPanel", browser)
				modview:SetModel("")
				modview:SetCamPos( Vector(modzoom,modzoom,modzoom/2) )
				modview:SetLookAt( Vector( 0, 0, 0 ) )
			elseif (browse_type == "material") then
				modview = vgui.Create("DImage", browser)
				modview:SetImage("")
			end
			
			modview:SetPos( 5, browser:GetTall() - 115)
			modview:SetSize(110,110)

			local mdlabel = vgui.Create("DLabel", browser)
			mdlabel:SetPos( 120, browser:GetTall() - 115 )
			mdlabel:SetSize( browser:GetWide() - 125, 20 )
			mdlabel:SetText( current )

			if (browse_type == "model") then
			
				local zoomslider = vgui.Create( "DNumSlider", browser)
				zoomslider:SetPos( 120, browser:GetTall() - 90 )
				zoomslider:SetWide( browser:GetWide() - 125 )
				zoomslider:SetText( "Zoom" )
				zoomslider:SetMin( 16 )
				zoomslider:SetMax( 256 )
				zoomslider:SetDecimals( 0 )
				zoomslider:SetValue( modzoom )
				zoomslider.OnValueChanged = function( panel, value )
					local modzoom = tonumber(value)
					modview:SetCamPos( Vector(modzoom,modzoom,modzoom/2) )
				end
				local areazm = zoomslider:GetTextArea()
				areazm.OnTextChanged = function() zoomslider:SetValue(areazm:GetValue()) end
				
			end
			
			local selected = ""
			
			modlist.OnRowSelected = function( panel, line, override )
				if (type(override) != "string") then override = nil end // for some reason the list itself throws a panel at it in the callback
				local path = override or modlist:GetLine(line):GetValue(1)

				if (browse_type == "model") then
					modview:SetModel(path)
				elseif (browse_type == "material") then
					if (path:sub( 1, 10 ) == "materials/") then
						path = path:sub( 11 ) // removes the "materials/" part
					end
					path = path:gsub( "%.vmt", "" )
					modview:SetImage(path)
				end

				mdlabel:SetText(path)
				selected = path
			end
			
			// set the default
			modlist.OnRowSelected(nil,nil,current)
			if (browse_type == "model") then
				wep.modelbrowser_list = modlist
			elseif (browse_type == "material") then
				wep.matbrowser_list = modlist
			end

			local choosebtn = vgui.Create("DButton", browser)
			choosebtn:SetPos( 120, browser:GetTall() - 40 )
			choosebtn:SetSize( browser:GetWide() - 125, 18 )
			if (browse_type == "model") then
				choosebtn:SetText("DO WANT THIS MODEL")
			elseif (browse_type == "material") then
				choosebtn:SetText("DO WANT THIS MATERIAL")
			end
			
			choosebtn.DoClick = function()
				if (wep.browser_callback) then
					pcall(wep.browser_callback, selected)
				end
				if (wep.Frame) then
					wep.Frame:SetVisible(true)
				end
				browser:Close()
			end
			
			local cancelbtn = vgui.Create("DButton", browser)
			cancelbtn:SetPos( 120, browser:GetTall() - 20 )
			cancelbtn:SetSize( browser:GetWide() - 125, 16 )
			cancelbtn:SetText("cancel")
			cancelbtn.DoClick = function()
				if (wep.Frame) then
					wep.Frame:SetVisible(true)
				end
				browser:Close()
			end
			
			local LoadDirectories
			local AddNode = function( base, dir, tree_override )
				
				local newpath = base.."/"..dir
				local basenode = nodelist[base]
				
				if (tree_override) then
					newpath = dir
					basenode = tree_override
				end
				
				if (!basenode) then
					print("No base node for \""..tostring(base).."\", \""..tostring(dir).."\", "..tostring(tree_override))
				end
				
				nodelist[newpath] = basenode:AddNode( dir )
				nodelist[newpath].DoClick = function()
					LoadDirectories( newpath )
					modlist:Clear()
					modlist:SetVisible(true)
					
					if (filecache[newpath]) then
						for k, f in pairs(filecache[newpath]) do
							modlist:AddLine(f)
						end
					else
						filecache[newpath] = {}
						local files
						if (newpath:sub(1,9) == "materials") then
							files = file.Find(newpath.."/*.vmt", "GAME")
						else
							files = file.Find(newpath.."/*.mdl", "GAME")
						end
						table.sort(files)
						for k, f in pairs(files) do
							local newfilepath = newpath.."/"..f
							modlist:AddLine(newfilepath)
							table.insert(filecache[newpath], newfilepath)
						end
					end
				end
					
			end
			
			if (browse_type == "model") then
				AddNode( "", "models", tree )
			elseif (browse_type == "material") then
				AddNode( "", "materials", tree )
			end
			
			LoadDirectories = function( v )
				
				if (table.HasValue(checked,v)) then return end
				newdirs = file.FindDir(v.."/*", "GAME")
				table.insert(checked, v)
				
				table.sort(newdirs)
				
				for _, dir in pairs(newdirs) do
					AddNode( v, dir )
				end

			end
			
			if (browse_type == "model") then
				LoadDirectories( "models" )
			elseif (browse_type == "material") then
				LoadDirectories( "materials" )
			end
		
			browser:SetVisible( true )
			browser:MakePopup()
			
		end
		
		/****************************************/
		
		// Now for the actual menu:		
		local f = vgui.Create("DFrame")
		f:SetSize( 300, 640 )
		f:SetPos( ScrW()/4 - 150, ScrH()/2 - 320 )
		f:SetTitle( "SWEP Construction Kit" )
		f:SetDraggable( true )
		f:ShowCloseButton( true )
		f:SetSizable( false )
		f:SetDeleteOnClose( false )

		local tbtn = vgui.Create( "DButton", f )
		tbtn:SetPos( 155, 2 )
		tbtn:SetSize( 120, 18 )
		tbtn:SetText( "Toggle thirdperson" )
		tbtn.DoClick = function()
			RunConsoleCommand("swepck_togglethirdperson")
		end
		
		local tab = vgui.Create( "DPropertySheet", f )
		tab:SetPos( 5, 30 )
		tab:SetSize( f:GetWide() - 10, f:GetTall()-35 )
		
		local ptool = vgui.Create("DPanel", tab)
		ptool.Paint = function() surface.SetDrawColor(50,50,50,255) surface.DrawRect(0,0,ptool:GetWide(),ptool:GetTall()) end
		local pweapon = vgui.Create("DPanel", tab)
		pweapon.Paint = function() surface.SetDrawColor(50,50,50,255) surface.DrawRect(0,0,pweapon:GetWide(),pweapon:GetTall()) end
		local pironsight = vgui.Create("DPanel", tab)
		pironsight.Paint = function() surface.SetDrawColor(50,50,50,255) surface.DrawRect(0,0,pironsight:GetWide(),pironsight:GetTall()) end
		local pmodels = vgui.Create("DPanel", tab)
		pmodels.Paint = function() surface.SetDrawColor(50,50,50,255) surface.DrawRect(0,0,pmodels:GetWide(),pmodels:GetTall()) end
		local pwmodels = vgui.Create("DPanel", tab)
		pwmodels.Paint = function() surface.SetDrawColor(50,50,50,255) surface.DrawRect(0,0,pwmodels:GetWide(),pwmodels:GetTall()) end
		
		tab:AddSheet( "Tool", ptool, "gui/silkicons/wrench", false, false, "Modify tool settings" )
		tab:AddSheet( "Weapon", pweapon, "gui/silkicons/bomb", false, false, "Modify weapon settings" )
		tab:AddSheet( "Ironsights", pironsight, "gui/silkicons/wrench", false, false, "Modify ironsights" )
		tab:AddSheet( "VModels", pmodels, "gui/silkicons/brick_add", false, false, "Modify view models" )
		tab:AddSheet( "WModels", pwmodels, "gui/silkicons/brick_add", false, false, "Modify world models" )
		
		/*****************
			Tool page
		*****************/
		local addy = 10
		
		// ***** Animations *****
		
		local alabel = vgui.Create( "DLabel", ptool )
		alabel:SetPos( 10, addy )
		alabel:SetSize( 240, 20 )
		alabel:SetText( "Play animation (buggy):" )
		
		addy = addy + 25
		
		local aabtn = vgui.Create( "DButton", ptool )
		aabtn:SetPos( 10, addy )
		aabtn:SetSize( 120, 18 )
		aabtn:SetText( "Primary Attack" )
		aabtn.DoClick = function()
			RunConsoleCommand("swepck_playanimation", ACT_VM_PRIMARYATTACK)
			wep:ResetSequenceInfo()
			wep:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
			LocalPlayer():SetAnimation(PLAYER_ATTACK1)
		end
		
		local arbtn = vgui.Create( "DButton", ptool )
		arbtn:SetPos( 140, addy )
		arbtn:SetSize( 120, 18 )
		arbtn:SetText( "Reload" )
		arbtn.DoClick = function()
			RunConsoleCommand("swepck_playanimation", ACT_VM_RELOAD)
			wep:SendWeaponAnim(ACT_VM_RELOAD)
			LocalPlayer():SetAnimation(PLAYER_RELOAD)
		end
		
		addy = addy + 20
		
		local m1btn = vgui.Create( "DButton", ptool )
		m1btn:SetPos( 10, addy )
		m1btn:SetSize( 120, 18 )
		m1btn:SetText( "Melee 1" )
		m1btn.DoClick = function()
			RunConsoleCommand("swepck_playanimation", ACT_VM_MISSCENTER)
			wep:SendWeaponAnim(ACT_VM_MISSCENTER)
			LocalPlayer():SetAnimation(PLAYER_ATTACK1)
		end
		
		local m2btn = vgui.Create( "DButton", ptool )
		m2btn:SetPos( 140, addy )
		m2btn:SetSize( 120, 18 )
		m2btn:SetText( "Melee 2" )
		m2btn.DoClick = function()
			RunConsoleCommand("swepck_playanimation", ACT_VM_HITCENTER)
			wep:SendWeaponAnim(ACT_VM_HITCENTER)
			LocalPlayer():SetAnimation(PLAYER_ATTACK1)
		end
		
		addy = addy + 20
		
		local gcbtn = vgui.Create( "DButton", ptool )
		gcbtn:SetPos( 10, addy )
		gcbtn:SetSize( 120, 18 )
		gcbtn:SetText( "Grenade pull (CSS)" )
		gcbtn.DoClick = function()
			RunConsoleCommand("swepck_playanimation", ACT_VM_PULLPIN)
			wep:SendWeaponAnim(ACT_VM_PULLPIN)
		end
		
		local ghbtn = vgui.Create( "DButton", ptool )
		ghbtn:SetPos( 140, addy )
		ghbtn:SetSize( 120, 18 )
		ghbtn:SetText( "Grenade pull (HL2)" )
		ghbtn.DoClick = function()
			RunConsoleCommand("swepck_playanimation", ACT_VM_PULLBACK_HIGH)
			wep:SendWeaponAnim(ACT_VM_PULLBACK_HIGH)
		end
		
		addy = addy + 20
		
		local wdbtn = vgui.Create( "DButton", ptool )
		wdbtn:SetPos( 10, addy )
		wdbtn:SetSize( 120, 18 )
		wdbtn:SetText( "Draw" )
		wdbtn.DoClick = function()
			RunConsoleCommand("swepck_playanimation", ACT_VM_DRAW)
			wep:SendWeaponAnim(ACT_VM_DRAW)
		end
		
		local tgbtn = vgui.Create( "DButton", ptool )
		tgbtn:SetPos( 140, addy )
		tgbtn:SetSize( 120, 18 )
		tgbtn:SetText( "Throw grenade" )
		tgbtn.DoClick = function()
			RunConsoleCommand("swepck_playanimation", ACT_VM_THROW)
			wep:SendWeaponAnim(ACT_VM_THROW)
			LocalPlayer():SetAnimation(PLAYER_ATTACK1)
		end
		
		addy = addy + 20
		
		local idlbtn = vgui.Create( "DButton", ptool )
		idlbtn:SetPos( 10, addy )
		idlbtn:SetSize( 120, 18 )
		idlbtn:SetText( "Idle" )
		idlbtn.DoClick = function()
			RunConsoleCommand("swepck_playanimation", ACT_VM_IDLE)
			wep:SendWeaponAnim(ACT_VM_IDLE)
		end
		
		addy = addy + 45
		
		// ***** Settings saving / loading *****
		local note_x = 10
		local note_y = addy + 75
		
		local function CreateSettingsNote( text )
			local templabel = vgui.Create( "DLabel" )
			templabel:SetText( text )
			templabel:SetSize( 260, 20 )

			local notif = vgui.Create( "DNotify" , ptool )
			notif:SetPos( note_x, note_y )
			notif:SetSize( 260, 20 )
			notif:SetLife( 5 )
			notif:AddItem(templabel)
		end
		
		local selabel = vgui.Create( "DLabel", ptool )
		selabel:SetPos( 10, addy )
		selabel:SetSize( 200, 20 )
		selabel:SetText( "Configuration:" )
		
		addy = addy + 25
		
		local satext = vgui.Create( "DTextEntry", ptool)
		satext:SetPos( 95, addy )
		satext:SetSize( 170, 20 )
		satext:SetMultiline(false)
		satext:SetText( "save1" )
		
		local sabtn = vgui.Create( "DButton", ptool )
		sabtn:SetPos( 10, addy )
		sabtn:SetSize( 80, 20 )
		sabtn:SetText( "Save as:" )
		sabtn.DoClick = function()
		
		if !IsValid(wep) then return end
				
		local text = string.Trim(satext:GetValue())
		if (text == "") then return end
			
			local save_data = wep.save_data
			
			// collect all save data
			save_data.v_models = table.Copy(wep.v_models)
			save_data.w_models = table.Copy(wep.w_models)
			save_data.v_bonemods = table.Copy(wep.v_bonemods)
			// remove caches
			for k, v in pairs(save_data.v_models) do
				v.createdModel = nil
				v.createdSprite = nil
			end
			for k, v in pairs(save_data.w_models) do
				v.createdModel = nil
				v.createdSprite = nil
			end
			save_data.ViewModelFlip = wep.ViewModelFlip
			save_data.ViewModel = wep.ViewModel
			save_data.CurWorldModel = wep.CurWorldModel
			save_data.ViewModelFOV = wep.ViewModelFOV
			save_data.HoldType = wep.HoldType
			save_data.IronSightsEnabled = wep:GetIronSights()
			save_data.IronSightsPos, save_data.IronSightsAng = wep:GetIronSightCoordination()
			save_data.ShowViewModel = wep.ShowViewModel
			save_data.ShowWorldModel = wep.ShowWorldModel
			
			local filename = "swep_construction_kit/"..text..".txt"
			
			local succ, val = pcall(Serialize, save_data)
			if (!succ) then LocalPlayer():ChatPrint("Failed to encode settings!") return end
			
			file.Write(filename, val)
			LocalPlayer():ChatPrint("Saved file \""..text.."\"!")
		end
		
		addy = addy + 25
		
		local lftext = vgui.Create( "DTextEntry", ptool)
		lftext:SetPos( 95, addy )
		lftext:SetSize( 170, 20 )
		lftext:SetMultiline(false)
		lftext:SetText( "save1" )
		
		local lfbtn = vgui.Create( "DButton", ptool )
		lfbtn:SetPos( 10, addy )
		lfbtn:SetSize( 80, 20 )
		lfbtn:SetText( "Load file:" )
		lfbtn.DoClick = function()
		local text = string.Trim(lftext:GetValue())
		if (text == "") then return end
			
			local filename = "swep_construction_kit/"..text..".txt"
			
			if (!file.Exists (filename, "DATA")) then
				CreateSettingsNote( "No such file exists!" )
				return
			end
			
			local data = file.Read(filename, "DATA")
			local succ, new_preset = pcall(Deserialize, data)
			if (!succ) then LocalPlayer():ChatPrint("Failed to load settings!") return end
			
			wep:CleanMenu()
			wep:OpenMenu( new_preset )
			LocalPlayer():ChatPrint("Loaded file \""..text.."\"!")
		end
		
		// link to FP thread
		
		addy = addy + 45
		
		local threadbtn = vgui.Create( "DButton", ptool )
		threadbtn:SetPos( 10, addy )
		threadbtn:SetSize( 240, 20 )
		threadbtn:SetText( "View Facepunch thread & tutorial" )
		threadbtn.DoClick = function()
			gui.OpenURL(tutorialURL)
		end
		
		/*local alabel = vgui.Create( "DLabel", ptool )
		alabel:SetPos( 10, addy )
		alabel:SetSize( 240, 20 )
		alabel:SetText( "Link to tool tutorial (copy-paste to browser):" )
		
		addy = addy + 25
		
		local tutltext = vgui.Create( "DTextEntry", ptool)
		tutltext:SetPos( 10, addy )
		tutltext:SetSize( 240, 20 )
		tutltext:SetMultiline(false)
		tutltext:SetEditable(true)
		tutltext:SetText( "http://tinyurl.com/swepkit" )
		*/
		
		/*****************
			Weapon page
		*****************/
		local addy = 10
		
		local next_v_model = ""
		
		// Weapon model
		local vlabel = vgui.Create( "DLabel", pweapon )
		vlabel:SetPos( 10, addy )
		vlabel:SetSize( 80, 20 )
		vlabel:SetText( "View model:" )
		
		local vtext = vgui.Create( "DTextEntry", pweapon)
		vtext:SetPos( 85, addy )
		vtext:SetSize( 160, 20 )
		vtext:SetMultiline(false)
		vtext.OnTextChanged = function()
			local newmod = string.gsub(vtext:GetValue(), ".mdl", "")
			RunConsoleCommand("swepck_viewmodel", newmod)
			
			// clear view model additions
			if (newmod != next_v_model and file.Exists(newmod..".mdl", "GAME")) then
				next_v_model = newmod
				ClearViewModels()
				RefreshViewModelBoneMods()
			end
			
		end
		vtext:SetText( wep.save_data.ViewModel )
		vtext:OnTextChanged()
		
		local vtbtn = vgui.Create( "DButton", pweapon )
		vtbtn:SetPos( 245, addy )
		vtbtn:SetSize( 20, 20 )
		vtbtn:SetText("...")
		vtbtn.DoClick = function()
			OpenBrowser( wep.ViewModel, "model", function( val ) vtext:SetText(val) vtext:OnTextChanged() end )
		end
		
		addy = addy + 25
		
		local wlabel = vgui.Create( "DLabel", pweapon )
		wlabel:SetPos( 10, addy )
		wlabel:SetSize( 80, 20 )
		wlabel:SetText( "World model:" )
		
		local wtext = vgui.Create( "DTextEntry", pweapon)
		wtext:SetPos( 85, addy )
		wtext:SetSize( 160, 20 )
		wtext:SetMultiline(false)
		wtext.OnTextChanged = function()
			local newmod = string.gsub(wtext:GetValue(), ".mdl", "")
			RunConsoleCommand("swepck_worldmodel", newmod)
			
			// clear world model additions
			if (newmod != wep.cur_wmodel) then
				ClearWorldModels()
			end
			
		end
		wtext:SetText( wep.save_data.CurWorldModel )
		wtext:OnTextChanged()
		
		local wtbtn = vgui.Create( "DButton", pweapon )
		wtbtn:SetPos( 245, addy )
		wtbtn:SetSize( 20, 20 )
		wtbtn:SetText("...")
		wtbtn.DoClick = function()
			OpenBrowser( wep.CurWorldModel, "model", function( val ) wtext:SetText(val) wtext:OnTextChanged() end )
		end
		
		addy = addy + 30
		
		// Weapon hold type
		local hlabel = vgui.Create( "DLabel", pweapon )
		hlabel:SetPos( 10, addy )
		hlabel:SetSize( 150, 20 )
		hlabel:SetText( "Hold type (3rd person):" )
		
		local hbox = vgui.Create( "DComboBox", pweapon )
		hbox:SetPos( 140, addy )
		hbox:SetSize( 125, 20 )
		for k, v in pairs( wep:GetHoldTypes() ) do
			hbox:AddChoice( v )
		end
		hbox.OnSelect = function(panel,index,value)
			if (!value) then return end
			wep:SetWeaponHoldType( value )
			wep.HoldType = value
			RunConsoleCommand("swepck_setholdtype", value)
		end
		hbox:SetText( wep.save_data.HoldType )
		hbox.OnSelect( nil, nil, wep.save_data.HoldType )
		
		addy = addy + 30
		
		// Show viewmodel
		local vhbox = vgui.Create( "DCheckBoxLabel", pweapon )
		vhbox:SetPos( 10, addy )
		vhbox:SetSize( 150, 20 )
		vhbox:SetText( "Show view model" )
		vhbox.OnChange = function()
			wep.ShowViewModel = vhbox:GetChecked()
			if (wep.ShowViewModel) then
				LocalPlayer():GetViewModel():SetColor(Color(255,255,255,255))
			else
				LocalPlayer():GetViewModel():SetColor(Color(255,255,255,1)) // we set the alpha to 1 because else ViewModelDrawn stops being called
			end
		end
		if (wep.save_data.ShowViewModel) then vhbox:SetValue(1)
		else vhbox:SetValue(0) end
		
		addy = addy + 30
		
		// Show worldmodel
		local whbox = vgui.Create( "DCheckBoxLabel", pweapon )
		whbox:SetPos( 10, addy )
		whbox:SetSize( 150, 20 )
		whbox:SetText( "Show world model" )
		whbox.OnChange = function()
			wep.ShowWorldModel = whbox:GetChecked()
		end
		if (wep.save_data.ShowWorldModel) then whbox:SetValue(1)
		else whbox:SetValue(0) end
		
		addy = addy + 30
		
		// Flip viewmodel
		local fcbox = vgui.Create( "DCheckBoxLabel", pweapon )
		fcbox:SetPos( 10, addy )
		fcbox:SetSize( 150, 20 )
		fcbox:SetText( "Flip viewmodel" )
		fcbox.OnChange = function()
			wep.ViewModelFlip = fcbox:GetChecked()
		end
		if (wep.save_data.ViewModelFlip) then fcbox:SetValue(1)
		else fcbox:SetValue(0) end
		
		addy = addy + 30
		
		// View model FOV slider
		local fovslider = vgui.Create( "DNumSlider", pweapon )
		fovslider:SetPos( 10, addy )
		fovslider:SetWide( 260 )
		fovslider:SetText( "View model FOV" )
		fovslider:SetMin( 20 )
		fovslider:SetMax( 140 )
		fovslider:SetDecimals( 0 )
		fovslider.OnValueChanged = function( panel, value )
			wep.ViewModelFOV = tonumber(value)
			RunConsoleCommand("swepck_viewmodelfov", value)
		end
		fovslider:SetValue( wep.save_data.ViewModelFOV )
		
		addy = addy + 50
		
		// View model bone scaling
		local vsbonelabel = vgui.Create( "DLabel", pweapon )
		vsbonelabel:SetPos( 10, addy )
		vsbonelabel:SetSize( 250, 20 )
		vsbonelabel:SetText( "Viewmodel bone mods:" )
		
		if (!wep.save_data.v_bonemods) then
			wep.save_data.v_bonemods = {}
		end
				
		// backwards compatability with old bone scales
		if (wep.save_data.v_bonescales) then
			for k, v in pairs(wep.save_data.v_bonescales) do
				if (v == Vector(1,1,1)) then continue end
				wep.save_data.v_bonemods[k] = { scale = v, pos = Vector(0,0,0), angle = Angle(0,0,0) }
			end
		end
		wep.save_data.v_bonescales = nil
		
		local curbone = table.GetFirstKey(wep.save_data.v_bonemods)
		if (curbone) then
			wep.v_bonemods = table.Copy(wep.save_data.v_bonemods)
		else
			curbone = ""
			wep.v_bonemods = {}
		end
		
		local resbtn = vgui.Create( "DButton", pweapon )
		resbtn:SetPos( 180, addy )
		resbtn:SetSize( 90, 20 )
		resbtn:SetText("Reset all")
		
		addy = addy + 25
		
		local vsbonebox = vgui.Create( "DComboBox", pweapon )
		vsbonebox:SetPos( 10, addy )
		vsbonebox:SetSize( 140, 20 )
		
		local resselbtn = vgui.Create( "DButton", pweapon )
		resselbtn:SetPos( 180, addy )
		resselbtn:SetSize( 90, 20 )
		resselbtn:SetText("Reset selected")
		
		addy = addy + 25
		
		local bonepanely = addy
		
		local function CreateBoneMod( selbone, x, y, preset_data )
			
			local data = wep.v_bonemods[selbone]
			if (!preset_data) then preset_data = {} end
			
			data.scale = preset_data.scale or Vector(1,1,1)
			data.pos = preset_data.pos or Vector(0,0,0)
			data.angle = preset_data.angle or Angle(0,0,0)
			
			local bonepanel = vgui.Create( "DPanel", pweapon )
			bonepanel:SetPos( x, y )
			bonepanel:SetSize( 260, 110 )
			bonepanel:SetVisible( true )
			bonepanel:SetPaintBackground( true )
			bonepanel.Paint = function() surface.SetDrawColor( 70, 70, 70, 255 ) surface.DrawRect( 0, 0, bonepanel:GetWide(), bonepanel:GetTall() ) end
			
			local rely = 0
			
			local vslabel = vgui.Create( "DLabel", bonepanel )
			vslabel:SetPos( 5, 8 + rely )
			vslabel:SetText( "Scale" )
			vslabel:SizeToContents()
			vslabel:SetTall( 24 )
			
			local vsxwang = vgui.Create( "DNumberWang", bonepanel )
			vsxwang:SetPos( 90, 8 + rely ) vsxwang:SetSize( 52, 24 ) vsxwang:SetMinMax( 0.01, 3 ) vsxwang:SetDecimals( 3 ) // look at me ma, I'm saving space!
			local areavx = vsxwang:GetTextArea()
			areavx.OnTextChanged = function() vsxwang:SetValue(tonumber(areavx:GetValue())) end
			
			local vsywang = vgui.Create( "DNumberWang", bonepanel )
			vsywang:SetPos( 145, 10 + rely ) vsywang:SetSize( 50, 20 ) vsywang:SetMinMax( 0.01, 3 ) vsywang:SetDecimals( 3 )
			vsywang.OnValueChanged = function( p, value ) 
				if (selbone != "") then wep.v_bonemods[selbone].scale.y = tonumber(value) end
			end
			local areavy = vsywang:GetTextArea()
			areavy.OnTextChanged = function() vsywang:SetValue(tonumber(areavy:GetValue())) end
			
			local vszwang = vgui.Create( "DNumberWang", bonepanel )
			vszwang:SetPos( 200, 10 + rely ) vszwang:SetSize( 50, 20 ) vszwang:SetMinMax( 0.01, 3 ) vszwang:SetDecimals( 3 )
			vszwang.OnValueChanged = function( p, value ) 
				if (selbone != "") then wep.v_bonemods[selbone].scale.z = tonumber(value) end 
			end
			local areavz = vszwang:GetTextArea()
			areavz.OnTextChanged = function() vszwang:SetValue(tonumber(areavz:GetValue())) end

			// make the x numberwang set the total size
			vsxwang.OnValueChanged = function( p, value )
				if (selbone == "") then return end
				vszwang:SetValue( value )
				vsywang:SetValue( value )
				wep.v_bonemods[selbone].scale.x = tonumber(value)
			end
			
			rely = rely + 30
			
			local vposlabel = vgui.Create( "DLabel", bonepanel )
			vposlabel:SetPos( 5, 8 + rely )
			vposlabel:SetText( "Pos" )
			vposlabel:SizeToContents()
			vposlabel:SetTall( 24 )
			
			local vposxwang = vgui.Create( "DNumberWang", bonepanel )
			vposxwang:SetPos( 90, 10 + rely ) vposxwang:SetSize( 52, 20 ) vposxwang:SetMinMax( -30, 30 ) vposxwang:SetDecimals( 3 ) // look at me ma, I'm saving space!
			vposxwang.OnValueChanged = function( p, value )
				if (selbone != "") then wep.v_bonemods[selbone].pos.x = tonumber(value) end
			end
			local areaposvx = vposxwang:GetTextArea()
			areaposvx.OnTextChanged = function() vposxwang:SetValue(tonumber(areaposvx:GetValue())) end
			
			local vposywang = vgui.Create( "DNumberWang", bonepanel )
			vposywang:SetPos( 145, 10 + rely ) vposywang:SetSize( 50, 20 ) vposywang:SetMinMax( -30, 30 ) vposywang:SetDecimals( 3 )
			vposywang.OnValueChanged = function( p, value ) 
				if (selbone != "") then wep.v_bonemods[selbone].pos.y = tonumber(value) end
			end
			local areaposvy = vposywang:GetTextArea()
			areaposvy.OnTextChanged = function() vposywang:SetValue(tonumber(areaposvy:GetValue())) end
			
			local vposzwang = vgui.Create( "DNumberWang", bonepanel )
			vposzwang:SetPos( 200, 10 + rely ) vposzwang:SetSize( 50, 20 ) vposzwang:SetMinMax( -30, 30 ) vposzwang:SetDecimals( 3 )
			vposzwang.OnValueChanged = function( p, value ) 
				if (selbone != "") then wep.v_bonemods[selbone].pos.z = tonumber(value) end 
			end
			local areaposvz = vposzwang:GetTextArea()
			areaposvz.OnTextChanged = function() vposzwang:SetValue(tonumber(areaposvz:GetValue())) end

			rely = rely + 30
			
			local vanglabel = vgui.Create( "DLabel", bonepanel )
			vanglabel:SetPos( 5, 8 + rely )
			vanglabel:SetText( "Angle" )
			vanglabel:SizeToContents()
			vanglabel:SetTall( 24 )
			
			local vangxwang = vgui.Create( "DNumberWang", bonepanel )
			vangxwang:SetPos( 90, 10 + rely ) vangxwang:SetSize( 52, 20 ) vangxwang:SetMinMax( -180, 180 ) vangxwang:SetDecimals( 3 ) // look at me ma, I'm saving space!
			vangxwang.OnValueChanged = function( p, value )
				if (selbone != "") then wep.v_bonemods[selbone].angle.p = tonumber(value) end
			end
			local areaangvx = vangxwang:GetTextArea()
			areaangvx.OnTextChanged = function() vangxwang:SetValue(tonumber(areaangvx:GetValue())) end
			
			local vangywang = vgui.Create( "DNumberWang", bonepanel )
			vangywang:SetPos( 145, 10 + rely ) vangywang:SetSize( 50, 20 ) vangywang:SetMinMax( -180, 180 ) vangywang:SetDecimals( 3 )
			vangywang.OnValueChanged = function( p, value ) 
				if (selbone != "") then wep.v_bonemods[selbone].angle.y = tonumber(value) end
			end
			local areaangvy = vangywang:GetTextArea()
			areaangvy.OnTextChanged = function() vangywang:SetValue(tonumber(areaangvy:GetValue())) end
			
			local vangzwang = vgui.Create( "DNumberWang", bonepanel )
			vangzwang:SetPos( 200, 10 + rely ) vangzwang:SetSize( 50, 20 ) vangzwang:SetMinMax( -180, 180 ) vangzwang:SetDecimals( 3 )
			vangzwang.OnValueChanged = function( p, value ) 
				if (selbone != "") then wep.v_bonemods[selbone].angle.r = tonumber(value) end 
			end
			local areaangvz = vangzwang:GetTextArea()
			areaangvz.OnTextChanged = function() vangzwang:SetValue(tonumber(areaangvz:GetValue())) end
			
			vsxwang:SetValue( data.scale.x )
			vsywang:SetValue( data.scale.y )
			vszwang:SetValue( data.scale.z )
			
			vposxwang:SetValue( data.pos.x )
			vposywang:SetValue( data.pos.y )
			vposzwang:SetValue( data.pos.z )
			
			vangxwang:SetValue( data.angle.p )
			vangywang:SetValue( data.angle.y )
			vangzwang:SetValue( data.angle.r )
			
			return bonepanel
		end
		
		local cur_bonepanel
		
		vsbonebox.OnSelect = function( p, index, value )
			local selbone = value
			if (!selbone or selbone == "") then return end
			
			if (!wep.v_bonemods[selbone]) then
				wep.v_bonemods[selbone] = { scale = Vector(1,1,1), pos = Vector(0,0,0), angle = Angle(0,0,0) }
			end
			
			if (cur_bonepanel) then 
				cur_bonepanel:Remove()
				cur_bonepanel = nil
			end
			
			cur_bonepanel = CreateBoneMod( selbone, 10, bonepanely, wep.v_bonemods[selbone])
			curbone = selbone
		end
		vsbonebox:SetText( curbone )
		vsbonebox.OnSelect( vsbonebox, 1, curbone ) 
			
		timer.Simple(2, function()
			local option = PopulateBoneList( vsbonebox, LocalPlayer():GetViewModel() )
			if (option and curbone == "") then 
				vsbonebox:ChooseOptionID(1)
			end
		end)
			
		resbtn.DoClick = function()
			wep.v_bonemods = {}
			if (curbone == "") then return end
			
			wep.v_bonemods[curbone] = { scale = Vector(1,1,1), pos = Vector(0,0,0), angle = Angle(0,0,0) }
			
			if (cur_bonepanel) then 
				cur_bonepanel:Remove() 
				cur_bonepanel = nil 
			end
			
			cur_bonepanel = CreateBoneMod( curbone, 10, bonepanely, wep.v_bonemods[curbone])
		end
		
		resselbtn.DoClick = function()
			
			if (curbone == "") then return end
			wep.v_bonemods[curbone] = { scale = Vector(1,1,1), pos = Vector(0,0,0), angle = Angle(0,0,0) }
			
			if (cur_bonepanel) then 
				cur_bonepanel:Remove() 
				cur_bonepanel = nil 
			end
			
			cur_bonepanel = CreateBoneMod( curbone, 10, bonepanely, wep.v_bonemods[curbone])
		end
		
		wep.v_modelbonebox = vsbonebox
		
		addy = addy + 130
		
		local wpbtn = vgui.Create( "DButton", pweapon )
		wpbtn:SetPos( 10, addy )
		wpbtn:SetSize( 260, 30 )
		wpbtn:SetText( "Print weapon code to console" )
		wpbtn.DoClick = function()
			MsgN("*********************************************")
			for k, v in pairs(string.Explode("\n",GetWeaponPrintText(wep))) do
				MsgN(v)
			end
			MsgN("*********************************************")
			LocalPlayer():ChatPrint("Code printed to console!")
		end
		
		addy = addy + 35
		
		local wpcbtn = vgui.Create( "DButton", pweapon )
		wpcbtn:SetPos( 10, addy )
		wpcbtn:SetSize( 260, 30 )
		wpcbtn:SetText( "Copy weapon code to clipboard" )
		wpcbtn.DoClick = function()
			SetClipboardText(GetWeaponPrintText(wep))
			LocalPlayer():ChatPrint("Code copied to clipboard!")
		end
		
		addy = addy + 35
		
		local wpdbtn = vgui.Create( "DButton", pweapon )
		wpdbtn:SetPos( 10, addy )
		wpdbtn:SetSize( 260, 30 )
		wpdbtn:SetText( "Drop weapon (hold reload key to pick back up)" )
		wpdbtn.DoClick = function()
			RunConsoleCommand("swepck_dropwep")
		end
		
		/*********************
			Ironsights page
		*********************/
		addy = 10
		
		local icbox = vgui.Create( "DCheckBoxLabel", pironsight )
		icbox:SetPos( 10, addy )
		icbox:SetSize( 150, 20 )
		icbox:SetText( "Enable ironsights" )
		icbox.OnChange = function()
			if (wep:GetIronSights() != icbox:GetChecked()) then
				RunConsoleCommand("swepck_toggleironsights")
			end
		end
		if (wep.save_data.IronSightsEnabled) then icbox:SetValue(1)
		else icbox:SetValue(0) end
	
		local ribtn = vgui.Create( "DButton", pironsight )
		ribtn:SetPos( 140, addy )
		ribtn:SetSize( 125, 20 )
		ribtn:SetText( "Reset ironsights" )
		ribtn.DoClick = function()
			wep:ResetIronSights()
		end

		addy = addy + 30
		
		local modlabel = vgui.Create( "DLabel", pironsight )
		modlabel:SetPos( 10, addy )
		modlabel:SetSize( 100, 20 )
		modlabel:SetText( "Drag mode:" )
		
		local drbox = vgui.Create( "DComboBox", pironsight )
		drbox:SetPos( 140, addy )
		drbox:SetSize( 125, 20 )
		drbox:SetText( wep.cur_drag_mode )
		for k, v in pairs( drag_modes ) do
			drbox:AddChoice( k )
		end
		drbox.OnSelect = function(panel,index,value)
			local modes = drag_modes[value]
			wep.cur_drag_mode = value
			for k, v in pairs( wep.ir_drag ) do
				v[1] = table.HasValue( modes, k ) // set the drag modus
			end
		end
		
		addy = addy + 30
		
		local ixslider = vgui.Create( "DNumSlider", pironsight )
		ixslider:SetPos( 10, addy )
		ixslider:SetWide( 260 )
		ixslider:SetText( "Translate x" )
		ixslider:SetMin( -20 )
		ixslider:SetMax( 20 )
		ixslider:SetDecimals( 3 )
		ixslider:SetConVar( "_sp_ironsight_x" )
		ixslider:SetValue( wep.save_data.IronSightsPos.x )
		local areaix = ixslider:GetTextArea()
		areaix.OnTextChanged = function() RunConsoleCommand("_sp_ironsight_x",areaix:GetValue()) end
			
		addy = addy + 45
		
		local iyslider = vgui.Create( "DNumSlider", pironsight )
		iyslider:SetPos( 10, addy )
		iyslider:SetWide( 260 )
		iyslider:SetText( "Translate y" )
		iyslider:SetMin( -20 )
		iyslider:SetMax( 20 )
		iyslider:SetDecimals( 3 )
		iyslider:SetConVar( "_sp_ironsight_y" )
		iyslider:SetValue( wep.save_data.IronSightsPos.y )
		local areaiy = iyslider:GetTextArea()
		areaiy.OnTextChanged = function() RunConsoleCommand("_sp_ironsight_y",areaiy:GetValue()) end
		
		addy = addy + 45
		
		local izslider = vgui.Create( "DNumSlider", pironsight )
		izslider:SetPos( 10, addy )
		izslider:SetWide( 260 )
		izslider:SetText( "Translate z" )
		izslider:SetMin( -20 )
		izslider:SetMax( 20 )
		izslider:SetDecimals( 3 )
		izslider:SetConVar( "_sp_ironsight_z" )
		izslider:SetValue( wep.save_data.IronSightsPos.z )
		local areaiz = izslider:GetTextArea()
		areaiz.OnTextChanged = function() RunConsoleCommand("_sp_ironsight_z",areaiz:GetValue()) end
		
		addy = addy + 45
		
		local ipslider = vgui.Create( "DNumSlider", pironsight )
		ipslider:SetPos( 10, addy )
		ipslider:SetWide( 260 )
		ipslider:SetText( "Rotate pitch" )
		ipslider:SetMin( -70 )
		ipslider:SetMax( 70 )
		ipslider:SetDecimals( 3 )
		ipslider:SetConVar( "_sp_ironsight_pitch" )
		ipslider:SetValue( wep.save_data.IronSightsAng.x )
		local areaip = ipslider:GetTextArea()
		areaip.OnTextChanged = function() RunConsoleCommand("_sp_ironsight_pitch",areaip:GetValue()) end
		
		addy = addy + 45
		
		local iyaslider = vgui.Create( "DNumSlider", pironsight )
		iyaslider:SetPos( 10, addy )
		iyaslider:SetWide( 260 )
		iyaslider:SetText( "Rotate yaw" )
		iyaslider:SetMin( -70 )
		iyaslider:SetMax( 70 )
		iyaslider:SetDecimals( 3 )
		iyaslider:SetConVar( "_sp_ironsight_yaw" )
		iyaslider:SetValue( wep.save_data.IronSightsAng.y )
		local areaiya = iyaslider:GetTextArea()
		areaiya.OnTextChanged = function() RunConsoleCommand("_sp_ironsight_yaw",areaiya:GetValue()) end
		
		addy = addy + 45
		
		local irslider = vgui.Create( "DNumSlider", pironsight )
		irslider:SetPos( 10, addy )
		irslider:SetWide( 260 )
		irslider:SetText( "Rotate roll" )
		irslider:SetMin( -70 )
		irslider:SetMax( 70 )
		irslider:SetDecimals( 3 )
		irslider:SetConVar( "_sp_ironsight_roll" )
		irslider:SetValue( wep.save_data.IronSightsAng.z )
		local areair = irslider:GetTextArea()
		areair.OnTextChanged = function() RunConsoleCommand("_sp_ironsight_roll",areair:GetValue()) end
		
		addy = addy + 45
		
		local prbtn = vgui.Create( "DButton", pironsight )
		prbtn:SetPos( 10, addy )
		prbtn:SetSize( 260, 30 )
		prbtn:SetText( "Print ironsights code to console" )
		prbtn.DoClick = function()
			local vec, ang = wep:GetIronSightCoordination()
			MsgN("*********************************************")
			MsgN(GetIronSightPrintText( vec, ang ))
			MsgN("*********************************************")
			LocalPlayer():ChatPrint("Code printed to console!")
		end
		
		addy = addy + 35
		
		local pcbtn = vgui.Create( "DButton", pironsight )
		pcbtn:SetPos( 10, addy )
		pcbtn:SetSize( 260, 30 )
		pcbtn:SetText( "Copy ironsights code to clipboard" )
		pcbtn.DoClick = function()
			local vec, ang = wep:GetIronSightCoordination()
			SetClipboardText(GetIronSightPrintText( vec, ang ))
			LocalPlayer():ChatPrint("Code copied to clipboard!")
		end
		
		/*********************
			Models page
		*********************/
		addy = 10
		
		local lastVisible = ""
		local mlist = vgui.Create( "DListView", pmodels)
		wep.v_modelListing = mlist

		local mlabel = vgui.Create( "DLabel", pmodels )
		mlabel:SetPos( 10, addy )
		mlabel:SetSize( 130, 20 )
		mlabel:SetText( "New viewmodel element:" )
		
		local function CreateNote( text )
			local templabel = vgui.Create( "DLabel" )
			templabel:SetText( text )
			templabel:SetSize( 120, 20 )

			local notif = vgui.Create( "DNotify" , pmodels )
			notif:SetPos( 140, 10 )
			notif:SetSize( 120, 20 )
			notif:SetLife( 5 )
			notif:AddItem(templabel)
			
		end
		
		addy = addy + 25
		
		local mntext = vgui.Create("DTextEntry", pmodels )
		mntext:SetPos( 10, addy )
		mntext:SetSize( 120, 20 )
		mntext:SetMultiline(false)
		mntext:SetText( "some_unique_name" )
		
		local tpbox = vgui.Create( "DComboBox", pmodels )
		tpbox:SetPos( 130, addy )
		tpbox:SetSize( 85, 20 )
		tpbox:SetText( "Model" )
		tpbox:AddChoice( "Model" )
		tpbox:AddChoice( "Sprite" )
		tpbox:AddChoice( "Quad" )
		local boxselected = "Model"
		tpbox.OnSelect = function( p, index, value )
			boxselected = value
		end
		
		local mnbtn = vgui.Create( "DButton", pmodels )
		mnbtn:SetPos( 220, addy )
		mnbtn:SetSize( 45, 20 )
		mnbtn:SetText( "Add" )

		addy = addy + 30
		
		mlist:SetPos( 10, addy )
		mlist:SetSize( 260, 120 )
		mlist:SetMultiSelect(false)
		mlist:SetDrawBackground(true)
		mlist:AddColumn("Name")
		mlist:AddColumn("Type")
		// cache the created panels
		mlist.OnRowSelected = function( panel, line )
			local name = mlist:GetLine(line):GetValue(1)
			
			local posx, posy = wep.v_panelCache[name]:GetPos()

			if (wep.v_panelCache[lastVisible]) then
				wep.v_panelCache[lastVisible]:SetVisible(false)
			end
			wep.v_panelCache[name]:SetVisible(true)
			
			lastVisible = name
		end
		
		addy = addy + 125
		
		local rmbtn = vgui.Create( "DButton", pmodels )
		rmbtn:SetPos( 10, addy )
		rmbtn:SetSize( 130, 25 )
		rmbtn:SetText( "Remove selected" )
		
		local copybtn = vgui.Create( "DButton", pmodels )
		copybtn:SetPos( 145, addy )
		copybtn:SetSize( 125, 25 )
		copybtn:SetText( "Copy selected" )
		
		addy = addy + 30
		
		local function CreatePositionModifiers( data, addy, panel )
			
			local trlabel = vgui.Create( "DLabel", panel )
			trlabel:SetPos( 5, addy )
			trlabel:SetSize( 80, 20 )
			trlabel:SetText( "Pos x/y/z:" )
			
			local mxwang = vgui.Create( "DNumberWang", panel )
			mxwang:SetPos( 90, addy )
			mxwang:SetSize( 50, 20 )
			mxwang:SetMin( -30 )
			mxwang:SetMax( 30 )
			mxwang:SetDecimals( 3 )
			mxwang.OnValueChanged = function( p, value ) data.pos.x = tonumber(value) end
			mxwang:SetValue( data.pos.x )
			local areax = mxwang:GetTextArea()
			areax.OnTextChanged = function() mxwang:SetValue(tonumber(areax:GetValue())) end
			
			local mywang = vgui.Create( "DNumberWang", panel )
			mywang:SetPos( 145, addy )
			mywang:SetSize( 50, 20 )
			mywang:SetMin( -30 )
			mywang:SetMax( 30 )
			mywang:SetDecimals( 3 )
			mywang.OnValueChanged = function( p, value ) data.pos.y = tonumber(value) end
			mywang:SetValue( data.pos.y )
			local areay = mywang:GetTextArea()
			areay.OnTextChanged = function() mywang:SetValue(tonumber(areay:GetValue())) end
			
			local mzwang = vgui.Create( "DNumberWang", panel )
			mzwang:SetPos( 200, addy )
			mzwang:SetSize( 50, 20 )
			mzwang:SetMin( -30 )
			mzwang:SetMax( 30 )
			mzwang:SetDecimals( 3 )
			mzwang.OnValueChanged = function( p, value ) data.pos.z = tonumber(value) end
			mzwang:SetValue( data.pos.z )
			local areaz = mzwang:GetTextArea()
			areaz.OnTextChanged = function() mzwang:SetValue(tonumber(areaz:GetValue())) end
		
		end
		
		local function CreateAngleModifiers( data, addy, panel )
		
			local anlabel = vgui.Create( "DLabel", panel )
			anlabel:SetPos( 5, addy )
			anlabel:SetSize( 80, 20 )
			anlabel:SetText( "Angle p/y/r:" )
			
			local mpitchwang = vgui.Create( "DNumberWang", panel )
			mpitchwang:SetPos( 90, addy )
			mpitchwang:SetSize( 50, 20 )
			mpitchwang:SetMin( -180 )
			mpitchwang:SetMax( 180 )
			mpitchwang:SetDecimals( 3 )
			mpitchwang.OnValueChanged = function( p, value ) data.angle.p = tonumber(value) end
			mpitchwang:SetValue( data.angle.p )
			local areap = mpitchwang:GetTextArea()
			areap.OnTextChanged = function() mpitchwang:SetValue(tonumber(areap:GetValue())) end
			
			local myawwang = vgui.Create( "DNumberWang", panel )
			myawwang:SetPos( 145, addy )
			myawwang:SetSize( 50, 20 )
			myawwang:SetMin( -180 )
			myawwang:SetMax( 180 )
			myawwang:SetDecimals( 3 )
			myawwang.OnValueChanged = function( p, value ) data.angle.y = tonumber(value) end
			myawwang:SetValue( data.angle.y )
			local areay = myawwang:GetTextArea()
			areay.OnTextChanged = function() myawwang:SetValue(tonumber(areay:GetValue())) end
			
			local mrollwang = vgui.Create( "DNumberWang", panel )
			mrollwang:SetPos( 200, addy )
			mrollwang:SetSize( 50, 20 )
			mrollwang:SetMin( -180 )
			mrollwang:SetMax( 180 )
			mrollwang:SetDecimals( 3 )
			mrollwang.OnValueChanged = function( p, value ) data.angle.r = tonumber(value) end
			mrollwang:SetValue( data.angle.r )
			local arear = mrollwang:GetTextArea()
			arear.OnTextChanged = function() mrollwang:SetValue(tonumber(arear:GetValue())) end
			
		end
		
		local function CreateSizeModifiers( data, addy, panel, dimensions )

			local sizelabel = vgui.Create( "DLabel", panel )
			sizelabel:SetPos( 5, addy )
			sizelabel:SetSize( 80, 20 )
			
			if (dimensions == 2) then
				sizelabel:SetText( "Size (xy)/y:" )
			elseif ( dimensions == 3 ) then
				sizelabel:SetText( "Size (xyz)/y/z:" )
			else
				sizelabel:SetText( "Size:" )
			end
			
			local msxwang = vgui.Create( "DNumberWang", panel )
			msxwang:SetPos( 90, addy-2 )
			msxwang:SetSize( 52, 24 )
			msxwang:SetMin( 0.01 )
			msxwang:SetMax( 10 )
			msxwang:SetDecimals( 3 )
			local areasx = msxwang:GetTextArea()
			areasx.OnTextChanged = function() msxwang:SetValue(tonumber(areasx:GetValue())) end
			
			local msywang, mszwang

			if (dimensions > 1 ) then
			
				msywang = vgui.Create( "DNumberWang", panel )
				msywang:SetPos( 145, addy )
				msywang:SetSize( 50, 20 )
				msywang:SetMin( 0.01 )
				msywang:SetMax( 10 )
				msywang:SetDecimals( 3 )
				msywang.OnValueChanged = function( p, value ) data.size.y = tonumber(value) end
				local areasy = msywang:GetTextArea()
				areasy.OnTextChanged = function() msywang:SetValue(tonumber(areasy:GetValue())) end

				if (dimensions > 2) then
					mszwang = vgui.Create( "DNumberWang", panel )
					mszwang:SetPos( 200, addy )
					mszwang:SetSize( 50, 20 )
					mszwang:SetMin( 0.01 )
					mszwang:SetMax( 10 )
					mszwang:SetDecimals( 3 )
					mszwang.OnValueChanged = function( p, value ) data.size.z = tonumber(value) end
					local areasz = mszwang:GetTextArea()
					areasz.OnTextChanged = function() mszwang:SetValue(tonumber(areasz:GetValue())) end
				end
			
			end
			
			// make the x numberwang set the total size
			msxwang.OnValueChanged = function( p, value )
				if (mszwang) then
					mszwang:SetValue( value )
				end
				if (msywang) then
					msywang:SetValue( value )
				end
				
				if (dimensions > 1) then
					data.size.x = tonumber(value)
				else
					data.size = tonumber(value)
				end
			end
			
			if (dimensions == 1) then
				
				msxwang:SetValue( data.size )
				
			else
			
				local new_y = data.size.y
				local new_z = data.size.z
				
				msxwang:SetValue( data.size.x )
				msywang:SetValue( new_y )
				if (mszwang) then
					mszwang:SetValue( new_z )
				end
				
			end
			
		end
		
		local function CreateColorModifiers( data, addy, panel )
		
			local collabel = vgui.Create( "DLabel", panel )
			collabel:SetPos( 5, addy )
			collabel:SetSize( 80, 20 )
			collabel:SetText( "Color r/g/b/a:" )
			
			local colrwang = vgui.Create( "DNumberWang", panel )
			colrwang:SetPos( 90, addy )
			colrwang:SetSize( 38, 20 )
			colrwang:SetMin( 0 )
			colrwang:SetMax( 255 )
			colrwang:SetDecimals( 0 )
			colrwang.OnValueChanged = function( p, value ) data.color.r = tonumber(value) end
			colrwang:SetValue(data.color.r)
			local arear = colrwang:GetTextArea()
			arear.OnTextChanged = function() colrwang:SetValue(tonumber(arear:GetValue())) end
			
			local colgwang = vgui.Create( "DNumberWang", panel )
			colgwang:SetPos( 130, addy )
			colgwang:SetSize( 38, 20 )
			colgwang:SetMin( 0 )
			colgwang:SetMax( 255 )
			colgwang:SetDecimals( 0 )
			colgwang.OnValueChanged = function( p, value ) data.color.g = tonumber(value) end
			colgwang:SetValue(data.color.g)
			local areag = colgwang:GetTextArea()
			areag.OnTextChanged = function() colgwang:SetValue(tonumber(areag:GetValue())) end
			
			local colbwang = vgui.Create( "DNumberWang", panel )
			colbwang:SetPos( 170, addy )
			colbwang:SetSize( 38, 20 )
			colbwang:SetMin( 0 )
			colbwang:SetMax( 255 )
			colbwang:SetDecimals( 0 )
			colbwang.OnValueChanged = function( p, value ) data.color.b = tonumber(value) end
			colbwang:SetValue(data.color.b)
			local areab = colbwang:GetTextArea()
			areab.OnTextChanged = function() colbwang:SetValue(tonumber(areab:GetValue())) end
			
			local colawang = vgui.Create( "DNumberWang", panel )
			colawang:SetPos( 210, addy )
			colawang:SetSize( 40, 20 )
			colawang:SetMin( 0 )
			colawang:SetMax( 255 )
			colawang:SetDecimals( 0 )
			colawang.OnValueChanged = function( p, value ) data.color.a = tonumber(value) end
			colawang:SetValue(data.color.a)
			local areaa = colawang:GetTextArea()
			areaa.OnTextChanged = function() colawang:SetValue(tonumber(areaa:GetValue())) end
			
		end
		
		local function CreateModelModifier( data, addy, panel )
		
			local pmolabel = vgui.Create( "DLabel", panel )
			pmolabel:SetPos( 5, addy )
			pmolabel:SetSize( 80, 20 )
			pmolabel:SetText( "Model:" )
			
			local pmmtext = vgui.Create( "DTextEntry", panel )
			pmmtext:SetPos( 60, addy )
			pmmtext:SetSize( 170, 20 )
			pmmtext:SetMultiline(false)
			pmmtext:SetToolTip("Path to the model file")
			pmmtext.OnTextChanged = function()
				local newmod = pmmtext:GetValue()
				if file.Exists (newmod, "GAME") then
					util.PrecacheModel(newmod)
					data.model = newmod
				end
			end
			pmmtext:SetText( data.model )
			pmmtext.OnTextChanged()
			
			local wtbtn = vgui.Create( "DButton", panel )
			wtbtn:SetPos( 230, addy )
			wtbtn:SetSize( 20, 20 )
			wtbtn:SetText("...")
			wtbtn.DoClick = function()
				OpenBrowser( data.model, "model", function( val ) pmmtext:SetText(val) pmmtext:OnTextChanged() end )
			end
			
		end
		
		local function CreateSpriteModifier( data, addy, panel )
		
			local pmolabel = vgui.Create( "DLabel", panel )
			pmolabel:SetPos( 5, addy )
			pmolabel:SetSize( 80, 20 )
			pmolabel:SetText( "Sprite:" )
			
			local pmmtext = vgui.Create( "DTextEntry", panel )
			pmmtext:SetPos( 60, addy )
			pmmtext:SetSize( 170, 20 )
			pmmtext:SetMultiline(false)
			pmmtext:SetToolTip("Path to the sprite material")
			pmmtext.OnTextChanged = function()
				local newsprite = pmmtext:GetValue()
				if file.Exists ("materials/"..newsprite..".vmt", "GAME") then
					data.sprite = newsprite
				end
			end
			pmmtext:SetText( data.sprite )
			pmmtext.OnTextChanged()
			
			local wtbtn = vgui.Create( "DButton", panel )
			wtbtn:SetPos( 230, addy )
			wtbtn:SetSize( 20, 20 )
			wtbtn:SetText("...")
			wtbtn.DoClick = function()
				OpenBrowser( data.sprite, "material", function( val ) pmmtext:SetText(val) pmmtext:OnTextChanged() end )
			end
			
			
		end
		
		local function CreateNameLabel( name, addy, panel )
			
			local pnmlabel = vgui.Create( "DLabel", panel )
			pnmlabel:SetPos( 5, addy )
			pnmlabel:SetSize( 80, 20 )
			pnmlabel:SetText( "Name:" )
			
			local pnmtext = vgui.Create( "DTextEntry", panel )
			pnmtext:SetPos( 60, addy )
			pnmtext:SetSize( 190, 20 )
			pnmtext:SetMultiline(false)
			pnmtext:SetText( name )
			pnmtext:SetEditable( false )
			
		end
		
		local function CreateParamModifiers( data, addy, panel )
		
			local ncchbox = vgui.Create( "DCheckBoxLabel", panel )
			ncchbox:SetPos( 5, addy )
			ncchbox:SetSize( 120, 20 )
			ncchbox:SetText("$nocull")
			ncchbox:SetValue( 0 )
			ncchbox.OnChange = function()
				data.nocull = ncchbox:GetChecked()
				data.spriteMaterial = nil // dump old material
			end
			if (data.nocull) then ncchbox:SetValue( 1 ) end
			
			local adchbox = vgui.Create( "DCheckBoxLabel", panel )
			adchbox:SetPos( 140, addy )
			adchbox:SetSize( 120, 20 )
			adchbox:SetText("$additive")
			adchbox:SetValue( 0 )
			adchbox.OnChange = function()
				data.additive = adchbox:GetChecked()
				data.spriteMaterial = nil // dump old material
			end
			if (data.additive) then adchbox:SetValue( 1 ) end
			
			addy = addy + 22
			
			local vtachbox = vgui.Create( "DCheckBoxLabel", panel )
			vtachbox:SetPos( 5, addy )
			vtachbox:SetSize( 120, 20 )
			vtachbox:SetText("$vertexalpha")
			vtachbox:SetValue( 0 )
			vtachbox.OnChange = function()
				data.vertexalpha = vtachbox:GetChecked()
				data.spriteMaterial = nil // dump old material
			end
			if (data.vertexalpha) then vtachbox:SetValue( 1 ) end
			
			local vtcchbox = vgui.Create( "DCheckBoxLabel", panel )
			vtcchbox:SetPos( 140, addy )
			vtcchbox:SetSize( 120, 20 )
			vtcchbox:SetText("$vertexcolor")
			vtcchbox:SetValue( 0 )
			vtcchbox.OnChange = function()
				data.vertexcolor = vtcchbox:GetChecked()
				data.spriteMaterial = nil // dump old material
			end
			if (data.vertexcolor) then vtcchbox:SetValue( 1 ) end
			
			addy = addy + 22
			
			local izchbox = vgui.Create( "DCheckBoxLabel", panel )
			izchbox:SetPos( 5, addy )
			izchbox:SetSize( 120, 20 )
			izchbox:SetText("$ignorez")
			izchbox:SetValue( 0 )
			izchbox.OnChange = function()
				data.ignorez = izchbox:GetChecked()
				data.spriteMaterial = nil // dump old material
			end
			if (data.ignorez) then izchbox:SetValue( 1 ) end
			
		end
		
		local function CreateMaterialModifier( data, addy, panel )
		
			local matlabel = vgui.Create( "DLabel", panel )
			matlabel:SetPos( 5, addy )
			matlabel:SetSize( 80, 20 )
			matlabel:SetText( "Material:" )

			local mattext = vgui.Create("DTextEntry", panel )
			mattext:SetPos( 90, addy )
			mattext:SetSize( 140, 20 )
			mattext:SetMultiline(false)
			mattext:SetToolTip("Path to the material file")
			mattext.OnTextChanged = function()
				local newmat = mattext:GetValue()
				if file.Exists ("materials/"..newmat..".vmt", "GAME") then
					data.material = newmat
				else
					data.material = ""
				end
			end
			mattext:SetText( data.material )
			
			local wtbtn = vgui.Create( "DButton", panel )
			wtbtn:SetPos( 230, addy )
			wtbtn:SetSize( 20, 20 )
			wtbtn:SetText("...")
			wtbtn.DoClick = function()
				OpenBrowser( data.material, "material", function( val ) mattext:SetText(val) mattext:OnTextChanged() end )
			end
			
		end
		
		local function CreateSLightningModifier( data, addy, panel )
		
			local lschbox = vgui.Create( "DCheckBoxLabel", panel )
			lschbox:SetPos( 5, addy )
			lschbox:SetSize( 200, 20 )
			lschbox:SetText("Surpress engine lightning")
			lschbox.OnChange = function()
				data.surpresslightning = lschbox:GetChecked()
			end
			if (data.surpresslightning) then
				lschbox:SetValue( 1 )
			else
				lschbox:SetValue( 0 )
			end
			
		end
		
		local function CreateBoneModifier( data, addy, panel, ent )
			
			local pbonelabel = vgui.Create( "DLabel", panel )
			pbonelabel:SetPos( 5, addy )
			pbonelabel:SetSize( 80, 20 )
			pbonelabel:SetText( "Bone:" )
			
			local bonebox = vgui.Create( "DComboBox", panel )
			bonebox:SetPos( 60, addy )
			bonebox:SetSize( 190, 20 )
			bonebox:SetToolTip("Bone to parent the selected element to. Is ignored if the 'Relative' field is not empty")
			bonebox.OnSelect = function( p, index, value )
				data.bone = value
			end
			bonebox:SetText( data.bone )
			
			local delay = 0
			// we have to call it later when loading settings because the viewmodel needs to be changed first
			if (data.bone != "") then delay = 2 end
			
			timer.Simple(delay, function()
				local option = PopulateBoneList( bonebox, ent )
				if (option and data.bone == "") then 
					bonebox:ChooseOptionID(1)
				end
			end)
			
		end
		
		local function CreateRelativeModifier( data, addy, panel )
			
			local prellabel = vgui.Create( "DLabel", panel )
			prellabel:SetPos( 5, addy )
			prellabel:SetSize( 80, 20 )
			prellabel:SetText( "Relative:" )
			
			local reltext = vgui.Create( "DTextEntry", panel )
			reltext:SetPos( 60, addy )
			reltext:SetSize( 190, 20 )
			reltext:SetMultiline(false)
			reltext:SetToolTip("Name of the element you want to parent this element to. Overrides parenting to a bone. Clear field to use bone as parent again")
			reltext.OnTextChanged = function()
				data.rel = reltext:GetValue()
			end
			reltext:SetText( data.rel )
			
		end
		
		local function CreateBodygroupSkinModifier( data, addy, panel )
		
			local addx = 5
		
			local bdlabel = vgui.Create( "DLabel", panel )
			bdlabel:SetPos( addx, addy )
			bdlabel:SetSize( 80, 20 )
			bdlabel:SetText( "Bodygroup:" )
			
			addx = addx + 85
			
			local bdwang = vgui.Create( "DNumberWang", panel )
			bdwang:SetPos( addx, addy )
			bdwang:SetSize( 30, 20 )
			bdwang:SetMin( 1 )
			bdwang:SetMax( 9 )
			bdwang:SetDecimals( 0 )
			bdwang:SetToolTip("Bodygroup number")
			local areabd = bdwang:GetTextArea()
			areabd.OnTextChanged = function() bdwang:SetValue(tonumber(areabd:GetValue())) end
			
			addx = addx + 30
			
			local islabel = vgui.Create( "DLabel", panel )
			islabel:SetPos( addx+2, addy )
			islabel:SetSize( 10, 20 )
			islabel:SetText( "=" )
			
			addx = addx + 10
			
			local bdvwang = vgui.Create( "DNumberWang", panel )
			bdvwang:SetPos( addx, addy )
			bdvwang:SetSize( 30, 20 )
			bdvwang:SetMin( 0 )
			bdvwang:SetMax( 9 )
			bdvwang:SetDecimals( 0 )
			bdvwang:SetToolTip("State number")
			local areabdv = bdvwang:GetTextArea()
			areabdv.OnTextChanged = function() bdvwang:SetValue(tonumber(areabdv:GetValue())) end
			
			bdvwang.OnValueChanged = function( p, value ) 
				local group = tonumber(bdwang:GetValue())
				local val = tonumber(value)
				data.bodygroup[group] = val
			end
			bdvwang:SetValue(0)

			bdwang.OnValueChanged = function( p, value )
				local group = tonumber(value)
				if (group < 1) then return end
				local setval = data.bodygroup[group] or 0
				bdvwang:SetValue(setval)
			end
			bdwang:SetValue(1)

			addx = addx + 50
			
			local sklabel = vgui.Create( "DLabel", panel )
			sklabel:SetPos( addx, addy )
			sklabel:SetSize( 40, 20 )
			sklabel:SetText( "Skin:" )
			
			addx = addx + 40
			
			local skwang = vgui.Create( "DNumberWang", panel )
			skwang:SetPos( addx, addy )
			skwang:SetSize( 30, 20 )
			skwang:SetMin( 0 )
			skwang:SetMax( 9 )
			skwang:SetDecimals( 0 )
			skwang.OnValueChanged = function( p, value ) data.skin = tonumber(value) end
			skwang:SetValue(data.skin)
			local areask = skwang:GetTextArea()
			areask.OnTextChanged = function() skwang:SetValue(tonumber(areask:GetValue())) end
			
		end
		
		
		local panely = addy
		local panelh = 580 - panely - 60
		/*** Model panel for adjusting models ***
		Name:
		Model:
		Bone name:
		Translation x / y / z
		Rotation pitch / yaw / role
		Model size x / y / z
		Material
		Color modulation
		*/
		local function CreateModelPanel( name, x, y, preset_data )
			
			local data = wep.v_models[name]
			if (!preset_data) then preset_data = {} end
			
			// default data
			data.type = preset_data.type or "Model"
			data.model = preset_data.model or ""
			data.bone = preset_data.bone or ""
			data.rel = preset_data.rel or ""
			data.pos = preset_data.pos or Vector(0,0,0)
			data.angle = preset_data.angle or Angle(0,0,0)
			data.size = preset_data.size or Vector(0.5,0.5,0.5)
			data.color = preset_data.color or Color(255,255,255,255)
			data.surpresslightning = preset_data.surpresslightning or false
			data.material = preset_data.material or ""
			data.bodygroup = preset_data.bodygroup or {}
			data.skin = preset_data.skin or 0
			
			wep.vRenderOrder = nil // force viewmodel render order to recache
			
			local panel = vgui.Create( "DPanel", pmodels )
			panel:SetPos( x, y )
			panel:SetSize( 260, panelh )
			panel:SetPaintBackground( true )
			panel.Paint = function() surface.SetDrawColor( 70, 70, 70, 255 ) surface.DrawRect( 0, 0, panel:GetWide(), panel:GetTall() ) end
			
			local addy = 5
			
			CreateNameLabel( name, addy, panel )
			
			addy = addy + 25
			
			CreateModelModifier( data, addy, panel )
			
			addy = addy + 25
			
			CreateBoneModifier( data, addy, panel, LocalPlayer():GetViewModel() )
			
			addy = addy + 25
			
			CreateRelativeModifier( data, addy, panel )
			
			addy = addy + 25
			
			CreatePositionModifiers( data, addy, panel )
			
			addy = addy + 25

			CreateAngleModifiers( data, addy, panel )
			
			addy = addy + 25

			CreateSizeModifiers( data, addy, panel, 3 )
			
			addy = addy + 25
			
			CreateColorModifiers( data, addy, panel )
			
			addy = addy + 25
			
			CreateSLightningModifier( data, addy, panel )
			
			addy = addy + 22
			
			CreateMaterialModifier( data, addy, panel )
			
			addy = addy + 25
			
			CreateBodygroupSkinModifier( data, addy, panel )
			
			return panel
			
		end
		
		/*** Sprite panel for adjusting sprites ***
		Name:
		Sprite:
		Bone name:
		Translation x / y / z
		Sprite x / y size
		Color
		*/
		local function CreateSpritePanel( name, x, y, preset_data )
			
			local data = wep.v_models[name]
			if (!preset_data) then preset_data = {} end
			
			// default data
			data.type = preset_data.type or "Sprite"
			data.sprite = preset_data.sprite or ""
			data.bone = preset_data.bone or ""
			data.rel = preset_data.rel or ""
			data.pos = preset_data.pos or Vector(0,0,0)
			data.size = preset_data.size or { x = 1, y = 1 }
			data.color = preset_data.color or Color(255,255,255,255)
			data.nocull = preset_data.nocull or true
			data.additive = preset_data.additive or true
			data.vertexalpha = preset_data.vertexalpha or true
			data.vertexcolor = preset_data.vertexcolor or true
			data.ignorez = preset_data.ignorez or false
			
			wep.vRenderOrder = nil
			
			local panel = vgui.Create( "DPanel", pmodels )
			panel:SetPos( x, y )
			panel:SetSize( 260, panelh )
			panel:SetPaintBackground( true )
			panel.Paint = function() surface.SetDrawColor( 70, 70, 70, 255 ) surface.DrawRect( 0, 0, panel:GetWide(), panel:GetTall() ) end
			
			local addy = 5
			
			CreateNameLabel( name, addy, panel )
			
			addy = addy + 25
			
			CreateSpriteModifier( data, addy, panel )
			
			addy = addy + 25
			
			CreateBoneModifier( data, addy, panel, LocalPlayer():GetViewModel() )
			
			addy = addy + 25
			
			CreateRelativeModifier( data, addy, panel )
			
			addy = addy + 25

			CreatePositionModifiers( data, addy, panel )
			
			addy = addy + 25

			CreateSizeModifiers( data, addy, panel, 2 )

			addy = addy + 25
			
			CreateColorModifiers( data, addy, panel )
			
			addy = addy + 25
			
			CreateParamModifiers( data, addy, panel )
			
			return panel
			
		end
		
		/*** Model panel for adjusting models ***
		Name:
		Model:
		Bone name:
		Translation x / y / z
		Rotation pitch / yaw / role
		Size
		*/
		local function CreateQuadPanel( name, x, y, preset_data )
			
			local data = wep.v_models[name]
			if (!preset_data) then preset_data = {} end
			
			// default data
			data.type = preset_data.type or "Quad"
			data.model = preset_data.model or ""
			data.bone = preset_data.bone or ""
			data.rel = preset_data.rel or ""
			data.pos = preset_data.pos or Vector(0,0,0)
			data.angle = preset_data.angle or Angle(0,0,0)
			data.size = preset_data.size or 0.05

			wep.vRenderOrder = nil // force viewmodel render order to recache
			
			local panel = vgui.Create( "DPanel", pmodels )
			panel:SetPos( x, y )
			panel:SetSize( 260, panelh )
			panel:SetPaintBackground( true )
			panel.Paint = function() surface.SetDrawColor( 70, 70, 70, 255 ) surface.DrawRect( 0, 0, panel:GetWide(), panel:GetTall() ) end
			
			local addy = 5
			
			CreateNameLabel( name, addy, panel )
			
			addy = addy + 25
			
			CreateBoneModifier( data, addy, panel, LocalPlayer():GetViewModel() )
			
			addy = addy + 25
			
			CreateRelativeModifier( data, addy, panel )
			
			addy = addy + 25
			
			CreatePositionModifiers( data, addy, panel )
			
			addy = addy + 25

			CreateAngleModifiers( data, addy, panel )
			
			addy = addy + 25

			CreateSizeModifiers( data, addy, panel, 1 )
			
			return panel
			
		end
		
		// adding button DoClick
		mnbtn.DoClick = function()
			local new = string.Trim( mntext:GetValue() )
			if (new) then
				if (new == "") then CreateNote("Empty name field!") return end
				if (wep.v_models[new] != nil) then CreateNote("Name already exists!") return end
				wep.v_models[new] = {}
				
				if (!wep.v_panelCache[new]) then
					if (boxselected == "Model") then
						wep.v_panelCache[new] = CreateModelPanel( new, 10, panely )
					elseif (boxselected == "Sprite") then
						wep.v_panelCache[new] = CreateSpritePanel( new, 10, panely )
					elseif (boxselected == "Quad") then
						wep.v_panelCache[new] = CreateQuadPanel( new, 10, panely )
					else
						error("wtf are u doing")
					end
				end
				
				wep.v_panelCache[new]:SetVisible(false)
				
				mlist:AddLine(new,boxselected)
			end
		end
		
		for k, v in pairs( wep.save_data.v_models ) do
			wep.v_models[k] = {}
			if (v.type == "Model") then
				wep.v_panelCache[k] = CreateModelPanel( k, 10, panely, v )
			elseif (v.type == "Sprite") then
				wep.v_panelCache[k] = CreateSpritePanel( k, 10, panely, v )
			elseif (v.type == "Quad") then
				wep.v_panelCache[k] = CreateQuadPanel( k, 10, panely, v )
			end
			wep.v_panelCache[k]:SetVisible(false)
			mlist:AddLine(k,v.type)
		
		end

		local prtbtn = vgui.Create( "DButton", pmodels)
		prtbtn:SetPos( 10, 525 )
		prtbtn:SetSize( 260, 20 )
		prtbtn:SetText("Print view model table to console")
		prtbtn.DoClick = function()
			MsgN("*********************************************")
			for k, v in pairs(string.Explode("\n",GetVModelsText())) do
				MsgN(v)
			end
			MsgN("*********************************************")
			LocalPlayer():ChatPrint("Code printed to console!")
		end
		
		local pctbtn = vgui.Create( "DButton", pmodels)
		pctbtn:SetPos( 10, 550 )
		pctbtn:SetSize( 260, 20 )
		pctbtn:SetText("Copy view model table to clipboard")
		pctbtn.DoClick = function()
			SetClipboardText(GetVModelsText())
			LocalPlayer():ChatPrint("Code copied to clipboard!")
		end
		
		// remove a line
		rmbtn.DoClick = function()
			local line = mlist:GetSelectedLine()
			if (line) then
				local name = mlist:GetLine(line):GetValue(1)
				wep.v_models[name] = nil
				// clear from panel cache
				if (wep.v_panelCache[name]) then 
					wep.v_panelCache[name]:Remove()
					wep.v_panelCache[name] = nil
				end
				mlist:RemoveLine(line)
			end
		end
		
		// duplicate line
		copybtn.DoClick = function()
			local line = mlist:GetSelectedLine()
			if (line) then
				local name = mlist:GetLine(line):GetValue(1)
				local to_copy = wep.v_models[name]
				local new_preset = table.Copy(to_copy)
				
				// quickly generate a new unique name
				while(wep.v_models[name]) do
					name = name.."+"
				end
				
				// have to fix every sub-table as well because table.Copy copies references
				new_preset.pos = Vector(to_copy.pos.x, to_copy.pos.y, to_copy.pos.z)
				if (to_copy.angle) then
					new_preset.angle = Angle(to_copy.angle.p, to_copy.angle.y, to_copy.angle.r)
				end
				if (to_copy.color) then
					new_preset.color = Color(to_copy.color.r,to_copy.color.g,to_copy.color.b,to_copy.color.a)
				end
				if (type(to_copy.size) == "table") then
					new_preset.size = table.Copy(to_copy.size)
				elseif (type(to_copy.size) == "Vector") then
					new_preset.size = Vector(to_copy.size.x, to_copy.size.y, to_copy.size.z)
				end
				if (to_copy.bodygroup) then
					new_preset.bodygroup = table.Copy(to_copy.bodygroup)
				end
				
				wep.v_models[name] = {}
				
				if (new_preset.type == "Model") then
					wep.v_panelCache[name] = CreateModelPanel( name, 10, panely, new_preset )
				elseif (new_preset.type == "Sprite") then
					wep.v_panelCache[name] = CreateSpritePanel( name, 10, panely, new_preset )
				elseif (new_preset.type == "Quad") then
					wep.v_panelCache[name] = CreateQuadPanel( name, 10, panely, new_preset )
				end
				
				wep.v_panelCache[name]:SetVisible(false)
				mlist:AddLine(name,new_preset.type)
			end
		end
		
		/*********************
			World models page
		*********************/
		addy = 10
		
		local lastVisible = ""
		local mwlist = vgui.Create( "DListView", pwmodels)
		wep.w_modelListing = mwlist
		
		local mlabel = vgui.Create( "DLabel", pwmodels )
		mlabel:SetPos( 10, addy )
		mlabel:SetSize( 130, 20 )
		mlabel:SetText( "New worldmodel element:" )
		
		local function CreateWNote( text )
			local templabel = vgui.Create( "DLabel" )
			templabel:SetText( text )
			templabel:SetSize( 120, 20 )

			local notif = vgui.Create( "DNotify" , pwmodels )
			notif:SetPos( 140, 10 )
			notif:SetSize( 120, 20 )
			notif:SetLife( 5 )
			notif:AddItem(templabel)
		end
		
		addy = addy + 25
		
		local mnwtext = vgui.Create("DTextEntry", pwmodels )
		mnwtext:SetPos( 10, addy )
		mnwtext:SetSize( 120, 20 )
		mnwtext:SetMultiline(false)
		mnwtext:SetText( "some_unique_name" )
		
		local tpbox = vgui.Create( "DComboBox", pwmodels )
		tpbox:SetPos( 130, addy )
		tpbox:SetSize( 85, 20 )
		tpbox:SetText( "Model" )
		tpbox:AddChoice( "Model" )
		tpbox:AddChoice( "Sprite" )
		tpbox:AddChoice( "Quad" )
		local wboxselected = "Model"
		tpbox.OnSelect = function( p, index, value )
			wboxselected = value
		end
		
		local mnwbtn = vgui.Create( "DButton", pwmodels )
		mnwbtn:SetPos( 220, addy )
		mnwbtn:SetSize( 45, 20 )
		mnwbtn:SetText( "Add" )
		
		addy = addy + 30
		
		mwlist:SetPos( 10, addy )
		mwlist:SetSize( 260, 125 )
		mwlist:SetMultiSelect(false)
		mwlist:SetDrawBackground(true)
		mwlist:AddColumn("Name")
		mwlist:AddColumn("Type")
		// cache the created panels
		mwlist.OnRowSelected = function( panel, line )
			local name = mwlist:GetLine(line):GetValue(1)
			
			if (wep.w_panelCache[lastVisible]) then
				wep.w_panelCache[lastVisible]:SetVisible(false)
			end
			wep.w_panelCache[name]:SetVisible(true)
			
			lastVisible = name
		end
		
		addy = addy + 130
		
		local importbtn = vgui.Create( "DButton", pwmodels )
		importbtn:SetPos( 10, addy )
		importbtn:SetSize( 260, 20 )
		importbtn:SetText( "Import viewmodels" )
		
		addy = addy + 25
		
		local rmbtn = vgui.Create( "DButton", pwmodels )
		rmbtn:SetPos( 10, addy )
		rmbtn:SetSize( 130, 20 )
		rmbtn:SetText( "Remove selected" )
		
		local copybtn = vgui.Create( "DButton", pwmodels )
		copybtn:SetPos( 145, addy )
		copybtn:SetSize( 125, 20 )
		copybtn:SetText( "Copy selected" )
		
		addy = addy + 25
		
		local panely = addy
		local panelh = 580 - panely - 60
		
		/*** Model panel for adjusting models ***
		Name:
		Model:
		Translation x / y / z
		Rotation pitch / yaw / role
		Model size x / y / z
		Material
		Color modulation
		*/
		local function CreateWorldModelPanel( name, x, y, preset_data )
			
			local data = wep.w_models[name]
			if (!preset_data) then preset_data = {} end
			
			// default data
			data.type = preset_data.type or "Model"
			data.model = preset_data.model or ""
			data.bone = preset_data.bone or "ValveBiped.Bip01_R_Hand"
			data.rel = preset_data.rel or ""
			data.pos = preset_data.pos or Vector(0,0,0)
			data.angle = preset_data.angle or Angle(0,0,0)
			data.size = preset_data.size or Vector(0.5,0.5,0.5)
			data.color = preset_data.color or Color(255,255,255,255)
			data.surpresslightning = preset_data.surpresslightning or false
			data.material = preset_data.material or ""
			data.bodygroup = preset_data.bodygroup or {}
			data.skin = preset_data.skin or 0
			
			wep.wRenderOrder = nil
			
			local panel = vgui.Create( "DPanel", pwmodels )
			panel:SetPos( x, y )
			panel:SetSize( 260, panelh )
			panel:SetPaintBackground( true )
			panel.Paint = function() surface.SetDrawColor( 70, 70, 70, 255 ) surface.DrawRect( 0, 0, panel:GetWide(), panel:GetTall() ) end
			
			local addy = 5
			
			CreateNameLabel( name, addy, panel )
			
			addy = addy + 25
			
			CreateModelModifier( data, addy, panel )
			
			addy = addy + 25

			CreateBoneModifier( data, addy, panel, LocalPlayer() )
			
			addy = addy + 25
			
			CreateRelativeModifier( data, addy, panel )
			
			addy = addy + 25
			
			CreatePositionModifiers( data, addy, panel )
			
			addy = addy + 25

			CreateAngleModifiers( data, addy, panel )
			
			addy = addy + 25

			CreateSizeModifiers( data, addy, panel, 3 )
			
			addy = addy + 25
			
			CreateColorModifiers( data, addy, panel )
			
			addy = addy + 25
			
			CreateSLightningModifier( data, addy, panel )
			
			addy = addy + 22
			
			CreateMaterialModifier( data, addy, panel )
			
			addy = addy + 25
			
			CreateBodygroupSkinModifier( data, addy, panel )
			
			return panel
			
		end
		
		/*** Sprite panel for adjusting sprites ***
		Name:
		Sprite:
		Translation x / y / z
		Sprite x / y size
		Color
		*/
		local function CreateWorldSpritePanel( name, x, y, preset_data )
			
			local data = wep.w_models[name]
			if (!preset_data) then preset_data = {} end
			
			// default data
			data.type = preset_data.type or "Sprite"
			data.sprite = preset_data.sprite or ""
			data.bone = preset_data.bone or "ValveBiped.Bip01_R_Hand"
			data.rel = preset_data.rel or ""
			data.pos = preset_data.pos or Vector(0,0,0)
			data.size = preset_data.size or { x = 1, y = 1 }
			data.color = preset_data.color or Color(255,255,255,255)
			data.nocull = preset_data.nocull or true
			data.additive = preset_data.additive or true
			data.vertexalpha = preset_data.vertexalpha or true
			data.vertexcolor = preset_data.vertexcolor or true
			data.ignorez = preset_data.ignorez or false
			
			wep.wRenderOrder = nil
			
			local panel = vgui.Create( "DPanel", pwmodels )
			panel:SetPos( x, y )
			panel:SetSize( 260, panelh )
			panel:SetPaintBackground( true )
			panel.Paint = function() surface.SetDrawColor( 70, 70, 70, 255 ) surface.DrawRect( 0, 0, panel:GetWide(), panel:GetTall() ) end
			
			local addy = 5
			
			CreateNameLabel( name, addy, panel )
			
			addy = addy + 25
			
			CreateSpriteModifier( data, addy, panel )
			
			addy = addy + 25
			
			CreateBoneModifier( data, addy, panel, LocalPlayer() )
			
			addy = addy + 25
			
			CreateRelativeModifier( data, addy, panel )
			
			addy = addy + 25
			
			CreatePositionModifiers( data, addy, panel )
			
			addy = addy + 25

			CreateSizeModifiers( data, addy, panel, 2 )

			addy = addy + 25
			
			CreateColorModifiers( data, addy, panel )
			
			addy = addy + 25
			
			CreateParamModifiers( data, addy, panel )
			
			return panel
			
		end
		
		/*** Model panel for adjusting models ***
		Name:
		Model:
		Bone name:
		Translation x / y / z
		Rotation pitch / yaw / role
		Size
		*/
		local function CreateWorldQuadPanel( name, x, y, preset_data )
			
			local data = wep.w_models[name]
			if (!preset_data) then preset_data = {} end
			
			// default data
			data.type = preset_data.type or "Quad"
			data.model = preset_data.model or ""
			data.bone = preset_data.bone or "ValveBiped.Bip01_R_Hand"
			data.rel = preset_data.rel or ""
			data.pos = preset_data.pos or Vector(0,0,0)
			data.angle = preset_data.angle or Angle(0,0,0)
			data.size = preset_data.size or 0.05

			wep.vRenderOrder = nil // force viewmodel render order to recache
			
			local panel = vgui.Create( "DPanel", pwmodels )
			panel:SetPos( x, y )
			panel:SetSize( 260, panelh )
			panel:SetPaintBackground( true )
			panel.Paint = function() surface.SetDrawColor( 70, 70, 70, 255 ) surface.DrawRect( 0, 0, panel:GetWide(), panel:GetTall() ) end
			
			local addy = 5
			
			CreateNameLabel( name, addy, panel )
			
			addy = addy + 25
			
			CreateBoneModifier( data, addy, panel, LocalPlayer() )
			
			addy = addy + 25
			
			CreateRelativeModifier( data, addy, panel )
			
			addy = addy + 25
			
			CreatePositionModifiers( data, addy, panel )
			
			addy = addy + 25

			CreateAngleModifiers( data, addy, panel )
			
			addy = addy + 25

			CreateSizeModifiers( data, addy, panel, 1 )
			
			return panel
			
		end
		
		// adding button DoClick
		mnwbtn.DoClick = function()
			local new = string.Trim( mnwtext:GetValue() )
			if (new) then
				if (new == "") then CreateWNote("Empty name field!") return end
				if (wep.w_models[new] != nil) then CreateWNote("Name already exists!") return end
				wep.w_models[new] = {}
				
				if (!wep.w_panelCache[new]) then
					if (wboxselected == "Model") then
						wep.w_panelCache[new] = CreateWorldModelPanel( new, 10, panely )
					elseif (wboxselected == "Sprite") then
						wep.w_panelCache[new] = CreateWorldSpritePanel( new, 10, panely )
					elseif (wboxselected == "Quad") then
						wep.w_panelCache[new] = CreateWorldQuadPanel( new, 10, panely )
					else
						error("wtf are u doing")
					end
				end
				
				wep.w_panelCache[new]:SetVisible(false)
				
				mwlist:AddLine(new,wboxselected)
			end
		end
		
		for k, v in pairs( wep.save_data.w_models ) do
			wep.w_models[k] = {}
			
			// backwards compatability
			if (!v.bone or v.bone == "") then
				v.bone = "ValveBiped.Bip01_R_Hand"
			end
			
			if (v.type == "Model") then
				wep.w_panelCache[k] = CreateWorldModelPanel( k, 10, panely, v )
			elseif (v.type == "Sprite") then
				wep.w_panelCache[k] = CreateWorldSpritePanel( k, 10, panely, v )
			elseif (v.type == "Quad") then
				wep.w_panelCache[k] = CreateWorldQuadPanel( k, 10, panely, v )
			end			
			wep.w_panelCache[k]:SetVisible(false)
			mwlist:AddLine(k,v.type)
		
		end
		
		local prtbtn = vgui.Create( "DButton", pwmodels)
		prtbtn:SetPos( 10, 525 )
		prtbtn:SetSize( 260, 20 )
		prtbtn:SetText("Print world model table to console")
		prtbtn.DoClick = function()
			MsgN("*********************************************")
			for k, v in pairs(string.Explode("\n",GetWModelsText())) do
				MsgN(v)
			end
			MsgN("*********************************************")
			LocalPlayer():ChatPrint("Code printed to console!")
		end
		
		local pctbtn = vgui.Create( "DButton", pwmodels)
		pctbtn:SetPos( 10, 550 )
		pctbtn:SetSize( 260, 20 )
		pctbtn:SetText("Copy world model table to clipboard")
		pctbtn.DoClick = function()
			SetClipboardText(GetWModelsText())
			LocalPlayer():ChatPrint("Code copied to clipboard!")
		end
		
		// import viewmodels
		importbtn.DoClick = function()
			local num = 0
			for k, v in pairs( wep.v_models ) do
				local name = k
				local i = 1
				while(wep.w_models[name] != nil) do
					name = k..""..i
					i = i + 1
					
					// changing names might mess up the relative transitions of some stuff
					// but whatever.
				end
				
				local new_preset = table.Copy(v)
				new_preset.bone = "ValveBiped.Bip01_R_Hand" // switch to hand bone by default
				
				if (new_preset.rel and new_preset.rel != "") then
					new_preset.pos = Vector(v.pos.x, v.pos.y, v.pos.z)
					if (v.angle) then
						new_preset.angle = Angle(v.angle.p, v.angle.y, v.angle.r)
					end
				else
					new_preset.pos = Vector(num*5,0,-10)
					if (v.angle) then
						new_preset.angle = Angle(0,0,0)
					end
				end
				
				if (v.color) then
					new_preset.color = Color(v.color.r,v.color.g,v.color.b,v.color.a)
				end
				if (type(v.size) == "table") then
					new_preset.size = table.Copy(v.size)
				elseif (type(v.size) == "Vector") then
					new_preset.size = Vector(v.size.x, v.size.y, v.size.z)
				end
				if (v.bodygroup) then
					new_preset.bodygroup = table.Copy(v.bodygroup)
				end
				
				wep.w_models[name] = {}
				if (v.type == "Model") then
					wep.w_panelCache[name] = CreateWorldModelPanel( name, 10, panely, new_preset )
				elseif (v.type == "Sprite") then
					wep.w_panelCache[name] = CreateWorldSpritePanel( name, 10, panely, new_preset )
				elseif (v.type == "Quad") then
					wep.w_panelCache[name] = CreateWorldQuadPanel( name, 10, panely, new_preset )
				end				
				wep.w_panelCache[name]:SetVisible(false)
				mwlist:AddLine(name,v.type)
				
				num = num + 1
			end
		end
		
		// remove a line
		rmbtn.DoClick = function()
			local line = mwlist:GetSelectedLine()
			if (line) then
				local name = mwlist:GetLine(line):GetValue(1)
				wep.w_models[name] = nil
				// clear from panel cache
				if (wep.w_panelCache[name]) then 
					wep.w_panelCache[name]:Remove()
					wep.w_panelCache[name] = nil
				end
				mwlist:RemoveLine(line)
			end
		end
		
		// duplicate line
		copybtn.DoClick = function()
			local line = mwlist:GetSelectedLine()
			if (line) then
				local name = mwlist:GetLine(line):GetValue(1)
				local to_copy = wep.w_models[name]
				local new_preset = table.Copy(to_copy)
				
				// quickly generate a new unique name
				while(wep.w_models[name]) do
					name = name.."+"
				end
				
				// have to fix every sub-table as well because table.Copy copies references
				new_preset.pos = Vector(to_copy.pos.x, to_copy.pos.y, to_copy.pos.z)
				if (to_copy.angle) then
					new_preset.angle = Angle(to_copy.angle.p, to_copy.angle.y, to_copy.angle.r)
				end
				if (to_copy.color) then
					new_preset.color = Color(to_copy.color.r,to_copy.color.g,to_copy.color.b,to_copy.color.a)
				end
				if (type(to_copy.size) == "table") then
					new_preset.size = table.Copy(to_copy.size)
				elseif (type(to_copy.size) == "Vector") then
					new_preset.size = Vector(to_copy.size.x, to_copy.size.y, to_copy.size.z)
				end
				if (to_copy.bodygroup) then
					new_preset.bodygroup = table.Copy(to_copy.bodygroup)
				end
				
				wep.w_models[name] = {}
				
				if (new_preset.type == "Model") then
					wep.w_panelCache[name] = CreateWorldModelPanel( name, 10, panely, new_preset )
				elseif (new_preset.type == "Sprite") then
					wep.w_panelCache[name] = CreateWorldSpritePanel( name, 10, panely, new_preset )
				elseif (new_preset.type == "Quad") then
					wep.w_panelCache[name] = CreateWorldQuadPanel( name, 10, panely, new_preset )
				end
				
				wep.w_panelCache[name]:SetVisible(false)
				mwlist:AddLine(name,new_preset.type)
			end
		end
		
		// finally, return the frame!
		return f

	end

	function SWEP:OpenMenu( preset )
		if (!self.Frame) then
			self.Frame = CreateMenu( preset )
		end
		
		if (IsValid(self.Frame)) then
			self.Frame:SetVisible(true)
			self.Frame:MakePopup()
		else
			self.Frame = nil
		end
		
	end
	
	function SWEP:OnRemove()
		self:CleanMenu()
	end
	
	function SWEP:OnDropWeapon()
		self.LastOwner = nil
		if (!self.Frame) then return end
		self.Frame:Close()
	end

	function SWEP:CleanMenu()
		self:RemoveModels()
		if (!self.Frame) then return end
		
		self.v_modelListing = nil
		self.w_modelListing = nil
		self.v_panelCache = {}
		self.w_panelCache = {}
		self.Frame:Remove()
		self.Frame = nil
	end
	
	function SWEP:HUDShouldDraw( el )
		return el != "CHudAmmo" and el != "CHudSecondaryAmmo"
	end
	
	/***************************
		Third person view
	***************************/
	function TPCalcView(pl, pos, angles, fov)
	
		local wep = pl:GetActiveWeapon()
		if (!IsValid(wep) or !wep.IsSCK or !wep.useThirdPerson) then
			wep.useThirdPerson = false
			return 
		end
		
		local look_pos = pos
		local rhand_bone = pl:LookupBone("ValveBiped.Bip01_R_Hand")
		if (rhand_bone) then
			look_pos = pl:GetBonePosition( rhand_bone )
		end
		
		local view = {}
		view.origin = look_pos + ((pl:GetAngles()+wep.thirdPersonAngle):Forward()*wep.thirdPersonDis)
		view.angles = (look_pos - view.origin):Angle()
		view.fov = fov
	 
		return view
	end
	
	oldCVHooks = {}
	hooksCleared = false
	local function CVHookReset()
		
		//print("Hook reset")
		hook.Remove( "CalcView", "TPCalcView" )
		for k, v in pairs( oldCVHooks ) do
			hook.Add("CalcView", k, v)
		end
		oldCVHooks = {}
		hooksCleared = false
			
	end	
	
	function SWEP:CalcViewHookManagement()
		
		if (!hooksCleared) then
			
			local CVHooks = hook.GetTable()["CalcView"]
			if CVHooks then
			
				for k, v in pairs( CVHooks ) do
					oldCVHooks[k] = v
					hook.Remove( "CalcView", k )
				end
			
			end
			
			hook.Add("CalcView", "TPCalcView", TPCalcView)
			hooksCleared = true
		else
			timer.Create("CVHookReset", 2, 1, CVHookReset)
		end
		
	end	
	
	hook.Add("ShouldDrawLocalPlayer", "ThirdPerson", function(pl)
		local wep = pl:GetActiveWeapon()
		if (IsValid(wep) and wep.useThirdPerson) then
			return true
		end
	end)

end