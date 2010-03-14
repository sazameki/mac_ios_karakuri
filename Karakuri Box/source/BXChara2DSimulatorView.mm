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

static const unsigned       KRCharaStateChangeModeNormalMask            = 0x00;
static const unsigned       KRCharaStateChangeModeIgnoreCancelFlagMask  = 0x01;
static const unsigned       KRCharaStateChangeModeSkipEndMask           = 0x02;



@interface BXChara2DSimulatorView ()

- (KRKeyInfo)keyState;
- (KRKeyInfo)keyStateOnce;
- (KRMouseInfo)mouseState;
- (KRMouseInfo)mouseStateOnce;

- (int)getCurrentStateID;

- (void)changeState:(int)stateID koma:(int)komaNumber mode:(unsigned)mask;

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

- (int)getCurrentStateID
{
    if (mNextState) {
        return [mNextState stateID];
    }

    return [mCurrentState stateID];
}

- (NSMenu*)makeStateButtonMenu
{
    NSMenu* theMenu = [[[NSMenu alloc] initWithTitle:@"State Button"] autorelease];
    
    for (int i = 0; i < [mTargetSpec stateCount]; i++) {
        BXChara2DState* theState = [mTargetSpec stateAtIndex:i];
        NSMenuItem* theItem = [theMenu addItemWithTitle:[NSString stringWithFormat:@"%d: %@", [theState stateID], [theState stateName]]
                                                 action:nil
                                          keyEquivalent:@""];
        [theItem setTag:[theState stateID]];
    }
    
    return theMenu;
}

- (void)updateStateButtons
{
    [oFirstStateButton setMenu:[self makeStateButtonMenu]];
    [oActionStateButtonDown setMenu:[self makeStateButtonMenu]];
    [oActionStateButtonUp setMenu:[self makeStateButtonMenu]];
    [oActionStateButtonLeft setMenu:[self makeStateButtonMenu]];
    [oActionStateButtonRight setMenu:[self makeStateButtonMenu]];
    [oActionStateButtonZ setMenu:[self makeStateButtonMenu]];
    [oActionStateButtonX setMenu:[self makeStateButtonMenu]];
    [oActionStateButtonC setMenu:[self makeStateButtonMenu]];
    [oActionStateButtonMouse setMenu:[self makeStateButtonMenu]];
}

