/*!
    @file   KRRandom.h
    @author numata
    @date   09/08/05
    
    Please write the description of this class.
 */

#pragma once

#include <Karakuri/Karakuri.h>


class KRRandom : KRObject {

    unsigned x, y, z, w;

public:
	KRRandom();

private:
    unsigned xor128() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;

public:
    int     nextInt();
    int     nextInt(int upper);
    float   nextFloat();
    double  nextDouble();
    
public:
    virtual std::string to_s() const;

};

extern KRRandom *KRRand;

