//
//  KarakuriGLView.mm
//  Karakuri Prototype
//
//  Created by numata on 09/07/18.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import "KarakuriGLView.h"

#import <Karakuri/KRGameController.h>
#include <Karakuri/KRInput.h>
#include <Karakuri/KRGraphics.h>


KarakuriGLView* gKRGLViewInst = nil;

static volatile BOOL    sIsReady = NO;


@implementation KarakuriGLView

- (BOOL)acceptsFirstResponder { return YES; }

- (id)init
{
    KRGameController* controller = [KRGameController sharedController];
    KRGameManager* game = [controller game];

    NSOpenGLPixelFormatAttribute attrs[] = {
        NSOpenGLPFAWindow,
        NSOpenGLPFAAccelerated,
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFANoRecovery,
        NSOpenGLPFAColorSize, (NSOpenGLPixelFormatAttribute)32,
        NSOpenGLPFAAlphaSize, (NSOpenGLPixelFormatAttribute)8,
        NSOpenGLPFADepthSize, (NSOpenGLPixelFormatAttribute)16,
        (NSOpenGLPixelFormatAttribute)0
    };
    NSOpenGLPixelFormat *pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
    if (!pixelFormat) {
        NSLog(@"KarakuriGLView: Failed to create a pixel format object.");
        [self release];
        return nil;
    }
    
    mKRGLContext.backingWidth = game->getScreenWidth();
    mKRGLContext.backingHeight = game->getScreenHeight();

    NSRect viewRect = NSMakeRect(0, 0, mKRGLContext.backingWidth, mKRGLContext.backingHeight);
    
#if KR_IPHONE_MACOSX_EMU
    if (game->getScreenWidth() > game->getScreenHeight()) {
        viewRect.origin.x += 250 / 2 + 17;
        viewRect.origin.y += 100 / 2 - 3 + 21;
    } else {
        viewRect.origin.x += 100 / 2;
        viewRect.origin.y += 250 / 2 + 8 + 21;
    }
#endif
    
    self = [super initWithFrame:viewRect
                    pixelFormat:pixelFormat];
    [pixelFormat release];
    if (self) {
        gKRGLViewInst = self;
        mKRGLContext.isFullScreen = NO;
        mKRGLContext.oldScreenModeRef = nil;        
    }
    return self;
}

- (void)dealloc
{
    delete mDefaultTex;
#if KR_IPHONE_MACOSX_EMU
    delete mTouchTex;
#endif
    
    [super dealloc];
}

- (void)viewDidMoveToWindow
{
    mMouseTrackingRectTag = [self addTrackingRect:[self bounds] owner:self userData:NULL assumeInside:NO];
}

- (void)prepareOpenGL
{    
    mKRGLContext.cglContext = (CGLContextObj)[[self openGLContext] CGLContextObj];
    CGLSetCurrentContext(mKRGLContext.cglContext);
    
    mDefaultTex = new _KRTexture2D("Default.png");
#if KR_IPHONE_MACOSX_EMU
    mTouchTex = new _KRTexture2D("/Developer/Extras/Karakuri/images/System/iPhone Emulator/touch_circle.png");
    [self clearTouches];
#endif

    glViewport(0, 0, mKRGLContext.backingWidth, mKRGLContext.backingHeight);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();

    glOrtho(0.0, (double)mKRGLContext.backingWidth, 0.0, (double)mKRGLContext.backingHeight, -1.0, 1.0);

    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);

    double angle = 0.0;
    if (gKRScreenSize.x > gKRScreenSize.y) {
        angle = M_PI / 2;
    }
    mDefaultTex->draw(gKRScreenSize/2, KRRect2DZero, angle, mDefaultTex->getCenterPos());
    _KRTexture2D::processBatchedTexture2DDraws();
    CGLFlushDrawable(mKRGLContext.cglContext);

    mDefaultTex->draw(gKRScreenSize/2, KRRect2DZero, angle, mDefaultTex->getCenterPos());
    _KRTexture2D::processBatchedTexture2DDraws();
    CGLFlushDrawable(mKRGLContext.cglContext);    

    [[KRGameController sharedController] setKRGLContext:&mKRGLContext];
    
    sIsReady = YES;
}

