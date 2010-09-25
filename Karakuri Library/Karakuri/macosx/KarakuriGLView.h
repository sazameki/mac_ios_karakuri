//
//  KarakuriGLView.h
//  Karakuri Prototype
//
//  Created by numata on 09/07/18.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import <Karakuri/KarakuriLibrary.h>

#import <Karakuri/KarakuriGLContext.h>
#import <Karakuri/KRTexture2D.h>


@interface KarakuriGLView : NSOpenGLView {
    KarakuriGLContext   mKRGLContext;
    
    NSTrackingRectTag   mMouseTrackingRectTag;

    _KRTexture2D*   mDefaultTex;
    
#if KR_IPHONE_MACOSX_EMU
    BOOL            mIsScreenSizeHalved;
    BOOL            mIsAccelerometerEnabled;
    _KRTexture2D*   mTouchTex;
    KRVector2D      mTouchPos[5];
#endif
}

- (void)waitForReady;

#if KR_MACOSX
- (void)toggleFullScreen;
#endif

- (void)clearMouseTrackingRect;

#if KR_IPHONE_MACOSX_EMU
- (void)setScreenSizeHalved:(BOOL)flag;
- (BOOL)isAccelerometerEnabled;
- (void)enableAccelerometer;
- (void)disableAccelerometer;
- (void)drawTouches;
- (void)addTouch:(KRVector2D)pos;
- (void)clearTouches;
#endif

@end


extern KarakuriGLView*  gKRGLViewInst;


