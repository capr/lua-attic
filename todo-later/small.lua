
local ffi = require'ffi'
local C = ffi.load'small'
local M = {}

ffi.cdef[[
struct quota {
	uint64_t value;
};
struct lf_lifo {
	void *next;
};
struct slab_arena {
	struct lf_lifo cache;
	void *arena;
	size_t prealloc;
	size_t used;
	struct quota *quota;
	uint32_t slab_size;
	int flags;
};
void quota_init(struct quota *quota, size_t total);
size_t quota_total(const struct quota *quota);
size_t quota_used(const struct quota *quota);

int slab_arena_create(struct slab_arena *arena, struct quota *quota,
		  size_t prealloc, uint32_t slab_size, int flags);
void slab_arena_destroy(struct slab_arena *arena);
void *slab_map(struct slab_arena *arena);
void slab_unmap(struct slab_arena *arena, void *ptr);
void slab_arena_mprotect(struct slab_arena *arena);

extern const uint32_t slab_magic;

struct rlist {
	struct rlist *prev;
	struct rlist *next;
};

struct slab {
	struct rlist next_in_cache;
	struct rlist next_in_list;
	size_t size;
	uint32_t magic;
	uint8_t order;
	uint8_t in_use;
};

struct small_stats {
	size_t used;
	size_t total;
};

struct slab_list {
	struct rlist slabs;
	struct small_stats stats;
};

enum { ORDER_MAX = 16 };

struct slab_cache {
	struct slab_arena *arena;
	uint32_t order0_size;
	uint8_t order0_size_lb;
	uint8_t order_max;
	struct slab_list allocated;
	struct slab_list orders[ORDER_MAX+1];
};

void          slab_cache_create   (struct slab_cache *cache, struct slab_arena *arena);
void          slab_cache_destroy  (struct slab_cache *cache);
struct slab*  slab_get_with_order (struct slab_cache *cache, uint8_t order);
void          slab_put_with_order (struct slab_cache *cache, struct slab *slab);
struct slab*  slab_get_large      (struct slab_cache *slab, size_t size);
void          slab_put_large      (struct slab_cache *cache, struct slab *slab);
struct slab * slab_get            (struct slab_cache *cache, size_t size);
void          slab_put            (struct slab_cache *cache, struct slab *slab);

typedef uint32_t matras_id_t;
typedef void *(*matras_alloc_func)(void *ctx);
typedef void (*matras_free_func)(void *ctx, void *ptr);

struct matras_view {
	void *root;
	matras_id_t block_count;
	struct matras_view *prev_view, *next_view;
};

struct matras {
	struct matras_view head;
	matras_id_t block_size;
	matras_id_t extent_size;
	matras_id_t extent_count;
	matras_id_t log2_capacity;
	matras_id_t shift1, shift2;
	matras_id_t mask1, mask2;
	matras_alloc_func alloc_func;
	matras_free_func free_func;
	void *alloc_ctx;
};

void  matras_create  (struct matras *m, matras_id_t extent_size, matras_id_t block_size,
                      matras_alloc_func alloc_func, matras_free_func free_func,
                      void *alloc_ctx);
void  matras_reset   (struct matras *m);
void  matras_destroy (struct matras *m);
void* matras_alloc   (struct matras *m, matras_id_t *id);
void  matras_dealloc (struct matras *m);

void*       matras_alloc_range       (struct matras *m, matras_id_t *id, matras_id_t range_count);
void        matras_dealloc_range     (struct matras *m, matras_id_t range_count);
matras_id_t matras_extent_count      (const struct matras *m);
void        matras_create_read_view  (struct matras *m, struct matras_view *v);
void        matras_destroy_read_view (struct matras *m, struct matras_view *v);
void*       matras_touch             (struct matras *m, matras_id_t id);

]]

ffi.metatype('struct quota', {__index = {
	total = C.quota_total,
	used  = C.quota_used,
}})

ffi.metatype('struct slab_arena', {__index = {
	free    = C.slab_arena_destroy,
	map     = C.slab_map,
	unmap   = C.slab_unmap,
	protect = C.slab_arena_mprotect,
}})

ffi.metatype('struct slab_cache', {__index = {
	free    = C.slab_cache_destroy,
	get     = C.slab_get,
	put     = C.slab_put,
}})

function M.quota(total)
	local q = ffi.new'struct quota'
	C.quota_init(q, total or 0)
	return q
end

function M.slab_arena(quota, slab_size, prealloc)
	local a = ffi.new'struct slab_arena'
	local ok = C.slab_arena_create(a, quota, prealloc, slab_size, 1) == 0
	return ok and a or nil
end

function M.slab_cache(arena)
	local c = ffi.new'struct slab_cache'
	C.slab_cache_create(c, arena)
	return c
end

local q = M.quota()
local a = assert(M.slab_arena(q, 64 * 1024, 100 * 4 * 1024^2, true, true))
local m = a:map()
print(m)
print(a.slab_size, a.used)
a:unmap(m)
local c = M.slab_cache(a)
local s = c:get(64 * 1024 * 4)
print(s.size)
c:put(s)
c:free()
a:free()
