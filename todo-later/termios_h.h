local ffi = require'ffi'
ffi.cdef[[

// <built-in>
enum {
	__STDC__             = 1,
	__STDC_HOSTED__      = 1,
	__GNUC__             = 4,
	__GNUC_MINOR__       = 8,
	__GNUC_PATCHLEVEL__  = 4,
	__VERSION__          = "4.8.4",
	__ATOMIC_RELAXED     = 0,
	__ATOMIC_SEQ_CST     = 5,
	__ATOMIC_ACQUIRE     = 2,
	__ATOMIC_RELEASE     = 3,
	__ATOMIC_ACQ_REL     = 4,
	__ATOMIC_CONSUME     = 1,
	__FINITE_MATH_ONLY__ = 0,
	_LP64                = 1,
	__LP64__             = 1,
	__SIZEOF_INT__       = 4,
	__SIZEOF_LONG__      = 8,
	__SIZEOF_LONG_LONG__ = 8,
	__SIZEOF_SHORT__     = 2,
	__SIZEOF_FLOAT__     = 4,
	__SIZEOF_DOUBLE__    = 8,
	__SIZEOF_LONG_DOUBLE__ = 16,
	__SIZEOF_SIZE_T__    = 8,
	__CHAR_BIT__         = 8,
	__BIGGEST_ALIGNMENT__ = 16,
	__ORDER_LITTLE_ENDIAN__ = 1234,
	__ORDER_BIG_ENDIAN__ = 4321,
	__ORDER_PDP_ENDIAN__ = 3412,
	__BYTE_ORDER__       = __ORDER_LITTLE_ENDIAN__,
	__FLOAT_WORD_ORDER__ = __ORDER_LITTLE_ENDIAN__,
	__SIZEOF_POINTER__   = 8,
	__SIZE_TYPE__        = long unsigned int,
	__PTRDIFF_TYPE__     = long int,
	__WCHAR_TYPE__       = int,
	__WINT_TYPE__        = unsigned int,
	__INTMAX_TYPE__      = long int,
	__UINTMAX_TYPE__     = long unsigned int,
	__CHAR16_TYPE__      = short unsigned int,
	__CHAR32_TYPE__      = unsigned int,
	__SIG_ATOMIC_TYPE__  = int,
	__INT8_TYPE__        = signed char,
	__INT16_TYPE__       = short int,
	__INT32_TYPE__       = int,
	__INT64_TYPE__       = long int,
	__UINT8_TYPE__       = unsigned char,
	__UINT16_TYPE__      = short unsigned int,
	__UINT32_TYPE__      = unsigned int,
	__UINT64_TYPE__      = long unsigned int,
	__INT_LEAST8_TYPE__  = signed char,
	__INT_LEAST16_TYPE__ = short int,
	__INT_LEAST32_TYPE__ = int,
	__INT_LEAST64_TYPE__ = long int,
	__UINT_LEAST8_TYPE__ = unsigned char,
	__UINT_LEAST16_TYPE__ = short unsigned int,
	__UINT_LEAST32_TYPE__ = unsigned int,
	__UINT_LEAST64_TYPE__ = long unsigned int,
	__INT_FAST8_TYPE__   = signed char,
	__INT_FAST16_TYPE__  = long int,
	__INT_FAST32_TYPE__  = long int,
	__INT_FAST64_TYPE__  = long int,
	__UINT_FAST8_TYPE__  = unsigned char,
	__UINT_FAST16_TYPE__ = long unsigned int,
	__UINT_FAST32_TYPE__ = long unsigned int,
	__UINT_FAST64_TYPE__ = long unsigned int,
	__INTPTR_TYPE__      = long int,
	__UINTPTR_TYPE__     = long unsigned int,
	__GXX_ABI_VERSION    = 1002,
	__SCHAR_MAX__        = 127,
	__SHRT_MAX__         = 32767,
	__INT_MAX__          = 2147483647,
	__LONG_MAX__         = 9223372036854775807L,
	__LONG_LONG_MAX__    = 9223372036854775807LL,
	__WCHAR_MAX__        = 2147483647,
	__WCHAR_MIN__        = (-__WCHAR_MAX__ - 1),
	__WINT_MAX__         = 4294967295U,
	__WINT_MIN__         = 0U,
	__PTRDIFF_MAX__      = 9223372036854775807L,
	__SIZE_MAX__         = 18446744073709551615UL,
	__INTMAX_MAX__       = 9223372036854775807L,
};
#define __INTMAX_C(c) c ## L
enum {
	__UINTMAX_MAX__      = 18446744073709551615UL,
};
#define __UINTMAX_C(c) c ## UL
enum {
	__SIG_ATOMIC_MAX__   = 2147483647,
	__SIG_ATOMIC_MIN__   = (-__SIG_ATOMIC_MAX__ - 1),
	__INT8_MAX__         = 127,
	__INT16_MAX__        = 32767,
	__INT32_MAX__        = 2147483647,
	__INT64_MAX__        = 9223372036854775807L,
	__UINT8_MAX__        = 255,
	__UINT16_MAX__       = 65535,
	__UINT32_MAX__       = 4294967295U,
	__UINT64_MAX__       = 18446744073709551615UL,
	__INT_LEAST8_MAX__   = 127,
};
#define __INT8_C(c) c
enum {
	__INT_LEAST16_MAX__  = 32767,
};
#define __INT16_C(c) c
enum {
	__INT_LEAST32_MAX__  = 2147483647,
};
#define __INT32_C(c) c
enum {
	__INT_LEAST64_MAX__  = 9223372036854775807L,
};
#define __INT64_C(c) c ## L
enum {
	__UINT_LEAST8_MAX__  = 255,
};
#define __UINT8_C(c) c
enum {
	__UINT_LEAST16_MAX__ = 65535,
};
#define __UINT16_C(c) c
enum {
	__UINT_LEAST32_MAX__ = 4294967295U,
};
#define __UINT32_C(c) c ## U
enum {
	__UINT_LEAST64_MAX__ = 18446744073709551615UL,
};
#define __UINT64_C(c) c ## UL
enum {
	__INT_FAST8_MAX__    = 127,
	__INT_FAST16_MAX__   = 9223372036854775807L,
	__INT_FAST32_MAX__   = 9223372036854775807L,
	__INT_FAST64_MAX__   = 9223372036854775807L,
	__UINT_FAST8_MAX__   = 255,
	__UINT_FAST16_MAX__  = 18446744073709551615UL,
	__UINT_FAST32_MAX__  = 18446744073709551615UL,
	__UINT_FAST64_MAX__  = 18446744073709551615UL,
	__INTPTR_MAX__       = 9223372036854775807L,
	__UINTPTR_MAX__      = 18446744073709551615UL,
	__FLT_EVAL_METHOD__  = 0,
	__DEC_EVAL_METHOD__  = 2,
	__FLT_RADIX__        = 2,
	__FLT_MANT_DIG__     = 24,
	__FLT_DIG__          = 6,
	__FLT_MIN_EXP__      = (-125),
	__FLT_MIN_10_EXP__   = (-37),
	__FLT_MAX_EXP__      = 128,
	__FLT_MAX_10_EXP__   = 38,
	__FLT_DECIMAL_DIG__  = 9,
	__FLT_MAX__          = 3.40282346638528859812e+38F,
	__FLT_MIN__          = 1.17549435082228750797e-38F,
	__FLT_EPSILON__      = 1.19209289550781250000e-7F,
	__FLT_DENORM_MIN__   = 1.40129846432481707092e-45F,
	__FLT_HAS_DENORM__   = 1,
	__FLT_HAS_INFINITY__ = 1,
	__FLT_HAS_QUIET_NAN__ = 1,
	__DBL_MANT_DIG__     = 53,
	__DBL_DIG__          = 15,
	__DBL_MIN_EXP__      = (-1021),
	__DBL_MIN_10_EXP__   = (-307),
	__DBL_MAX_EXP__      = 1024,
	__DBL_MAX_10_EXP__   = 308,
	__DBL_DECIMAL_DIG__  = 17,
	__DBL_MAX__          = ((double)1.79769313486231570815e+308L),
	__DBL_MIN__          = ((double)2.22507385850720138309e-308L),
	__DBL_EPSILON__      = ((double)2.22044604925031308085e-16L),
	__DBL_DENORM_MIN__   = ((double)4.94065645841246544177e-324L),
	__DBL_HAS_DENORM__   = 1,
	__DBL_HAS_INFINITY__ = 1,
	__DBL_HAS_QUIET_NAN__ = 1,
	__LDBL_MANT_DIG__    = 64,
	__LDBL_DIG__         = 18,
	__LDBL_MIN_EXP__     = (-16381),
	__LDBL_MIN_10_EXP__  = (-4931),
	__LDBL_MAX_EXP__     = 16384,
	__LDBL_MAX_10_EXP__  = 4932,
	__DECIMAL_DIG__      = 21,
	__LDBL_MAX__         = 1.18973149535723176502e+4932L,
	__LDBL_MIN__         = 3.36210314311209350626e-4932L,
	__LDBL_EPSILON__     = 1.08420217248550443401e-19L,
	__LDBL_DENORM_MIN__  = 3.64519953188247460253e-4951L,
	__LDBL_HAS_DENORM__  = 1,
	__LDBL_HAS_INFINITY__ = 1,
	__LDBL_HAS_QUIET_NAN__ = 1,
	__DEC32_MANT_DIG__   = 7,
	__DEC32_MIN_EXP__    = (-94),
	__DEC32_MAX_EXP__    = 97,
	__DEC32_MIN__        = 1E-95DF,
	__DEC32_MAX__        = 9.999999E96DF,
	__DEC32_EPSILON__    = 1E-6DF,
	__DEC32_SUBNORMAL_MIN__ = 0.000001E-95DF,
	__DEC64_MANT_DIG__   = 16,
	__DEC64_MIN_EXP__    = (-382),
	__DEC64_MAX_EXP__    = 385,
	__DEC64_MIN__        = 1E-383DD,
	__DEC64_MAX__        = 9.999999999999999E384DD,
	__DEC64_EPSILON__    = 1E-15DD,
	__DEC64_SUBNORMAL_MIN__ = 0.000000000000001E-383DD,
	__DEC128_MANT_DIG__  = 34,
	__DEC128_MIN_EXP__   = (-6142),
	__DEC128_MAX_EXP__   = 6145,
	__DEC128_MIN__       = 1E-6143DL,
	__DEC128_MAX__       = 9.999999999999999999999999999999999E6144DL,
	__DEC128_EPSILON__   = 1E-33DL,
	__DEC128_SUBNORMAL_MIN__ = 0.000000000000000000000000000000001E-6143DL,
	__GNUC_GNU_INLINE__  = 1,
	__NO_INLINE__        = 1,
	__GCC_HAVE_SYNC_COMPARE_AND_SWAP_1 = 1,
	__GCC_HAVE_SYNC_COMPARE_AND_SWAP_2 = 1,
	__GCC_HAVE_SYNC_COMPARE_AND_SWAP_4 = 1,
	__GCC_HAVE_SYNC_COMPARE_AND_SWAP_8 = 1,
	__GCC_ATOMIC_BOOL_LOCK_FREE = 2,
	__GCC_ATOMIC_CHAR_LOCK_FREE = 2,
	__GCC_ATOMIC_CHAR16_T_LOCK_FREE = 2,
	__GCC_ATOMIC_CHAR32_T_LOCK_FREE = 2,
	__GCC_ATOMIC_WCHAR_T_LOCK_FREE = 2,
	__GCC_ATOMIC_SHORT_LOCK_FREE = 2,
	__GCC_ATOMIC_INT_LOCK_FREE = 2,
	__GCC_ATOMIC_LONG_LOCK_FREE = 2,
	__GCC_ATOMIC_LLONG_LOCK_FREE = 2,
	__GCC_ATOMIC_TEST_AND_SET_TRUEVAL = 1,
	__GCC_ATOMIC_POINTER_LOCK_FREE = 2,
	__GCC_HAVE_DWARF2_CFI_ASM = 1,
	__PRAGMA_REDEFINE_EXTNAME = 1,
	__SSP__              = 1,
	__SIZEOF_INT128__    = 16,
	__SIZEOF_WCHAR_T__   = 4,
	__SIZEOF_WINT_T__    = 4,
	__SIZEOF_PTRDIFF_T__ = 8,
	__amd64              = 1,
	__amd64__            = 1,
	__x86_64             = 1,
	__x86_64__           = 1,
	__ATOMIC_HLE_ACQUIRE = 65536,
	__ATOMIC_HLE_RELEASE = 131072,
	__k8                 = 1,
	__k8__               = 1,
	__code_model_small__ = 1,
	__MMX__              = 1,
	__SSE__              = 1,
	__SSE2__             = 1,
	__FXSR__             = 1,
	__SSE_MATH__         = 1,
	__SSE2_MATH__        = 1,
	__gnu_linux__        = 1,
	__linux              = 1,
	__linux__            = 1,
	linux                = 1,
	__unix               = 1,
	__unix__             = 1,
	unix                 = 1,
	__ELF__              = 1,
	__DECIMAL_BID_FORMAT__ = 1,
};

// /usr/include/stdc-predef.h
enum {
	_STDC_PREDEF_H       = 1,
	__STDC_IEC_559__     = 1,
	__STDC_IEC_559_COMPLEX__ = 1,
	__STDC_ISO_10646__   = 201103L,
	__STDC_NO_THREADS__  = 1,
};

// /usr/include/termios.h
enum {
	_TERMIOS_H           = 1,
};
typedef __pid_t pid_t;
#define CCEQ(val,c) ((c) == (val) && (val) != _POSIX_VDISABLE)
extern speed_t cfgetospeed (const struct termios *__termios_p) __attribute__ ((__nothrow__ , __leaf__));
extern speed_t cfgetispeed (const struct termios *__termios_p) __attribute__ ((__nothrow__ , __leaf__));
extern int cfsetospeed (struct termios *__termios_p, speed_t __speed) __attribute__ ((__nothrow__ , __leaf__));
extern int cfsetispeed (struct termios *__termios_p, speed_t __speed) __attribute__ ((__nothrow__ , __leaf__));
extern int cfsetspeed (struct termios *__termios_p, speed_t __speed) __attribute__ ((__nothrow__ , __leaf__));
extern int tcgetattr (int __fd, struct termios *__termios_p) __attribute__ ((__nothrow__ , __leaf__));
extern int tcsetattr (int __fd, int __optional_actions,
        const struct termios *__termios_p) __attribute__ ((__nothrow__ , __leaf__));
extern void cfmakeraw (struct termios *__termios_p) __attribute__ ((__nothrow__ , __leaf__));
extern int tcsendbreak (int __fd, int __duration) __attribute__ ((__nothrow__ , __leaf__));
extern int tcdrain (int __fd);
extern int tcflush (int __fd, int __queue_selector) __attribute__ ((__nothrow__ , __leaf__));
extern int tcflow (int __fd, int __action) __attribute__ ((__nothrow__ , __leaf__));
extern __pid_t tcgetsid (int __fd) __attribute__ ((__nothrow__ , __leaf__));

// /usr/include/features.h
enum {
	_FEATURES_H          = 1,
};
#define __GNUC_PREREQ(maj,min) ((__GNUC__ << 16) + __GNUC_MINOR__ >= ((maj) << 16) + (min))
enum {
	_DEFAULT_SOURCE      = 1,
	_BSD_SOURCE          = 1,
	_SVID_SOURCE         = 1,
	__USE_POSIX_IMPLICITLY = 1,
	_POSIX_SOURCE        = 1,
	_POSIX_C_SOURCE      = 200809L,
	__USE_POSIX          = 1,
	__USE_POSIX2         = 1,
	__USE_POSIX199309    = 1,
	__USE_POSIX199506    = 1,
	__USE_XOPEN2K        = 1,
	__USE_ISOC95         = 1,
	__USE_ISOC99         = 1,
	__USE_XOPEN2K8       = 1,
	_ATFILE_SOURCE       = 1,
	__USE_MISC           = 1,
	__USE_BSD            = 1,
	__USE_SVID           = 1,
	__USE_ATFILE         = 1,
	__USE_FORTIFY_LEVEL  = 0,
	__GNU_LIBRARY__      = 6,
	__GLIBC__            = 2,
	__GLIBC_MINOR__      = 19,
};
#define __GLIBC_PREREQ(maj,min) ((__GLIBC__ << 16) + __GLIBC_MINOR__ >= ((maj) << 16) + (min))

// /usr/include/x86_64-linux-gnu/sys/cdefs.h
enum {
	_SYS_CDEFS_H         = 1,
	__LEAF               = , __leaf__,
	__LEAF_ATTR          = __attribute__ ((__leaf__)),
	__THROW              = __attribute__ ((__nothrow__ __LEAF)),
	__THROWNL            = __attribute__ ((__nothrow__)),
};
#define __NTH(fct) __attribute__ ((__nothrow__ __LEAF)) fct
#define __P(args) args
#define __PMT(args) args
#define __CONCAT(x,y) x ## y
#define __STRING(x) #x
enum {
	__ptr_t              = void *,
	__long_double_t      = long double,
};
#define __USING_NAMESPACE_STD(name) 
#define __USING_NAMESPACE_C99(name) 
#define __bos(ptr) __builtin_object_size (ptr, __USE_FORTIFY_LEVEL > 1)
#define __bos0(ptr) __builtin_object_size (ptr, 0)
enum {
	__fortify_function   = __extern_always_inline __attribute_artificial__,
};
#define __warndecl(name,msg) extern void name (void) __attribute__((__warning__ (msg)))
#define __warnattr(msg) __attribute__((__warning__ (msg)))
#define __errordecl(name,msg) extern void name (void) __attribute__((__error__ (msg)))
enum {
	__flexarr            = [],
};
#define __REDIRECT(name,proto,alias) name proto 
#define __REDIRECT_NTH(name,proto,alias) name proto 
#define __REDIRECT_NTHNL(name,proto,alias) name proto 
#define __ASMNAME(cname) __ASMNAME2 (__USER_LABEL_PREFIX__, cname)
#define __ASMNAME2(prefix,cname) __STRING (prefix) cname
enum {
	__attribute_malloc__ = __attribute__ ((__malloc__)),
};
#define __attribute_alloc_size__(params) __attribute__ ((__alloc_size__ params))
enum {
	__attribute_pure__   = __attribute__ ((__pure__)),
	__attribute_const__  = __attribute__ ((__const__)),
	__attribute_used__   = __attribute__ ((__used__)),
	__attribute_noinline__ = __attribute__ ((__noinline__)),
	__attribute_deprecated__ = __attribute__ ((__deprecated__)),
};
#define __attribute_format_arg__(x) __attribute__ ((__format_arg__ (x)))
#define __attribute_format_strfmon__(a,b) __attribute__ ((__format__ (__strfmon__, a, b)))
#define __nonnull(params) __attribute__ ((__nonnull__ params))
enum {
	__attribute_warn_unused_result__ = __attribute__ ((__warn_unused_result__)),
	__always_inline      = __inline __attribute__ ((__always_inline__)),
	__attribute_artificial__ = __attribute__ ((__artificial__)),
	__extern_inline      = extern __inline __attribute__ ((__gnu_inline__)),
	__extern_always_inline = extern __always_inline __attribute__ ((__gnu_inline__)),
};
#define __va_arg_pack() __builtin_va_arg_pack ()
#define __va_arg_pack_len() __builtin_va_arg_pack_len ()
enum {
	__restrict_arr       = __restrict,
};
#define __glibc_unlikely(cond) __builtin_expect ((cond), 0)
#define __glibc_likely(cond) __builtin_expect ((cond), 1)
#define __LDBL_REDIR1(name,proto,alias) name proto
#define __LDBL_REDIR(name,proto) name proto
#define __LDBL_REDIR1_NTH(name,proto,alias) name proto __THROW
#define __LDBL_REDIR_NTH(name,proto) name proto __THROW
#define __LDBL_REDIR_DECL(name) 
#define __REDIRECT_LDBL(name,proto,alias) __REDIRECT (name, proto, alias)
#define __REDIRECT_NTH_LDBL(name,proto,alias) __REDIRECT_NTH (name, proto, alias)

// /usr/include/x86_64-linux-gnu/bits/wordsize.h
enum {
	__WORDSIZE           = 64,
	__WORDSIZE_TIME64_COMPAT32 = 1,
	__SYSCALL_WORDSIZE   = 64,
	__WORDSIZE           = 64,
	__WORDSIZE_TIME64_COMPAT32 = 1,
	__SYSCALL_WORDSIZE   = 64,
};

// /usr/include/x86_64-linux-gnu/gnu/stubs-64.h

// /usr/include/x86_64-linux-gnu/bits/types.h
enum {
	_BITS_TYPES_H        = 1,
};
typedef unsigned char __u_char;
typedef unsigned short int __u_short;
typedef unsigned int __u_int;
typedef unsigned long int __u_long;
typedef signed char __int8_t;
typedef unsigned char __uint8_t;
typedef signed short int __int16_t;
typedef unsigned short int __uint16_t;
typedef signed int __int32_t;
typedef unsigned int __uint32_t;
typedef signed long int __int64_t;
typedef unsigned long int __uint64_t;
typedef long int __quad_t;
typedef unsigned long int __u_quad_t;
enum {
	__S16_TYPE           = short int,
	__U16_TYPE           = unsigned short int,
	__S32_TYPE           = int,
	__U32_TYPE           = unsigned int,
	__SLONGWORD_TYPE     = long int,
	__ULONGWORD_TYPE     = unsigned long int,
	__SQUAD_TYPE         = long int,
	__UQUAD_TYPE         = unsigned long int,
	__SWORD_TYPE         = long int,
	__UWORD_TYPE         = unsigned long int,
	__SLONG32_TYPE       = int,
	__ULONG32_TYPE       = unsigned int,
	__S64_TYPE           = long int,
	__U64_TYPE           = unsigned long int,
	__STD_TYPE           = typedef,
};
typedef unsigned long int __dev_t;
typedef unsigned int __uid_t;
typedef unsigned int __gid_t;
typedef unsigned long int __ino_t;
typedef unsigned long int __ino64_t;
typedef unsigned int __mode_t;
typedef unsigned long int __nlink_t;
typedef long int __off_t;
typedef long int __off64_t;
typedef int __pid_t;
typedef struct { int __val[2]; } __fsid_t;
typedef long int __clock_t;
typedef unsigned long int __rlim_t;
typedef unsigned long int __rlim64_t;
typedef unsigned int __id_t;
typedef long int __time_t;
typedef unsigned int __useconds_t;
typedef long int __suseconds_t;
typedef int __daddr_t;
typedef int __key_t;
typedef int __clockid_t;
typedef void * __timer_t;
typedef long int __blksize_t;
typedef long int __blkcnt_t;
typedef long int __blkcnt64_t;
typedef unsigned long int __fsblkcnt_t;
typedef unsigned long int __fsblkcnt64_t;
typedef unsigned long int __fsfilcnt_t;
typedef unsigned long int __fsfilcnt64_t;
typedef long int __fsword_t;
typedef long int __ssize_t;
typedef long int __syscall_slong_t;
typedef unsigned long int __syscall_ulong_t;
typedef __off64_t __loff_t;
typedef __quad_t *__qaddr_t;
typedef char *__caddr_t;
typedef long int __intptr_t;
typedef unsigned int __socklen_t;

// /usr/include/x86_64-linux-gnu/bits/typesizes.h
enum {
	_BITS_TYPESIZES_H    = 1,
	__SYSCALL_SLONG_TYPE = __SLONGWORD_TYPE,
	__SYSCALL_ULONG_TYPE = __ULONGWORD_TYPE,
	__DEV_T_TYPE         = __UQUAD_TYPE,
	__UID_T_TYPE         = __U32_TYPE,
	__GID_T_TYPE         = __U32_TYPE,
	__INO_T_TYPE         = __SYSCALL_ULONG_TYPE,
	__INO64_T_TYPE       = __UQUAD_TYPE,
	__MODE_T_TYPE        = __U32_TYPE,
	__NLINK_T_TYPE       = __SYSCALL_ULONG_TYPE,
	__FSWORD_T_TYPE      = __SYSCALL_SLONG_TYPE,
	__OFF_T_TYPE         = __SYSCALL_SLONG_TYPE,
	__OFF64_T_TYPE       = __SQUAD_TYPE,
	__PID_T_TYPE         = __S32_TYPE,
	__RLIM_T_TYPE        = __SYSCALL_ULONG_TYPE,
	__RLIM64_T_TYPE      = __UQUAD_TYPE,
	__BLKCNT_T_TYPE      = __SYSCALL_SLONG_TYPE,
	__BLKCNT64_T_TYPE    = __SQUAD_TYPE,
	__FSBLKCNT_T_TYPE    = __SYSCALL_ULONG_TYPE,
	__FSBLKCNT64_T_TYPE  = __UQUAD_TYPE,
	__FSFILCNT_T_TYPE    = __SYSCALL_ULONG_TYPE,
	__FSFILCNT64_T_TYPE  = __UQUAD_TYPE,
	__ID_T_TYPE          = __U32_TYPE,
	__CLOCK_T_TYPE       = __SYSCALL_SLONG_TYPE,
	__TIME_T_TYPE        = __SYSCALL_SLONG_TYPE,
	__USECONDS_T_TYPE    = __U32_TYPE,
	__SUSECONDS_T_TYPE   = __SYSCALL_SLONG_TYPE,
	__DADDR_T_TYPE       = __S32_TYPE,
	__KEY_T_TYPE         = __S32_TYPE,
	__CLOCKID_T_TYPE     = __S32_TYPE,
	__TIMER_T_TYPE       = void *,
	__BLKSIZE_T_TYPE     = __SYSCALL_SLONG_TYPE,
	__FSID_T_TYPE        = struct { int __val[2]; },
	__SSIZE_T_TYPE       = __SWORD_TYPE,
	__OFF_T_MATCHES_OFF64_T = 1,
	__INO_T_MATCHES_INO64_T = 1,
	__FD_SETSIZE         = 1024,
};

// /usr/include/x86_64-linux-gnu/bits/termios.h
typedef unsigned char cc_t;
typedef unsigned int speed_t;
typedef unsigned int tcflag_t;
enum {
	NCCS                 = 32,
};
struct termios
  {
    tcflag_t c_iflag;
    tcflag_t c_oflag;
    tcflag_t c_cflag;
    tcflag_t c_lflag;
    cc_t c_line;
    cc_t c_cc[32];
    speed_t c_ispeed;
    speed_t c_ospeed;
enum {
	_HAVE_STRUCT_TERMIOS_C_ISPEED = 1,
	_HAVE_STRUCT_TERMIOS_C_OSPEED = 1,
};
  };
enum {
	VINTR                = 0,
	VQUIT                = 1,
	VERASE               = 2,
	VKILL                = 3,
	VEOF                 = 4,
	VTIME                = 5,
	VMIN                 = 6,
	VSWTC                = 7,
	VSTART               = 8,
	VSTOP                = 9,
	VSUSP                = 10,
	VEOL                 = 11,
	VREPRINT             = 12,
	VDISCARD             = 13,
	VWERASE              = 14,
	VLNEXT               = 15,
	VEOL2                = 16,
	IGNBRK               = 0000001,
	BRKINT               = 0000002,
	IGNPAR               = 0000004,
	PARMRK               = 0000010,
	INPCK                = 0000020,
	ISTRIP               = 0000040,
	INLCR                = 0000100,
	IGNCR                = 0000200,
	ICRNL                = 0000400,
	IUCLC                = 0001000,
	IXON                 = 0002000,
	IXANY                = 0004000,
	IXOFF                = 0010000,
	IMAXBEL              = 0020000,
	IUTF8                = 0040000,
	OPOST                = 0000001,
	OLCUC                = 0000002,
	ONLCR                = 0000004,
	OCRNL                = 0000010,
	ONOCR                = 0000020,
	ONLRET               = 0000040,
	OFILL                = 0000100,
	OFDEL                = 0000200,
	NLDLY                = 0000400,
	NL0                  = 0000000,
	NL1                  = 0000400,
	CRDLY                = 0003000,
	CR0                  = 0000000,
	CR1                  = 0001000,
	CR2                  = 0002000,
	CR3                  = 0003000,
	TABDLY               = 0014000,
	TAB0                 = 0000000,
	TAB1                 = 0004000,
	TAB2                 = 0010000,
	TAB3                 = 0014000,
	BSDLY                = 0020000,
	BS0                  = 0000000,
	BS1                  = 0020000,
	FFDLY                = 0100000,
	FF0                  = 0000000,
	FF1                  = 0100000,
	VTDLY                = 0040000,
	VT0                  = 0000000,
	VT1                  = 0040000,
	XTABS                = 0014000,
	CBAUD                = 0010017,
	B0                   = 0000000,
	B50                  = 0000001,
	B75                  = 0000002,
	B110                 = 0000003,
	B134                 = 0000004,
	B150                 = 0000005,
	B200                 = 0000006,
	B300                 = 0000007,
	B600                 = 0000010,
	B1200                = 0000011,
	B1800                = 0000012,
	B2400                = 0000013,
	B4800                = 0000014,
	B9600                = 0000015,
	B19200               = 0000016,
	B38400               = 0000017,
	EXTA                 = B19200,
	EXTB                 = B38400,
	CSIZE                = 0000060,
	CS5                  = 0000000,
	CS6                  = 0000020,
	CS7                  = 0000040,
	CS8                  = 0000060,
	CSTOPB               = 0000100,
	CREAD                = 0000200,
	PARENB               = 0000400,
	PARODD               = 0001000,
	HUPCL                = 0002000,
	CLOCAL               = 0004000,
	CBAUDEX              = 0010000,
	B57600               = 0010001,
	B115200              = 0010002,
	B230400              = 0010003,
	B460800              = 0010004,
	B500000              = 0010005,
	B576000              = 0010006,
	B921600              = 0010007,
	B1000000             = 0010010,
	B1152000             = 0010011,
	B1500000             = 0010012,
	B2000000             = 0010013,
	B2500000             = 0010014,
	B3000000             = 0010015,
	B3500000             = 0010016,
	B4000000             = 0010017,
	__MAX_BAUD           = B4000000,
	CIBAUD               = 002003600000,
	CMSPAR               = 010000000000,
	CRTSCTS              = 020000000000,
	ISIG                 = 0000001,
	ICANON               = 0000002,
	XCASE                = 0000004,
	ECHO                 = 0000010,
	ECHOE                = 0000020,
	ECHOK                = 0000040,
	ECHONL               = 0000100,
	NOFLSH               = 0000200,
	TOSTOP               = 0000400,
	ECHOCTL              = 0001000,
	ECHOPRT              = 0002000,
	ECHOKE               = 0004000,
	FLUSHO               = 0010000,
	PENDIN               = 0040000,
	IEXTEN               = 0100000,
	EXTPROC              = 0200000,
	TCOOFF               = 0,
	TCOON                = 1,
	TCIOFF               = 2,
	TCION                = 3,
	TCIFLUSH             = 0,
	TCOFLUSH             = 1,
	TCIOFLUSH            = 2,
	TCSANOW              = 0,
	TCSADRAIN            = 1,
	TCSAFLUSH            = 2,
	_IOT_termios         = _IOT (_IOTS (cflag_t), 4, _IOTS (cc_t), NCCS, _IOTS (speed_t), 2),
};

// /usr/include/x86_64-linux-gnu/sys/ttydefaults.h
enum {
	TTYDEF_IFLAG         = (BRKINT | ISTRIP | ICRNL | IMAXBEL | IXON | IXANY),
	TTYDEF_OFLAG         = (OPOST | ONLCR | XTABS),
	TTYDEF_LFLAG         = (ECHO | ICANON | ISIG | IEXTEN | ECHOE|ECHOKE|ECHOCTL),
	TTYDEF_CFLAG         = (CREAD | CS7 | PARENB | HUPCL),
	TTYDEF_SPEED         = (B9600),
};
#define CTRL(x) (x&037)
enum {
	CEOF                 = CTRL('d'),
	CEOL                 = '\0',
	CERASE               = 0177,
	CINTR                = CTRL('c'),
	CSTATUS              = '\0',
	CKILL                = CTRL('u'),
	CMIN                 = 1,
	CQUIT                = 034,
	CSUSP                = CTRL('z'),
	CTIME                = 0,
	CDSUSP               = CTRL('y'),
	CSTART               = CTRL('q'),
	CSTOP                = CTRL('s'),
	CLNEXT               = CTRL('v'),
	CDISCARD             = CTRL('o'),
	CWERASE              = CTRL('w'),
	CREPRINT             = CTRL('r'),
	CEOT                 = CEOF,
	CBRK                 = CEOL,
	CRPRNT               = CREPRINT,
	CFLUSH               = CDISCARD,
};
]]
