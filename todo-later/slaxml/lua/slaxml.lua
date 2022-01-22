--[=[

	XML Parser and formatter from http://github.com/Phrogz/slaxml
	v0.8 Copyright © 2013-2018 Gavin Kistner <!@phrogz.net>; MIT Licensed.
	Modified by Cosmin Apreutesei (public domain).

	slaxml.parser(opt) -> parser               create a parser
		opt.pi(target, s)                       PI command
		opt.comment(s)                          comment
		opt.start_tag(name, nsURI, nsPrefix)    start tag
		opt.attr(k, v, nsURI, nsPrefix)         tag attribute
		opt.text(s, cdata)                      text
		opt.end_tag(name, nsURI, nsPrefix)      end tag
	parser:parse(s, [opt])                     parse XML via callbacks
		opt.strip_whitespace                    strip whitespace
	slaxml.parse(s, opt)                       parse XML via callbacks
	slaxml.dom(xml, [opt]) -> tree             parse XML string to DOM tree
		opt.simple                              produce a simpler tree
		opt.*                                   options passed to parse()
	slaxml.format(tree) -> s                   format a DOM tree to XML

]=]

local ffi = require'ffi'
local bit = require'bit'
local band = bit.band
local shr = bit.rshift
local format = string.format
local char = string.char

local M = {}

local print_callbacks = {
	pi = function(target, content)
		print(format('<?%s %s?>', target, content))
	end,
	comment = function(content)
		print(format('<!-- %s -->', content))
	end,
	start_tag = function(name, nsURI, nsPrefix)
		io.write'<'
		if nsPrefix then io.write(nsPrefix, ':') end
		io.write(name)
		if nsURI then io.write(" (ns='", nsURI, "')") end
		print'>'
	end,
	attr = function(name, value, nsURI, nsPrefix)
		io.write'  '
		if nsPrefix then io.write(nsPrefix, ':') end
		io.write(name, '=', format('%q', value))
		if nsURI then io.write(" (ns='", nsURI, "')") end
		io.write'\n'
	end,
	text = function(text, cdata)
		print(format('  %s: %q', cdata and 'cdata' or 'text', text))
	end,
	end_tag = function(name, nsURI, nsPrefix)
		io.write'</'
		if nsPrefix then io.write(nsPrefix, ':') end
		io.write(name, '>\n')
	end,
}

local cb = ffi.new'uint8_t[4]'
local function utf8_encode_char(c)
	if c <= 0x7F then
		return char(c)
	elseif c <= 0x7FF then
		cb[1] = 0x80 + band(c, 0x3F); c = shr(c, 6)
		cb[0] = 0xC0 + c
		return ffi.string(cb, 2)
	elseif c >= 0xD800 and c <= 0xDFFF then --surrogate pair
		return '' --invalid in utf8
	elseif c <= 0xFFFF then
		cb[2] = 0x80 + band(c, 0x3F); c = shr(c, 6)
		cb[1] = 0x80 + band(c, 0x3F); c = shr(c, 6)
		cb[0] = 0xE0 + c
		return ffi.string(cb, 3)
	elseif c <= 0x10FFFF then
		cb[3] = 0x80 + band(c, 0x3F); c = shr(c, 6)
		cb[2] = 0x80 + band(c, 0x3F); c = shr(c, 6)
		cb[1] = 0x80 + band(c, 0x3F); c = shr(c, 6)
		cb[0] = 0xF0 + c
		return ffi.string(cb, 4)
	else
		return '' --invalid
	end
end

