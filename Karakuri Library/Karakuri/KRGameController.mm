//
//  KRGameController.mm
//  Karakuri Prototype
//
//  Created by numata on 09/07/17.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import "KRGameController.h"

#import "KarakuriLibraryConnector.h"

#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
#import "KarakuriMenu.h"
#endif

#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
#import <AVFoundation/AVFoundation.h>
#endif

#include <mach/mach.h>
#include <mach/mach_time.h>
#include <sys/time.h>
#include <ctime>
#include <cstdlib>

#import "KarakuriSound.h"
#import "KRSaveBox.h"
#import "KarakuriFunctions.h"
#import "KRWorld.h"
#import "KRRandom.h"
#import "KRSimulator2D.h"
#import "KRControlManager.h"


#define KRMaxFrameSkipCount     5


static KRGameController *sInstance = nil;


#if __DEBUG__
inline double gettimeofday_sec()
{
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return tv.tv_sec + (double)tv.tv_usec*1e-6;
}
#endif


/*!
 @function   ConvertNanoSecToMachTime
 @abstract   ナノ秒単位を Mach 時間に変換します。
 @param      nanoSec 変換する時間（ナノ秒単位）
 @result     nanoSec を Mach 時間に変換した64ビット値
 */
static inline uint64_t ConvertNanoSecToMachTime(uint64_t nanoSec) {
    mach_timebase_info_data_t timebaseInfo;
    mach_timebase_info(&timebaseInfo);
    return nanoSec * timebaseInfo.denom / timebaseInfo.numer;
}


@interface KRGameController (Private)

- (void)setupApplication;

@end


@implementation KRGameController

+ (KRGameController *)sharedController
{
    return sInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        sInstance = self;
        
        mLastErrorMessage = NULL;
        
        mLoadingWorld = NULL;
        mIsWorldLoading = NO;

        mGameIsInitialized = NO;
        mGameIsAborted = NO;

        mHasMetEmergency = NO;
        mTerminatedByUser = NO;
        
        mNetworkServer = nil;
        mIsInvitingNetworkPeer = NO;

        mLibraryConnector = [KarakuriLibraryConnector new];
        
        NSString *currentLangCode = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
        if ([currentLangCode isEqualToString:@"ja"]) {
            gKRLanguage = KRLanguageJapanese;            
        }
        
        KRSetupSaveBox();

        mGame = [mLibraryConnector createGameInstance];
        mGraphics = new KRGraphics();
        mInput = new KRInput();
        mCharacterAnime = new KRAnime2D();
        
        mMCFrameInterval = ConvertNanoSecToMachTime((uint64_t)(1000000000 / mGame->getFrameRate()));
        
#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
        mGameIsChaningScreenMode = NO;
#endif

#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
        mEAGLSharegroup = [EAGLSharegroup new];
#endif
        
#if __DEBUG__
        mFPSDisplay = NULL;
        mDebugControlManager = NULL;
        mCurrentFPS = 60.0;
        mFrameCount = 0;
        for (int i = 0; i < KR_FRAME_COUNT_HISTORY_SIZE; i++) {
            mFrameCounts[i] = 60;
        }
        for (int i = 0; i < KR_TEXTURE_CHANGE_COUNT_HISTORY_SIZE; i++) {
            mTextureChangeCounts[i] = 1;
        }
        mFrameCountPos = 0;

        mCurrentTPF = 1.0;
        mTextureChangeCountPos = 0;

        mCurrentBPF = 1.0;
        mTextureBatchProcessCountPos = 0;
#endif
        
        [self setupApplication];
    }
    return self;
}

- (void)cleanUpResources
{
    if (!mWindow) {
        return;
    }
    
    if (mNetworkServer != NULL) {
        delete mNetworkServer;
    }

    [mWindow release];
    mWindow = nil;
    
    [mLibraryConnector release];
    
    delete mGraphics;
    delete mGame;
    delete mInput;
    delete mCharacterAnime;
    
#if __DEBUG__
    if (mFPSDisplay != NULL) {
        delete mFPSDisplay;
    }
#endif
    
#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
    [mEAGLSharegroup release];
#endif
    
    KRCleanUpOpenAL();
    KRCleanUpSaveBox();
}

- (void)dealloc
{
    [self cleanUpResources];

    [super dealloc];
}


#pragma mark -

#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
- (EAGLSharegroup *)eaglSharegroup
{
    return mEAGLSharegroup;
}
#endif

- (void)setupApplication
{
#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
    NSApplication *app = [NSApplication sharedApplication];
    [app setDelegate:self];
    
    KarakuriMenu *menu = [[KarakuriMenu new] autorelease];
    [app setMainMenu:menu];
    [menu setupMenuItems];
    
    mWindow = [KarakuriWindow new];
    
    NSString *appName = [NSString stringWithCString:mGame->getTitle().c_str() encoding:NSUTF8StringEncoding];
    [mWindow setTitle:appName];
    [mWindow center];
#endif
    
    KRInitOpenAL();
    KRSimulator2D::initSimulatorSystem();
}

- (void)checkOpenGLVersion
{
    const GLubyte *verStr = glGetString(GL_VERSION);
    _KROpenGLVersionStr += (const char *)verStr;
    
    std::string first3 = _KROpenGLVersionStr.substr(0, 3);
    
    _KROpenGLVersionValue = atof(first3.c_str());
}

