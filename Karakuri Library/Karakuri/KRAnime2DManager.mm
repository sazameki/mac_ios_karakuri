/*!
    @file   KRAnime2DManager.cpp
    @author Satoshi Numata
    @date   10/01/11
 */

#include "KRAnime2DManager.h"
#include "KRChara2D.h"
#include "KRGameController.h"


KRAnime2DManager*   gKRAnime2DMan = NULL;
KRMemoryAllocator*  _gKRChara2DAllocator = NULL;


#pragma mark -
#pragma mark KRAnime2DManager クラスの実装

KRAnime2DManager::KRAnime2DManager(int maxCharacter2DCount, size_t maxChara2DSize)
{
    gKRAnime2DMan = this;
    
    mNextInnerCharaSpecID = 10000;
    mNextSimulatorID = 10000;
    
    _gKRChara2DAllocator = new KRMemoryAllocator(maxChara2DSize, maxCharacter2DCount, "kr-chara2d-alloc");
}

KRAnime2DManager::~KRAnime2DManager()
{
    removeAllCharas();

    // キャラクタの特徴マップの削除
    {
        std::map<int, _KRChara2DSpec*>::iterator it = mCharaSpecMap.begin();
        while (it != mCharaSpecMap.end()) {
            delete (*it).second;
            it++;
        }
        mCharaSpecMap.clear();
    }
    
    delete _gKRChara2DAllocator;
    _gKRChara2DAllocator = NULL;
}


#pragma mark -
#pragma mark キャラクタの特徴の管理

void KRAnime2DManager::_addCharaSpec(int specID, _KRChara2DSpec* spec)
{
    mCharaSpecMap[specID] = spec;
    spec->setSpecID(specID);
}

void KRAnime2DManager::_addParticle2DWithTextureID(int groupID, int resourceID, int texID)
{
    mParticleSystemMap[resourceID] = new _KRParticle2DSystem(groupID, texID);
}

int KRAnime2DManager::_addTexCharaSpec(int groupID, const std::string& imageFileName)
{
    int theSpecID = mNextInnerCharaSpecID;
    mNextInnerCharaSpecID++;

    _KRChara2DSpec* theSpec = new _KRChara2DSpec(groupID, "");
    theSpec->initForManualParticle2D(imageFileName);
    
    _addCharaSpec(theSpecID, theSpec);

    return theSpecID;
}

int KRAnime2DManager::_addTexCharaSpecWithTextureID(int groupID, int texID)
{
    int theSpecID = mNextInnerCharaSpecID;
    mNextInnerCharaSpecID++;
    
    _KRChara2DSpec* theSpec = new _KRChara2DSpec(groupID, "");
    theSpec->initForBoxParticle2D(texID);

    _addCharaSpec(theSpecID, theSpec);
    
    return theSpecID;    
}


#pragma mark -
#pragma mark シミュレータの管理

int KRAnime2DManager::addSimulator(const KRVector2D& gravity)
{
    int theSimulatorID = mNextSimulatorID;
    mNextSimulatorID++;
    
    KRSimulator2D* theSimulator = new KRSimulator2D(gravity);
    mSimulatorMap[theSimulatorID] = theSimulator;
    
    return theSimulatorID;
}

void KRAnime2DManager::putCharaInSimulator(KRChara2D* aChara, int simulatorID)
{
}


#pragma mark -
#pragma mark キャラクタの管理

_KRChara2DSpec* KRAnime2DManager::_getChara2DSpec(int specID)
{
    _KRChara2DSpec* theSpec = mCharaSpecMap[specID];
    if (theSpec == NULL) {
        const char *errorFormat = "KRAnime2D::createCharacter() Character spec was not found for spec-id %d.";
        if (gKRLanguage == KRLanguageJapanese) {
            errorFormat = "KRAnime2D::createCharacter() ID が %d のキャラクタ特徴は見つかりませんでした。";
        }
        throw KRRuntimeError(errorFormat, specID);
    }
    return theSpec;
}

void KRAnime2DManager::addChara2D(KRChara2D* newChara)
{
    if (newChara->_isInList()) {
        return;
    }
    
    int zOrder = newChara->getZOrder();
    
    bool hasAdded = false;
    
    for (std::list<KRChara2D*>::iterator it = mCharas.begin(); it != mCharas.end(); it++) {
        if (zOrder >= (*it)->getZOrder()) {
            mCharas.insert(it, newChara);
            hasAdded = true;
            break;
        }
    }
    
    if (!hasAdded) {
        mCharas.push_back(newChara);
    }
    
    newChara->_setIsInList(true);
}

KRChara2D* KRAnime2DManager::getChara2D(int classType, const KRVector2D& pos) const
{
    for (std::list<KRChara2D*>::const_iterator it = mCharas.begin(); it != mCharas.end(); it++) {
        if ((*it)->getClassType() != classType) {
            continue;
        }
        if ((*it)->contains(pos)) {
            return *it;
        }
    }
    return NULL;
}

