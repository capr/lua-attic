--like string.find() but does not support anchors and only returns the byte index and the char index.
--the pattern should start with the '^' anchor except in plain mode.
--NOTE: this algorithm is slow, with O(N*M/2) complexity and lots of branches.
function str.find(s, sub, start_ci, plain)
	start_ci = start_ci or 1
	local ci = 0
	for i in str.byte_indices(s) do
		ci = ci + 1
		if ci >= start_ci then
			if plain then
				if str.contains(s, i, sub) then
					return i, ci
				end
			elseif s:find(sub, i) == i then
				return i, ci
			end
		end
	end
end

assert(utf8.find('abcde', 'cd') == 3)
assert(utf8.find('abcde', '') == 1)
assert(utf8.find('abcde', 'cd', 3) == 3)
assert(utf8.find('abcde', '', 4) == 4)
assert(utf8.find('abcde', 'cd', 3, true) == 3)
assert(utf8.find('abcde', 'cd', 4, true) == nil)
assert(utf8.find('abcde', '', 4, true) == 4)
assert(utf8.find('abcde', '', 6, true) == nil)
assert(utf8.find('abcde', '.', 1, true) == nil)

assert(utf8.find(' \t abc', '^[^\t ]') == 4)



--escape ascii control characters as \xXX and non-ascii utf8 characters to \uXXXX
--to escape using only \xXX or \ddd use a pretty printing library.
function str.escape(s)
    --TODO
	 if ord == nil then return nil end
    if ord < 32 then return string.format('\\x%02x', ord) end
    if ord < 126 then return string.char(ord) end
    if ord < 65539 then return string.format("\\u%04x", ord) end
    if ord < 1114111 then return string.format("\\u%08x", ord) end
end

--unescape \xXX and \uXXXX
function str.unescape(s)
	--TODO
end

--decode utf8 char at byte index i into the corresponding undicode codepoint (a number between 0 and 0x7FFFFFFF)
function str.codepoint(s, i)
	--TODO:
end

--encode a single unicode codepoint to its utf8 representation (a string of 1 to 6 chars)
function str.encode(codepoint)
	--TODO http://stackoverflow.com/questions/6240055/manually-converting-unicode-codepoints-into-utf-8-and-utf-16
end
