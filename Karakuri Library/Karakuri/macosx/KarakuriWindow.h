//
//  KarakuriWindow.h
//  Karakuri Prototype
//
//  Created by numata on 09/07/17.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import <Karakuri/KarakuriLibrary.h>

#import <Karakuri/macosx/KarakuriGLView.h>

#if KR_IPHONE_MACOSX_EMU
#import "KarakuriAccSlider.h"
#import "smsutils/smsutils.h"
#endif


@interface KarakuriWindow : NSWindow {
    KarakuriGLView      *mGLView;
    
#if KR_IPHONE_MACOSX_EMU
    KarakuriAccSlider   *mAccHorizontalSlider;
    KarakuriAccSlider   *mAccVerticalSlider;
    NSButton            *mMotionSensorButton;
    sms_t               mSMS;
    BOOL                mSMSEnabled;
#endif
}

#if KR_IPHONE_MACOSX_EMU
- (void)fetchSMSData;
- (void)cleanUpSMS;
#endif

@end


extern KarakuriWindow *KRWindowInst;


