/*!
    @file   KRAnime2DManager.cpp
    @author Satoshi Numata
    @date   10/01/11
 */

#include "KRAnime2DManager.h"


KRAnime2DManager*   gKRAnime2DMan = NULL;
KRMemoryAllocator*  gKRChara2DAllocator = NULL;


#pragma mark -
#pragma mark KRChara2DKoma の実装

KRChara2DKoma::KRChara2DKoma()
{
    mAtlasIndex = -1;
    mAtlasPos = KRVector2DInt(-1, -1);
}

void KRChara2DKoma::initForManualChara2D(int textureID, KRVector2DInt atlasPos, int interval, bool isCancelable, int gotoTarget)
{
    mTextureID = textureID;

    mAtlasPos = atlasPos;
    mIsCancelable = isCancelable;
    mInterval = interval;
    mGotoTarget = gotoTarget;    
}

void KRChara2DKoma::initForBoxChara2D(const std::string& imageTicket, int atlasIndex, int interval, bool isCancelable, int gotoTarget)
{
    mTextureID = gKRTex2DMan->getTextureIDForTicket(imageTicket);
    
    mAtlasIndex = atlasIndex;
    mIsCancelable = isCancelable;
    mInterval = interval;
    mGotoTarget = gotoTarget;
}

KRVector2DInt KRChara2DKoma::getAtlasPos()
{
    if (mAtlasPos.x >= 0) {
        return mAtlasPos;
    }
    
    KRTexture2D* theTex = gKRTex2DMan->_getTexture(mTextureID);

    int divX = theTex->getDivX();

    return KRVector2DInt(mAtlasIndex % divX, mAtlasIndex / divX);
}

KRVector2D KRChara2DKoma::getAtlasSize()
{
    KRTexture2D* theTex = gKRTex2DMan->_getTexture(mTextureID);
    return theTex->getAtlasSize();
}

int KRChara2DKoma::getGotoTarget()
{
    return mGotoTarget;
}

int KRChara2DKoma::getInterval()
{
    return mInterval;
}

int KRChara2DKoma::getTextureID()
{
    return mTextureID;
}


#pragma mark -
#pragma mark KRChara2DState の実装

KRChara2DState::KRChara2DState()
{
}

void KRChara2DState::initForManualChara2D(int cancelKomaNumber, int nextStateID)
{
    mCancelKomaNumber = cancelKomaNumber;
    mNextStateID = nextStateID;
}

void KRChara2DState::initForBoxChara2D(int cancelKomaNumber, int nextStateID)
{
    mCancelKomaNumber = cancelKomaNumber;
    mNextStateID = nextStateID;
}

void KRChara2DState::addKoma(KRChara2DKoma* aKoma)
{
    mKomas.push_back(aKoma);
}

int KRChara2DState::getKomaCount()
{
    return mKomas.size();
}

KRChara2DKoma* KRChara2DState::getKoma(int komaNumber)
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

KRChara2DSpec::KRChara2DSpec(int texGroupID)
{
    mGroupID = texGroupID;
    mSpecID = -1;
    mParticleTexID = -1;
}

KRChara2DSpec::~KRChara2DSpec()
{
    std::map<int, KRChara2DState*>::iterator it = mStateMap.begin();
	while (it != mStateMap.end()) {
        delete (*it).second;
		it++;
	}
}

void KRChara2DSpec::initForManualChara2D()
{
    // Do nothing
}

void KRChara2DSpec::initForManualParticle2D(const std::string& fileName)
{
    mParticleTexID = gKRTex2DMan->addTexture(mGroupID, fileName);
}

void KRChara2DSpec::initForBoxParticle2D(const std::string& imageTicket)
{
    mParticleTexID = gKRTex2DMan->getTextureIDForTicket(imageTicket);
}

void KRChara2DSpec::addState(int stateID, KRChara2DState* aState)
{
    mStateMap[stateID] = aState;
}

KRChara2DState* KRChara2DSpec::getState(int stateID)
{
    return mStateMap[stateID];
}

