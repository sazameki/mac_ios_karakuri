//
//  KarakuriGame.mm
//  Karakuri Prototype
//
//  Created by numata on 09/07/17.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#include "KarakuriGame.h"
#include "KarakuriWorld.h"


KarakuriGame    *KRGame = NULL;
KRVector2D      KRScreenSize;

static BOOL sIsUpdatingModel = NO;


KarakuriGame::KarakuriGame()
    : mTitle("Karakuri Game"), mFrameRate(60.0f), mScreenWidth(480), mScreenHeight(320),
      mAudioMixType(KRAudioMixTypeAmbientSolo), mShowsMouseCursor(false), mShowsFPS(false),
      mGameIDForNetwork("")
{
    KRGame = this;
    
    mWasChangingWorld = false;
    
    mWorldManager = new KarakuriWorldManager();
}

std::string KarakuriGame::getTitle() const
{
    return mTitle;
}

void KarakuriGame::setTitle(const std::string& str)
{
    mTitle = str;
}

float KarakuriGame::getFrameRate() const
{
    return mFrameRate;
}

void KarakuriGame::setFrameRate(float value)
{
    mFrameRate = value;
}

int KarakuriGame::getScreenWidth() const
{
    return mScreenWidth;
}

int KarakuriGame::getScreenHeight() const
{
    return mScreenHeight;
}

KRVector2D KarakuriGame::getScreenSize() const
{
    return KRVector2D(mScreenWidth, mScreenHeight);
}

bool KarakuriGame::getShowsMouseCursor() const
{
    return mShowsMouseCursor;
}

void KarakuriGame::setShowsMouseCursor(bool flag)
{
    mShowsMouseCursor = flag;
}

bool KarakuriGame::getShowsFPS() const
{
    return mShowsFPS;
}

void KarakuriGame::setShowsFPS(bool flag)
{
    mShowsFPS = flag;
}

void KarakuriGame::setScreenSize(int width, int height)
{
#if KR_IPHONE
    if (width > height) {
        width = 480;
        height = 320;
    } else {
        width = 320;
        height = 480;
    }
#endif
    mScreenWidth = width;
    mScreenHeight = height;
    KRScreenSize.x = width;
    KRScreenSize.y = height;
}

void KarakuriGame::startWorldChanging()
{
    mWasChangingWorld = true;
}

void KarakuriGame::cleanUpGame()
{
    delete mWorldManager;
    mWorldManager = NULL;
}

void KarakuriGame::updateModel(KRInput *input)
{
    sIsUpdatingModel = YES;

    KarakuriWorld *currentWorld = mWorldManager->getCurrentWorld();
    if (currentWorld != NULL) {
        currentWorld->startUpdateModel(input);
    }

    sIsUpdatingModel = NO;
}

void KarakuriGame::drawView(KRGraphics *g)
{
    KarakuriWorld *currentWorld = mWorldManager->getCurrentWorld();
    if (currentWorld != NULL) {
        currentWorld->startDrawView(g);
    }    
}

void KarakuriGame::addWorld(const std::string& name, KarakuriWorld *aWorld)
{
    mWorldManager->registerWorld(name, aWorld);
}

KarakuriWorld *KarakuriGame::getWorld(const std::string& name) const
{
    return mWorldManager->getWorldWithName(name);
}

KarakuriWorld *KarakuriGame::getCurrentWorld() const
{
    return mWorldManager->getCurrentWorld();
}

void KarakuriGame::changeWorld(const std::string& name)
{
    changeWorldImpl(name, true);
}

void KarakuriGame::changeWorldImpl(const std::string& name, bool useLoadingThread, bool isFirstInitialization)
{
    if (!isFirstInitialization && useLoadingThread && !sIsUpdatingModel) {
        const char *errorFormat = "Invalid world changing was performed. changeWorld() cannot be invoked outside updateModel().";
        if (KRLanguage == KRLanguageJapanese) {
            errorFormat = "不正なワールド変更処理が行われました。changeWorld() 関数は、updateModel() の中以外では呼び出せません。";
        }
        throw KRRuntimeError(errorFormat);
    }
    if (mWorldManager->selectWorldWithName(name, useLoadingThread) == NULL) {
        const char *errorFormat = "Failed to find the world named \"%s\".";
        if (KRLanguage == KRLanguageJapanese) {
            errorFormat = "\"%s\" という名前のワールドは見つかりませんでした。";
        }
        throw KRRuntimeError(errorFormat, name.c_str());
    }
}

std::string KarakuriGame::getGameIDForNetwork() const
{
    return mGameIDForNetwork;
}

std::string KarakuriGame::getNetworkStartWorldName() const
{
    return mNetworkStartWorldName;
}

void KarakuriGame::setNetworkGameID(const std::string& gameID, const std::string& startWorldName)
{
    mGameIDForNetwork = gameID;
    mNetworkStartWorldName = startWorldName;
}

void KarakuriGame::saveForEmergency() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
{
    KarakuriWorld *currentWorld = mWorldManager->getCurrentWorld();
    if (currentWorld != NULL) {
        currentWorld->saveForEmergency(KRSaveBoxInst);
        KRSaveBoxInst->save();
    }    
}

void KarakuriGame::exitGame()
{
    throw KRGameExitError();
}

KRAudioMixType KarakuriGame::getAudioMixType() const
{
    return mAudioMixType;
}

void KarakuriGame::setAudioMixType(KRAudioMixType type)
{
    mAudioMixType = type;
}

std::string KarakuriGame::to_s() const
{
    std::string ret = "<game>(title=\"" + mTitle + "\", ";
    ret += KRFS("screen_size=(%d, %d), frame_rate=%3.2f)", mScreenWidth, mScreenHeight, mFrameRate);
    return ret;
}


