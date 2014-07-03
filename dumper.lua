local glue = require'glue'
local dynasm = require'dynasm'
local ffi = require'ffi'
local dasm = require'dasm'
local x64 = ffi.arch == 'x64'

local _ = string.format
local out = function(...) io.stdout:write(...) end
local s = ('-'):rep(80)
local hr = function() out(s, '\n') end

local function asmfunc(asm, env, ctype, ...)
	local asm = _([[
	local ffi = require'ffi'
	local dasm = require'dasm'
	|.arch ARCH
	|.actionlist actions
	return function(Dst)
		%s
	end, actions
	]], asm)
	print(dynasm.translate_tostring(dynasm.string_infile(asm), {lang = "lua"}))
	local chunk = assert(dynasm.loadstring(asm))
	if env then
		setmetatable(env, {__index = _G})
		setfenv(chunk, env)
	end
	local gencode, actions = chunk()
	local st = dasm.new(actions)
	gencode(st)
	local buf, sz = st:build()
	dasm.dump(buf, sz); --out'\n'
	out'\n'
	local fptr = ffi.cast(ctype, buf)
	return function(...)
		local _ = buf -- pin it
		return fptr(...)
	end
end

ffi.cdef[[
typedef union __attribute__((__packed__)) D_BYTE {
	uint8_t   uint8;
	int8_t    int8;
} D_BYTE;

typedef union __attribute__((__packed__)) D_WORD {
	uint8_t  uint8[2];
	int8_t   int8[2];
	D_BYTE   byte[2];
	uint16_t uint16;
	int16_t  int16;
	struct { D_BYTE lo, hi; };
} D_WORD;

typedef union __attribute__((__packed__)) D_DWORD {
	uint8_t  uint8[4];
	int8_t   int8[4];
	D_BYTE   byte[4];
	uint16_t uint16[2];
	int16_t  int16[2];
	D_WORD   word[2];
	uint32_t uint32;
	int32_t  int32;
	float    floatval;
	struct { D_WORD lo, hi; };
} D_DWORD;

typedef union __attribute__((__packed__)) D_QWORD {
	uint8_t  uint8[8];
	int8_t   int8[8];
	D_BYTE   byte[8];
	uint16_t uint16[4];
	int16_t  int16[4];
	D_WORD   word[4];
	uint32_t uint32[2];
	int32_t  int32[2];
	D_DWORD  dword[2];
	uint64_t uint64;
	int64_t  int64;
	double   doubleval;
	struct { D_DWORD lo, hi; };
} D_QWORD;

typedef union __attribute__((__packed__)) D_DQWORD {
	uint8_t  uint8[16];
	int8_t   int8[16];
	D_BYTE   byte[16];
	uint16_t uint16[8];
	int16_t  int16[8];
	D_WORD   word[8];
	uint32_t uint32[4];
	int32_t  int32[4];
	D_DWORD  dword[4];
	uint64_t uint64[2];
	int64_t  int64[2];
	D_QWORD  qword[2];
	struct { D_QWORD lo, hi; };
} D_DQWORD;

typedef union __attribute__((__packed__)) D_TWORD {
	uint8_t  uint8[10];
	int8_t   int8[10];
	D_BYTE    byte[10];
	uint16_t uint16[5];
	int16_t  int16[5];
	D_WORD    word[5];
	uint32_t lo;
	uint32_t hi;
	uint16_t ex;
} D_TWORD;

typedef struct D_EFLAGS {
	uint32_t CF: 1;  // 0
	uint32_t _1: 1;
	uint32_t PF: 1;  // 2
	uint32_t _2: 1;
	uint32_t AF: 1;  // 4
	uint32_t _3: 1;
	uint32_t ZF: 1;  // 6
	uint32_t SF: 1;  // 7
	uint32_t TF: 1;  // 8
	uint32_t IF: 1;  // 9
	uint32_t DF: 1;  // 10
	uint32_t OF: 1;  // 11
	uint32_t IOPL: 2; // 12-13
	uint32_t NT: 1;  // 14
	uint32_t _4: 1;
	uint32_t RF: 1;  // 16
	uint32_t VM: 1;  // 17
	uint32_t AC: 1;  // 18
	uint32_t VIF: 1; // 19
	uint32_t VIP: 1; // 20
	uint32_t ID: 1;  // 21
} D_EFLAGS;

typedef struct D_FCW {
	uint16_t IM: 1;  // 0
	uint16_t DM: 1;  // 1
	uint16_t ZM: 1;  // 2
	uint16_t OM: 1;  // 3
	uint16_t UM: 1;  // 4
	uint16_t PM: 1;  // 5
	uint16_t _1: 1;
	uint16_t IEM:1;  // 7
	uint16_t PC: 2;  // 8-9
	uint16_t RC: 2;  // 10-11
	uint16_t IC: 1;  // 12
} D_FCW;

typedef struct D_FSW {
	uint16_t I:  1; // 0
	uint16_t D:  1; // 1
	uint16_t Z:  1; // 2
	uint16_t O:  1; // 3
	uint16_t U:  1; // 4
	uint16_t P:  1; // 5
	uint16_t SF: 1; // 6
	uint16_t IR: 1; // 7
	uint16_t C0: 1; // 8
	uint16_t C1: 1; // 9
	uint16_t C2: 1; // 10
	uint16_t TOP:3; // 11-13
	uint16_t C3: 1; // 14
	uint16_t B:  1; // 15
} D_FSW;

typedef struct D_FTW {
	uint16_t _1; // TODO
} D_FTW;

typedef struct D_FTWX {
	uint8_t _1; // TODO
} D_FTWX;

typedef struct __attribute__((__packed__)) D_FSTENV {
	D_FCW     FCW;
	uint16_t  _fstenv_1;
	D_FSW     FSW;
	uint16_t  _fstenv_2;
	D_FTW TW;
	uint16_t  _fstenv_3;
	uint32_t  FPU_IP;
	uint16_t  FPU_CS;
	uint16_t  _fstenv_4;
	uint32_t  FPU_OP;
	uint16_t  FPU_DS;
	uint16_t  _fstenv_5;
} D_FSTENV;

typedef struct D_MXCSR {
	uint32_t IE: 1; // 0
	uint32_t DE: 1; // 1
	uint32_t ZE: 1; // 2
	uint32_t OE: 1; // 3
	uint32_t UE: 1; // 4
	uint32_t PE: 1; // 5
	uint32_t DAZ:1; // 6
	uint32_t IM: 1; // 7
	uint32_t DM: 1; // 8
	uint32_t ZM: 1; // 9
	uint32_t OM: 1; // 10
	uint32_t UM: 1; // 11
	uint32_t PM: 1; // 12
	uint32_t RM: 2; // 13-14 (round mode)
	uint32_t FZ: 1; // 15
} D_MXCSR;

typedef struct __attribute__((__packed__)) D_FPRX {
	D_TWORD;       // 10 bytes
	uint8_t _1[6]; // 6 bytes padding
} D_FPRX;

typedef struct D_FXSAVE {
	D_FCW      FCW;
	D_FSW      FSW;
	D_FTWX     FTWX;
	uint8_t    _1;
	uint16_t   FOP;
	union {
		struct {
			uint32_t  FPU_IP;
			uint16_t  FPU_CS;
			uint16_t  __1;
			uint32_t  FPU_DP;
			uint16_t  FPU_DS;
			uint16_t  __2;
		} x86;
		struct {
			uint64_t  FPU_IP;
			uint64_t  FPU_DP;
		} x64;
	};
	D_MXCSR    MXCSR;
	uint32_t   MXCSR_MASK;
	D_FPRX     FPR[8];
	D_DQWORD   XMM[16];
	uint8_t    _2[96];
} D_FXSAVE;

typedef struct __attribute__((__packed__)) MemDump {
	D_FXSAVE;         // must be first in struct! fxsave needs this aligned to 16 bytes.
	//D_FSTENV FSTENV;  // alternative

	// CPU state
	D_DWORD EAX, EBX, ECX, EDX, ESI, EDI, EBP, ESP;
	D_EFLAGS EFLAGS;

	// FPU state
	//D_QWORD ST[8];

	// STACK state
	uint32_t stack_size;
	D_DWORD stack[4096];  // top-to-bottom (ESP -> EBP)
} MemDump;
]]

