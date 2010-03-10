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
#import "BXParticle2DSimulatorView.h"
#import "BXResourceFileManager.h"
#import "BXChara2DAtlasView.h"
#import "BXChara2DImage.h"
#import "BXChara2DKoma.h"
#import "BXChara2DKomaPreviewView.h"
#import "BXChara2DSimulatorView.h"


@interface BXDocument : NSDocument
{
    ///// 各種エディタに共通のアウトレット
    IBOutlet NSWindow*                  oMainWindow;
    IBOutlet NSOutlineView*             oElementView;
    IBOutlet NSTabView*                 oEditorTabView;
    IBOutlet SZStatusBarBackgroundView* oStatusBarBGView;

    ///// 2Dキャラクタの設定用アウトレット
    IBOutlet NSTextField*               oChara2DResourceIDField;
    IBOutlet NSTextField*               oChara2DResourceNameField;
    
    IBOutlet NSOutlineView*             oChara2DStateListView;
    IBOutlet NSOutlineView*             oChara2DImageListView;
    IBOutlet NSTextField*               oChara2DImageDivXField;
    IBOutlet NSTextField*               oChara2DImageDivYField;
    IBOutlet BXChara2DAtlasView*        oChara2DImageAtlasView;
    IBOutlet NSOutlineView*             oChara2DKomaListView;
    IBOutlet BXChara2DKomaPreviewView*  oChara2DKomaPreviewView;
    IBOutlet BXChara2DSimulatorView*    oChara2DSimulatorView;
    IBOutlet NSPopUpButtonCell*         oChara2DKomaIntervalButtonCell;
    
    IBOutlet NSPopUpButton*             oChara2DKomaDefaultIntervalButton;
    IBOutlet NSPopUpButton*             oChara2DStateNextStateButton;
    
    IBOutlet NSPanel*                   oChara2DSimulatorPanel;
    
    ///// パーティクルの設定用アウトレット
    IBOutlet BXParticle2DSimulatorView* oParticleView;

    IBOutlet NSTextField*               oParticleResourceIDField;
    IBOutlet NSTextField*               oParticleResourceNameField;

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
    
    BXResourceFileManager*  mFileManager;
    NSFileWrapper*          mRootWrapper;
}


///// 一般的な追加アクション

- (void)addChara2D:(id)sender;
- (void)addParticle2D:(id)sender;


///// 2Dキャラクタ設定アクション

- (IBAction)addChara2DImage:(id)sender;
- (IBAction)addChara2DState:(id)sender;
- (IBAction)changedChara2DImageDivX:(id)sender;
- (IBAction)changedChara2DImageDivY:(id)sender;
- (IBAction)changedChara2DResourceID:(id)sender;
- (IBAction)changedChara2DResourceName:(id)sender;
- (IBAction)removeChara2DState:(id)sender;
- (IBAction)changedChara2DKomaDefaultInterval:(id)sender;

- (IBAction)startChara2DSimulator:(id)sender;
- (IBAction)stopChara2DSimulator:(id)sender;


///// パーティクル設定アクション

- (IBAction)changedParticleResourceID:(id)sender;
- (IBAction)changedParticleResourceName:(id)sender;

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


///// 2Dキャラクタ設定に関するメソッド

- (BOOL)canAddChara2DImage;
- (BOOL)canRemoveChara2DImage;
- (BOOL)canRemoveChara2DState;
- (void)removeSelectedChara2DKoma;
- (BXChara2DImage*)selectedChara2DImage;
- (BXChara2DKoma*)selectedChara2DKoma;
- (void)updateChara2DAtlasList;
- (BOOL)isChara2DStateSelected;
- (BOOL)isChara2DKomaSelected;
- (BOOL)canChara2DStateSelectNextState;

- (void)addChara2DWithInfo:(NSDictionary*)theInfo;


///// 2Dパーティクル設定に関するメソッド

- (void)addParticle2DWithInfo:(NSDictionary*)theInfo;


///// その他のアクセッサ
- (BXResourceFileManager*)fileManager;
- (NSFileWrapper*)rootWrapper;
- (NSFileWrapper*)contentsWrapper;
- (NSFileWrapper*)resourcesWrapper;


@end