int KRChara2DSpec::getParticleTextureID() const
{
    return mParticleTexID;
}

int KRChara2DSpec::getSpecID() const
{
    return mSpecID;
}

bool KRChara2DSpec::isParticle()
{
    return (mParticleTexID >= 0)? true: false;
}

/*bool KRChara2DSpec::isTextureAtlased() const
{
    return (gKRTex2DMan->getAtlasSize(mTextureID).x > 0.0)? true: false;
}*/

void KRChara2DSpec::setSpecID(int specID)
{
    mSpecID = specID;
}


#pragma mark -
#pragma mark KRChara2D クラスの実装

KRChara2D::KRChara2D(KRChara2DSpec *charaSpec, const KRVector2D& _centerPos, int zOrder, void *repObj)
    : mCharaSpec(charaSpec), pos(_centerPos), mZOrder(zOrder), mRepresentedObject(repObj)
{
    _angle = 0.0;
    blendMode = KRBlendModeAlpha;
    color = KRColor(1.0, 1.0, 1.0, 1.0);
    scale = 1.0;
    
    mCurrentStateID = -1;
    mIsFinished = true;
    
    mRepresentedObject = NULL;

    //changeState(firstState);
}

void* KRChara2D::getObject() const
{
    return mRepresentedObject;
}

KRVector2D KRChara2D::getSize() const
{
    KRChara2DState* theState = mCharaSpec->getState(mCurrentStateID);
    if (theState == NULL) {
        return KRVector2DZero;
    }
    
    KRChara2DKoma* theKoma = theState->getKoma(mCurrentKomaNumber);
    return theKoma->getAtlasSize();
}

int KRChara2D::getState() const
{
    return mCurrentStateID;
}

int KRChara2D::getZOrder() const
{
    return mZOrder;
}

void KRChara2D::changeState(int stateID, unsigned modeMask)
{
    if (mCharaSpec->isParticle()) {
        return;
    }

    if (mCurrentStateID == stateID) {
        return;
    }

    KRChara2DState* theState = mCharaSpec->getState(stateID);
    if (theState == NULL) {
        if (gKRLanguage == KRLanguageJapanese) {
            throw KRRuntimeError("KRChara2D::changeState() キャラクタ特徴 %d の 状態 %d は見つかりませんでした。", mCharaSpec->getSpecID(), stateID);
        } else {
            throw KRRuntimeError("KRChara2D::changeState() State %d was not found for character spec %d.", stateID, mCharaSpec->getSpecID());
        }
        return;
    }
    
    mCurrentStateID = stateID;

    mCurrentKomaNumber = 1;
    mIsFinished = false;

    KRChara2DKoma* theKoma = theState->getKoma(mCurrentKomaNumber);
    mImageInterval = theKoma->getInterval();
}

void KRChara2D::setObject(void *anObj)
{
    mRepresentedObject = anObj;
}

void KRChara2D::setZOrder(int zOrder)
{
    if (mZOrder == zOrder) {
        return;
    }
    mZOrder = zOrder;
    gKRAnime2DMan->_reorderChara2D(this);
}

void KRChara2D::_step()
{
    if (mCurrentStateID < 0) {
        return;
    }
    
    if (mIsFinished) {
        return;
    }
    
    mImageInterval--;
    if (mImageInterval == 0) {
        KRChara2DState* theState = mCharaSpec->getState(mCurrentStateID);
        KRChara2DKoma* theKoma = theState->getKoma(mCurrentKomaNumber);
        
        int gotoTarget = theKoma->getGotoTarget();

        // GOTO の場合
        if (gotoTarget > 0) {
            mCurrentKomaNumber = gotoTarget;
            theKoma = theState->getKoma(mCurrentKomaNumber);
            mImageInterval = theKoma->getInterval();
        }
        // 次のコマへ
        else {
            // 最後のコマ
            if (theState->getKomaCount() == mCurrentKomaNumber) {
                mIsFinished = true;
            }
            // それ以外の場合
            else  {
                mCurrentKomaNumber++;
                theKoma = theState->getKoma(mCurrentKomaNumber);
                mImageInterval = theKoma->getInterval();
            }
        }
    }
}

