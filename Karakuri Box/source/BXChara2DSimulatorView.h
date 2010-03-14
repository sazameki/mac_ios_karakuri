//
//  BXChara2DSimulatorView.h
//  Karakuri Box
//
//  Created by numata on 10/03/11.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BXOpenGLView.h"
#import "KRColor.h"
#import "BXChara2DSpec.h"
#import "BXChara2DState.h"
#import "BXChara2DKoma.h"
#import "KRTexture2D.h"
#import "KarakuriTypes.h"


typedef unsigned long long  KRKeyInfo;
typedef unsigned int        KRMouseInfo;


@interface BXChara2DSimulatorView : BXOpenGLView {
    IBOutlet NSButton*      oAnimationButton;
    IBOutlet NSPopUpButton* oFirstStateButton;
    IBOutlet NSPopUpButton* oFirstStateKomaButton;
    IBOutlet NSTextField*   oCurrentStateField;
    IBOutlet NSButton*      oRevertToFirstStateWithNoKeyButton;
    IBOutlet NSButton*      oIgnoreCancelDeclRevertToFirstState;
    IBOutlet NSButton*      oIgnoreFinalAnimationRevertToFirstState;
    
    IBOutlet NSPopUpButton* oActionStateButtonUp;
    IBOutlet NSPopUpButton* oActionStateKomaButtonUp;
    IBOutlet NSButton*      oIgnoreCancelDeclButtonUp;
    IBOutlet NSButton*      oIgnoreFinalAnimationButtonUp;
    IBOutlet NSTextField*   oActionSpeedFieldUp;

    IBOutlet NSPopUpButton* oActionStateButtonDown;
    IBOutlet NSPopUpButton* oActionStateKomaButtonDown;
    IBOutlet NSButton*      oIgnoreCancelDeclButtonDown;
    IBOutlet NSButton*      oIgnoreFinalAnimationButtonDown;
    IBOutlet NSTextField*   oActionSpeedFieldDown;

    IBOutlet NSPopUpButton* oActionStateButtonLeft;
    IBOutlet NSPopUpButton* oActionStateKomaButtonLeft;
    IBOutlet NSButton*      oIgnoreCancelDeclButtonLeft;
    IBOutlet NSButton*      oIgnoreFinalAnimationButtonLeft;
    IBOutlet NSTextField*   oActionSpeedFieldLeft;

    IBOutlet NSPopUpButton* oActionStateButtonRight;
    IBOutlet NSPopUpButton* oActionStateKomaButtonRight;
    IBOutlet NSButton*      oIgnoreCancelDeclButtonRight;
    IBOutlet NSButton*      oIgnoreFinalAnimationButtonRight;
    IBOutlet NSTextField*   oActionSpeedFieldRight;

    IBOutlet NSPopUpButton* oActionStateButtonZ;
    IBOutlet NSPopUpButton* oActionStateKomaButtonZ;
    IBOutlet NSButton*      oIgnoreCancelDeclButtonZ;
    IBOutlet NSButton*      oIgnoreFinalAnimationButtonZ;

    IBOutlet NSPopUpButton* oActionStateButtonX;
    IBOutlet NSPopUpButton* oActionStateKomaButtonX;
    IBOutlet NSButton*      oIgnoreCancelDeclButtonX;
    IBOutlet NSButton*      oIgnoreFinalAnimationButtonX;

    IBOutlet NSPopUpButton* oActionStateButtonC;
    IBOutlet NSPopUpButton* oActionStateKomaButtonC;
    IBOutlet NSButton*      oIgnoreCancelDeclButtonC;
    IBOutlet NSButton*      oIgnoreFinalAnimationButtonC;

    IBOutlet NSPopUpButton* oActionStateButtonMouse;
    IBOutlet NSPopUpButton* oActionStateKomaButtonMouse;
    IBOutlet NSButton*      oIgnoreCancelDeclButtonMouse;
    IBOutlet NSButton*      oIgnoreFinalAnimationButtonMouse;
    IBOutlet NSButton*      oDoChangeLocationButtonMouse;
    
    BXChara2DSpec*  mTargetSpec;

    BXChara2DState* mCurrentState;
    BXChara2DKoma*  mCurrentKoma;
    int             mKomaNumber;
    int             mKomaInterval;

    KRKeyInfo       mKeyState;
    KRKeyInfo       mKeyStateOld;

    KRMouseInfo     mMouseState;
    KRMouseInfo     mMouseStateOld;

    KRVector2D*     mCurrentPos;
    
    BOOL            mIsAnimationRunning;
    NSPoint         mMousePos;

    BXChara2DState* mNextState;
    BXChara2DKoma*  mNextKoma;
    BOOL            mSkipEndToNext;
    BOOL            mHasChangingStarted;
}

- (IBAction)changedFirstState:(id)sender;
- (IBAction)changedFirstStateKoma:(id)sender;

- (IBAction)changedActionStateDown:(id)sender;
- (IBAction)changedActionStateUp:(id)sender;
- (IBAction)changedActionStateLeft:(id)sender;
- (IBAction)changedActionStateRight:(id)sender;
- (IBAction)changedActionStateZ:(id)sender;
- (IBAction)changedActionStateX:(id)sender;
- (IBAction)changedActionStateC:(id)sender;
- (IBAction)changedActionStateMouse:(id)sender;

- (IBAction)startAnimation:(id)sender;
- (IBAction)stopAnimation:(id)sender;

- (void)saveAnimationSettings;
- (void)setupForChara2DSpec:(BXChara2DSpec*)aSpec;

@end

