/*!
    @file   KRAnime2DManager.cpp
    @author Satoshi Numata
    @date   10/01/11
 */

#include "KRAnime2DManager.h"


KRAnime2DManager*   gKRAnime2DMan = NULL;
KRMemoryAllocator*  gKRChara2DAllocator = NULL;


#pragma mark -
#pragma mark KRChara2DSpec の実装

KRChara2DSpec::KRChara2DSpec(int texGroupID, const std::string& textureName, const KRVector2D& atlasSize)
{
    mSpecID = -1;
    mTextureID = gKRTex2DMan->addTexture(texGroupID, textureName, atlasSize);
}

KRChara2DSpec::~KRChara2DSpec()
{
    std::map<int, _KRChara2DState*>::iterator it = mStateMap.begin();
	while (it != mStateMap.end()) {
        delete (*it).second;
		it++;
	}
}
    
void KRChara2DSpec::addState(int state, int imageInterval, int repeatCount, bool doReverse, int nextState)
{
    _KRChara2DState* theState = mStateMap[state];
    if (theState == NULL) {
        theState = new _KRChara2DState();
        mStateMap[state] = theState;
    }

    theState->state = state;
    theState->imageInterval = imageInterval;
    theState->repeatCount = repeatCount;
    theState->doReverse = doReverse;
    theState->nextState = nextState;
    theState->repeatHeadIndex = 0;
}

void KRChara2DSpec::addStateImage(int state, const KRVector2DInt& atlasPos, bool isRepeatHead)
{
    _KRChara2DState* theState = mStateMap[state];
    if (theState == NULL) {
        const char *errorFormat = "KRChara2DSpec::addStateImage() State %d is not registered.";
        if (gKRLanguage == KRLanguageJapanese) {
            errorFormat = "KRChara2DSpec::addStateImage() 状態 %d は登録されていません。";
        }        
        throw KRRuntimeError(errorFormat, state);
    }
    
    if (isRepeatHead) {
        theState->repeatHeadIndex = theState->atlasPositions.size();
    }
    theState->atlasPositions.push_back(atlasPos);
}

_KRChara2DState* KRChara2DSpec::_getState(int state)
{
    return mStateMap[state];
}

int KRChara2DSpec::_getTextureID() const
{
    return mTextureID;
}

int KRChara2DSpec::_getSpecID() const
{
    return mSpecID;
}

bool KRChara2DSpec::_isTextureAtlased() const
{
    return (gKRTex2DMan->getAtlasSize(mTextureID).x > 0.0)? true: false;
}

void KRChara2DSpec::_setSpecID(int specID)
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
    
    mState = -1;
    mNextState = -1;
    
    mRepresentedObject = NULL;

    //changeState(firstState);
}

void* KRChara2D::getObject() const
{
    return mRepresentedObject;
}

KRVector2D KRChara2D::getSize() const
{
    return gKRTex2DMan->getAtlasSize(mCharaSpec->_getTextureID());
}

int KRChara2D::getState() const
{
    if (mNextState >= 0) {
        return mNextState;
    }
    return mState;
}

int KRChara2D::getZOrder() const
{
    return mZOrder;
}

