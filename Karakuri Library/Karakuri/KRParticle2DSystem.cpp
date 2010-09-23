/*!
    @file   KRParticle2DSystem.cpp
    @author numata
    @date   09/08/07
 */

#include "KRParticle2DSystem.h"
#include "KRChara2D.h"


/*!
    @method _KRParticle2D
    Constructor
 */
_KRParticle2D::_KRParticle2D(int charaSpecID, unsigned life, const KRVector2D& pos, const KRVector2D& v, const KRVector2D& gravity,
                             double angleV, const KRColor& color, double size, double scale,
                             double deltaRed, double deltaGreen, double deltaBlue, double deltaAlpha, double deltaSize, double deltaScale)
    : KRChara2D(charaSpecID, 1000000), mBaseLife(life), mLife(life), mV(v), mGravity(gravity), mAngleV(angleV), mColor(color), mSize(size), mScale(scale),
      mDeltaRed(deltaRed), mDeltaGreen(deltaGreen), mDeltaBlue(deltaBlue), mDeltaAlpha(deltaAlpha), mDeltaSize(deltaSize), mDeltaScale(deltaScale)
{
    mAngle = 0.0;
    setCenterPos(pos);
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
    
    KRVector2D pos = getPos();
    pos += mV;
    setPos(pos);

    this->_angle = mAngle;

    double ratio = 1.0 - (double)mLife / mBaseLife;

    double scale = KRMax(mScale + mDeltaScale * ratio, 0.0);
    setScale(KRVector2D(scale, scale));

    double r = KRMax(mColor.r + mDeltaRed * ratio, 0.0);
    double g = KRMax(mColor.g + mDeltaGreen * ratio, 0.0);
    double b = KRMax(mColor.b + mDeltaBlue * ratio, 0.0);
    double a = KRMax(mColor.a + mDeltaAlpha * ratio, 0.0);
    setColor(KRColor(r, g, b, a));

    mLife--;  
    return true;
}

std::string _KRParticle2D::to_s() const
{
    return "<particle2>()";
}


