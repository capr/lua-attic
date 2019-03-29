-- byte 1     byte 2      byte 3     byte 4
--------------------------------------------
-- 00 - 7F
-- C2 - DF    80 - BF
-- E0         A0 - BF     80 - BF
-- E1 - EC    80 - BF     80 - BF
-- ED         80 - 9F     80 - BF
-- EE - EF    80 - BF     80 - BF
-- F0         90 - BF     80 - BF    80 - BF
-- F1 - F3    80 - BF     80 - BF    80 - BF
-- F4         80 - 8F     80 - BF    80 - BF

--returns: (0==EOF|1=OK|-1=ERROR, next_index, codepoint)
terra utf8.next(buf: rawstring, len: intptr, i: intptr): {enum, intptr, codepoint}
	var buf = [&uint8](buf)
	if i >= len then
		return 0, i, 0 --EOF
	end
	var c1 = buf[i]
	i = i + 1
	if c1 <= 0x7F then
		return 1, i, c1 --ASCII
	elseif c1 < 0xC2 then
		--invalid
	elseif c1 <= 0xDF then --2-byte
		if i < len then
			var c2 = buf[i]
			if c2 >= 0x80 and c2 <= 0xBF then
				return 1, i + 1,
					  ((c1 and 0x1F) <<  6)
					+  (c2 and 0x3F)
			end
		end
	elseif c1 <= 0xEF then --3-byte
		if i < len + 1 then
			var c2, c3 = buf[i], buf[i+1]
			if not (
				   c2 < 0x80 or c2 > 0xBF
				or c3 < 0x80 or c3 > 0xBF
				or (c1 == 0xE0 and c2 < 0xA0)
				or (c1 == 0xED and c2 > 0x9F)
			) then
				return 1, i + 2,
					  ((c1 and 0x0F) << 12)
					+ ((c2 and 0x3F) <<  6)
					+  (c3 and 0x3F)
			end
		end
	elseif c1 <= 0xF4 then --4-byte
		if i < len + 2 then
			var c2, c3, c4 = buf[i], buf[i+1], buf[i+2]
			if not (
				   c2 < 0x80 or c2 > 0xBF
				or c3 < 0x80 or c3 > 0xBF
				or c3 < 0x80 or c3 > 0xBF
				or c4 < 0x80 or c4 > 0xBF
				or (c1 == 0xF0 and c2 < 0x90)
				or (c1 == 0xF4 and c2 > 0x8F)
			) then
				return 1, i + 3,
					  ((c1 and 0x07) << 18)
					+ ((c2 and 0x3F) << 12)
				   + ((c3 and 0x3F) <<  6)
				   +  (c4 and 0x3F)
			end
		end
	end
	return -1, i, c1 --invalid
end