- (void)waitForReady
{
    while (!sIsReady) {
        [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}

#if KR_MACOSX
- (BOOL)startFullScreen
{
    mKRGLContext.isFullScreen = YES;

    {
        CGDisplayFadeReservationToken newToken;
        CGAcquireDisplayFadeReservation(0.7, &newToken); // reserve display hardware time    
        CGDisplayFade(newToken,
                      0.7f,	 // 0.7 seconds
                      kCGDisplayBlendNormal,	// Starting state
                      kCGDisplayBlendSolidColor, // Ending state
                      0.0, 0.0, 0.0,	 // black
                      true);	 // wait for completion
        CGReleaseDisplayFadeReservation(newToken);
    }

    NSOpenGLPixelFormatAttribute attrs[] = {
        NSOpenGLPFAFullScreen,
        NSOpenGLPFAScreenMask, (NSOpenGLPixelFormatAttribute)CGDisplayIDToOpenGLDisplayMask(kCGDirectMainDisplay),
        NSOpenGLPFAAccelerated,
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFANoRecovery,
        NSOpenGLPFAColorSize, (NSOpenGLPixelFormatAttribute)32,
        NSOpenGLPFAAlphaSize, (NSOpenGLPixelFormatAttribute)8,
        NSOpenGLPFADepthSize, (NSOpenGLPixelFormatAttribute)16,
        (NSOpenGLPixelFormatAttribute)0
    };
    NSOpenGLPixelFormat *pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
    if (!pixelFormat) {
        NSLog(@"KarakuriGLView-startFullScreen: Failed to create a pixel format object for full screen context.");
        return NO;
    }
    
    CFDictionaryRef refDisplayMode = CGDisplayBestModeForParametersAndRefreshRate(kCGDirectMainDisplay, 16, 800, 600, 60.0, NULL);
    if (refDisplayMode) {
        mKRGLContext.oldScreenModeRef = CGDisplayCurrentMode(kCGDirectMainDisplay);
        CGDisplayErr err = CGDisplayCapture(kCGDirectMainDisplay);
        if (err != CGDisplayNoErr) {
            NSLog(@"KarakuriGLView-startFullScreen: Failed to capture a display.");
            return NO;
        }
        /*err = CGDisplaySwitchToMode(kCGDirectMainDisplay, refDisplayMode);
        if (err != CGDisplayNoErr) {
            [fullScreenContext release];
            fullScreenContext = nil;
            NSLog(@"KarakuriGLView: Failed to switch display mode.");
            return NO;
        }*/
    } else {
        CGDisplayErr err = CGCaptureAllDisplays();
        if (err != CGDisplayNoErr) {
            NSLog(@"KarakuriGLView-startFullScreen: Failed to capture all displays.");
            return NO;
        }
    }
    
    // Hide mouse cursor
    if (!gKRGameMan->getShowsMouseCursor()) {
        CGDisplayHideCursor(kCGDirectMainDisplay);
    }
    
    NSOpenGLContext *fullScreenContext = [[NSOpenGLContext alloc] initWithFormat:pixelFormat shareContext:[self openGLContext]];
    mKRGLContext.cglFullScreenContext = (CGLContextObj)[fullScreenContext CGLContextObj];
    
    [pixelFormat release];
    pixelFormat = nil;
    
    if (!fullScreenContext) {
        NSLog(@"KarakuriGLView-startFullScreen: Failed to create full screen context.");
        return NO;
    }
    
    [fullScreenContext setFullScreen];
    [fullScreenContext makeCurrentContext];

    [[KRGameController sharedController] fullScreenGameProc];
    
    {
        CGDisplayFadeReservationToken newToken;
        CGAcquireDisplayFadeReservation(0.7, &newToken); // reserve display hardware time    
        CGDisplayFade(newToken,
                      0.7f,	 // 0.7 seconds
                      kCGDisplayBlendNormal,	// Starting state
                      kCGDisplayBlendSolidColor, // Ending state
                      0.0, 0.0, 0.0,	 // black
                      true);	 // wait for completion
        CGReleaseDisplayFadeReservation(newToken);
    }
    
    // Clear both front side and back side
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    [fullScreenContext flushBuffer];
    glClear(GL_COLOR_BUFFER_BIT);
    [fullScreenContext flushBuffer];
    
    // Exit fullscreen mode and release our FullScreen NSOpenGLContext.
    [NSOpenGLContext clearCurrentContext];
    [fullScreenContext clearDrawable];
    [fullScreenContext release];
    fullScreenContext = nil;
    
    if (mKRGLContext.oldScreenModeRef) {
        CGDisplaySwitchToMode(kCGDirectMainDisplay, mKRGLContext.oldScreenModeRef);
        mKRGLContext.oldScreenModeRef = nil;
    }
    
    // Show mouse cursor
    CGDisplayShowCursor(kCGDirectMainDisplay);
    
    // Release control of the display.
    CGReleaseAllDisplays();
    
    mKRGLContext.isFullScreen = NO;

    return YES;
}
#endif

#if KR_MACOSX
- (BOOL)stopFullScreen
{
    return YES;
}
#endif

#if KR_MACOSX
- (void)toggleFullScreen
{
    [self startFullScreen];
}
#endif

- (void)keyDown:(NSEvent *)theEvent
{
#if KR_MACOSX
    unsigned short keyCode = [theEvent keyCode];
    gKRInputInst->_processKeyDownCode(keyCode);
#endif
}

- (void)keyUp:(NSEvent *)theEvent
{
#if KR_MACOSX
    unsigned short keyCode = [theEvent keyCode];
    gKRInputInst->_processKeyUpCode(keyCode);
#endif
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    // Hide mouse cursor
    if (!gKRGameMan->getShowsMouseCursor()) {
        CGDisplayHideCursor(kCGDirectMainDisplay);
    }
}

- (void)mouseExited:(NSEvent *)theEvent
{
    // Show mouse cursor
    CGDisplayShowCursor(kCGDirectMainDisplay);
}

- (void)mouseDown:(NSEvent *)theEvent
{
#if KR_MACOSX
    gKRInputInst->_processMouseDown(KRInput::_MouseButtonLeft);
#endif
    
#if KR_IPHONE_MACOSX_EMU
    NSPoint pos = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    unsigned modifierFlags = [theEvent modifierFlags];

    NSPoint touchPos[3];
    
    touchPos[0] = pos;
    touchPos[1].x = -99999;
    touchPos[2].x = -99999;
    if (modifierFlags & NSAlternateKeyMask) {
        touchPos[1] = NSMakePoint(gKRScreenSize.x - pos.x, gKRScreenSize.y - pos.y);
    } else if (modifierFlags & NSCommandKeyMask) {
        touchPos[1] = NSMakePoint(pos.x + 40, pos.y + 40);
    } else if (modifierFlags & NSShiftKeyMask) {
        touchPos[1] = NSMakePoint(pos.x + 40, pos.y + 40);
        touchPos[2] = NSMakePoint(pos.x + 40*2, pos.y + 40*2);
    }
    
    [self clearTouches];
    for (int i = 0; i < 3; i++) {
        NSPoint pos = touchPos[i];
        if (pos.x < -9999.0f) {
            break;
        }
        if (pos.x < 0.0f) {
            pos.x = 0.0f;
        } else if (pos.x >= gKRScreenSize.x) {
            pos.x = gKRScreenSize.x - 1.0f;
        }
        if (pos.y < 0.0f) {
            pos.y = 0.0f;
        } else if (pos.y >= gKRScreenSize.y) {
            pos.y = gKRScreenSize.y - 1.0f;
        }
        gKRInputInst->_startTouch(i, pos.x, pos.y);
        [self addTouch:KRVector2D(pos.x, pos.y)];
    }
#endif
}

- (void)mouseUp:(NSEvent *)theEvent
{
#if KR_MACOSX
    gKRInputInst->_processMouseUp(KRInput::_MouseButtonLeft);
#endif

#if KR_IPHONE_MACOSX_EMU
    NSPoint pos = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    unsigned modifierFlags = [theEvent modifierFlags];

    NSPoint touchPos[3];

    touchPos[0] = pos;
    touchPos[1].x = -99999;
    touchPos[2].x = -99999;
    if (modifierFlags & NSAlternateKeyMask) {
        touchPos[1] = NSMakePoint(gKRScreenSize.x - pos.x, gKRScreenSize.y - pos.y);
    } else if (modifierFlags & NSCommandKeyMask) {
        touchPos[1] = NSMakePoint(pos.x + 40, pos.y + 40);
    } else if (modifierFlags & NSShiftKeyMask) {
        touchPos[1] = NSMakePoint(pos.x + 40, pos.y + 40);
        touchPos[2] = NSMakePoint(pos.x + 40*2, pos.y + 40*2);
    }
    
    for (int i = 0; i < 3; i++) {
        NSPoint pos = touchPos[i];
        if (pos.x < -9999.0f) {
            break;
        }
        if (pos.x < 0.0f) {
            pos.x = 0.0f;
        } else if (pos.x >= gKRScreenSize.x) {
            pos.x = gKRScreenSize.x - 1.0f;
        }
        if (pos.y < 0.0f) {
            pos.y = 0.0f;
        } else if (pos.y >= gKRScreenSize.y) {
            pos.y = gKRScreenSize.y - 1.0f;
        }
        gKRInputInst->_endTouch(i, pos.x, pos.y, 0, 0);
    }
    [self clearTouches];
#endif
}

#if KR_IPHONE_MACOSX_EMU
- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint pos = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    unsigned modifierFlags = [theEvent modifierFlags];

    NSPoint touchPos[3];
    
    touchPos[0] = pos;
    touchPos[1].x = -99999;
    touchPos[2].x = -99999;
    if (modifierFlags & NSAlternateKeyMask) {
        touchPos[1] = NSMakePoint(gKRScreenSize.x - pos.x, gKRScreenSize.y - pos.y);
    } else if (modifierFlags & NSCommandKeyMask) {
        touchPos[1] = NSMakePoint(pos.x + 40, pos.y + 40);
    } else if (modifierFlags & NSShiftKeyMask) {
        touchPos[1] = NSMakePoint(pos.x + 40, pos.y + 40);
        touchPos[2] = NSMakePoint(pos.x + 40*2, pos.y + 40*2);
    }
    
    [self clearTouches];
    for (int i = 0; i < 3; i++) {
        NSPoint pos = touchPos[i];
        if (pos.x < -9999.0f) {
            break;
        }
        if (pos.x < 0.0f) {
            pos.x = 0.0f;
        } else if (pos.x >= gKRScreenSize.x) {
            pos.x = gKRScreenSize.x - 1.0f;
        }
        if (pos.y < 0.0f) {
            pos.y = 0.0f;
        } else if (pos.y >= gKRScreenSize.y) {
            pos.y = gKRScreenSize.y - 1.0f;
        }
        gKRInputInst->_moveTouch(i, pos.x, pos.y, 0, 0);
        [self addTouch:KRVector2D(pos.x, pos.y)];
    }
}
#endif

- (void)rightMouseDown:(NSEvent *)theEvent
{
#if KR_MACOSX
    gKRInputInst->_processMouseDown(KRInput::_MouseButtonRight);
#endif
}

- (void)rightMouseUp:(NSEvent *)theEvent
{
#if KR_MACOSX
    gKRInputInst->_processMouseUp(KRInput::_MouseButtonRight);
#endif
}

- (void)clearMouseTrackingRect
{
    [self removeTrackingRect:mMouseTrackingRectTag];
}

#if KR_IPHONE_MACOSX_EMU
- (void)enableAccelerometer
{
    if (mIsAccelerometerEnabled) {
        return;
    }
    
    mIsAccelerometerEnabled = YES;
}

- (void)disableAccelerometer
{
    if (!mIsAccelerometerEnabled) {
        return;
    }
    
    mIsAccelerometerEnabled = NO;
}

- (BOOL)isAccelerometerEnabled
{
    return mIsAccelerometerEnabled;
}

- (void)drawTouches
{
    KRBlendMode oldBlendMode = gKRGraphicsInst->getBlendMode();
    gKRGraphicsInst->setBlendMode(KRBlendModeAlpha);

    for (int i = 0; i < 5; i++) {
        if (mTouchPos[i].x >= 0) {
            mTouchTex->drawAtPoint(mTouchPos[i].x-mTouchTex->getWidth()/2, mTouchPos[i].y-mTouchTex->getHeight()/2);
        }
    }
    
    gKRGraphicsInst->setBlendMode(oldBlendMode);
}

- (void)addTouch:(KRVector2D)pos
{
    for (int i = 0; i < 5; i++) {
        if (mTouchPos[i].x < 0) {
            mTouchPos[i] = pos;
            break;
        }
    }
}

- (void)clearTouches
{
    for (int i = 0; i < 5; i++) {
        mTouchPos[i].x = -1;
        mTouchPos[i].y = -1;
    }
}
#endif

@end