void KRChara2D::changeState(int state)
{
    if (mNextState >= 0 || mState == state) {
        return;
    }

    _KRChara2DState* theState = mCharaSpec->_getState(state);
    if (theState == NULL) {
        if (gKRLanguage == KRLanguageJapanese) {
            throw KRRuntimeError("KRChara2D::changeState() キャラクタ特徴 %d の 状態 %d は見つかりませんでした。\n", mCharaSpec->_getSpecID(), state);
        } else {
            throw KRRuntimeError("KRChara2D::changeState() State %d was not found for character spec %d.\n", state, mCharaSpec->_getSpecID());
        }
        return;
    }
    
    _KRChara2DState* theCurrentState = mCharaSpec->_getState(mState);
    bool backToHead = false;
    if (theCurrentState != NULL) {
        if (std::find(theCurrentState->backToState.begin(), theCurrentState->backToState.end(), state) != theCurrentState->backToState.end()) {
            backToHead = true;
        }
    }

    // そのまま状態を変更する場合
    if (!backToHead || mImageIndex == 0) {
        mState = state;
        mNextState = -1;
        mHasPassedHead = false;
        mImageIndex = 0;
        mImageInc = 1;
        mIsStateFinished = false;
        mRepeatCount = theState->repeatCount;
        mImageInterval = theState->imageInterval;
    }
    // 状態変更時に頭まで巻き戻す場合
    else {
        mNextState = state;
        mImageInterval = theState->imageInterval;
        mHasPassedHead = (mImageIndex <= theState->repeatHeadIndex || theState->doReverse);
    }
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
    if (mState < 0) {
        return;
    }
    
    // 状態変更時に頭まで巻き戻す場合
    if (mNextState >= 0) {
        if (mImageInterval == 0) {
            if (mHasPassedHead) {
                mImageIndex--;
                if (mImageIndex < 0) {
                    mState = mNextState;
                    mNextState = -1;
                    mHasPassedHead = false;
                    mImageIndex = 0;
                    mImageInc = 1;
                    mIsStateFinished = false;

                    _KRChara2DState* theState = mCharaSpec->_getState(mState);
                    mRepeatCount = theState->repeatCount;
                    mImageInterval = theState->imageInterval;
                } else {
                    _KRChara2DState* theState = mCharaSpec->_getState(mState);
                    mImageInterval = theState->imageInterval;
                }
            } else {
                _KRChara2DState* theState = mCharaSpec->_getState(mState);
                int imageCount = theState->atlasPositions.size();
                mImageIndex++;
                if (mImageIndex >= imageCount) {
                    mImageIndex = theState->repeatHeadIndex;
                    mHasPassedHead = true;
                }
            }
        } else {
            mImageInterval--;
        }
        return;
    }
    
    // 状態変更が終了して、最後のコマを表示し続ける場合
    if (mIsStateFinished) {
        return;
    }
    
    // ステップ実行処理
    if (mImageInterval == 0) {
        _KRChara2DState* theState = mCharaSpec->_getState(mState);
        int imageCount = theState->atlasPositions.size();
        mImageIndex += mImageInc;

        // アニメーションのコマがもうない場合
        if (mImageIndex >= imageCount) {
            // とりあえず最後のコマに戻しておく。
            mImageIndex--;

            // 反転する場合
            if (theState->doReverse) {
                mImageInc = -1;
                if (mImageIndex > 0) {
                    mImageIndex += mImageInc;
                }
                mImageInterval = theState->imageInterval;
            }
            // 反転しない場合
            else {
                // リピートする場合
                if (mRepeatCount != 0) {
                    if (mRepeatCount > 0) {
                        mRepeatCount--;
                    }
                    mImageIndex = theState->repeatHeadIndex;
                    mImageInterval = theState->imageInterval;
                }
                // リピートしない／リピート終了
                else {
                    // 次の状態が設定されている場合には、その状態に移行する。
                    if (theState->nextState >= 0) {
                        changeState(theState->nextState);
                    }
                    // 次の状態がない場合には、ステップ実行を終了する。
                    else {
                        mIsStateFinished = true;
                    }
                }
            }
        }
        // アニメーションの先頭のコマに戻った場合（反転してきた場合にしか先頭に戻らない）
        else if (mHasPassedHead && mImageIndex < theState->repeatHeadIndex) {
            // とりあえず先頭のコマに戻しておく。
            mImageIndex = theState->repeatHeadIndex;

            // リピートする場合
            if (mRepeatCount != 0) {
                if (mRepeatCount > 0) {
                    mRepeatCount--;
                }
                mImageInc = 1;
                mImageIndex += mImageInc;
                if (mImageIndex >= imageCount) {
                    mImageIndex = 0;
                }
                mImageInterval = theState->imageInterval;
            }
            // リピートしない／リピート終了
            else {
                // 次の状態が設定されている場合には、その状態に移行する。
                if (theState->nextState >= 0) {
                    changeState(theState->nextState);
                }
                // 次の状態がない場合には、ステップ実行を終了する。
                else {
                    mIsStateFinished = true;
                }
            }
        }
        // それ以外の場合
        else {
            mImageInterval = theState->imageInterval;
            if (!mHasPassedHead && mImageIndex >= theState->repeatHeadIndex) {
                mHasPassedHead = true;
            }
        }
    } else {
        mImageInterval--;
    }
}

