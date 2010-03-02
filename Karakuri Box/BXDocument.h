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
    IBOutlet NSTextField*               oParticleMinVXField;
    IBOutlet NSTextField*               oParticleMinVYField;
    IBOutlet NSSlider*                  oParticleMinVXSlider;
    IBOutlet NSSlider*                  oParticleMinVYSlider;
    IBOutlet NSTextField*               oParticleMaxVXField;
    IBOutlet NSTextField*               oParticleMaxVYField;
    IBOutlet NSSlider*                  oParticleMaxVXSlider;
    IBOutlet NSSlider*                  oParticleMaxVYSlider;
    IBOutlet NSTextField*               oParticleDeltaScaleField;
    IBOutlet NSSlider*                  oParticleDeltaScaleSlider;
    IBOutlet NSTextField*               oParticleDeltaAlphaField;
    IBOutlet NSSlider*                  oParticleDeltaAlphaSlider;
    IBOutlet NSTextField*               oParticleDeltaRedField;
    IBOutlet NSSlider*                  oParticleDeltaRedSlider;
    IBOutlet NSTextField*               oParticleDeltaGreenField;
    IBOutlet NSSlider*                  oParticleDeltaGreenSlider;
    IBOutlet NSTextField*               oParticleDeltaBlueField;
    IBOutlet NSSlider*                  oParticleDeltaBlueSlider;
    IBOutlet NSTextField*               oParticleGenerateCountField;
    IBOutlet NSSlider*                  oParticleGenerateCountSlider;
    IBOutlet NSTextField*               oParticleMaxParticleCountField;
    IBOutlet NSSlider*                  oParticleMaxParticleCountSlider;
    
    IBOutlet NSButton*                  oParticleLoopButton;
    IBOutlet NSColorWell*               oParticleBGColorWell1;
    
    NSMutableArray*     mRootElements;
    
    BXResourceGroup*    mBackgroundGroup;
    BXResourceGroup*    mCharaGroup;
    BXResourceGroup*    mParticleGroup;
    BXResourceGroup*    mBGMGroup;
    BXResourceGroup*    mSEGroup;
    BXResourceGroup*    mStageGroup;
}

///// パーティクル設定アクション

- (IBAction)changedParticleImage:(id)sender;

- (IBAction)changedParticleGravityX:(id)sender;
- (IBAction)changedParticleGravityY:(id)sender;
- (IBAction)changedParticleLife:(id)sender;
- (IBAction)changedParticleColor:(id)sender;
- (IBAction)changedParticleMinAngleV:(id)sender;
- (IBAction)changedParticleMaxAngleV:(id)sender;
- (IBAction)changedParticleMaxVX:(id)sender;
- (IBAction)changedParticleMaxVY:(id)sender;
- (IBAction)changedParticleMinVX:(id)sender;
- (IBAction)changedParticleMinVY:(id)sender;
- (IBAction)changedParticleBlendMode:(id)sender;
- (IBAction)changedParticleDeltaScale:(id)sender;
- (IBAction)changedParticleDeltaColor:(id)sender;
- (IBAction)changedParticleGenerateCount:(id)sender;
- (IBAction)changedParticleMaxCount:(id)sender;

- (IBAction)changedParticleLoopSetting:(id)sender;
- (IBAction)changedParticleBGColor1:(id)sender;

@end

