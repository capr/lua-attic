# build with included hash generator, included regex, included http parser, dynamic bind to zlib
# no ssl, no ssh, no iconv, no tracing
gcc -O2 -shared -o ../../bin/mingw32/git2.dll \
	src/*.c -Isrc -Iinclude src/xdiff/*.c src/transports/*.c \
	src/hash/hash_generic.c \
	deps/http-parser/*.c -Ideps/http-parser \
	deps/regex/regex.c -Ideps/regex \
	-I../zlib -L../../bin/mingw32 -lz \
	-DGIT_THREADS -DGIT_ARCH_32 -DWINVER=0x501 src/win32/*.c -lws2_32
