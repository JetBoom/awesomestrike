ENT.Base = "base_ai"
ENT.Type = "ai"

ENT.ShouldCleanUp = true

ENT.NoThrowFromPosition = true

ENT.AutomaticFrameAdvance = true

function ENT:ShouldBeLastChance()
	return self:GetCarry():IsValid() or CurTime() < self:GetLastDrop() + 3
end

function ENT:OnRemove()
end

function ENT:PhysicsCollide(data, physobj)
end

function ENT:PhysicsUpdate(physobj)
end

function ENT:SetAutomaticFrameAdvance(bUsingAnim)
	self.AutomaticFrameAdvance = bUsingAnim
end

function ENT:SetCarry(ent) self:SetDTEntity(0, ent) end
function ENT:GetCarry() return self:GetDTEntity(0) end
function ENT:SetLastDrop(time) self:SetDTFloat(0, time) end
function ENT:GetLastDrop() return self:GetDTFloat(0) end
