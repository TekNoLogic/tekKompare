
local myname, ns = ...

local function tonumber_all(v, ...)
	if select('#', ...) == 0 then
		return tonumber(v)
	else
		return tonumber(v), tonumber_all(...)
	end
end

ns.tonumber_all = tonumber_all