- (void)saveAnimationSettings
{
    [mTargetSpec setFirstStateID:[oFirstStateButton selectedTag]];
    [mTargetSpec setFirstStateKomaNumber:[oFirstStateKomaButton selectedTag]];
    [mTargetSpec setRevertToFirstState:([oRevertToFirstStateWithNoKeyButton state] == NSOnState)];
    [mTargetSpec setIgnoresCancelFlag:([oIgnoreCancelDeclRevertToFirstState state] == NSOnState)];
    [mTargetSpec setSkipEndAnimation:([oIgnoreFinalAnimationRevertToFirstState state] == NSOnState)];

    [mTargetSpec setActionStateIDUp:[oActionStateButtonUp selectedTag]];
    [mTargetSpec setActionKomaNumberUp:[oActionStateKomaButtonUp selectedTag]];
    [mTargetSpec setIgnoresCancelFlagUp:([oIgnoreCancelDeclButtonUp state] == NSOnState)];
    [mTargetSpec setSkipEndAnimationUp:([oIgnoreFinalAnimationButtonUp state] == NSOnState)];
    [mTargetSpec setActionSpeedUp:[oActionSpeedFieldUp intValue]];
    
    [mTargetSpec setActionStateIDDown:[oActionStateButtonDown selectedTag]];
    [mTargetSpec setActionKomaNumberDown:[oActionStateKomaButtonDown selectedTag]];
    [mTargetSpec setIgnoresCancelFlagDown:([oIgnoreCancelDeclButtonDown state] == NSOnState)];
    [mTargetSpec setSkipEndAnimationDown:([oIgnoreFinalAnimationButtonDown state] == NSOnState)];
    [mTargetSpec setActionSpeedDown:[oActionSpeedFieldDown intValue]];
    
    [mTargetSpec setActionStateIDLeft:[oActionStateButtonLeft selectedTag]];
    [mTargetSpec setActionKomaNumberLeft:[oActionStateKomaButtonLeft selectedTag]];
    [mTargetSpec setIgnoresCancelFlagLeft:([oIgnoreCancelDeclButtonLeft state] == NSOnState)];
    [mTargetSpec setSkipEndAnimationLeft:([oIgnoreFinalAnimationButtonLeft state] == NSOnState)];
    [mTargetSpec setActionSpeedLeft:[oActionSpeedFieldLeft intValue]];
    
    [mTargetSpec setActionStateIDRight:[oActionStateButtonRight selectedTag]];
    [mTargetSpec setActionKomaNumberRight:[oActionStateKomaButtonRight selectedTag]];
    [mTargetSpec setIgnoresCancelFlagRight:([oIgnoreCancelDeclButtonRight state] == NSOnState)];
    [mTargetSpec setSkipEndAnimationRight:([oIgnoreFinalAnimationButtonRight state] == NSOnState)];
    [mTargetSpec setActionSpeedRight:[oActionSpeedFieldRight intValue]];
    
    [mTargetSpec setActionStateIDZ:[oActionStateButtonZ selectedTag]];
    [mTargetSpec setActionKomaNumberZ:[oActionStateKomaButtonZ selectedTag]];
    [mTargetSpec setIgnoresCancelFlagZ:([oIgnoreCancelDeclButtonZ state] == NSOnState)];
    [mTargetSpec setSkipEndAnimationZ:([oIgnoreFinalAnimationButtonZ state] == NSOnState)];
    
    [mTargetSpec setActionStateIDX:[oActionStateButtonX selectedTag]];
    [mTargetSpec setActionKomaNumberX:[oActionStateKomaButtonX selectedTag]];
    [mTargetSpec setIgnoresCancelFlagX:([oIgnoreCancelDeclButtonX state] == NSOnState)];
    [mTargetSpec setSkipEndAnimationX:([oIgnoreFinalAnimationButtonX state] == NSOnState)];
    
    [mTargetSpec setActionStateIDC:[oActionStateButtonC selectedTag]];
    [mTargetSpec setActionKomaNumberC:[oActionStateKomaButtonC selectedTag]];
    [mTargetSpec setIgnoresCancelFlagC:([oIgnoreCancelDeclButtonC state] == NSOnState)];
    [mTargetSpec setSkipEndAnimationC:([oIgnoreFinalAnimationButtonC state] == NSOnState)];
    
    [mTargetSpec setActionStateIDMouse:[oActionStateButtonMouse selectedTag]];
    [mTargetSpec setActionKomaNumberMouse:[oActionStateKomaButtonMouse selectedTag]];
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
    
    [oCurrentStateField setStringValue:@"--------"];
    
    [oActionSpeedFieldUp setIntValue:2];
    [oActionSpeedFieldDown setIntValue:2];
    [oActionSpeedFieldLeft setIntValue:2];
    [oActionSpeedFieldRight setIntValue:2];    
    
    [self updateStateButtons];
    
    // 最初の状態の読み込み
    int firstStateID = [mTargetSpec firstStateID];
    int firstKomaNumber = [mTargetSpec firstStateKomaNumber];
    if (![mTargetSpec stateWithID:firstStateID]) {
        firstStateID = [[mTargetSpec stateAtIndex:0] stateID];
        firstKomaNumber = 1;
    }
    [oFirstStateButton selectItemWithTag:firstStateID];
    [self changedFirstState:self];
    [oFirstStateKomaButton selectItemWithTag:firstKomaNumber];
    [oIgnoreCancelDeclRevertToFirstState setState:([mTargetSpec ignoresCancelFlag]? NSOnState: NSOffState)];
    [oRevertToFirstStateWithNoKeyButton setState:([mTargetSpec revertToFirstState]? NSOnState: NSOffState)];
    [oIgnoreFinalAnimationRevertToFirstState setState:([mTargetSpec skipEndAnimation]? NSOnState: NSOffState)];
    
    // KeyDown
    int downStateID = [mTargetSpec actionStateIDDown];
    int downKomaNumber = [mTargetSpec actionKomaNumberDown];
    if (![mTargetSpec stateWithID:downStateID]) {
        downStateID = [[mTargetSpec stateAtIndex:0] stateID];
        downKomaNumber = 1;
    }
    [oActionStateButtonDown selectItemWithTag:downStateID];
    [self changedActionStateDown:self];
    [oActionStateKomaButtonDown selectItemWithTag:downKomaNumber];
    [oIgnoreCancelDeclButtonDown setState:([mTargetSpec ignoresCancelFlagDown]? NSOnState: NSOffState)];
    [oIgnoreFinalAnimationButtonDown setState:([mTargetSpec skipEndAnimationDown]? NSOnState: NSOffState)];
    [oActionSpeedFieldDown setIntValue:[mTargetSpec actionSpeedDown]];

    // KeyUp
    int upStateID = [mTargetSpec actionStateIDUp];
    int upKomaNumber = [mTargetSpec actionKomaNumberUp];
    if (![mTargetSpec stateWithID:upStateID]) {
        upStateID = [[mTargetSpec stateAtIndex:0] stateID];
        upKomaNumber = 1;
    }
    [oActionStateButtonUp selectItemWithTag:upStateID];
    [self changedActionStateUp:self];
    [oActionStateKomaButtonUp selectItemWithTag:upKomaNumber];
    [oIgnoreCancelDeclButtonUp setState:([mTargetSpec ignoresCancelFlagUp]? NSOnState: NSOffState)];
    [oIgnoreFinalAnimationButtonUp setState:([mTargetSpec skipEndAnimationUp]? NSOnState: NSOffState)];
    [oActionSpeedFieldUp setIntValue:[mTargetSpec actionSpeedUp]];

    // Left
    int leftStateID = [mTargetSpec actionStateIDLeft];
    int leftKomaNumber = [mTargetSpec actionKomaNumberLeft];
    if (![mTargetSpec stateWithID:leftStateID]) {
        leftStateID = [[mTargetSpec stateAtIndex:0] stateID];
        leftKomaNumber = 1;
    }
    [oActionStateButtonLeft selectItemWithTag:leftStateID];
    [self changedActionStateLeft:self];
    [oActionStateKomaButtonLeft selectItemWithTag:leftKomaNumber];
    [oIgnoreCancelDeclButtonLeft setState:([mTargetSpec ignoresCancelFlagLeft]? NSOnState: NSOffState)];
    [oIgnoreFinalAnimationButtonLeft setState:([mTargetSpec skipEndAnimationLeft]? NSOnState: NSOffState)];
    [oActionSpeedFieldLeft setIntValue:[mTargetSpec actionSpeedLeft]];

    // Right
    int rightStateID = [mTargetSpec actionStateIDRight];
    int rightKomaNumber = [mTargetSpec actionKomaNumberRight];
    if (![mTargetSpec stateWithID:rightStateID]) {
        rightStateID = [[mTargetSpec stateAtIndex:0] stateID];
        rightKomaNumber = 1;
    }
    [oActionStateButtonRight selectItemWithTag:rightStateID];
    [self changedActionStateRight:self];
    [oActionStateKomaButtonRight selectItemWithTag:rightKomaNumber];
    [oIgnoreCancelDeclButtonRight setState:([mTargetSpec ignoresCancelFlagRight]? NSOnState: NSOffState)];
    [oIgnoreFinalAnimationButtonRight setState:([mTargetSpec skipEndAnimationRight]? NSOnState: NSOffState)];
    [oActionSpeedFieldRight setIntValue:[mTargetSpec actionSpeedRight]];

    // KeyZ
    int zStateID = [mTargetSpec actionStateIDZ];
    int zKomaNumber = [mTargetSpec actionKomaNumberZ];
    if (![mTargetSpec stateWithID:zStateID]) {
        zStateID = [[mTargetSpec stateAtIndex:0] stateID];
        zKomaNumber = 1;
    }
    [oActionStateButtonZ selectItemWithTag:zStateID];
    [self changedActionStateZ:self];
    [oActionStateKomaButtonZ selectItemWithTag:zKomaNumber];
    [oIgnoreCancelDeclButtonZ setState:([mTargetSpec ignoresCancelFlagZ]? NSOnState: NSOffState)];
    [oIgnoreFinalAnimationButtonZ setState:([mTargetSpec skipEndAnimationZ]? NSOnState: NSOffState)];

    // KeyX
    int xStateID = [mTargetSpec actionStateIDX];
    int xKomaNumber = [mTargetSpec actionKomaNumberX];
    if (![mTargetSpec stateWithID:xStateID]) {
        xStateID = [[mTargetSpec stateAtIndex:0] stateID];
        xKomaNumber = 1;
    }
    [oActionStateButtonX selectItemWithTag:xStateID];
    [self changedActionStateX:self];
    [oActionStateKomaButtonX selectItemWithTag:xKomaNumber];
    [oIgnoreCancelDeclButtonX setState:([mTargetSpec ignoresCancelFlagX]? NSOnState: NSOffState)];
    [oIgnoreFinalAnimationButtonX setState:([mTargetSpec skipEndAnimationX]? NSOnState: NSOffState)];

    // KeyC
    int cStateID = [mTargetSpec actionStateIDC];
    int cKomaNumber = [mTargetSpec actionKomaNumberC];
    if (![mTargetSpec stateWithID:cStateID]) {
        cStateID = [[mTargetSpec stateAtIndex:0] stateID];
        cKomaNumber = 1;
    }
    [oActionStateButtonC selectItemWithTag:cStateID];
    [self changedActionStateC:self];
    [oActionStateKomaButtonC selectItemWithTag:cKomaNumber];
    [oIgnoreCancelDeclButtonC setState:([mTargetSpec ignoresCancelFlagC]? NSOnState: NSOffState)];
    [oIgnoreFinalAnimationButtonC setState:([mTargetSpec skipEndAnimationC]? NSOnState: NSOffState)];

    // Mouse
    int mouseStateID = [mTargetSpec actionStateIDMouse];
    int mouseKomaNumber = [mTargetSpec actionKomaNumberMouse];
    if (![mTargetSpec stateWithID:mouseStateID]) {
        mouseStateID = [[mTargetSpec stateAtIndex:0] stateID];
        mouseKomaNumber = 1;
    }
    [oActionStateButtonMouse selectItemWithTag:mouseStateID];
    [self changedActionStateMouse:self];
    [oActionStateKomaButtonMouse selectItemWithTag:mouseKomaNumber];
    [oIgnoreCancelDeclButtonMouse setState:([mTargetSpec ignoresCancelFlagMouse]? NSOnState: NSOffState)];
    [oIgnoreFinalAnimationButtonMouse setState:([mTargetSpec skipEndAnimationMouse]? NSOnState: NSOffState)];
    [oDoChangeLocationButtonMouse setState:([mTargetSpec doChangeMouseLocation]? NSOnState: NSOffState)];
    
    mNextState = nil;
    mNextKoma = nil;
}