void _KRParticle2DSystem::init()
{    
    mStartPos = gKRScreenSize / 2;
    
    mColor = KRColor::White;
    
    mMinSize = 1.0;
    mMaxSize = 64.0;

    mMinScale = 1.0;
    mMaxScale = 1.0;
    
    mMinV = KRVector2D(-8.0, -8.0);
    mMaxV = KRVector2D(8.0, 8.0);
    
    mGravity = KRVector2DZero;
    
    mMinAngleV = -0.1;
    mMaxAngleV = 0.1;
    
    mDeltaScale = -1.0;
    mDeltaSize = 0.0;
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

_KRParticle2DSystem::_KRParticle2DSystem(int groupID, const std::string& imageFileName, int zOrder)
    : mGroupID(groupID), mZOrder(zOrder)
{
    mDoLoop = false;

    mCharaSpecID = gKRAnime2DMan->_addTexCharaSpec(groupID, imageFileName);
    
    init();
}

/*!
    @method _KRParticle2DSystem
    Constructor
 */
_KRParticle2DSystem::_KRParticle2DSystem(int groupID, int texID)
    : mGroupID(groupID)
{
    mZOrder = 0;
    mDoLoop = false;
    
    mCharaSpecID = gKRAnime2DMan->_addTexCharaSpecWithTextureID(groupID, texID);
    
    init();
}

/*!
    @method _KRParticle2DSystem
    Constructor
 */
_KRParticle2DSystem::_KRParticle2DSystem(const std::string& filename, bool doLoop)
    : mDoLoop(doLoop)
{
    mGroupID = -1;
    mCharaSpecID = -1;
    mHasInnerTexture = true;

#warning "<< Using a deprecated method. >>"
    mTexture = new KRTexture2D(filename);
    
    init();
}

/*!
    @method _KRParticle2DSystem
    Constructor
 */
_KRParticle2DSystem::_KRParticle2DSystem(KRTexture2D *texture, bool doLoop)
    : mDoLoop(doLoop)
{
    mGroupID = -1;
    mCharaSpecID = -1;
    mHasInnerTexture = false;
    mTexture = texture;
    
    init();
}

/*!
    @method ~_KRParticleSystem
    Destructor
 */
_KRParticle2DSystem::~_KRParticle2DSystem()
{
    for (std::list<_KRParticle2D *>::iterator it = mParticles.begin(); it != mParticles.end(); it++) {
        delete *it;
    }
    mParticles.clear();
    
    if (mHasInnerTexture) {
#warning "<< Using a deprecated method. >>"
        delete mTexture;
    }
}


#pragma mark -
#pragma mark Getter Functions

unsigned _KRParticle2DSystem::getLife() const
{
    return mLife;
}

double _KRParticle2DSystem::getMaxAngleV() const
{
    return mMaxAngleV;
}

double _KRParticle2DSystem::getMinAngleV() const
{
    return mMinAngleV;
}

double _KRParticle2DSystem::getMaxScale() const
{
    return mMaxScale;
}

double _KRParticle2DSystem::getMinScale() const
{
    return mMinScale;
}

KRVector2D _KRParticle2DSystem::getStartPos() const
{
    return mStartPos;
}

unsigned _KRParticle2DSystem::getParticleCount() const
{
    return mParticleCount;
}

int _KRParticle2DSystem::getGenerateCount() const
{
    return mGenerateCount;
}

unsigned _KRParticle2DSystem::getGeneratedParticleCount() const
{
    return mParticles.size();
}

KRBlendMode _KRParticle2DSystem::getBlendMode() const
{
    return mBlendMode;
}

KRColor _KRParticle2DSystem::getColor() const
{
    return mColor;
}

double _KRParticle2DSystem::getDeltaRed() const
{
    return mDeltaRed;
}

double _KRParticle2DSystem::getDeltaGreen() const
{
    return mDeltaGreen;
}

double _KRParticle2DSystem::getDeltaBlue() const
{
    return mDeltaBlue;
}

double _KRParticle2DSystem::getDeltaAlpha() const
{
    return mDeltaAlpha;
}

double _KRParticle2DSystem::getDeltaScale() const
{
    return mDeltaScale;
}

KRVector2D _KRParticle2DSystem::getMinV() const
{
    return mMinV;
}

KRVector2D _KRParticle2DSystem::getMaxV() const
{
    return mMaxV;
}

KRVector2D _KRParticle2DSystem::getGravity() const
{
    return mGravity;
}


#pragma mark -
#pragma mark Setter Functions

void _KRParticle2DSystem::setStartPos(const KRVector2D& pos)
{
    mStartPos = pos;
}

void _KRParticle2DSystem::setColor(const KRColor& color)
{
    mColor = color;
}

void _KRParticle2DSystem::setColorDelta(double red, double green, double blue, double alpha)
{
    mDeltaRed = red;
    mDeltaGreen = green;
    mDeltaBlue = blue;
    mDeltaAlpha = alpha;
}

void _KRParticle2DSystem::setBlendMode(KRBlendMode blendMode)
{
    mBlendMode = blendMode;
}

void _KRParticle2DSystem::setParticleCount(unsigned count)
{
    mParticleCount = count;
}

void _KRParticle2DSystem::setGenerateCount(int count)
{
    mGenerateCount = count;
}

double _KRParticle2DSystem::getMinSize() const
{
    return mMinSize;
}

double _KRParticle2DSystem::getMaxSize() const
{
    return mMaxSize;
}

void _KRParticle2DSystem::setMaxScale(double scale)
{
    mMaxScale = scale;
}

void _KRParticle2DSystem::setMinSize(double size)
{
    mMinSize = size;
}

void _KRParticle2DSystem::setMaxSize(double size)
{
    mMaxSize = size;
}

void _KRParticle2DSystem::setMinScale(double scale)
{
    mMinScale = scale;
}

void _KRParticle2DSystem::setScaleDelta(double value)
{
    mDeltaScale = value;
}

void _KRParticle2DSystem::setSizeDelta(double value)
{
    mDeltaSize = value;
}

void _KRParticle2DSystem::setLife(unsigned life)
{
    mLife = life;
}

void _KRParticle2DSystem::setMaxAngleV(double angleV)
{
    mMaxAngleV = angleV;
}

void _KRParticle2DSystem::setMinAngleV(double angleV)
{
    mMinAngleV = angleV;
}

void _KRParticle2DSystem::setMinV(const KRVector2D& v)
{
    mMinV = v;
}

void _KRParticle2DSystem::setMaxV(const KRVector2D& v)
{
    mMaxV = v;
}

void _KRParticle2DSystem::setGravity(const KRVector2D& a)
{
    mGravity = a;
}

void _KRParticle2DSystem::addGenerationPoint(const KRVector2D& pos, int zOrder)
{
    if (mActiveGenCount >= _KRParticle2DGenMaxCount) {
        return;
    }
    for (int i = 0; i < _KRParticle2DGenMaxCount; i++) {
        if (mGenInfos[i].count == 0) {
            mGenInfos[i].count = mGenerateCount;
            mGenInfos[i].centerPos = pos;
            mGenInfos[i].zOrder = zOrder;
            mActiveGenCount++;
            break;
        }
    }
}

void _KRParticle2DSystem::step()
{
    // パーティクルの生成
    int genCount = 0;
    int finishedCount = 0;
    for (int i = 0; i < mActiveGenCount; i++) {
        if (mGenInfos[i].count > 0) {
            unsigned createCount = KRMin(mGenerateCount, mGenInfos[i].count);
            for (int j = 0; j < createCount; j++) {
                double dx = mMaxV.x - mMinV.x;
                double dy = mMaxV.x - mMinV.x;
                KRVector2D theV;
                if (dx != 0.0) {
                    theV.x = KRRandInt(dx) + mMinV.x;
                }
                if (dy != 0.0) {
                    theV.y = KRRandInt(dy) + mMinV.y;
                }
                double theSize = KRRandDouble() * (mMaxSize - mMinSize) + mMinSize;
                double theScale = KRRandDouble() * (mMaxScale - mMinScale) + mMinScale;
                double theAngleV = KRRandDouble() * (mMaxAngleV - mMinAngleV) + mMinAngleV;

                _KRParticle2D *particle = new _KRParticle2D(mCharaSpecID, mLife, mGenInfos[i].centerPos, theV, mGravity, theAngleV, mColor, theSize, theScale,
                                                            mDeltaRed, mDeltaGreen, mDeltaBlue, mDeltaAlpha, mDeltaSize, mDeltaScale);
                particle->setZOrder(mGenInfos[i].zOrder);
                particle->setBlendMode(mBlendMode);
                mParticles.push_back(particle);
                gKRAnime2DMan->addChara2D(particle);
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
    
    // 各パーティクルの移動
    for (std::list<_KRParticle2D *>::iterator it = mParticles.begin(); it != mParticles.end();) {
        if ((*it)->step()) {
            it++;
        } else {
            _KRParticle2D* theParticle = *it;
            it = mParticles.erase(it);
            gKRAnime2DMan->removeChara2D(theParticle);
        }
    }    
}

std::string _KRParticle2DSystem::to_s() const
{
    if (mCharaSpecID >= 0) {
        return KRFS("<particle2_sys>(size=(%3.1f, %3.1f), life=%u, count=%u, generated=%u, charaspec=%d)", mMinSize, mMaxSize, mLife, mParticleCount, mParticles.size(), mCharaSpecID);
    }
    return KRFS("<particle2_sys>(size=(%3.1f, %3.1f), life=%u, count=%u, generated=%u, tex=%s)", mMinSize, mMaxSize, mLife, mParticleCount, mParticles.size(), mTexture->c_str());
}



