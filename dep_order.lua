
local function dependency_order(items, item_deps)
	local function dep_maps()
		local t = {} --{item->{dep_item->true}}
		local function add_item(item)
			if t[item] then return true end --already added
			local deps = item_deps(item)
			local dt = {}
			t[item] = dt
			for dep_item in pairs(deps) do
				if add_item(dep_item) then
					dt[dep_item] = true
				end
			end
			return true --added
		end
		for item in pairs(items) do
			add_item(item)
		end
		return t
	end
	--add items with zero deps first, remove them from the dep maps
	--of all other items and from the original table of items,
	--and repeat, until there are no more items.
	local t = dep_maps()
	local circular_deps
	local dt = {}
	while next(t) do
		local guard = true
		for item, deps in sortedpairs(t) do --stabilize the list
			if not next(deps) then
				guard = false
				add(dt, item) --build it
				t[item] = nil --remove it from the final table
				--remove it from all dep lists
				for _, deps in pairs(t) do
					deps[item] = nil
				end
			end
		end
		if guard then
			circular_deps = t --circular dependencies found
			break
		end
	end
	return dt, circular_deps
end