assert(ffi.sizeof('D_BYTE') == 1)
assert(ffi.sizeof('D_WORD') == 2)
assert(ffi.sizeof('D_DWORD') == 4)
assert(ffi.sizeof('D_QWORD') == 8)
assert(ffi.sizeof('D_TWORD') == 10)
assert(ffi.sizeof('D_FSTENV') == 28)
assert(ffi.sizeof('D_FPRX') == 16)
assert(ffi.sizeof('D_FXSAVE') == 512)

local D_EFLAGS = {
	title = 'EFLAGS', stitle = 'EF', mdfield = 'EFLAGS',
	fields = {'CF', 'PF', 'AF', 'ZF', 'SF', 'TF', 'IF', 'DF', 'OF',
				'IOPL', 'NT', 'RF', 'VM', 'AC', 'VIF', 'VIP', 'ID'},
	descr = {
		CF    = 'Carry',
		PF    = 'Parity',
		AF    = 'Auxiliary carry',
		ZF    = 'Zero',
		SF    = 'Sign',
		TF    = 'Trap',
		IF    = 'Interrupt enable',
		DF    = 'Direction',
		OF    = 'Overflow',
		IOPL  = 'I/O Priviledge level',
		NT    = 'Nested task',
		RF    = 'Resume',
		VM    = 'Virtual 8086 mode',
		AC    = 'Alignment check',
		VIF   = 'Virutal interrupt',
		VIP   = 'Virtual interrupt pending',
		ID    = 'ID',
	},
}

