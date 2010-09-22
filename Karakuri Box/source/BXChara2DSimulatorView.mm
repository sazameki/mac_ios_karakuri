//
//  BXChara2DSimulatorView.m
//  Karakuri Box
//
//  Created by numata on 10/03/11.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BXChara2DSimulatorView.h"


static const KRKeyInfo      KeyA           = (0x1LL << 10);
static const KRKeyInfo      KeyB           = (0x1LL << 11);
static const KRKeyInfo      KeyC           = (0x1LL << 12);
static const KRKeyInfo      KeyD           = (0x1LL << 13);
static const KRKeyInfo      KeyE           = (0x1LL << 14);
static const KRKeyInfo      KeyF           = (0x1LL << 15);
static const KRKeyInfo      KeyG           = (0x1LL << 16);
static const KRKeyInfo      KeyH           = (0x1LL << 17);
static const KRKeyInfo      KeyI           = (0x1LL << 18);
static const KRKeyInfo      KeyJ           = (0x1LL << 19);
static const KRKeyInfo      KeyK           = (0x1LL << 20);
static const KRKeyInfo      KeyL           = (0x1LL << 21);
static const KRKeyInfo      KeyM           = (0x1LL << 22);
static const KRKeyInfo      KeyN           = (0x1LL << 23);
static const KRKeyInfo      KeyO           = (0x1LL << 24);
static const KRKeyInfo      KeyP           = (0x1LL << 25);
static const KRKeyInfo      KeyQ           = (0x1LL << 26);
static const KRKeyInfo      KeyR           = (0x1LL << 27);
static const KRKeyInfo      KeyS           = (0x1LL << 28);
static const KRKeyInfo      KeyT           = (0x1LL << 29);
static const KRKeyInfo      KeyU           = (0x1LL << 30);
static const KRKeyInfo      KeyV           = (0x1LL << 31);
static const KRKeyInfo      KeyW           = (0x1LL << 32);
static const KRKeyInfo      KeyX           = (0x1LL << 33);
static const KRKeyInfo      KeyY           = (0x1LL << 34);
static const KRKeyInfo      KeyZ           = (0x1LL << 35);
static const KRKeyInfo      KeyUp          = (0x1LL << 36);
static const KRKeyInfo      KeyDown        = (0x1LL << 37);
static const KRKeyInfo      KeyLeft        = (0x1LL << 38);
static const KRKeyInfo      KeyRight       = (0x1LL << 39);
static const KRKeyInfo      KeyReturn      = (0x1LL << 40);
static const KRKeyInfo      KeySpace       = (0x1LL << 41);
static const KRKeyInfo      KeyBackspace   = (0x1LL << 42);
static const KRKeyInfo      KeyDelete      = (0x1LL << 43);
static const KRKeyInfo      KeyTab         = (0x1LL << 44);
static const KRKeyInfo      KeyEscape      = (0x1LL << 45);

static const KRMouseInfo    MouseButtonLeft = 0x01;

static const unsigned       KRCharaMotionChangeModeNormalMask            = 0x00;
static const unsigned       KRCharaMotionChangeModeIgnoreCancelFlagMask  = 0x01;
static const unsigned       KRCharaMotionChangeModeSkipEndMask           = 0x02;



@interface BXChara2DSimulatorView ()

- (KRKeyInfo)keyState;
- (KRKeyInfo)keyStateOnce;
- (KRMouseInfo)mouseState;
- (KRMouseInfo)mouseStateOnce;

- (int)getCurrentMotionID;

- (void)changeMotion:(int)motionID koma:(int)komaNumber mode:(unsigned)mask;

@end


@implementation BXChara2DSimulatorView

- (BOOL)acceptsFirstResponder { return YES; }


#pragma mark -
#pragma mark 初期化・クリーンアップ

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        mIsAnimationRunning = NO;

        mTargetSpec = NULL;
        mCurrentPos = new KRVector2D();

        mKeyState = 0;
        mKeyStateOld = 0;
        mMouseState = 0;
        mMouseStateOld = 0;
    }
    return self;
}

- (void)dealloc
{
    delete mCurrentPos;
    
    [super dealloc];
}


#pragma mark -
#pragma mark アクセッサ

- (int)getCurrentMotionID
{
    if (mNextMotion) {
        return [mNextMotion motionID];
    }

    return [mCurrentMotion motionID];
}

- (NSMenu*)makeMotionButtonMenu
{
    NSMenu* theMenu = [[[NSMenu alloc] initWithTitle:@"Motion Button"] autorelease];
    
    for (int i = 0; i < [mTargetSpec motionCount]; i++) {
        BXChara2DMotion* theMotion = [mTargetSpec motionAtIndex:i];
        NSMenuItem* theItem = [theMenu addItemWithTitle:[NSString stringWithFormat:@"%d: %@", [theMotion motionID], [theMotion motionName]]
                                                 action:nil
                                          keyEquivalent:@""];
        [theItem setTag:[theMotion motionID]];
    }
    
    return theMenu;
}

- (void)updateMotionButtons
{
    [oFirstMotionButton setMenu:[self makeMotionButtonMenu]];
    [oActionMotionButtonDown setMenu:[self makeMotionButtonMenu]];
    [oActionMotionButtonUp setMenu:[self makeMotionButtonMenu]];
    [oActionMotionButtonLeft setMenu:[self makeMotionButtonMenu]];
    [oActionMotionButtonRight setMenu:[self makeMotionButtonMenu]];
    [oActionMotionButtonZ setMenu:[self makeMotionButtonMenu]];
    [oActionMotionButtonX setMenu:[self makeMotionButtonMenu]];
    [oActionMotionButtonC setMenu:[self makeMotionButtonMenu]];
    [oActionMotionButtonMouse setMenu:[self makeMotionButtonMenu]];
}