void KRChara2D::_draw()
{
    if (mState < 0) {
        return;
    }
    
    _KRChara2DState* theState = mCharaSpec->_getState(mState);
    if (theState == NULL) {
        return;
    }
    
    gKRGraphicsInst->setBlendMode(blendMode);
    
    int texID = mCharaSpec->_getTextureID();
    if (mCharaSpec->_isTextureAtlased()) {
        KRVector2DInt& atlasPos = theState->atlasPositions[mImageIndex];        
        gKRTex2DMan->drawAtlasAtPointEx(texID, atlasPos, pos, _angle, gKRTex2DMan->getAtlasSize(texID)/2, KRVector2D(scale, scale), color);
    } else {
        gKRTex2DMan->drawAtPointEx(texID, pos, _angle, gKRTex2DMan->getTextureSize(texID)/2, KRVector2D(scale, scale), color);
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
    spec->_setSpecID(specID);
}

void KRAnime2DManager::addCharaSpecs(int groupID, const std::string& specFileName)
{
    KRTextReader reader(specFileName);
    
    std::string str;
    int lineCount = 0;
    
    int             theSpecID = -1; 
    KRChara2DSpec*  theSpec = NULL;
    int             theStateID = -1;
    
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
        std::vector<std::string> vec = KRSplitString(str, ", \t():");
        int elemCount = vec.size();
        
        if (elemCount == 0) {
            continue;
        }
        
        std::string command = vec[0];
        
        if (command == "chara") {
            if (elemCount < 5) {
                const char *errorFormat = "KRAnime2D::loadCharacterSpecs() Too few parameters for chara command (file=%s, line=%d)";
                if (gKRLanguage == KRLanguageJapanese) {
                    errorFormat = "KRAnime2D::loadCharacterSpecs() chara 命令の引数が不足しています。 (file=%s, line=%d)";
                }
                throw KRRuntimeError(errorFormat, specFileName.c_str(), lineCount);
            }
            int specID = atoi(vec[1].c_str());
            std::string textureName = vec[2];
            int atlasWidth = atoi(vec[3].c_str());
            int atlasHeight = atoi(vec[4].c_str());
            
            if (theSpec != NULL) {
                if (theStateID < 0) {
                    theSpec->addState(0, 1, 0, false, -1);
                    theSpec->addStateImage(0, KRVector2DInt(0, 0), false);
                }
                gKRAnime2DMan->_addCharaSpec(theSpecID, theSpec);
                theStateID = -1;
            }
            
            theSpecID = specID;
            theSpec = new KRChara2DSpec(groupID, textureName, KRVector2D(atlasWidth, atlasHeight));
        }
        else if (command == "state") {
            if (theSpec == NULL) {
                const char *errorFormat = "KRAnime2D::loadCharacterSpecs() State command without chara command (file=%s, line=%d)";
                if (gKRLanguage == KRLanguageJapanese) {
                    errorFormat = "KRAnime2D::loadCharacterSpecs() chara 命令なしに state 命令が呼び出されました。 (file=%s, line=%d)";
                }
                throw KRRuntimeError(errorFormat, specFileName.c_str(), lineCount);
            }
            if (elemCount < 2) {
                const char *errorFormat = "KRAnime2D::loadCharacterSpecs() No state-id for state command (file=%s, line=%d)";
                if (gKRLanguage == KRLanguageJapanese) {
                    errorFormat = "KRAnime2D::loadCharacterSpecs() state 命令に状態IDがありません。 (file=%s, line=%d)";
                }
                throw KRRuntimeError(errorFormat, specFileName.c_str(), lineCount);
            }
            int stateID = atoi(vec[1].c_str());
            
            if (stateID < 0) {
                const char *errorFormat = "KRAnime2D::loadCharacterSpecs() State-id should be greater than or equal to 0 (file=%s, line=%d)";
                if (gKRLanguage == KRLanguageJapanese) {
                    errorFormat = "KRAnime2D::loadCharacterSpecs() 状態IDは 0 以上でなければいけません。 (file=%s, line=%d)";
                }
                throw KRRuntimeError(errorFormat, specFileName.c_str(), lineCount);
            }
            
            int interval = 1;
            int repeatCount = 0;
            bool doReverse = false;
            int nextState = -1;
            
            for (int i = 2; i < elemCount; i++) {
                std::vector<std::string> paramElems = KRSplitString(vec[i], " \t=");
                if (paramElems.size() != 2) {
                    const char *errorFormat = "KRAnime2D::loadCharacterSpecs() Invalid state command param: \"%s\" (file=%s, line=%d)";
                    if (gKRLanguage == KRLanguageJapanese) {
                        errorFormat = "KRAnime2D::loadCharacterSpecs() state 命令のパラメータのフォーマットが不正です: \"%s\" (file=%s, line=%d)";
                    }
                    throw KRRuntimeError(errorFormat, vec[i].c_str(), specFileName.c_str(), lineCount);
                }
                if (paramElems[0] == "repeat") {
                    if (paramElems[1] == "ever") {
                        repeatCount = -1;
                    } else {
                        repeatCount = atoi(paramElems[1].c_str());
                    }
                }
                else if (paramElems[0] == "interval") {
                    interval = atoi(paramElems[1].c_str());
                }
                else if (paramElems[0] == "reverse") {
                    doReverse = (paramElems[1] == "true");
                }
                else if (paramElems[0] == "next") {
                    nextState = atoi(paramElems[1].c_str());
                }
            }
            
            theStateID = stateID;
            theSpec->addState(stateID, interval, repeatCount, doReverse, nextState);
        }
        else if (command == "back-to") {
            if (theSpec == NULL) {
                const char *errorFormat = "KRAnime2D::loadCharacterSpecs() Back-to command without chara command (file=%s, line=%d)";
                if (gKRLanguage == KRLanguageJapanese) {
                    errorFormat = "KRAnime2D::loadCharacterSpecs() chara 命令なしに back-to 命令が呼び出されました。 (file=%s, line=%d)";
                }
                throw KRRuntimeError(errorFormat, specFileName.c_str(), lineCount);
            }
            if (theStateID < 0) {
                const char *errorFormat = "KRAnime2D::loadCharacterSpecs() Back-to command without state command (file=%s, line=%d)";
                if (gKRLanguage == KRLanguageJapanese) {
                    errorFormat = "KRAnime2D::loadCharacterSpecs() state 命令なしに back-to 命令が呼び出されました。 (file=%s, line=%d)";
                }
                throw KRRuntimeError(errorFormat, specFileName.c_str(), lineCount);
            }
            for (int i = 1; i < elemCount; i++) {
                _KRChara2DState *theState = theSpec->_getState(theStateID);
                theState->backToState.push_back(atoi(vec[i].c_str()));
            }
        }
        else if (command == "image") {
            if (theSpec == NULL) {
                const char *errorFormat = "KRAnime2D::loadCharacterSpecs() Image command without chara command (file=%s, line=%d)";
                if (gKRLanguage == KRLanguageJapanese) {
                    errorFormat = "KRAnime2D::loadCharacterSpecs() chara 命令なしに image 命令が呼び出されました。 (file=%s, line=%d)";
                }
                throw KRRuntimeError(errorFormat, specFileName.c_str(), lineCount);
            }
            if (theStateID < 0) {
                const char *errorFormat = "KRAnime2D::loadCharacterSpecs() Image command without state command (file=%s, line=%d)";
                if (gKRLanguage == KRLanguageJapanese) {
                    errorFormat = "KRAnime2D::loadCharacterSpecs() state 命令なしに image 命令が呼び出されました。 (file=%s, line=%d)";
                }
                throw KRRuntimeError(errorFormat, specFileName.c_str(), lineCount);
            }
            if (elemCount < 3) {
                const char *errorFormat = "KRAnime2D::loadCharacterSpecs() Too few parameters for image command (file=%s, line=%d)";
                if (gKRLanguage == KRLanguageJapanese) {
                    errorFormat = "KRAnime2D::loadCharacterSpecs() image 命令の引数が不足しています。 (file=%s, line=%d)";
                }
                throw KRRuntimeError(errorFormat, specFileName.c_str(), lineCount);
            }
            int atlasX = atoi(vec[1].c_str());
            int atlasY = atoi(vec[2].c_str());
            bool isRepeatHead = false;
            if (elemCount >= 4) {
                isRepeatHead = (vec[3] == "*");
            }
            
            theSpec->addStateImage(theStateID, KRVector2DInt(atlasX, atlasY), isRepeatHead);
        }
        else {
            const char *errorFormat = "KRAnime2D::loadCharacterSpecs() Unknown command: \"%s\" (file=%s, line=%d)";
            if (gKRLanguage == KRLanguageJapanese) {
                errorFormat = "KRAnime2D::loadCharacterSpecs() 不明な命令: \"%s\" (file=%s, line=%d)";
            }
            throw KRRuntimeError(errorFormat, command.c_str(), specFileName.c_str(), lineCount);
        }
    }
    
    if (theSpec != NULL) {
        if (theStateID < 0) {
            theSpec->addState(0, 1, 0, false, -1);
            theSpec->addStateImage(0, KRVector2DInt(0, 0), false);
        }
        gKRAnime2DMan->_addCharaSpec(theSpecID, theSpec);
    }
}

