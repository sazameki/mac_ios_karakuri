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
#import "BXTexture2DPreviewView.h"
#import "BXTexture2DAtlas.h"


@interface BXDocument : NSDocument
{
    ///// 各種エディタに共通のアウトレット
    IBOutlet NSWindow*                  oMainWindow;
    IBOutlet NSOutlineView*             oElementView;
    IBOutlet NSTabView*                 oEditorTabView;
    IBOutlet SZStatusBarBackgroundView* oStatusBarBGView;
    IBOutlet NSView*                    oExportAccessoryView;
    IBOutlet NSMatrix*                  oExportOptionMatrix;

    ///// 2Dテクスチャの設定用アウトレット
    IBOutlet NSTextField*               oTex2DGroupIDField;
    IBOutlet NSTextField*               oTex2DResourceIDField;
    IBOutlet NSTextField*               oTex2DResourceNameField;
    IBOutlet NSTextField*               oTex2DImageNameField;
    IBOutlet NSPopUpButton*             oTex2DPreviewScaleButton;
    IBOutlet BXTexture2DPreviewView*    oTex2DPreviewView;
    IBOutlet NSOutlineView*             oTex2DAtlasListView;
    IBOutlet NSTextField*               oTex2DAtlasStartPosXField;
    IBOutlet NSButton*                  oTex2DAtlasPreviewOnButton;

    ///// 2Dキャラクタの設定用アウトレット
    IBOutlet NSTextField*               oChara2DGroupIDField;
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

    IBOutlet NSPopUpButton*             oChara2DKomaPreviewScaleButton;
    IBOutlet NSPopUpButton*             oChara2DStateCancelKomaNumberButton;
    IBOutlet NSPopUpButton*             oChara2DKomaActionCommandButton;

    IBOutlet NSPanel*                   oChara2DSimulatorPanel;
    
    IBOutlet NSButton*                  oChara2DHitButtonAll;
    IBOutlet NSButton*                  oChara2DHitButton1;
    IBOutlet NSButton*                  oChara2DHitButton2;
    IBOutlet NSButton*                  oChara2DHitButton3;
    IBOutlet NSButton*                  oChara2DHitButton4;
    IBOutlet NSButton*                  oChara2DHitButton5;
    IBOutlet NSButton*                  oChara2DHitButton6;
    IBOutlet NSButton*                  oChara2DHitButton7;
    IBOutlet NSButton*                  oChara2DHitButton8;
    IBOutlet NSButton*                  oChara2DHitButton9;
    IBOutlet NSButton*                  oChara2DHitButton10;
    IBOutlet NSButton*                  oChara2DHitButton11;
    IBOutlet NSButton*                  oChara2DHitButton12;
    IBOutlet NSButton*                  oChara2DHitButtonAddCircle;
    IBOutlet NSButton*                  oChara2DHitButtonAddRect;
    IBOutlet NSTextField*               oChara2DHitCountField;
    
    ///// パーティクルの設定用アウトレット
    IBOutlet BXParticle2DSimulatorView* oParticleView;

    IBOutlet NSTextField*               oParticleGroupIDField;
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
    BXResourceGroup*    mTex2DGroup;
    BXResourceGroup*    mChara2DGroup;
    BXResourceGroup*    mParticle2DGroup;
    BXResourceGroup*    mBGMGroup;
    BXResourceGroup*    mSEGroup;
    BXResourceGroup*    mStageGroup;
    
    BXResourceFileManager*  mFileManager;
    NSFileWrapper*          mRootWrapper;
}


///// 一般的なアクション

- (void)addTexture2D:(id)sender;
- (void)addChara2D:(id)sender;
- (void)addParticle2D:(id)sender;

- (void)exportAllResources:(id)sender;
- (void)exportSelectedResource:(id)sender;

- (void)updateExportedResources:(id)sender;


///// 2Dテクスチャ設定アクション

- (IBAction)referTex2DFile:(id)sender;
- (IBAction)changedTex2DPreviewScale:(id)sender;
- (IBAction)changedTex2DGroupID:(id)sender;
- (IBAction)changedTex2DResourceID:(id)sender;
- (IBAction)changedTex2DResourceName:(id)sender;
- (IBAction)addTex2DAtlas:(id)sender;
- (IBAction)changedTex2DAtlasPreviewOn:(id)sender;


///// 2Dキャラクタ設定アクション

