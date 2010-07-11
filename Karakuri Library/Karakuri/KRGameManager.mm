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
#include "KRParticle2DSystem.h"
#import "BXResourceImporter.h"

#import "KRGameController.h"

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
    
    mMaxChara2DCount = 1024;
    mMaxChara2DSize = sizeof(KRChara2D);
    updateMaxChara2DSize(sizeof(_KRParticle2D));

    mGameIDForNetwork = "";

    mWasChangingWorld = false;
    
    mWorldManager = new KRWorldManager();
}

KRGameManager::~KRGameManager()
{
    // Do nothing
}


#pragma mark -
#pragma mark ゲーム実行に関する関数

void KRGameManager::exitGame()
{
    throw KRGameExitError();
}

double KRGameManager::getCurrentTime()
{
    return (double)[NSDate timeIntervalSinceReferenceDate];
}

double KRGameManager::getFrameRate() const
{
    return mFrameRate;
}

void KRGameManager::setFrameRate(double value)
{
    if (value <= 0.0) {
        const char *errorFormat = "Invalid frame rate %3.1f was set.";
        if (gKRLanguage == KRLanguageJapanese) {
            errorFormat = "不正なフレームレート %3.1f を設定しようとしました。";
        }        
        throw KRRuntimeError(errorFormat, value);
    }

    mFrameRate = value;

    if ([[KRGameController sharedController] isGameInitialized]) {
        [[KRGameController sharedController] updateFrameRateSetting];
    }
}

void KRGameManager::sleep(double interval)
{
    [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:interval]];
}


#pragma mark -
#pragma mark ワールドに関する関数

void KRGameManager::addWorld(const std::string& name, KRWorld *aWorld)
{
    mWorldManager->registerWorld(name, aWorld);
}

void KRGameManager::changeWorld(const std::string& name)
{
    _changeWorldImpl(name, true);
}

void KRGameManager::_changeWorldImpl(const std::string& name, bool useLoadingThread, bool isFirstInitialization)
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

KRWorld* KRGameManager::getCurrentWorld() const
{
    return mWorldManager->getCurrentWorld();
}

KRWorld* KRGameManager::getWorld(const std::string& name) const
{
    return mWorldManager->getWorldWithName(name);
}


#pragma mark -
#pragma mark ゲームのセットアップ

void KRGameManager::setupResources()
{
    // Do nothing
}

void KRGameManager::loadResourceGroup(int groupID)
{
    gKRTex2DMan->_loadTextureFiles(groupID, NULL, 0.0);
    gKRAudioMan->_loadAudioFiles(groupID, NULL, 0.0);
}


#pragma mark -
#pragma mark ゲームの各種設定

void KRGameManager::addResources(const std::string& filename)
{
    NSString* filenameStr = [NSString stringWithCString:filename.c_str() encoding:NSUTF8StringEncoding];
    
    BXResourceImporter* importer = [[BXResourceImporter alloc] initWithFileName:filenameStr];
    if (!importer) {
        const char *errorFormat = "Failed to load a Karakuri resource file \"%s\".";
        if (gKRLanguage == KRLanguageJapanese) {
            errorFormat = "Karakuri リソースファイル \"%s\" の読み込みに失敗しました。";
        }
        throw KRRuntimeError(errorFormat, filename.c_str());
    }

    [importer importPrimitiveResources];
    [importer importRichResources];

    [importer release];
}

std::string KRGameManager::getTitle() const
{
    return mTitle;
}

void KRGameManager::setTitle(const std::string& str)
{
    mTitle = str;
}

bool KRGameManager::_checkDeviceType(KRDeviceType type) const
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

int KRGameManager::getMaxChara2DCount() const
{
    return mMaxChara2DCount;
}

void KRGameManager::setMaxChara2DCount(int count)
{
    mMaxChara2DCount = count;
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

size_t KRGameManager::getMaxChara2DSize() const
{
    return mMaxChara2DSize;
}

void KRGameManager::updateMaxChara2DSize(size_t size)
{
    if (mMaxChara2DSize < size) {
        mMaxChara2DSize = size;
    }
}

void KRGameManager::_startWorldChanging()
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

void KRGameManager::_saveForEmergency() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
{
    KRWorld *currentWorld = mWorldManager->getCurrentWorld();
    if (currentWorld != NULL) {
        currentWorld->saveForEmergency(gKRSaveBoxInst);
        gKRSaveBoxInst->save();
    }    
}

void KRGameManager::_checkDeviceType() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
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

KRAudioMixType KRGameManager::getAudioMixType() const
{
    return mAudioMixType;
}

void KRGameManager::setAudioMixType(KRAudioMixType type)
{
    mAudioMixType = type;
}


#pragma mark -
#pragma mark デバッグサポート

std::string KRGameManager::to_s() const
{
    std::string ret = "<game>(title=\"" + mTitle + "\", ";
    ret += KRFS("screen_size=(%d, %d), frame_rate=%3.2f)", mScreenWidth, mScreenHeight, mFrameRate);
    return ret;
}


