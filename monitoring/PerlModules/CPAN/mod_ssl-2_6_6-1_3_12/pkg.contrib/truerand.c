/*
 *    Physically random numbers (very nearly uniform)
 *      D. P. Mitchell 
 *      Modified by Matt Blaze 2/95
 *      Assembled and reformatted by Ralf S. Engelschall for mod_ssl
 */

/*
 * The authors of this software are Don Mitchell and Matt Blaze.
 *              Copyright (c) 1995 by AT&T.
 * Permission to use, copy, and modify this software without fee
 * is hereby granted, provided that this entire notice is included in
 * all copies of any software which is or includes a copy or
 * modification of this software and in all copies of the supporting
 * documentation for such software.
 *
 * This software may be subject to United States export controls.
 *
 * THIS SOFTWARE IS BEING PROVIDED "AS IS", WITHOUT ANY EXPRESS OR IMPLIED
 * WARRANTY.  IN PARTICULAR, NEITHER THE AUTHORS NOR AT&T MAKE ANY
 * REPRESENTATION OR WARRANTY OF ANY KIND CONCERNING THE MERCHANTABILITY
 * OF THIS SOFTWARE OR ITS FITNESS FOR ANY PARTICULAR PURPOSE.
 */

/*
 * WARNING: depending on the particular platform, truerand() output may
 * be biased or correlated.  In general, you can expect about 16 bits of
 * "pseudo-entropy" out of each 32 bit word returned by truerand(),
 * but it may not be uniformly diffused.  You should therefore run
 * the output through some post-whitening function (like MD5 or DES or
 * whatever) before using it to generate key material.  (RSAREF's
 * random package does this for you when you feed truerand() bits to the
 * seed input function.)
 *
 * Test these assumptions on your own platform before fielding a system
 * based on this software or these techniques.
 *
 * This software seems to work well (at 16 bits per truerand() call) on
 * a Sun Sparc-20 under SunOS 4.1.3 and on a P100 under BSDI 2.0.  You're
 * on your own elsewhere.
 */

#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <setjmp.h>
#include <math.h>
#include <sys/time.h>

static jmp_buf env;
static volatile unsigned int count;
static volatile unsigned int ocount;
static volatile unsigned int buffer;

static void tick(void)
{
    struct itimerval it, oit;

    timerclear(&it.it_interval);
    it.it_value.tv_sec = 0;
    it.it_value.tv_usec = 16665;
    if (setitimer(ITIMER_REAL, &it, &oit) < 0)
        perror("tick");
}

static void interrupt(int s)
{
    if (count)
        longjmp(env, 1);
    (void) signal(SIGALRM, interrupt);
    tick();
}

static unsigned long roulette(void)
{
    if (setjmp(env)) {
        count ^= (count >> 3) ^ (count >> 6) ^ ocount;
        count &= 0x7;
        ocount = count;
        buffer = (buffer << 3) ^ count;
        return buffer;
    }
    (void) signal(SIGALRM, interrupt);
    count = 0;
    tick();
    for (;;)
        count++; /* about 1 MHz on VAX 11/780 */
}

unsigned long truerand(void)
{
    count = 0;
    (void) roulette();
    (void) roulette();
    (void) roulette();
    (void) roulette();
    (void) roulette();
    (void) roulette();
    (void) roulette();
    (void) roulette();
    (void) roulette();
    (void) roulette();
    return roulette();
}

int n_truerand(int n)
{
    int slop, v;

    slop = 0x7FFFFFFF % n;
    do {
        v = truerand() >> 1;
    } while (v <= slop);
    return v % n;
}

/*
 * Secure Hash Standard
 * proposed NIST SHS
 * coded for byte strings: number of bits is a multiple of 8
 *
 * Copyright (c) 1992, 1994 AT&T Bell Laboratories
 * Coded by Jim Reeds 5 Feb 1992
 * Enhanced by Jack Lacy 1993, 1994
 */

/*
 * unsigned char * shs(char *s, int n);
 *
 * input:  
 *                s character array to be hashed
 *                n length of s in BYTES
 * output:
 *                return value: address of 5 unsigned longs holding hash
 *
 * machine dependencies:
 *                assumes a char is 8 bits
 */

/*
 * passes test on:
 *                gauss (vax)
 *                3k (cray)
 *                slepian (MIPS)
 *                bird (sparcstation II)
 */

#include <sys/types.h>
#include <string.h>
#include <stdio.h>

typedef struct {
    long totalLength;
    unsigned long h[5];
    unsigned long w[80];
} SHS_CTX;

unsigned char *shs();
static long nbits;
static unsigned long *h;
static unsigned long *w;
static void shs1();

