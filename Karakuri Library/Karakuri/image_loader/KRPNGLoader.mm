/*!
    @file   KRPNGLoader.mm
    @author numata
    @date   09/08/14
 */

#import "KRPNGLoader.h"


/*
    This PNG image loader is based on stbi-1.18 (public domain JPEG/PNG reader): http://nothings.org/stb_image.c
 */


#pragma mark Texture Loading Own Implementation

//////////////////////////////////////////////////////////////////////////////
//
// Own loading is supported by stbi-1.18 (public domain PNG reader): http://nothings.org/stb_image.c
//

#define __forceinline   inline

int stbi_png_partial;   // a quick hack to only allow decoding some of a PNG... I should implement real streaming support instead


#pragma mark -
#pragma mark Error Handling

static const char *failure_reason;

const char *stbi_get_failure_reason(void)
{
    return failure_reason;
}

static void stbi_set_failure_reason(const char *str)
{
    failure_reason = str;
}


#pragma mark -
#pragma mark Generic Types

//////////////////////////////////////////////////////////////////////////////
//
// Generic API that works on all image types
//

// this is not threadsafe

typedef unsigned char   stbi_uint8;
typedef unsigned short  stbi_uint16;
typedef unsigned int    stbi_uint32;

typedef unsigned char   stbi_uc;


#pragma mark -
#pragma mark Image Buffer Handling

//////////////////////////////////////////////////////////////////////////////
//
// Common code used by all image loaders
//

enum {
    SCAN_load=0,
    SCAN_type,
    SCAN_header,
};

typedef struct {
    stbi_uint32 img_x, img_y;
    int img_n, img_out_n;
    
    unsigned char *img_buffer;
    unsigned char *img_buffer_end;
} STBI_ImageContext;

static void stbi_img_start_mem(STBI_ImageContext *s, stbi_uint8 const *buffer, int len)
{
    s->img_buffer = (stbi_uint8 *)buffer;
    s->img_buffer_end = (stbi_uint8 *)buffer+len;
}

__forceinline static int stbi_img_get8(STBI_ImageContext *s)
{
    int ret = 0;
    if (s->img_buffer < s->img_buffer_end) {
        ret = *s->img_buffer++;
    }
    return ret;
}

__forceinline static stbi_uint8 stbi_img_get8u(STBI_ImageContext *s)
{
    return (stbi_uint8) stbi_img_get8(s);
}

static void stbi_img_skip(STBI_ImageContext *s, int n)
{
    s->img_buffer += n;
}

static int stbi_img_get16(STBI_ImageContext *s)
{
    int z = stbi_img_get8(s);
    return (z << 8) + stbi_img_get8(s);
}

static stbi_uint32 stbi_img_get32(STBI_ImageContext *s)
{
    stbi_uint32 z = stbi_img_get16(s);
    return (z << 16) + stbi_img_get16(s);
}

static void stbi_img_getn(STBI_ImageContext *s, stbi_uc *buffer, int n)
{
    memcpy(buffer, s->img_buffer, n);
    s->img_buffer += n;
}


//////////////////////////////////////////////////////////////////////////////
//
//  generic converter from built-in img_n to req_comp
//    individual types do this automatically as much as possible (e.g. jpeg
//    does all cases internally since it needs to colorspace convert anyway,
//    and it never has alpha, so very few cases ). png can automatically
//    interleave an alpha=255 channel, but falls back to this for other cases
//
//  assume data buffer is malloced, so malloc a new one and free that one
//  only failure mode is malloc failing

static void stbi_img_free(void *retval_from_stbi_load)
{
    free(retval_from_stbi_load);
}

static stbi_uint8 stbi_img_compute_y(int r, int g, int b)
{
    return (stbi_uint8) (((r*77) + (g*150) +  (29*b)) >> 8);
}

static unsigned char *stbi_img_convert_format(unsigned char *data, int img_n, int req_comp, int x, int y, int rwidth, int rheight)
{
    if (req_comp == img_n && rwidth == x && rheight == y) {
        return data;
    }
    
    assert(req_comp >= 1 && req_comp <= 4);
    
    if (rwidth <= 0) {
        rwidth = x;
    }
    if (rheight <= 0) {
        rheight = y;
    }
    
    //good = (unsigned char *)malloc(req_comp * x * y);
    unsigned char *good = (unsigned char *)malloc(req_comp * rwidth * rheight);
    if (good == NULL) {
        free(data);
        stbi_set_failure_reason("Out of memory");
        return NULL;
    }
    
    for (int j = 0; j < (int)y; j++) {
        unsigned char *src = data + j * x * img_n;
        unsigned char *dest = good + j * rwidth * req_comp;
        
#define COMBO(a,b)  ((a)*8+(b))
#define CASE(a,b)   case COMBO(a,b): for(int i=x-1; i >= 0; --i, src += a, dest += b)
        // convert source image with img_n components to one with req_comp components;
        // avoid switch per pixel, so use switch per scanline and massive macros
        switch (COMBO(img_n, req_comp)) {
                CASE(1,2) dest[0]=src[0], dest[1]=255; break;
                CASE(1,3) dest[0]=dest[1]=dest[2]=src[0]; break;
                CASE(1,4) dest[0]=dest[1]=dest[2]=src[0], dest[3]=255; break;
                CASE(2,1) dest[0]=src[0]; break;
                CASE(2,3) dest[0]=dest[1]=dest[2]=src[0]; break;
                CASE(2,4) dest[0]=dest[1]=dest[2]=src[0], dest[3]=src[1]; break;
                CASE(3,4) dest[0]=src[0],dest[1]=src[1],dest[2]=src[2],dest[3]=255; break;
                CASE(3,1) dest[0]=stbi_img_compute_y(src[0],src[1],src[2]); break;
                CASE(3,3) dest[0]=src[0], dest[1]=src[1], dest[2]=src[2]; break;
                CASE(3,2) dest[0]=stbi_img_compute_y(src[0],src[1],src[2]), dest[1] = 255; break;
                CASE(4,1) dest[0]=stbi_img_compute_y(src[0],src[1],src[2]); break;
                CASE(4,2) dest[0]=stbi_img_compute_y(src[0],src[1],src[2]), dest[1] = src[3]; break;
                CASE(4,3) dest[0]=src[0],dest[1]=src[1],dest[2]=src[2]; break;
                CASE(4,4) dest[0]=src[0], dest[1]=src[1], dest[2]=src[2], dest[3]=src[3]; break;
            default: assert(0);
        }
#undef CASE
    }
    
    free(data);
    return good;
}


