/*!
    @file   KRParticle2DSystem.cpp
    @author numata
    @date   09/08/07
 */

#include "KRParticle2DSystem.h"
#include "KarakuriFunctions.h"
#include "KRRandom.h"


/*!
    @method _KRParticle2D
    Constructor
 */
_KRParticle2D::_KRParticle2D(unsigned life, const KRVector2D& pos, const KRVector2D& v, const KRVector2D& gravity,
                             double angleV, const KRColor& color, double scale,
                             double deltaRed, double deltaGreen, double deltaBlue, double deltaAlpha, double deltaScale)
    : mBaseLife(life), mLife(life), mPos(pos), mV(v), mGravity(gravity), mAngleV(angleV), mColor(color), mScale(scale),
      mDeltaRed(deltaRed), mDeltaGreen(deltaGreen), mDeltaBlue(deltaBlue), mDeltaAlpha(deltaAlpha), mDeltaScale(deltaScale)
{
    mAngle = 0.0;
}

_KRParticle2D::~_KRParticle2D()
{
    // Do nothing
}

bool _KRParticle2D::step()
{
    if (mLife == 0) {  
        return false;
    }
    mAngle += mAngleV;
    mV += mGravity;
    mPos += mV;
    mLife--;  
    return true;
}

std::string _KRParticle2D::to_s() const
{
    return "<particle2>()";
}


void KRParticle2DSystem::init()
{    
    mStartPos = KRVector2D(0, 0);
    
    mColor = KRColor::White;
    
    mMinScale = 1.0;
    mMaxScale = 1.0;
    
    mMinV = KRVector2D(-8.0, -8.0);
    mMaxV = KRVector2D(8.0, 8.0);
    
    mGravity = KRVector2DZero;
    
    mMinAngleV = -0.1;
    mMaxAngleV = 0.1;
    
    mDeltaScale = -1.0;
    mDeltaRed = 0.0;
    mDeltaGreen = 0.0;
    mDeltaBlue = 0.0;
    mDeltaAlpha = -2.0;
    
    mBlendMode = KRBlendModeAlpha;
    
    mParticleCount = 256;
    mGenerateCount = 5;
    
    mLife = 60;
    
    mActiveGenCount = 0;
    for (int i = 0; i < _KRParticle2DGenMaxCount; i++) {
        mGenInfos[i].count = 0;
    }
}


#pragma mark -
#pragma mark Constructor / Destructor

/*!
    @method KRParticle2DSystem
    Constructor
 */
KRParticle2DSystem::KRParticle2DSystem(const std::string& filename)
{
    mTexture = new KRTexture2D(filename);
    
    init();
}

KRParticle2DSystem::KRParticle2DSystem(int imageTag, std::string& customPath)
{
    mTexture = new KRTexture2D(imageTag, customPath);
    
    init();
}

/*!
    @method ~KRParticleSystem
    Destructor
 */
KRParticle2DSystem::~KRParticle2DSystem()
{
    for (std::list<_KRParticle2D *>::iterator it = mParticles.begin(); it != mParticles.end(); it++) {
        delete *it;
    }
    mParticles.clear();
    
    delete mTexture;
}


#pragma mark -
#pragma mark Getter Functions

unsigned KRParticle2DSystem::getLife() const
{
    return mLife;
}

double KRParticle2DSystem::getMaxAngleV() const
{
    return mMaxAngleV;
}

double KRParticle2DSystem::getMinAngleV() const
{
    return mMinAngleV;
}

double KRParticle2DSystem::getMaxScale() const
{
    return mMaxScale;
}

double KRParticle2DSystem::getMinScale() const
{
    return mMinScale;
}

KRVector2D KRParticle2DSystem::getStartPos() const
{
    return mStartPos;
}

unsigned KRParticle2DSystem::getParticleCount() const
{
    return mParticleCount;
}

int KRParticle2DSystem::getGenerateCount() const
{
    return mGenerateCount;
}

unsigned KRParticle2DSystem::getGeneratedParticleCount() const
{
    return mParticles.size();
}

KRBlendMode KRParticle2DSystem::getBlendMode() const
{
    return mBlendMode;
}

KRColor KRParticle2DSystem::getColor() const
{
    return mColor;
}

double KRParticle2DSystem::getDeltaRed() const
{
    return mDeltaRed;
}

double KRParticle2DSystem::getDeltaGreen() const
{
    return mDeltaGreen;
}

double KRParticle2DSystem::getDeltaBlue() const
{
    return mDeltaBlue;
}

double KRParticle2DSystem::getDeltaAlpha() const
{
    return mDeltaAlpha;
}

double KRParticle2DSystem::getDeltaScale() const
{
    return mDeltaScale;
}

KRVector2D KRParticle2DSystem::getMinV() const
{
    return mMinV;
}

KRVector2D KRParticle2DSystem::getMaxV() const
{
    return mMaxV;
}

KRVector2D KRParticle2DSystem::getGravity() const
{
    return mGravity;
}


#pragma mark -
#pragma mark Setter Functions

void KRParticle2DSystem::setStartPos(const KRVector2D& pos)
{
    mStartPos = pos;
}

