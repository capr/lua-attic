function mac_table_check()
   local uint32_ptr_t = ffi.typeof('uint32_t*')
   local uint16_ptr_t = ffi.typeof('uint16_t*')
   local key_t = ffi.typeof('struct { uint8_t mac[6]; }')
   local value_t = ffi.typeof('struct { uint16_t lo; uint16_t hi; }')
   local cast = ffi.cast
   local bor = bit.bor

   local function hash_mac(key)
      local hi = cast(uint32_ptr_t, key.mac)[0]
      local lo = cast(uint16_ptr_t, key.mac + 4)[0]
      -- Extend lo to the upper half too so that the hash function isn't
      -- spreading around needless zeroes.
      lo = bor(lo, lshift(lo, 16))
      return hash_i32(bxor(hi, hash_i32(lo)))
   end

   -- 14-byte entries
   local occupancy = 2e5
   local params = {
      key_type = key_t,
      value_type = value_t,
      hash_fn = hash_mac,
      max_occupancy_rate = 0.4,
      initial_size = ceil(occupancy / 0.4)
   }
   local ctab = new(params)

   -- Fill with { i, 0 } => { bnot(i) }.
   do
      local k = key_t()
      local v = value_t()
      for i = 1,occupancy do
         cast(uint32_ptr_t, k.mac)[0] = i
         cast(uint16_ptr_t, k.mac+4)[0] = 0
         cast(uint32_ptr_t, v)[0] = bnot(i)
         ctab:add(k, v)
      end
   end   

   local pmu = require('lib.pmu')
   local has_pmu_counters, err = pmu.is_available()
   if not has_pmu_counters then
      print('No PMU available: '..err)
   end

   if has_pmu_counters then pmu.setup() end

   local function measure(f, iterations)
      local set
      if has_pmu_counters then set = pmu.new_counter_set() end
      local start = C.get_time_ns()
      if has_pmu_counters then pmu.switch_to(set) end
      local res = f(iterations)
      if has_pmu_counters then pmu.switch_to(nil) end
      local stop = C.get_time_ns()
      local ns = tonumber(stop-start)
      local cycles = nil
      if has_pmu_counters then cycles = pmu.to_table(set).cycles end
      return cycles, ns, res
   end

   local function check_perf(f, iterations, max_cycles, max_ns, what)
      require('jit').flush()
      io.write(tostring(what or f)..': ')
      io.flush()
      local cycles, ns, res = measure(f, iterations)
      if cycles then
         cycles = cycles/iterations
         io.write(('%.2f cycles, '):format(cycles))
      end
      ns = ns/iterations
      io.write(('%.2f ns per iteration (result: %s)\n'):format(
            ns, tostring(res)))
      if cycles and cycles > max_cycles then
         print('WARNING: perfmark failed: exceeded maximum cycles '..max_cycles)
      end
      if ns > max_ns then
         print('WARNING: perfmark failed: exceeded maximum ns '..max_ns)
      end
      return res
   end

   local function test_lookup(count)
      local result
      local k = key_t()
      for i = 1, count do
         cast(uint32_ptr_t, k)[0] = i
         result = ctab:lookup_ptr(k).value.lo
      end
      return result
   end

   check_perf(test_lookup, 2e5, 300, 100, 'lookup (40% occupancy)')
end