#pragma mark -
#pragma mark ZLib Decoding

// public domain zlib decode    v0.2  Sean Barrett 2006-11-18
//    simple implementation
//      - all input must be provided in an upfront buffer
//      - all output is written to a single output buffer (can malloc/realloc)
//    performance
//      - fast huffman

// fast-way is faster to check than jpeg huffman, but slow way is slower
#define ZFAST_BITS  9 // accelerate all cases in default tables
#define ZFAST_MASK  ((1 << ZFAST_BITS) - 1)

// zlib-style huffman encoding
// (jpegs packs from left, zlib from right, so can't share code)
typedef struct {
    stbi_uint16 fast[1 << ZFAST_BITS];
    stbi_uint16 firstcode[16];
    int maxcode[17];
    stbi_uint16 firstsymbol[16];
    stbi_uint8  size[288];
    stbi_uint16 value[288]; 
} STBI_ZHuffman;


__forceinline static int bitreverse16(int n)
{
    n = ((n & 0xAAAA) >>  1) | ((n & 0x5555) << 1);
    n = ((n & 0xCCCC) >>  2) | ((n & 0x3333) << 2);
    n = ((n & 0xF0F0) >>  4) | ((n & 0x0F0F) << 4);
    n = ((n & 0xFF00) >>  8) | ((n & 0x00FF) << 8);
    return n;
}

__forceinline static int bit_reverse(int v, int bits)
{
    assert(bits <= 16);
    // to bit reverse n bits, reverse 16 and shift
    // e.g. 11 bits, bit reverse and shift away 5
    return bitreverse16(v) >> (16-bits);
}

static BOOL stbi_zlib_zbuild_huffman(STBI_ZHuffman *z, stbi_uint8 *sizelist, int num)
{
    int k=0;
    int code, next_code[16], sizes[17];
    
    // DEFLATE spec for generating codes
    memset(sizes, 0, sizeof(sizes));
    memset(z->fast, 255, sizeof(z->fast));
    for (int i = 0; i < num; i++) {
        ++sizes[sizelist[i]];
    }
    sizes[0] = 0;
    for (int i = 1; i < 16; i++) {
        assert(sizes[i] <= (1 << i));
    }
    code = 0;
    for (int i = 1; i < 16; i++) {
        next_code[i] = code;
        z->firstcode[i] = (stbi_uint16) code;
        z->firstsymbol[i] = (stbi_uint16) k;
        code = (code + sizes[i]);
        if (sizes[i]) {
            if (code-1 >= (1 << i)) {
                stbi_set_failure_reason("Bad codelengths");
                return NO;
            }
        }
        z->maxcode[i] = code << (16-i); // preshift for inner loop
        code <<= 1;
        k += sizes[i];
    }
    z->maxcode[16] = 0x10000; // sentinel
    for (int i = 0; i < num; i++) {
        int s = sizelist[i];
        if (s) {
            int c = next_code[s] - z->firstcode[s] + z->firstsymbol[s];
            z->size[c] = (stbi_uint8)s;
            z->value[c] = (stbi_uint16)i;
            if (s <= ZFAST_BITS) {
                int k = bit_reverse(next_code[s],s);
                while (k < (1 << ZFAST_BITS)) {
                    z->fast[k] = (stbi_uint16) c;
                    k += (1 << s);
                }
            }
            ++next_code[s];
        }
    }
    return YES;
}

// zlib-from-memory implementation for PNG reading
//    because PNG allows splitting the zlib stream arbitrarily,
//    and it's annoying structurally to have PNG call ZLIB call PNG,
//    we require PNG read all the IDATs and combine them into a single
//    memory buffer

typedef struct {
    stbi_uint8 *zbuffer, *zbuffer_end;
    int num_bits;
    stbi_uint32 code_buffer;
    
    char *zout;
    char *zout_start;
    char *zout_end;
    int   z_expandable;
    
    STBI_ZHuffman z_length, z_distance;
} STBI_ZLibContext;

__forceinline static int stbi_zlib_get8(STBI_ZLibContext *zbuf)
{
    int ret = 0;
    if (zbuf->zbuffer < zbuf->zbuffer_end) {
        ret = *zbuf->zbuffer++;
    }
    return ret;
}

static void stbi_zlib_fill_bits(STBI_ZLibContext *z)
{
    do {
        assert(z->code_buffer < (1U << z->num_bits));
        z->code_buffer |= stbi_zlib_get8(z) << z->num_bits;
        z->num_bits += 8;
    } while (z->num_bits <= 24);
}

__forceinline static unsigned int stbi_zlib_zreceive(STBI_ZLibContext *z, int n)
{
    unsigned int k;
    if (z->num_bits < n) {
        stbi_zlib_fill_bits(z);
    }
    k = z->code_buffer & ((1 << n) - 1);
    z->code_buffer >>= n;
    z->num_bits -= n;
    return k;   
}

__forceinline static int stbi_zlib_zhuffman_decode(STBI_ZLibContext *a, STBI_ZHuffman *z)
{
    int b,s,k;
    if (a->num_bits < 16) {
        stbi_zlib_fill_bits(a);
    }
    b = z->fast[a->code_buffer & ZFAST_MASK];
    if (b < 0xffff) {
        s = z->size[b];
        a->code_buffer >>= s;
        a->num_bits -= s;
        return z->value[b];
    }
    
    // not resolved by fast table, so compute it the slow way
    // use jpeg approach, which requires MSbits at top
    k = bit_reverse(a->code_buffer, 16);
    for (s=ZFAST_BITS+1; ; ++s) {
        if (k < z->maxcode[s]) {
            break;
        }
    }
    if (s == 16) {
        return -1; // invalid code!
    }
    // code size is s, so:
    b = (k >> (16-s)) - z->firstcode[s] + z->firstsymbol[s];
    assert(z->size[b] == s);
    
    a->code_buffer >>= s;
    a->num_bits -= s;
    
    return z->value[b];
}

