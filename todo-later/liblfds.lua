
local ffi = require'ffi'
require'liblfds_h_611'
local C = ffi.load'lfds'
local M = {C = C}

local rb = {}
rb.__index = rb

function M.ringbuffer(n)
	local self = ffi.new'lfds_ringbuffer_state*[1]'
	local ret = C.lfds_ringbuffer_new(rs, n, nil, , nil)
end

	void lfds_ringbuffer_use( struct lfds_ringbuffer_state *rs ) asm("lfds611_ringbuffer_use");
void lfds_ringbuffer_delete( struct lfds_ringbuffer_state *rs, void (*user_data_delete_function)(void *user_data, void *user_state), void *user_state ) asm("lfds611_ringbuffer_delete");
struct lfds_freelist_element *lfds_ringbuffer_get_read_element( struct lfds_ringbuffer_state *rs, struct lfds_freelist_element **fe ) asm("lfds611_ringbuffer_get_read_element");
struct lfds_freelist_element *lfds_ringbuffer_get_write_element( struct lfds_ringbuffer_state *rs, struct lfds_freelist_element **fe, int *overwrite_flag ) asm("lfds611_ringbuffer_get_write_element");
void lfds_ringbuffer_put_read_element( struct lfds_ringbuffer_state *rs, struct lfds_freelist_element *fe ) asm("lfds611_ringbuffer_put_read_element");
void lfds_ringbuffer_put_write_element( struct lfds_ringbuffer_state *rs, struct lfds_freelist_element *fe ) asm("lfds611_ringbuffer_put_write_element");
void lfds_ringbuffer_query( struct lfds_ringbuffer_state *rs, enum lfds_ringbuffer_query_type query_type, void *query_input, void *query_output ) asm("lfds611_ringbuffer_query");

ffi.metatype('lfds_ringbuffer_state', rb)

int lfds_ringbuffer_new( struct lfds_ringbuffer_state **rs, lfds_atom_t number_elements, int (*user_data_init_function)(void **user_data, void *user_state), void *user_state ) asm("lfds611_ringbuffer_new");
void lfds_ringbuffer_use( struct lfds_ringbuffer_state *rs ) asm("lfds611_ringbuffer_use");
void lfds_ringbuffer_delete( struct lfds_ringbuffer_state *rs, void (*user_data_delete_function)(void *user_data, void *user_state), void *user_state ) asm("lfds611_ringbuffer_delete");
struct lfds_freelist_element *lfds_ringbuffer_get_read_element( struct lfds_ringbuffer_state *rs, struct lfds_freelist_element **fe ) asm("lfds611_ringbuffer_get_read_element");
struct lfds_freelist_element *lfds_ringbuffer_get_write_element( struct lfds_ringbuffer_state *rs, struct lfds_freelist_element **fe, int *overwrite_flag ) asm("lfds611_ringbuffer_get_write_element");
void lfds_ringbuffer_put_read_element( struct lfds_ringbuffer_state *rs, struct lfds_freelist_element *fe ) asm("lfds611_ringbuffer_put_read_element");
void lfds_ringbuffer_put_write_element( struct lfds_ringbuffer_state *rs, struct lfds_freelist_element *fe ) asm("lfds611_ringbuffer_put_write_element");
void lfds_ringbuffer_query( struct lfds_ringbuffer_state *rs, enum lfds_ringbuffer_query_type query_type, void *query_input, void *query_output ) asm("lfds611_ringbuffer_query");


return M
