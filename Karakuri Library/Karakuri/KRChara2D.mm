/*
 *  KRChara2D.cpp
 *  Karakuri Library
 *
 *  Created by numata on 10/07/09.
 *  Copyright 2010 Satoshi Numata. All rights reserved.
 *
 */

#include "KRChara2D.h"
#include <Karakuri/Karakuri.h>


#pragma mark -
#pragma mark _KRChara2DHitArea の実装

bool _KRChara2DHitArea::hitTest(const KRVector2D& offset, const KRVector2D& scale, const KRVector2D& pos) const
{
    KRRect2D theRect = rect;
    theRect.x *= scale.x;
    theRect.y *= scale.y;
    theRect.x += offset.x;
    theRect.y += offset.y;
    theRect.width *= scale.x;
    theRect.height *= scale.y;
    if (theRect.contains(pos)) {
        // TODO: 円形の当たり判定領域への正式対応
        return true;
    }
    return false;
}

bool _KRChara2DHitArea::hitTest(const KRVector2D& offset, const KRVector2D& scale, int count, _KRChara2DHitArea* hitAreas, int targetHitType, const KRVector2D& targetOffset, const KRVector2D& targetScale) const
{
    KRRect2D theRect = rect;
    theRect.x *= scale.x;
    theRect.y *= scale.y;
    theRect.x += offset.x;
    theRect.y += offset.y;
    theRect.width *= scale.x;
    theRect.height *= scale.y;
    
    for (int i = 0; i < count; i++) {
        if (hitAreas[i].group != targetHitType) {
            continue;
        }
        KRRect2D targetRect = hitAreas[i].rect;
        targetRect.x *= targetScale.x;
        targetRect.y *= targetScale.y;
        targetRect.x += targetOffset.x;
        targetRect.y += targetOffset.y;
        targetRect.width *= targetScale.x;
        targetRect.height *= targetScale.y;
        if (targetRect.intersects(theRect)) {
            // TODO: 円形の当たり判定領域への正式対応
            return true;
        }
    }
    return false;
}


#pragma mark -
#pragma mark _KRChara2DKoma の実装

_KRChara2DKoma::_KRChara2DKoma()
{
    mAtlasIndex = -1;
    mAtlasPos = KRVector2DInt(-1, -1);
    
    mHitAreaCount = 0;
    mHitAreas = NULL;
}

_KRChara2DKoma::~_KRChara2DKoma()
{
    if (mHitAreas != NULL) {
        delete[] mHitAreas;
    }
}

void _KRChara2DKoma::initForManualChara2D(int textureID, KRVector2DInt atlasPos, int interval, bool isCancelable, int gotoTarget)
{
    mTextureID = textureID;
    
    mAtlasPos = atlasPos;
    mIsCancelable = isCancelable;
    mInterval = interval;
    mGotoTarget = gotoTarget;    
}

void _KRChara2DKoma::initForBoxChara2D(const std::string& imageTicket, int atlasIndex, int interval, bool isCancelable, int gotoTarget)
{
    mTextureID = gKRTex2DMan->_getTextureIDForTicket(imageTicket);
    
    mAtlasIndex = atlasIndex;
    mIsCancelable = isCancelable;
    mInterval = interval;
    mGotoTarget = gotoTarget;
}

KRVector2DInt _KRChara2DKoma::getAtlasPos()
{
    if (mAtlasPos.x >= 0) {
        return mAtlasPos;
    }
    
    _KRTexture2D* theTex = gKRTex2DMan->_getTexture(mTextureID);
    
    int divX = theTex->getDivX();
    
    return KRVector2DInt(mAtlasIndex % divX, mAtlasIndex / divX);
}

KRVector2D _KRChara2DKoma::getAtlasSize()
{
    _KRTexture2D* theTex = gKRTex2DMan->_getTexture(mTextureID);
    return theTex->getAtlasSize();
}

int _KRChara2DKoma::getGotoTarget()
{
    return mGotoTarget;
}

int _KRChara2DKoma::getInterval()
{
    return mInterval;
}

int _KRChara2DKoma::getTextureID()
{
    return mTextureID;
}