static BOOL stbi_zlib_expand(STBI_ZLibContext *zctx, int n)  // need to make room for n bytes
{
    if (!zctx->z_expandable) {
        stbi_set_failure_reason("Output buffer limit");
        return NO;
    }
    
    int cur = (int) (zctx->zout - zctx->zout_start);
    int limit = (int) (zctx->zout_end - zctx->zout_start);
    while (cur + n > limit) {
        limit *= 2;
    }
    char *q = (char *)realloc(zctx->zout_start, limit);
    if (q == NULL) {
        stbi_set_failure_reason("Out of memory");
        return NO;
    }
    zctx->zout_start = q;
    zctx->zout       = q + cur;
    zctx->zout_end   = q + limit;
    return YES;
}

static int length_base[31] = {
3,4,5,6,7,8,9,10,11,13,
15,17,19,23,27,31,35,43,51,59,
67,83,99,115,131,163,195,227,258,0,0
};

static int length_extra[31]= { 0,0,0,0,0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,0,0,0 };

static int dist_base[32] = {
1,2,3,4,5,7,9,13,17,25,33,49,65,97,129,193,
257,385,513,769,1025,1537,2049,3073,4097,6145,8193,12289,16385,24577,0,0
};

static int dist_extra[32] = { 0,0,0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13 };

static int stbi_zlib_parse_huffman_block(STBI_ZLibContext *zctx)
{
    while (YES) {
        int z = stbi_zlib_zhuffman_decode(zctx, &zctx->z_length);
        if (z < 256) {
            if (z < 0) {
                stbi_set_failure_reason("Bad huffman code");
                return NO;
            }
            if (zctx->zout >= zctx->zout_end && !stbi_zlib_expand(zctx, 1)) {
                return NO;
            }
            *zctx->zout++ = (char) z;
        } else {
            stbi_uint8 *p;
            int len,dist;
            if (z == 256) {
                return YES;
            }
            z -= 257;
            len = length_base[z];
            if (length_extra[z]) {
                len += stbi_zlib_zreceive(zctx, length_extra[z]);
            }
            z = stbi_zlib_zhuffman_decode(zctx, &zctx->z_distance);
            if (z < 0) {
                stbi_set_failure_reason("Bad huffman code");
                return NO;
            }
            dist = dist_base[z];
            if (dist_extra[z]) dist += stbi_zlib_zreceive(zctx, dist_extra[z]);
            if (zctx->zout - zctx->zout_start < dist) {
                stbi_set_failure_reason("Bad dist");
                return NO;
            }
            if (zctx->zout + len > zctx->zout_end && !stbi_zlib_expand(zctx, len)) {
                return NO;
            }
            p = (stbi_uint8 *)(zctx->zout - dist);
            while (len--) {
                *zctx->zout++ = *p++;
            }
        }
    }
}

static BOOL stbi_zlib_compute_huffman_codes(STBI_ZLibContext *zctx)
{
    static stbi_uint8 length_dezigzag[19] = { 16,17,18,0,8,7,9,6,10,5,11,4,12,3,13,2,14,1,15 };
    STBI_ZHuffman z_codelength;
    stbi_uint8 lencodes[286+32+137];//padding for maximum single op
    stbi_uint8 codelength_sizes[19];
    
    int hlit  = stbi_zlib_zreceive(zctx,5) + 257;
    int hdist = stbi_zlib_zreceive(zctx,5) + 1;
    int hclen = stbi_zlib_zreceive(zctx,4) + 4;
    
    memset(codelength_sizes, 0, sizeof(codelength_sizes));
    for (int i = 0; i < hclen; i++) {
        int s = stbi_zlib_zreceive(zctx, 3);
        codelength_sizes[length_dezigzag[i]] = (stbi_uint8)s;
    }
    if (!stbi_zlib_zbuild_huffman(&z_codelength, codelength_sizes, 19)) {
        return NO;
    }
    
    int n = 0;
    while (n < hlit + hdist) {
        int c = stbi_zlib_zhuffman_decode(zctx, &z_codelength);
        assert(c >= 0 && c < 19);
        if (c < 16)
            lencodes[n++] = (stbi_uint8) c;
        else if (c == 16) {
            c = stbi_zlib_zreceive(zctx,2)+3;
            memset(lencodes+n, lencodes[n-1], c);
            n += c;
        } else if (c == 17) {
            c = stbi_zlib_zreceive(zctx,3)+3;
            memset(lencodes+n, 0, c);
            n += c;
        } else {
            assert(c == 18);
            c = stbi_zlib_zreceive(zctx,7)+11;
            memset(lencodes+n, 0, c);
            n += c;
        }
    }
    if (n != hlit+hdist) {
        stbi_set_failure_reason("Bad codelengths");
        return NO;
    }
    if (!stbi_zlib_zbuild_huffman(&zctx->z_length, lencodes, hlit)) {
        return NO;
    }
    if (!stbi_zlib_zbuild_huffman(&zctx->z_distance, lencodes+hlit, hdist)) {
        return NO;
    }
    return YES;
}

