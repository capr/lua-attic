
setfenv(1, require'low'.C)

HashableInt = {}

HashableInt.Type = uint64

HashableInt.hash = terralib.includecstring([[
#include <stdint.h>
uint64_t hash64(uint64_t key)
{
	key = (~key) + (key << 21);
	key = key ^ (key >> 24);
	key = (key + (key << 3)) + (key << 8);
	key = key ^ (key >> 14);
	key = (key + (key << 2)) + (key << 4);
	key = key ^ (key >> 28);
	key = key + (key << 31);
	return key;
}
]]).hash64

terra HashableInt.equals(x : int64, y : int64)
	return x == y
end

function MakeHashTable(hashable, Value)
	local INITIAL_SIZE = 8
	local max_occupancy = 0.75

	local Key = hashable.Type

	local struct Entry{
		hash : uint64,
		key : Key,
		value : Value
	}

	local struct Table{
		length : uint64,
		occupancy : uint64,
		entries : &Entry
	}

	local terra new_entry_list(len : uint64) : &Entry
		return [&Entry](calloc(len, sizeof(Entry)))
	end

	terra Table:init()
		self.occupancy = 0
		self.length = INITIAL_SIZE
		self.entries = new_entry_list(INITIAL_SIZE)
	end

	terra Table:del()
		free(self.entries)
	end

	Table.find_entry_with_hash = {} -> {}

	local terra h(key : Key)
		var hash = hashable.hash(key)
		if hash == 0 then return 1 else return hash end
	end

	terra Table:grow_table() : {}
		var backup = @self
		self.length = self.length * 2
		self.entries = new_entry_list(self.length)
		self.occupancy = 0

		for i = 0,backup.length do
			var e = backup.entries + i
			if (e.hash ~= 0) then
				self:find_entry_with_hash(e.key, e.hash).value = e.value
			end
		end
		free(backup.entries)
	end

	terra Table:find_entry_with_hash(key : Key, hash : int64) : &Entry
		var probe = hash % self.length
		while true do
			var e = self.entries + probe
			if e.hash == 0 then
				if self.occupancy >= self.length * max_occupancy then
					self:grow_table()
					return self:find_entry_with_hash(key, hash)
				else
					e.hash = hash
					e.key = key
					self.occupancy = self.occupancy + 1
					return e
				end
			else
				if hashable.equals(key, e.key) then
					return e
				else
					probe = (probe + 1) % self.length
				end
			end
		end
	end

	terra Table:find_entry(key : Key)
		return self:find_entry_with_hash(key, h(key))
	end

	terra Table:set(key : Key, value : Value)
		self:find_entry(key).value = value
	end

	terra Table:get(key : Key)
		return self:find_entry(key).value
	end

	terra Table:print_table(format : &int8)
		printf("HashTable[")
		var printed = 0
		for i=0,self.length do
			var e = self.entries + i
			if e.hash ~= 0 then
				printed = printed + 1
				printf("(")
				printf(format, e.key, e.value)
				printf(")")
				if printed < self.occupancy then
					printf(", ")
				end
			end
		end
		printf("]")
	end

	return Table
end

SparseVector = MakeHashTable(HashableInt, double)

terra main()
	var x : SparseVector
	x:init()
	var n = 17
	for i = 1,n do
		x:set(i, i * 3)
		x:print_table("%d -> %f")
		puts("")
	end

	for i = 1,n do
		printf("%d -> %f\n", i, x:get(i))
	end
	x:del()
	return 0
end
main()