function M.parser(call)

	call = call or print_callbacks

	local parser = {}

	function parser:parse(xml, opt)

		local find, sub, gsub, char, push, pop, concat =
			string.find, string.sub, string.gsub, string.char,
			table.insert, table.remove, table.concat
		local unpack = unpack or table.unpack

		local first, last, match1, match2, match3, pos2, nsURI
		local pos = 1
		local state = 'text'
		local text_start = 1
		local elem = {}
		local attrs = {}
		local attrn -- manually track length since the table is reused
		local ns_stack = {}
		local elements_found = false

		local entityMap  = {["lt"]="<", ["gt"]=">", ["amp"]="&", ["quot"]='"', ["apos"]="'"}
		local entitySwap = function(orig, n, s)
			return entityMap[s] or n == '#' and utf8_encode_char(tonumber('0'..s)) or orig
		end
		local function unescape(str)
			return gsub(str, '(&(#?)([%d%a]+);)', entitySwap)
		end

		local strip_whitespace = opt and opt.strip_whitespace
		local function finishText()
			if first > text_start and call.text then
				local text = sub(xml, text_start, first-1)
				if strip_whitespace then
					text = gsub(text, '^%s+','')
					text = gsub(text, '%s+$','')
					if #text == 0 then text = nil end
				end
				if text then call.text(unescape(text), false) end
			end
		end

		local function findPI()
			first, last, match1, match2 = find(xml, '^<%?([:%a_][:%w_.-]*) ?(.-)%?>', pos)
			if first then
				finishText()
				if call.pi then call.pi(match1, match2) end
				pos = last + 1
				text_start = pos
				return true
			end
		end

		local function findComment()
			first, last, match1 = find(xml, '^<!%-%-(.-)%-%->', pos)
			if first then
				finishText()
				if call.comment then call.comment(match1) end
				pos = last + 1
				text_start = pos
				return true
			end
		end

		local function nsForPrefix(prefix)
			if prefix == 'xml' then  -- http://www.w3.org/TR/xml-names/#ns-decl
				return 'http://www.w3.org/XML/1998/namespace'
			end
			for i = #ns_stack, 1, -1 do
				if ns_stack[i][prefix] then
					return ns_stack[i][prefix]
				end
			end
			error(format('Cannot find namespace for prefix %s', prefix))
		end

		local function startElement()
			elements_found = true
			first, last, match1 = find(xml, '^<([%a_][%w_.-]*)', pos)
			if first then
				elem[2] = nil -- reset the nsURI, since this table is re-used
				elem[3] = nil -- reset the nsPrefix, since this table is re-used
				finishText()
				pos = last + 1
				first, last, match2 = find(xml, '^:([%a_][%w_.-]*)', pos)
				if first then
					elem[1] = match2
					elem[3] = match1 -- Save the prefix for later resolution
					match1 = match2
					pos = last + 1
				else
					elem[1] = match1
					for i = #ns_stack, 1, -1 do
						if ns_stack[i]['!'] then
							elem[2] = ns_stack[i]['!']
							break
						end
					end
				end
				attrn = 0
				push(ns_stack, {})
				return true
			end
		end

		local function findAttribute()
			first, last, match1 = find(xml, '^%s+([:%a_][:%w_.-]*)%s*=%s*', pos)
			if first then
				pos2 = last + 1
				first, last, match2 = find(xml, '^"([^<"]*)"', pos2) -- FIXME: disallow non-entity ampersands
				if first then
					pos = last + 1
					match2 = unescape(match2)
				else
					first, last, match2 = find(xml, "^'([^<']*)'", pos2) -- FIXME: disallow non-entity ampersands
					if first then
						pos = last + 1
						match2 = unescape(match2)
					end
				end
			end
			if match1 and match2 then
				local attr = {match1, match2}
				local prefix,name = string.match(match1, '^([^:]+):([^:]+)$')
				if prefix then
					if prefix == 'xmlns' then
						ns_stack[#ns_stack][name] = match2
					else
						attr[1] = name
						attr[4] = prefix
					end
				else
					if match1 == 'xmlns' then
						ns_stack[#ns_stack]['!'] = match2
						elem[2] = match2
					end
				end
				attrn = attrn + 1
				attrs[attrn] = attr
				return true
			end
		end

		local function findCDATA()
			first, last, match1 = find( xml, '^<!%[CDATA%[(.-)%]%]>', pos)
			if first then
				finishText()
				if call.text then call.text(match1, true) end
				pos = last + 1
				text_start = pos
				return true
			end
		end

		local function closeElement()
			first, last, match1 = find(xml, '^%s*(/?)>', pos)
			if first then
				state = 'text'
				pos = last + 1
				text_start = pos

				-- Resolve namespace prefixes AFTER all new/redefined prefixes have been parsed
				if elem[3] then
					elem[2] = nsForPrefix(elem[3])
				end
				if call.start_tag then
					call.start_tag(unpack(elem))
				end
				if call.attr then
					for i=1,attrn do
						if attrs[i][4] then
							attrs[i][3] = nsForPrefix(attrs[i][4])
						end
						call.attr(unpack(attrs[i]))
					end
				end

				if match1 == '/' then
					pop(ns_stack)
					if call.end_tag then
						call.end_tag(unpack(elem))
					end
				end
				return true
			end
		end

		local function findElementClose()
			first, last, match1, match2 = find(xml, '^</([%a_][%w_.-]*)%s*>', pos)
			if first then
				nsURI = nil
				for i = #ns_stack, 1, -1 do
					if ns_stack[i]['!'] then
						nsURI = ns_stack[i]['!']
						break
					end
				end
			else
				first, last, match2, match1 = find(xml, '^</([%a_][%w_.-]*):([%a_][%w_.-]*)%s*>', pos)
				if first then nsURI = nsForPrefix(match2) end
			end
			if first then
				finishText()
				if call.end_tag then
					call.end_tag(match1,nsURI)
				end
				pos = last + 1
				text_start = pos
				pop(ns_stack)
				return true
			end
		end

		while pos < #xml do
			if state == 'text' then
				if not (findPI() or findComment() or findCDATA() or findElementClose()) then
					if startElement() then
						state = 'attributes'
					else
						first, last = find(xml, '^[^<]+', pos)
						pos = (first and last or pos) + 1
					end
				end
			elseif state == 'attributes' then
				if not findAttribute() then
					if not closeElement() then
						error'element not closed'
					end
				end
			end
		end

		assert(elements_found, 'no elements')
		assert(#ns_stack == 0, 'unclosed elements')
	end

	return parser
end

function M.parse(s, opt)
	return M.parser(opt):parse(s)
end

function M.dom(xml, opt)
	opt = opt or {}
	local rich = not opt.simple
	local push, pop = table.insert, table.remove
	local doc = {type = 'document', name = '#doc'}
	local current, stack = doc, {doc}
	local parser = M.parser{
		start_tag = function(name, nsURI, nsPrefix)
			local el = {type = 'element', name = name, el = rich and {} or nil,
				attr = {}, nsURI = nsURI, nsPrefix = nsPrefix, parent = rich and current or nil}
			if current==doc then
				if doc.root then
					error(format("element after root element: '%s'", name))
				end
				doc.root = rich and el or nil
			end
			push(current, el)
			if current.el then push(current.el, el) end
			current = el
			push(stack, el)
		end,
		attr = function(name, value, nsURI, nsPrefix)
			if not current or current.type ~= 'element' then
				error(format("attr %s=%s not inside element", name, value))
			end
			local attr = {type = 'attribute', name = name, nsURI = nsURI,
				nsPrefix = nsPrefix, value = value, parent = rich and current or nil}
			if rich then current.attr[name] = value end
			push(current.attr, attr)
		end,
		end_tag = function(name)
			if current.name ~= name or current.type ~= 'element' then
				error(format("closing '%s' inside '%s' %s", name, current.name, current.type))
			end
			pop(stack)
			current = stack[#stack]
		end,
		text = function(value,cdata)
			-- documents may only have text node children that are whitespace: https://www.w3.org/TR/xml/#NT-Misc
			if current.type == 'document' and not value:find'^%s+$' then
				error(format("non-whitespace text at root: '%s'", value))
			end
			push(current, {type = 'text', name = '#text', cdata = cdata and true or nil,
				value = value, parent = rich and current or nil})
		end,
		comment = function(value)
			push(current, {type = 'comment', name = '#comment', value = value,
				parent = rich and current or nil})
		end,
		pi = function(name, value)
			push(current, {type = 'pi', name = name, value = value,
				parent = rich and current or nil})
		end
	}
	parser:parse(xml, opt)
	return doc
end

local escmap = {["<"]="&lt;", [">"]="&gt;", ["&"]="&amp;", ['"']="&quot;", ["'"]="&apos;"}
local function esc(s) return s:gsub('[<>&"]', escmap) end

function M.format(n, opt)
	opt = opt or {}
	local out = {}
	local tab = opt.indent and (type(opt.indent) == 'number'
		and string.rep(' ', opt.indent) or opt.indent) or ''
	local ser = {}
	local omit = {}
	if opt.omit then
		for _,s in ipairs(opt.omit) do
			omit[s] = true
		end
	end

	function ser.document(n)
		for _,kid in ipairs(n) do
			if ser[kid.type] then ser[kid.type](kid,0) end
		end
	end

	function ser.pi(n,depth)
		depth = depth or 0
		table.insert(out, tab:rep(depth)..'<?'..n.name..' '..n.value..'?>')
	end

	function ser.element(n,depth)
		if n.nsURI and omit[n.nsURI] then return end
		depth = depth or 0
		local indent = tab:rep(depth)
		local name = n.nsPrefix and n.nsPrefix..':'..n.name or n.name
		local result = indent..'<'..name
		if n.attr and n.attr[1] then
			local sorted = n.attr
			if opt.sort then
				sorted = {}
				for i,a in ipairs(n.attr) do sorted[i] = a end
				table.sort(sorted, function(a, b)
					if a.nsPrefix and b.nsPrefix then
						return a.nsPrefix == b.nsPrefix and a.name < b.name or a.nsPrefix < b.nsPrefix
					elseif not (a.nsPrefix or b.nsPrefix) then
						return a.name < b.name
					elseif b.nsPrefix then
						return true
					else
						return false
					end
				end)
			end

			local attrs = {}
			for _,a in ipairs(sorted) do
				if (not a.nsURI or not omit[a.nsURI]) and not (omit[a.value]
					and a.name:find('^xmlns:'))
				then
					attrs[#attrs+1] = ' '..(a.nsPrefix and (a.nsPrefix..':') or '')
						..a.name..'="'..esc(a.value)..'"'
				end
			end
			result = result..table.concat(attrs,'')
		end
		result = result .. (n[1] and '>' or '/>')
		table.insert(out, result)
		if n[1] then
			for _,kid in ipairs(n) do
				if ser[kid.type] then ser[kid.type](kid,depth+1) end
			end
			table.insert(out, indent..'</'..name..'>')
		end
	end

	function ser.text(n,depth)
		if n.cdata then
			table.insert(out, tab:rep(depth)..'<![CDATA['..n.value..']]>')
		else
			table.insert(out, tab:rep(depth)..esc(n.value))
		end
	end

	function ser.comment(n,depth)
		table.insert(out, tab:rep(depth)..'<!--'..n.value..'-->')
	end

	ser[n.type](n, 0)

	return table.concat(out, opt.indent and '\n' or '')
end

return M