- (void)startChaningWorld:(KRWorld *)world
{
    mIsWorldLoading = YES;
    mLoadingWorld = world;
}

- (void)setKRGLContext:(KarakuriGLContext *)context
{
    mKRGLContext = context;
}

- (void)setupGLOptions
{
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    //glEnable(GL_TEXTURE_2D);
    //glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glShadeModel(GL_SMOOTH);
    
    //glEnable(GL_DEPTH_TEST);
    //glDepthFunc(GL_LEQUAL);

#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
    // Set up VSYNC (Not needed at most of the case. So we disable this option at now.)
    //long sync = 1;
    //CGLSetParameter(mKRGLContext->cglContext, kCGLCPSwapInterval, (GLint *)&sync);
#endif
}

- (KRGame *)game
{
    return mGame;
}

#if __DEBUG__
- (void)addDebugString:(const std::string&)str
{
    mDebugControlManager->scrollUpAllDebugLabels();

    timeval tp;
    gettimeofday(&tp, NULL);
    
    time_t theTime = time(NULL);
    tm *date = localtime(&theTime);
    
    static char dateBuffer[16];
    strftime(dateBuffer, 15, "%H:%M:%S", date);
    
    KRLabel *aLabel = new KRLabel(KRRect2D(10, 1, gKRScreenSize.x-10*2, 20));
    aLabel->setFont("Courier", 12.0);
    aLabel->setTextColor(KRColor::White);
    aLabel->setTextShadowColor(KRColor::Black);
    aLabel->setHasTextShadow(true);
    aLabel->setText(KRFS("[%s.%02d] %s", dateBuffer, tp.tv_usec / 10000, str.c_str()));
    mDebugControlManager->addControl(aLabel, 0);
}

- (void)removeDebugStrings
{
    mDebugControlManager->removeAllControls();
}
#endif


#pragma mark -
#pragma mark Network Invitation Acceptance

- (void)startNetworkServer
{
    std::string gameID = mGame->getGameIDForNetwork();
    mNetworkServer = new KRNetwork(gameID);
}

- (void)processNetworkRequest:(NSString *)name
{
    mNetworkPeerName = [name retain];
    
    NSString *title = @"Network Play Invitation";
    NSString *acceptLabel = @"Accept";
    NSString *rejectLabel = @"Reject";
    NSString *messageFormat = @"%@ is inviting you to join a new game. Do you want to accept the invitation?";
    
    if (gKRLanguage == KRLanguageJapanese) {
        title = @"ネットワーク・プレイの招待";
        acceptLabel = @"招待を受ける";
        rejectLabel = @"拒否する";
        messageFormat = @"%@ さんから招待が来ています。招待を受けますか？";
    }
    
    NSString *message = [NSString stringWithFormat:messageFormat, mNetworkPeerName];
    
#if KR_MACOSX || KR_IPHONE_MACOSX_EMU    
    NSBeginAlertSheet(title,
                      acceptLabel,
                      rejectLabel,
                      nil,
                      mWindow,
                      self, @selector(networkInvitationSheetDidEnd:returnCode:contextInfo:), nil, nil,
                      message, nil);
#endif  // #if KR_MACOSX || KR_IPHONE_MACOSX_EMU
    
#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
    mNetworkAcceptAlertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:rejectLabel
                                              otherButtonTitles:acceptLabel, nil];
    [mNetworkAcceptAlertView show];
    [mNetworkAcceptAlertView release];
#endif  // #if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
}

#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
- (void)networkInvitationSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
    if (returnCode == NSAlertDefaultReturn) {
        mHasAcceptedNetworkPeer = YES;
        gKRNetworkInst->doAccept();
    } else {
        mHasAcceptedNetworkPeer = NO;
        gKRNetworkInst->doReject();
    }
    mNetworkPeerName = nil;
}
#endif

#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == mErrorAlertView) {
        exit(9999);
    }
    else if (alertView == mNetworkAcceptAlertView) {
        if (buttonIndex == 1) {
            mHasAcceptedNetworkPeer = YES;
            gKRNetworkInst->doAccept();
        } else {
            mHasAcceptedNetworkPeer = NO;
            gKRNetworkInst->doReject();
        }
        mNetworkPeerName = nil;
        mNetworkAcceptAlertView = nil;
    }
}
#endif  // #if KR_IPHONE && !KR_IPHONE_MACOSX_EMU


#pragma mark -
#pragma mark Network Peer Picker

- (void)showNetworkPeerPicker
{
    mIsInvitingNetworkPeer = YES;

#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
    mPeerPickerWindow = [[KRPeerPickerWindow alloc] initWithMainWindow:mWindow];
    [mPeerPickerWindow setDelegate:self];
    [mPeerPickerWindow makeKeyAndOrderFront:self];
#endif
    
#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU    
    mPeerPickerController = [KRPeerPickerController new];
    mPeerPickerController.delegate = self;
    
    BOOL isHorizontal = (gKRScreenSize.x > gKRScreenSize.y);
    
    if (isHorizontal) {
        mPeerPickerController.view.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI_2);
        mPeerPickerController.view.frame = CGRectMake(-320, 0, 320, 480);
    } else {
        mPeerPickerController.view.frame = CGRectMake(0, 480, 320, 480);
    }

    [gKRWindowInst addSubview:mPeerPickerController.view];
    
    [UIView beginAnimations:@"Picker In" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    if (isHorizontal) {
        mPeerPickerController.view.frame = CGRectMake(0, 0, 320, 480);
    } else {
        mPeerPickerController.view.frame = CGRectMake(0, 0, 320, 480);
    }
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
    [UIView commitAnimations];
#endif
}