- (IBAction)changedChara2DGroupID:(id)sender;
- (IBAction)changedChara2DResourceID:(id)sender;
- (IBAction)changedChara2DResourceName:(id)sender;

- (IBAction)addChara2DImage:(id)sender;
- (IBAction)addChara2DState:(id)sender;
- (IBAction)changedChara2DImageDivX:(id)sender;
- (IBAction)changedChara2DImageDivY:(id)sender;
- (IBAction)removeChara2DState:(id)sender;
- (IBAction)changedChara2DKomaDefaultInterval:(id)sender;

- (IBAction)changedChara2DKomaPreviewScale:(id)sender;

- (IBAction)startChara2DSimulator:(id)sender;
- (IBAction)stopChara2DSimulator:(id)sender;

- (IBAction)startChara2DKomaPreviewAnimation:(id)sender;

- (IBAction)changedChara2DShowsHitInfos:(id)sender;

- (IBAction)activateChara2DHitButton1:(id)sender;
- (IBAction)activateChara2DHitButton2:(id)sender;
- (IBAction)activateChara2DHitButton3:(id)sender;
- (IBAction)activateChara2DHitButton4:(id)sender;
- (IBAction)activateChara2DHitButton5:(id)sender;
- (IBAction)activateChara2DHitButton6:(id)sender;
- (IBAction)activateChara2DHitButton7:(id)sender;
- (IBAction)activateChara2DHitButton8:(id)sender;
- (IBAction)activateChara2DHitButton9:(id)sender;
- (IBAction)activateChara2DHitButton10:(id)sender;
- (IBAction)activateChara2DHitButton11:(id)sender;
- (IBAction)activateChara2DHitButton12:(id)sender;

- (IBAction)addChara2DHitInfoOval:(id)sender;
- (IBAction)addChara2DHitInfoRect:(id)sender;

- (IBAction)removeSelectedChara2D:(id)sender;
- (IBAction)removeSelectedChara2DImage:(id)sender;


///// パーティクル設定アクション

- (IBAction)changedParticleGroupID:(id)sender;
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

- (IBAction)removeSelectedParticle2D:(id)sender;


///// 2Dテクスチャ設定に関するメソッド

- (BXTexture2DSpec*)selectedTex2DSpec;
- (BXTexture2DAtlas*)selectedTex2DAtlas;

- (void)addTexture2DWithInfo:(NSDictionary*)theInfo;
- (void)setupEditorUIForTexture2D:(BXTexture2DSpec*)theSpec;

- (BOOL)isTex2DAtlasSelected;
- (int)tex2DAtlasStartPosX;
- (void)setTex2DAtlasStartPosX:(int)x;
- (int)tex2DAtlasStartPosY;
- (void)setTex2DAtlasStartPosY:(int)y;
- (int)tex2DAtlasSizeX;
- (void)setTex2DAtlasSizeX:(int)x;
- (int)tex2DAtlasSizeY;
- (void)setTex2DAtlasSizeY:(int)y;
- (int)tex2DAtlasCountX;
- (void)setTex2DAtlasCountX:(int)x;
- (int)tex2DAtlasCountY;
- (void)setTex2DAtlasCountY:(int)y;


///// 2Dキャラクタ設定に関するメソッド

- (BOOL)canAddChara2DImage;
- (BOOL)canRemoveChara2DImage;
- (BOOL)canRemoveChara2DState;
- (void)removeSelectedChara2DKoma;
- (BXChara2DSpec*)selectedChara2DSpec;
- (BXChara2DImage*)selectedChara2DImage;
- (BXChara2DState*)selectedChara2DState;
- (BXChara2DKoma*)selectedChara2DKoma;
- (void)updateChara2DAtlasList;
- (BOOL)isChara2DImageSelected;
- (BOOL)isChara2DKomaSelected;
- (BOOL)isChara2DStateSelected;
- (BOOL)canChara2DStateSelectNextState;

- (void)addChara2DWithInfo:(NSDictionary*)theInfo;


///// 2Dパーティクル設定に関するメソッド

- (void)addParticle2DWithInfo:(NSDictionary*)theInfo;


///// その他のアクセッサ
- (BXResourceFileManager*)fileManager;
- (NSFileWrapper*)rootWrapper;
- (NSFileWrapper*)contentsWrapper;
- (NSFileWrapper*)resourcesWrapper;

- (BXResourceGroup*)chara2DGroup;
- (BXResourceGroup*)particle2DGroup;


@end