- (void)saveAnimationSettings
{
    [mTargetSpec setFirstMotionID:[oFirstMotionButton selectedTag]];
    [mTargetSpec setFirstMotionKomaNumber:[oFirstMotionKomaButton selectedTag]];
    [mTargetSpec setRevertToFirstMotion:([oRevertToFirstMotionWithNoKeyButton state] == NSOnState)];
    [mTargetSpec setIgnoresCancelFlag:([oIgnoreCancelDeclRevertToFirstMotion state] == NSOnState)];
    [mTargetSpec setSkipEndAnimation:([oIgnoreFinalAnimationRevertToFirstMotion state] == NSOnState)];

    [mTargetSpec setActionMotionIDUp:[oActionMotionButtonUp selectedTag]];
    [mTargetSpec setActionKomaNumberUp:[oActionMotionKomaButtonUp selectedTag]];
    [mTargetSpec setIgnoresCancelFlagUp:([oIgnoreCancelDeclButtonUp state] == NSOnState)];
    [mTargetSpec setSkipEndAnimationUp:([oIgnoreFinalAnimationButtonUp state] == NSOnState)];
    [mTargetSpec setActionSpeedUp:[oActionSpeedFieldUp intValue]];
    
    [mTargetSpec setActionMotionIDDown:[oActionMotionButtonDown selectedTag]];
    [mTargetSpec setActionKomaNumberDown:[oActionMotionKomaButtonDown selectedTag]];
    [mTargetSpec setIgnoresCancelFlagDown:([oIgnoreCancelDeclButtonDown state] == NSOnState)];
    [mTargetSpec setSkipEndAnimationDown:([oIgnoreFinalAnimationButtonDown state] == NSOnState)];
    [mTargetSpec setActionSpeedDown:[oActionSpeedFieldDown intValue]];
    
    [mTargetSpec setActionMotionIDLeft:[oActionMotionButtonLeft selectedTag]];
    [mTargetSpec setActionKomaNumberLeft:[oActionMotionKomaButtonLeft selectedTag]];
    [mTargetSpec setIgnoresCancelFlagLeft:([oIgnoreCancelDeclButtonLeft state] == NSOnState)];
    [mTargetSpec setSkipEndAnimationLeft:([oIgnoreFinalAnimationButtonLeft state] == NSOnState)];
    [mTargetSpec setActionSpeedLeft:[oActionSpeedFieldLeft intValue]];
    
    [mTargetSpec setActionMotionIDRight:[oActionMotionButtonRight selectedTag]];
    [mTargetSpec setActionKomaNumberRight:[oActionMotionKomaButtonRight selectedTag]];
    [mTargetSpec setIgnoresCancelFlagRight:([oIgnoreCancelDeclButtonRight state] == NSOnState)];
    [mTargetSpec setSkipEndAnimationRight:([oIgnoreFinalAnimationButtonRight state] == NSOnState)];
    [mTargetSpec setActionSpeedRight:[oActionSpeedFieldRight intValue]];
    
    [mTargetSpec setActionMotionIDZ:[oActionMotionButtonZ selectedTag]];
    [mTargetSpec setActionKomaNumberZ:[oActionMotionKomaButtonZ selectedTag]];
    [mTargetSpec setIgnoresCancelFlagZ:([oIgnoreCancelDeclButtonZ state] == NSOnState)];
    [mTargetSpec setSkipEndAnimationZ:([oIgnoreFinalAnimationButtonZ state] == NSOnState)];
    
    [mTargetSpec setActionMotionIDX:[oActionMotionButtonX selectedTag]];
    [mTargetSpec setActionKomaNumberX:[oActionMotionKomaButtonX selectedTag]];
    [mTargetSpec setIgnoresCancelFlagX:([oIgnoreCancelDeclButtonX state] == NSOnState)];
    [mTargetSpec setSkipEndAnimationX:([oIgnoreFinalAnimationButtonX state] == NSOnState)];
    
    [mTargetSpec setActionMotionIDC:[oActionMotionButtonC selectedTag]];
    [mTargetSpec setActionKomaNumberC:[oActionMotionKomaButtonC selectedTag]];
    [mTargetSpec setIgnoresCancelFlagC:([oIgnoreCancelDeclButtonC state] == NSOnState)];
    [mTargetSpec setSkipEndAnimationC:([oIgnoreFinalAnimationButtonC state] == NSOnState)];
    
    [mTargetSpec setActionMotionIDMouse:[oActionMotionButtonMouse selectedTag]];
    [mTargetSpec setActionKomaNumberMouse:[oActionMotionKomaButtonMouse selectedTag]];
    [mTargetSpec setIgnoresCancelFlagMouse:([oIgnoreCancelDeclButtonMouse state] == NSOnState)];
    [mTargetSpec setSkipEndAnimationMouse:([oIgnoreFinalAnimationButtonMouse state] == NSOnState)];
    [mTargetSpec setDoChangeMouseLocation:([oDoChangeLocationButtonMouse state] == NSOnState)];
}

