//
//  KarakuriWindow.mm
//  Karakuri Prototype
//
//  Created by numata on 09/07/17.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import "KarakuriWindow.h"
#import "KRGameController.h"

#if KR_IPHONE_MACOSX_EMU
#import "KarakuriEmulatorBackView.h"
#endif

KarakuriWindow *gKRWindowInst = nil;

static KRVector3D   sAcc;


@implementation KarakuriWindow

- (id)init
{
    KRGameController* controller = [KRGameController sharedController];
    KRGameManager* game = [controller game];

    int styleMask = (NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask);
    NSRect windowRect = NSMakeRect(0, 0, game->getScreenWidth(), game->getScreenHeight());
    
#if KR_IPHONE_MACOSX_EMU
    styleMask |= NSTexturedBackgroundWindowMask;
    if (game->getScreenWidth() > game->getScreenHeight()) {
        windowRect.size.width += 270 + 21;
        windowRect.size.height += 100 + 21;
    } else {
        windowRect.size.width += 100 + 21;
        windowRect.size.height += 270 + 21;
    }
#endif
    
    self = [super initWithContentRect:windowRect
                            styleMask:styleMask
                              backing:NSBackingStoreBuffered
                                defer:NO];
    if (self) {
        gKRWindowInst = self;
        
        [self setDelegate:[KRGameController sharedController]];
        
#if KR_IPHONE_MACOSX_EMU
        KarakuriEmulatorBackView *backView = [KarakuriEmulatorBackView new];
        [[self contentView] addSubview:backView];
        sAcc = KRVector3DZero;
        
        mSMSEnabled = YES;
        if (smsOpen(&mSMS) != 0) {
            mSMSEnabled = NO;
        }
#endif
        
        mGLView = [KarakuriGLView new];
        [[self contentView] addSubview:mGLView];
        
#if KR_IPHONE_MACOSX_EMU
        if (game->getScreenWidth() > game->getScreenHeight()) {
            mAccHorizontalSlider = [[KarakuriAccSlider alloc] initWithFrame:NSMakeRect(580+4, 5, 150, 21)];
            mAccVerticalSlider = [[KarakuriAccSlider alloc] initWithFrame:NSMakeRect(750-4, 21+4, 21, 120)];
        } else {
            mAccHorizontalSlider = [[KarakuriAccSlider alloc] initWithFrame:NSMakeRect(580-320+4+14, 5, 120, 21)];
            mAccVerticalSlider = [[KarakuriAccSlider alloc] initWithFrame:NSMakeRect(750-320-4-14, 21+4, 21, 150)];
        }
        [mAccHorizontalSlider setMinValue:-1.0];
        [mAccHorizontalSlider setMaxValue:1.0];
        [mAccVerticalSlider setMinValue:-1.0];
        [mAccVerticalSlider setMaxValue:1.0];
        [mAccHorizontalSlider setFloatValue:0.0f];
        [mAccVerticalSlider setFloatValue:0.0f];
        [mAccHorizontalSlider setTarget:self];
        [mAccHorizontalSlider setAction:@selector(changedAccValue:)];        
        [mAccVerticalSlider setTarget:self];
        [mAccVerticalSlider setAction:@selector(changedAccValue:)];
        [[self contentView] addSubview:mAccHorizontalSlider];
        [[self contentView] addSubview:mAccVerticalSlider];
        
        mMotionSensorButton = [[NSButton alloc] initWithFrame:NSMakeRect(10, 5, 150, 18)];
        NSString *motionSensorButtonTitle = @"SMS Emulation";
        if (gKRLanguage == KRLanguageJapanese) {
            motionSensorButtonTitle = @"SMS エミュレーション";
        }
        [mMotionSensorButton setTitle:motionSensorButtonTitle];
        [mMotionSensorButton setButtonType:NSSwitchButton];
        [mMotionSensorButton setTarget:self];
        [mMotionSensorButton setAction:@selector(changedMotionSensorButtonState:)];
        if (!mSMSEnabled) {
            [mMotionSensorButton setEnabled:NO];
        }
        [[self contentView] addSubview:mMotionSensorButton];
#endif
    }
    return self;
}

- (void)dealloc
{
    [mGLView release];

#if KR_IPHONE_MACOSX_EMU
    [mAccHorizontalSlider release];
    [mAccVerticalSlider release];
    [mMotionSensorButton release];
#endif

    [super dealloc];
}

#if KR_IPHONE_MACOSX_EMU
- (void)changedAccValue:(NSSlider *)sender
{
    if (![gKRGLViewInst isAccelerometerEnabled]) {
        return;
    }
    float value = [sender floatValue];
    if (sender == mAccHorizontalSlider) {
        sAcc.x = value * 0.8;
    } else {
        sAcc.y = value * 0.8;
    }
    gKRInputInst->setAcceleration(sAcc.x, sAcc.y, sAcc.z);
}

- (void)changedMotionSensorButtonState:(id)sender
{
    if ([mMotionSensorButton state] == NSOnState) {
        [mAccHorizontalSlider setEnabled:NO];
        [mAccVerticalSlider setEnabled:NO];
    } else {
        sAcc.x = sAcc.y = sAcc.z = 0.0;
        gKRInputInst->setAcceleration(sAcc.x, sAcc.y, sAcc.z);        
        [mAccHorizontalSlider setEnabled:YES];
        [mAccVerticalSlider setEnabled:YES];
    }
}

- (void)fetchSMSData
{
    if (!mSMSEnabled) {
        sAcc.x = sAcc.y = sAcc.z = 0.0;
        return;
    }

    if ([mMotionSensorButton state] != NSOnState) {
        sAcc.x = sAcc.y = sAcc.z = 0.0;
        return;
    }

    if (![gKRGLViewInst isAccelerometerEnabled]) {
        sAcc.x = sAcc.y = sAcc.z = 0.0;
        gKRInputInst->setAcceleration(sAcc.x, sAcc.y, sAcc.z);        
        return;
    }
 
    sms_data_t smsData;
    if (smsGetData(&mSMS, &smsData) == 0) {
        float x = smsData.x * mSMS.unit * 5;
        float y = smsData.y * mSMS.unit * 5;
        float z = smsData.z * mSMS.unit * 5;
        sAcc.x = -(x / 0xff);
        sAcc.y = -(y / 0xff);
        sAcc.z = -(z / 0xff);
        gKRInputInst->setAcceleration(sAcc.x, sAcc.y, sAcc.z);
    }
}

- (void)cleanUpSMS
{
    smsClose(&mSMS);
}

#endif

@end

