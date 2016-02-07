${X}gcc -c -O2 $C *.c -I. -D_FILE_OFFSET_BITS=64
${X}gcc *.o -shared -o ../../bin/$P/$D $L
${X}ar rcs ../../bin/$P/$A *.o
rm *.o