- (void)glDrawMain
{
    mGraphics->clear(KRColor::Black);
    
    if (mCurrentKoma != NULL) {
        KRTexture2D* theTex = [mCurrentKoma previewTexture];
        theTex->drawAtPoint(*mCurrentPos, KRColor::White);
    }
}

- (NSMenu*)makeKomaMenuForState:(BXChara2DState*)aState
{
    NSMenu* theMenu = [[[NSMenu alloc] initWithTitle:@"Koma Button Menu"] autorelease];
    
    for (int i = 0; i < [aState komaCount]; i++) {
        BXChara2DKoma* aKoma = [aState komaAtIndex:i];
        NSMenuItem* theItem = [theMenu addItemWithTitle:[NSString stringWithFormat:@"%d", [aKoma komaNumber]]
                                                 action:nil
                                          keyEquivalent:@""];
        [theItem setTag:[aKoma komaNumber]];
    }
    
    return theMenu;
}

- (void)changeState:(int)stateID koma:(int)komaNumber mode:(unsigned)mask
{
    if (mNextState && [mNextState stateID] == stateID && [mNextKoma komaNumber] == komaNumber) {
        return;
    }
    
    mNextState = [mTargetSpec stateWithID:stateID];
    mNextKoma = [mNextState komaWithNumber:komaNumber];
    
    mHasChangingStarted = NO;
    mSkipEndToNext = (mask & KRCharaStateChangeModeSkipEndMask)? YES: NO;
    
    if ([mCurrentKoma isCancelable] || (mask & KRCharaStateChangeModeIgnoreCancelFlagMask)) {
        mHasChangingStarted = YES;
        if (mSkipEndToNext || ![mCurrentState targetKomaForCancel]) {
            mCurrentState = mNextState;
            mCurrentKoma = mNextKoma;
            mNextState = nil;
            mNextKoma = nil;
            mKomaNumber = [mCurrentKoma komaNumber];
            mKomaInterval = [mCurrentKoma interval];
            if (mKomaInterval == 0) {
                mKomaInterval = [mCurrentState defaultKomaInterval];
            }
        } else {
            BXChara2DKoma* endStartKoma = [mCurrentState targetKomaForCancel];
            mCurrentKoma = endStartKoma;
            mKomaNumber = [mCurrentKoma komaNumber];
            mKomaInterval = [mCurrentKoma interval];
            if (mKomaInterval == 0) {
                mKomaInterval = [mCurrentState defaultKomaInterval];
            }
        }
    }    
}