- (void)setupForChara2DSpec:(BXChara2DSpec*)aSpec
{
    [self setNeedsDisplay:YES];
    
    *mCurrentPos = KRVector2D(100, 100);

    CGLLockContext(mCGLContext);
    CGLSetCurrentContext(mCGLContext);

    mTargetSpec = aSpec;
    
    [mTargetSpec preparePreviewTextures];

    CGLUnlockContext(mCGLContext);
    
    [oCurrentMotionField setStringValue:@"--------"];
    
    [oActionSpeedFieldUp setIntValue:2];
    [oActionSpeedFieldDown setIntValue:2];
    [oActionSpeedFieldLeft setIntValue:2];
    [oActionSpeedFieldRight setIntValue:2];    
    
    [self updateMotionButtons];
    
    // 最初のモーションの読み込み
    int firstMotionID = [mTargetSpec firstMotionID];
    int firstKomaNumber = [mTargetSpec firstMotionKomaNumber];
    if (![mTargetSpec motionWithID:firstMotionID]) {
        firstMotionID = [[mTargetSpec motionAtIndex:0] motionID];
        firstKomaNumber = 1;
    }
    [oFirstMotionButton selectItemWithTag:firstMotionID];
    [self changedFirstMotion:self];
    [oFirstMotionKomaButton selectItemWithTag:firstKomaNumber];
    [oIgnoreCancelDeclRevertToFirstMotion setState:([mTargetSpec ignoresCancelFlag]? NSOnState: NSOffState)];
    [oRevertToFirstMotionWithNoKeyButton setState:([mTargetSpec revertToFirstMotion]? NSOnState: NSOffState)];
    [oIgnoreFinalAnimationRevertToFirstMotion setState:([mTargetSpec skipEndAnimation]? NSOnState: NSOffState)];
    
    // KeyDown
    int downMotionID = [mTargetSpec actionMotionIDDown];
    int downKomaNumber = [mTargetSpec actionKomaNumberDown];
    if (![mTargetSpec motionWithID:downMotionID]) {
        downMotionID = [[mTargetSpec motionAtIndex:0] motionID];
        downKomaNumber = 1;
    }
    [oActionMotionButtonDown selectItemWithTag:downMotionID];
    [self changedActionMotionDown:self];
    [oActionMotionKomaButtonDown selectItemWithTag:downKomaNumber];
    [oIgnoreCancelDeclButtonDown setState:([mTargetSpec ignoresCancelFlagDown]? NSOnState: NSOffState)];
    [oIgnoreFinalAnimationButtonDown setState:([mTargetSpec skipEndAnimationDown]? NSOnState: NSOffState)];
    [oActionSpeedFieldDown setIntValue:[mTargetSpec actionSpeedDown]];

    // KeyUp
    int upMotionID = [mTargetSpec actionMotionIDUp];
    int upKomaNumber = [mTargetSpec actionKomaNumberUp];
    if (![mTargetSpec motionWithID:upMotionID]) {
        upMotionID = [[mTargetSpec motionAtIndex:0] motionID];
        upKomaNumber = 1;
    }
    [oActionMotionButtonUp selectItemWithTag:upMotionID];
    [self changedActionMotionUp:self];
    [oActionMotionKomaButtonUp selectItemWithTag:upKomaNumber];
    [oIgnoreCancelDeclButtonUp setState:([mTargetSpec ignoresCancelFlagUp]? NSOnState: NSOffState)];
    [oIgnoreFinalAnimationButtonUp setState:([mTargetSpec skipEndAnimationUp]? NSOnState: NSOffState)];
    [oActionSpeedFieldUp setIntValue:[mTargetSpec actionSpeedUp]];

    // Left
    int leftMotionID = [mTargetSpec actionMotionIDLeft];
    int leftKomaNumber = [mTargetSpec actionKomaNumberLeft];
    if (![mTargetSpec motionWithID:leftMotionID]) {
        leftMotionID = [[mTargetSpec motionAtIndex:0] motionID];
        leftKomaNumber = 1;
    }
    [oActionMotionButtonLeft selectItemWithTag:leftMotionID];
    [self changedActionMotionLeft:self];
    [oActionMotionKomaButtonLeft selectItemWithTag:leftKomaNumber];
    [oIgnoreCancelDeclButtonLeft setState:([mTargetSpec ignoresCancelFlagLeft]? NSOnState: NSOffState)];
    [oIgnoreFinalAnimationButtonLeft setState:([mTargetSpec skipEndAnimationLeft]? NSOnState: NSOffState)];
    [oActionSpeedFieldLeft setIntValue:[mTargetSpec actionSpeedLeft]];

    // Right
    int rightMotionID = [mTargetSpec actionMotionIDRight];
    int rightKomaNumber = [mTargetSpec actionKomaNumberRight];
    if (![mTargetSpec motionWithID:rightMotionID]) {
        rightMotionID = [[mTargetSpec motionAtIndex:0] motionID];
        rightKomaNumber = 1;
    }
    [oActionMotionButtonRight selectItemWithTag:rightMotionID];
    [self changedActionMotionRight:self];
    [oActionMotionKomaButtonRight selectItemWithTag:rightKomaNumber];
    [oIgnoreCancelDeclButtonRight setState:([mTargetSpec ignoresCancelFlagRight]? NSOnState: NSOffState)];
    [oIgnoreFinalAnimationButtonRight setState:([mTargetSpec skipEndAnimationRight]? NSOnState: NSOffState)];
    [oActionSpeedFieldRight setIntValue:[mTargetSpec actionSpeedRight]];

    // KeyZ
    int zMotionID = [mTargetSpec actionMotionIDZ];
    int zKomaNumber = [mTargetSpec actionKomaNumberZ];
    if (![mTargetSpec motionWithID:zMotionID]) {
        zMotionID = [[mTargetSpec motionAtIndex:0] motionID];
        zKomaNumber = 1;
    }
    [oActionMotionButtonZ selectItemWithTag:zMotionID];
    [self changedActionMotionZ:self];
    [oActionMotionKomaButtonZ selectItemWithTag:zKomaNumber];
    [oIgnoreCancelDeclButtonZ setState:([mTargetSpec ignoresCancelFlagZ]? NSOnState: NSOffState)];
    [oIgnoreFinalAnimationButtonZ setState:([mTargetSpec skipEndAnimationZ]? NSOnState: NSOffState)];

    // KeyX
    int xMotionID = [mTargetSpec actionMotionIDX];
    int xKomaNumber = [mTargetSpec actionKomaNumberX];
    if (![mTargetSpec motionWithID:xMotionID]) {
        xMotionID = [[mTargetSpec motionAtIndex:0] motionID];
        xKomaNumber = 1;
    }
    [oActionMotionButtonX selectItemWithTag:xMotionID];
    [self changedActionMotionX:self];
    [oActionMotionKomaButtonX selectItemWithTag:xKomaNumber];
    [oIgnoreCancelDeclButtonX setState:([mTargetSpec ignoresCancelFlagX]? NSOnState: NSOffState)];
    [oIgnoreFinalAnimationButtonX setState:([mTargetSpec skipEndAnimationX]? NSOnState: NSOffState)];

    // KeyC
    int cMotionID = [mTargetSpec actionMotionIDC];
    int cKomaNumber = [mTargetSpec actionKomaNumberC];
    if (![mTargetSpec motionWithID:cMotionID]) {
        cMotionID = [[mTargetSpec motionAtIndex:0] motionID];
        cKomaNumber = 1;
    }
    [oActionMotionButtonC selectItemWithTag:cMotionID];
    [self changedActionMotionC:self];
    [oActionMotionKomaButtonC selectItemWithTag:cKomaNumber];
    [oIgnoreCancelDeclButtonC setState:([mTargetSpec ignoresCancelFlagC]? NSOnState: NSOffState)];
    [oIgnoreFinalAnimationButtonC setState:([mTargetSpec skipEndAnimationC]? NSOnState: NSOffState)];

    // Mouse
    int mouseMotionID = [mTargetSpec actionMotionIDMouse];
    int mouseKomaNumber = [mTargetSpec actionKomaNumberMouse];
    if (![mTargetSpec motionWithID:mouseMotionID]) {
        mouseMotionID = [[mTargetSpec motionAtIndex:0] motionID];
        mouseKomaNumber = 1;
    }
    [oActionMotionButtonMouse selectItemWithTag:mouseMotionID];
    [self changedActionMotionMouse:self];
    [oActionMotionKomaButtonMouse selectItemWithTag:mouseKomaNumber];
    [oIgnoreCancelDeclButtonMouse setState:([mTargetSpec ignoresCancelFlagMouse]? NSOnState: NSOffState)];
    [oIgnoreFinalAnimationButtonMouse setState:([mTargetSpec skipEndAnimationMouse]? NSOnState: NSOffState)];
    [oDoChangeLocationButtonMouse setState:([mTargetSpec doChangeMouseLocation]? NSOnState: NSOffState)];
    
    mNextMotion = nil;
    mNextKoma = nil;
}

- (void)glDrawMain
{
    mGraphics->clear(KRColor::Black);
    
    if (mCurrentKoma != NULL) {
        KRTexture2D* theTex = [mCurrentKoma previewTexture];
        if (theTex != NULL) {
            theTex->drawAtPoint(*mCurrentPos, KRColor::White);
        }
    }
}

- (NSMenu*)makeKomaMenuForMotion:(BXChara2DMotion*)aMotion
{
    NSMenu* theMenu = [[[NSMenu alloc] initWithTitle:@"Koma Button Menu"] autorelease];
    
    for (int i = 0; i < [aMotion komaCount]; i++) {
        BXChara2DKoma* aKoma = [aMotion komaAtIndex:i];
        NSMenuItem* theItem = [theMenu addItemWithTitle:[NSString stringWithFormat:@"%d", [aKoma komaNumber]-1]
                                                 action:nil
                                          keyEquivalent:@""];
        [theItem setTag:[aKoma komaNumber]];
    }
    
    return theMenu;
}

