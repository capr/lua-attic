local clock = require'time'.clock
local libb64 = require'libb64'
local s=''
for i=1,1000 do s = s .. '0123456789' end
local n = 50000

local st = clock()
local encoded1
for i=1,n do
	encoded1 = encode(s)
end
local et = clock()
local dt = et - st
print('Lua len:',#s,'n:',n,dt,'sec', (#s*n)/dt/1024.0/1024.0, 'MB/s' )

local st = clock()
local encoded2
for i=1,n do
	encoded2 = libb64.encode(s)
end
local et = clock()
local dt = et - st
print('C   len:',#s,'n:',n,dt,'sec', (#s*n)/dt/1024.0/1024.0, 'MB/s' )

encoded2 = encoded2:gsub('\n', '')
assert(encoded1 == encoded2)
assert(decode(encoded1) == s)

--TODO: benchmark decode.
