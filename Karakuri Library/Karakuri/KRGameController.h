//
//  KRGameController.h
//  Karakuri Prototype
//
//  Created by numata on 09/07/17.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import <Karakuri/KarakuriLibrary.h>

#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
#import <Karakuri/macosx/KarakuriWindow.h>
#import <Karakuri/macosx/KRPeerPicker.h>
#endif

#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
#import <Karakuri/iphone/KarakuriWindow.h>
#import <Karakuri/iphone/KRPeerPicker.h>
#endif

#import <Karakuri/KRGame.h>
#import <Karakuri/KarakuriGLContext.h>
#import <Karakuri/KarakuriLibraryConnectorBase.h>
#import <Karakuri/KRGraphics.h>
#import <Karakuri/KRInput.h>
#import <Karakuri/KRFPSDisplay.h>
#import <Karakuri/KarakuriNetwork.h>
#import <Karakuri/KRAnime2D.h>


#if __DEBUG__
    #define KR_FRAME_COUNT_HISTORY_SIZE         10
    #define KR_TEXTURE_CHANGE_COUNT_HISTORY_SIZE       10
    #define KR_TEXTURE_BATCH_PROCESS_COUNT_HISTORY_SIZE       10
#endif


@interface KRGameController : NSObject<KRPeerPickerDelegate> {
    KarakuriWindow      *mWindow;
    KarakuriGLContext   *mKRGLContext;
    KRGame              *mGame;
    
    KRGraphics          *mGraphics;
    KRInput             *mInput;
    
    KarakuriLibraryConnectorBase    *mLibraryConnector;
    
    volatile BOOL       mGameIsRunning;
    volatile BOOL       mGameIsFinished;
    
    volatile BOOL       mGameIsInitialized;
    volatile BOOL       mGameIsAborted;
    
    uint64_t            mMCFrameInterval;
    
    KRWorld             *mLoadingWorld;
    volatile BOOL       mIsWorldLoading;
    KRWorld             *mLoadingScreenWorld;
    
    BOOL                mIsInFullScreenMode;
    BOOL                mHasMetEmergency;
    BOOL                mTerminatedByUser;
    
    KRAnime2D           *mCharacterAnime;
    
    KRNetwork           *mNetworkServer;
    NSString            *mNetworkPeerName;
    BOOL                mHasAcceptedNetworkPeer;
    volatile BOOL       mIsInvitingNetworkPeer;
    
#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
    KRPeerPickerWindow  *mPeerPickerWindow;
#endif
    
#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
    KRPeerPickerController  *mPeerPickerController;
    UIAlertView         *mErrorAlertView;
    UIAlertView         *mNetworkAcceptAlertView;
#endif
    
#if __DEBUG__
    KRFPSDisplay        *mFPSDisplay;
    KRControlManager    *mDebugControlManager;

    double              mCurrentFPS;
    int                 mFrameCount;
    int                 mFrameCounts[KR_FRAME_COUNT_HISTORY_SIZE];
    int                 mFrameCountPos;
    double              mPrevFPSUpdateTime;
    
    double              mCurrentTPF;
    int                 mTextureChangeCounts[KR_TEXTURE_CHANGE_COUNT_HISTORY_SIZE];
    int                 mTextureChangeCountPos;

    double              mCurrentBPF;
    int                 mTextureBatchProcessCounts[KR_TEXTURE_BATCH_PROCESS_COUNT_HISTORY_SIZE];
    int                 mTextureBatchProcessCountPos;
#endif

    std::string         *mLastErrorMessage;

#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
    volatile BOOL       mGameIsChaningScreenMode;
#endif
    
#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
    EAGLSharegroup      *mEAGLSharegroup;
#endif
}

+ (KRGameController *)sharedController;

//- (void)startLoadingScreenThreadForWorld:(KRWorld *)world;
- (void)startChaningWorld:(KRWorld *)world;

#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
- (EAGLSharegroup *)eaglSharegroup;
#endif

- (void)setKRGLContext:(KarakuriGLContext *)context;
- (void)setupGLOptions;

#if KR_MACOSX
- (void)fullScreenGameProc;
#endif

- (KRGame *)game;

#if __DEBUG__
- (void)addDebugString:(const std::string&)str;
- (void)removeDebugStrings;
#endif

- (void)processNetworkRequest:(NSString *)name;
- (void)showNetworkPeerPicker;

@end