local D_FSW = {
	title = 'FPU STATUS WORD', stitle = 'FSW', mdfield = 'FSW',
	fields = {'I', 'D', 'Z', 'O', 'U', 'P', 'SF', 'IR', 'C0', 'C1', 'C2', 'TOP', 'C3', 'B'},
	descr = {
		I   = 'Invalid operation exception',
		D   = 'Denormalized exception',
		Z   = 'Zero divide exception',
		O   = 'Overflow exception',
		U   = 'Underflow exception',
		P   = 'Precision exception',
		SF  = 'Stack Fault exception',
		IR  = 'Interrupt Request',
		C0  = 'C0',
		C1  = 'C1',
		C2  = 'C2',
		TOP = 'TOP',
		C3  = 'C3',
		B   = 'Busy',
	},
}

local D_FCW = {
	title = 'FPU CONTROL WORD', stitle = 'FCW', mdfield = 'FCW',
	fields = {'IM', 'DM', 'ZM', 'OM', 'UM', 'PM', 'IEM', 'PC', 'RC', 'IC'},
	descr = {
		IM  = 'Invalid operation mask',
		DM  = 'Denormalized operand mask',
		ZM  = 'Zero divide mask',
		OM  = 'Overflow mask',
		UM  = 'Underflow mask',
		PM  = 'Precision mask',
		IEM = 'Interrupt Enable mask',
		PC  = 'Precision Control mask',
		RC  = 'Rounding Control mask',
		IC  = 'Infinity Control mask',
	},
}

