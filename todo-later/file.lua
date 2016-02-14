
--file API for Windows, Linux and OSX
--Written by Cosmin Apreutesei. Public Domain.

local ffi = require'ffi'

local file = {}

if ffi.os == 'Windows' then

	local CREATE_NEW        = 1
	local CREATE_ALWAYS     = 2
	local OPEN_EXISTING     = 3
	local OPEN_ALWAYS       = 4
	local TRUNCATE_EXISTING = 5

	ffi.cdef('typedef '..(ffi.abi'64bit' and 'int64_t' or 'int32_t')..' ULONG_PTR;')

	ffi.cdef[[
	typedef void*          HANDLE;
	typedef int16_t        WORD;
	typedef int32_t        DWORD, *LPDWORD;
	typedef int            BOOL;
	typedef ULONG_PTR      SIZE_T;
	typedef void           VOID, *LPVOID;
	typedef char*          LPSTR;
	typedef const wchar_t* LPCWSTR;
	typedef const void*    LPCVOID;

	typedef struct {
		DWORD  nLength;
		void*  lpSecurityDescriptor;
		BOOL   bInheritHandle;
	} *LPSECURITY_ATTRIBUTES;

	typedef struct _OVERLAPPED {
		ULONG_PTR Internal;
		ULONG_PTR InternalHigh;
		union {
			struct {
				DWORD Offset;
				DWORD OffsetHigh;
			};
		  void* Pointer;
		};
		HANDLE hEvent;
	} OVERLAPPED, *LPOVERLAPPED;

	typedef struct _OVERLAPPED_ENTRY {
		ULONG_PTR lpCompletionKey;
		LPOVERLAPPED lpOverlapped;
		ULONG_PTR Internal;
		DWORD dwNumberOfBytesTransferred;
	} OVERLAPPED_ENTRY, *LPOVERLAPPED_ENTRY;

	HANDLE CreateFileW(
		LPCWSTR lpFileName,
		DWORD dwDesiredAccess,
		DWORD dwShareMode,
		LPSECURITY_ATTRIBUTES lpSecurityAttributes,
		DWORD dwCreationDisposition,
		DWORD dwFlagsAndAttributes,
		HANDLE hTemplateFile
	);

	BOOL WriteFile(
		HANDLE hFile,
		LPCVOID lpBuffer,
		DWORD nNumberOfBytesToWrite,
		LPDWORD lpNumberOfBytesWritten,
		LPOVERLAPPED lpOverlapped
	);

	BOOL ReadFile(
		HANDLE hFile,
		void* lpBuffer,
		DWORD nNumberOfBytesToRead,
		LPDWORD lpNumberOfBytesRead,
		LPOVERLAPPED lpOverlapped
	);

	BOOL FlushFileBuffers(HANDLE hFile);
	]]

	local function validhi(ret)
		return ret ~= INVALID_HANDLE_VALUE,
			'handle expected, got INVALID_HANDLE_VALUE'
	end
	local rethi = retwith(validhi)

	function CreateFile(filename, accessflags, sharemode, secattrs, creationdisp,
		flagsandattrs, htemplatefile)
		return rethi(C.CreateFileW(
			wcs(filename), flags(accessflags), flags(sharemode), secattrs,
			flags(creationdisp), flags(flagsandattrs), htemplatefile))
	end

	--return the number of bytes read/written or nil,err,errcode.
	local function ioop(outbytes, ret, ...)
		outbytes = outbytes or ffi.new'DWORD[1]'
		if ret then
			return outbytes[0]
		else
			return nil, ...
		end
	end

	function WriteFile(hfile, buf, sz, overlapped, outbytes)
		return ioop(outbytes, C.WriteFile(hfile, buf, sz, outbytes, overlapped))
	end

	function ReadFile(hfile, buf, sz, overlapped, outbytes)
		return ioop(outbytes, C.ReadFile(hfile, buf, sz, outbytes, overlapped))
	end

	function FlushFileBuffers(hfile)
		return retnz(C.FlushFileBuffers(hfile))
	end

	if not ... then
		local tmpname = '_CreateFileTest.tmp'
		local f = assert(CreateFile(tmpname, 'GENERIC_WRITE', 0, nil,
			'OPEN_ALWAYS', 'FILE_ATTRIBUTE_NORMAL'))
		assert(CloseHandle(f))
		os.remove(tmpname)
	end
end
