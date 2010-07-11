/*!
    @file   KRAnime2DManager.cpp
    @author Satoshi Numata
    @date   10/01/11
 */

#include "KRAnime2DManager.h"
#include "KRChara2D.h"


KRAnime2DManager*   gKRAnime2DMan = NULL;
_KRMemoryAllocator* _gKRChara2DAllocator = NULL;


#pragma mark -
#pragma mark KRAnime2DManager クラスの実装

KRAnime2DManager::KRAnime2DManager(int maxCharacter2DCount, size_t maxChara2DSize)
{
    gKRAnime2DMan = this;
    
    mNextInnerCharaSpecID = 10000;
    mNextSimulatorID = 10000;
    
    _gKRChara2DAllocator = new _KRMemoryAllocator(maxChara2DSize, maxCharacter2DCount, "kr-chara2d-alloc");
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

/*
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
}*/

int KRAnime2DManager::_addParticle2D(int groupID, const std::string& imageFileName)
{
    int theParticleID = mParticleSystemMap.size() + 1000;
    
    mParticleSystemMap[theParticleID] = new _KRParticle2DSystem(groupID, imageFileName, 0);
    
    return theParticleID;
}

void KRAnime2DManager::_addParticle2DWithTicket(int resourceID, int groupID, const std::string& imageTicket)
{
    mParticleSystemMap[resourceID] = new _KRParticle2DSystem(groupID, imageTicket);
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

int KRAnime2DManager::_addTexCharaSpecWithTicket(int groupID, const std::string& ticket)
{
    int theSpecID = mNextInnerCharaSpecID;
    mNextInnerCharaSpecID++;
    
    _KRChara2DSpec* theSpec = new _KRChara2DSpec(groupID, "");
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
    int zOrder = newChara->getZOrder();
    
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
    KRChara2D* chara = new KRChara2D(charaSpecID, 100000);
    chara->setZOrder(zOrder);
    chara->changeMotion(motionID);
    chara->setPos(pos);
    
    this->addChara2D(chara);
}

void KRAnime2DManager::playChara2DCenter(int charaSpecID, int motionID, const KRVector2D& centerPos, int zOrder)
{
    KRChara2D* chara = new KRChara2D(charaSpecID, 100000);
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
    for (std::list<KRChara2D*>::iterator it = mCharas.begin(); it != mCharas.end();) {
        (*it)->_step();
        if ((*it)->_isTemporal() && (*it)->_isFinished()) {
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
        (*it)->_draw();
    }
    
    gKRGraphicsInst->setBlendMode(oldBlendMode);
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

void KRAnime2DManager::generateParticle2D(int particleID, const KRVector2D& pos)
{
    return _getParticleSystem(particleID)->addGenerationPoint(pos);
}

KRBlendMode KRAnime2DManager::getParticle2DBlendMode(int particleID) const
{
    return _getParticleSystem(particleID)->getBlendMode();
}

void KRAnime2DManager::setParticle2DBlendMode(int particleID, KRBlendMode blendMode)
{
    _getParticleSystem(particleID)->setBlendMode(blendMode);
}


/*KRColor KRAnime2DManager::_getParticle2DColor(int particleID) const
{
    return _getParticleSystem(particleID)->getColor();
}*/

/*int KRAnime2DManager::_getParticle2DCount(int particleID) const
{
    return _getParticleSystem(particleID)->getGeneratedParticleCount();
}*/

/*double KRAnime2DManager::_getParticle2DAlphaDelta(int particleID) const
{
    return _getParticleSystem(particleID)->getDeltaAlpha();
}*/

/*double KRAnime2DManager::_getParticle2DBlueDelta(int particleID) const
{
    return _getParticleSystem(particleID)->getDeltaBlue();
}*/

/*double KRAnime2DManager::_getParticle2DGreenDelta(int particleID) const
{
    return _getParticleSystem(particleID)->getDeltaGreen();
}*/

/*double KRAnime2DManager::_getParticle2DRedDelta(int particleID) const
{
    return _getParticleSystem(particleID)->getDeltaRed();
}*/

/*double KRAnime2DManager::_getParticle2DScaleDelta(int particleID) const
{
    return _getParticleSystem(particleID)->getDeltaScale();
}*/

/*int KRAnime2DManager::_getParticle2DGenerateCount(int particleID) const
{
    return _getParticleSystem(particleID)->getGenerateCount();
}*/

/*KRVector2D KRAnime2DManager::_getParticle2DGravity(int particleID) const
{
    return _getParticleSystem(particleID)->getGravity();
}*/

/*int KRAnime2DManager::_getParticle2DLife(int particleID) const
{
    return _getParticleSystem(particleID)->getLife();
}*/

/*double KRAnime2DManager::_getParticle2DMaxAngleV(int particleID) const
{
    return _getParticleSystem(particleID)->getMaxAngleV();
}*/

/*int KRAnime2DManager::_getParticle2DMaxCount(int particleID) const
{
    return _getParticleSystem(particleID)->getParticleCount();
}*/

/*double KRAnime2DManager::_getParticle2DMaxScale(int particleID) const
{
    return _getParticleSystem(particleID)->getMaxScale();
}*/

/*KRVector2D KRAnime2DManager::_getParticle2DMaxV(int particleID) const
{
    return _getParticleSystem(particleID)->getMaxV();
}*/

/*double KRAnime2DManager::_getParticle2DMinAngleV(int particleID) const
{
    return _getParticleSystem(particleID)->getMinAngleV();
}*/

/*double KRAnime2DManager::_getParticle2DMinScale(int particleID) const
{
    return _getParticleSystem(particleID)->getMinScale();
}*/

/*KRVector2D KRAnime2DManager::_getParticle2DMinV(int particleID) const
{
    return _getParticleSystem(particleID)->getMinV();
}*/

/*void KRAnime2DManager::_setParticle2DColor(int particleID, const KRColor& color)
{
    _getParticleSystem(particleID)->setColor(color);
}*/

/*void KRAnime2DManager::_setParticle2DColorDelta(int particleID, double red, double green, double blue, double alpha)
{
    _getParticleSystem(particleID)->setColorDelta(red, green, blue, alpha);
}*/

/*void KRAnime2DManager::_setParticle2DGenerateCount(int particleID, int count)
{
    _getParticleSystem(particleID)->setGenerateCount(count);
}*/

/*void KRAnime2DManager::_setParticle2DGravity(int particleID, const KRVector2D& a)
{
    _getParticleSystem(particleID)->setGravity(a);
}*/

/*void KRAnime2DManager::_setParticle2DLife(int particleID, unsigned life)
{
    _getParticleSystem(particleID)->setLife(life);
}*/

/*void KRAnime2DManager::_setParticle2DMaxAngleV(int particleID, double angleV)
{
    _getParticleSystem(particleID)->setMaxAngleV(angleV);
}*/

/*void KRAnime2DManager::_setParticle2DMaxCount(int particleID, unsigned count)
{
    _getParticleSystem(particleID)->setParticleCount(count);
}*/

/*void KRAnime2DManager::_setParticle2DMaxScale(int particleID, double scale)
{
    _getParticleSystem(particleID)->setMaxScale(scale);
}*/

/*void KRAnime2DManager::_setParticle2DMaxV(int particleID, const KRVector2D& v)
{
    _getParticleSystem(particleID)->setMaxV(v);
}*/

/*void KRAnime2DManager::_setParticle2DMinAngleV(int particleID, double angleV)
{
    _getParticleSystem(particleID)->setMinAngleV(angleV);
}*/

/*void KRAnime2DManager::_setParticle2DMinScale(int particleID, double scale)
{
    _getParticleSystem(particleID)->setMinScale(scale);
}*/

/*void KRAnime2DManager::_setParticle2DMinV(int particleID, const KRVector2D& v)
{
    _getParticleSystem(particleID)->setMinV(v);
}*/

/*void KRAnime2DManager::_setParticle2DScaleDelta(int particleID, double value)
{
    _getParticleSystem(particleID)->setScaleDelta(value);
}*/



