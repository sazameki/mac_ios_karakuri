//
//  BXDocument.h
//  Karakuri Box
//
//  Created by numata on 10/02/27.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SZStatusBarBackgroundView.h"
#import "BXResourceGroup.h"
#import "BXParticleSimulatorView.h"


@interface BXDocument : NSDocument
{
    IBOutlet NSWindow*                  oMainWindow;
    IBOutlet NSOutlineView*             oElementView;
    IBOutlet NSTabView*                 oEditorTabView;
    IBOutlet BXParticleSimulatorView*   oParticleView;
    IBOutlet SZStatusBarBackgroundView* oStatusBarBGView;

    IBOutlet NSPopUpButton*             oParticleImageButton;

    IBOutlet NSTextField*               oParticleGravityFieldX;
    IBOutlet NSSlider*                  oParticleGravitySliderX;
    IBOutlet NSTextField*               oParticleGravityFieldY;
    IBOutlet NSSlider*                  oParticleGravitySliderY;
    IBOutlet NSTextField*               oParticleLifeField;
    IBOutlet NSSlider*                  oParticleLifeSlider;
    IBOutlet NSColorWell*               oParticleColorWell;
    IBOutlet NSTextField*               oParticleMinAngleVField;
    IBOutlet NSSlider*                  oParticleMinAngleVSlider;
    IBOutlet NSTextField*               oParticleMaxAngleVField;
    IBOutlet NSSlider*                  oParticleMaxAngleVSlider;
    IBOutlet NSPopUpButton*             oParticleBlendModeButton;

    IBOutlet NSButton*                  oParticleLoopButton;
    IBOutlet NSColorWell*               oParticleBGColorWell1;
    
    NSMutableArray*     mRootElements;
    
    BXResourceGroup*    mCharaGroup;
    BXResourceGroup*    mParticleGroup;
    BXResourceGroup*    mBGMGroup;
    BXResourceGroup*    mSEGroup;
}

///// パーティクル設定アクション

- (IBAction)changedParticleImage:(id)sender;

- (IBAction)changedParticleGravityX:(id)sender;
- (IBAction)changedParticleGravityY:(id)sender;
- (IBAction)changedParticleLife:(id)sender;
- (IBAction)changedParticleColor:(id)sender;
- (IBAction)changedParticleMinAngleV:(id)sender;
- (IBAction)changedParticleMaxAngleV:(id)sender;
- (IBAction)changedParticleBlendMode:(id)sender;

- (IBAction)changedParticleLoopSetting:(id)sender;
- (IBAction)changedParticleBGColor1:(id)sender;

@end