#define MASK (unsigned long)0xffffffffL  /* in case more than 32 bits per long */

/*
 * stick one byte into the current block; process the block when full
 */
static void opack(unsigned char c)
{
    int n32, nd32, shiftbits;
    register unsigned long x, mask, y;

    nd32 = (int) (nbits >> 5);  /* nbits/32 */
    n32 = (int) (nbits & 0x1f); /* nbits%32 */
    shiftbits = 24 - n32;

    x = (unsigned long) (c << shiftbits);
    mask = (unsigned long) (0xff << shiftbits);
    mask = ~mask;

    y = w[nd32];
    y = (y & mask) + x;
    w[nd32] = y;

    nbits += 8;
    if (nbits == 512) {
        nbits = 0;
        shs1();
    }
}

static void pack(unsigned char c0, unsigned char c1, unsigned char c2, unsigned char c3)
{
    int nd32;

    nd32 = (int) (nbits >> 5);
    w[nd32] = (u_long) (((u_long) c0 << 24) | ((u_long) c1 << 16) | ((u_long) c2 << 8) |
                        (u_long) c3);
    nbits += 32;
    if (nbits == 512) {
        nbits = 0;
        shs1();
    }
}

/*
 * stick a 4 byte number into the current block
 */
static void packl(unsigned long x)
{
    pack((unsigned char) (x >> 24), (unsigned char) (x >> 16),
         (unsigned char) (x >> 8), (unsigned char) (x >> 0));
}

/*
 * process one block
 */
static void shs1(void)
{
    unsigned long *wp;
    unsigned long temp;
    unsigned long A, B, C, D, E;
    int t;

#define S(n,x) (u_long)(((x)<<(n))|((MASK&(x))>>(32-(n))))

    wp = w;
    t = 8;
    do {
        wp[16] = S(1, (u_long) (wp[13] ^ wp[8] ^ wp[2] ^ wp[0]));
        wp[17] = S(1, (u_long) (wp[14] ^ wp[9] ^ wp[3] ^ wp[1]));
        wp[18] = S(1, (u_long) (wp[15] ^ wp[10] ^ wp[4] ^ wp[2]));
        wp[19] = S(1, (u_long) (wp[16] ^ wp[11] ^ wp[5] ^ wp[3]));
        wp[20] = S(1, (u_long) (wp[17] ^ wp[12] ^ wp[6] ^ wp[4]));
        wp[21] = S(1, (u_long) (wp[18] ^ wp[13] ^ wp[7] ^ wp[5]));
        wp[22] = S(1, (u_long) (wp[19] ^ wp[14] ^ wp[8] ^ wp[6]));
        wp[23] = S(1, (u_long) (wp[20] ^ wp[15] ^ wp[9] ^ wp[7]));
        wp += 8;
        t--;
    } while (t > 0);

    A = h[0];
    B = h[1];
    C = h[2];
    D = h[3];
    E = h[4];

    t = 0;
    while (t < 20) {
        temp = S(5, A) + E + w[t++];
        temp += (unsigned long) 0x5a827999L + ((B & C) | (D & ~B));
        E = D;
        D = C;
        C = S(30, B);
        B = A;
        A = temp;
    }
    while (t < 40) {
        temp = S(5, A) + E + w[t++];
        temp += (unsigned long) 0x6ed9eba1L + (B ^ C ^ D);
        E = D;
        D = C;
        C = S(30, B);
        B = A;
        A = temp;
    }
    while (t < 60) {
        temp = S(5, A) + E + w[t++];
        temp += (unsigned long) 0x8f1bbcdcL + ((B & C) | (B & D) | (C & D));
        E = D;
        D = C;
        C = S(30, B);
        B = A;
        A = temp;
    }
    while (t < 80) {
        temp = S(5, A) + E + w[t++];
        temp += (unsigned long) 0xca62c1d6L + (B ^ C ^ D);
        E = D;
        D = C;
        C = S(30, B);
        B = A;
        A = temp;
    }
    h[0] = MASK & (h[0] + A);
    h[1] = MASK & (h[1] + B);
    h[2] = MASK & (h[2] + C);
    h[3] = MASK & (h[3] + D);
    h[4] = MASK & (h[4] + E);
}

#define CHARSTOLONG(wp,s,i) \
        {*wp++ = \
          (u_long)((((u_long)(s[i])&0xff)<<24)| \
         (((u_long)(s[i+1])&0xff)<<16)| \
         (((u_long)(s[i+2])&0xff)<<8)| \
         (u_long)(s[i+3]&0xff));}

