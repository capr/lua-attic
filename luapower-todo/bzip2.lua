
--bzip2 binding.
--Written by Cosmin Apreutesei. Public Domain.

local ffi = require'ffi'

--bzip2.h from bzip2 1.0.6
ffi.cdef[[
typedef struct FILE FILE;

enum {
	BZ_RUN               = 0,
	BZ_FLUSH             = 1,
	BZ_FINISH            = 2,
	BZ_OK                = 0,
	BZ_RUN_OK            = 1,
	BZ_FLUSH_OK          = 2,
	BZ_FINISH_OK         = 3,
	BZ_STREAM_END        = 4,
};

enum {
	BZ_SEQUENCE_ERROR    = (-1),
	BZ_PARAM_ERROR       = (-2),
	BZ_MEM_ERROR         = (-3),
	BZ_DATA_ERROR        = (-4),
	BZ_DATA_ERROR_MAGIC  = (-5),
	BZ_IO_ERROR          = (-6),
	BZ_UNEXPECTED_EOF    = (-7),
	BZ_OUTBUFF_FULL      = (-8),
	BZ_CONFIG_ERROR      = (-9),
};

typedef struct {
	char *next_in;
	unsigned int avail_in;
	unsigned int total_in_lo32;
	unsigned int total_in_hi32;
	char *next_out;
	unsigned int avail_out;
	unsigned int total_out_lo32;
	unsigned int total_out_hi32;
	void *state;
	void *(*bzalloc)(void *,int,int);
	void (*bzfree)(void *,void *);
	void *opaque;
} bz_stream;

int BZ2_bzCompressInit (
		bz_stream* strm,
		int blockSize100k,
		int verbosity,
		int workFactor
	);
int BZ2_bzCompress (
		bz_stream* strm,
		int action
	);
int BZ2_bzCompressEnd (
		bz_stream* strm
	);
int BZ2_bzDecompressInit (
		bz_stream *strm,
		int verbosity,
		int small
	);
int BZ2_bzDecompress (
		bz_stream* strm
	);
int BZ2_bzDecompressEnd (
		bz_stream *strm
	);

typedef struct BZFILE BZFILE;
BZFILE* BZ2_bzReadOpen (
		int* bzerror,
		FILE* f,
		int verbosity,
		int small,
		void* unused,
		int nUnused
	);
void BZ2_bzReadClose (
		int* bzerror,
		BZFILE* b
	);
void BZ2_bzReadGetUnused (
		int* bzerror,
		BZFILE* b,
		void** unused,
		int* nUnused
	);
int BZ2_bzRead (
		int* bzerror,
		BZFILE* b,
		void* buf,
		int len
	);
BZFILE* BZ2_bzWriteOpen (
		int* bzerror,
		FILE* f,
		int blockSize100k,
		int verbosity,
		int workFactor
	);
void BZ2_bzWrite (
		int* bzerror,
		BZFILE* b,
		void* buf,
		int len
	);
void BZ2_bzWriteClose (
		int* bzerror,
		BZFILE* b,
		int abandon,
		unsigned int* nbytes_in,
		unsigned int* nbytes_out
	);
void BZ2_bzWriteClose64 (
		int* bzerror,
		BZFILE* b,
		int abandon,
		unsigned int* nbytes_in_lo32,
		unsigned int* nbytes_in_hi32,
		unsigned int* nbytes_out_lo32,
		unsigned int* nbytes_out_hi32
	);
int BZ2_bzBuffToBuffCompress (
		char* dest,
		unsigned int* destLen,
		char* source,
		unsigned int sourceLen,
		int blockSize100k,
		int verbosity,
		int workFactor
	);
int BZ2_bzBuffToBuffDecompress (
		char* dest,
		unsigned int* destLen,
		char* source,
		unsigned int sourceLen,
		int small,
		int verbosity
	);
const char * BZ2_bzlibVersion (
		void
	);
BZFILE * BZ2_bzopen (
		const char *path,
		const char *mode
	);
BZFILE * BZ2_bzdopen (
		int fd,
		const char *mode
	);
int BZ2_bzread (
		BZFILE* b,
		void* buf,
		int len
	);
int BZ2_bzwrite (
		BZFILE* b,
		void* buf,
		int len
	);
int BZ2_bzflush (
		BZFILE* b
	);
void BZ2_bzclose (
		BZFILE* b
	);
const char * BZ2_bzerror (
		BZFILE *b,
		int *errnum
	);
]]