local struct codepoints_iter {
	buf: rawstring;
	len: intptr;
}
codepoints_iter.metamethods.__for = function(self, body)
	return quote
		var i: intptr = 0
		while true do
			var r, i1, cp = utf8.next(self.buf, self.len, i)
			if r == 0 then break end
			[ body(`r ~= -1, `i, `cp) ]
			i = i1
		end
	end
end
utf8.codes = macro(function(buf, len)
	return `codepoints_iter{buf=buf, len=len}
end)

--returns: number of output codepoints, number of input bytes consumed,
--and number of invalid sequences.
local terra decode_counts(
	s: rawstring, len: intptr,
	maxn: intptr, invalid_action: enum
)
	var p = [&uint8](s)
	var bof = p
	var eof = p+len
	var n: intptr = 0 --output codepoint count
 	var q: intptr = 0 --invalid byte count
	while p < eof do
		if p[0] <= 0x7F then --ASCII
			inc(p); goto valid
		elseif p[0] < 0xC2 then --invalid
			--
		elseif p[0] <= 0xDF then --2-byte
			if p + 1 < eof and p[1] >= 0x80 and p[1] <= 0xBF then
				inc(p, 2); goto valid
			end
		elseif p[0] <= 0xEF then --3-byte
			if p + 2 < eof and not (
				   p[1] < 0x80 or p[1] > 0xBF
				or p[2] < 0x80 or p[2] > 0xBF
				or (p[0] == 0xE0 and p[1] < 0xA0)
				or (p[0] == 0xED and p[1] > 0x9F)
			) then
				inc(p, 3); goto valid
			end
		elseif p[0] <= 0xF4 then --4-byte
			if p + 3 < eof and not (
					p[1] < 0x80 or p[1] > 0xBF
				or p[2] < 0x80 or p[2] > 0xBF
				or p[2] < 0x80 or p[2] > 0xBF
				or p[3] < 0x80 or p[3] > 0xBF
				or (p[0] == 0xF0 and p[1] < 0x90)
				or (p[0] == 0xF4 and p[1] > 0x8F)
			) then
				inc(p, 4); goto valid
			end
		else
			--invalid
		end
		inc(p); inc(q)
		if invalid_action == utf8.REPLACE then
			goto valid
		elseif invalid_action == utf8.KEEP then
			goto valid
		elseif invalid_action == utf8.SKIP then
			goto continue
		elseif invalid_action == utf8.STOP then
			break
		else
			assert(false)
		end
		::valid::
		if n < maxn then
			inc(n)
		else
			break
		end
		::continue::
	end
	return n, p-bof, q
end

--decode without checks: input must be valid and output must be sufficient.
terra utf8.fastdecode(ss: rawstring, len: intptr, us: &codepoint)
	var n: intptr = 0
	var s = [&uint8](ss)
	var t = [&uint8](s)
	while s - t < len do
		var c = s[0]
      if c <= 0x7f then --1-byte
			@us = s[0]
			inc(us); inc(s)
		elseif c <= 0xdf then --2-byte
			@us =
				  ((s[0] and 0x1f) <<  6)
				+ ((s[1] and 0x3f)      )
			inc(us); inc(s, 2)
		elseif c <= 0xef then --3-byte
			@us =
				  ((s[0] and 0x0f) << 12)
				+ ((s[1] and 0x3f) <<  6)
				+ ((s[2] and 0x3f)      )
			inc(us); inc(s, 3)
		else -- 4-byte
			@us =
				  ((s[0] and 0x07) << 18)
				+ ((s[1] and 0x3f) << 12)
				+ ((s[2] and 0x3f) <<  6)
				+ ((s[3] and 0x3f)      )
			inc(us); inc(s, 4)
		end
		inc(n)
	end
	return n
end

utf8.decode = overload'decode'
utf8.decode:adddefinition(terra(
	buf: rawstring, len: intptr, out: &codepoint, outlen: intptr,
	invalid_action: enum, repl_cp: codepoint
)
	if out == nil then
		return decode_counts(buf, len, outlen, invalid_action)
	end
	var n: intptr = 0 --number of output codepoints
	var q: intptr = 0 --number of invalid sequences
	for valid, i, cp in utf8.codes(buf, len) do
		if not valid then
			inc(q)
			if invalid_action == utf8.REPLACE then
				cp = repl_cp
			elseif invalid_action == utf8.KEEP then
				--
			elseif invalid_action == utf8.SKIP then
				goto continue
			elseif invalid_action == utf8.STOP then
				return n, i, q
			else
				assert(false)
			end
		end
		if n < outlen then
			out[n] = cp
			inc(n)
		else
			return n, i, q
		end
		::continue::
	end
	return n, len, q
end)

utf8.codepoint_arr = arr{T=codepoint, size_t=intptr}

utf8.decode:adddefinition(terra(
	buf: rawstring, len: intptr, maxlen: intptr,
	invalid_action: enum, repl_cp: codepoint
)
	var n, i, q = decode_counts(buf, len, maxlen, invalid_action)
	var out = utf8.codepoint_arr(nil)
	out.len = n
	if q == 0 then
		var n1 = utf8.fastdecode(buf, len, out.elements)
		assert(n1 == n)
	else
		utf8.decode(buf, len, out.elements, out.len, invalid_action, repl_cp)
	end
	return out, i, q
end)

terra utf8.isvalid(c: codepoint)
	return c <= 0x10FFFF and (c < 0xD800 or c > 0xDFFF)
end

terra utf8.size(c: codepoint)
	if c <= 0x7F then
		return 1
	elseif c <= 0x7FF then
		return 2
	elseif c <= 0xFFFF then
		return 3
	else
		return 4
	end
end

local terra encode_counts(
	buf: &codepoint, len: intptr,
	invalid_action: enum, repl_cp: codepoint
): {intptr, intptr}
	var b: intptr = 0 --number of output bytes needed to encode the buffer
	var q: intptr = 0 --number of invalid codepoints
	var repl_len: int8 = 0
	if invalid_action == utf8.REPLACE then
		assert(utf8.isvalid(repl_cp))
		repl_len = utf8.size(repl_cp)
	elseif invalid_action == utf8.SKIP then
	elseif invalid_action == utf8.STOP then
	else
		assert(false)
	end
	for i: intptr = 0, len do
		if utf8.isvalid(buf[i]) then
			inc(b, utf8.size(buf[i]))
		elseif invalid_action == utf8.REPLACE then
			inc(b, repl_len)
			inc(q)
		elseif invalid_action == utf8.SKIP then
			inc(q)
		elseif invalid_action == utf8.STOP then
			q = i
			break
		else
			assert(false)
		end
	end
	return b, q
end

terra utf8.encode(
	buf: &codepoint, len: intptr, out: rawstring, outlen: intptr,
	invalid_action: enum, repl_cp: codepoint
): {intptr, intptr}
	if out == nil then
		return encode_counts(buf, len, invalid_action, repl_cp)
	end
	if invalid_action == utf8.REPLACE then
		assert(utf8.isvalid(repl_cp))
	end
	var j: intptr = 0
	var eof = out + outlen
	for i: intptr = 0, len do
		var c = buf[i]
		if (c >= 0xD800 and c <= 0xDFFF) or c > 0x10FFFF then --invalid
			if invalid_action == utf8.REPLACE then
				c = repl_cp
			elseif invalid_action == utf8.SKIP then
				goto continue
			elseif invalid_action == utf8.STOP then
				break
			else
				assert(false)
			end
		end
		if c <= 0x7F then
			if out >= eof then break end
			out[0] = c
			inc(out, 1)
		elseif c <= 0x7FF then
			if out + 1 >= eof then break end
			out[1] = 0x80 + ((c      ) and 0x3F)
			out[0] = 0xC0 + ((c >>  6)         )
			inc(out, 2)
		elseif c <= 0xFFFF then
			if out + 2 >= eof then break end
			out[2] = 0x80 + ((c      ) and 0x3F)
			out[1] = 0x80 + ((c >>  6) and 0x3F)
			out[0] = 0xE0 + ((c >> 12)         )
			inc(out, 3)
		else
			if out + 3 >= eof then break end
			out[3] = 0x80 + ((c      ) and 0x3F)
			out[2] = 0x80 + ((c >>  6) and 0x3F)
			out[1] = 0x80 + ((c >> 12) and 0x3F)
			out[0] = 0xF0 + ((c >> 18)         )
			inc(out, 4)
		end
		::continue::
	end
	return outlen-(eof-out), 0
end
