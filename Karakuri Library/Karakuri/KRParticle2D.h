/*!
 @file   KRParticle2D.h
 @author numata
 @date   09/08/07
 
 Please write the description of this class.
 */

#pragma once

#include <Karakuri/Karakuri.h>


#define KR_PARTICLE2D_USE_POINT_SPRITE  0


struct KRParticle2DGenInfo {
    
    KRVector2D  centerPos;
    int         count;
    
};


const int KRParticle2DGenMaxCount = 20;


class KRParticle2D : public KRObject {
    
public:
    unsigned    mLife;
    unsigned    mBaseLife;
    KRVector2D  mPos;
    KRVector2D  mV;
    KRVector2D  mGravity;
    KRColor     mColor;
    float       mSize;
    
    float       mDeltaSize;
    float       mDeltaRed;
    float       mDeltaGreen;
    float       mDeltaBlue;
    float       mDeltaAlpha;
    
public:
	KRParticle2D(unsigned life, const KRVector2D& pos, const KRVector2D& v, const KRVector2D& gravity, const KRColor& color, float size,
                 float deltaRed, float deltaGreen, float deltaBlue, float deltaAlpha, float deltaSize);
    
public:
    bool    step();
    
public:
    virtual std::string to_s() const;

};

/*!
    @class  KRParticle2DSystem
    @group  Game 2D Graphics
 */
class KRParticle2DSystem : KRObject {
    
    std::list<KRParticle2D *>   mParticles;

    unsigned        mLife;
    KRVector2D      mStartPos;
    
    KRTexture2D     *mTexture;
    bool            mHasInnerTexture;
    
    KRVector2D      mMinV;
    KRVector2D      mMaxV;
    KRVector2D      mGravity;
    
    unsigned        mParticleCount;
    int             mGenerateCount;
    
    KRBlendMode     mBlendMode;
    
    KRColor         mColor;
    float           mDeltaSize;
    float           mDeltaRed;
    float           mDeltaGreen;
    float           mDeltaBlue;
    float           mDeltaAlpha;
    
    bool            mDoLoop;
    KRParticle2DGenInfo mGenInfos[KRParticle2DGenMaxCount];
    int             mActiveGenCount;
    
#if KR_PARTICLE2D_USE_POINT_SPRITE
    float           mSize;
#else
    float           mMinSize;
    float           mMaxSize;
#endif
    
public:
    KRParticle2DSystem(const std::string& filename, bool doLoop=true);
    KRParticle2DSystem(KRTexture2D *texture, bool doLoop=true);
    virtual ~KRParticle2DSystem();
    
private:
    void    init();
    
public:
    KRBlendMode getBlendMode() const;
    KRColor     getColor() const;
    float       getDeltaRed() const;
    float       getDeltaGreen() const;
    float       getDeltaBlue() const;
    float       getDeltaAlpha() const;
    float       getDeltaSize() const;
    int         getGenerateCount() const;
    unsigned    getGeneratedParticleCount() const;
    KRVector2D  getGravity() const;
    unsigned    getLife() const;
    KRVector2D  getMaxV() const;
    KRVector2D  getMinV() const;
    unsigned    getParticleCount() const;
    KRVector2D  getStartPos() const;

public:
    void    setBlendMode(KRBlendMode blendMode);
    void    setColor(const KRColor& color);
    void    setColorDelta(float red, float green, float blue, float alpha);
    void    setGenerateCount(int count);
    void    setGravity(const KRVector2D& a);
    void    setLife(unsigned life);
    void    setMaxV(const KRVector2D& v);
    void    setMinV(const KRVector2D& v);
    void    setParticleCount(unsigned count);
    void    setSizeDelta(float value);
    
public:
    void    setStartPos(const KRVector2D& pos);
    
public:
    void    addGenerationPoint(const KRVector2D& pos);
    
public:
#if KR_PARTICLE2D_USE_POINT_SPRITE
    float   getSize() const;
    void    setSize(float size);
#else
    float   getMinSize() const;
    float   getMaxSize() const;
    void    setMinSize(float size);
    void    setMaxSize(float size);
#endif
    
public:
    void    step();
    void    draw();
    
public:
    virtual std::string to_s() const;

};


