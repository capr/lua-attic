
--stb_vorbis binding.
--Written by Cosmin Apreutesei. Public Domain.

local ffi = require'ffi'

ffi.cdef[[
typedef struct FILE FILE;
typedef struct
{
	char *alloc_buffer;
	int   alloc_buffer_length_in_bytes;
} stb_vorbis_alloc;
typedef struct stb_vorbis stb_vorbis;
typedef struct
{
	unsigned int sample_rate;
	int channels;
	unsigned int setup_memory_required;
	unsigned int setup_temp_memory_required;
	unsigned int temp_memory_required;
	int max_frame_size;
} stb_vorbis_info;
stb_vorbis_info stb_vorbis_get_info(stb_vorbis *f);
int stb_vorbis_get_error(stb_vorbis *f);
void stb_vorbis_close(stb_vorbis *f);
int stb_vorbis_get_sample_offset(stb_vorbis *f);
unsigned int stb_vorbis_get_file_offset(stb_vorbis *f);
stb_vorbis *stb_vorbis_open_pushdata(
	unsigned char *datablock, int datablock_length_in_bytes,
	int *datablock_memory_consumed_in_bytes,
	int *error,
	stb_vorbis_alloc *alloc_buffer);
int stb_vorbis_decode_frame_pushdata(
	stb_vorbis *f, unsigned char *datablock, int datablock_length_in_bytes,
	int *channels,
	float ***output,
	int *samples);
void stb_vorbis_flush_pushdata(stb_vorbis *f);
int stb_vorbis_decode_filename(const char *filename, int *channels, int *sample_rate, short **output);
int stb_vorbis_decode_memory(const unsigned char *mem, int len, int *channels, int *sample_rate, short **output);
stb_vorbis *stb_vorbis_open_memory(const unsigned char *data, int len, int *error, stb_vorbis_alloc *alloc_buffer);
stb_vorbis *stb_vorbis_open_filename(const char *filename, int *error, stb_vorbis_alloc *alloc_buffer);
stb_vorbis *stb_vorbis_open_file(FILE *f, int close_handle_on_close, int *error, stb_vorbis_alloc *alloc_buffer);
stb_vorbis *stb_vorbis_open_file_section(FILE *f, int close_handle_on_close, int *error, stb_vorbis_alloc *alloc_buffer, unsigned int len);
int stb_vorbis_seek_frame(stb_vorbis *f, unsigned int sample_number);
int stb_vorbis_seek(stb_vorbis *f, unsigned int sample_number);
void stb_vorbis_seek_start(stb_vorbis *f);
unsigned int stb_vorbis_stream_length_in_samples(stb_vorbis *f);
float        stb_vorbis_stream_length_in_seconds(stb_vorbis *f);
int stb_vorbis_get_frame_float(stb_vorbis *f, int *channels, float ***output);
int stb_vorbis_get_frame_short_interleaved(stb_vorbis *f, int num_c, short *buffer, int num_shorts);
int stb_vorbis_get_frame_short            (stb_vorbis *f, int num_c, short **buffer, int num_samples);
int stb_vorbis_get_samples_float_interleaved(stb_vorbis *f, int channels, float *buffer, int num_floats);
int stb_vorbis_get_samples_float(stb_vorbis *f, int channels, float **buffer, int num_samples);
int stb_vorbis_get_samples_short_interleaved(stb_vorbis *f, int channels, short *buffer, int num_shorts);
int stb_vorbis_get_samples_short(stb_vorbis *f, int channels, short **buffer, int num_samples);
enum STBVorbisError
{
   VORBIS__no_error,
   VORBIS_need_more_data=1,
   VORBIS_invalid_api_mixing,
   VORBIS_outofmem,
   VORBIS_feature_not_supported,
   VORBIS_too_many_channels,
   VORBIS_file_open_failure,
   VORBIS_seek_without_length,
   VORBIS_unexpected_eof=10,
   VORBIS_seek_invalid,
   VORBIS_invalid_setup=20,
   VORBIS_invalid_stream,
   VORBIS_missing_capture_pattern=30,
   VORBIS_invalid_stream_structure_version,
   VORBIS_continued_packet_flag_invalid,
   VORBIS_incorrect_stream_serial_number,
   VORBIS_invalid_first_page,
   VORBIS_bad_packet_type,
   VORBIS_cant_find_last_page,
   VORBIS_seek_failed,
};
]]

local C = ffi.load'vorbis'
local M = {C = C}

function M.open(t)
	local vorbis
	local err = ffi.new'int[1]'
	if t.cdata then
		vorbis = C.stb_vorbis_open_memory(t.cdata, t.size, err, nil)
	elseif t.string then
		vorbis = C.stb_vorbis_open_memory(t.string, #t.string, err, nil)
	elseif t.path then
		vorbis = C.stb_vorbis_open_filename(t.path, err, nil)
	elseif t.stream then
		C.stb_vorbis_open_file(t.stream, false, err, nil)
	else
		error'source missing'
	end

	return vorbis
end

ffi.metatype('stb_vorbis', {__index = {
	seek_frame = C.stb_vorbis_seek_frame, --(stb_vorbis *f, unsigned int sample_number);
	seek = C.stb_vorbis_seek, --(stb_vorbis *f, unsigned int sample_number);
	seek_start = C.stb_vorbis_seek_start,
	samples = C.stb_vorbis_stream_length_in_samples,
	seconds = C.stb_vorbis_stream_length_in_seconds,
	--[[
	frame = function(self)
		C.stb_vorbis_get_frame_float, --(stb_vorbis *f, int *channels, float ***output);
		C.stb_vorbis_get_frame_short_interleaved, --(stb_vorbis *f, int num_c, short *buffer, int num_shorts);
		C.stb_vorbis_get_frame_short, --(stb_vorbis *f, int num_c, short **buffer, int num_samples);
	end,
	samples = function(self)
		C.stb_vorbis_get_samples_float_interleaved, --(stb_vorbis *f, int channels, float *buffer, int num_floats);
		C.stb_vorbis_get_samples_float, --(stb_vorbis *f, int channels, float **buffer, int num_samples);
		C.stb_vorbis_get_samples_short_interleaved, --(stb_vorbis *f, int channels, short *buffer, int num_shorts);
		C.stb_vorbis_get_samples_short, --(stb_vorbis *f, int channels, short **buffer, int num_samples);
	end,
	]]
}})

--showcase

if not ... then
	--
end

return M
