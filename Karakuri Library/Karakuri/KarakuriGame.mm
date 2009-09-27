//
//  KarakuriGame.mm
//  Karakuri Prototype
//
//  Created by numata on 09/07/17.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#include "KarakuriGame.h"
#include "KarakuriWorld.h"


KRGame      *gKRGameInst = NULL;
KRVector2D  gKRScreenSize;

static BOOL sIsUpdatingModel = NO;


KRGame::KRGame()
    : mTitle("Karakuri Game"), mFrameRate(60.0f), mScreenWidth(480), mScreenHeight(320),
      mAudioMixType(KRAudioMixTypeAmbientSolo), mShowsMouseCursor(false), mShowsFPS(false),
      mGameIDForNetwork("")
{
    gKRGameInst = this;
    
    mWasChangingWorld = false;
    
    mWorldManager = new KarakuriWorldManager();
}

std::string KRGame::getTitle() const
{
    return mTitle;
}

void KRGame::setTitle(const std::string& str)
{
    mTitle = str;
}

float KRGame::getFrameRate() const
{
    return mFrameRate;
}

void KRGame::setFrameRate(float value)
{
    mFrameRate = value;
}

int KRGame::getScreenWidth() const
{
    return mScreenWidth;
}

int KRGame::getScreenHeight() const
{
    return mScreenHeight;
}

KRVector2D KRGame::getScreenSize() const
{
    return KRVector2D(mScreenWidth, mScreenHeight);
}

bool KRGame::getShowsMouseCursor() const
{
    return mShowsMouseCursor;
}

void KRGame::setShowsMouseCursor(bool flag)
{
    mShowsMouseCursor = flag;
}

bool KRGame::getShowsFPS() const
{
    return mShowsFPS;
}

void KRGame::setShowsFPS(bool flag)
{
    mShowsFPS = flag;
}

void KRGame::setScreenSize(int width, int height)
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
    gKRScreenSize.x = width;
    gKRScreenSize.y = height;
}

void KRGame::startWorldChanging()
{
    mWasChangingWorld = true;
}

void KRGame::cleanUpGame()
{
    delete mWorldManager;
    mWorldManager = NULL;
}

void KRGame::updateModel(KRInput *input)
{
    sIsUpdatingModel = YES;

    KRWorld *currentWorld = mWorldManager->getCurrentWorld();
    if (currentWorld != NULL) {
        currentWorld->startUpdateModel(input);
    }

    sIsUpdatingModel = NO;
}

void KRGame::drawView(KRGraphics *g)
{
    KRWorld *currentWorld = mWorldManager->getCurrentWorld();
    if (currentWorld != NULL) {
        currentWorld->startDrawView(g);
    }    
}

void KRGame::addWorld(const std::string& name, KRWorld *aWorld)
{
    mWorldManager->registerWorld(name, aWorld);
}

KRWorld *KRGame::getWorld(const std::string& name) const
{
    return mWorldManager->getWorldWithName(name);
}

KRWorld *KRGame::getCurrentWorld() const
{
    return mWorldManager->getCurrentWorld();
}

void KRGame::changeWorld(const std::string& name)
{
    changeWorldImpl(name, true);
}

void KRGame::changeWorldImpl(const std::string& name, bool useLoadingThread, bool isFirstInitialization)
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

std::string KRGame::getGameIDForNetwork() const
{
    return mGameIDForNetwork;
}

std::string KRGame::getNetworkStartWorldName() const
{
    return mNetworkStartWorldName;
}

void KRGame::setNetworkGameID(const std::string& gameID, const std::string& startWorldName)
{
    mGameIDForNetwork = gameID;
    mNetworkStartWorldName = startWorldName;
}

void KRGame::saveForEmergency() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
{
    KRWorld *currentWorld = mWorldManager->getCurrentWorld();
    if (currentWorld != NULL) {
        currentWorld->saveForEmergency(KRSaveBoxInst);
        KRSaveBoxInst->save();
    }    
}

void KRGame::exitGame()
{
    throw KRGameExitError();
}

KRAudioMixType KRGame::getAudioMixType() const
{
    return mAudioMixType;
}

void KRGame::setAudioMixType(KRAudioMixType type)
{
    mAudioMixType = type;
}

std::string KRGame::to_s() const
{
    std::string ret = "<game>(title=\"" + mTitle + "\", ";
    ret += KRFS("screen_size=(%d, %d), frame_rate=%3.2f)", mScreenWidth, mScreenHeight, mFrameRate);
    return ret;
}


