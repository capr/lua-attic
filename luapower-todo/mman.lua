typedef __mode_t mode_t;

#define MAP_FAILED	((void *) -1)

extern void *mmap64 (void *__addr, size_t __len, int __prot,
		     int __flags, int __fd, __off64_t __offset);

extern int munmap (void *__addr, size_t __len);

extern int mprotect (void *__addr, size_t __len, int __prot) __THROW;

/* Synchronize the region starting at ADDR and extending LEN bytes with the
   file it maps.  Filesystem operations on a file being mapped are
   unpredictable before this is done.  Flags are from the MS_* set.

   This function is a cancellation point and therefore not marked with
   __THROW.  */
extern int msync (void *__addr, size_t __len, int __flags);

#ifdef __USE_BSD
/* Advise the system about particular usage patterns the program follows
   for the region starting at ADDR and extending LEN bytes.  */
extern int madvise (void *__addr, size_t __len, int __advice) __THROW;
#endif
#ifdef __USE_XOPEN2K
/* This is the POSIX name for this function.  */
extern int posix_madvise (void *__addr, size_t __len, int __advice) __THROW;
#endif

/* Guarantee all whole pages mapped by the range [ADDR,ADDR+LEN) to
   be memory resident.  */
extern int mlock (__const void *__addr, size_t __len) __THROW;

/* Unlock whole pages previously mapped by the range [ADDR,ADDR+LEN).  */
extern int munlock (__const void *__addr, size_t __len) __THROW;

/* Cause all currently mapped pages of the process to be memory resident
   until unlocked by a call to the `munlockall', until the process exits,
   or until the process calls `execve'.  */
extern int mlockall (int __flags) __THROW;

/* All currently mapped pages of the process' address space become
   unlocked.  */
extern int munlockall (void) __THROW;

#ifdef __USE_MISC
/* mincore returns the memory residency status of the pages in the
   current process's address space specified by [start, start + len).
   The status is returned in a vector of bytes.  The least significant
   bit of each byte is 1 if the referenced page is in memory, otherwise
   it is zero.  */
extern int mincore (void *__start, size_t __len, unsigned char *__vec)
     __THROW;
#endif

#ifdef __USE_GNU
/* Remap pages mapped by the range [ADDR,ADDR+OLD_LEN) to new length
   NEW_LEN.  If MREMAP_MAYMOVE is set in FLAGS the returned address
   may differ from ADDR.  If MREMAP_FIXED is set in FLAGS the function
   takes another paramter which is a fixed address at which the block
   resides after a successful call.  */
extern void *mremap (void *__addr, size_t __old_len, size_t __new_len,
		     int __flags, ...) __THROW;

/* Remap arbitrary pages of a shared backing store within an existing
   VMA.  */
extern int remap_file_pages (void *__start, size_t __size, int __prot,
			     size_t __pgoff, int __flags) __THROW;
#endif


/* Open shared memory segment.  */
extern int shm_open (__const char *__name, int __oflag, mode_t __mode);

/* Remove shared memory segment.  */
extern int shm_unlink (__const char *__name);

__END_DECLS

#endif	/* sys/mman.h */