- (IBAction)changedFirstState:(id)sender
{
    mCurrentState = nil;
    mCurrentKoma = nil;

    if ([mTargetSpec stateCount] == 0) {
        return;
    }

    int theStateID = [oFirstStateButton selectedTag];
    mCurrentState = [mTargetSpec stateWithID:theStateID];

    [oFirstStateKomaButton setMenu:[self makeKomaMenuForState:mCurrentState]];
    [self changedFirstStateKoma:self];
    
    [self setNeedsDisplay:YES];
    
    [[self window] makeFirstResponder:self];
}

- (IBAction)changedFirstStateKoma:(id)sender
{
    int theKomaNumber = [oFirstStateKomaButton selectedTag];
    mKomaNumber = theKomaNumber;
    mCurrentKoma = [mCurrentState komaWithNumber:theKomaNumber];
    mKomaInterval = [mCurrentKoma interval];
    if (mKomaInterval == 0) {
        mKomaInterval = [mCurrentState defaultKomaInterval];
    }

    [self setNeedsDisplay:YES];

    [[self window] makeFirstResponder:self];
}

- (IBAction)changedActionStateDown:(id)sender
{
    int stateID = [oActionStateButtonDown selectedTag];
    BXChara2DState* theState = [mTargetSpec stateWithID:stateID];
    
    [oActionStateKomaButtonDown setMenu:[self makeKomaMenuForState:theState]];    
}