- (void)changeMotion:(int)motionID koma:(int)komaNumber mode:(unsigned)mask
{
    if (mNextMotion && [mNextMotion motionID] == motionID && [mNextKoma komaNumber] == komaNumber) {
        return;
    }
    
    mNextMotion = [mTargetSpec motionWithID:motionID];
    mNextKoma = [mNextMotion komaWithNumber:komaNumber];
    
    mHasChangingStarted = NO;
    mSkipEndToNext = (mask & KRCharaMotionChangeModeSkipEndMask)? YES: NO;
    
    if ([mCurrentKoma isCancelable] || (mask & KRCharaMotionChangeModeIgnoreCancelFlagMask)) {
        mHasChangingStarted = YES;
        if (mSkipEndToNext || ![mCurrentMotion targetKomaForCancel]) {
            mCurrentMotion = mNextMotion;
            mCurrentKoma = mNextKoma;
            mNextMotion = nil;
            mNextKoma = nil;
            mKomaNumber = [mCurrentKoma komaNumber];
            mKomaInterval = [mCurrentKoma interval];
            if (mKomaInterval == 0) {
                mKomaInterval = [mCurrentMotion defaultKomaInterval];
            }
        } else {
            BXChara2DKoma* endStartKoma = [mCurrentMotion targetKomaForCancel];
            mCurrentKoma = endStartKoma;
            mKomaNumber = [mCurrentKoma komaNumber];
            mKomaInterval = [mCurrentKoma interval];
            if (mKomaInterval == 0) {
                mKomaInterval = [mCurrentMotion defaultKomaInterval];
            }
        }
    }    
}

- (IBAction)changedFirstMotion:(id)sender
{
    mCurrentMotion = nil;
    mCurrentKoma = nil;

    if ([mTargetSpec motionCount] == 0) {
        return;
    }

    int theMotionID = [oFirstMotionButton selectedTag];
    mCurrentMotion = [mTargetSpec motionWithID:theMotionID];

    [oFirstMotionKomaButton setMenu:[self makeKomaMenuForMotion:mCurrentMotion]];
    [self changedFirstMotionKoma:self];
    
    [self setNeedsDisplay:YES];
    
    [[self window] makeFirstResponder:self];
}

- (IBAction)changedFirstMotionKoma:(id)sender
{
    int theKomaNumber = [oFirstMotionKomaButton selectedTag];
    mKomaNumber = theKomaNumber;
    mCurrentKoma = [mCurrentMotion komaWithNumber:theKomaNumber];
    mKomaInterval = [mCurrentKoma interval];
    if (mKomaInterval == 0) {
        mKomaInterval = [mCurrentMotion defaultKomaInterval];
    }

    NSString* motionStr = [NSString stringWithFormat:@"%d[%@] - %d", [mCurrentMotion motionID], [mCurrentMotion motionName], [mCurrentKoma komaNumber]-1];
    [oCurrentMotionField setStringValue:motionStr];

    [self setNeedsDisplay:YES];

    [[self window] makeFirstResponder:self];
}

- (IBAction)changedActionMotionDown:(id)sender
{
    int motionID = [oActionMotionButtonDown selectedTag];
    BXChara2DMotion* theMotion = [mTargetSpec motionWithID:motionID];
    
    [oActionMotionKomaButtonDown setMenu:[self makeKomaMenuForMotion:theMotion]];    
}

- (IBAction)changedActionMotionUp:(id)sender
{
    int motionID = [oActionMotionButtonUp selectedTag];
    BXChara2DMotion* theMotion = [mTargetSpec motionWithID:motionID];
    
    [oActionMotionKomaButtonUp setMenu:[self makeKomaMenuForMotion:theMotion]];    
}

- (IBAction)changedActionMotionLeft:(id)sender
{
    int motionID = [oActionMotionButtonLeft selectedTag];
    BXChara2DMotion* theMotion = [mTargetSpec motionWithID:motionID];
    
    [oActionMotionKomaButtonLeft setMenu:[self makeKomaMenuForMotion:theMotion]];    
}

- (IBAction)changedActionMotionRight:(id)sender
{
    int motionID = [oActionMotionButtonRight selectedTag];
    BXChara2DMotion* theMotion = [mTargetSpec motionWithID:motionID];
    
    [oActionMotionKomaButtonRight setMenu:[self makeKomaMenuForMotion:theMotion]];    
}

- (IBAction)changedActionMotionZ:(id)sender
{
    int motionID = [oActionMotionButtonZ selectedTag];
    BXChara2DMotion* theMotion = [mTargetSpec motionWithID:motionID];
    
    [oActionMotionKomaButtonZ setMenu:[self makeKomaMenuForMotion:theMotion]];    
}

- (IBAction)changedActionMotionX:(id)sender
{
    int motionID = [oActionMotionButtonX selectedTag];
    BXChara2DMotion* theMotion = [mTargetSpec motionWithID:motionID];
    
    [oActionMotionKomaButtonX setMenu:[self makeKomaMenuForMotion:theMotion]];    
}

- (IBAction)changedActionMotionC:(id)sender
{
    int motionID = [oActionMotionButtonC selectedTag];
    BXChara2DMotion* theMotion = [mTargetSpec motionWithID:motionID];
    
    [oActionMotionKomaButtonC setMenu:[self makeKomaMenuForMotion:theMotion]];    
}

- (IBAction)changedActionMotionMouse:(id)sender
{
    int motionID = [oActionMotionButtonMouse selectedTag];
    BXChara2DMotion* theMotion = [mTargetSpec motionWithID:motionID];
    
    [oActionMotionKomaButtonMouse setMenu:[self makeKomaMenuForMotion:theMotion]];
}

