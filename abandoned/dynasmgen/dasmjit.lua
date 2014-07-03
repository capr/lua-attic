--dasmjit (Cosmin Apreutesei, public domain)
--Based on DynAsm 1.3.0 from http://luajit.org/dynasm.html, Copyright (C) 2005-2014 Mike Pall, MIT License.

local ffi = require'ffi'

io.stdout:setvbuf'no'
io.stderr:setvbuf'no'

-- Cache library functions.
local type, pairs, ipairs = type, pairs, ipairs
local pcall, error, assert = pcall, error, assert
local sub, match, gmatch, gsub = string.sub, string.match, string.gmatch, string.gsub
local format, rep, upper = string.format, string.rep, string.upper
local remove, concat, sort = table.remove, table.concat, table.sort
local stdout, stderr = io.stdout, io.stderr

-- Global state for current file.
local g_lineno
local g_errcount = 0

-- Write buffer for output file.
local g_wbuffer

------------------------------------------------------------------------------

-- Write an output line (or callback function) to the buffer.
local function wline(line)
	local buf = g_wbuffer
	buf[#buf+1] = line
end

-- Dummy action flush function. Replaced with arch-specific function later.
local function wflush(term) end

-- Dump all buffered output lines.
local function wdumplines(out, buf)
	for _,line in ipairs(buf) do
		if type(line) == "string" then
			assert(out:write(line, "\n"))
		else
			-- Special callback to dynamically insert lines after end of processing.
			line(out)
		end
	end
end

------------------------------------------------------------------------------

-- Emit an error. Processing continues with next statement.
local function werror(msg)
	error(format("line %d: error: %s", g_lineno, msg), 0)
end

-- Emit a fatal error. Processing stops.
local function wfatal(msg)
	g_errcount = "fatal"
	werror(msg)
end

-- Print a warning. Processing continues.
local function wwarn(msg)
	stderr:write(format("line %d: warning: %s", g_lineno, msg))
end

-- Print caught error message. But suppress excessive errors.
local function wprinterr(...)
	if type(g_errcount) == "number" then
		-- Regular error.
		g_errcount = g_errcount + 1
		if g_errcount < 21 then -- Seems to be a reasonable limit.
			stderr:write(...)
		elseif g_errcount == 21 then
			stderr:write("warning: too many errors (suppressed further messages).\n")
		end
	else
		-- Fatal error.
		stderr:write(...)
		return true -- Stop processing.
	end
end

------------------------------------------------------------------------------

-- Core pseudo-opcodes.
local map_coreop = {}
-- Dummy opcode map. Replaced by arch-specific map.
local map_op = {}

-- Forward declarations.
local dostmt

------------------------------------------------------------------------------

-- Map for defines (initially empty, chains to arch-specific map).
local map_def = {}

-- Pseudo-opcode to define a substitution.
map_coreop[".define_2"] = function(params, nparams)
	if not params then return nparams == 1 and "name" or "name, subst" end
	local name, def = params[1], params[2] or "1"
	if not match(name, "^[%a_][%w_]*$") then werror("bad or duplicate define") end
	map_def[name] = def
end
map_coreop[".define_1"] = map_coreop[".define_2"]

-- Define a substitution on the command line.
function define(args)
	local namesubst = optparam(args)
	local name, subst = match(namesubst, "^([%a_][%w_]*)=(.*)$")
	if name then
		map_def[name] = subst
	elseif match(namesubst, "^[%a_][%w_]*$") then
		map_def[namesubst] = "1"
	else
		wfatal("bad define")
	end
end

-- Undefine a substitution on the command line.
function undef(args)
	local name = optparam(args)
	if match(name, "^[%a_][%w_]*$") then
		map_def[name] = nil
	else
		wfatal("bad define")
	end
end

-- Helper for definesubst.
local gotsubst

local function definesubst_one(word)
	local subst = map_def[word]
	if subst then gotsubst = word; return subst else return word end
end

-- Iteratively substitute defines.
local function definesubst(stmt)
	-- Limit number of iterations.
	for i=1,100 do
		gotsubst = false
		stmt = gsub(stmt, "#?[%w_]+", definesubst_one)
		if not gotsubst then break end
	end
	if gotsubst then wfatal("recursive define involving `"..gotsubst.."'") end
	return stmt
end

------------------------------------------------------------------------------

-- Support variables for conditional assembly.
local condlevel = 0
local condstack = {}

-- Evaluate condition with a Lua expression. Substitutions already performed.
local function cond_eval(cond)
	local func, err
	if setfenv then
		func, err = loadstring("return "..cond, "=expr")
	else
		-- No globals. All unknown identifiers evaluate to nil.
		func, err = load("return "..cond, "=expr", "t", {})
	end
	if func then
		if setfenv then
			setfenv(func, {}) -- No globals. All unknown identifiers evaluate to nil.
		end
		local ok, res = pcall(func)
		if ok then
			if res == 0 then return false end -- Oh well.
			return not not res
		end
		err = res
	end
	wfatal("bad condition: "..err)
end

-- Skip statements until next conditional pseudo-opcode at the same level.
local function stmtskip()
	local dostmt_save = dostmt
	local lvl = 0
	dostmt = function(stmt)
		local op = match(stmt, "^%s*(%S+)")
		if op == ".if" then
			lvl = lvl + 1
		elseif lvl ~= 0 then
			if op == ".endif" then lvl = lvl - 1 end
		elseif op == ".elif" or op == ".else" or op == ".endif" then
			dostmt = dostmt_save
			dostmt(stmt)
		end
	end
end

-- Pseudo-opcodes for conditional assembly.
map_coreop[".if_1"] = function(params)
	if not params then return "condition" end
	local lvl = condlevel + 1
	local res = cond_eval(params[1])
	condlevel = lvl
	condstack[lvl] = res
	if not res then stmtskip() end
end

map_coreop[".elif_1"] = function(params)
	if not params then return "condition" end
	if condlevel == 0 then wfatal(".elif without .if") end
	local lvl = condlevel
	local res = condstack[lvl]
	if res then
		if res == "else" then wfatal(".elif after .else") end
	else
		res = cond_eval(params[1])
		if res then
			condstack[lvl] = res
			return
		end
	end
	stmtskip()
end

map_coreop[".else_0"] = function(params)
	if condlevel == 0 then wfatal(".else without .if") end
	local lvl = condlevel
	local res = condstack[lvl]
	condstack[lvl] = "else"
	if res then
		if res == "else" then wfatal(".else after .else") end
		stmtskip()
	end
end

map_coreop[".endif_0"] = function(params)
	local lvl = condlevel
	if lvl == 0 then wfatal(".endif without .if") end
	condlevel = lvl - 1
end

-- Check for unfinished conditionals.
local function checkconds()
	if g_errcount ~= "fatal" and condlevel ~= 0 then
		wprinterr("error: unbalanced conditional\n")
	end
end

------------------------------------------------------------------------------

-- Make conditionals initially available, too.
map_op[".if_1"] = map_coreop[".if_1"]
map_op[".elif_1"] = map_coreop[".elif_1"]
map_op[".else_0"] = map_coreop[".else_0"]
map_op[".endif_0"] = map_coreop[".endif_0"]

------------------------------------------------------------------------------

-- Support variables for macros.
local mac_capture, mac_lineno, mac_name
local mac_active = {}
local mac_list = {}

-- Pseudo-opcode to define a macro.
map_coreop[".macro_*"] = function(mparams)
	if not mparams then return "name [, params...]" end
	-- Split off and validate macro name.
	local name = remove(mparams, 1)
	if not name then werror("missing macro name") end
	if not (match(name, "^[%a_][%w_%.]*$") or match(name, "^%.[%w_%.]*$")) then
		wfatal("bad macro name `"..name.."'")
	end
	-- Validate macro parameter names.
	local mdup = {}
	for _,mp in ipairs(mparams) do
		if not match(mp, "^[%a_][%w_]*$") then
			wfatal("bad macro parameter name `"..mp.."'")
		end
		if mdup[mp] then wfatal("duplicate macro parameter name `"..mp.."'") end
		mdup[mp] = true
	end
	-- Check for duplicate or recursive macro definitions.
	local opname = name.."_"..#mparams
	if map_op[opname] or map_op[name.."_*"] then
		wfatal("duplicate macro `"..name.."' ("..#mparams.." parameters)")
	end
	if mac_capture then wfatal("recursive macro definition") end

	-- Enable statement capture.
	local lines = {}
	mac_lineno = g_lineno
	mac_name = name
	mac_capture = function(stmt) -- Statement capture function.
		-- Stop macro definition with .endmacro pseudo-opcode.
		if not match(stmt, "^%s*.endmacro%s*$") then
			lines[#lines+1] = stmt
			return
		end
		mac_capture = nil
		mac_lineno = nil
		mac_name = nil
		mac_list[#mac_list+1] = opname
		-- Add macro-op definition.
		map_op[opname] = function(params)
			if not params then return mparams, lines end
			-- Protect against recursive macro invocation.
			if mac_active[opname] then wfatal("recursive macro invocation") end
			mac_active[opname] = true
			-- Setup substitution map.
			local subst = {}
			for i,mp in ipairs(mparams) do subst[mp] = params[i] end
			-- Loop through all captured statements
			for _,stmt in ipairs(lines) do
				-- Substitute macro parameters.
				local st = gsub(stmt, "[%w_]+", subst)
				st = definesubst(st)
				st = gsub(st, "%s*%.%.%s*", "") -- Token paste a..b.
				-- Emit statement. Use a protected call for better diagnostics.
				local ok, err = pcall(dostmt, st)
				if not ok then
					-- Add the captured statement to the error.
					wprinterr(err, "\n", stmt, "\t[MACRO ", name, " (", #mparams, ")]\n")
				end
			end
			mac_active[opname] = nil
		end
	end
end

-- An .endmacro pseudo-opcode outside of a macro definition is an error.
map_coreop[".endmacro_0"] = function(params)
	wfatal(".endmacro without .macro")
end

-- Dump all macros and their contents (with -PP only).
local function dumpmacros(out, lvl)
	sort(mac_list)
	out:write("Macros:\n")
	for _,opname in ipairs(mac_list) do
		local name = sub(opname, 1, -3)
		local params, lines = map_op[opname]()
		out:write(format("  %-20s %s\n", name, concat(params, ", ")))
		if lvl > 1 then
			for _,line in ipairs(lines) do
				out:write("  ", line, "\n")
			end
			out:write("\n")
		end
	end
	out:write("\n")
end

-- Check for unfinished macro definitions.
local function checkmacros()
	if mac_capture then
		wprinterr('line', mac_lineno, ": error: unfinished .macro `", mac_name ,"'\n")
	end
end

------------------------------------------------------------------------------

local actlist

-- Load architecture-specific module.
local function loadarch(arch)
	local m_arch = require('dasmjit_'..arch)
	wflush, actlist = m_arch.passcb(wline, werror, wfatal, wwarn)
	map_op, map_def = m_arch.mergemaps(map_coreop, map_def)
end

------------------------------------------------------------------------------

-- Dummy pseudo-opcode. Don't confuse '.nop' with 'nop'.
map_coreop[".nop_*"] = function(params)
	if not params then return "[ignored...]" end
end

-- Pseudo-opcodes to raise errors.
map_coreop[".error_1"] = function(params)
	if not params then return "message" end
	werror(params[1])
end

map_coreop[".fatal_1"] = function(params)
	if not params then return "message" end
	wfatal(params[1])
end

------------------------------------------------------------------------------

-- Helper for splitstmt.
local splitlvl

local function splitstmt_one(c)
	if c == "(" then
		splitlvl = ")"..splitlvl
	elseif c == "[" then
		splitlvl = "]"..splitlvl
	elseif c == "{" then
		splitlvl = "}"..splitlvl
	elseif c == ")" or c == "]" or c == "}" then
		if sub(splitlvl, 1, 1) ~= c then werror("unbalanced (), [] or {}") end
		splitlvl = sub(splitlvl, 2)
	elseif splitlvl == "" then
		return " \0 "
	end
	return c
end

-- Split statement into (pseudo-)opcode and params.
local function splitstmt(stmt)
	-- Convert label with trailing-colon into .label statement.
	local label = match(stmt, "^%s*(.+):%s*$")
	if label then return ".label", {label} end

	-- Split at commas and equal signs, but obey parentheses and brackets.
	splitlvl = ""
	stmt = gsub(stmt, "[,%(%)%[%]{}]", splitstmt_one)
	if splitlvl ~= "" then werror("unbalanced () or []") end

	-- Split off opcode.
	local op, other = match(stmt, "^%s*([^%s%z]+)%s*(.*)$")
	if not op then werror("bad statement syntax") end

	-- Split parameters.
	local params = {}
	for p in gmatch(other, "%s*(%Z+)%z?") do
		params[#params+1] = gsub(p, "%s+$", "")
	end
	if #params > 16 then werror("too many parameters") end

	params.op = op
	return op, params
end

dostmt = function(stmt)
	-- Ignore empty statements.
	if match(stmt, "^%s*$") then return end

	-- Capture macro defs before substitution.
	if mac_capture then return mac_capture(stmt) end

	-- Substitute defines.
	stmt = definesubst(stmt)

	-- Split into (pseudo-)opcode and params.
	local op, params = splitstmt(stmt)

	-- Get opcode handler (matching # of parameters or generic handler).
	local f = map_op[op.."_"..#params] or map_op[op.."_*"]
	if not f then
		-- Improve error report.
		for i=0,9 do
			if map_op[op.."_"..i] then
				werror("wrong number of parameters for `"..op.."'")
			end
		end
		werror("unknown statement `"..op.."'")
	end

	-- Call opcode handler or special handler for template strings.
	if type(f) == "string" then
		local help = #params > 0 and map_op[".template__"](nil, f, 0) or ''
		print()
		print(stmt:gsub('^%s*', ''), require'pp'.format(params), help)
		print'-------------------------------------'
		map_op[".template__"](params, f)
	else
		local help = #params > 0 and f() or ''
		print()
		print(
				(map_op[op.."_"..#params] and (op.."_"..#params)) or
				(map_op[op.."_*"] and (op.."_*")) or '', help, require'pp'.format(params))
		print'-------------------------------------'
		f(params)
	end
end

local function doline(aline)
	-- Strip assembler comments.
	aline = gsub(aline, "//.*$", "")

	-- Split line into statements at semicolons.
	if match(aline, ";") then
		for stmt in gmatch(aline, "[^;]+") do dostmt(stmt) end
	else
		dostmt(aline)
	end
end

local function dostring(s)
	-- Split string into lines.
	if match(s, "[\n\r]") then
		for line in gmatch(s, "[^\n\r]+") do
			doline(line)
		end
	else
		doline(s)
	end
end

local function dumpopcodes(out)
	out = out or io.stdout

	local t = {}
	for name in pairs(map_coreop) do t[#t+1] = name end
	for name in pairs(map_op) do t[#t+1] = name end
	sort(t)

	local pseudo = true
	out:write("Pseudo-Opcodes:\n")
	for _,sname in ipairs(t) do
		local name, nparam = match(sname, "^(.+)_([0-9%*])$")
		if name then
			if pseudo and sub(name, 1, 1) ~= "." then
				out:write("\nOpcodes:\n")
				pseudo = false
			end
			local f = map_op[sname]
			local s
			if nparam ~= "*" then nparam = nparam + 0 end
			if nparam == 0 then
				s = ""
			elseif type(f) == "string" then
				s = map_op[".template__"](nil, f, nparam)
			else
				s = f(nil, nparam)
			end
			if type(s) == "table" then
				for _,s2 in ipairs(s) do
					out:write(format("  %-12s %s\n", name, s2))
				end
			else
				out:write(format("  %-12s %s\n", name, s))
			end
		end
	end
	out:write("\n")
end

local mmap, munmap

if ffi.os == 'Windows' then

	local winapi = require'winapi'
	require'winapi.memory'

	function mmap(sz) --will alloc multiple of 64k
		local p = winapi.VirtualAlloc(nil, sz, 'MEM_RESERVE|MEM_COMMIT', 'PAGE_READWRITE')
		winapi.VirtualProtect(p, sz, 'PAGE_EXECUTE_READ')
		return p
	end

elseif ffi.os == 'Linux' or ffi.os == 'OSX' then

	function mmap(size)
		local p = checknz(mmap(nil, sz, 'PROT_READ|PROT_WRITE', 'MAP_PRIVATE|MAP_ANONYMOUS', -1, 0))
		mprotect(p, sz, 'PROT_READ|PROT_EXEC')
		return p
	end

end

if not ... then
local pp = require'pp'

g_wbuffer = {}
g_indent = ""
g_lineno = 0

loadarch'x86'
--dostmt'mov ax, bx'
--[=[dostring[[
1:
->mylabel:
=>pcexpr:
jmp =>a+d
.type str, MyStruct, edx
mov ax, 5
.macro mymacro, x, y
	mov ax, x
	mov eax, ah
	mov bx, y
.endmacro
mymacro 5, d
.define OSX
.if OSX; mov ax, bx; .endif

]]
]=]
--dostring'mov Rw(x+y), 5'
dostring[[
->l1:
//mov ax, bx
//jmp ->l1
.define MOVE, mov
.define REG, bx
.define PREG, eax
.define IMM1, PREG
.define IMM2, 5
MOVE REG, [IMM1+IMM2]
//jmp dword [0xABC]
//jmp byte [0x5]
//mov ax, Rd(5)
//.type STR, MyStruct, edx
//mov STR:ebx, 5
]]

checkconds()
checkmacros()

print()
print()
print'-------------------------------------'
wflush()
print(require'pp'.format(actlist))
local asm = string.char(unpack(actlist))
local disass = require'jit.dis_x86'.disass
disass(asm, 0, io.write)

wdumplines(stdout, g_wbuffer)

if true then
print()
print()
print'-------------------------------------'
local x86 = require'dasmjit_x86'
--x86.dumparch()
x86.dumpdef()
dumpmacros(stdout, 0)
dumpopcodes()
end

end

