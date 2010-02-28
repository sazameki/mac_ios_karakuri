/*!
    @file   KRRandom.cpp
    @author numata
    @date   09/08/05
 */

#include "KRRandom.h"

#include <ctime>
#include <unistd.h>


static unsigned sGeneratedCount = 0;


static KRRandom *sKRRandInst = new KRRandom();
KRRandom *gKRRandInst = NULL;


/*!
    @method KRRandom
    Constructor
 */
KRRandom::KRRandom()
{
    gKRRandInst = this;

    resetSeed();
}

void KRRandom::resetSeed()
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

unsigned KRRandom::getX() const
{
    return x;
}

unsigned KRRandom::getY() const
{
    return y;
}

unsigned KRRandom::getZ() const
{
    return z;
}

unsigned KRRandom::getW() const
{
    return w;
}

void KRRandom::setXYZW(unsigned _x, unsigned _y, unsigned _z, unsigned _w)
{
    x = _x;
    y = _y;
    z = _z;
    w = _w;
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

int KRRandInt()
{
    return sKRRandInst->nextInt();
}

int KRRandInt(int upper)
{
    return sKRRandInst->nextInt(upper);
}

/*
float KRRandFloat()
{
    return sKRRandInst->nextFloat();
}
*/

double KRRandDouble()
{
    return sKRRandInst->nextDouble();
}


