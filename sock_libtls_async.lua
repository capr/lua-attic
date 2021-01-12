
if not ... then require'luapower_server'; return end

--secure sockets with libtls.
--Written by Cosmin Apreutesei. Public Domain.

require'sock' --not used directly, but it is a dependency.
local glue = require'glue'
local tls = require'libtls'
local ffi = require'ffi'
local C = tls.C

ffi.cdef[[
int            tls_async_connected(struct tls *ctx);
unsigned char* tls_async_send_buf(struct tls *ctx, size_t *len);
unsigned char* tls_async_recv_buf(struct tls *ctx, size_t *len);
void           tls_async_send_ack(struct tls *ctx, size_t len);
void           tls_async_recv_ack(struct tls *ctx, size_t len);
ssize_t        tls_async_send(struct tls *ctx, unsigned char *buf, size_t len);
ssize_t        tls_async_recv(struct tls *ctx, unsigned char *buf, size_t len);
]]

local szbuf = ffi.new'size_t[1]'
local tsbuf = ffi.new'unsigned char[33178]'

local function tls_ready(self, expires)
	repeat
		local buf = C.tls_async_send_buf(self.tls, szbuf)
		if buf ~= nil then
			local sz = tonumber(szbuf[0])
			local len, err, errcode = self.tcp:send(buf, sz, expires)
			if not len then return nil, err, errcode end
			C.tls_async_send_ack(self.tls, len)
			ack = true
		end
		local buf = C.tls_async_recv_buf(self.tls, szbuf)
		print('recv_buf', buf)
		if buf ~= nil then
			local sz = tonumber(szbuf[0])
			local len, err, errcode = self.tcp:recv(buf, sz, expires)
			if not len then return nil, err, errcode end
			C.tls_async_recv_ack(self.tls, len)
			ack = true
		end
	until not ack
	return true
end

local stcp = {issocket = true, istcpsocket = true, istlssocket = true}
local client_stcp = {}
local server_stcp = {}
local M = {}

local read_cb = ffi.cast('tls_read_cb', function() assert(false) end)
local write_cb = ffi.cast('tls_write_cb', function() assert(false) end)

function M.client_stcp(tcp, servername, opt)
	local tls, err = tls.client(opt)
	if not tls then
		return nil, err
	end
	local ok, err = tls:connect(servername, read_cb, write_cb)
	if not ok then
		tls:free()
		return nil, err
	end
	return glue.object(client_stcp, {
		tcp = tcp,
		tls = tls,
	})
end

function M.server_stcp(tcp, opt)
	local tls, err = tls.server(opt)
	if not tls then
		return nil, err
	end
	return glue.object(server_stcp, {
		tcp = tcp,
		tls = tls,
	})
end

function server_stcp:accept(expires)
	local ctcp, err, errcode = self.tcp:accept(expires)
	if not ctcp then
		return nil, err, errcode
	end
	local ctls, err = self.tls:accept(read_cb, write_cb)
	if not ctls then
		return nil, err
	end
	local self = glue.object(client_stcp, {
		tcp = ctcp,
		tls = ctls,
	})
	local ok, err, errcode = tls_ready(self, expires)
	if not ok then
		ctcp:close()
		ctls:free()
		return nil, err, errcode
	end
	if C.tls_async_connected(self.tls) ~= 0 then
		ctcp:close()
		ctls:free()
		return nil, 'tls handshake error'
	end
	return self
end

function client_stcp:recv(buf, sz, expires)
	if self._closed then return nil, 'closed' end
	local ok, err, errcode = tls_ready(self, expires)
	if not ok then return nil, err, errcode end
	local n = tonumber(C.tls_async_recv(self.tls, buf, sz))
	print(n)
	return n
end

function client_stcp:send(buf, sz, expires)
	local ok, err, errcode = tls_ready(self, expires)
	if not ok then return nil, err, errcode end
	local len = tonumber(C.tls_async_send(self.tls, buf, sz))
	local ok, err, errcode = tls_ready(self, expires)
	if not ok then return nil, err, errcode end
	return true
end

function client_stcp:shutdown(mode)
	return self.tcp:shutdown(mode)
end

function stcp:close(expires)
	if self._closed then return true end
	self._closed = true --close barrier.

	--

	self.tls:free()
	local tcp_ok, tcp_err, tcp_errcode = self.tcp:close()
	self.tls = nil
	self.tcp = nil
	if not tls_ok then return false, tls_err, tls_errcode end
	if not tcp_ok then return false, tcp_err, tcp_errcode end
	return true
end

function stcp:closed()
	return self._closed or false
end

function stcp:shutdown(mode, expires)
	return self:close(expires)
end

glue.update(client_stcp, stcp)
glue.update(server_stcp, stcp)

M.config = tls.config

return M
