/*!
    @file   KRAnime2DManager.cpp
    @author Satoshi Numata
    @date   10/01/11
 */

#include "KRAnime2DManager.h"


KRAnime2DManager*   gKRAnime2DMan = NULL;
KRMemoryAllocator*  gKRCharacter2DAllocator = NULL;


#pragma mark -
#pragma mark KRCharacter2DSpec の実装

KRCharacter2DSpec::KRCharacter2DSpec(int texGroupID, const std::string& textureName, const KRVector2D& atlasSize)
{
    mSpecID = -1;
    mTextureID = gKRTex2DMan->addTexture(texGroupID, textureName, atlasSize);
}

KRCharacter2DSpec::~KRCharacter2DSpec()
{
    std::map<int, _KRCharacter2DState*>::iterator it = mStateMap.begin();
	while (it != mStateMap.end()) {
        delete (*it).second;
		it++;
	}
}
    
void KRCharacter2DSpec::addState(int state, int imageInterval, int repeatCount, bool doReverse, int nextState)
{
    _KRCharacter2DState* theState = mStateMap[state];
    if (theState == NULL) {
        theState = new _KRCharacter2DState();
        mStateMap[state] = theState;
    }

    theState->state = state;
    theState->imageInterval = imageInterval;
    theState->repeatCount = repeatCount;
    theState->doReverse = doReverse;
    theState->nextState = nextState;
    theState->repeatHeadIndex = 0;
}

void KRCharacter2DSpec::addStateImage(int state, const KRVector2DInt& atlasPos, bool isRepeatHead)
{
    _KRCharacter2DState* theState = mStateMap[state];
    if (theState == NULL) {
        const char *errorFormat = "KRCharacter2DSpec::addStateImage() State %d is not registered.";
        if (gKRLanguage == KRLanguageJapanese) {
            errorFormat = "KRCharacter2DSpec::addStateImage() 状態 %d は登録されていません。";
        }        
        throw KRRuntimeError(errorFormat, state);
    }
    
    if (isRepeatHead) {
        theState->repeatHeadIndex = theState->atlasPositions.size();
    }
    theState->atlasPositions.push_back(atlasPos);
}

_KRCharacter2DState* KRCharacter2DSpec::_getState(int state)
{
    return mStateMap[state];
}

int KRCharacter2DSpec::_getTextureID() const
{
    return mTextureID;
}

int KRCharacter2DSpec::_getSpecID() const
{
    return mSpecID;
}

void KRCharacter2DSpec::_setSpecID(int specID)
{
    mSpecID = specID;
}


#pragma mark -
#pragma mark KRCharacter2D クラスの実装

KRCharacter2D::KRCharacter2D(KRCharacter2DSpec *charaSpec, const KRVector2D& _centerPos, int zOrder, void *repObj)
    : mCharaSpec(charaSpec), pos(_centerPos), mZOrder(zOrder), mRepresentedObject(repObj)
{
    color = KRColor(1.0, 1.0, 1.0, 1.0);
    
    mState = -1;
    mNextState = -1;
    
    mRepresentedObject = NULL;

    //changeState(firstState);
}

void* KRCharacter2D::getRepresentedObject() const
{
    return mRepresentedObject;
}

KRVector2D KRCharacter2D::getSize() const
{
    return gKRTex2DMan->getAtlasSize(mCharaSpec->_getTextureID());
}

int KRCharacter2D::getState() const
{
    if (mNextState >= 0) {
        return mNextState;
    }
    return mState;
}

int KRCharacter2D::getZOrder() const
{
    return mZOrder;
}

