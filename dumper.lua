local glue = require'glue'
local dynasm = require'dynasm'
local ffi = require'ffi'
local dasm = require'dasm'
local x64 = ffi.arch == 'x64'

local _ = string.format
local out = function(...) io.stdout:write(...) end
local s = ('-'):rep(x64 and 140 or 96)
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
	--print(dynasm.translate_tostring(dynasm.string_infile(asm), {lang = "lua"}))
	local chunk = assert(dynasm.loadstring(asm))
	if env then
		setmetatable(env, {__index = _G})
		setfenv(chunk, env)
	end
	local gencode, actions = chunk()
	local st = dasm.new(actions)
	gencode(st)
	local buf, sz = st:build()
	--dasm.dump(buf, sz); --out'\n'
	out'\n'
	local fptr = ffi.cast(ctype, buf)
	return function(...)
		local _ = buf -- pin it
		return fptr(...)
	end
end

local cvt80to64 = asmfunc([[
	| mov eax, dword [esp+4]
	| fld tword [eax]
	| ret
]], {}, 'double(*)(uint8_t*)')


--https://github.com/Itseez/opencv/blob/master/modules/core/include/opencv2/core/cvdef.h
local function isnan(q)
	return bit.band(q.hi.uval, 0x7fffffff) + (q.lo.uval ~= 0 and 1 or 0) > 0x7ff00000
end

local function isnanf(d)
	return bit.band(d.uval, 0x7fffffff) + (d.lo.uval ~= 0 and 1 or 0) > 0x7ff00000
end