void KRChara2D::_draw()
{    
    // パーティクル用のキャラクタ
    if (mCharaSpec->isParticle()) {
        gKRGraphicsInst->setBlendMode(blendMode);

        int texID = mCharaSpec->getParticleTextureID();
        gKRTex2DMan->drawAtPointCenterEx(texID, pos, _angle, gKRTex2DMan->getTextureSize(texID)/2, KRVector2D(scale, scale), color);
    }
    
    // 通常のキャラクタ
    else {
        if (mCurrentStateID < 0) {
            return;
        }
        
        KRChara2DState* theState = mCharaSpec->getState(mCurrentStateID);
        if (theState == NULL) {
            return;
        }
        
        KRChara2DKoma* theKoma = theState->getKoma(mCurrentKomaNumber);
        
        gKRGraphicsInst->setBlendMode(blendMode);
        
        int texID = theKoma->getTextureID();
        
        KRVector2DInt atlasPos = theKoma->getAtlasPos();
        gKRTex2DMan->drawAtlasAtPointEx(texID, atlasPos, pos, 0.0, KRVector2DZero, KRVector2D(scale, scale), color);
    }
}



#pragma mark -
#pragma mark KRAnime2DManager クラスの実装

KRAnime2DManager::KRAnime2DManager(int maxCharacter2DSize)
{
    gKRAnime2DMan = this;
    
    mNextInnerCharaSpecID = 10000;
    mNextSimulatorID = 10000;
    
    gKRChara2DAllocator = new KRMemoryAllocator(sizeof(KRChara2D), maxCharacter2DSize, "kr-chara2d-alloc");
}

KRAnime2DManager::~KRAnime2DManager()
{
    removeAllCharas();

    // キャラクタの特徴マップの削除
    {
        std::map<int, KRChara2DSpec*>::iterator it = mCharaSpecMap.begin();
        while (it != mCharaSpecMap.end()) {
            delete (*it).second;
            it++;
        }
        mCharaSpecMap.clear();
    }
    
    delete gKRChara2DAllocator;
    gKRChara2DAllocator = NULL;
}


#pragma mark -
#pragma mark キャラクタの特徴の管理

void KRAnime2DManager::_addCharaSpec(int specID, KRChara2DSpec* spec)
{
    mCharaSpecMap[specID] = spec;
    spec->setSpecID(specID);
}

