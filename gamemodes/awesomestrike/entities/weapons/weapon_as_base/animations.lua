/**************************************************
	SWEP Construction Kit base code
		Created by Clavus
	Available for public use, thread at:
	   facepunch.com/threads/1032378
**************************************************/

local function BuildViewModelBones(self)
	--if LocalPlayer():GetActiveWeapon() == self and self.ViewModelBoneMods then
	if self.ViewModelBoneMods then
		for k, v in pairs( self.ViewModelBoneMods ) do
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
	

function SWEP:Anim_Initialize()
	self:CreateModels(self.VElements)
	self:CreateModels(self.WElements)

	self.BuildViewModelBones = BuildViewModelBones
end

	SWEP.vRenderOrder = nil
	function SWEP:Anim_ViewModelDrawn()		
		local validowner = self.Owner and self.Owner:IsValid()
		local vm = validowner and self.Owner:GetViewModel()
		if !IsValid(vm) then return end
		
		if (!self.VElements) then return end

		if self.CoolDown and self:GetReloadEnd() ~= 0 and CurTime() < self:GetReloadEnd() then return end

		if vm.BuildBonePositions ~= self.BuildViewModelBones then
			vm.BuildBonePositions = self.BuildViewModelBones
		end

		if (self.ShowViewModel == nil or self.ShowViewModel) then
			vm:SetColor(Color(255,255,255,255))
		else
			-- we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
			vm:SetColor(Color(255,255,255,1) )
		end

		local baseblend = validowner and self.Owner:IsPlayer() and self.Owner:CallStateFunction("GetVisibility") or 1
		
		if (!self.vRenderOrder) then
			
			-- we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}

			for k, v in pairs( self.VElements ) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end
			
		end

		for k, name in ipairs( self.vRenderOrder ) do
		
			local v = self.VElements[name]
			if (!v) then self.vRenderOrder = nil break end
		
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (!v.bone) then continue end
			
			local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )
			
			if (!pos) then continue end
			
			if v.type == "Model" and IsValid(model) then
				local vpos = v.pos
				local vang = v.angle
				model:SetPos(pos + ang:Forward() * vpos.x + ang:Right() * vpos.y + ang:Up() * vpos.z )
				if vang.yaw ~= 0 then ang:RotateAroundAxis(ang:Up(), vang.y) end
				if vang.pitch ~= 0 then ang:RotateAroundAxis(ang:Right(), vang.pitch) end
				if vang.roll ~= 0 then ang:RotateAroundAxis(ang:Forward(), vang.roll) end
				model:SetAngles(ang)

				if v.surpresslightning then
					render.SuppressEngineLighting(true)
				end
				
				local col = v.color
				if col then
					render.SetColorModulation(col.r / 255, col.g / 255, col.b / 255)
					render.SetBlend(col.a / 255 * baseblend)
				else
					render.SetBlend(255 * baseblend)
				end

				if v.material then
					render.MaterialOverride(v.material)
				end

				model:DrawModel()

				render.MaterialOverride()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				render.SuppressEngineLighting(false)
			elseif v.type == "Sprite" and sprite then
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
			elseif v.type == "Quad" and v.draw_func then
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
	end

	SWEP.wRenderOrder = nil
	function SWEP:Anim_DrawWorldModel()
		
		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:DrawModel()
		end
		
		if (!self.WElements) then return end

		if self.CoolDown and self:GetReloadEnd() ~= 0 and CurTime() < self:GetReloadEnd() then return end
		
		if (!self.wRenderOrder) then
			self.wRenderOrder = {}

			for k, v in pairs( self.WElements ) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				else
					table.insert(self.wRenderOrder, k)
				end
			end
		end

		local baseblend = 1
		if IsValid(self.Owner) then
			bone_ent = self.Owner

			if self.Owner:IsPlayer() then
				baseblend = self.Owner:CallStateFunction("GetVisibility") or baseblend
			end
		else
			-- when the weapon is dropped
			bone_ent = self
		end
		
		for k, name in pairs( self.wRenderOrder ) do
			local v = self.WElements[name]
			if not v then self.wRenderOrder = nil break end
			
			local pos, ang
			
			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end
			
			if not pos then continue end

			local fw = ang:Forward()
			local rt = ang:Right()
			local up = ang:Up()

			if v.type == "Model" then
				local model = v.modelEnt
				if IsValid(model) then
					local vpos = v.pos
					local rang = v.angle
					model:SetPos(pos + fw * vpos.x + rt * vpos.y + up * vpos.z)
					if rang.y ~= 0 then ang:RotateAroundAxis(up, rang.y) end
					if rang.p ~= 0 then ang:RotateAroundAxis(rt, rang.p) end
					if rang.r ~= 0 then ang:RotateAroundAxis(fw, rang.r) end
					model:SetAngles(ang)

					if v.surpresslightning then
						render.SuppressEngineLighting(true)
					end
				
					local col = v.color
					if col then
						render.SetColorModulation(col.r / 255, col.g / 255, col.b / 255)
						render.SetBlend(col.a / 255 * baseblend)
					else
						render.SetBlend(255 * baseblend)
					end

					if v.material then
						render.MaterialOverride(v.material)
					end

					model:DrawModel()

					render.MaterialOverride()

					render.SetBlend(1)
					render.SetColorModulation(1, 1, 1)
					render.SuppressEngineLighting(false)
				end
			elseif v.type == "Sprite" then
				if v.spriteMaterial then
					render.SetMaterial(v.spriteMaterial)
					render.DrawSprite(pos + fw * v.pos.x + rt * v.pos.y + up * v.pos.z, v.size.x, v.size.y, v.color)
				end
			elseif v.type == "Quad" and v.draw_func then
				local drawpos = pos + fw * v.pos.x + rt * v.pos.y + up * v.pos.z
				local rang = v.angle
				ang:RotateAroundAxis(up, rang.y)
				ang:RotateAroundAxis(rt, rang.p)
				ang:RotateAroundAxis(fw, rang.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()
			end
		end
	end

	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )
		if (tab.rel and tab.rel != "") then
			local v = basetab[tab.rel]
			
			if (!v) then return end
			
			-- Technically, if there exists an element with the same name as a bone
			-- you can get in an infinite loop. Let's just hope nobody's that stupid.
			local pos, ang = self:GetBoneOrientation( basetab, v, ent )
			
			if (!pos) then return end
			
			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
			return pos, ang
		end

		if not tab.BoneCache then tab.BoneCache = ent:LookupBone(bone_override or tab.bone) end

		local bone = tab.BoneCache

		if (!bone) then return end
			
		local pos, ang
		local m = ent:GetBoneMatrix(bone)
		if (m) then
			pos, ang = m:GetTranslation(), m:GetAngles()
		end
			
		if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
			ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
			ang.r = -ang.r -- Fixes mirrored models
		end

		return pos or Vector(0, 0, 0), ang or Angle(0, 0, 0)
	end

