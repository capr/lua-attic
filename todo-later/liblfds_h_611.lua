
local ffi = require'ffi'

ffi.cdef[[
typedef unsigned long long int lfds_atom_t;
enum lfds_data_structure_validity
{
	LFDS_VALIDITY_VALID,
	LFDS_VALIDITY_INVALID_LOOP,
	LFDS_VALIDITY_INVALID_MISSING_ELEMENTS,
	LFDS_VALIDITY_INVALID_ADDITIONAL_ELEMENTS,
	LFDS_VALIDITY_INVALID_TEST_DATA
};
struct lfds_validation_info
{
	lfds_atom_t
		min_elements,
		max_elements;
};
enum lfds_freelist_query_type
{
	LFDS_FREELIST_QUERY_ELEMENT_COUNT,
	LFDS_FREELIST_QUERY_VALIDATE
};
struct lfds_freelist_state;
struct lfds_freelist_element;

enum lfds_queue_query_type
{
	LFDS_QUEUE_QUERY_ELEMENT_COUNT,
	LFDS_QUEUE_QUERY_VALIDATE
};

enum lfds_ringbuffer_query_type
{
	LFDS_RINGBUFFER_QUERY_VALIDATE
};

enum lfds_stack_query_type
{
	LFDS_STACK_QUERY_ELEMENT_COUNT,
	LFDS_STACK_QUERY_VALIDATE
};

struct lfds_queue_state;
struct lfds_ringbuffer_state;
struct lfds_slist_state;
struct lfds_slist_element;
struct lfds_stack_state;

void *lfds_abstraction_malloc( size_t size ) asm("lfds611_abstraction_malloc");
void lfds_abstraction_free( void *memory ) asm("lfds611_abstraction_free");

int lfds_freelist_new( struct lfds_freelist_state **fs, lfds_atom_t number_elements, int (*user_data_init_function)(void **user_data, void *user_state), void *user_state ) asm("lfds611_freelist_new");
void lfds_freelist_use( struct lfds_freelist_state *fs ) asm("lfds611_freelist_use");
void lfds_freelist_delete( struct lfds_freelist_state *fs, void (*user_data_delete_function)(void *user_data, void *user_state), void *user_state ) asm("lfds611_freelist_delete");
lfds_atom_t lfds_freelist_new_elements( struct lfds_freelist_state *fs, lfds_atom_t number_elements ) asm("lfds611_freelist_new_elements");
struct lfds_freelist_element *lfds_freelist_pop( struct lfds_freelist_state *fs, struct lfds_freelist_element **fe ) asm("lfds611_freelist_pop");
struct lfds_freelist_element *lfds_freelist_guaranteed_pop( struct lfds_freelist_state *fs, struct lfds_freelist_element **fe ) asm("lfds611_freelist_guaranteed_pop");
void lfds_freelist_push( struct lfds_freelist_state *fs, struct lfds_freelist_element *fe ) asm("lfds611_freelist_push");
void *lfds_freelist_get_user_data_from_element( struct lfds_freelist_element *fe, void **user_data ) asm("lfds611_freelist_get_user_data_from_element");
void lfds_freelist_set_user_data_in_element( struct lfds_freelist_element *fe, void *user_data ) asm("lfds611_freelist_set_user_data_in_element");
void lfds_freelist_query( struct lfds_freelist_state *fs, enum lfds_freelist_query_type query_type, void *query_input, void *query_output ) asm("lfds611_freelist_query");

int lfds_queue_new( struct lfds_queue_state **sq, lfds_atom_t number_elements ) asm("lfds611_queue_new");
void lfds_queue_use( struct lfds_queue_state *qs ) asm("lfds611_queue_use");
void lfds_queue_delete( struct lfds_queue_state *qs, void (*user_data_delete_function)(void *user_data, void *user_state), void *user_state ) asm("lfds611_queue_delete");
int lfds_queue_enqueue( struct lfds_queue_state *qs, void *user_data ) asm("lfds611_queue_enqueue");
int lfds_queue_guaranteed_enqueue( struct lfds_queue_state *qs, void *user_data ) asm("lfds611_queue_guaranteed_enqueue");
int lfds_queue_dequeue( struct lfds_queue_state *qs, void **user_data ) asm("lfds611_queue_dequeue");
void lfds_queue_query( struct lfds_queue_state *qs, enum lfds_queue_query_type query_type, void *query_input, void *query_output ) asm("lfds611_queue_query");

int lfds_ringbuffer_new( struct lfds_ringbuffer_state **rs, lfds_atom_t number_elements, int (*user_data_init_function)(void **user_data, void *user_state), void *user_state ) asm("lfds611_ringbuffer_new");
void lfds_ringbuffer_use( struct lfds_ringbuffer_state *rs ) asm("lfds611_ringbuffer_use");
void lfds_ringbuffer_delete( struct lfds_ringbuffer_state *rs, void (*user_data_delete_function)(void *user_data, void *user_state), void *user_state ) asm("lfds611_ringbuffer_delete");
struct lfds_freelist_element *lfds_ringbuffer_get_read_element( struct lfds_ringbuffer_state *rs, struct lfds_freelist_element **fe ) asm("lfds611_ringbuffer_get_read_element");
struct lfds_freelist_element *lfds_ringbuffer_get_write_element( struct lfds_ringbuffer_state *rs, struct lfds_freelist_element **fe, int *overwrite_flag ) asm("lfds611_ringbuffer_get_write_element");
void lfds_ringbuffer_put_read_element( struct lfds_ringbuffer_state *rs, struct lfds_freelist_element *fe ) asm("lfds611_ringbuffer_put_read_element");
void lfds_ringbuffer_put_write_element( struct lfds_ringbuffer_state *rs, struct lfds_freelist_element *fe ) asm("lfds611_ringbuffer_put_write_element");
void lfds_ringbuffer_query( struct lfds_ringbuffer_state *rs, enum lfds_ringbuffer_query_type query_type, void *query_input, void *query_output ) asm("lfds611_ringbuffer_query");

int lfds_slist_new( struct lfds_slist_state **ss, void (*user_data_delete_function)(void *user_data, void *user_state), void *user_state ) asm("lfds611_slist_new");
void lfds_slist_use( struct lfds_slist_state *ss ) asm("lfds611_slist_use");
void lfds_slist_delete( struct lfds_slist_state *ss ) asm("lfds611_slist_delete");
struct lfds_slist_element *lfds_slist_new_head( struct lfds_slist_state *ss, void *user_data ) asm("lfds611_slist_new_head");
struct lfds_slist_element *lfds_slist_new_next( struct lfds_slist_element *se, void *user_data ) asm("lfds611_slist_new_next");
int lfds_slist_logically_delete_element( struct lfds_slist_state *ss, struct lfds_slist_element *se ) asm("lfds611_slist_logically_delete_element");
void lfds_slist_single_threaded_physically_delete_all_elements( struct lfds_slist_state *ss ) asm("lfds611_slist_single_threaded_physically_delete_all_elements");
int lfds_slist_get_user_data_from_element( struct lfds_slist_element *se, void **user_data ) asm("lfds611_slist_get_user_data_from_element");
int lfds_slist_set_user_data_in_element( struct lfds_slist_element *se, void *user_data ) asm("lfds611_slist_set_user_data_in_element");
struct lfds_slist_element *lfds_slist_get_head( struct lfds_slist_state *ss, struct lfds_slist_element **se ) asm("lfds611_slist_get_head");
struct lfds_slist_element *lfds_slist_get_next( struct lfds_slist_element *se, struct lfds_slist_element **next_se ) asm("lfds611_slist_get_next");
struct lfds_slist_element *lfds_slist_get_head_and_then_next( struct lfds_slist_state *ss, struct lfds_slist_element **se ) asm("lfds611_slist_get_head_and_then_next");

int lfds_stack_new( struct lfds_stack_state **ss, lfds_atom_t number_elements ) asm("lfds611_stack_new");
void lfds_stack_use( struct lfds_stack_state *ss ) asm("lfds611_stack_use");
void lfds_stack_delete( struct lfds_stack_state *ss, void (*user_data_delete_function)(void *user_data, void *user_state), void *user_state ) asm("lfds611_stack_delete");
void lfds_stack_clear( struct lfds_stack_state *ss, void (*user_data_clear_function)(void *user_data, void *user_state), void *user_state ) asm("lfds611_stack_clear");
int lfds_stack_push( struct lfds_stack_state *ss, void *user_data ) asm("lfds611_stack_push");
int lfds_stack_guaranteed_push( struct lfds_stack_state *ss, void *user_data ) asm("lfds611_stack_guaranteed_push");
int lfds_stack_pop( struct lfds_stack_state *ss, void **user_data ) asm("lfds611_stack_pop");
void lfds_stack_query( struct lfds_stack_state *ss, enum lfds_stack_query_type query_type, void *query_input, void *query_output ) asm("lfds611_stack_query");
]]