#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
- (void)peerPickerCanceled:(KRPeerPickerWindow *)pickerWindow
{
    mPeerPickerWindow = nil;
    mIsInvitingNetworkPeer = NO;
}

- (void)peerPickerAccepted:(KRPeerPickerWindow *)pickerWindow
{
    mHasAcceptedNetworkPeer = YES;
    mPeerPickerWindow = nil;
    mIsInvitingNetworkPeer = NO;
}

- (void)peerPickerDenied:(KRPeerPickerWindow *)pickerWindow
{
    mHasAcceptedNetworkPeer = NO;
    mPeerPickerWindow = nil;
    mIsInvitingNetworkPeer = NO;
}
#endif

#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
- (void)peerPickerCanceled:(KRPeerPickerController *)pickerController
{
    [UIView beginAnimations:@"Picker Out" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    if (gKRScreenSize.x > gKRScreenSize.y) {
        mPeerPickerController.view.frame = CGRectMake(-320, 0, 320, 480);
    } else {
        mPeerPickerController.view.frame = CGRectMake(0, 480, 320, 480);
    }
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(pickerOutAnimationFinished:finished:context:)];
    [UIView commitAnimations];
}
- (void)peerPickerAccepted:(KRPeerPickerController *)pickerController
{
    mHasAcceptedNetworkPeer = YES;

    [UIView beginAnimations:@"Picker Out" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    mPeerPickerController.view.alpha = 0.0;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(pickerOutAnimationFinished:finished:context:)];
    [UIView commitAnimations];
}
- (void)peerPickerDenied:(KRPeerPickerController *)pickerController
{
    mHasAcceptedNetworkPeer = YES;
    
    [UIView beginAnimations:@"Picker Out" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    if (gKRScreenSize.x > gKRScreenSize.y) {
        mPeerPickerController.view.frame = CGRectMake(-320, 0, 320, 480);
    } else {
        mPeerPickerController.view.frame = CGRectMake(0, 480, 320, 480);
    }
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(pickerOutAnimationFinished:finished:context:)];
    [UIView commitAnimations];
}
- (void)pickerOutAnimationFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
    [mPeerPickerController.view removeFromSuperview];
    [mPeerPickerController release];
    mPeerPickerController = nil;
    mIsInvitingNetworkPeer = NO;
}
#endif


#pragma mark -
#pragma mark NSApplication Delegation

#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [mWindow makeKeyAndOrderFront:self];
    
    [self checkOpenGLVersion];
    [self startNetworkServer];
    
    [NSThread detachNewThreadSelector:@selector(gameThreadProc:) toTarget:self withObject:nil];
}
#endif

#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
- (IBAction)openAboutPanel:(id)sender
{
    [NSApp orderFrontStandardAboutPanel:self];
}
#endif

#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
- (void)terminate:(id)sender
{
    [mWindow orderOut:self];
}

- (void)minimizeWindow:(id)sender
{
    [mWindow miniaturize:self];
}