local D_MXCSR = {
	title = 'SSE CONTROL/STATUS FLAG', stitle = 'MXCSR', mdfield = 'MXCSR',
	fields = {'IE', 'DE', 'ZE', 'OE', 'UE', 'PE', 'DAZ', 'IM',
				'DM', 'ZM', 'OM', 'UM', 'PM', 'RM', 'FZ'},
	descr = {
		FZ	= 'Flush To Zero',
		RM = 'Round Mode',
		PM = 'Precision Mask',
		UM = 'Underflow Mask',
		OM = 'Overflow Mask',
		ZM = 'Divide By Zero Mask',
		DM = 'Denormal Mask',
		IM = 'Invalid Operation Mask',
		DAZ = 'Denormals Are Zero',
		PE = 'Precision Flag',
		UE = 'Underflow Flag',
		OE = 'Overflow Flag',
		ZE = 'Divide By Zero Flag',
		DE = 'Denormal Flag',
		IE = 'Invalid Operation Flag',
	},
}

local asm = [[
	|.type MD, MemDump, eax
	|
	| pushfd
	| push eax
	|
	| mov eax, ffi.cast('void*', md)
   |
	| mov MD.EBX, ebx
	| mov MD.ECX, ecx
	| mov MD.EDX, edx
	| mov MD.ESI, esi
	| mov MD.EDI, edi
	| mov MD.EBP, ebp
	|
	| mov ecx, eax
	| pop eax
	| mov MD:ecx.EAX, eax
	| mov eax, ecx
	|
	| pop ecx
	| mov MD.EFLAGS, ecx
	|
	| mov MD.ESP, esp
	|
	| fldpi
	| fldpi
	| fldpi

	| push 0x12345678
   | push 0x9abcdef0
   | push 0xfedbca98
   | push 0x76543210
   | //movdqa xmm0, [esp]
	| add esp, 16

	--[==[
	-- dump the FPU state, control and tag regs
	| //fstsw word MD.FSW
	| //fstcw word MD.FCW
	| fstenv MD.FSTENV

	-- dump the FPU regs raw
	local RAWST0 = ffi.offsetof('MemDump', 'RAWST')
	for i=0,7 do
		| fstp tword [eax+RAWST0+i*10]
	end

	-- load the FPU regs back so we can dump them again
	for i=7,0,-1 do
		| fld tword [eax+RAWST0+i*10]
	end

	-- dump the FPU regs as double
	local ST0 = ffi.offsetof('MemDump', 'ST')
	for i=0,7 do
		| fstp qword [eax+ST0+i*8]
	end

	-- dump the SSE MXCSR reg
	| stmxcsr dword MD.MXCSR

	-- dump the XMM regs as double
	local XMM0 = ffi.offsetof('MemDump', 'XMM')
	for i=0,7 do
		| movsd xmm(i), qword [eax+XMM0+i*8]
	end
	]==]

	| fxsave [eax]

	|
	| push ebx
	|
	| mov ecx, eax
	| mov edx, esp
	| add edx, 4 // skip just-pushed ebx
	|
	|->loop:
	|
	| // check frame
	| cmp edx, ebp
	| jae ->end
	|
	| // check count
	| mov ebx, ecx
	| sub ebx, eax
	| shr ebx, 2
	| cmp ebx, 4096
	| ja ->end
	|
	| // save, advance and go back
	| mov ebx, [edx]
	| mov MD:ecx.stack, ebx
	| add edx, 4
	| add ecx, 4
	| jmp ->loop
	|
	|->end:
	| sub ecx, eax
	| shr ecx, 2
	| mov MD.stack_size, ecx
   |
	| pop ebx
	| ret
]]

--like ffi.new() but we can specify an alignment of the start address, plus we get a pointer to ct, not a ct.
local function aligned_new(align, ctype, ...)
	local ct   = ffi.typeof(ctype, ...)
	local buf  = ffi.new('uint8_t[?]', ffi.sizeof(ct) + align)
	local nptr = ffi.cast('uintptr_t', buf)
	local nptr = nptr / align * align + align
	local ptr  = ffi.cast(ffi.typeof('$*', ct), nptr)
	ffi.gc(ptr, function(ptr)
		local _ = buf --anchor buf
	end)
	return ptr
end

