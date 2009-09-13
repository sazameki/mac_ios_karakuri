/*!
    @file   KRRandom.h
    @author numata
    @date   09/08/05
    
    Please write the description of this class.
 */

#pragma once

#include <Karakuri/Karakuri.h>


/*!
    @class  KRRandom
    @group  Game Foundation
    @abstract 乱数を生成するクラスです。
 */
class KRRandom : KRObject {

    unsigned x, y, z, w;

public:
	KRRandom();

private:
    unsigned xor128() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;

public:
    /*!
        @method nextInt
     */
    int     nextInt();

    /*!
        @method nextInt
     */
    int     nextInt(int upper);

    /*!
        @method nextFloat
     */
    float   nextFloat();

    /*!
        @method nextDouble
     */
    double  nextDouble();
    
public:
    virtual std::string to_s() const;

};


/*!
    @var    KRRand
    @group  Game Foundation
 */
extern KRRandom *KRRand;

