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

KarakuriWindow* gKRWindowInst = nil;

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
    
    int width = game->getScreenWidth();
    int height = game->getScreenHeight();
    
    // iPhone
    if (width < 500 && height < 500) {
        if (width > height) {
            windowRect.size.width += 244 + 21;
            windowRect.size.height += 70 + 21;
        } else {
            windowRect.size.width += 74 + 21;
            windowRect.size.height += 250 + 21;
        }
    }
    // iPad
    else {
        windowRect.size.width += 21*2;
        windowRect.size.height += 21*2;
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
        KarakuriEmulatorBackView* backView = [KarakuriEmulatorBackView new];
        [[self contentView] addSubview:backView];
        [backView release];
        sAcc = KRVector3DZero;
        
        mSMSEnabled = YES;
        if (smsOpen(&mSMS) != 0) {
            mSMSEnabled = NO;
        }
#endif
        
        mGLView = [KarakuriGLView new];
        [[self contentView] addSubview:mGLView];
        
#if KR_IPHONE_MACOSX_EMU
        int width = game->getScreenWidth();
        int height = game->getScreenHeight();
        
        // iPhone
        if (width < 500) {
            if (width > height) {
                mAccHorizontalSlider = [[KarakuriAccSlider alloc] initWithFrame:NSMakeRect(570, 3, 150, 21)];
                mAccVerticalSlider = [[KarakuriAccSlider alloc] initWithFrame:NSMakeRect(720, 21+4, 21, 120)];
            } else {
                mAccHorizontalSlider = [[KarakuriAccSlider alloc] initWithFrame:NSMakeRect(274, 3, 120, 21)];
                mAccVerticalSlider = [[KarakuriAccSlider alloc] initWithFrame:NSMakeRect(391, 21, 21, 150)];
            }
        }
        // iPad
        else {
            if (width > height) {
                mAccHorizontalSlider = [[KarakuriAccSlider alloc] initWithFrame:NSMakeRect(898, 0, 150, 21)];
                mAccVerticalSlider = [[KarakuriAccSlider alloc] initWithFrame:NSMakeRect(1024+21, 17, 21, 120)];
            } else {
                mAccHorizontalSlider = [[KarakuriAccSlider alloc] initWithFrame:NSMakeRect(671, 0, 120, 21)];
                mAccVerticalSlider = [[KarakuriAccSlider alloc] initWithFrame:NSMakeRect(768+21, 17, 21, 150)];
            }
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
        
        // iPhone
        if (game->getScreenWidth() < 500) {
            mMotionSensorButton = [[NSButton alloc] initWithFrame:NSMakeRect(10, 5, 150, 18)];
        }
        // iPad
        else {
            mMotionSensorButton = [[NSButton alloc] initWithFrame:NSMakeRect(10, 1, 150, 18)];            
        }

        NSString* motionSensorButtonTitle = @"SMS Emu";
        [mMotionSensorButton setTitle:motionSensorButtonTitle];
        [mMotionSensorButton setButtonType:NSSwitchButton];
        [mMotionSensorButton setTarget:self];
        [mMotionSensorButton setAction:@selector(changedMotionSensorButtonState:)];
        if (!mSMSEnabled) {
            [mMotionSensorButton setEnabled:NO];
        }
        [[self contentView] addSubview:mMotionSensorButton];
        
        // iPad
        if (game->getScreenWidth() > 500 || 1) {
            // Set Button's Text Color
            NSMutableAttributedString* attrTitle = [[NSMutableAttributedString alloc] initWithAttributedString:[mMotionSensorButton attributedTitle]];
            int len = [attrTitle length];
            NSRange range = NSMakeRange(0, len);
            [attrTitle addAttribute:NSForegroundColorAttributeName 
                              value:[NSColor whiteColor] 
                              range:range];
            [attrTitle fixAttributesInRange:range];
            [mMotionSensorButton setAttributedTitle:attrTitle];
            [attrTitle release];            
        }
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

// このメソッドは iPad のときしか呼ばれない。
- (void)changeWindowSize
{
    KRGameController* controller = [KRGameController sharedController];
    KRGameManager* game = [controller game];
    int width = game->getScreenWidth();
    int height = game->getScreenHeight();
    
    NSSize contentSize = NSMakeSize(width, height);
    
    if ([controller isScreenSizeHalved]) {
        contentSize.width /= 2;
        contentSize.height /= 2;
        
        NSRect glViewFrame = [mGLView frame];
        glViewFrame.size = NSMakeSize(width / 2, height / 2);
        [mGLView setFrame:glViewFrame];
        [mGLView setScreenSizeHalved:YES];
        
        NSRect hSliderFrame = [mAccHorizontalSlider frame];
        hSliderFrame.origin.x -= (width > height)? 1024/2: 768/2;
        [mAccHorizontalSlider setFrame:hSliderFrame];

        NSRect vSliderFrame = [mAccVerticalSlider frame];
        vSliderFrame.origin.x -= (width > height)? 1024/2: 768/2;
        [mAccVerticalSlider setFrame:vSliderFrame];
    } else {
        NSRect glViewFrame = [mGLView frame];
        glViewFrame.size = NSMakeSize(width, height);
        [mGLView setFrame:glViewFrame];
        [mGLView setScreenSizeHalved:NO];

        NSRect hSliderFrame = [mAccHorizontalSlider frame];
        hSliderFrame.origin.x += (width > height)? 1024/2: 768/2;
        [mAccHorizontalSlider setFrame:hSliderFrame];

        NSRect vSliderFrame = [mAccVerticalSlider frame];
        vSliderFrame.origin.x += (width > height)? 1024/2: 768/2;
        [mAccVerticalSlider setFrame:vSliderFrame];
    }
    
    contentSize.width += 21*2;
    contentSize.height += 21*2;
    
    NSRect oldFrame = [self frame];

    NSRect newFrame = [self frameRectForContentRect: NSMakeRect(0, 0, contentSize.width, contentSize.height)];
    float titleBarHeight = newFrame.size.height - contentSize.height;
    newFrame.origin.x = oldFrame.origin.x;
    newFrame.origin.y = oldFrame.origin.y + oldFrame.size.height - newFrame.size.height, titleBarHeight;
    [self setFrame:newFrame display:YES animate:NO];
}

- (void)changedAccValue:(NSSlider*)sender
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
    gKRInputInst->_setAcceleration(sAcc.x, sAcc.y, sAcc.z);
}

- (void)changedMotionSensorButtonState:(id)sender
{
    if ([mMotionSensorButton state] == NSOnState) {
        [mAccHorizontalSlider setEnabled:NO];
        [mAccVerticalSlider setEnabled:NO];
    } else {
        sAcc.x = sAcc.y = sAcc.z = 0.0;
        gKRInputInst->_setAcceleration(sAcc.x, sAcc.y, sAcc.z);        
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
        gKRInputInst->_setAcceleration(sAcc.x, sAcc.y, sAcc.z);        
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
        gKRInputInst->_setAcceleration(sAcc.x, sAcc.y, sAcc.z);
    }
}

- (void)cleanUpSMS
{
    smsClose(&mSMS);
}

#endif

@end

