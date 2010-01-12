/*!
    @file   KRParticle2DSystem.cpp
    @author numata
    @date   09/08/07
 */

#include "KRParticle2DSystem.h"


#if KR_PARTICLE2D_USE_POINT_SPRITE
static GLenum sPointSpriteName = 0;
static GLenum sPointSpriteCoordReplaceName = 0;
#endif


/*!
    @method _KRParticle2D
    Constructor
 */
_KRParticle2D::_KRParticle2D(unsigned life, const KRVector2D& pos, const KRVector2D& v, const KRVector2D& gravity, const KRColor& color, double size,
                             double deltaRed, double deltaGreen, double deltaBlue, double deltaAlpha, double deltaSize)
    : mBaseLife(life), mLife(life), mPos(pos), mV(v), mGravity(gravity), mColor(color), mSize(size),
      mDeltaRed(deltaRed), mDeltaGreen(deltaGreen), mDeltaBlue(deltaBlue), mDeltaAlpha(deltaAlpha), mDeltaSize(deltaSize)
{
    // Do nothing
}

bool _KRParticle2D::step()
{
    if (mLife == 0) {  
        return false;
    }
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
#if KR_PARTICLE2D_USE_POINT_SPRITE
    if (sPointSpriteName == 0) {
#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
        if (_KROpenGLVersionValue > 1.4 && 0) {
            sPointSpriteName = GL_POINT_SPRITE;
            sPointSpriteCoordReplaceName = GL_COORD_REPLACE;
        } else if (KRCheckOpenGLExtensionSupported("GL_ARB_point_sprite")) {
            sPointSpriteName = GL_POINT_SPRITE_ARB;
            sPointSpriteCoordReplaceName = GL_COORD_REPLACE_ARB;
        } else {
            const char *errorFormat = "This computer does not support point sprite.";
            if (gKRLanguage == KRLanguageJapanese) {
                errorFormat = "このコンピュータはポイントスプライトをサポートしていません。";
            }
            throw KRRuntimeError(errorFormat);
        }
#endif  // #if KR_MACOSX || KR_IPHONE_MACOSX_EMU
        
#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
        sPointSpriteName = GL_POINT_SPRITE_OES;
        sPointSpriteCoordReplaceName = GL_COORD_REPLACE_OES;
#endif  // #if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
    }
#endif  // #if KR_PARTICLE2D_USE_POINT_SPRITE
    
    mStartPos = gKRScreenSize / 2;
    
    mColor = KRColor::White;
    
#if KR_PARTICLE2D_USE_POINT_SPRITE
    mSize = 64.0;
#else
    mMinSize = 1.0;
    mMaxSize = 64.0;
#endif
    
    mMinV = KRVector2D(-8.0, -8.0);
    mMaxV = KRVector2D(8.0, 8.0);
    
    mGravity = KRVector2DZero;
    
    mDeltaSize = 0.0;
    mDeltaRed = 0.0;
    mDeltaGreen = 0.0;
    mDeltaBlue = 0.0;
    mDeltaAlpha = -2.0;
    
    mBlendMode = KRBlendModeAddition;
    
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
KRParticle2DSystem::KRParticle2DSystem(const std::string& filename, bool doLoop)
    : mDoLoop(doLoop)
{
    mHasInnerTexture = true;
    mTexture = new KRTexture2D(filename);
    
    init();
}
/*!
    @method KRParticle2DSystem
    Constructor
 */
KRParticle2DSystem::KRParticle2DSystem(KRTexture2D *texture, bool doLoop)
    : mDoLoop(doLoop)
{
    mHasInnerTexture = false;
    mTexture = texture;
    
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
    
    if (mHasInnerTexture) {
        delete mTexture;
    }
}


#pragma mark -
#pragma mark Getter Functions

unsigned KRParticle2DSystem::getLife() const
{
    return mLife;
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

#if KR_PARTICLE2D_USE_POINT_SPRITE

double KRParticle2DSystem::getSize() const
{
    return mSize;
}

void KRParticle2DSystem::setSize(double size)
{
    // We limit the size to 64 pixels, because the size of point sprite is limited to 64 pixels on iPhone
    if (size < 0.0) {
        size = 0.0;
    } else if (size > 64.0) {
        size = 64.0;
    }
    mSize = size;
}

#else

double KRParticle2DSystem::getMinSize() const
{
    return mMinSize;
}

double KRParticle2DSystem::getMaxSize() const
{
    return mMaxSize;
}

void KRParticle2DSystem::setMinSize(double size)
{
    mMinSize = size;
}

void KRParticle2DSystem::setMaxSize(double size)
{
    mMaxSize = size;
}

#endif

void KRParticle2DSystem::setSizeDelta(double value)
{
    mDeltaSize = value;
}

void KRParticle2DSystem::setLife(unsigned life)
{
    mLife = life;
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
    // Continuous Generation
    if (mDoLoop) {
        if (mGenerateCount >= 0) {
            unsigned count = 0;
            while (mParticles.size() < mParticleCount) {
                KRVector2D theV(KRRandInt(mMaxV.x - mMinV.x) + mMinV.x, KRRandInt(mMaxV.y - mMinV.y) + mMinV.y);
                
    #if KR_PARTICLE2D_USE_POINT_SPRITE
                double theSize = mSize;
    #else
                double theSize = KRRandDouble() * (mMaxSize - mMinSize) + mMinSize;
    #endif
                
                _KRParticle2D *particle = new _KRParticle2D(mLife, mStartPos, theV, mGravity, mColor, theSize,
                                                          mDeltaRed, mDeltaGreen, mDeltaBlue, mDeltaAlpha, mDeltaSize);
                mParticles.push_back(particle);
                count++;
                if (count == mGenerateCount) {
                    break;
                }
            }
        }
    }
    // Point to Point Generation
    else {
        int genCount = 0;
        int finishedCount = 0;
        for (int i = 0; i < mActiveGenCount; i++) {
            if (mGenInfos[i].count > 0) {
                unsigned createCount = KRMin(mGenerateCount, mGenInfos[i].count);
                for (int j = 0; j < createCount; j++) {
                    KRVector2D theV(KRRandInt(mMaxV.x - mMinV.x) + mMinV.x, KRRandInt(mMaxV.y - mMinV.y) + mMinV.y);
#if KR_PARTICLE2D_USE_POINT_SPRITE
                    double theSize = mSize;
#else
                    double theSize = KRRandDouble() * (mMaxSize - mMinSize) + mMinSize;
#endif
                    _KRParticle2D *particle = new _KRParticle2D(mLife, mGenInfos[i].centerPos, theV, mGravity, mColor, theSize,
                                                              mDeltaRed, mDeltaGreen, mDeltaBlue, mDeltaAlpha, mDeltaSize);
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
    }
    
    // Move all points 
    for (std::list<_KRParticle2D *>::iterator it = mParticles.begin(); it != mParticles.end();) {
        if ((*it)->step()) {
            it++;
        } else {
            it = mParticles.erase(it);
        }
    }    
}

#if KR_PARTICLE2D_USE_POINT_SPRITE
void KRParticle2DSystem::draw()
{
    KRTexture2D::processBatchedTexture2DDraws();
    
    // ポイントスプライトを有効化
    glTexEnvi(sPointSpriteName, sPointSpriteCoordReplaceName, GL_TRUE);
    glEnable(sPointSpriteName);
    
    KRBlendMode oldBlendMode = gKRGraphicsInst->getBlendMode();
    
    gKRGraphicsInst->setBlendMode(mBlendMode);
    
    mTexture->set();
    
    glPointSize(mSize);  
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    
    //double constant = 0.0;
    //double linear = 0.002;
    //double quadratic = 0.00001;
    //double coefficients[] = { constant, linear, quadratic };
    //glPointParameterfv(GL_POINT_DISTANCE_ATTENUATION, coefficients);    
	//glPointParameterf(GL_POINT_FADE_THRESHOLD_SIZE, 60.0f);
	glPointParameterf(GL_POINT_SIZE_MIN, 0.0f);
	glPointParameterf(GL_POINT_SIZE_MAX, 64.0f);
    
    unsigned particleCount = mParticles.size();
    
    GLfloat data[particleCount * 6];
    GLfloat *p = data;
    
    for (std::list<KRParticle2D *>::iterator it = mParticles.begin(); it != mParticles.end(); it++) {
        double ratio = (1.0 - (double)((*it)->mLife) / (*it)->mBaseLife);
        //float ratio2 = ratio * ratio;
        *(p++) = (*it)->mPos.x;
        *(p++) = (*it)->mPos.y;
        *(p++) = KRMax((*it)->mColor.r + (*it)->mDeltaRed * ratio, 0.0);
        *(p++) = KRMax((*it)->mColor.g + (*it)->mDeltaGreen * ratio, 0.0);
        *(p++) = KRMax((*it)->mColor.b + (*it)->mDeltaBlue * ratio, 0.0);
        *(p++) = KRMax((*it)->mColor.a + (*it)->mDeltaAlpha * ratio, 0.0);
    }
    glVertexPointer(2, GL_FLOAT, 6 * sizeof(GLfloat), data);  
    glColorPointer(4, GL_FLOAT, 6 * sizeof(GLfloat), data + 2);  
    glDrawArrays(GL_POINTS, 0, particleCount);

    gKRGraphicsInst->setBlendMode(oldBlendMode);

#if __DEBUG__
    _KRTextureBatchProcessCount++;
#endif
}
#else // #if KR_PARTICLE2D_USE_POINT_SPRITE
void KRParticle2DSystem::draw()
{
    KRBlendMode oldBlendMode = gKRGraphicsInst->getBlendMode();

    gKRGraphicsInst->setBlendMode(mBlendMode);
    
    KRVector2D centerPos = mTexture->getCenterPos();
    for (std::list<_KRParticle2D *>::iterator it = mParticles.begin(); it != mParticles.end(); it++) {
        double ratio = (1.0 - (double)((*it)->mLife) / (*it)->mBaseLife);
        double size = KRMax((*it)->mSize + (*it)->mDeltaSize * ratio, 0.0);
        KRColor color;
        color.r = KRMax((*it)->mColor.r + (*it)->mDeltaRed * ratio, 0.0);
        color.g = KRMax((*it)->mColor.g + (*it)->mDeltaGreen * ratio, 0.0);
        color.b = KRMax((*it)->mColor.b + (*it)->mDeltaBlue * ratio, 0.0);
        color.a = KRMax((*it)->mColor.a + (*it)->mDeltaAlpha * ratio, 0.0);
        mTexture->drawInRectC(KRRect2D((*it)->mPos.x-size/2, (*it)->mPos.y-size/2, size, size), color);
    }
    
    gKRGraphicsInst->setBlendMode(oldBlendMode);
}
#endif  // #if KR_PARTICLE2D_USE_POINT_SPRITE

std::string KRParticle2DSystem::to_s() const
{
#if KR_PARTICLE2D_USE_POINT_SPRITE
    return KRFS("<particle2_sys>(size=%3.1f, life=%u, count=%u, generated=%u, tex=%s)", mSize, mLife, mParticleCount, mParticles.size(), mTexture->c_str());
#else
    return KRFS("<particle2_sys>(size=(%3.1f, %3.1f), life=%u, count=%u, generated=%u, tex=%s)", mMinSize, mMaxSize, mLife, mParticleCount, mParticles.size(), mTexture->c_str());
#endif
}



