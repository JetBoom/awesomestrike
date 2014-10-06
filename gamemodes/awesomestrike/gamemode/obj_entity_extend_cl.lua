local meta = FindMetaTable("Entity")
if not meta then return end

if not meta.TakeDamage then
function meta:TakeDamage()
end
end

if not meta.TakeDamageInfo then
function meta:TakeDamageInfo()
end
end

-- For some reason the "ai" type of entity doesn't let you give it members in ENT.
function meta:ShouldBeLastChance()
	return self:GetDTEntity(0):IsValid() or CurTime() < self:GetDTFloat(0) + 3
end