- (IBAction)changedActionStateUp:(id)sender
{
    int stateID = [oActionStateButtonUp selectedTag];
    BXChara2DState* theState = [mTargetSpec stateWithID:stateID];
    
    [oActionStateKomaButtonUp setMenu:[self makeKomaMenuForState:theState]];    
}

- (IBAction)changedActionStateLeft:(id)sender
{
    int stateID = [oActionStateButtonLeft selectedTag];
    BXChara2DState* theState = [mTargetSpec stateWithID:stateID];
    
    [oActionStateKomaButtonLeft setMenu:[self makeKomaMenuForState:theState]];    
}

- (IBAction)changedActionStateRight:(id)sender
{
    int stateID = [oActionStateButtonRight selectedTag];
    BXChara2DState* theState = [mTargetSpec stateWithID:stateID];
    
    [oActionStateKomaButtonRight setMenu:[self makeKomaMenuForState:theState]];    
}

- (IBAction)changedActionStateZ:(id)sender
{
    int stateID = [oActionStateButtonZ selectedTag];
    BXChara2DState* theState = [mTargetSpec stateWithID:stateID];
    
    [oActionStateKomaButtonZ setMenu:[self makeKomaMenuForState:theState]];    
}

- (IBAction)changedActionStateX:(id)sender
{
    int stateID = [oActionStateButtonX selectedTag];
    BXChara2DState* theState = [mTargetSpec stateWithID:stateID];
    
    [oActionStateKomaButtonX setMenu:[self makeKomaMenuForState:theState]];    
}

- (IBAction)changedActionStateC:(id)sender
{
    int stateID = [oActionStateButtonC selectedTag];
    BXChara2DState* theState = [mTargetSpec stateWithID:stateID];
    
    [oActionStateKomaButtonC setMenu:[self makeKomaMenuForState:theState]];    
}

- (IBAction)changedActionStateMouse:(id)sender
{
    int stateID = [oActionStateButtonMouse selectedTag];
    BXChara2DState* theState = [mTargetSpec stateWithID:stateID];
    
    [oActionStateKomaButtonMouse setMenu:[self makeKomaMenuForState:theState]];
}

- (IBAction)startAnimation:(id)sender
{
    if (mIsAnimationRunning) {
        return;
    }
    mIsAnimationRunning = YES;
    
    [oFirstStateButton setEnabled:NO];
    [oFirstStateKomaButton setEnabled:NO];
    [oRevertToFirstStateWithNoKeyButton setEnabled:NO];
    [oIgnoreCancelDeclRevertToFirstState setEnabled:NO];
    [oIgnoreFinalAnimationRevertToFirstState setEnabled:NO];

    [oActionStateButtonUp setEnabled:NO];
    [oActionStateKomaButtonUp setEnabled:NO];
    [oIgnoreCancelDeclButtonUp setEnabled:NO];
    [oIgnoreFinalAnimationButtonUp setEnabled:NO];
    [oActionSpeedFieldUp setEnabled:NO];

    [oActionStateButtonDown setEnabled:NO];
    [oActionStateKomaButtonDown setEnabled:NO];
    [oIgnoreCancelDeclButtonDown setEnabled:NO];
    [oIgnoreFinalAnimationButtonDown setEnabled:NO];
    [oActionSpeedFieldDown setEnabled:NO];

    [oActionStateButtonLeft setEnabled:NO];
    [oActionStateKomaButtonLeft setEnabled:NO];
    [oIgnoreCancelDeclButtonLeft setEnabled:NO];
    [oIgnoreFinalAnimationButtonLeft setEnabled:NO];
    [oActionSpeedFieldLeft setEnabled:NO];

    [oActionStateButtonRight setEnabled:NO];
    [oActionStateKomaButtonRight setEnabled:NO];
    [oIgnoreCancelDeclButtonRight setEnabled:NO];
    [oIgnoreFinalAnimationButtonRight setEnabled:NO];
    [oActionSpeedFieldRight setEnabled:NO];    

    [oActionStateButtonZ setEnabled:NO];
    [oActionStateKomaButtonZ setEnabled:NO];
    [oIgnoreCancelDeclButtonZ setEnabled:NO];
    [oIgnoreFinalAnimationButtonZ setEnabled:NO];
    
    [oActionStateButtonX setEnabled:NO];
    [oActionStateKomaButtonX setEnabled:NO];
    [oIgnoreCancelDeclButtonX setEnabled:NO];
    [oIgnoreFinalAnimationButtonX setEnabled:NO];
    
    [oActionStateButtonC setEnabled:NO];
    [oActionStateKomaButtonC setEnabled:NO];
    [oIgnoreCancelDeclButtonC setEnabled:NO];
    [oIgnoreFinalAnimationButtonC setEnabled:NO];

    [oActionStateButtonMouse setEnabled:NO];
    [oActionStateKomaButtonMouse setEnabled:NO];
    [oIgnoreCancelDeclButtonMouse setEnabled:NO];
    [oIgnoreFinalAnimationButtonMouse setEnabled:NO];
    [oDoChangeLocationButtonMouse setEnabled:NO];
    
    [oAnimationButton setAction:@selector(stopAnimation:)];
    [oAnimationButton setTitle:NSLocalizedString(@"Chara2D Simulator Animation Button Stop", nil)];
    
    [self changedFirstStateKoma:self];
    
    [[self window] makeFirstResponder:self];
    
    [NSThread detachNewThreadSelector:@selector(refreshProc:) toTarget:self withObject:nil];
}

