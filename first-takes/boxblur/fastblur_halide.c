//go@ gcc fastblur_halide.c -msse2 -O3 -o ../../bin/mingw64/fastblur_halide.dll -shared

#include <x86intrin.h>
#include <stdint.h>
#include <stdio.h>

void fast_blur_halide( const uint16_t *in, uint16_t *blurred,
	int32_t width, int32_t height, int32_t src_stride, int32_t dst_stride )
{
	int32_t x, y;
	int32_t xTile, yTile;
	__m128i one_third;

	one_third = _mm_set1_epi16(21846);

	for( yTile = 0; yTile < height; yTile += 32 ) {
		__m128i a, b, c;
		__m128i sum, avg;
		__m128i tmp[(256/8)*(32+2)];

		for( xTile = 0; xTile < width; xTile += 256 ) {
			__m128i *tmpPtr = tmp;
			for (y = -1; y < 32+1; y++) {
				const uint16_t *inPtr = &in[(yTile+y)*src_stride + xTile];
				for (x = 0; x < 256; x += 8) {
					a = _mm_loadu_si128( (__m128i*)(inPtr-1) );
					b = _mm_loadu_si128( (__m128i*)(inPtr+1) );
					c = _mm_load_si128(  (__m128i*)(inPtr)   );
					sum = _mm_adds_epi16( _mm_adds_epi16( a, b ), c );
					avg = _mm_mulhi_epi16( sum, one_third );
					_mm_store_si128( tmpPtr++, avg );
					inPtr += 8;
				}
			}

			tmpPtr = tmp;

			for (y = 0; y < 32; y++) {
				__m128i *outPtr = (__m128i *)&blurred[(yTile+y)*dst_stride + xTile];
				for( x = 0; x < 256; x += 8 ) {
					a = _mm_load_si128( tmpPtr+(2*256)/8 );
					b = _mm_load_si128( tmpPtr+256/8     );
					c = _mm_load_si128( tmpPtr++         );
					sum = _mm_adds_epi16( _mm_adds_epi16( a, b ), c );
					avg = _mm_mulhi_epi16( sum, one_third );
					_mm_store_si128( outPtr++, avg );
				}
			}
		}
	}
}