int KRAnime2DManager::addParticleSystem(int groupID, const std::string& imageFileName, int zOrder)
{
    int theParticleID = mParticleSystemMap.size();
    
    mParticleSystemMap[theParticleID] = new KRParticle2DSystem(groupID, imageFileName, zOrder);
    
    return theParticleID;
}

int KRAnime2DManager::_addTexCharaSpec(int groupID, const std::string& imageFileName)
{
    int theSpecID = mNextInnerCharaSpecID;
    mNextInnerCharaSpecID++;
    
    KRChara2DSpec* theSpec = new KRChara2DSpec(groupID, imageFileName, KRVector2DZero);
    theSpec->addState(0, 0, 0, false);
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

void KRAnime2DManager::generateParticles(int particleID, const KRVector2D& pos)
{
    return _getParticleSystem(particleID)->addGenerationPoint(pos);
}

KRBlendMode KRAnime2DManager::getParticleBlendMode(int particleID) const
{
    return _getParticleSystem(particleID)->getBlendMode();
}

KRColor KRAnime2DManager::getParticleColor(int particleID) const
{
    return _getParticleSystem(particleID)->getColor();
}

int KRAnime2DManager::getParticleCount(int particleID) const
{
    return _getParticleSystem(particleID)->getGeneratedParticleCount();
}

double KRAnime2DManager::getParticleAlphaDelta(int particleID) const
{
    return _getParticleSystem(particleID)->getDeltaAlpha();
}

double KRAnime2DManager::getParticleBlueDelta(int particleID) const
{
    return _getParticleSystem(particleID)->getDeltaBlue();
}

double KRAnime2DManager::getParticleGreenDelta(int particleID) const
{
    return _getParticleSystem(particleID)->getDeltaGreen();
}

double KRAnime2DManager::getParticleRedDelta(int particleID) const
{
    return _getParticleSystem(particleID)->getDeltaRed();
}

double KRAnime2DManager::getParticleScaleDelta(int particleID) const
{
    return _getParticleSystem(particleID)->getDeltaScale();
}

int KRAnime2DManager::getParticleGenerateCount(int particleID) const
{
    return _getParticleSystem(particleID)->getGenerateCount();
}

KRVector2D KRAnime2DManager::getParticleGravity(int particleID) const
{
    return _getParticleSystem(particleID)->getGravity();
}

int KRAnime2DManager::getParticleLife(int particleID) const
{
    return _getParticleSystem(particleID)->getLife();
}

double KRAnime2DManager::getParticleMaxAngleV(int particleID) const
{
    return _getParticleSystem(particleID)->getMaxAngleV();
}

int KRAnime2DManager::getParticleMaxCount(int particleID) const
{
    return _getParticleSystem(particleID)->getParticleCount();
}

double KRAnime2DManager::getParticleMaxScale(int particleID) const
{
    return _getParticleSystem(particleID)->getMaxScale();
}

KRVector2D KRAnime2DManager::getParticleMaxV(int particleID) const
{
    return _getParticleSystem(particleID)->getMaxV();
}

double KRAnime2DManager::getParticleMinAngleV(int particleID) const
{
    return _getParticleSystem(particleID)->getMinAngleV();
}

double KRAnime2DManager::getParticleMinScale(int particleID) const
{
    return _getParticleSystem(particleID)->getMinScale();
}

KRVector2D KRAnime2DManager::getParticleMinV(int particleID) const
{
    return _getParticleSystem(particleID)->getMinV();
}

void KRAnime2DManager::setParticleBlendMode(int particleID, KRBlendMode blendMode)
{
    _getParticleSystem(particleID)->setBlendMode(blendMode);
}

void KRAnime2DManager::setParticleColor(int particleID, const KRColor& color)
{
    _getParticleSystem(particleID)->setColor(color);
}

void KRAnime2DManager::setParticleColorDelta(int particleID, double red, double green, double blue, double alpha)
{
    _getParticleSystem(particleID)->setColorDelta(red, green, blue, alpha);
}

void KRAnime2DManager::setParticleGenerateCount(int particleID, int count)
{
    _getParticleSystem(particleID)->setGenerateCount(count);
}

void KRAnime2DManager::setParticleGravity(int particleID, const KRVector2D& a)
{
    _getParticleSystem(particleID)->setGravity(a);
}

void KRAnime2DManager::setParticleLife(int particleID, unsigned life)
{
    _getParticleSystem(particleID)->setLife(life);
}

void KRAnime2DManager::setParticleMaxAngleV(int particleID, double angleV)
{
    _getParticleSystem(particleID)->setMaxAngleV(angleV);
}

void KRAnime2DManager::setParticleMaxCount(int particleID, unsigned count)
{
    _getParticleSystem(particleID)->setParticleCount(count);
}

void KRAnime2DManager::setParticleMaxScale(int particleID, double scale)
{
    _getParticleSystem(particleID)->setMaxScale(scale);
}

void KRAnime2DManager::setParticleMaxV(int particleID, const KRVector2D& v)
{
    _getParticleSystem(particleID)->setMaxV(v);
}

void KRAnime2DManager::setParticleMinAngleV(int particleID, double angleV)
{
    _getParticleSystem(particleID)->setMinAngleV(angleV);
}

void KRAnime2DManager::setParticleMinScale(int particleID, double scale)
{
    _getParticleSystem(particleID)->setMinScale(scale);
}

void KRAnime2DManager::setParticleMinV(int particleID, const KRVector2D& v)
{
    _getParticleSystem(particleID)->setMinV(v);
}

void KRAnime2DManager::setParticleScaleDelta(int particleID, double value)
{
    _getParticleSystem(particleID)->setScaleDelta(value);
}