void KRParticle2DSystem::setColor(const KRColor& color)
{
    mColor = color;
}

void KRParticle2DSystem::setColorDelta(double red, double green, double blue, double alpha)
{
    mDeltaRed = red;
    mDeltaGreen = green;
    mDeltaBlue = blue;
    mDeltaAlpha = alpha;
}

void KRParticle2DSystem::setBlendMode(KRBlendMode blendMode)
{
    mBlendMode = blendMode;
}

void KRParticle2DSystem::setParticleCount(unsigned count)
{
    mParticleCount = count;
}

void KRParticle2DSystem::setGenerateCount(int count)
{
    mGenerateCount = count;
}

void KRParticle2DSystem::setMaxScale(double scale)
{
    mMaxScale = scale;
}

void KRParticle2DSystem::setMinScale(double scale)
{
    mMinScale = scale;
}

void KRParticle2DSystem::setScaleDelta(double value)
{
    mDeltaScale = value;
}

void KRParticle2DSystem::setLife(unsigned life)
{
    mLife = life;
}

void KRParticle2DSystem::setMaxAngleV(double angleV)
{
    mMaxAngleV = angleV;
}

void KRParticle2DSystem::setMinAngleV(double angleV)
{
    mMinAngleV = angleV;
}

void KRParticle2DSystem::setMinV(const KRVector2D& v)
{
    mMinV = v;
}

void KRParticle2DSystem::setMaxV(const KRVector2D& v)
{
    mMaxV = v;
}

void KRParticle2DSystem::setGravity(const KRVector2D& a)
{
    mGravity = a;
}

void KRParticle2DSystem::addGenerationPoint(const KRVector2D& pos)
{
    if (mActiveGenCount >= _KRParticle2DGenMaxCount) {
        return;
    }
    for (int i = 0; i < _KRParticle2DGenMaxCount; i++) {
        if (mGenInfos[i].count == 0) {
            mGenInfos[i].count = mGenerateCount;
            mGenInfos[i].centerPos = pos;
            mActiveGenCount++;
            break;
        }
    }
}

void KRParticle2DSystem::step()
{
    // Point to Point Generation
    int genCount = 0;
    int finishedCount = 0;
    for (int i = 0; i < mActiveGenCount; i++) {
        if (mGenInfos[i].count > 0) {
            unsigned createCount = KRMin(mGenerateCount, mGenInfos[i].count);
            for (int j = 0; j < createCount; j++) {
                KRVector2D theV(KRRandInt(mMaxV.x - mMinV.x) + mMinV.x, KRRandInt(mMaxV.y - mMinV.y) + mMinV.y);
                double theScale = KRRandDouble() * (mMaxScale - mMinScale) + mMinScale;
                double theAngleV = KRRandDouble() * (mMaxAngleV - mMinAngleV) + mMinAngleV;
                
                _KRParticle2D *particle = new _KRParticle2D(mLife, mGenInfos[i].centerPos, theV, mGravity, theAngleV, mColor, theScale,
                                                            mDeltaRed, mDeltaGreen, mDeltaBlue, mDeltaAlpha, mDeltaScale);
                mParticles.push_back(particle);
            }
            mGenInfos[i].count -= createCount;
            if (mGenInfos[i].count == 0) {
                finishedCount++;
            }
            genCount++;
            if (genCount >= mActiveGenCount) {
                break;
            }
        }
    }
    mActiveGenCount -= finishedCount;
    
    // Move all points 
    for (std::list<_KRParticle2D *>::iterator it = mParticles.begin(); it != mParticles.end();) {
        if ((*it)->step()) {
            it++;
        } else {
            _KRParticle2D* theParticle = *it;
            it = mParticles.erase(it);
            delete theParticle;
        }
    }    
}

void KRParticle2DSystem::draw()
{
    KRBlendMode oldBlendMode = gKRGraphicsInst->getBlendMode();

    gKRGraphicsInst->setBlendMode(mBlendMode);
    
    KRVector2D centerPos = mTexture->getCenterPos();
    for (std::list<_KRParticle2D *>::iterator it = mParticles.begin(); it != mParticles.end(); it++) {
        double ratio = (1.0 - (double)((*it)->mLife) / (*it)->mBaseLife);
        double scale = KRMax((*it)->mScale + (*it)->mDeltaScale * ratio, 0.0);

        KRColor color;
        color.r = KRMax((*it)->mColor.r + (*it)->mDeltaRed * ratio, 0.0);
        color.g = KRMax((*it)->mColor.g + (*it)->mDeltaGreen * ratio, 0.0);
        color.b = KRMax((*it)->mColor.b + (*it)->mDeltaBlue * ratio, 0.0);
        color.a = KRMax((*it)->mColor.a + (*it)->mDeltaAlpha * ratio, 0.0);
        
        mTexture->drawAtPointCenterEx((*it)->mPos, KRRect2DZero, (*it)->mAngle, centerPos, KRVector2D(scale, scale), color);
    }
    
    gKRGraphicsInst->setBlendMode(oldBlendMode);
}



