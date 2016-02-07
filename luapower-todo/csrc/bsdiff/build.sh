${X}gcc -c -O3 $C *.c -I. -D_FILE_OFFSET_BITS=64
${X}gcc *.o -shared -o ../../bin/$P/$D $L -lbz2 -L../../bin/$P
${X}ar rcs ../../bin/$P/$A *.o
rm *.o