static BOOL stbi_zlib_parse_uncompressed_block(STBI_ZLibContext *a)
{
    stbi_uint8 header[4];
    int len, nlen;
    
    if (a->num_bits & 7) {
        stbi_zlib_zreceive(a, a->num_bits & 7); // discard
    }
    
    // drain the bit-packed data into header
    int k = 0;
    while (a->num_bits > 0) {
        header[k++] = (stbi_uint8) (a->code_buffer & 255); // wtf this warns?
        a->code_buffer >>= 8;
        a->num_bits -= 8;
    }
    assert(a->num_bits == 0);
    
    // now fill header the normal way
    while (k < 4) {
        header[k++] = (stbi_uint8) stbi_zlib_get8(a);
    }
    len  = header[1] * 256 + header[0];
    nlen = header[3] * 256 + header[2];
    if (nlen != (len ^ 0xffff)) {
        stbi_set_failure_reason("Zlib corrupt");
        return NO;
    }
    if (a->zbuffer + len > a->zbuffer_end) {
        stbi_set_failure_reason("Read past buffer");
        return NO;
    }
    if (a->zout + len > a->zout_end) {
        if (!stbi_zlib_expand(a, len)) {
            return NO;
        }
    }
    memcpy(a->zout, a->zbuffer, len);
    a->zbuffer += len;
    a->zout += len;
    return YES;
}

static BOOL stbi_zlib_parse_header(STBI_ZLibContext *zctx)
{
    int cmf = stbi_zlib_get8(zctx);     // Compression Method and flags
    
    int cm = cmf & 15;  // Compression Method
    /* int cinfo = cmf >> 4;    // Compression Info */
    int flg = stbi_zlib_get8(zctx);
    
    if ((cmf * 256 + flg) % 31 != 0) {
        stbi_set_failure_reason("Invalid zlib header"); // zlib spec
        return NO;
    }
    if (flg & 32) {
        stbi_set_failure_reason("Preset dictionary is not allowed");    // preset dictionary is not allowed in PNG
        return NO;
    }
    if (cm != 8) {
        stbi_set_failure_reason("Invalid compression method");  // DEFLATE required for png
        return NO;
    }
    // window = 1 << (8 + cinfo)... but who cares, we fully buffer output
    return YES;
}

static BOOL stbi_zlib_default_is_initialized = NO;
static stbi_uint8 stbi_zlib_default_length[288];
static stbi_uint8 stbi_zlib_default_distance[32];

static void stbi_zlib_init_defaults(void)
{
    int i;   // use <= to match clearly with spec
    for (i = 0; i <= 143; i++) {
        stbi_zlib_default_length[i] = 8;
    }
    for (; i <= 255; i++) {
        stbi_zlib_default_length[i] = 9;
    }
    for (; i <= 279; i++) {
        stbi_zlib_default_length[i] = 7;
    }
    for (; i <= 287; i++) {
        stbi_zlib_default_length[i]   = 8;
    }
    for (i = 0; i <= 31; i++) {
        stbi_zlib_default_distance[i] = 5;
    }
    
    stbi_zlib_default_is_initialized = YES;
}

static BOOL stbi_zlib_parse(STBI_ZLibContext *zctx, BOOL parse_header)
{
    int final, type;
    if (parse_header) {
        if (!stbi_zlib_parse_header(zctx)) {
            return NO;
        }
    }
    zctx->num_bits = 0;
    zctx->code_buffer = 0;
    do {
        final = stbi_zlib_zreceive(zctx,1);
        type = stbi_zlib_zreceive(zctx,2);
        if (type == 0) {
            if (!stbi_zlib_parse_uncompressed_block(zctx)) {
                return NO;
            }
        } else if (type == 3) {
            return NO;
        } else {
            if (type == 1) {
                // use fixed code lengths
                if (!stbi_zlib_default_is_initialized) {
                    stbi_zlib_init_defaults();
                }
                if (!stbi_zlib_zbuild_huffman(&zctx->z_length, stbi_zlib_default_length, 288)) {
                    return NO;
                }
                if (!stbi_zlib_zbuild_huffman(&zctx->z_distance, stbi_zlib_default_distance, 32)) {
                    return NO;
                }
            } else {
                if (!stbi_zlib_compute_huffman_codes(zctx)) {
                    return NO;
                }
            }
            if (!stbi_zlib_parse_huffman_block(zctx)) {
                return NO;
            }
        }
        if (stbi_png_partial && zctx->zout - zctx->zout_start > 65536) {
            break;
        }
    } while (!final);
    return YES;
}

static BOOL stbi_zlib_do_zlib(STBI_ZLibContext *zctx, char *obuf, int olen, int exp, BOOL parse_header)
{
    zctx->zout_start = obuf;
    zctx->zout       = obuf;
    zctx->zout_end   = obuf + olen;
    zctx->z_expandable = exp;
    
    return stbi_zlib_parse(zctx, parse_header);
}

static char *stbi_zlib_decode_malloc_guesssize(const char *buffer, int len, int initial_size, int *outlen, BOOL parse_header)
{
    STBI_ZLibContext zctx;
    char *p = (char *)malloc(initial_size);
    if (p == NULL) {
        return NULL;
    }
    zctx.zbuffer = (stbi_uint8 *)buffer;
    zctx.zbuffer_end = (stbi_uint8 *) buffer + len;
    if (stbi_zlib_do_zlib(&zctx, p, initial_size, 1, parse_header)) {
        if (outlen) {
            *outlen = (int) (zctx.zout - zctx.zout_start);
        }
        return zctx.zout_start;
    } else {
        free(zctx.zout_start);
        return NULL;
    }
}

static char *stbi_zlib_decode_malloc(char const *buffer, int len, int *outlen, BOOL parse_header)
{
    return stbi_zlib_decode_malloc_guesssize(buffer, len, 16384, outlen, parse_header);
}


#pragma mark -
#pragma mark PNG Decoder

// public domain "baseline" PNG decoder   v0.10  Sean Barrett 2006-11-18
//    simple implementation
//      - only 8-bit samples
//      - no CRC checking
//      - allocates lots of intermediate memory
//        - avoids problem of streaming data between subsystems
//        - avoids explicit window management
//    performance
//      - uses stb_zlib, a PD zlib implementation with fast huffman decoding

#define STBI_PNG_TYPE(a,b,c,d)  (((a) << 24) + ((b) << 16) + ((c) << 8) + (d))

typedef struct {
    STBI_ImageContext image_ctx;
    stbi_uint8 *idata;
    stbi_uint8 *expanded;
    stbi_uint8 *out;
} STBI_PNGImage;