- (void)windowWillClose:(NSNotification *)notification
{
    if (mPeerPickerWindow) {
        [mPeerPickerWindow cancelPeerPicker:self];
    }
    if (!mTerminatedByUser) {
        mHasMetEmergency = YES;
    }
    mGameIsRunning = NO;
    while (!mGameIsFinished) {
        [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
#if KR_IPHONE_MACOSX_EMU
    [gKRWindowInst cleanUpSMS];
#endif
}
#endif

#if KR_MACOSX
- (void)toggleFullScreen:(id)sender
{
    mGameIsChaningScreenMode = YES;
    while (mGameIsRunning) {
        [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    _KRTexture2DEnabled = false;
    _KRTexture2DName = GL_INVALID_VALUE;
    _KRColorRed = _KRColorGreen = _KRColorBlue = _KRColorAlpha = -1.0;
    _KRClearColorRed = _KRClearColorGreen = _KRClearColorBlue = _KRClearColorAlpha = -1.0;

    [gKRGLViewInst toggleFullScreen];

    _KRTexture2DEnabled = false;
    _KRTexture2DName = GL_INVALID_VALUE;
    _KRColorRed = _KRColorGreen = _KRColorBlue = _KRColorAlpha = -1.0;
    _KRClearColorRed = _KRClearColorGreen = _KRClearColorBlue = _KRClearColorAlpha = -1.0;

    if (!mGameIsFinished) {
        if (mGameIsAborted) {
            [gKRGLViewInst clearMouseTrackingRect];
            CGDisplayShowCursor(kCGDirectMainDisplay);
            NSBeep();
            
            NSString *alertTitle = @"Karakuri Runtime Error";
            if (gKRLanguage == KRLanguageJapanese) {
                alertTitle = @"Karakuri ランタイムエラー";
            }
            NSString *message = [NSString stringWithCString:mLastErrorMessage->c_str() encoding:NSUTF8StringEncoding];
            std::cerr << "[Karakuri Runtime Error] " << *mLastErrorMessage << std::endl;
            
            NSBeginCriticalAlertSheet(alertTitle,
                                      @"OK",
                                      nil,
                                      nil,
                                      mWindow,
                                      self,
                                      @selector(didEndGameAbortMessageSelector),
                                      nil,
                                      nil,
                                      message);
            
            delete mLastErrorMessage;
            mLastErrorMessage = NULL;
        } else {
            [NSThread detachNewThreadSelector:@selector(gameThreadProc:) toTarget:self withObject:nil];
        }
    } else {
        [self terminate:self];
    }
}
#endif


#pragma mark -
#pragma mark UIApplication Delegation

#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    if (gKRScreenSize.x > gKRScreenSize.y) {
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
    }

    mWindow = [KarakuriWindow new];
    [mWindow makeKeyAndVisible];
    
    [self checkOpenGLVersion];
    [self startNetworkServer];

    [NSThread detachNewThreadSelector:@selector(gameThreadProc:) toTarget:self withObject:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    mHasMetEmergency = YES;
    mGameIsRunning = NO;

    while (!mGameIsFinished) {
        [NSThread sleepForTimeInterval:0.1];
    }

    [self cleanUpResources];
}
#endif


#pragma mark -

- (void)worldLoadingProc:(id)dummy
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    
#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
    CGLContextObj cglContext = (mKRGLContext->isFullScreen)? mKRGLContext->cglFullScreenContext: mKRGLContext->cglContext;
    CGLSetCurrentContext(cglContext);
#endif
    
#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
    [EAGLContext setCurrentContext:mKRGLContext->eaglContext];
#endif
    
    try {
        mLoadingWorld->startBecameActive();
    } catch (KRRuntimeError& e) {
        mLastErrorMessage = new std::string(e.what());
    }

    mIsWorldLoading = NO;
    
    [pool release];
}

- (void)gameThreadProc:(id)dummy
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];

    [gKRGLViewInst waitForReady];
    
    mGameIsRunning = YES;
    mGameIsFinished = NO;

#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
    mGameIsChaningScreenMode = NO;
#endif
    
#if __DEBUG__
    if (mDebugControlManager == NULL) {
        mDebugControlManager = new KRControlManager();
    }
#endif
    
    try {
#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
        CGLContextObj cglContext = (mKRGLContext->isFullScreen)? mKRGLContext->cglFullScreenContext: mKRGLContext->cglContext;
        
        CGLLockContext(cglContext);
        CGLSetCurrentContext(cglContext);
#endif
        
#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
        [EAGLContext setCurrentContext:mKRGLContext->eaglContext];
#endif
        
#if __DEBUG__
        if (mFPSDisplay == NULL && mGame->getShowsFPS()) {
            mFPSDisplay = new KRFPSDisplay();
        }
        mPrevFPSUpdateTime = gettimeofday_sec();
        mFrameCount = 0;
#endif
        
        [self setupGLOptions];

        if (!mGameIsInitialized) {
            std::string firstWorldName = mGame->setupWorlds();
            mGame->changeWorldImpl(firstWorldName, true, true);
            if (mLoadingWorld != NULL) {
                std::string loadingScreenWorldName = mLoadingWorld->getLoadingScreenWorldName();
                if (loadingScreenWorldName.length() > 0) {
                    mLoadingScreenWorld = mGame->getWorld(loadingScreenWorldName);
                    if (mLoadingScreenWorld == NULL) {
                        if (gKRLanguage == KRLanguageJapanese) {
                            std::string errorFormat = "\"" + mLoadingWorld->getName() + "\" ワールドのための読み込み画面用ワールド \"" + loadingScreenWorldName + "\" は見つかりませんでした。";
                            throw KRRuntimeError(errorFormat);
                        } else {
                            std::string errorFormat = "World \"" + loadingScreenWorldName + "\" was not found for loading screen at \"" + mLoadingWorld->getName() + "\" world.";
                            throw KRRuntimeError(errorFormat);
                        }
                    }
                    mLoadingScreenWorld->setLoadingWorld();
                    mLoadingScreenWorld->startBecameActive();
                    [NSThread detachNewThreadSelector:@selector(worldLoadingProc:) toTarget:self withObject:nil];
                } else {
                    mLoadingWorld->startBecameActive();
                    mLoadingWorld = NULL;
                    mIsWorldLoading = NO;
                }
            }
            mGameIsInitialized = YES;
        }
        
#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
        CGLUnlockContext(cglContext);
#endif    

        uint64_t mcPrevTime = mach_absolute_time();     // End time of the previous loop (Mach time)

        while (mGameIsRunning) {
            // Set up the OpenGL context
#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
            CGLLockContext(cglContext);
            CGLSetCurrentContext(cglContext);
#endif
#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
            [EAGLContext setCurrentContext:mKRGLContext->eaglContext];
            glBindFramebufferOES(GL_FRAMEBUFFER_OES, mKRGLContext->viewFramebuffer);
#endif

            // Set the view port
            glViewport(0, 0, mKRGLContext->backingWidth, mKRGLContext->backingHeight);

            glMatrixMode(GL_PROJECTION);
            glLoadIdentity();

#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
            glOrtho(0.0, (double)mKRGLContext->backingWidth, 0.0, (double)mKRGLContext->backingHeight, -1.0, 1.0);
#endif
#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
            glOrthof(0.0f, (float)mKRGLContext->backingWidth, 0.0f, (float)mKRGLContext->backingHeight, -1.0f, 1.0f);
            // If Horizontal
            if (mGame->getScreenWidth() > mGame->getScreenHeight()) {
                glTranslatef(0.0f, (float)(mKRGLContext->backingHeight), 0.0f);
                glScalef(1.0f, 1.0f, 1.0f);
                glRotatef(-90.0f, 0.0f, 0.0f, 1.0f);
            }
#endif
            glMatrixMode(GL_MODELVIEW);

            mGraphics->setupDefaultSetting();
#if __DEBUG__
            _KRTextureChangeCount = 0;
            _KRTextureBatchProcessCount = 0;
#endif
            if (mLoadingScreenWorld != NULL) {
                mLoadingScreenWorld->startDrawView(mGraphics);
            } else {
                mGame->drawView(mGraphics);
            }
#if __DEBUG__
            mDebugControlManager->drawAllControls(gKRGraphicsInst, 0);
#endif
            KRTexture2D::processBatchedTexture2DDraws();
#if __DEBUG__
            if (mFPSDisplay != NULL) {
                mTextureChangeCounts[mTextureChangeCountPos++] = _KRTextureChangeCount;
                if (mTextureChangeCountPos >= KR_TEXTURE_CHANGE_COUNT_HISTORY_SIZE) {
                    mTextureChangeCountPos = 0;
                }
                mTextureBatchProcessCounts[mTextureBatchProcessCountPos++] = _KRTextureBatchProcessCount;
                if (mTextureBatchProcessCountPos >= KR_TEXTURE_BATCH_PROCESS_COUNT_HISTORY_SIZE) {
                    mTextureBatchProcessCountPos = 0;
                }
                mFrameCount++;
                mFPSDisplay->drawFPS(gKRScreenSize.x-10, gKRScreenSize.y-30, mCurrentFPS);
                mFPSDisplay->drawTPF(gKRScreenSize.x-10, gKRScreenSize.y-30*2, mCurrentTPF);
                mFPSDisplay->drawBPF(gKRScreenSize.x-10, gKRScreenSize.y-30*3, mCurrentBPF);
                KRTexture2D::processBatchedTexture2DDraws();
            }
#endif
            
#if KR_IPHONE_MACOSX_EMU
            [gKRGLViewInst drawTouches];
            KRTexture2D::processBatchedTexture2DDraws();
#endif

            // ダブルバッファのスワップ
#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
            CGLFlushDrawable(cglContext);
            CGLUnlockContext(cglContext);
#endif

#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
            glBindRenderbufferOES(GL_RENDERBUFFER_OES, mKRGLContext->viewRenderbuffer);
            [mKRGLContext->eaglContext presentRenderbuffer:GL_RENDERBUFFER_OES];
#endif

            if (_KRMatrixPushCount != 0) {
                std::string message = "KRPushMatrix() call count and KRPopMatrix() call count do not match.";
                if (gKRLanguage == KRLanguageJapanese) {
                    message = "KRPushMatrix() 関数と KRPopMatrix() 関数の呼び出し回数が一致しませんでした。";
                }
                throw KRRuntimeError(message);
            }

            // Calculate the update count and sleep certain interval
            uint64_t mcCurrentTime = mach_absolute_time();
            int modelUpdateCount = (int)((mcCurrentTime - mcPrevTime) / mMCFrameInterval);
            if (modelUpdateCount <= 0) {
                modelUpdateCount = 1;               // Update once at least
                mcPrevTime += mMCFrameInterval;     // Calc "next" prev time
                mach_wait_until(mcPrevTime);        // Sleep until the "next" prev time
            } else if (modelUpdateCount > KRMaxFrameSkipCount) {
                modelUpdateCount = KRMaxFrameSkipCount;   // Drop the frame
                mcPrevTime = mcCurrentTime;
            } else {
                mcPrevTime += mMCFrameInterval * modelUpdateCount;
            }
            
            // Update model
            if (mLoadingWorld != NULL) {
                if (!mIsWorldLoading) {
                    if (mLastErrorMessage != NULL) {
                        KRRuntimeError theError(*mLastErrorMessage);
                        delete mLastErrorMessage;
                        throw theError;
                    }
                    mLoadingScreenWorld->startResignedActive();
                    mLoadingWorld = NULL;
                    mLoadingScreenWorld = NULL;
                } else {
                    for (int i = 0; i < modelUpdateCount; i++) {
#if KR_IPHONE_MACOSX_EMU
                        [gKRWindowInst fetchSMSData];
#endif
                        mLoadingScreenWorld->startUpdateModel(mInput);
                    }
                }
            } else {
                for (int i = 0; i < modelUpdateCount; i++) {
#if KR_IPHONE_MACOSX_EMU
                    [gKRWindowInst fetchSMSData];
#endif
                    mGame->updateModel(mInput);
                    
                    if (mNetworkPeerName) {
                        while (mNetworkPeerName) {
                            [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
                        }
                        if (mHasAcceptedNetworkPeer) {
                            mGame->changeWorldImpl(mGame->getNetworkStartWorldName(), true, true);
                        }
                    } else if (mIsInvitingNetworkPeer) {
                        while (mIsInvitingNetworkPeer) {
                            [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
                        }
                        if (mHasAcceptedNetworkPeer) {
                            mGame->changeWorldImpl(mGame->getNetworkStartWorldName(), true, true);
                        }
                    }
                    
                    if (mLoadingWorld != NULL) {
                        std::string loadingScreenWorldName = mLoadingWorld->getLoadingScreenWorldName();
                        if (loadingScreenWorldName.length() > 0) {
                            mLoadingScreenWorld = mGame->getWorld(loadingScreenWorldName);
                            if (mLoadingScreenWorld == NULL) {
                                if (gKRLanguage == KRLanguageJapanese) {
                                    std::string errorFormat = "\"" + mLoadingWorld->getName() + "\" ワールドのための読み込み画面用ワールド \"" + loadingScreenWorldName + "\" は見つかりませんでした。";
                                    throw KRRuntimeError(errorFormat);
                                } else {
                                    std::string errorFormat = "World \"" + loadingScreenWorldName + "\" was not found for loading screen at \"" + mLoadingWorld->getName() + "\" world.";
                                    throw KRRuntimeError(errorFormat);
                                }
                            }
                            mLoadingScreenWorld->setLoadingWorld();
                            mLoadingScreenWorld->startBecameActive();
                            [NSThread detachNewThreadSelector:@selector(worldLoadingProc:) toTarget:self withObject:nil];
                        } else {
                            mLoadingWorld->startBecameActive();
                            mLoadingWorld = NULL;
                            mLoadingScreenWorld = NULL;
                            mIsWorldLoading = NO;
                        }
                        break;
                    }
                }
            }
            
#if __DEBUG__
            double currentTime = gettimeofday_sec();
            if (currentTime - mPrevFPSUpdateTime > 1.0) {
                mFrameCounts[mFrameCountPos++] = mFrameCount;
                if (mFrameCountPos >= KR_FRAME_COUNT_HISTORY_SIZE) {
                    mFrameCountPos = 0;
                }

                mCurrentFPS = 0.0;
                for (int i = 0; i < KR_FRAME_COUNT_HISTORY_SIZE; i++) {
                    mCurrentFPS += mFrameCounts[i];
                }
                mCurrentFPS /= KR_FRAME_COUNT_HISTORY_SIZE;
                mFrameCount = 0;
                
                mCurrentTPF = 0.0;
                for (int i = 0; i < KR_TEXTURE_CHANGE_COUNT_HISTORY_SIZE; i++) {
                    mCurrentTPF += mTextureChangeCounts[i];
                }
                mCurrentTPF /= KR_TEXTURE_CHANGE_COUNT_HISTORY_SIZE;

                mCurrentBPF = 0.0;
                for (int i = 0; i < KR_TEXTURE_BATCH_PROCESS_COUNT_HISTORY_SIZE; i++) {
                    mCurrentBPF += mTextureBatchProcessCounts[i];
                }
                mCurrentBPF /= KR_TEXTURE_BATCH_PROCESS_COUNT_HISTORY_SIZE;
                
                mPrevFPSUpdateTime = currentTime;
            }
#endif

#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
            if (mGameIsChaningScreenMode) {
                break;
            }
#endif
        }
    } catch (KRRuntimeError &e) {
        mGameIsAborted = YES;
        NSString *alertTitle = @"Karakuri Runtime Error";
        if (gKRLanguage == KRLanguageJapanese) {
            alertTitle = @"Karakuri ランタイムエラー";
        }
        if (dynamic_cast<KRGameError *>(&e)) {
            alertTitle = @"Game Execution Error";
            if (gKRLanguage == KRLanguageJapanese) {
                alertTitle = @"ゲーム実行エラー";
            }
        }
        NSString *message = [NSString stringWithCString:e.what() encoding:NSUTF8StringEncoding];
        std::cerr << "[Karakuri Runtime Error] " << e.what() << std::endl;
#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
        [gKRGLViewInst clearMouseTrackingRect];
        CGDisplayShowCursor(kCGDirectMainDisplay);
        NSBeep();
        NSBeginCriticalAlertSheet(alertTitle,
                                  @"OK",
                                  nil,
                                  nil,
                                  mWindow,
                                  self,
                                  @selector(didEndGameAbortMessageSelector),
                                  nil,
                                  nil,
                                  message);
#endif
        
#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
        mErrorAlertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
        [mErrorAlertView show];
        [mErrorAlertView release];
#endif
    } catch (KRGameExitError &e) {
        mTerminatedByUser = YES;
    }

    if (mHasMetEmergency) {
        if (mLoadingWorld == NULL) {
            mGame->saveForEmergency();
        }
    }
    
    if (!mGameIsAborted) {
#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
        if (!mGameIsChaningScreenMode) {
            mGame->cleanUpGame();
            mGameIsFinished = YES;
        }
#endif
            
#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
        mGame->cleanUpGame();
        mGameIsFinished = YES;
#endif
    }

    mGameIsRunning = NO;    //!< This makes it clear that the game loop was ended during the screen mode changing

    if (mTerminatedByUser) {
#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
        [mWindow performSelectorOnMainThread:@selector(performClose:) withObject:self waitUntilDone:NO];
#endif
        
#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
        [self applicationWillTerminate:[UIApplication sharedApplication]];
        exit(0);
#endif
    }
    
    [pool release];
}

#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
- (void)didEndGameAbortMessageSelector
{
    exit(9999);
}
#endif

#if KR_MACOSX
- (void)fullScreenGameProc
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    
#if __DEBUG__
    if (mFPSDisplay == NULL && mGame->getShowsFPS()) {
        mFPSDisplay = new KRFPSDisplay();
    }
    mPrevFPSUpdateTime = gettimeofday_sec();
    mFrameCount = 0;
#endif
    
    [self setupGLOptions];
    
    NSSize fullScreenSize = [[NSScreen mainScreen] frame].size;
    
    KRRect2D blackBox[2];

    double width = 480.0;
    double height = 320.0;
    if (gKRScreenSize.x / gKRScreenSize.y < fullScreenSize.width / fullScreenSize.height) {
        height = fullScreenSize.height;
        width = height * gKRScreenSize.x / gKRScreenSize.y;
        blackBox[0] = KRRect2D(0, 0, (fullScreenSize.width - width) / 2, height);
        blackBox[1] = KRRect2D(fullScreenSize.width-blackBox[0].width, 0, blackBox[0].width, height);
    } else {
        width = fullScreenSize.width;
        height = width * gKRScreenSize.x / gKRScreenSize.y;
        blackBox[0] = KRRect2D(0, 0, width, (fullScreenSize.height - height) / 2);
        blackBox[1] = KRRect2D(0, fullScreenSize.height-blackBox[0].height, width, blackBox[0].height);
    }
    KRRect2D viewRect((fullScreenSize.width - width) / 2, (fullScreenSize.height - height) / 2, width, height);

    glViewport(viewRect.x, viewRect.y, viewRect.width, viewRect.height);
    glOrtho(0.0, gKRScreenSize.x, 0.0, gKRScreenSize.y, -1.0, 1.0);    

    volatile bool isRunning = YES;
    
    //mInput->setFullScreenMode(true);
    _KRIsFullScreen = true;
    
    uint64_t mcPrevTime = mach_absolute_time();     // End time of the previous loop (Mach time)

    try {
        while (isRunning) {
            mGraphics->setupDefaultSetting();
#if __DEBUG__
            _KRTextureChangeCount = 0;
            _KRTextureBatchProcessCount = 0;
#endif
            KRColor::Black.setAsClearColor();
            glClear(GL_COLOR_BUFFER_BIT);
                
            if (mLoadingScreenWorld != NULL) {
                mLoadingScreenWorld->startDrawView(mGraphics);
            } else {
                mGame->drawView(mGraphics);
            }
            KRTexture2D::processBatchedTexture2DDraws();
#if __DEBUG__
            if (mFPSDisplay != NULL) {
                mTextureChangeCounts[mTextureChangeCountPos++] = _KRTextureChangeCount;
                if (mTextureChangeCountPos >= KR_TEXTURE_CHANGE_COUNT_HISTORY_SIZE) {
                    mTextureChangeCountPos = 0;
                }
                mTextureBatchProcessCounts[mTextureBatchProcessCountPos++] = _KRTextureBatchProcessCount;
                if (mTextureBatchProcessCountPos >= KR_TEXTURE_BATCH_PROCESS_COUNT_HISTORY_SIZE) {
                    mTextureBatchProcessCountPos = 0;
                }
                mFrameCount++;
                mFPSDisplay->drawFPS(gKRScreenSize.x-10, gKRScreenSize.y-30, mCurrentFPS);
                mFPSDisplay->drawTPF(gKRScreenSize.x-10, gKRScreenSize.y-30*2, mCurrentTPF);
                mFPSDisplay->drawBPF(gKRScreenSize.x-10, gKRScreenSize.y-30*3, mCurrentBPF);
                KRTexture2D::processBatchedTexture2DDraws();
            }
#endif

            CGLFlushDrawable(mKRGLContext->cglFullScreenContext);

            if (_KRMatrixPushCount != 0) {
                std::string message = "KRPushMatrix() call count and KRPopMatrix() call count do not match.";
                if (gKRLanguage == KRLanguageJapanese) {
                    message = "KRPushMatrix() 関数と KRPopMatrix() 関数の呼び出し回数が一致しませんでした。";
                }
                throw KRRuntimeError(message);
            }
            
            NSEvent *event;
            while (isRunning && (event = [NSApp nextEventMatchingMask:NSAnyEventMask untilDate:[NSDate distantPast] inMode:NSDefaultRunLoopMode dequeue:YES])) {
                switch ([event type]) {
                    case NSLeftMouseDown:
                        mInput->processMouseDown(KRInput::MouseButtonLeft);
                        break;
                        
                    case NSLeftMouseUp:
                        mInput->processMouseUp(KRInput::MouseButtonLeft);
                        break;

                    case NSKeyDown: {
                        unsigned short keyCode = [event keyCode];
                        unsigned modifierFlags = [event modifierFlags];
                        if (keyCode == 0x03 && (modifierFlags & NSCommandKeyMask)) {
                            isRunning = NO;
                        }
                        else if (keyCode == 0x0c && (modifierFlags & NSCommandKeyMask)) {
                            mGameIsFinished = YES;
                            isRunning = NO;
                        } else {
                            mInput->processKeyDownCode(keyCode);
                        }
                        break;
                    }
                        
                    case NSKeyUp: {
                        unsigned short keyCode = [event keyCode];
                        mInput->processKeyUpCode(keyCode);
                        break;
                    }
                        
                    default:
                        break;
                }
            }

            // Calculate the update count and sleep certain interval
            uint64_t mcCurrentTime = mach_absolute_time();
            int modelUpdateCount = (int)((mcCurrentTime - mcPrevTime) / mMCFrameInterval);
            if (modelUpdateCount <= 0) {
                modelUpdateCount = 1;               // Update once at least
                mcPrevTime += mMCFrameInterval;     // Calc "next" prev time
                mach_wait_until(mcPrevTime);        // Sleep until the "next" prev time
            } else if (modelUpdateCount > KRMaxFrameSkipCount) {
                modelUpdateCount = KRMaxFrameSkipCount;   // Drop the frame
                mcPrevTime = mcCurrentTime;
            } else {
                mcPrevTime += mMCFrameInterval * modelUpdateCount;
            }
            
            // Update model
            if (mLoadingWorld != NULL) {
                if (!mIsWorldLoading) {
                    if (mLastErrorMessage != NULL) {
                        KRRuntimeError theError(*mLastErrorMessage);
                        delete mLastErrorMessage;
                        throw theError;
                    }
                    mLoadingScreenWorld->startResignedActive();
                    mLoadingWorld = NULL;
                    mLoadingScreenWorld = NULL;
                } else {
                    for (int i = 0; i < modelUpdateCount; i++) {
                        mLoadingScreenWorld->startUpdateModel(mInput);
                    }
                }
            } else {
                for (int i = 0; i < modelUpdateCount; i++) {
                    mGame->updateModel(mInput);
                    if (mLoadingWorld != NULL) {
                        std::string loadingScreenWorldName = mLoadingWorld->getLoadingScreenWorldName();
                        if (loadingScreenWorldName.length() > 0) {
                            mLoadingScreenWorld = mGame->getWorld(loadingScreenWorldName);
                            if (mLoadingScreenWorld == NULL) {
                                if (gKRLanguage == KRLanguageJapanese) {
                                    std::string errorFormat = "\"" + mLoadingWorld->getName() + "\" ワールドのための読み込み画面用ワールド \"" + loadingScreenWorldName + "\" は見つかりませんでした。";
                                    throw KRRuntimeError(errorFormat);
                                } else {
                                    std::string errorFormat = "World \"" + loadingScreenWorldName + "\" was not found for loading screen at \"" + mLoadingWorld->getName() + "\" world.";
                                    throw KRRuntimeError(errorFormat);
                                }
                            }
                            mLoadingScreenWorld->setLoadingWorld();
                            mLoadingScreenWorld->startBecameActive();
                            [NSThread detachNewThreadSelector:@selector(worldLoadingProc:) toTarget:self withObject:nil];
                        } else {
                            mLoadingWorld->startBecameActive();
                            mLoadingWorld = NULL;
                            mIsWorldLoading = NO;
                        }
                        break;
                    }
                }
            }
            
#if __DEBUG__
            double currentTime = gettimeofday_sec();
            if (currentTime - mPrevFPSUpdateTime > 1.0) {
                mFrameCounts[mFrameCountPos++] = mFrameCount;
                if (mFrameCountPos >= KR_FRAME_COUNT_HISTORY_SIZE) {
                    mFrameCountPos = 0;
                }

                mCurrentFPS = 0.0;
                for (int i = 0; i < KR_FRAME_COUNT_HISTORY_SIZE; i++) {
                    mCurrentFPS += mFrameCounts[i];
                }
                mCurrentFPS /= KR_FRAME_COUNT_HISTORY_SIZE;
                mFrameCount = 0;

                mCurrentTPF = 0.0;
                for (int i = 0; i < KR_TEXTURE_CHANGE_COUNT_HISTORY_SIZE; i++) {
                    mCurrentTPF += mTextureChangeCounts[i];
                }
                mCurrentTPF /= KR_TEXTURE_CHANGE_COUNT_HISTORY_SIZE;

                mCurrentBPF = 0.0;
                for (int i = 0; i < KR_TEXTURE_BATCH_PROCESS_COUNT_HISTORY_SIZE; i++) {
                    mCurrentBPF += mTextureBatchProcessCounts[i];
                }
                mCurrentBPF /= KR_TEXTURE_BATCH_PROCESS_COUNT_HISTORY_SIZE;
                
                mPrevFPSUpdateTime = currentTime;
            }
#endif            
        }
        if (mGameIsFinished) {
            mGame->cleanUpGame();
        }
    } catch (KRRuntimeError &e) {
        mGameIsAborted = YES;
        mLastErrorMessage = new std::string(e.what());
    } catch (KRGameExitError &e) {
        mGameIsFinished = YES;
        mGame->cleanUpGame();
    }
    
    //mInput->setFullScreenMode(false);
    _KRIsFullScreen = false;

    [pool release];
}

#endif

@end

