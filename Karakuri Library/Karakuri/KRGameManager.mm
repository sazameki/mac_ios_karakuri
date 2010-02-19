//
//  KRGameManager.mm
//  Karakuri Prototype
//
//  Created by numata on 09/07/17.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#include "KRGameManager.h"
#include "KRWorld.h"
#include "KRTexture2DManager.h"
#include "KRAudioManager.h"

#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
#import <Karakuri/macosx/KarakuriGLView.h>
#endif

#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
#import <Karakuri/iphone/KarakuriGLView.h>
#endif


KRGameManager*  gKRGameMan = NULL;
KRGameManager*  gKRGameInst = NULL;     // 後方互換のための以前のゲームマネージャ変数
KRVector2D      gKRScreenSize;

static BOOL sIsUpdatingModel = NO;


KRGameManager::KRGameManager()
{
    gKRGameMan = this;
    gKRGameInst = this;
    
    mTitle = "Karakuri Game";

    mFrameRate = 60.0;
    mScreenWidth = 480;
    mScreenHeight = 320;

    mAudioMixType = KRAudioMixTypeAmbientSolo;
    mShowsMouseCursor = false;
    mShowsFPS = false;
    
    mMaxCharacter2DCount = 256;

    mGameIDForNetwork = "";

    mWasChangingWorld = false;
    
    mWorldManager = new KRWorldManager();
}

KRGameManager::~KRGameManager()
{
    // Do nothing
}

void KRGameManager::setupResources()
{
    // Do nothing
}

void KRGameManager::loadResourceGroup(int groupID)
{
    gKRTex2DMan->loadTextureFiles(groupID, NULL, 0.0);
    gKRAudioMan->loadAudioFiles(groupID, NULL, 0.0);
}

std::string KRGameManager::getTitle() const
{
    return mTitle;
}

void KRGameManager::setTitle(const std::string& str)
{
    mTitle = str;
}

double KRGameManager::getFrameRate() const
{
    return mFrameRate;
}

void KRGameManager::setFrameRate(double value)
{
    mFrameRate = value;
}

bool KRGameManager::checkDeviceType(KRDeviceType type) const
{
    return (mDeviceType == type)? true: false;
}

int KRGameManager::getScreenWidth() const
{
    return mScreenWidth;
}

int KRGameManager::getScreenHeight() const
{
    return mScreenHeight;
}

KRVector2D KRGameManager::getScreenSize() const
{
    return KRVector2D(mScreenWidth, mScreenHeight);
}

bool KRGameManager::getShowsMouseCursor() const
{
    return mShowsMouseCursor;
}

void KRGameManager::setShowsMouseCursor(bool flag)
{
    mShowsMouseCursor = flag;
}

bool KRGameManager::getShowsFPS() const
{
    return mShowsFPS;
}

void KRGameManager::setShowsFPS(bool flag)
{
    mShowsFPS = flag;
}

int KRGameManager::getMaxCharacter2DCount() const
{
    return mMaxCharacter2DCount;
}

void KRGameManager::setMaxCharacter2DCount(int count)
{
    mMaxCharacter2DCount = count;
}

void KRGameManager::setScreenSize(int width, int height)
{
#if KR_IPHONE
    
    int longSide = 480;
    int shortSide = 320;
    
#if !KR_IPHONE_MACOSX_EMU
    CGRect bounds = [[UIScreen mainScreen] bounds];
    longSide = bounds.size.height;
    shortSide = bounds.size.width;
#endif

    if (width > height) {
        width = longSide;
        height = shortSide;
    } else {
        width = shortSide;
        height = longSide;
    }
#endif
    mScreenWidth = width;
    mScreenHeight = height;
    gKRScreenSize.x = width;
    gKRScreenSize.y = height;
}

void KRGameManager::startWorldChanging()
{
    mWasChangingWorld = true;
}

void KRGameManager::cleanUpGame()
{
    delete mWorldManager;
    mWorldManager = NULL;
}

void KRGameManager::updateModel(KRInput *input)
{
    sIsUpdatingModel = YES;

    KRWorld* currentWorld = mWorldManager->getCurrentWorld();
    if (currentWorld != NULL) {
        currentWorld->startUpdateModel(input);
    }

    sIsUpdatingModel = NO;
}

void KRGameManager::drawView(KRGraphics* g)
{
    KRWorld *currentWorld = mWorldManager->getCurrentWorld();
    if (currentWorld != NULL) {
        currentWorld->startDrawView(g);
    }    
}

void KRGameManager::addWorld(const std::string& name, KRWorld *aWorld)
{
    mWorldManager->registerWorld(name, aWorld);
}

KRWorld* KRGameManager::getWorld(const std::string& name) const
{
    return mWorldManager->getWorldWithName(name);
}

KRWorld* KRGameManager::getCurrentWorld() const
{
    return mWorldManager->getCurrentWorld();
}

void KRGameManager::changeWorld(const std::string& name)
{
    changeWorldImpl(name, true);
}

void KRGameManager::changeWorldImpl(const std::string& name, bool useLoadingThread, bool isFirstInitialization)
{
    if (!isFirstInitialization && useLoadingThread && !sIsUpdatingModel) {
        const char *errorFormat = "Invalid world changing was performed. changeWorld() cannot be invoked outside updateModel().";
        if (gKRLanguage == KRLanguageJapanese) {
            errorFormat = "不正なワールド変更処理が行われました。changeWorld() 関数は、updateModel() の中以外では呼び出せません。";
        }
        throw KRRuntimeError(errorFormat);
    }
    if (mWorldManager->selectWorldWithName(name, useLoadingThread) == NULL) {
        const char *errorFormat = "Failed to find the world named \"%s\".";
        if (gKRLanguage == KRLanguageJapanese) {
            errorFormat = "\"%s\" という名前のワールドは見つかりませんでした。";
        }
        throw KRRuntimeError(errorFormat, name.c_str());
    }
}

std::string KRGameManager::getGameIDForNetwork() const
{
    return mGameIDForNetwork;
}

std::string KRGameManager::getNetworkStartWorldName() const
{
    return mNetworkStartWorldName;
}

void KRGameManager::setNetworkGameID(const std::string& gameID, const std::string& startWorldName)
{
    mGameIDForNetwork = gameID;
    mNetworkStartWorldName = startWorldName;
}

void KRGameManager::saveForEmergency() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
{
    KRWorld *currentWorld = mWorldManager->getCurrentWorld();
    if (currentWorld != NULL) {
        currentWorld->saveForEmergency(gKRSaveBoxInst);
        gKRSaveBoxInst->save();
    }    
}

void KRGameManager::checkDeviceType() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
{
#if KR_MACOSX
    mDeviceType = KRDeviceTypeMac;
#else
    if (gKRScreenSize.x >= 768) {
        mDeviceType = KRDeviceTypeIPad;
    } else {
        mDeviceType = KRDeviceTypeIPhone;
    }
#endif
}

void KRGameManager::exitGame()
{
    throw KRGameExitError();
}

KRAudioMixType KRGameManager::getAudioMixType() const
{
    return mAudioMixType;
}

void KRGameManager::setAudioMixType(KRAudioMixType type)
{
    mAudioMixType = type;
}

std::string KRGameManager::to_s() const
{
    std::string ret = "<game>(title=\"" + mTitle + "\", ";
    ret += KRFS("screen_size=(%d, %d), frame_rate=%3.2f)", mScreenWidth, mScreenHeight, mFrameRate);
    return ret;
}