typedef struct {
    stbi_uint32 length;
    stbi_uint32 type;
} STBI_PNG_Chunk;


static STBI_PNG_Chunk stbi_png_get_chunk_header(STBI_ImageContext *s)
{
    STBI_PNG_Chunk c;
    c.length = stbi_img_get32(s);
    c.type   = stbi_img_get32(s);
    return c;
}

static BOOL stbi_png_check_header(STBI_PNGImage *png)
{
    STBI_ImageContext *image_ctx = &png->image_ctx;
    
    static stbi_uint8 png_sig[8] = { 0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a };
    for (int i = 0; i < 8; i++) {
        if (stbi_img_get8(image_ctx) != png_sig[i]) {
            stbi_set_failure_reason("Invalid PNG Signature");
            return NO;
        }
    }
    return YES;
}

enum {
    F_none=0, F_sub=1, F_up=2, F_avg=3, F_paeth=4,
    F_avg_first, F_paeth_first,
};

static stbi_uint8 first_row_filter[5] = {
F_none, F_sub, F_none, F_avg_first, F_paeth_first
};

static int stbi_png_paeth(int a, int b, int c)
{
    int p = a + b - c;
    int pa = abs(p-a);
    int pb = abs(p-b);
    int pc = abs(p-c);
    if (pa <= pb && pa <= pc) {
        return a;
    }
    if (pb <= pc) {
        return b;
    }
    return c;
}

// create the png data from post-deflated data
static BOOL stbi_png_create_image_raw(STBI_PNGImage *png, stbi_uint8 *raw, stbi_uint32 raw_len, int out_n, stbi_uint32 x, stbi_uint32 y)
{
    STBI_ImageContext *s = &png->image_ctx;
    stbi_uint32 i,stride = x*out_n;
    int k;
    int img_n = s->img_n; // copy it into a local for later
    assert(out_n == s->img_n || out_n == s->img_n+1);
    
    if (stbi_png_partial) {
        y = 1;
    }
    png->out = (stbi_uint8 *)malloc(x * y * out_n);
    if (png->out == NULL) {
        stbi_set_failure_reason("Out of memory");
        return NO;
    }
    
    if (!stbi_png_partial) {
        if (s->img_x == x && s->img_y == y) {
            if (raw_len != (img_n * x + 1) * y || raw_len < (img_n * x + 1) * y) {
                stbi_set_failure_reason("not enough pixels");
                return NO;
            }
        }
    }
    
    for (int j = 0; j < y; j++) {
        stbi_uint8 *cur = png->out + stride*j;
        stbi_uint8 *prior = cur - stride;
        int filter = *raw++;
        if (filter > 4) {
            stbi_set_failure_reason("invalid filter");
            return NO;
        }
        // if first row, use special filter that doesn't sample previous row
        if (j == 0) {
            filter = first_row_filter[filter];
        }
        // handle first pixel explicitly
        for (k=0; k < img_n; ++k) {
            switch (filter) {
                case F_none       : cur[k] = raw[k]; break;
                case F_sub        : cur[k] = raw[k]; break;
                case F_up         : cur[k] = raw[k] + prior[k]; break;
                case F_avg        : cur[k] = raw[k] + (prior[k]>>1); break;
                case F_paeth      : cur[k] = (stbi_uint8) (raw[k] + stbi_png_paeth(0,prior[k],0)); break;
                case F_avg_first  : cur[k] = raw[k]; break;
                case F_paeth_first: cur[k] = raw[k]; break;
            }
        }
        if (img_n != out_n) {
            cur[img_n] = 255;
        }
        raw += img_n;
        cur += out_n;
        prior += out_n;
        // this is a little gross, so that we don't switch per-pixel or per-component
        if (img_n == out_n) {
#define CASE(f) \
case f:     \
for (i=x-1; i >= 1; --i, raw+=img_n,cur+=img_n,prior+=img_n) \
for (k=0; k < img_n; ++k)
            switch(filter) {
                    CASE(F_none)  cur[k] = raw[k]; break;
                    CASE(F_sub)   cur[k] = raw[k] + cur[k-img_n]; break;
                    CASE(F_up)    cur[k] = raw[k] + prior[k]; break;
                    CASE(F_avg)   cur[k] = raw[k] + ((prior[k] + cur[k-img_n])>>1); break;
                    CASE(F_paeth)  cur[k] = (stbi_uint8) (raw[k] + stbi_png_paeth(cur[k-img_n],prior[k],prior[k-img_n])); break;
                    CASE(F_avg_first)    cur[k] = raw[k] + (cur[k-img_n] >> 1); break;
                    CASE(F_paeth_first)  cur[k] = (stbi_uint8) (raw[k] + stbi_png_paeth(cur[k-img_n],0,0)); break;
            }
#undef CASE
        } else {
            assert(img_n+1 == out_n);
#define CASE(f) \
case f:     \
for (i=x-1; i >= 1; --i, cur[img_n]=255,raw+=img_n,cur+=out_n,prior+=out_n) \
for (k=0; k < img_n; ++k)
            switch(filter) {
                    CASE(F_none)  cur[k] = raw[k]; break;
                    CASE(F_sub)   cur[k] = raw[k] + cur[k-out_n]; break;
                    CASE(F_up)    cur[k] = raw[k] + prior[k]; break;
                    CASE(F_avg)   cur[k] = raw[k] + ((prior[k] + cur[k-out_n])>>1); break;
                    CASE(F_paeth)  cur[k] = (stbi_uint8) (raw[k] + stbi_png_paeth(cur[k-out_n],prior[k],prior[k-out_n])); break;
                    CASE(F_avg_first)    cur[k] = raw[k] + (cur[k-out_n] >> 1); break;
                    CASE(F_paeth_first)  cur[k] = (stbi_uint8) (raw[k] + stbi_png_paeth(cur[k-out_n],0,0)); break;
            }
#undef CASE
        }
    }
    return YES;
}