void KRAnime2DManager::addCharacterSpecs(int groupID, const std::string& specFileName)
{
    KRTextReader reader(specFileName);
    
    std::string str;
    int lineCount = 0;
    
    KRChara2DSpec* theSpec = NULL;
    KRChara2DState* theState = NULL;
    int texID = -1;
    int defaultInterval = 4;
    
    while (reader.readLine(&str)) {
        lineCount++;
        
        // 空行や「#」から始まる行はスキップ
        if (str.length() == 0 || str[0] == '#') {
            continue;
        }
        
        // 「@」から始まる行は、メタ情報の記述
        if (str[0] == '@') {
            continue;
        }
        
        // 行構成の分割
        std::vector<std::string> vec = KRSplitString(str, ", \t():=");
        int elemCount = vec.size();
        
        if (elemCount == 0) {
            continue;
        }
        
        std::string command = vec[0];
        
        // キャラクタの生成
        if (command == "chara") {
            int specID = atoi(vec[1].c_str());
            std::string filename = "";
            int atlasX = 0;
            int atlasY = 0;
            int groupID = 0;
            
            for (int i = 2; i < elemCount;) {
                if (vec[i] == "tex") {
                    filename = vec[i+1];
                    i += 2;
                }
                else if (vec[i] == "atlas") {
                    atlasX = atoi(vec[i+1].c_str());
                    atlasY = atoi(vec[i+2].c_str());
                    i += 3;
                }
                else if (vec[i] == "group") {
                    groupID = atoi(vec[i+1].c_str());
                    i += 2;
                }
                else {
                    throw KRRuntimeError("Invalid chara command parameter: %s", vec[i].c_str());
                }
            }
            
            if (filename == "" || atlasX == 0 || atlasY == 0) {
                throw KRRuntimeError("chara command should have texture filename and atlas size specifications.");
            }
            
            texID = gKRTex2DMan->addTexture(groupID, filename, KRVector2D(atlasX, atlasY));
            
            theSpec = new KRChara2DSpec(groupID);
            theSpec->initForManualChara2D();
            _addCharaSpec(specID, theSpec);
            
            theState = NULL;
        }
        // キャラクタの状態
        else if (command == "state") {
            defaultInterval = 4;

            int stateID = atoi(vec[1].c_str());
            int nextStateID = -1;
            int cancelKomaNumber = 0;

            for (int i = 2; i < elemCount;) {
                if (vec[i] == "interval") {
                    defaultInterval = atoi(vec[i+1].c_str());
                    i += 2;
                }
                else if (vec[i] == "next") {
                    nextStateID = atoi(vec[i+1].c_str());
                    i += 2;
                }
                else if (vec[i] == "cancel") {
                    cancelKomaNumber = atoi(vec[i+1].c_str());
                    i += 2;
                }
                else {
                    throw KRRuntimeError("Invalid state command parameter: %s", vec[i].c_str());
                }
            }
            
            theState = new KRChara2DState();
            theState->initForManualChara2D(cancelKomaNumber, nextStateID);
            theSpec->addState(stateID, theState);
        }
        // 各状態のコマ
        else if (command == "image") {
            int atlasX = atoi(vec[1].c_str());
            int atlasY = atoi(vec[2].c_str());
            int interval = defaultInterval;
            bool isCancelable = true;
            int gotoTarget = 0;
            int komaNumber = theState->getKomaCount() + 1;
            
            for (int i = 3; i < elemCount;) {
                if (vec[i] == "repeat-back") {
                    gotoTarget = komaNumber - atoi(vec[i+1].c_str());
                    i += 2;
                }
                else if (vec[i] == "interval") {
                    interval = atoi(vec[i+1].c_str());
                    i += 2;
                }
                else if (vec[i] == "cancel") {
                    isCancelable = (atoi(vec[i+1].c_str())? true: false);
                    i += 2;
                }
                else {
                    throw KRRuntimeError("Invalid image command parameter: %s", vec[i].c_str());
                }
            }

            KRChara2DKoma* aKoma = new KRChara2DKoma();
            aKoma->initForManualChara2D(texID, KRVector2DInt(atlasX, atlasY), interval, isCancelable, gotoTarget);
            theState->addKoma(aKoma);
        }
        // 不明なコマンド
        else {
            throw KRRuntimeError("Unknown command: %s", command.c_str());
        }
    }
}

int KRAnime2DManager::addParticle2D(int groupID, const std::string& imageFileName)
{
    int theParticleID = mParticleSystemMap.size() + 1000;
    
    mParticleSystemMap[theParticleID] = new KRParticle2DSystem(groupID, imageFileName, 0);
    
    return theParticleID;
}

void KRAnime2DManager::_addParticle2DWithTicket(int resourceID, int groupID, const std::string& imageTicket)
{
    mParticleSystemMap[resourceID] = new KRParticle2DSystem(groupID, imageTicket);
}

int KRAnime2DManager::_addTexCharaSpec(int groupID, const std::string& imageFileName)
{
    int theSpecID = mNextInnerCharaSpecID;
    mNextInnerCharaSpecID++;

    KRChara2DSpec* theSpec = new KRChara2DSpec(groupID);
    theSpec->initForManualParticle2D(imageFileName);
    
    _addCharaSpec(theSpecID, theSpec);

    return theSpecID;
}