void shsInit(SHS_CTX *mdContext)
{
    nbits = 0;
    mdContext->h[0] = (unsigned long) 0x67452301L;
    mdContext->h[1] = (unsigned long) 0xefcdab89L;
    mdContext->h[2] = (unsigned long) 0x98badcfeL;
    mdContext->h[3] = (unsigned long) 0x10325476L;
    mdContext->h[4] = (unsigned long) 0xc3d2e1f0L;
    mdContext->totalLength = 0;
}

void shsUpdate(SHS_CTX *mdContext, unsigned char *s, unsigned int n)
{
    register unsigned long *wp;
    long nn = n;
    long i;

    w = mdContext->w;
    h = mdContext->h;
    mdContext->totalLength += n;

    nbits = 0;
    n = n / (u_long) 64;
    wp = w;

    while (n > 0) {
        CHARSTOLONG(wp, s, 0);
        CHARSTOLONG(wp, s, 4);
        CHARSTOLONG(wp, s, 8);
        CHARSTOLONG(wp, s, 12);
        CHARSTOLONG(wp, s, 16);
        CHARSTOLONG(wp, s, 20);
        CHARSTOLONG(wp, s, 24);
        CHARSTOLONG(wp, s, 28);
        CHARSTOLONG(wp, s, 32);
        CHARSTOLONG(wp, s, 36);
        CHARSTOLONG(wp, s, 40);
        CHARSTOLONG(wp, s, 44);
        CHARSTOLONG(wp, s, 48);
        CHARSTOLONG(wp, s, 52);
        CHARSTOLONG(wp, s, 56);
        CHARSTOLONG(wp, s, 60);
        n--;
        wp = w;
        s = (s + 64);
        shs1();
    }
    i = nn % 64;
    while (i > 3) {
        CHARSTOLONG(wp, s, 0);
        s = (s + 4);
        nbits += (u_long) 32;
        i -= 4;
    }
    while (i) {
        opack((unsigned char) *s++);
        i--;
    }
}

void shsFinal(SHS_CTX *mdContext)
{
    long nn = mdContext->totalLength;
    w = mdContext->w;
    h = mdContext->h;

    opack(128);
    while (nbits != 448)
        opack(0);
    packl((unsigned long) (nn >> 29));
    packl((unsigned long) (nn << 3));

    /* if(nbits != 0)
       handle_exception(CRITICAL,"shsFinal(): nbits != 0\n"); */
}

unsigned char *shs(unsigned char *s, long n)
{
    SHS_CTX *mdContext;
    static SHS_CTX mdC;
    static unsigned char ret[20];
    int i;

    mdContext = &mdC;

    shsInit(mdContext);
    shsUpdate(mdContext, s, n);
    shsFinal(mdContext);
    for (i = 0; i < 5; i++) {
        ret[i * 4] = (mdContext->h[i] >> 24) & 0xff;
        ret[i * 4 + 1] = (mdContext->h[i] >> 16) & 0xff;
        ret[i * 4 + 2] = (mdContext->h[i] >> 8) & 0xff;
        ret[i * 4 + 3] = (mdContext->h[i]) & 0xff;
    }

    return ret;
}

unsigned long *fShsDigest(FILE *in)
{
    SHS_CTX *mdContext;
    SHS_CTX mdC;
    unsigned char buffer[1024];
    long length, total;

    mdContext = &mdC;

    memset(buffer, 0, 1024);

    total = 0;
    shsInit(mdContext);
    while ((length = fread(buffer, 1, 1024, in)) != 0) {
        total += length;
        shsUpdate(mdContext, buffer, length);
    }
    shsFinal(mdContext);

    return mdContext->h;
}

/*
 *    Random byte interface to truerand()
 *      Matt Blaze 5/95
 *      eight really random bits
 *      usage: 
 *              unsigned char r; int randbyte();
 *              r=randbyte();
 *      randbyte() takes about .3 seconds on most machines.
 */

int randbyte(void)
{
    unsigned long truerand();
    unsigned char *shs();
    unsigned long r[2];
    unsigned char *hash;

    r[0] = truerand();
    r[1] = truerand();
    hash = shs((unsigned char *)r, (long)sizeof(r));
#ifdef DEBUGRND
    printf("%011o %011o %02x\n", r[0], r[1], *hash & 0xff);
#endif
    return ((int) (*hash)) & 0xff;
}

/*
 * Main program
 */

/* SIGPIPE causes normal exit */
static void handler(int sig)
{
    exit(0);
}

int main(int argc, char **argv)
{
    int count;

    signal(SIGPIPE, handler);
    if (argc == 1)
        count = 0;
    else
        count = atoi(argv[1]) + 1;
    setbuf(stdout, NULL);
    while (--count)
        fprintf(stdout, "%c", randbyte());
    return 0;
}