static BOOL stbi_png_create_image(STBI_PNGImage *png, stbi_uint8 *raw, stbi_uint32 raw_len, int out_n, int interlaced)
{
    if (!interlaced) {
        return stbi_png_create_image_raw(png, raw, raw_len, out_n, png->image_ctx.img_x, png->image_ctx.img_y);
    }
    
    int old_stbi_png_partial = stbi_png_partial;
    stbi_png_partial = 0;
    
    // de-interlacing
    stbi_uint8 *final = (stbi_uint8 *) malloc(png->image_ctx.img_x * png->image_ctx.img_y * out_n);
    for (int p = 0; p < 7; p++) {
        int xorig[] = { 0, 4, 0, 2, 0, 1, 0 };
        int yorig[] = { 0, 0, 4, 0, 2, 0, 1 };
        int xspc[] = { 8, 8, 4, 4, 2, 2, 1 };
        int yspc[] = { 8, 8, 8, 4, 4, 2, 2 };
        // pass1_x[4] = 0, pass1_x[5] = 1, pass1_x[12] = 1
        int x = (png->image_ctx.img_x - xorig[p] + xspc[p]-1) / xspc[p];
        int y = (png->image_ctx.img_y - yorig[p] + yspc[p]-1) / yspc[p];
        if (x && y) {
            if (!stbi_png_create_image_raw(png, raw, raw_len, out_n, x, y)) {
                free(final);
                return NO;
            }
            for (int j = 0; j < y; j++) {
                for (int i = 0; i < x; i++) {
                    memcpy(final + (j*yspc[p]+yorig[p])*png->image_ctx.img_x*out_n + (i*xspc[p]+xorig[p])*out_n,
                           png->out + (j*x+i)*out_n, out_n);
                }
            }
            free(png->out);
            raw += (x * out_n + 1) * y;
            raw_len -= (x * out_n + 1) * y;
        }
    }
    png->out = final;
    
    stbi_png_partial = old_stbi_png_partial;
    return YES;
}

/*!
 Compute color-based transparency, assuming we've
 already got 255 as the alpha value in the output.
 */
static BOOL stbi_png_compute_transparency(STBI_PNGImage *png, stbi_uint8 tc[3], int out_n)
{
    assert(out_n == 2 || out_n == 4);
    
    STBI_ImageContext *s = &png->image_ctx;
    stbi_uint32 pixel_count = s->img_x * s->img_y;
    stbi_uint8 *p = png->out;
    
    if (out_n == 2) {
        for (int i = 0; i < pixel_count; i++) {
            p[1] = (p[0] == tc[0])? 0: 255;
            p += 2;
        }
    } else {
        for (int i = 0; i < pixel_count; i++) {
            if (p[0] == tc[0] && p[1] == tc[1] && p[2] == tc[2]) {
                p[3] = 0;
            }
            p += 4;
        }
    }
    return YES;
}

static BOOL stbi_png_expand_palette(STBI_PNGImage *png, stbi_uint8 *palette, int len, int pal_img_n)
{
    stbi_uint32 pixel_count = png->image_ctx.img_x * png->image_ctx.img_y;
    
    stbi_uint8 *p = (stbi_uint8 *)malloc(pixel_count * pal_img_n);
    if (p == NULL) {
        stbi_set_failure_reason("Out of memory");
        return NO;
    }
    
    // between here and free(out) below, exitting would leak
    stbi_uint8 *orig = png->out;
    stbi_uint8 *temp_out = p;
    
    if (pal_img_n == 3) {
        for (int i = 0; i < pixel_count; i++) {
            int n = orig[i]*4;
            p[0] = palette[n];
            p[1] = palette[n+1];
            p[2] = palette[n+2];
            p += 3;
        }
    } else {
        for (int i = 0; i < pixel_count; i++) {
            int n = orig[i] * 4;
            p[0] = palette[n];
            p[1] = palette[n+1];
            p[2] = palette[n+2];
            p[3] = palette[n+3];
            p += 4;
        }
    }
    free(png->out);
    png->out = temp_out;
    return YES;
}

