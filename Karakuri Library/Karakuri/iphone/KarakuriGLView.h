//
//  KarakuriGLView.h
//  Karakuri Prototype
//
//  Created by numata on 09/07/17.
//  Copyright Satoshi Numata 2009. All rights reserved.
//

#import <Karakuri/KarakuriLibrary.h>

#import <Karakuri/KarakuriGLContext.h>
#import <Karakuri/KRTexture2D.h>


#define KR_TOUCH_MAX_COUNT    5


typedef struct _KRTouchInfo2 {
    bool        is_used;
    CGPoint     pos;
    void*       touch_pointer;
    unsigned    touch_id;
} _KRTouchInfo2;


@interface KarakuriGLView : UIView<UIAccelerometerDelegate> {
    KarakuriGLContext   mKRGLContext;
    
    unsigned            mNextTouchID;
    _KRTouchInfo2       mTouchInfos[KR_TOUCH_MAX_COUNT];
    
//    BOOL        mIsTouchActive[KR_TOUCH_MAX_COUNT];
//    CGPoint     mTouchPos[KR_TOUCH_MAX_COUNT];

    BOOL    mIsAccelerometerEnabled;
    
    BOOL    mIsAttachedToSecondScreen;
    
    _KRTexture2D*   mDefaultTex;
    void*           mCurrentImageBuffer;
}

- (id)initWithScreenSize:(CGSize)screenSize;

- (void)waitForReady;

- (void)enableAccelerometer;
- (void)disableAccelerometer;

- (void)setAttachedToSecondScreen;

- (UIImage*)currentImage;

@end


extern KarakuriGLView*  gKRGLViewInst;