function SWEP:CreateModels( tab )

	if (!tab) then return end

	-- Create the clientside models here because Garry says we can't do it in the render hook
	for k, v in pairs( tab ) do
		if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
				string.find(v.model, ".mdl", 1, true) and file.Exists (v.model, "GAME") ) then

			v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
			if (IsValid(v.modelEnt)) then
				v.modelEnt:DrawShadow(false)
				v.modelEnt:SetPos(self:GetPos())
				v.modelEnt:SetAngles(self:GetAngles())
				v.modelEnt:SetParent(self)
				v.modelEnt:SetNoDraw(true)
				if v.size then
					v.modelEnt:SetModelScaleVector(v.size)
				end
				if v.material then
					v.modelEnt:SetMaterial(v.material)
				end
				v.createdModel = v.model
			else
				v.modelEnt = nil
			end
		elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
			and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then
				
			local name = v.sprite.."-"
			local params = { ["$basetexture"] = v.sprite }
			-- make sure we create a unique name based on the selected options
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

function SWEP:Anim_OnRemove()
	self:RemoveModels()
end

function SWEP:RemoveModels()
	if (self.VElements) then
		for k, v in pairs( self.VElements ) do
			if (IsValid( v.modelEnt )) then v.modelEnt:Remove() end
		end
	end
	if (self.WElements) then
		for k, v in pairs( self.WElements ) do
			if (IsValid( v.modelEnt )) then v.modelEnt:Remove() end
		end
	end
	self.VElements = nil
	self.WElements = nil
end