static BOOL stbi_png_parse_buffer(STBI_PNGImage *png, int scan, int req_comp, BOOL *pIsAppleCgBI)
{
    if (!stbi_png_check_header(png)) {
        return NO;
    }
    
    if (scan == SCAN_type) {
        return YES;
    }
    
    stbi_uint8 palette[1024], pal_img_n=0;
    stbi_uint8 has_trans=0, tc[3];
    stbi_uint32 ioff=0, idata_limit=0, pal_len=0;
    int interlace=0;
    STBI_ImageContext *s = &png->image_ctx;
    BOOL isAppleCgBI = NO;
    if (pIsAppleCgBI != NULL) {
        *pIsAppleCgBI = NO;
    }
    
    while (YES) {
        STBI_PNG_Chunk c = stbi_png_get_chunk_header(s);
        switch (c.type) {
            case STBI_PNG_TYPE('C','g','B','I'): {
                isAppleCgBI = YES;
                if (pIsAppleCgBI != NULL) {
                    *pIsAppleCgBI = YES;
                }
                stbi_img_skip(s, c.length);
                break;
            }
            case STBI_PNG_TYPE('I','H','D','R'): {
                int depth, color, comp, filter;
                if (c.length != 13) {
                    stbi_set_failure_reason("Invalid IHDR length");
                    return NO;
                }
                s->img_x = stbi_img_get32(s);
                if (s->img_x > (1 << 24)) {
                    stbi_set_failure_reason("Image width is too large");
                    return NO;
                }
                s->img_y = stbi_img_get32(s);
                if (s->img_y > (1 << 24)) {
                    stbi_set_failure_reason("Image height is too large");
                    return NO;
                }
                depth = stbi_img_get8(s);
                if (depth != 8) {
                    stbi_set_failure_reason("Non 8-bit PNG is not supported");
                    return NO;
                }
                color = stbi_img_get8(s);
                if (color > 6) {
                    stbi_set_failure_reason("Invalid color type was detected (type 1)");
                    return NO;
                }
                if (color == 3) {
                    pal_img_n = 3;
                } else if (color & 1) {
                    stbi_set_failure_reason("Invalid color type was detected (type 2)");
                    return NO;
                }
                comp = stbi_img_get8(s);
                if (comp) {
                    stbi_set_failure_reason("Invalid compression method was detected");
                    return NO;
                }
                filter= stbi_img_get8(s);
                if (filter) {
                    stbi_set_failure_reason("Invalid filtering method was detected");
                    return NO;
                }
                interlace = stbi_img_get8(s);
                if (interlace > 1) {
                    stbi_set_failure_reason("Invalid interlace method was detected");
                    return NO;
                }
                if (s->img_x == 0 || s->img_y == 0) {
                    stbi_set_failure_reason("Zero image size");
                    return NO;
                }
                if (pal_img_n == 0) {
                    s->img_n = ((color & 2)? 3: 1) + ((color & 4)? 1: 0);
                    if (((1 << 30) / s->img_x / s->img_n) < s->img_y) {
                        stbi_set_failure_reason("Image size is too large to decode (non-palette)");
                        return NO;
                    }
                    if (scan == SCAN_header) {
                        return YES;
                    }
                } else {
                    // if paletted, then pal_n is our final components, and
                    // img_n is # components to decompress/filter.
                    s->img_n = 1;
                    if (((1 << 30) / s->img_x / 4) < s->img_y) {
                        stbi_set_failure_reason("Image size is too large to decode (palette)");
                        return NO;
                    }
                    // if SCAN_header, have to scan to see if we have a tRNS
                }
                break;
            }
                
            case STBI_PNG_TYPE('P','L','T','E'):  {
                if (c.length > 256*3) {
                    stbi_set_failure_reason("Invalid PLTE data");
                    return NO;
                }
                pal_len = c.length / 3;
                if (pal_len * 3 != c.length) {
                    stbi_set_failure_reason("Invalid PLTE data");
                    return NO;
                }
                for (int i = 0; i < pal_len; i++) {
                    palette[i*4+0] = stbi_img_get8u(s);
                    palette[i*4+1] = stbi_img_get8u(s);
                    palette[i*4+2] = stbi_img_get8u(s);
                    palette[i*4+3] = 255;
                }
                break;
            }
                
            case STBI_PNG_TYPE('t','R','N','S'): {
                if (png->idata != NULL) {
                    stbi_set_failure_reason("tRNS after IDAT");
                    return NO;
                }
                if (pal_img_n) {
                    if (scan == SCAN_header) {
                        s->img_n = 4;
                        return YES;
                    }
                    if (pal_len == 0) {
                        stbi_set_failure_reason("tRNS before PLTE");
                        return NO;
                    }
                    if (c.length > pal_len) {
                        stbi_set_failure_reason("Invalid tRNS length");
                        return NO;
                    }
                    pal_img_n = 4;
                    for (int i = 0; i < c.length; i++) {
                        palette[i*4+3] = stbi_img_get8u(s);
                    }
                } else {
                    if (!(s->img_n & 1)) {
                        stbi_set_failure_reason("tRNS with alpha");
                        return NO;
                    }
                    if (c.length != (stbi_uint32) s->img_n*2) {
                        stbi_set_failure_reason("Invalid tRNS length");
                        return NO;
                    }
                    has_trans = 1;
                    for (int k = 0; k < s->img_n; k++) {
                        tc[k] = (stbi_uint8) stbi_img_get16(s); // non 8-bit images will be larger
                    }
                }
                break;
            }
                
            case STBI_PNG_TYPE('I','D','A','T'): {
                if (pal_img_n && !pal_len) {
                    stbi_set_failure_reason("No PLTE");
                    return NO;
                }
                if (scan == SCAN_header) {
                    s->img_n = pal_img_n;
                    return YES;
                }
                if (ioff + c.length > idata_limit) {
                    if (idata_limit == 0) {
                        idata_limit = (c.length > 4096)? c.length: 4096;
                    }
                    while (ioff + c.length > idata_limit) {
                        idata_limit *= 2;
                    }
                    stbi_uint8 *p = (stbi_uint8 *)realloc(png->idata, idata_limit);
                    if (p == NULL) {
                        stbi_set_failure_reason("Out of memory (IDAT)");
                        return NO;
                    }
                    png->idata = p;
                }
                stbi_img_getn(s, png->idata+ioff, c.length);
                ioff += c.length;
                break;
            }
                
            case STBI_PNG_TYPE('I','E','N','D'): {
                stbi_uint32 raw_len;
                if (scan != SCAN_load) {
                    return YES;
                }
                if (png->idata == NULL) {
                    stbi_set_failure_reason("No IDAT");
                    return NO;
                }
                png->expanded = (stbi_uint8 *)stbi_zlib_decode_malloc((char *)png->idata, ioff, (int *)&raw_len, !isAppleCgBI);
                if (png->expanded == NULL) {
                    return NO; // zlib should set error
                }
                free(png->idata);
                png->idata = NULL;
                if ((req_comp == s->img_n+1 && req_comp != 3 && !pal_img_n) || has_trans) {
                    s->img_out_n = s->img_n+1;
                } else {
                    s->img_out_n = s->img_n;
                }
                if (!stbi_png_create_image(png, png->expanded, raw_len, s->img_out_n, interlace)) {
                    return NO;
                }
                if (has_trans) {
                    if (!stbi_png_compute_transparency(png, tc, s->img_out_n)) {
                        return NO;
                    }
                }
                if (pal_img_n) {
                    // pal_img_n == 3 or 4
                    s->img_n = pal_img_n; // record the actual colors we had
                    s->img_out_n = pal_img_n;
                    if (req_comp >= 3) s->img_out_n = req_comp;
                    if (!stbi_png_expand_palette(png, palette, pal_len, s->img_out_n)) {
                        return NO;
                    }
                }
                free(png->expanded);
                png->expanded = NULL;
                return YES;
            }
                
            default:
                // if critical, fail
                if ((c.type & (1 << 29)) == 0) {
                    char errorStringBuffer[128];
                    sprintf(errorStringBuffer, "%c%c%c%c chunk is not known",
                            (stbi_uint8) (c.type >> 24), (stbi_uint8) (c.type >> 16),
                            (stbi_uint8) (c.type >> 8), (stbi_uint8) (c.type >> 0));
                    stbi_set_failure_reason(errorStringBuffer);
                    return NO;
                }
                stbi_img_skip(s, c.length);
                break;
        }
        // At end of chunk, skip CRC
        stbi_img_skip(s, 4);
    }
}