void _KRChara2DKoma::_importHitArea(void* hitInfo)
{
    NSArray* hitInfos = (NSArray*)hitInfo;
    
    mHitAreaCount = [hitInfos count];
    if (mHitAreaCount == 0) {
        return;
    }
    
    mHitAreas = new _KRChara2DHitArea[mHitAreaCount];

    for (unsigned i = 0; i < mHitAreaCount; i++) {
        NSDictionary* anInfo = [hitInfos objectAtIndex:i];
        int hitType = [[anInfo objectForKey:@"Hit Type"] intValue];
        int groupIndex = [[anInfo objectForKey:@"Group Index"] intValue];
        int x = (int)([[anInfo objectForKey:@"Rect X"] doubleValue] + 0.5);
        int y = (int)([[anInfo objectForKey:@"Rect Y"] doubleValue] + 0.5);
        int width = (int)([[anInfo objectForKey:@"Rect Width"] doubleValue] + 0.5);
        int height = (int)([[anInfo objectForKey:@"Rect Height"] doubleValue] + 0.5);
        mHitAreas[i].type = (hitType == 0)? _KRChara2DHitAreaTypeRect: _KRChara2DHitAreaTypeOval;
        mHitAreas[i].group = groupIndex;
        mHitAreas[i].rect = KRRect2D(x, y, width, height);
    }
}

int _KRChara2DKoma::_getHitAreaCount() const
{
    return mHitAreaCount;
}

_KRChara2DHitArea* _KRChara2DKoma::_getHitAreas() const
{
    return mHitAreas;
}



#pragma mark -
#pragma mark _KRChara2DMotion の実装

_KRChara2DMotion::_KRChara2DMotion()
{
    // Do nothing
}

void _KRChara2DMotion::initForManualChara2D(int cancelKomaNumber, int nextMotionID)
{
    mCancelKomaNumber = cancelKomaNumber;
    mNextMotionID = nextMotionID;
}

void _KRChara2DMotion::initForBoxChara2D(int cancelKomaNumber, int nextMotionID)
{
    mCancelKomaNumber = cancelKomaNumber;
    mNextMotionID = nextMotionID;
}

void _KRChara2DMotion::addKoma(_KRChara2DKoma* aKoma)
{
    mKomas.push_back(aKoma);
}

int _KRChara2DMotion::getKomaCount()
{
    return mKomas.size();
}

_KRChara2DKoma* _KRChara2DMotion::getKoma(int komaNumber)
{
    return mKomas[komaNumber-1];
}



#pragma mark -
#pragma mark KRChara2DSpec の実装

/*KRChara2DSpec::KRChara2DSpec(int texGroupID, const std::string& textureName, const KRVector2D& atlasSize)
 {
 mSpecID = -1;
 mTextureID = gKRTex2DMan->addTexture(texGroupID, textureName, atlasSize);
 }
 
 KRChara2DSpec::KRChara2DSpec(int texGroupID, const std::string& ticket)
 {
 mSpecID = -1;
 mTextureID = gKRTex2DMan->getTextureIDForTicket(ticket);
 }*/

_KRChara2DSpec::_KRChara2DSpec(int texGroupID, const std::string& specName)
{
    mGroupID = texGroupID;
    mSpecName = specName;
    mSpecID = -1;
    mParticleTexID = -1;
}

_KRChara2DSpec::~_KRChara2DSpec()
{
    std::map<int, _KRChara2DMotion*>::iterator it = mMotionMap.begin();
	while (it != mMotionMap.end()) {
        delete (*it).second;
		it++;
	}
}

void _KRChara2DSpec::initForManualChara2D()
{
    // Do nothing
}

void _KRChara2DSpec::initForManualParticle2D(const std::string& fileName)
{
    printf("KRChara2DSpec::initForManualParticle2D(const std::string&) should be implemented!!\n");
    //mParticleTexID = gKRTex2DMan->addTexture(mGroupID, fileName);
}

void _KRChara2DSpec::initForBoxParticle2D(const std::string& imageTicket)
{
    mParticleTexID = gKRTex2DMan->_getTextureIDForTicket(imageTicket);
}

void _KRChara2DSpec::addMotion(int motionID, _KRChara2DMotion* aMotion)
{
    mMotionMap[motionID] = aMotion;
}

std::string _KRChara2DSpec::getSpecName() const
{
    return mSpecName;
}

_KRChara2DMotion* _KRChara2DSpec::getMotion(int motionID)
{
    return mMotionMap[motionID];
}

int _KRChara2DSpec::getParticleTextureID() const
{
    return mParticleTexID;
}

int _KRChara2DSpec::getSpecID() const
{
    return mSpecID;
}

bool _KRChara2DSpec::isParticle()
{
    return (mParticleTexID >= 0)? true: false;
}

/*bool KRChara2DSpec::isTextureAtlased() const
 {
 return (gKRTex2DMan->getAtlasSize(mTextureID).x > 0.0)? true: false;
 }*/

void _KRChara2DSpec::setSpecID(int specID)
{
    mSpecID = specID;
}


#pragma mark -
#pragma mark KRChara2D クラスの実装