ffi.cdef[[
typedef union __attribute__((__packed__)) D_BYTE {
	uint8_t  bval;
	uint8_t  uval;
	int8_t   sval;
} D_BYTE;

typedef union __attribute__((__packed__)) D_WORD {
	D_BYTE   bytes[2];
	struct { D_BYTE lo, hi; };
	uint8_t  bval[2];
	uint16_t uval;
	int16_t  sval;
} D_WORD;

typedef union __attribute__((__packed__)) D_DWORD {
	D_BYTE   bytes[4];
	D_WORD   words[2];
	struct { D_WORD lo, hi; };
	uint8_t  bval[4];
	uint32_t uval;
	int32_t  sval;
	float    fval;
} D_DWORD;

typedef union __attribute__((__packed__)) D_QWORD {
	D_BYTE   bytes[8];
	D_WORD   words[4];
	D_DWORD  dwords[2];
	struct { D_DWORD lo, hi; };
	uint8_t  bval[8];
	uint64_t uval;
	int64_t  sval;
	double   fval;
} D_QWORD;

typedef union __attribute__((__packed__)) D_DQWORD {
	D_BYTE   bytes[16];
	D_WORD   words[8];
	D_DWORD  dwords[4];
	D_QWORD  qwords[2];
	struct { D_QWORD lo, hi; };
	uint8_t  bval[16];
} D_DQWORD;

typedef union __attribute__((__packed__)) D_TWORD {
	D_BYTE   bytes[10];
	struct __attribute__((__packed__)) {
		int64_t mantissa;
		struct {
			uint16_t exponent: 15;
			uint16_t sign: 1;
		};
	};
	uint8_t  bval[10];
} D_TWORD;

typedef union __attribute__((__packed__)) D_EFLAGS {
	uint64_t val;
	struct {
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
	};
} D_EFLAGS;

typedef union __attribute__((__packed__)) D_FCW {
	uint16_t val;
	struct {
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
	};
} D_FCW;

typedef union __attribute__((__packed__)) D_FSW {
	uint16_t val;
	struct {
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
	};
} D_FSW;

typedef union __attribute__((__packed__)) D_FTW { // TOS-independent order
	uint16_t val;
	struct {
		uint16_t FP7: 2;
		uint16_t FP6: 2;
		uint16_t FP5: 2;
		uint16_t FP4: 2;
		uint16_t FP3: 2;
		uint16_t FP2: 2;
		uint16_t FP1: 2;
		uint16_t FP0: 2;
	};
} D_FTW;

typedef union __attribute__((__packed__)) D_FTWX {
	uint8_t val;
	struct {
		uint8_t FP7: 1;
		uint8_t FP6: 1;
		uint8_t FP5: 1;
		uint8_t FP4: 1;
		uint8_t FP3: 1;
		uint8_t FP2: 1;
		uint8_t FP1: 1;
		uint8_t FP0: 1;
	};
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

typedef struct __attribute__((aligned (16))) D_FXSAVE {
	D_FCW      FCW;
	D_FSW      FSW;
	D_FTWX     FTWX;
	uint8_t    _fxsave_1;
	uint16_t   FOP;
	union {
		struct {
			uint32_t  FPU_IP;
			uint16_t  FPU_CS;
			uint16_t  _1;
			uint32_t  FPU_DP;
			uint16_t  FPU_DS;
			uint16_t  _2;
		} x86;
		struct {
			uint64_t  FPU_IP;
			uint64_t  FPU_DP;
		} x64;
	};
	D_MXCSR    MXCSR;
	uint32_t   MXCSR_MASK;
	D_FPRX     FPR[8]; // in TOS-independent order
	D_DQWORD   XMM[16];
	uint8_t    _fxsave_2[96];
} D_FXSAVE;

typedef struct MemDump {
	union {
		D_QWORD GPR[16];
		struct { D_QWORD RAX, RCX, RDX, RBX, RSP, RBP, RSI, RDI, R8, R9, R10, R11, R12, R13, R14, R15; };
		struct { D_DWORD _1, EAX, _2, ECX, _3, EDX, _4, EBX, _5, ESP, _6, EBP, _7, ESI, _8, EDI; };
	};
	D_EFLAGS EFLAGS;
	D_FXSAVE;
	uint32_t stack_size;
	D_QWORD stack[4096];  // top-to-bottom (ESP -> EBP)
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
	title = 'FLAGS', stitle = 'FLAGS', mdfield = 'EFLAGS',
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
		FZ	 = 'Flush To Zero',
		RM  = 'Round Mode',
		PM  = 'Precision Mask',
		UM  = 'Underflow Mask',
		OM  = 'Overflow Mask',
		ZM  = 'Divide By Zero Mask',
		DM  = 'Denormal Mask',
		IM  = 'Invalid Operation Mask',
		DAZ = 'Denormals Are Zero',
		PE  = 'Precision Flag',
		UE  = 'Underflow Flag',
		OE  = 'Overflow Flag',
		ZE  = 'Divide By Zero Flag',
		DE  = 'Denormal Flag',
		IE  = 'Invalid Operation Flag',
	},
}

local template_asm = [[
	local X64 = ffi.arch == 'x64'
	|
	| --push EFLAGS and EAX, which will hold the addr. of md
	|.if X86
	|   pushfd
	|   push eax
	|  .define BASE, eax
	|.else
	|   pushfq
	|   push rax
	|  .define BASE, rax
	|.endif
	|
	|.type MD, MemDump, BASE
	| mov BASE, ffi.cast('void*', md)
   |
	| --save FPU/MMX and SSE state in one shot
	| fxsave MD.FCW
	|
	| --save GPRs
   |.if X86
	|   mov MD.ECX, ecx
	|   mov MD.EDX, edx
	|   mov MD.ESI, esi
	|   mov MD.EDI, edi
	|   mov MD.EBP, ebp
	|   mov ecx, eax
	|   pop eax
	|   mov MD:ecx.EAX, eax
	|   mov eax, ecx
	|   pop ecx
	|   mov MD.EFLAGS, ecx
	|   mov MD.ESP, esp --esp has initial value now
	|.else
	|   mov MD.RBX, rbx
	|   mov MD.RCX, rcx
	|   mov MD.RDX, rdx
	|   mov MD.RSI, rsi
	|   mov MD.RDI, rdi
	|   mov MD.RBP, rbp
	|   mov rcx, rax
	|   pop rax
	|   mov MD:rcx.RAX, rax
	|   mov rax, rcx
	|   pop rcx
	|   mov MD.EFLAGS, rcx
	|   mov MD.RSP, rsp --rsp has initial value now
	|   mov MD.R8,  r8
	|   mov MD.R9,  r9
	|   mov MD.R10, r10
	|   mov MD.R11, r11
	|   mov MD.R12, r12
	|   mov MD.R13, r13
	|   mov MD.R14, r14
	|   mov MD.R15, r15
   |.endif
	|
	| --save stack between EBP and ESP
	|
	|.if X86
	|  .define TMP, ebx
	|  .define SRC, edx
	|  .define DST, ecx
	|  .define ADD, 4
	|  .define SHIFT, 2
	|  .define SP, esp
	|  .define BP, ebp
	|.else
	|  .define TMP, rbx
	|  .define SRC, rdx
	|  .define DST, rcx
	|  .define ADD, 8
	|  .define SHIFT, 3
	|  .define SP, rsp
	|  .define BP, rbp
	|.endif
	|
	| push TMP
	| mov DST, BASE
	| mov SRC, SP
	| add SRC, ADD --skip just-pushed ebx/rbx
	|->loop:
	| --check frame
	| cmp SRC, BP
	| jae ->end
	|
	| // check count
	| mov TMP, DST
	| sub TMP, BASE
	| shr TMP, SHIFT
	| cmp TMP, 4096
	| ja ->end
	|
	| // save, advance and go back
	| mov TMP, [SRC]
	| mov MD:DST.stack, TMP
	| add SRC, ADD
	| add DST, 8
	| jmp ->loop
	|
	|->end:
	| sub DST, BASE
	| shr DST, 3
	| mov MD.stack_size, DST
   |
	| pop TMP

	-- add user code here
	%s

	| ret
]]

local function mkframe(ctype, user_asm)
	local md = ffi.new'MemDump'
	local asm = string.format(template_asm, user_asm or '')
	local frame = asmfunc(asm, {md = md}, ctype)
	return frame, md
end

local function dumpframe(md)

	local function out_qwords(qwords)
		local fmt = '%-8s 0x%08X%08X %19s %16d %16d %19s %19s %8d %8d %8d %8d\n'
		out(_(            '%-8s %18s %19s %16s %16s %19s %19s %8s %8s %8s %8s\n',
			'name', '0x', 'd', 'dw1', 'dw0', 'd1', 'd0', 'w3', 'w2', 'w1', 'w0'))
		hr()
		for name, qword in qwords() do
			out(_(fmt, name,
				qword.hi.uval,
				qword.lo.uval,
				isnan(qword) and 'nan' or _('%19g', qword.fval),
				qword.hi.sval,
				qword.lo.sval,
				isnanf(qword.hi) and 'nan' or _('%19g', qword.hi.fval),
				isnanf(qword.lo) and 'nan' or _('%19g', qword.lo.fval),
				qword.hi.hi.sval,
				qword.hi.lo.sval,
				qword.lo.hi.sval,
				qword.lo.lo.sval))
		end
		out'\n'
	end

	local function out_dwords(dwords)
		local fmt = '%-8s 0x%08X %16d %19s %8d %8d %4d %4d %4d %4d\n'
		out(_(       '%-8s   %8s %16s %19s %8s %8s %4s %4s %4s %4s\n',
			'name', '0x', 'dw', 'f', 'w1', 'w0', 'b3', 'b2', 'b1', 'b0'))
		hr()
		for name, dword in dwords() do
			out(_(fmt, name,
				dword.uval,
				dword.sval,
				isnanf(dword) and 'nan' or _('%19g', dword.fval),
				dword.hi.sval,
				dword.lo.sval,
				dword.hi.hi.sval,
				dword.hi.lo.sval,
				dword.lo.hi.sval,
				dword.lo.lo.sval))
		end
		out'\n'
	end

	local cpu_regs = x64 and {
		'RAX', 'RBX', 'RCX', 'RDX',
		'RSI', 'RDI', 'RBP', 'RSP',
		'R8', 'R9', 'R10', 'R11', 'R12', 'R13', 'R14', 'R15',
	} or {
		'EAX', 'EBX', 'ECX', 'EDX',
		'ESI', 'EDI', 'EBP', 'ESP',
	}

	local function out_gpr(md)
		local out_words = x64 and out_qwords or out_dwords
		out_words(function()
			local i = 0
			return function()
				i = i + 1
				if not cpu_regs[i] then return end
				return cpu_regs[i]:lower(), md[cpu_regs[i]]
			end
		end)
	end

	local function out_xmm_d(md)
		out_dwords(function()
			return coroutine.wrap(function()
				local n = x64 and 16 or 8
				for i=0,n do
					for j=0,3 do
						coroutine.yield('xmm'..i..'.d'..j, md.XMM[i].dwords[j])
					end
				end
			end)
		end)
	end

	local function out_xmm_q(md)
		out_qwords(function()
			return coroutine.wrap(function()
				local n = x64 and 16 or 8
				for i=0,n-1 do
					for j=0,1 do
						coroutine.yield('xmm'..i..'.q'..j, md.XMM[i].qwords[j])
					end
				end
			end)
		end)
	end

	local function out_xmm(md, q)
		if q then out_xmm_q(md) else out_xmm_d(md) end
	end

	local function out_stack(md)
		local out_words = x64 and out_qwords or out_dwords
		out_words(function()
			local i = -1
			return function()
				i = i + 1
				if i >= md.stack_size then return end
				local name = _((x64 and 'r' or 'e')..'sp+%d', tostring(i) * (x64 and 8 or 4))
				return name, x64 and md.stack[i] or md.stack[i].lo
			end
		end)
	end

	local function getbit(n, v)
		return bit.band(v, bit.lshift(1, n)) ~= 0
	end

	local function out_streg(md, n, k)
		if not getbit(7-n, md.FTWX.val) then return end
		out(_('st(%d)   ', n), _('%s    ', glue.tohex(ffi.string(md.FPR[k].bytes, 10))),
			_('%g', cvt80to64(md.FPR[k].bval)), '\n')
	end

	local function out_fpr(md)
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

	out_gpr(md)
	out_fpr(md)
	out_xmm(md, x64 and 1)
	out_stack(md)

	out_eflags(md)
	out_mxcsr(md)
	out_fsw(md)
	out_fcw(md)
end

local frame, md = mkframe('int(__cdecl*)(float, int, int, int, int, int)', [[
	| mov eax, 654321
]])
local ret = frame(12345.6, 0x3333, 0x4444, 0x5555, 0x6666, 0x7777)
dumpframe(md)
assert(ret == 654321)