- (IBAction)stopAnimation:(id)sender
{
    if (!mIsAnimationRunning) {
        return;
    }
    mIsAnimationRunning = NO;
    
    [oFirstStateButton setEnabled:YES];
    [oFirstStateKomaButton setEnabled:YES];
    [oRevertToFirstStateWithNoKeyButton setEnabled:YES];
    [oIgnoreCancelDeclRevertToFirstState setEnabled:YES];
    [oIgnoreFinalAnimationRevertToFirstState setEnabled:YES];

    [oActionStateButtonUp setEnabled:YES];
    [oActionStateKomaButtonUp setEnabled:YES];
    [oIgnoreCancelDeclButtonUp setEnabled:YES];
    [oIgnoreFinalAnimationButtonUp setEnabled:YES];
    [oActionSpeedFieldUp setEnabled:YES];
    
    [oActionStateButtonDown setEnabled:YES];
    [oActionStateKomaButtonDown setEnabled:YES];
    [oIgnoreCancelDeclButtonDown setEnabled:YES];
    [oIgnoreFinalAnimationButtonDown setEnabled:YES];
    [oActionSpeedFieldDown setEnabled:YES];

    [oActionStateButtonLeft setEnabled:YES];
    [oActionStateKomaButtonLeft setEnabled:YES];
    [oIgnoreCancelDeclButtonLeft setEnabled:YES];
    [oIgnoreFinalAnimationButtonLeft setEnabled:YES];
    [oActionSpeedFieldLeft setEnabled:YES];

    [oActionStateButtonRight setEnabled:YES];
    [oActionStateKomaButtonRight setEnabled:YES];
    [oIgnoreCancelDeclButtonRight setEnabled:YES];
    [oIgnoreFinalAnimationButtonRight setEnabled:YES];
    [oActionSpeedFieldRight setEnabled:YES];

    [oActionStateButtonZ setEnabled:YES];
    [oActionStateKomaButtonZ setEnabled:YES];
    [oIgnoreCancelDeclButtonZ setEnabled:YES];
    [oIgnoreFinalAnimationButtonZ setEnabled:YES];
    
    [oActionStateButtonX setEnabled:YES];
    [oActionStateKomaButtonX setEnabled:YES];
    [oIgnoreCancelDeclButtonX setEnabled:YES];
    [oIgnoreFinalAnimationButtonX setEnabled:YES];
    
    [oActionStateButtonC setEnabled:YES];
    [oActionStateKomaButtonC setEnabled:YES];
    [oIgnoreCancelDeclButtonC setEnabled:YES];
    [oIgnoreFinalAnimationButtonC setEnabled:YES];
    
    [oActionStateButtonMouse setEnabled:YES];
    [oActionStateKomaButtonMouse setEnabled:YES];
    [oIgnoreCancelDeclButtonMouse setEnabled:YES];
    [oIgnoreFinalAnimationButtonMouse setEnabled:YES];
    [oDoChangeLocationButtonMouse setEnabled:YES];
    
    [oAnimationButton setAction:@selector(startAnimation:)];
    [oAnimationButton setTitle:NSLocalizedString(@"Chara2D Simulator Animation Button Start", nil)];
    
    *mCurrentPos = KRVector2D(100, 100);
    
    [self changedFirstState:self];
}