KRChara2D::KRChara2D(int charaSpecID, int classType)
{
    _mCharaSpec = gKRAnime2DMan->_getChara2DSpec(charaSpecID);
    _mClassType = classType;
    _mZOrder = 0;

    _mPos = KRVector2DZero;
    
    _angle = 0.0;
    _mBlendMode = KRBlendModeAlpha;
    _mColor = KRColor(1.0, 1.0, 1.0, 1.0);
    _mScale = KRVector2DOne;
    
    _mCurrentMotionID = -1;
    _mIsFinished = true;
    
    _mIsTemporal = false;
}

KRChara2D::~KRChara2D()
{
    // Do nothing
}

bool KRChara2D::_isTemporal() const
{
    return _mIsTemporal;
}

void KRChara2D::_setAsTemporal()
{
    _mIsTemporal = true;
}

bool KRChara2D::_isFinished() const
{
    return _mIsFinished;
}

bool KRChara2D::contains(const KRVector2D& p) const
{
    KRVector2D size = getSize();
    KRRect2D rect(_mPos.x, _mPos.y, size.x * _mScale.x, size.y * _mScale.y);
    return rect.contains(p);
}

_KRChara2DKoma* KRChara2D::_getCurrentKoma() const
{
    _KRChara2DMotion* theMotion = _mCharaSpec->getMotion(_mCurrentMotionID);
    if (theMotion == NULL) {
        return NULL;
    }
    
    return theMotion->getKoma(_mCurrentKomaNumber);
}

bool KRChara2D::hitTest(int hitType, const KRVector2D& pos) const
{
    _KRChara2DMotion* theMotion = _mCharaSpec->getMotion(_mCurrentMotionID);
    if (theMotion == NULL) {
        return false;
    }
    
    _KRChara2DKoma* theKoma = theMotion->getKoma(_mCurrentKomaNumber);
    int count = theKoma->_getHitAreaCount();
    if (count == 0) {
        return false;
    }

    _KRChara2DHitArea* hitAreas = theKoma->_getHitAreas();
    for (int i = 0; i < count; i++) {
        if (hitAreas[i].group != hitType) {
            continue;
        }
        if (hitAreas[i].hitTest(_mPos, _mScale, pos)) {
            return true;
        }
    }
    
    return false;
}

bool KRChara2D::hitTest(int hitType, const KRChara2D* targetChara, int targetHitType) const
{
    _KRChara2DMotion* theMotion = _mCharaSpec->getMotion(_mCurrentMotionID);
    if (theMotion == NULL) {
        return false;
    }
    
    _KRChara2DKoma* theKoma = theMotion->getKoma(_mCurrentKomaNumber);
    int count = theKoma->_getHitAreaCount();
    if (count == 0) {
        return false;
    }

    _KRChara2DKoma* targetKoma = targetChara->_getCurrentKoma();
    if (targetKoma == NULL) {
        return false;
    }
    unsigned targetHitAreaCount = targetKoma->_getHitAreaCount();
    if (targetKoma == NULL || targetHitAreaCount == 0) {
        return false;
    }
    _KRChara2DHitArea* targetAreas = targetKoma->_getHitAreas();
    KRVector2D targetOffset = targetChara->getPos();
    KRVector2D targetScale = targetChara->getScale();

    _KRChara2DHitArea* hitAreas = theKoma->_getHitAreas();
    for (int i = 0; i < count; i++) {
        if (hitAreas[i].group != hitType) {
            continue;
        }
        if (hitAreas[i].hitTest(_mPos, _mScale, targetHitAreaCount, targetAreas, targetHitType, targetOffset, targetScale)) {
            return true;
        }
    }
    
    return false;
}


#pragma mark （動作の管理）

int KRChara2D::getMotion() const
{
    return _mCurrentMotionID;
}

void KRChara2D::changeMotion(int motionID)
{
    changeMotion(motionID, KRCharaMotionChangeModeNormalMask);
}

void KRChara2D::changeMotion(int motionID, unsigned modeMask)
{
    if (_mCharaSpec->isParticle()) {
        return;
    }
    
    if (_mCurrentMotionID == motionID) {
        return;
    }
    
    _KRChara2DMotion* theMotion = _mCharaSpec->getMotion(motionID);
    if (theMotion == NULL) {
        if (gKRLanguage == KRLanguageJapanese) {
            throw KRRuntimeError("KRChara2D::changeMotion() キャラクタ \"%s\" の動作 %d は見つかりませんでした。", _mCharaSpec->getSpecName().c_str(), motionID);
        } else {
            throw KRRuntimeError("KRChara2D::changeMotion() Motion %d was not found for the character \"%s\".", motionID, _mCharaSpec->getSpecName().c_str());
        }
        return;
    }
    
    _mCurrentMotionID = motionID;
    
    _mCurrentKomaNumber = 1;
    _mIsFinished = false;
    
    _KRChara2DKoma* theKoma = theMotion->getKoma(_mCurrentKomaNumber);
    _mImageInterval = theKoma->getInterval();
}


