
local class_mt = {}

function class_mt:__call(...)
	local parents = { ... }
	
	local new_class = {}
	function new_class:GetClass() return new_class end
	function new_class:GetParentClass() return unpack(parents) end
	
	local new_object_mt = { __index = new_class }
	
	local new_class_mt = {}
	function new_class_mt:__call(...)
		-- Create the object
		local new_object = setmetatable({}, new_object_mt)
		
		-- Call the constructor
		local constructor = new_object.new
		if constructor then
			constructor(new_object, ...)
		end
		
		-- Return the new object
		return new_object
	end
	function new_class_mt:__index(key)
		-- Look into parent classes
		local parents = { self:GetParentClass() }
		for _, parent in ipairs(parents) do
			local value = parent[key]
			if value ~= nil then
				return value
			end
		end
	end
	
	return setmetatable(new_class, new_class_mt)
end

class = setmetatable({}, class_mt)