local C = ffi.load'bz2'
local M = {C = C}

--stream API

function M.compress_stream(blocksize, verbosity, workfactor)
	local strm = ffi.new'bz_stream'
	assert(C.BZ2_bzCompressInit(strm, blocksize, verbosity, workfactor) == 0)
	return strm
end

local bz = {}

function bz:compress()
	C.BZ2_bzCompress(self, action)
end

function bz:compress_end()
	C.BZ2_bzCompressEnd(self)
end

function M.decompress_stream(verbosity, small)
	local strm = ffi.new'bz_stream'
	assert(C.BZ2_bzDecompressInit(strm, verbosity, small) == 0)
	return strm
end

function bz:decompress()
	C.BZ2_bzDecompress(self)
end

function bz:decompress_end()
	C.BZ2_bzDecompressEnd(self)
end

--file API

local BZ = {}

local bzerr = ffi.new'int[1]'
local function ret(b, ...)
	local e = bzerr[0]
	if e ~= 0 then
		local s = ffi.string(C.BZ2_bzerror(b, e))
		return nil, s, e
	end
	return ...
end

function M.open_read(f, verbosity, small)
	local b = C.BZ2_bzReadOpen(bzerr, f, verbosity, small, nil, 0)
	return ret(b, b)
end

function BZ:read_close()
	return ret(self, C.BZ2_bzReadClose(bzerr, self))
end

function BZ:read_get_unused(buf, len)
	return ret(self, C.BZ2_bzReadGetUnused(bzerr, self, buf, len)) --TODO
end

function BZ:read(buf, len)
	return ret(self, C.BZ2_bzRead(bzerr, self, buf, len))
end

function M.open_write(f, blocksize, verbosity, workfactor)
	local b = C.BZ2_bzWriteOpen(bzerr, f, blocksize, verbosity, workfactor)
	return ret(b, b)
end

function BZ:write(buf, len)
	return ret(self, C.BZ2_bzWrite(bzerr, self, buf, len))
end

local nbytes_in  = ffi.new'unsigned int[1]'
local nbytes_out = ffi.new'unsigned int[1]'
local nbytes_in  = ffi.new'unsigned int[1]'
local nbytes_out = ffi.new'unsigned int[1]'

local function fix64(lo, hi)
	return hi * 2^32 + lo
end

function BZ:write_close(abandon)
	C.BZ2_bzWriteClose64(bzerr, self, abandon,
		nbytes_in_lo,
		nbytes_in_hi,
		nbytes_out_lo,
		nbytes_out_hi)
	return ret(self,
		fix64(nbytes_in_lo, nbytes_in_hi),
		fix64(nbytes_out_lo, nbytes_out_h))
end

--buff-to-buff API

--[[
int BZ2_bzBuffToBuffCompress (
		char* dest,
		unsigned int* destLen,
		char* source,
		unsigned int sourceLen,
		int blockSize100k,
		int verbosity,
		int workFactor
	);
int BZ2_bzBuffToBuffDecompress (
		char* dest,
		unsigned int* destLen,
		char* source,
		unsigned int sourceLen,
		int small,
		int verbosity
	);
]]

--bz2 file API

--[[
BZFILE * BZ2_bzopen (
		const char *path,
		const char *mode
	);
BZFILE * BZ2_bzdopen (
		int fd,
		const char *mode
	);
int BZ2_bzread (
		BZFILE* b,
		void* buf,
		int len
	);
int BZ2_bzwrite (
		BZFILE* b,
		void* buf,
		int len
	);
int BZ2_bzflush (
		BZFILE* b
	);
void BZ2_bzclose (
		BZFILE* b
	);
]]

--misc.

function M.version()
	return ffi.string(C.BZ2_bzlibVersion())
end

ffi.metatype('bz_stream', {__index = bz})
ffi.metatype('BZFILE', {__index = BZ})

return M
