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
#import "BXChara2DMotion.h"
#import "BXChara2DKoma.h"
#import "KRTexture2D.h"
#import "KarakuriTypes.h"


typedef unsigned long long  KRKeyInfo;
typedef unsigned int        KRMouseInfo;


@interface BXChara2DSimulatorView : BXOpenGLView {
    IBOutlet NSButton*      oAnimationButton;
    IBOutlet NSPopUpButton* oFirstMotionButton;
    IBOutlet NSPopUpButton* oFirstMotionKomaButton;
    IBOutlet NSTextField*   oCurrentMotionField;
    IBOutlet NSButton*      oRevertToFirstMotionWithNoKeyButton;
    IBOutlet NSButton*      oIgnoreCancelDeclRevertToFirstMotion;
    IBOutlet NSButton*      oIgnoreFinalAnimationRevertToFirstMotion;
    
    IBOutlet NSPopUpButton* oActionMotionButtonUp;
    IBOutlet NSPopUpButton* oActionMotionKomaButtonUp;
    IBOutlet NSButton*      oIgnoreCancelDeclButtonUp;
    IBOutlet NSButton*      oIgnoreFinalAnimationButtonUp;
    IBOutlet NSTextField*   oActionSpeedFieldUp;

    IBOutlet NSPopUpButton* oActionMotionButtonDown;
    IBOutlet NSPopUpButton* oActionMotionKomaButtonDown;
    IBOutlet NSButton*      oIgnoreCancelDeclButtonDown;
    IBOutlet NSButton*      oIgnoreFinalAnimationButtonDown;
    IBOutlet NSTextField*   oActionSpeedFieldDown;

    IBOutlet NSPopUpButton* oActionMotionButtonLeft;
    IBOutlet NSPopUpButton* oActionMotionKomaButtonLeft;
    IBOutlet NSButton*      oIgnoreCancelDeclButtonLeft;
    IBOutlet NSButton*      oIgnoreFinalAnimationButtonLeft;
    IBOutlet NSTextField*   oActionSpeedFieldLeft;

    IBOutlet NSPopUpButton* oActionMotionButtonRight;
    IBOutlet NSPopUpButton* oActionMotionKomaButtonRight;
    IBOutlet NSButton*      oIgnoreCancelDeclButtonRight;
    IBOutlet NSButton*      oIgnoreFinalAnimationButtonRight;
    IBOutlet NSTextField*   oActionSpeedFieldRight;

    IBOutlet NSPopUpButton* oActionMotionButtonZ;
    IBOutlet NSPopUpButton* oActionMotionKomaButtonZ;
    IBOutlet NSButton*      oIgnoreCancelDeclButtonZ;
    IBOutlet NSButton*      oIgnoreFinalAnimationButtonZ;

    IBOutlet NSPopUpButton* oActionMotionButtonX;
    IBOutlet NSPopUpButton* oActionMotionKomaButtonX;
    IBOutlet NSButton*      oIgnoreCancelDeclButtonX;
    IBOutlet NSButton*      oIgnoreFinalAnimationButtonX;

    IBOutlet NSPopUpButton* oActionMotionButtonC;
    IBOutlet NSPopUpButton* oActionMotionKomaButtonC;
    IBOutlet NSButton*      oIgnoreCancelDeclButtonC;
    IBOutlet NSButton*      oIgnoreFinalAnimationButtonC;

    IBOutlet NSPopUpButton* oActionMotionButtonMouse;
    IBOutlet NSPopUpButton* oActionMotionKomaButtonMouse;
    IBOutlet NSButton*      oIgnoreCancelDeclButtonMouse;
    IBOutlet NSButton*      oIgnoreFinalAnimationButtonMouse;
    IBOutlet NSButton*      oDoChangeLocationButtonMouse;
    
    BXChara2DSpec*      mTargetSpec;

    BXChara2DMotion*    mCurrentMotion;
    BXChara2DKoma*      mCurrentKoma;
    int                 mKomaIndex;
    int                 mKomaInterval;

    KRKeyInfo           mKeyState;
    KRKeyInfo           mKeyStateOld;

    KRMouseInfo         mMouseState;
    KRMouseInfo         mMouseStateOld;

    KRVector2D*         mCurrentPos;
    
    BOOL                mIsAnimationRunning;
    NSPoint             mMousePos;

    BXChara2DMotion*    mNextMotion;
    BXChara2DKoma*      mNextKoma;
    BOOL                mSkipEndToNext;
    BOOL                mHasChangingStarted;
    
    BOOL                mHadInput;
}

- (IBAction)changedFirstMotion:(id)sender;
- (IBAction)changedFirstMotionKoma:(id)sender;

- (IBAction)changedActionMotionDown:(id)sender;
- (IBAction)changedActionMotionUp:(id)sender;
- (IBAction)changedActionMotionLeft:(id)sender;
- (IBAction)changedActionMotionRight:(id)sender;
- (IBAction)changedActionMotionZ:(id)sender;
- (IBAction)changedActionMotionX:(id)sender;
- (IBAction)changedActionMotionC:(id)sender;
- (IBAction)changedActionMotionMouse:(id)sender;

- (IBAction)startAnimation:(id)sender;
- (IBAction)stopAnimation:(id)sender;

- (void)saveAnimationSettings;
- (void)setupForChara2DSpec:(BXChara2DSpec*)aSpec;

@end