static unsigned char *stbi_png_do_png(STBI_PNGImage *png, int *x, int *y, int *n, int req_comp, int rwidth, int rheight, BOOL *isAppleCgBI)
{
    unsigned char *result = NULL;
    png->expanded = NULL;
    png->idata = NULL;
    png->out = NULL;
    if (req_comp < 0 || req_comp > 4) {
        stbi_set_failure_reason("Invalid count of required components");
        return NULL;
    }
    if (stbi_png_parse_buffer(png, SCAN_load, req_comp, isAppleCgBI)) {
        result = png->out;
        png->out = NULL;
        if (req_comp > 0 && (req_comp != png->image_ctx.img_out_n || rwidth > 0 && rwidth != png->image_ctx.img_x || rheight > 0 && rheight != png->image_ctx.img_y)) {
            result = stbi_img_convert_format(result, png->image_ctx.img_out_n, req_comp, png->image_ctx.img_x, png->image_ctx.img_y, rwidth, rheight);
            png->image_ctx.img_out_n = req_comp;
            if (result == NULL) {
                return result;
            }
        }
        *x = png->image_ctx.img_x;
        *y = png->image_ctx.img_y;
        if (n != NULL) {
            *n = png->image_ctx.img_n;
        }
    }
    
    free(png->out);
    png->out = NULL;
    
    free(png->expanded);
    png->expanded = NULL;
    
    free(png->idata);
    png->idata = NULL;
    
    return result;
}

unsigned char *stbi_png_load_from_memory(stbi_uc const *buffer, int len, int *x, int *y, int *comp, int req_comp, int rwidth, int rheight, BOOL *isAppleCgBI)
{
    STBI_PNGImage png;
    stbi_img_start_mem(&png.image_ctx, buffer,len);
    return stbi_png_do_png(&png, x, y, comp, req_comp, rwidth, rheight, isAppleCgBI);
}

static BOOL stbi_png_info_from_memory(stbi_uc const *buffer, int len, int *x, int *y, int *comp)
{
    STBI_PNGImage p;
    stbi_img_start_mem(&p.image_ctx, buffer,len);
    if (stbi_png_parse_buffer(&p, SCAN_header, 0, NULL)) {
        if (x != NULL) {
            *x = p.image_ctx.img_x;
        }
        if (y != NULL) {
            *y = p.image_ctx.img_y;
        }
        if (comp != NULL) {
            *comp = p.image_ctx.img_n;
        }
        return YES;
    }
    return NO;
}


#pragma mark -
#pragma mark PNG Loader Interface

GLuint KRCreatePNGGLTextureFromImageAtPath(NSString *imagePath, KRVector2D *imageSize, KRVector2D *textureSize)
{
    GLuint textureName = GL_INVALID_VALUE;
    NSData *fileData = [[NSData alloc] initWithContentsOfFile:imagePath];
    if (!fileData || [fileData length] == 0) {
        return textureName;
    }
    int image_width, image_height, image_component_count;

    if (stbi_png_info_from_memory((const stbi_uc *)[fileData bytes], [fileData length], &image_width, &image_height, &image_component_count)) {        
        int rwidth = image_width;
        if ((rwidth != 1) && (rwidth & (rwidth - 1))) {
            int i = 1;
            while (i < rwidth) {
                i *= 2;
            }
            rwidth = i;
        }
        
        int rheight = image_height;
        if ((rheight != 1) && (rheight & (rheight - 1))) {
            int i = 1;
            while (i < rheight) {
                i *= 2;
            }
            rheight = i;
        }
        
        BOOL isAppleCgBI = NO;
        unsigned char *image_buffer = stbi_png_load_from_memory((const stbi_uc *)[fileData bytes], [fileData length],
                                                                &image_width, &image_height, &image_component_count, image_component_count,
                                                                rwidth, rheight, &isAppleCgBI);
        if (image_buffer != NULL && (!isAppleCgBI || isAppleCgBI && image_component_count == 4)) {
            // Create new texture
            if (!_KRTexture2DEnabled) {
                _KRTexture2DEnabled = true;
                glEnable(GL_TEXTURE_2D);
            }

#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
            glPixelStorei(GL_UNPACK_ROW_LENGTH, rwidth);
#endif
            glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
            glGenTextures(1, &textureName);
            
            if (textureName != GL_INVALID_VALUE && textureName != GL_INVALID_OPERATION) {
                glBindTexture(GL_TEXTURE_2D, textureName);

                GLenum sourceFormat;
                if (isAppleCgBI) {
                    sourceFormat = GL_BGRA;
                } else {
                    sourceFormat = (image_component_count == 3)? GL_RGB: GL_RGBA;
                }
                
                glTexImage2D(GL_TEXTURE_2D, 
                             0,						// Texture resolution of MIPMAP (0: No MIPMAP)
                             ((image_component_count == 3)? GL_RGB: GL_RGBA),   // Data format of the pixels inside OpenGL
                             rwidth,                // WIDTH
                             rheight,               // HEIGHT
                             0,						// BORDER
                             sourceFormat,          // Data format of the pixels on memory
                             GL_UNSIGNED_BYTE, 		// Data type of the pixels on memory
                             image_buffer           // Pixel data on memory
                             );
                
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
                
                imageSize->x = image_width;
                imageSize->y = image_height;
                
                textureSize->x = (float)imageSize->x / rwidth;
                textureSize->y = (float)imageSize->y / rheight;
            } else {
                textureName = GL_INVALID_VALUE;
            }
            
            stbi_img_free(image_buffer);
        }
    }
    [fileData release];
    return textureName;
}