local function mkframe(ctype)
	local md = aligned_new(16, 'MemDump') --aligned alloc (fxsave needs it)
	local frame = asmfunc(asm, {md = md}, ctype)
	return function(...)
		local _ = md --pin it
		return md, frame(...)
	end
end

local function dumpframe()

	local function out_dwords(dwords)
		local fmt = '%-8s 0x%08X   %10d   %6d   %6d   %6d   %6d\n'
		out(_(      '%-8s     %8s   %10s   %6s   %6s   %6s   %6s\n',
			'name', '0x u32', 'i32', 'hi.u16', 'lo.u16', 'hi.u8', 'lo.u8'))
		hr()
		for name,val in dwords() do
			out(_(fmt, name,
				val.uint32,
				val.int32,
				val.hi.uint16,
				val.lo.uint16,
				val.lo.hi.uint8,
				val.lo.lo.uint8))
		end
		out'\n'
	end

	local cpu_regs = {
		'EAX', 'EBX', 'ECX', 'EDX',
		'ESI', 'EDI', 'EBP', 'ESP',
	}

	local function out_gpr(md)
		out'CPU REGISTERS:\n'
		out_dwords(function()
			local i = 0
			return function()
				i = i + 1
				if not cpu_regs[i] then return end
				return cpu_regs[i]:lower(), md[cpu_regs[i]]
			end
		end)
	end

	local function out_xmm(md)
		out'SSE REGISTERS:\n'
		out_dwords(function()
			return coroutine.wrap(function()
				for i=0,7 do
					for j=0,3 do
						coroutine.yield('xmm'..i..'.dw'..j, md.XMM[i].dword[j])
					end
				end
			end)
		end)
	end

	local function out_stack(md)
		out(_('STACK (%d DWORDs):\n', md.stack_size))
		out_dwords(function()
			local i = -1
			return function()
				i = i + 1
				if i >= md.stack_size then return end
				local name = _('esp+%d', tostring(i) * 4)
				return name, md.stack[i]
			end
		end)
	end

	local function out_streg(md, n, k)
		out(_('st(%d)   ', n), _('0x%04X%08X%08X    ', md.FPR[k].ex, md.FPR[k].hi, md.FPR[k].lo),
			--_('%g', md.FPR[k].doubleval),
			'\n')
	end

	local function out_fpr(md)
		out'FPU REGISTERS:\n'
		hr()
		for i=0,7 do
			out_streg(md, i, i)
		end
		out'\n'
	end

	local function flag_dumper(def)
		local function longdump(md)
			out(_('%s:\n', def.title))
			hr()
			local mdfield = type(def.mdfield) == 'string' and md[def.mdfield] or def.mdfield(md)
			for i,name in ipairs(def.fields) do
				out(_('%-8s', name), _('%-8d', mdfield[name]), def.descr[name], '\n')
			end
			out'\n'
		end
		local function shortdump(md)
			out(_('%-5s ', def.stitle))
			local mdfield = type(def.mdfield) == 'string' and md[def.mdfield] or def.mdfield(md)
			for i,name in ipairs(def.fields) do
				out(_('%-2s=%d ', name, mdfield[name]))
			end
			out'\n'
		end
		return function(md, long)
			if long then longdump(md) else shortdump(md) end
		end
	end

	local out_eflags = flag_dumper(D_EFLAGS)
	local out_fsw    = flag_dumper(D_FSW)
	local out_fcw    = flag_dumper(D_FCW)
	local out_mxcsr  = flag_dumper(D_MXCSR)

	local caller = mkframe('void(*)(double, int, int, int, int, int)')
	local md = caller(0x2222, 0x3333, 0x4444, 0x5555, 0x6666, 0x7777)

	out_gpr(md)
	out_fpr(md)
	out_xmm(md)
	out_stack(md)

	out_eflags(md)
	out_mxcsr(md)
	out_fsw(md)
	out_fcw(md)
end

dumpframe()
