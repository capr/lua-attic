//go@ gcc fastblur1.c -msse2 -O3 -o ../../bin/mingw64/fastblur1.dll -shared

#include <x86intrin.h>
#include <stdint.h>
#include <stdio.h>

void fast_blur_horiz2d( const uint16_t *in, uint16_t *blurred,
	int32_t width, int32_t height, int32_t src_stride, int32_t dst_stride )
{
	int32_t x, y;
	__m128i one_third;
	__m128i *dst0, *dst1;

	one_third = _mm_set1_epi16(21846);
	dst0 = (__m128i *)blurred;
	dst1 = (__m128i *)(blurred + dst_stride);

	for( y = 0; y < height; y += 2 ) {
		const uint16_t *row0, *row1, *row2, *row3;

		row1 = in + y * src_stride;
		row0 = row1 - src_stride;
		row2 = row1 + src_stride;
		row3 = row2 + src_stride;

		for( x = 0; x < width; x += 8 ) {
			__m128i s00, s01, s02;
			__m128i r00, r01, r02;

			s00 = _mm_loadu_si128( (__m128i*)(row0-1) );
			s01 = _mm_loadu_si128( (__m128i*)(row0+1) );
			s02 = _mm_load_si128(  (__m128i*)(row0) );
			r00 = _mm_mulhi_epi16( _mm_adds_epi16( _mm_adds_epi16( s00, s01 ), s02 ), one_third );

			s00 = _mm_loadu_si128( (__m128i*)(row1-1) );
			s01 = _mm_loadu_si128( (__m128i*)(row1+1) );
			s02 = _mm_load_si128(  (__m128i*)(row1) );
			r01 = _mm_mulhi_epi16( _mm_adds_epi16( _mm_adds_epi16( s00, s01 ), s02 ), one_third );

			s00 = _mm_loadu_si128( (__m128i*)(row2-1) );
			s01 = _mm_loadu_si128( (__m128i*)(row2+1) );
			s02 = _mm_load_si128(  (__m128i*)(row2) );
			r02 = _mm_mulhi_epi16( _mm_adds_epi16( _mm_adds_epi16( s00, s01 ), s02 ), one_third );

			_mm_store_si128( dst0++, _mm_mulhi_epi16( _mm_adds_epi16( _mm_adds_epi16( r00, r01 ), r02 ), one_third ) );

			s00 = _mm_loadu_si128( (__m128i*)(row3-1) );
			s01 = _mm_loadu_si128( (__m128i*)(row3+1) );
			s02 = _mm_load_si128(  (__m128i*)(row3) );
			r00 = _mm_mulhi_epi16( _mm_adds_epi16( _mm_adds_epi16( s00, s01 ), s02 ), one_third );

			_mm_store_si128( dst1++, _mm_mulhi_epi16( _mm_adds_epi16( _mm_adds_epi16( r00, r01 ), r02 ), one_third ) );

			row0 += 8;
			row1 += 8;
			row2 += 8;
			row3 += 8;
		}

		dst0 += dst_stride >> 3;
		dst1 += dst_stride >> 3;

	}

}