KRChara2D* KRAnime2DManager::hitChara2D(int classType, int hitType, const KRVector2D& pos) const
{
    for (std::list<KRChara2D*>::const_iterator it = mCharas.begin(); it != mCharas.end(); it++) {
        if ((*it)->getClassType() != classType) {
            continue;
        }
        if ((*it)->hitTest(hitType, pos)) {
            return *it;
        }
    }
    return NULL;    
}

KRChara2D* KRAnime2DManager::hitChara2D(int classType, int hitType, const KRChara2D* targetChara, int targetHitType) const
{
    for (std::list<KRChara2D*>::const_iterator it = mCharas.begin(); it != mCharas.end(); it++) {
        if ((*it)->getClassType() != classType) {
            continue;
        }
        if ((*it)->hitTest(hitType, targetChara, targetHitType)) {
            return *it;
        }
    }
    return NULL;    
}

void KRAnime2DManager::playChara2D(int charaSpecID, int motionID, const KRVector2D& pos, int zOrder)
{
    KRChara2D* chara = new KRChara2D(100000, charaSpecID);
    chara->setZOrder(zOrder);
    chara->changeMotion(motionID);
    chara->setPos(pos);
    
    this->addChara2D(chara);
}

void KRAnime2DManager::playChara2DCenter(int charaSpecID, int motionID, const KRVector2D& centerPos, int zOrder)
{
    KRChara2D* chara = new KRChara2D(100000, charaSpecID);
    chara->_setAsTemporal();
    chara->setZOrder(zOrder);
    chara->changeMotion(motionID);
    chara->setCenterPos(centerPos);
    
    this->addChara2D(chara);
}

void KRAnime2DManager::removeAllCharas()
{
    for (std::list<KRChara2D*>::iterator it = mCharas.begin(); it != mCharas.end();) {
        KRChara2D* aChara = *it;
        it = mCharas.erase(it);
        delete aChara;
    }
    mCharas.clear();
}

void KRAnime2DManager::removeChara2D(KRChara2D* chara)
{
    if (!chara->_isInList()) {
        return;
    }
    
    mCharas.remove(chara);
    delete chara;
}

void KRAnime2DManager::_reorderChara2D(KRChara2D* chara)
{
    if (!chara->_isInList()) {
        return;
    }
    
    int zOrder = chara->getZOrder();
    
    mCharas.remove(chara);

    bool hasAdded = false;
    for (std::list<KRChara2D*>::iterator it = mCharas.begin(); it != mCharas.end(); it++) {
        KRChara2D* aChara = *it;
        if (zOrder >= aChara->getZOrder()) {
            mCharas.insert(it, chara);
            hasAdded = true;
            break;
        }
    }
    
    if (!hasAdded) {
        mCharas.push_back(chara);
    }    
}

void KRAnime2DManager::stepAllCharas()
{
    for (std::list<KRChara2D*>::iterator it = mCharas.begin(); it != mCharas.end();) {
        (*it)->_step();
        if ((*it)->_isTemporal() && (*it)->isMotionFinished()) {
            KRChara2D* aChara = *it;
            it = mCharas.erase(it);
            delete aChara;
        } else {
            it++;
        }
    }
    
    for (std::map<int, _KRParticle2DSystem*>::iterator it = mParticleSystemMap.begin(); it != mParticleSystemMap.end(); it++) {
        _KRParticle2DSystem* theParticleSystem = it->second;
        theParticleSystem->step();
    }
}

void KRAnime2DManager::draw()
{
    KRBlendMode oldBlendMode = gKRGraphicsInst->getBlendMode();
    
    for (std::list<KRChara2D*>::reverse_iterator it = mCharas.rbegin(); it != mCharas.rend(); it++) {
        if (!(*it)->_mIsHidden) {
            (*it)->_draw();
        }
    }
    
    gKRGraphicsInst->setBlendMode(oldBlendMode);
    
#if __DEBUG__
    _gCharaDrawCounts[_gCharaDrawCountPos++] = mCharas.size();
    if (_gCharaDrawCountPos >= KR_CHARA_COUNT_HISTORY_SIZE) {
        _gCharaDrawCountPos = 0;
    }    
#endif
}


#pragma mark -
#pragma mark パーティクルシステム

_KRParticle2DSystem* KRAnime2DManager::_getParticleSystem(int particleID) const
{
    _KRParticle2DSystem* theParticleSystem = NULL;

    // IDからパーティクルシステムを引っ張ってくる。
    std::map<int, _KRParticle2DSystem*>::const_iterator theElem = mParticleSystemMap.find(particleID);
    if (theElem != mParticleSystemMap.end()) {
        theParticleSystem = theElem->second;
    }
    
    // パーティクルシステムが見つからなかったときの処理。
    if (theParticleSystem == NULL) {
        const char *errorFormat = "Failed to find the particle system with ID %d.";
        if (gKRLanguage == KRLanguageJapanese) {
            errorFormat = "ID が %d のパーティクルシステムは見つかりませんでした。";
        }
        throw KRRuntimeError(errorFormat, particleID);
    }
    
    // リターン
    return theParticleSystem;    
}

void KRAnime2DManager::generateParticle2D(int particleID, const KRVector2D& pos, int zOrder)
{
    return _getParticleSystem(particleID)->addGenerationPoint(pos, zOrder);
}