void KRCharacter2D::changeState(int state)
{
    if (mNextState >= 0 || mState == state) {
        return;
    }

    _KRCharacter2DState* theState = mCharaSpec->_getState(state);
    if (theState == NULL) {
        if (gKRLanguage == KRLanguageJapanese) {
            throw KRRuntimeError("KRCharacter2D::changeState() キャラクタ特徴 %d の 状態 %d は見つかりませんでした。\n", mCharaSpec->_getSpecID(), state);
        } else {
            throw KRRuntimeError("KRCharacter2D::changeState() State %d was not found for character spec %d.\n", state, mCharaSpec->_getSpecID());
        }
        return;
    }
    
    _KRCharacter2DState* theCurrentState = mCharaSpec->_getState(mState);
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

void KRCharacter2D::setRepresentedObject(void *anObj)
{
    mRepresentedObject = anObj;
}

void KRCharacter2D::setZOrder(int zOrder)
{
    if (mZOrder == zOrder) {
        return;
    }
    mZOrder = zOrder;
    gKRAnime2DMan->_reorderCharacter(this);
}

void KRCharacter2D::_step()
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

                    _KRCharacter2DState* theState = mCharaSpec->_getState(mState);
                    mRepeatCount = theState->repeatCount;
                    mImageInterval = theState->imageInterval;
                } else {
                    _KRCharacter2DState* theState = mCharaSpec->_getState(mState);
                    mImageInterval = theState->imageInterval;
                }
            } else {
                _KRCharacter2DState* theState = mCharaSpec->_getState(mState);
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
        _KRCharacter2DState* theState = mCharaSpec->_getState(mState);
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

void KRCharacter2D::_draw()
{
    if (mState < 0) {
        return;
    }
    
    _KRCharacter2DState* theState = mCharaSpec->_getState(mState);
    if (theState == NULL) {
        return;
    }

    KRVector2DInt& atlasPos = theState->atlasPositions[mImageIndex];
    int texID = mCharaSpec->_getTextureID();
    
    gKRTex2DMan->drawAtlasAtPointCenter(texID, atlasPos, pos, color);
}



#pragma mark -
#pragma mark KRAnime2DManager クラスの実装

KRAnime2DManager::KRAnime2DManager(int maxCharacter2DSize)
{
    gKRAnime2DMan = this;
    
    gKRCharacter2DAllocator = new KRMemoryAllocator(sizeof(KRCharacter2D), maxCharacter2DSize, "kr-chara2d-alloc");
}

KRAnime2DManager::~KRAnime2DManager()
{
    removeAllCharacters();

    // キャラクタの特徴マップの削除
    {
        std::map<int, KRCharacter2DSpec*>::iterator it = mCharaSpecMap.begin();
        while (it != mCharaSpecMap.end()) {
            delete (*it).second;
            it++;
        }
        mCharaSpecMap.clear();
    }
    
    delete gKRCharacter2DAllocator;
    gKRCharacter2DAllocator = NULL;
}


#pragma mark -
#pragma mark キャラクタの特徴の管理

void KRAnime2DManager::_addCharacterSpec(int specID, KRCharacter2DSpec *spec)
{
    mCharaSpecMap[specID] = spec;
    spec->_setSpecID(specID);
}

void KRAnime2DManager::addCharacterSpecs(int groupID, const std::string& specFileName)
{
    KRTextReader reader(specFileName);
    
    std::string str;
    int lineCount = 0;
    
    int                 theSpecID = -1; 
    KRCharacter2DSpec*  theSpec = NULL;
    int                 theStateID = -1;
    
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
                gKRAnime2DMan->_addCharacterSpec(theSpecID, theSpec);
                theStateID = -1;
            }
            
            theSpecID = specID;
            theSpec = new KRCharacter2DSpec(groupID, textureName, KRVector2D(atlasWidth, atlasHeight));
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
                _KRCharacter2DState *theState = theSpec->_getState(theStateID);
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
        gKRAnime2DMan->_addCharacterSpec(theSpecID, theSpec);
    }
}


#pragma mark -
#pragma mark キャラクタの管理

KRCharacter2D* KRAnime2DManager::createCharacter(int specID, const KRVector2D& centerPos, int firstState, int zOrder, void *repObj)
{
    KRCharacter2DSpec* theSpec = mCharaSpecMap[specID];
    if (theSpec == NULL) {
        const char *errorFormat = "KRAnime2D::createCharacter() Character spec was not found for spec-id %d.";
        if (gKRLanguage == KRLanguageJapanese) {
            errorFormat = "KRAnime2D::createCharacter() ID が %d のキャラクタ特徴は見つかりませんでした。";
        }
        throw KRRuntimeError(errorFormat, specID);
    }

    KRCharacter2D *newChara = new KRCharacter2D(theSpec, centerPos, zOrder, repObj);

    bool hasAdded = false;
    for (std::list<KRCharacter2D*>::iterator it = mCharacters.begin(); it != mCharacters.end(); it++) {
        KRCharacter2D* aChara = *it;
        if (zOrder >= aChara->getZOrder()) {
            mCharacters.insert(it, newChara);
            hasAdded = true;
            break;
        }
    }
    
    if (!hasAdded) {
        mCharacters.push_back(newChara);
    }
    
    newChara->changeState(firstState);
    
    return newChara;
}

void KRAnime2DManager::removeAllCharacters()
{
    for (std::list<KRCharacter2D*>::iterator it = mCharacters.begin(); it != mCharacters.end();) {
        KRCharacter2D *aChara = *it;
        it = mCharacters.erase(it);
        delete aChara;
    }
    mCharacters.clear();
}

void KRAnime2DManager::removeCharacter(KRCharacter2D *chara)
{
    mCharacters.remove(chara);
    delete chara;
}

void KRAnime2DManager::_reorderCharacter(KRCharacter2D *chara)
{
    int zOrder = chara->getZOrder();
    
    mCharacters.remove(chara);

    bool hasAdded = false;
    for (std::list<KRCharacter2D*>::iterator it = mCharacters.begin(); it != mCharacters.end(); it++) {
        KRCharacter2D* aChara = *it;
        if (zOrder >= aChara->getZOrder()) {
            mCharacters.insert(it, chara);
            hasAdded = true;
            break;
        }
    }
    
    if (!hasAdded) {
        mCharacters.push_back(chara);
    }    
}

void KRAnime2DManager::stepAllCharacters()
{
    for (std::list<KRCharacter2D*>::reverse_iterator it = mCharacters.rbegin(); it != mCharacters.rend(); it++) {
        (*it)->_step();
    }
}

void KRAnime2DManager::drawAllCharacters()
{
    for (std::list<KRCharacter2D*>::reverse_iterator it = mCharacters.rbegin(); it != mCharacters.rend(); it++) {
        (*it)->_draw();
    }
}