int KRAnime2DManager::_addTexCharaSpecWithTicket(int groupID, const std::string& ticket)
{
    int theSpecID = mNextInnerCharaSpecID;
    mNextInnerCharaSpecID++;
    
    KRChara2DSpec* theSpec = new KRChara2DSpec(groupID);
    theSpec->initForBoxParticle2D(ticket);

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

KRChara2D* KRAnime2DManager::createChara2D(int specID, const KRVector2D& centerPos, int firstState, int zOrder, void *repObj)
{
    KRChara2DSpec* theSpec = mCharaSpecMap[specID];
    if (theSpec == NULL) {
        const char *errorFormat = "KRAnime2D::createCharacter() Character spec was not found for spec-id %d.";
        if (gKRLanguage == KRLanguageJapanese) {
            errorFormat = "KRAnime2D::createCharacter() ID が %d のキャラクタ特徴は見つかりませんでした。";
        }
        throw KRRuntimeError(errorFormat, specID);
    }

    KRChara2D* newChara = new KRChara2D(theSpec, centerPos, zOrder, repObj);

    bool hasAdded = false;
    for (std::list<KRChara2D*>::iterator it = mCharas.begin(); it != mCharas.end(); it++) {
        KRChara2D* aChara = *it;
        if (zOrder >= aChara->getZOrder()) {
            mCharas.insert(it, newChara);
            hasAdded = true;
            break;
        }
    }
    
    if (!hasAdded) {
        mCharas.push_back(newChara);
    }
    
    newChara->changeState(firstState);
    
    return newChara;
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
    mCharas.remove(chara);
    delete chara;
}

void KRAnime2DManager::_reorderChara2D(KRChara2D* chara)
{
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
    for (std::list<KRChara2D*>::reverse_iterator it = mCharas.rbegin(); it != mCharas.rend(); it++) {
        (*it)->_step();
    }
    
    for (std::map<int, KRParticle2DSystem*>::iterator it = mParticleSystemMap.begin(); it != mParticleSystemMap.end(); it++) {
        KRParticle2DSystem* theParticleSystem = it->second;
        theParticleSystem->step();
    }
}

void KRAnime2DManager::draw()
{
    KRBlendMode oldBlendMode = gKRGraphicsInst->getBlendMode();
    
    for (std::list<KRChara2D*>::reverse_iterator it = mCharas.rbegin(); it != mCharas.rend(); it++) {
        (*it)->_draw();
    }
    
    gKRGraphicsInst->setBlendMode(oldBlendMode);
}


#pragma mark -
#pragma mark パーティクルシステム

KRParticle2DSystem* KRAnime2DManager::_getParticleSystem(int particleID) const
{
    KRParticle2DSystem* theParticleSystem = NULL;

    // IDからパーティクルシステムを引っ張ってくる。
    std::map<int, KRParticle2DSystem*>::const_iterator theElem = mParticleSystemMap.find(particleID);
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

void KRAnime2DManager::generateParticle2D(int particleID, const KRVector2D& pos)
{
    return _getParticleSystem(particleID)->addGenerationPoint(pos);
}

KRBlendMode KRAnime2DManager::getParticle2DBlendMode(int particleID) const
{
    return _getParticleSystem(particleID)->getBlendMode();
}

KRColor KRAnime2DManager::getParticle2DColor(int particleID) const
{
    return _getParticleSystem(particleID)->getColor();
}

int KRAnime2DManager::getParticle2DCount(int particleID) const
{
    return _getParticleSystem(particleID)->getGeneratedParticleCount();
}

double KRAnime2DManager::getParticle2DAlphaDelta(int particleID) const
{
    return _getParticleSystem(particleID)->getDeltaAlpha();
}

double KRAnime2DManager::getParticle2DBlueDelta(int particleID) const
{
    return _getParticleSystem(particleID)->getDeltaBlue();
}

double KRAnime2DManager::getParticle2DGreenDelta(int particleID) const
{
    return _getParticleSystem(particleID)->getDeltaGreen();
}

double KRAnime2DManager::getParticle2DRedDelta(int particleID) const
{
    return _getParticleSystem(particleID)->getDeltaRed();
}

double KRAnime2DManager::getParticle2DScaleDelta(int particleID) const
{
    return _getParticleSystem(particleID)->getDeltaScale();
}

int KRAnime2DManager::getParticle2DGenerateCount(int particleID) const
{
    return _getParticleSystem(particleID)->getGenerateCount();
}

KRVector2D KRAnime2DManager::getParticle2DGravity(int particleID) const
{
    return _getParticleSystem(particleID)->getGravity();
}

int KRAnime2DManager::getParticle2DLife(int particleID) const
{
    return _getParticleSystem(particleID)->getLife();
}

double KRAnime2DManager::getParticle2DMaxAngleV(int particleID) const
{
    return _getParticleSystem(particleID)->getMaxAngleV();
}

int KRAnime2DManager::getParticle2DMaxCount(int particleID) const
{
    return _getParticleSystem(particleID)->getParticleCount();
}

double KRAnime2DManager::getParticle2DMaxScale(int particleID) const
{
    return _getParticleSystem(particleID)->getMaxScale();
}

KRVector2D KRAnime2DManager::getParticle2DMaxV(int particleID) const
{
    return _getParticleSystem(particleID)->getMaxV();
}

double KRAnime2DManager::getParticle2DMinAngleV(int particleID) const
{
    return _getParticleSystem(particleID)->getMinAngleV();
}

double KRAnime2DManager::getParticle2DMinScale(int particleID) const
{
    return _getParticleSystem(particleID)->getMinScale();
}

KRVector2D KRAnime2DManager::getParticle2DMinV(int particleID) const
{
    return _getParticleSystem(particleID)->getMinV();
}

void KRAnime2DManager::setParticle2DBlendMode(int particleID, KRBlendMode blendMode)
{
    _getParticleSystem(particleID)->setBlendMode(blendMode);
}

void KRAnime2DManager::setParticle2DColor(int particleID, const KRColor& color)
{
    _getParticleSystem(particleID)->setColor(color);
}

void KRAnime2DManager::setParticle2DColorDelta(int particleID, double red, double green, double blue, double alpha)
{
    _getParticleSystem(particleID)->setColorDelta(red, green, blue, alpha);
}

void KRAnime2DManager::setParticle2DGenerateCount(int particleID, int count)
{
    _getParticleSystem(particleID)->setGenerateCount(count);
}

void KRAnime2DManager::setParticle2DGravity(int particleID, const KRVector2D& a)
{
    _getParticleSystem(particleID)->setGravity(a);
}

void KRAnime2DManager::setParticle2DLife(int particleID, unsigned life)
{
    _getParticleSystem(particleID)->setLife(life);
}

void KRAnime2DManager::setParticle2DMaxAngleV(int particleID, double angleV)
{
    _getParticleSystem(particleID)->setMaxAngleV(angleV);
}

void KRAnime2DManager::setParticle2DMaxCount(int particleID, unsigned count)
{
    _getParticleSystem(particleID)->setParticleCount(count);
}

void KRAnime2DManager::setParticle2DMaxScale(int particleID, double scale)
{
    _getParticleSystem(particleID)->setMaxScale(scale);
}

void KRAnime2DManager::setParticle2DMaxV(int particleID, const KRVector2D& v)
{
    _getParticleSystem(particleID)->setMaxV(v);
}

void KRAnime2DManager::setParticle2DMinAngleV(int particleID, double angleV)
{
    _getParticleSystem(particleID)->setMinAngleV(angleV);
}

void KRAnime2DManager::setParticle2DMinScale(int particleID, double scale)
{
    _getParticleSystem(particleID)->setMinScale(scale);
}

void KRAnime2DManager::setParticle2DMinV(int particleID, const KRVector2D& v)
{
    _getParticleSystem(particleID)->setMinV(v);
}

void KRAnime2DManager::setParticle2DScaleDelta(int particleID, double value)
{
    _getParticleSystem(particleID)->setScaleDelta(value);
}