- (IBAction)startAnimation:(id)sender
{
    if (mIsAnimationRunning) {
        return;
    }
    mIsAnimationRunning = YES;
    mHadInput = NO;
    
    [oFirstMotionButton setEnabled:NO];
    [oFirstMotionKomaButton setEnabled:NO];
    [oRevertToFirstMotionWithNoKeyButton setEnabled:NO];
    [oIgnoreCancelDeclRevertToFirstMotion setEnabled:NO];
    [oIgnoreFinalAnimationRevertToFirstMotion setEnabled:NO];

    [oActionMotionButtonUp setEnabled:NO];
    [oActionMotionKomaButtonUp setEnabled:NO];
    [oIgnoreCancelDeclButtonUp setEnabled:NO];
    [oIgnoreFinalAnimationButtonUp setEnabled:NO];
    [oActionSpeedFieldUp setEnabled:NO];

    [oActionMotionButtonDown setEnabled:NO];
    [oActionMotionKomaButtonDown setEnabled:NO];
    [oIgnoreCancelDeclButtonDown setEnabled:NO];
    [oIgnoreFinalAnimationButtonDown setEnabled:NO];
    [oActionSpeedFieldDown setEnabled:NO];

    [oActionMotionButtonLeft setEnabled:NO];
    [oActionMotionKomaButtonLeft setEnabled:NO];
    [oIgnoreCancelDeclButtonLeft setEnabled:NO];
    [oIgnoreFinalAnimationButtonLeft setEnabled:NO];
    [oActionSpeedFieldLeft setEnabled:NO];

    [oActionMotionButtonRight setEnabled:NO];
    [oActionMotionKomaButtonRight setEnabled:NO];
    [oIgnoreCancelDeclButtonRight setEnabled:NO];
    [oIgnoreFinalAnimationButtonRight setEnabled:NO];
    [oActionSpeedFieldRight setEnabled:NO];    

    [oActionMotionButtonZ setEnabled:NO];
    [oActionMotionKomaButtonZ setEnabled:NO];
    [oIgnoreCancelDeclButtonZ setEnabled:NO];
    [oIgnoreFinalAnimationButtonZ setEnabled:NO];
    
    [oActionMotionButtonX setEnabled:NO];
    [oActionMotionKomaButtonX setEnabled:NO];
    [oIgnoreCancelDeclButtonX setEnabled:NO];
    [oIgnoreFinalAnimationButtonX setEnabled:NO];
    
    [oActionMotionButtonC setEnabled:NO];
    [oActionMotionKomaButtonC setEnabled:NO];
    [oIgnoreCancelDeclButtonC setEnabled:NO];
    [oIgnoreFinalAnimationButtonC setEnabled:NO];

    [oActionMotionButtonMouse setEnabled:NO];
    [oActionMotionKomaButtonMouse setEnabled:NO];
    [oIgnoreCancelDeclButtonMouse setEnabled:NO];
    [oIgnoreFinalAnimationButtonMouse setEnabled:NO];
    [oDoChangeLocationButtonMouse setEnabled:NO];
    
    [oAnimationButton setAction:@selector(stopAnimation:)];
    [oAnimationButton setTitle:NSLocalizedString(@"Chara2D Simulator Animation Button Stop", nil)];
    
    [self changedFirstMotionKoma:self];
    
    [[self window] makeFirstResponder:self];
    
    [NSThread detachNewThreadSelector:@selector(refreshProc:) toTarget:self withObject:nil];
}

- (IBAction)stopAnimation:(id)sender
{
    if (!mIsAnimationRunning) {
        return;
    }
    mIsAnimationRunning = NO;
    
    [oFirstMotionButton setEnabled:YES];
    [oFirstMotionKomaButton setEnabled:YES];
    [oRevertToFirstMotionWithNoKeyButton setEnabled:YES];
    [oIgnoreCancelDeclRevertToFirstMotion setEnabled:YES];
    [oIgnoreFinalAnimationRevertToFirstMotion setEnabled:YES];

    [oActionMotionButtonUp setEnabled:YES];
    [oActionMotionKomaButtonUp setEnabled:YES];
    [oIgnoreCancelDeclButtonUp setEnabled:YES];
    [oIgnoreFinalAnimationButtonUp setEnabled:YES];
    [oActionSpeedFieldUp setEnabled:YES];
    
    [oActionMotionButtonDown setEnabled:YES];
    [oActionMotionKomaButtonDown setEnabled:YES];
    [oIgnoreCancelDeclButtonDown setEnabled:YES];
    [oIgnoreFinalAnimationButtonDown setEnabled:YES];
    [oActionSpeedFieldDown setEnabled:YES];

    [oActionMotionButtonLeft setEnabled:YES];
    [oActionMotionKomaButtonLeft setEnabled:YES];
    [oIgnoreCancelDeclButtonLeft setEnabled:YES];
    [oIgnoreFinalAnimationButtonLeft setEnabled:YES];
    [oActionSpeedFieldLeft setEnabled:YES];

    [oActionMotionButtonRight setEnabled:YES];
    [oActionMotionKomaButtonRight setEnabled:YES];
    [oIgnoreCancelDeclButtonRight setEnabled:YES];
    [oIgnoreFinalAnimationButtonRight setEnabled:YES];
    [oActionSpeedFieldRight setEnabled:YES];

    [oActionMotionButtonZ setEnabled:YES];
    [oActionMotionKomaButtonZ setEnabled:YES];
    [oIgnoreCancelDeclButtonZ setEnabled:YES];
    [oIgnoreFinalAnimationButtonZ setEnabled:YES];
    
    [oActionMotionButtonX setEnabled:YES];
    [oActionMotionKomaButtonX setEnabled:YES];
    [oIgnoreCancelDeclButtonX setEnabled:YES];
    [oIgnoreFinalAnimationButtonX setEnabled:YES];
    
    [oActionMotionButtonC setEnabled:YES];
    [oActionMotionKomaButtonC setEnabled:YES];
    [oIgnoreCancelDeclButtonC setEnabled:YES];
    [oIgnoreFinalAnimationButtonC setEnabled:YES];
    
    [oActionMotionButtonMouse setEnabled:YES];
    [oActionMotionKomaButtonMouse setEnabled:YES];
    [oIgnoreCancelDeclButtonMouse setEnabled:YES];
    [oIgnoreFinalAnimationButtonMouse setEnabled:YES];
    [oDoChangeLocationButtonMouse setEnabled:YES];
    
    [oAnimationButton setAction:@selector(startAnimation:)];
    [oAnimationButton setTitle:NSLocalizedString(@"Chara2D Simulator Animation Button Start", nil)];
    
    *mCurrentPos = KRVector2D(100, 100);
    
    [self changedFirstMotion:self];
}

