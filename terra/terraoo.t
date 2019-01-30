
--Object system with virtual properties and method overriding hooks for Terra.
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'low'.C)

local function class()

	local cls = {}

	cls.struct = terralib.types.newstruct()

	cls.entries:insert { field = "size", type = int }

	return cls
end

local cls = class()

local terra f()



end
f()