- (void)updateModel
{
    NSRect frame = [self frame];
    
    KRKeyInfo key = [self keyState];
    KRKeyInfo keyOnce = [self keyStateOnce];
    KRMouseInfo mouse = [self mouseState];
    KRMouseInfo mouseOnce = [self mouseStateOnce];
    
    if (key & KeyLeft) {
        int nextStateID = [oActionStateButtonLeft selectedTag];
        if ([self getCurrentStateID] != nextStateID) {
            unsigned changeMask = KRCharaStateChangeModeNormalMask;
            if ([oIgnoreCancelDeclButtonLeft state] == NSOnState) {
                changeMask |= KRCharaStateChangeModeIgnoreCancelFlagMask;
            }
            if ([oIgnoreFinalAnimationButtonLeft state] == NSOnState) {
                changeMask |= KRCharaStateChangeModeSkipEndMask;
            }
            int nextKomaNumber = [oActionStateKomaButtonLeft selectedTag];
            
            [self changeState:nextStateID koma:nextKomaNumber mode:changeMask];            
        }
        
        int speed = [oActionSpeedFieldLeft intValue];
        mCurrentPos->x -= speed;
    }
    if (key & KeyRight) {
        int nextStateID = [oActionStateButtonRight selectedTag];
        if ([self getCurrentStateID] != nextStateID) {
            unsigned changeMask = KRCharaStateChangeModeNormalMask;
            if ([oIgnoreCancelDeclButtonRight state] == NSOnState) {
                changeMask |= KRCharaStateChangeModeIgnoreCancelFlagMask;
            }
            if ([oIgnoreFinalAnimationButtonRight state] == NSOnState) {
                changeMask |= KRCharaStateChangeModeSkipEndMask;
            }
            int nextKomaNumber = [oActionStateKomaButtonRight selectedTag];
            
            [self changeState:nextStateID koma:nextKomaNumber mode:changeMask];            
        }

        int speed = [oActionSpeedFieldRight intValue];
        mCurrentPos->x += speed;
    }
    if (key & KeyUp) {
        int nextStateID = [oActionStateButtonUp selectedTag];
        if ([self getCurrentStateID] != nextStateID) {
            unsigned changeMask = KRCharaStateChangeModeNormalMask;
            if ([oIgnoreCancelDeclButtonUp state] == NSOnState) {
                changeMask |= KRCharaStateChangeModeIgnoreCancelFlagMask;
            }
            if ([oIgnoreFinalAnimationButtonUp state] == NSOnState) {
                changeMask |= KRCharaStateChangeModeSkipEndMask;
            }
            int nextKomaNumber = [oActionStateKomaButtonUp selectedTag];
            
            [self changeState:nextStateID koma:nextKomaNumber mode:changeMask];            
        }
        
        int speed = [oActionSpeedFieldUp intValue];
        mCurrentPos->y += speed;
    }
    if (key & KeyDown) {
        int nextStateID = [oActionStateButtonDown selectedTag];
        if ([self getCurrentStateID] != nextStateID) {
            unsigned changeMask = KRCharaStateChangeModeNormalMask;
            if ([oIgnoreCancelDeclButtonDown state] == NSOnState) {
                changeMask |= KRCharaStateChangeModeIgnoreCancelFlagMask;
            }
            if ([oIgnoreFinalAnimationButtonDown state] == NSOnState) {
                changeMask |= KRCharaStateChangeModeSkipEndMask;
            }
            int nextKomaNumber = [oActionStateKomaButtonDown selectedTag];
            
            [self changeState:nextStateID koma:nextKomaNumber mode:changeMask];            
        }

        int speed = [oActionSpeedFieldDown intValue];
        mCurrentPos->y -= speed;
    }
    if (keyOnce & KeyZ) {
        int nextStateID = [oActionStateButtonZ selectedTag];
        if ([self getCurrentStateID] != nextStateID) {
            unsigned changeMask = KRCharaStateChangeModeNormalMask;
            if ([oIgnoreCancelDeclButtonZ state] == NSOnState) {
                changeMask |= KRCharaStateChangeModeIgnoreCancelFlagMask;
            }
            if ([oIgnoreFinalAnimationButtonZ state] == NSOnState) {
                changeMask |= KRCharaStateChangeModeSkipEndMask;
            }
            int nextKomaNumber = [oActionStateKomaButtonZ selectedTag];
            
            [self changeState:nextStateID koma:nextKomaNumber mode:changeMask];            
        }
    }
    if (keyOnce & KeyX) {
        int nextStateID = [oActionStateButtonX selectedTag];
        if ([self getCurrentStateID] != nextStateID) {
            unsigned changeMask = KRCharaStateChangeModeNormalMask;
            if ([oIgnoreCancelDeclButtonX state] == NSOnState) {
                changeMask |= KRCharaStateChangeModeIgnoreCancelFlagMask;
            }
            if ([oIgnoreFinalAnimationButtonX state] == NSOnState) {
                changeMask |= KRCharaStateChangeModeSkipEndMask;
            }
            int nextKomaNumber = [oActionStateKomaButtonX selectedTag];
            
            [self changeState:nextStateID koma:nextKomaNumber mode:changeMask];            
        }
    }
    if (keyOnce & KeyC) {
        int nextStateID = [oActionStateButtonC selectedTag];
        if ([self getCurrentStateID] != nextStateID) {
            unsigned changeMask = KRCharaStateChangeModeNormalMask;
            if ([oIgnoreCancelDeclButtonC state] == NSOnState) {
                changeMask |= KRCharaStateChangeModeIgnoreCancelFlagMask;
            }
            if ([oIgnoreFinalAnimationButtonC state] == NSOnState) {
                changeMask |= KRCharaStateChangeModeSkipEndMask;
            }
            int nextKomaNumber = [oActionStateKomaButtonC selectedTag];
            
            [self changeState:nextStateID koma:nextKomaNumber mode:changeMask];            
        }
    }
    
    if (mouseOnce & MouseButtonLeft) {
        int nextStateID = [oActionStateButtonMouse selectedTag];
        if ([self getCurrentStateID] != nextStateID) {
            unsigned changeMask = KRCharaStateChangeModeNormalMask;
            if ([oIgnoreCancelDeclButtonMouse state] == NSOnState) {
                changeMask |= KRCharaStateChangeModeIgnoreCancelFlagMask;
            }
            if ([oIgnoreFinalAnimationButtonMouse state] == NSOnState) {
                changeMask |= KRCharaStateChangeModeSkipEndMask;
            }
            int nextKomaNumber = [oActionStateKomaButtonMouse selectedTag];
            
            [self changeState:nextStateID koma:nextKomaNumber mode:changeMask];            
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
        if ([oRevertToFirstStateWithNoKeyButton state] == NSOnState) {
            int firstStateID = [oFirstStateButton selectedTag];
            if ([self getCurrentStateID] != firstStateID) {
                unsigned changeMask = KRCharaStateChangeModeNormalMask;
                if ([oIgnoreCancelDeclRevertToFirstState state] == NSOnState) {
                    changeMask |= KRCharaStateChangeModeIgnoreCancelFlagMask;
                }
                if ([oIgnoreFinalAnimationRevertToFirstState state] == NSOnState) {
                    changeMask |= KRCharaStateChangeModeSkipEndMask;
                }                
                int firstKomaNumber = [oFirstStateKomaButton selectedTag];
                
                [self changeState:firstStateID koma:firstKomaNumber mode:changeMask];
            }
        }
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
    
    if (mKomaInterval != 0) {
        return;
    }
    
    if (!mHasChangingStarted && mNextState && [mCurrentKoma isCancelable]) {
        mHasChangingStarted = YES;
        if (mSkipEndToNext || ![mCurrentState targetKomaForCancel]) {
            mCurrentState = mNextState;
            mCurrentKoma = mNextKoma;
            mNextState = nil;
            mNextKoma = nil;
            mKomaNumber = [mCurrentKoma komaNumber];
            mKomaInterval = [mCurrentKoma interval];
            if (mKomaInterval == 0) {
                mKomaInterval = [mCurrentState defaultKomaInterval];
            }
        } else {
            BXChara2DKoma* endStartKoma = [mCurrentState targetKomaForCancel];
            mCurrentKoma = endStartKoma;
            mKomaNumber = [mCurrentKoma komaNumber];
            mKomaInterval = [mCurrentKoma interval];
            if (mKomaInterval == 0) {
                mKomaInterval = [mCurrentState defaultKomaInterval];
            }
        }
        return;
    }
    
    int gotoTargetNumber = [mCurrentKoma gotoTargetNumber];
    if (gotoTargetNumber > 0) {
        mKomaNumber = gotoTargetNumber;
    } else {
        mKomaNumber++;
    }
    if (mKomaNumber <= [mCurrentState komaCount]) {
        mCurrentKoma = [mCurrentState komaWithNumber:mKomaNumber];
        mKomaInterval = [mCurrentKoma interval];
        if (mKomaInterval == 0) {
            mKomaInterval = [mCurrentState defaultKomaInterval];
        }
    } else {
        if (mNextState) {
            mCurrentState = mNextState;
            mCurrentKoma = mNextKoma;
            mNextState = nil;
            mNextKoma = nil;
            mKomaNumber = [mCurrentKoma komaNumber];
            mKomaInterval = [mCurrentKoma interval];
            if (mKomaInterval == 0) {
                mKomaInterval = [mCurrentState defaultKomaInterval];
            }
        } else {
            BXChara2DState* nextState = [mTargetSpec stateWithID:[mCurrentState nextStateID]];
            if (nextState) {
                mCurrentState = nextState;
                mKomaNumber = 1;
                mCurrentKoma = [mCurrentState komaWithNumber:mKomaNumber];
                mKomaInterval = [mCurrentKoma interval];
                if (mKomaInterval == 0) {
                    mKomaInterval = [mCurrentState defaultKomaInterval];
                }                
            } else {
                mKomaNumber = [mCurrentKoma komaNumber];
            }
        }        
    }
    
    NSString* stateStr = [NSString stringWithFormat:@"%d[%@] - %d", [mCurrentState stateID], [mCurrentState stateName], [mCurrentKoma komaNumber]];
    [oCurrentStateField setStringValue:stateStr];
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