- (void)updateModel
{
    NSRect frame = [self frame];
    
    KRKeyInfo key = [self keyState];
    KRKeyInfo keyOnce = [self keyStateOnce];
    KRMouseInfo mouse = [self mouseState];
    KRMouseInfo mouseOnce = [self mouseStateOnce];
    
    if (key & KeyLeft) {
        int nextMotionID = [oActionMotionButtonLeft selectedTag];
        if ([self getCurrentMotionID] != nextMotionID) {
            unsigned changeMask = KRCharaMotionChangeModeNormalMask;
            if ([oIgnoreCancelDeclButtonLeft state] == NSOnState) {
                changeMask |= KRCharaMotionChangeModeIgnoreCancelFlagMask;
            }
            if ([oIgnoreFinalAnimationButtonLeft state] == NSOnState) {
                changeMask |= KRCharaMotionChangeModeSkipEndMask;
            }
            int nextKomaNumber = [oActionMotionKomaButtonLeft selectedTag];
            
            [self changeMotion:nextMotionID koma:nextKomaNumber mode:changeMask];            
        }
        
        int speed = [oActionSpeedFieldLeft intValue];
        mCurrentPos->x -= speed;
    }
    if (key & KeyRight) {
        int nextMotionID = [oActionMotionButtonRight selectedTag];
        if ([self getCurrentMotionID] != nextMotionID) {
            unsigned changeMask = KRCharaMotionChangeModeNormalMask;
            if ([oIgnoreCancelDeclButtonRight state] == NSOnState) {
                changeMask |= KRCharaMotionChangeModeIgnoreCancelFlagMask;
            }
            if ([oIgnoreFinalAnimationButtonRight state] == NSOnState) {
                changeMask |= KRCharaMotionChangeModeSkipEndMask;
            }
            int nextKomaNumber = [oActionMotionKomaButtonRight selectedTag];
            
            [self changeMotion:nextMotionID koma:nextKomaNumber mode:changeMask];            
        }

        int speed = [oActionSpeedFieldRight intValue];
        mCurrentPos->x += speed;
    }
    if (key & KeyUp) {
        int nextMotionID = [oActionMotionButtonUp selectedTag];
        if ([self getCurrentMotionID] != nextMotionID) {
            unsigned changeMask = KRCharaMotionChangeModeNormalMask;
            if ([oIgnoreCancelDeclButtonUp state] == NSOnState) {
                changeMask |= KRCharaMotionChangeModeIgnoreCancelFlagMask;
            }
            if ([oIgnoreFinalAnimationButtonUp state] == NSOnState) {
                changeMask |= KRCharaMotionChangeModeSkipEndMask;
            }
            int nextKomaNumber = [oActionMotionKomaButtonUp selectedTag];
            
            [self changeMotion:nextMotionID koma:nextKomaNumber mode:changeMask];            
        }
        
        int speed = [oActionSpeedFieldUp intValue];
        mCurrentPos->y += speed;
    }
    if (key & KeyDown) {
        int nextMotionID = [oActionMotionButtonDown selectedTag];
        if ([self getCurrentMotionID] != nextMotionID) {
            unsigned changeMask = KRCharaMotionChangeModeNormalMask;
            if ([oIgnoreCancelDeclButtonDown state] == NSOnState) {
                changeMask |= KRCharaMotionChangeModeIgnoreCancelFlagMask;
            }
            if ([oIgnoreFinalAnimationButtonDown state] == NSOnState) {
                changeMask |= KRCharaMotionChangeModeSkipEndMask;
            }
            int nextKomaNumber = [oActionMotionKomaButtonDown selectedTag];
            
            [self changeMotion:nextMotionID koma:nextKomaNumber mode:changeMask];            
        }

        int speed = [oActionSpeedFieldDown intValue];
        mCurrentPos->y -= speed;
    }
    if (keyOnce & KeyZ) {
        int nextMotionID = [oActionMotionButtonZ selectedTag];
        if ([self getCurrentMotionID] != nextMotionID) {
            unsigned changeMask = KRCharaMotionChangeModeNormalMask;
            if ([oIgnoreCancelDeclButtonZ state] == NSOnState) {
                changeMask |= KRCharaMotionChangeModeIgnoreCancelFlagMask;
            }
            if ([oIgnoreFinalAnimationButtonZ state] == NSOnState) {
                changeMask |= KRCharaMotionChangeModeSkipEndMask;
            }
            int nextKomaNumber = [oActionMotionKomaButtonZ selectedTag];
            
            [self changeMotion:nextMotionID koma:nextKomaNumber mode:changeMask];            
        }
    }
    if (keyOnce & KeyX) {
        int nextMotionID = [oActionMotionButtonX selectedTag];
        if ([self getCurrentMotionID] != nextMotionID) {
            unsigned changeMask = KRCharaMotionChangeModeNormalMask;
            if ([oIgnoreCancelDeclButtonX state] == NSOnState) {
                changeMask |= KRCharaMotionChangeModeIgnoreCancelFlagMask;
            }
            if ([oIgnoreFinalAnimationButtonX state] == NSOnState) {
                changeMask |= KRCharaMotionChangeModeSkipEndMask;
            }
            int nextKomaNumber = [oActionMotionKomaButtonX selectedTag];
            
            [self changeMotion:nextMotionID koma:nextKomaNumber mode:changeMask];            
        }
    }
    if (keyOnce & KeyC) {
        int nextMotionID = [oActionMotionButtonC selectedTag];
        if ([self getCurrentMotionID] != nextMotionID) {
            unsigned changeMask = KRCharaMotionChangeModeNormalMask;
            if ([oIgnoreCancelDeclButtonC state] == NSOnState) {
                changeMask |= KRCharaMotionChangeModeIgnoreCancelFlagMask;
            }
            if ([oIgnoreFinalAnimationButtonC state] == NSOnState) {
                changeMask |= KRCharaMotionChangeModeSkipEndMask;
            }
            int nextKomaNumber = [oActionMotionKomaButtonC selectedTag];
            
            [self changeMotion:nextMotionID koma:nextKomaNumber mode:changeMask];            
        }
    }
    
    if (mouseOnce & MouseButtonLeft) {
        int nextMotionID = [oActionMotionButtonMouse selectedTag];
        if ([self getCurrentMotionID] != nextMotionID) {
            unsigned changeMask = KRCharaMotionChangeModeNormalMask;
            if ([oIgnoreCancelDeclButtonMouse state] == NSOnState) {
                changeMask |= KRCharaMotionChangeModeIgnoreCancelFlagMask;
            }
            if ([oIgnoreFinalAnimationButtonMouse state] == NSOnState) {
                changeMask |= KRCharaMotionChangeModeSkipEndMask;
            }
            int nextKomaNumber = [oActionMotionKomaButtonMouse selectedTag];
            
            [self changeMotion:nextMotionID koma:nextKomaNumber mode:changeMask];            
        }
        
        if ([oDoChangeLocationButtonMouse state] == NSOnState) {
            mCurrentPos->x = mMousePos.x;
            mCurrentPos->y = mMousePos.y;
        }
    } else if (mouse & MouseButtonLeft) {
        if ([oDoChangeLocationButtonMouse state] == NSOnState) {
            mCurrentPos->x = mMousePos.x;
            mCurrentPos->y = mMousePos.y;
        }
    }
    
    // 何かしらの入力がない場合
    if (!((key & (KeyDown|KeyUp|KeyLeft|KeyRight|KeyZ|KeyX|KeyC)) || (mouse & MouseButtonLeft))) {
        if (mHadInput && [oRevertToFirstMotionWithNoKeyButton state] == NSOnState) {
            mHadInput = NO;
            int firstMotionID = [oFirstMotionButton selectedTag];
            if ([self getCurrentMotionID] != firstMotionID) {
                unsigned changeMask = KRCharaMotionChangeModeNormalMask;
                if ([oIgnoreCancelDeclRevertToFirstMotion state] == NSOnState) {
                    changeMask |= KRCharaMotionChangeModeIgnoreCancelFlagMask;
                }
                if ([oIgnoreFinalAnimationRevertToFirstMotion state] == NSOnState) {
                    changeMask |= KRCharaMotionChangeModeSkipEndMask;
                }                
                int firstKomaNumber = [oFirstMotionKomaButton selectedTag];
                
                [self changeMotion:firstMotionID koma:firstKomaNumber mode:changeMask];
                NSString* motionStr = [NSString stringWithFormat:@"%d[%@] - %d", [mCurrentMotion motionID], [mCurrentMotion motionName], [mCurrentKoma komaNumber]-1];
                [oCurrentMotionField setStringValue:motionStr];
            }
        }
    }
    // 何かしら入力はあった
    else {
        mHadInput = YES;
        NSString* motionStr = [NSString stringWithFormat:@"%d[%@] - %d", [mCurrentMotion motionID], [mCurrentMotion motionName], [mCurrentKoma komaNumber]-1];
        [oCurrentMotionField setStringValue:motionStr];
    }
    
    if (mCurrentPos->x < 0) {
        mCurrentPos->x = 0;
    } else if (mCurrentPos->x >= frame.size.width-1) {
        mCurrentPos->x = frame.size.width-1;
    }
    if (mCurrentPos->y < 0) {
        mCurrentPos->y = 0;
    } else if (mCurrentPos->y >= frame.size.height-1) {
        mCurrentPos->y = frame.size.height-1;
    }
}