#pragma mark （状態の取得）

KRVector2D KRChara2D::getCenterPos() const
{
    KRVector2D size = getSize();
    return KRVector2D(_mPos.x + size.x * _mScale.x / 2, _mPos.y + size.y * _mScale.y / 2);
}

void KRChara2D::setCenterPos(const KRVector2D& p)
{
    KRVector2D size = getSize();
    _mPos.x = p.x - size.x * _mScale.x / 2;
    _mPos.y = p.y - size.y * _mScale.y / 2;
}

int KRChara2D::getClassType() const
{
    return _mClassType;
}

KRColor KRChara2D::getColor() const
{
    return _mColor;
}

KRVector2D KRChara2D::getPos() const
{
    return _mPos;
}

KRVector2D KRChara2D::getScale() const
{
    return _mScale;
}

KRVector2D KRChara2D::getSize() const
{
    _KRChara2DMotion* theMotion = _mCharaSpec->getMotion(_mCurrentMotionID);
    if (theMotion == NULL) {
        return KRVector2DZero;
    }
    
    _KRChara2DKoma* theKoma = theMotion->getKoma(_mCurrentKomaNumber);
    return theKoma->getAtlasSize();
}

int KRChara2D::getZOrder() const
{
    return _mZOrder;
}

void KRChara2D::setBlendMode(KRBlendMode blendMode)
{
    _mBlendMode = blendMode;
}

void KRChara2D::setColor(const KRColor& color)
{
    _mColor = color;
}

void KRChara2D::setPos(const KRVector2D& pos)
{
    _mPos = pos;
}

void KRChara2D::setScale(const KRVector2D& scale)
{
    _mScale = scale;
}

void KRChara2D::setZOrder(int zOrder)
{
    if (_mZOrder == zOrder) {
        return;
    }
    _mZOrder = zOrder;
    gKRAnime2DMan->_reorderChara2D(this);
}

void KRChara2D::_step()
{
    if (_mCurrentMotionID < 0) {
        return;
    }
    
    if (_mIsFinished) {
        return;
    }
    
    _mImageInterval--;
    if (_mImageInterval == 0) {
        _KRChara2DMotion* theMotion = _mCharaSpec->getMotion(_mCurrentMotionID);
        _KRChara2DKoma* theKoma = theMotion->getKoma(_mCurrentKomaNumber);
        
        int gotoTarget = theKoma->getGotoTarget();
        
        // GOTO の場合
        if (gotoTarget > 0) {
            _mCurrentKomaNumber = gotoTarget;
            theKoma = theMotion->getKoma(_mCurrentKomaNumber);
            _mImageInterval = theKoma->getInterval();
        }
        // 次のコマへ
        else {
            // 最後のコマ
            if (theMotion->getKomaCount() == _mCurrentKomaNumber) {
                _mIsFinished = true;
            }
            // それ以外の場合
            else  {
                _mCurrentKomaNumber++;
                theKoma = theMotion->getKoma(_mCurrentKomaNumber);
                _mImageInterval = theKoma->getInterval();
            }
        }
    }
}

void KRChara2D::_draw()
{    
    // パーティクル用のキャラクタ
    if (_mCharaSpec->isParticle()) {
        gKRGraphicsInst->setBlendMode(_mBlendMode);
        
        int texID = _mCharaSpec->getParticleTextureID();
        gKRTex2DMan->drawAtPointCenterEx(texID, _mPos, _angle, _mScale, _mColor);
    }
    
    // 通常のキャラクタ
    else {
        if (_mCurrentMotionID < 0) {
            return;
        }
        
        _KRChara2DMotion* theMotion = _mCharaSpec->getMotion(_mCurrentMotionID);
        if (theMotion == NULL) {
            return;
        }
        
        _KRChara2DKoma* theKoma = theMotion->getKoma(_mCurrentKomaNumber);
        
        gKRGraphicsInst->setBlendMode(_mBlendMode);
        
        int texID = theKoma->getTextureID();
        
        KRVector2DInt atlasPos = theKoma->getAtlasPos();
        gKRTex2DMan->drawAtlasAtPointEx(texID, atlasPos, _mPos, 0.0, KRVector2DZero, _mScale, _mColor);
    }
}



