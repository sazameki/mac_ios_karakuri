/*!
    @file   KRRandom.cpp
    @author numata
    @date   09/08/05
 */

#include "KRRandom.h"

#include <ctime>
#include <unistd.h>


static unsigned sGeneratedCount = 0;


KRRandom *KRRand = new KRRandom();


/*!
    @method KRRandom
    Constructor
 */
KRRandom::KRRandom()
{
    unsigned the_time = (unsigned)(time(NULL));
    unsigned pid = (unsigned)getpid();
    unsigned seed = the_time * pid;
    
    seed = 1812433253U * (seed ^ (seed >> 30)) + 1;
    x = seed;
    seed = 1812433253U * (seed ^ (seed >> 30)) + 2;
    y = seed;
    seed = 1812433253U * (seed ^ (seed >> 30)) + 3;
    z = seed;
    seed = 1812433253U * (seed ^ (seed >> 30)) + 4;
    w = seed;
}

unsigned KRRandom::xor128()
{
    sGeneratedCount++;

    unsigned t = (x ^ (x << 11));
    x = y;
    y = z;
    z = w;
    return (w = (w ^ (w >> 19)) ^ (t ^ (t >> 8)));
}

int KRRandom::nextInt()
{
    return (int)xor128();
}

int KRRandom::nextInt(int upper)
{
    return (int)(xor128() % upper);
}

float KRRandom::nextFloat()
{
    return ((float)xor128() / 0xffffffff);
}

double KRRandom::nextDouble()
{
    return ((double)xor128() / 0xffffffff);
}

std::string KRRandom::to_s() const
{
    return KRFS("<rand>(generated=%u)", sGeneratedCount);
}