- (void)updateKoma
{
    if (mKomaInterval > 0) {
        mKomaInterval--;
    }
    
    if (mKomaInterval > 0) {
        return;
    }

    if (!mHasChangingStarted && mNextMotion && [mCurrentKoma isCancelable]) {
        mHasChangingStarted = YES;
        if (mSkipEndToNext || ![mCurrentMotion targetKomaForCancel]) {
            mCurrentMotion = mNextMotion;
            mCurrentKoma = mNextKoma;
            mNextMotion = nil;
            mNextKoma = nil;
            mKomaNumber = [mCurrentKoma komaNumber];
            mKomaInterval = [mCurrentKoma interval];
            if (mKomaInterval == 0) {
                mKomaInterval = [mCurrentMotion defaultKomaInterval];
            }
        } else {
            BXChara2DKoma* endStartKoma = [mCurrentMotion targetKomaForCancel];
            mCurrentKoma = endStartKoma;
            mKomaNumber = [mCurrentKoma komaNumber];
            mKomaInterval = [mCurrentKoma interval];
            if (mKomaInterval == 0) {
                mKomaInterval = [mCurrentMotion defaultKomaInterval];
            }
        }
        NSString* motionStr = [NSString stringWithFormat:@"%d[%@] - %d", [mCurrentMotion motionID], [mCurrentMotion motionName], [mCurrentKoma komaNumber]-1];
        [oCurrentMotionField setStringValue:motionStr];
        return;
    }
    
    int gotoTargetNumber = [mCurrentKoma gotoTargetNumber];
    if (gotoTargetNumber > 0) {
        mKomaNumber = gotoTargetNumber;
    } else {
        mKomaNumber++;
    }
    if (mKomaNumber <= [mCurrentMotion komaCount]) {
        mCurrentKoma = [mCurrentMotion komaWithNumber:mKomaNumber];
        mKomaInterval = [mCurrentKoma interval];
        if (mKomaInterval == 0) {
            mKomaInterval = [mCurrentMotion defaultKomaInterval];
        }
    } else {
        if (mNextMotion) {
            mCurrentMotion = mNextMotion;
            mCurrentKoma = mNextKoma;
            mNextMotion = nil;
            mNextKoma = nil;
            mKomaNumber = [mCurrentKoma komaNumber];
            mKomaInterval = [mCurrentKoma interval];
            if (mKomaInterval == 0) {
                mKomaInterval = [mCurrentMotion defaultKomaInterval];
            }
        } else {
            BXChara2DMotion* nextMotion = [mTargetSpec motionWithID:[mCurrentMotion nextMotionID]];
            if (nextMotion) {
                mCurrentMotion = nextMotion;
                mKomaNumber = 1;
                mCurrentKoma = [mCurrentMotion komaWithNumber:mKomaNumber];
                mKomaInterval = [mCurrentKoma interval];
                if (mKomaInterval == 0) {
                    mKomaInterval = [mCurrentMotion defaultKomaInterval];
                }              
            } else {
                mKomaNumber = [mCurrentKoma komaNumber];
            }
        }        
    }
    
    NSString* motionStr = [NSString stringWithFormat:@"%d[%@] - %d", [mCurrentMotion motionID], [mCurrentMotion motionName], [mCurrentKoma komaNumber]-1];
    [oCurrentMotionField setStringValue:motionStr];
}

- (void)refreshProc:(NSTimer*)theTimer
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    while (mIsAnimationRunning) {
        NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];

        [self drawRect:NSZeroRect];        
        [self updateModel];
        [self updateKoma];

        NSTimeInterval endTime = [NSDate timeIntervalSinceReferenceDate];
        NSTimeInterval restTime = 0.016 - (endTime - startTime);
        
        if (restTime > 0) {
            [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:restTime]];
        }
    }

    [pool release];
}


#pragma mark -
#pragma mark 入力の受け付け

- (void)processKeyDown:(KRKeyInfo)keyMask
{
    mKeyState |= keyMask;
}

- (void)processKeyUp:(KRKeyInfo)keyMask
{
    mKeyState &= ~keyMask;
    mKeyStateOld &= ~keyMask;
}

- (KRKeyInfo)keyState
{
    return mKeyState;
}

- (KRKeyInfo)keyStateOnce
{
	KRKeyInfo ret = (mKeyState ^ mKeyStateOld) & mKeyState;
	mKeyStateOld |= mKeyState;
	return ret;
}

- (KRMouseInfo)mouseState
{
    return mMouseState;
}

- (KRMouseInfo)mouseStateOnce
{
	KRMouseInfo ret = (mMouseState ^ mMouseStateOld) & mMouseState;
	mMouseStateOld |= mMouseState;
	return ret;
}

