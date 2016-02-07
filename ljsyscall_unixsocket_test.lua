local file = "/var/tmp/selftest.sock"

local ss = assert(S.socket("unix", "stream, nonblock"))
S.unlink(file)
local sa = S.t.sockaddr_un(file)
assert(ss:bind(sa))
assert(ss:listen())

local cs = assert(S.socket("unix", "stream, nonblock"))

local accepted, connected

while true do

	if not accepted then
		local sa = S.t.sockaddr_un()
		local a, err = ss:accept(sa)
		if not a then
			if err.AGAIN then
				print('accept', err)
			else
				assert(nil, tostring(err))
			end
		else
			ss = a
			accepted = true
		end
	end

	if not connected then
		local sa = S.t.sockaddr_un(file)
		local ok, err = cs:connect(sa)
		if not ok then
			if err.CONNREFUSED or err.AGAIN then
				print('connect', err)
			else
				assert(nil, tostring(err))
			end
		else
			connected = true
		end
	end

	if connected and S.select({writefds = {cs}}, 0).count > 0 then
		local p = packet.allocate()
		local s = 'hello'
		ffi.copy(p.data, s)
		p.length = #s
		local len, err = S.write(cs, p.data, p.length)
		if not len then
			print('write', err)
		elseif len == 0 then
			print('sent 0 len')
		end
		packet.free(p)
	end

	if accepted and S.select({readfds = {ss}}, 0).count > 0 then
		local p = packet.allocate()
		local len, err = S.read(ss, p.data, ffi.sizeof(p.data))
		if not len then
			print('read', err)
		elseif len == 0 then
			print('recv 0 len')
		else
			print(ffi.string(p.data, len))
		end
	end

	ffi.C.usleep(100000)

end
