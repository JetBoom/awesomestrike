local meta = FindMetaTable("Entity")
if not meta then return end

function meta:FireOutput(outpt, activator, caller, args)
	local intab = self[outpt]
	if intab then
		for key, tab in pairs(intab) do
			for __, subent in pairs(self:FindByNameHammer(tab.entityname, activator, caller)) do
				local delay = tonumber(tab.delay)
				if delay == nil or delay <= 0 then
					subent:Input(tab.input, activator, caller, tab.args)
				else
					timer.Simple(delay, function() if subent:IsValid() then subent:Input(tab.input, activator, caller, tab.args) end end)
				end
			end
		end
	end
end

function meta:AddOnOutput(key, value)
	self[key] = self[key] or {}
	local tab = string.Explode(",", value)
	table.insert(self[key], {entityname=tab[1], input=tab[2], args=tab[3], delay=tab[4], reps=tab[5]})
end

function meta:FindByNameHammer(name, activator, caller)
	if name == "!self" then return {self} end
	if name == "!activator" then return {activator} end
	if name == "!caller" then return {caller} end
	return ents.FindByName(name)
end
