local ffi = require'ffi'

print(tostring(ffi.typeof'void*'))
ffi.cast('ctype<void*>', nil)
