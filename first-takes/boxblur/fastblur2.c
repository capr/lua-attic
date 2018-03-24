//go@ gcc fastblur2.c -msse2 -O3 -o ../../bin/mingw64/fastblur2.dll -shared

#include <x86intrin.h>
#include <stdint.h>
#include <stdio.h>

void fast_blur_horiz2d( uint16_t *in, uint16_t *blurred,
	int32_t width, int32_t height, int32_t src_stride, int32_t dst_stride )
{
	int R = 41;
	int hR = (R - 1) / 2;
	int y;
	__m128i fraction;
	__m128i *dst0;

	fraction = _mm_set1_epi16(65536 / R);
	dst0 = (__m128i *)(blurred + 0 * dst_stride);

	for( y = 0; y < height; y += R-2 ) {

		uint16_t *row;
		int x;

		row = in + y * src_stride;

		for( x = 0; x < width >> 3; x ++ ) {

			int i;
			__m128i s[R];
			__m128i r[R];

			inline __m128i row_avg(int row_offset) {
				const uint16_t* row1 = row + row_offset * src_stride;
				int i;
				__m128i avg = _mm_set1_epi16(0);
				for (i = 0; i < R; i++) {
					s[i] = _mm_loadu_si128( (__m128i*)(row1 + i - 2) );
					avg = _mm_adds_epi16(avg, s[i]);
				}
				return _mm_mulhi_epi16(avg, fraction);
			};

			inline void store(__m128i* dst) {
				int i;
				__m128i avg = _mm_set1_epi16(0);
				for (i = 0; i < R; i++)
					avg = _mm_adds_epi16(avg, r[i]);
				_mm_store_si128(dst, _mm_mulhi_epi16(avg, fraction));
			};

			for(i = 0; i < R; i++)
				r[i] = row_avg(i - hR);
			store(dst0 + x);

			for(i = 0; i < R - 3; i++) {
				r[i] = row_avg(i + hR + 1);
				store(dst0 + x + (i + 1) * (dst_stride >> 3));
			}
			row += 8;
		}

		dst0 += (R-2) * dst_stride >> 3;

	}

}