- (void)keyDown:(NSEvent*)theEvent
{
    unsigned short keyCode = [theEvent keyCode];
    
    if (keyCode == 0x00) {
        [self processKeyDown:KeyA];
    }
    else if (keyCode == 0x0b) {
        [self processKeyDown:KeyB];
    }
    else if (keyCode == 0x08) {
        [self processKeyDown:KeyC];
    }
    else if (keyCode == 0x02) {
        [self processKeyDown:KeyD];
    }
    else if (keyCode == 0x0e) {
        [self processKeyDown:KeyE];
    }
    else if (keyCode == 0x03) {
        [self processKeyDown:KeyF];
    }
    else if (keyCode == 0x05) {
        [self processKeyDown:KeyG];
    }
    else if (keyCode == 0x04) {
        [self processKeyDown:KeyH];
    }
    else if (keyCode == 0x22) {
        [self processKeyDown:KeyI];
    }
    else if (keyCode == 0x26) {
        [self processKeyDown:KeyJ];
    }
    else if (keyCode == 0x28) {
        [self processKeyDown:KeyK];
    }
    else if (keyCode == 0x25) {
        [self processKeyDown:KeyL];
    }
    else if (keyCode == 0x2e) {
        [self processKeyDown:KeyM];
    }
    else if (keyCode == 0x2d) {
        [self processKeyDown:KeyN];
    }
    else if (keyCode == 0x1f) {
        [self processKeyDown:KeyO];
    }
    else if (keyCode == 0x23) {
        [self processKeyDown:KeyP];
    }
    else if (keyCode == 0x0c) {
        [self processKeyDown:KeyQ];
    }
    else if (keyCode == 0x0f) {
        [self processKeyDown:KeyR];
    }
    else if (keyCode == 0x01) {
        [self processKeyDown:KeyS];
    }
    else if (keyCode == 0x11) {
        [self processKeyDown:KeyT];
    }
    else if (keyCode == 0x20) {
        [self processKeyDown:KeyU];
    }
    else if (keyCode == 0x09) {
        [self processKeyDown:KeyV];
    }
    else if (keyCode == 0x0d) {
        [self processKeyDown:KeyW];
    }
    else if (keyCode == 0x07) {
        [self processKeyDown:KeyX];
    }
    else if (keyCode == 0x10) {
        [self processKeyDown:KeyY];
    }
    else if (keyCode == 0x06) {
        [self processKeyDown:KeyZ];
    }
    else if (keyCode == 0x7e) {
        [self processKeyDown:KeyUp];
    }
    else if (keyCode == 0x7d) {
        [self processKeyDown:KeyDown];
    }
    else if (keyCode == 0x7b) {
        [self processKeyDown:KeyLeft];
    }
    else if (keyCode == 0x7c) {
        [self processKeyDown:KeyRight];
    }
    else if (keyCode == 0x24 || keyCode == 0x4c) {
        [self processKeyDown:KeyReturn];
    }
    else if (keyCode == 0x30) {
        [self processKeyDown:KeyTab];
    }
    else if (keyCode == 0x31) {
        [self processKeyDown:KeySpace];
    }
    else if (keyCode == 0x33) {
        [self processKeyDown:KeyBackspace];
    }
    else if (keyCode == 0x75) {
        [self processKeyDown:KeyDelete];
    }
    else if (keyCode == 0x35) {
        [self processKeyDown:KeyEscape];
    }
}

- (void)keyUp:(NSEvent*)theEvent
{
    unsigned short keyCode = [theEvent keyCode];
    
    if (keyCode == 0x00) {
        [self processKeyUp:KeyA];
    }
    else if (keyCode == 0x0b) {
        [self processKeyUp:KeyB];
    }
    else if (keyCode == 0x08) {
        [self processKeyUp:KeyC];
    }
    else if (keyCode == 0x02) {
        [self processKeyUp:KeyD];
    }
    else if (keyCode == 0x0e) {
        [self processKeyUp:KeyE];
    }
    else if (keyCode == 0x03) {
        [self processKeyUp:KeyF];
    }
    else if (keyCode == 0x05) {
        [self processKeyUp:KeyG];
    }
    else if (keyCode == 0x04) {
        [self processKeyUp:KeyH];
    }
    else if (keyCode == 0x22) {
        [self processKeyUp:KeyI];
    }
    else if (keyCode == 0x26) {
        [self processKeyUp:KeyJ];
    }
    else if (keyCode == 0x28) {
        [self processKeyUp:KeyK];
    }
    else if (keyCode == 0x25) {
        [self processKeyUp:KeyL];
    }
    else if (keyCode == 0x2e) {
        [self processKeyUp:KeyM];
    }
    else if (keyCode == 0x2d) {
        [self processKeyUp:KeyN];
    }
    else if (keyCode == 0x1f) {
        [self processKeyUp:KeyO];
    }
    else if (keyCode == 0x23) {
        [self processKeyUp:KeyP];
    }
    else if (keyCode == 0x0c) {
        [self processKeyUp:KeyQ];
    }
    else if (keyCode == 0x0f) {
        [self processKeyUp:KeyR];
    }
    else if (keyCode == 0x01) {
        [self processKeyUp:KeyS];
    }
    else if (keyCode == 0x11) {
        [self processKeyUp:KeyT];
    }
    else if (keyCode == 0x20) {
        [self processKeyUp:KeyU];
    }
    else if (keyCode == 0x09) {
        [self processKeyUp:KeyV];
    }
    else if (keyCode == 0x0d) {
        [self processKeyUp:KeyW];
    }
    else if (keyCode == 0x07) {
        [self processKeyUp:KeyX];
    }
    else if (keyCode == 0x10) {
        [self processKeyUp:KeyY];
    }
    else if (keyCode == 0x06) {
        [self processKeyUp:KeyZ];
    }
    else if (keyCode == 0x7e) {
        [self processKeyUp:KeyUp];
    }
    else if (keyCode == 0x7d) {
        [self processKeyUp:KeyDown];
    }
    else if (keyCode == 0x7b) {
        [self processKeyUp:KeyLeft];
    }
    else if (keyCode == 0x7c) {
        [self processKeyUp:KeyRight];
    }
    else if (keyCode == 0x24 || keyCode == 0x4c) {
        [self processKeyUp:KeyReturn];
    }
    else if (keyCode == 0x30) {
        [self processKeyUp:KeyTab];
    }
    else if (keyCode == 0x31) {
        [self processKeyUp:KeySpace];
    }
    else if (keyCode == 0x33) {
        [self processKeyUp:KeyBackspace];
    }
    else if (keyCode == 0x75) {
        [self processKeyUp:KeyDelete];
    }
    else if (keyCode == 0x35) {
        [self processKeyUp:KeyEscape];
    }
}

- (void)mouseDown:(NSEvent*)theEvent
{
    mMousePos = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    mMouseState |= MouseButtonLeft;
}

- (void)mouseDragged:(NSEvent*)theEvent
{
    mMousePos = [self convertPoint:[theEvent locationInWindow] fromView:nil];
}

- (void)mouseUp:(NSEvent*)theEvent
{
    mMousePos = [self convertPoint:[theEvent locationInWindow] fromView:nil];

    mMouseState &= ~MouseButtonLeft;
    mMouseStateOld &= ~MouseButtonLeft;
}

@end

