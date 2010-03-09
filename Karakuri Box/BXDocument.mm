//
//  BXDocument.m
//  Karakuri Box
//
//  Created by numata on 10/02/27.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BXDocument.h"

#import "BXBackgroundSpec.h"
#import "BXCharaSpec.h"
#import "BXParticleSpec.h"
#import "BXBGMResource.h"
#import "BXSEResource.h"
#import "BXStageSpec.h"


static NSString*    sKADocumentToolbarItemAddBackground  = @"KADocumentToolbarItemAddBackground";
static NSString*    sKADocumentToolbarItemAddCharacter  = @"KADocumentToolbarItemAddCharacter";
static NSString*    sKADocumentToolbarItemAddParticle   = @"KADocumentToolbarItemAddParticle";
static NSString*    sKADocumentToolbarItemAddBGM        = @"KADocumentToolbarItemAddBGM";
static NSString*    sKADocumentToolbarItemAddSE         = @"KADocumentToolbarItemAddSE";
static NSString*    sKADocumentToolbarItemAddStage      = @"KADocumentToolbarItemAddStage";


@interface BXDocument ()

- (BXCharaSpec*)selectedChara2DSpec;
- (BXSingleParticleSpec*)selectedSingleParticleSpec;
- (void)setupEditorUIForChara2D:(BXCharaSpec*)theSpec;
- (void)setupEditorUIForSingleParticle:(BXSingleParticleSpec*)theSpec;

@end


@implementation BXDocument

#pragma mark -
#pragma mark 基本設定

- (NSString *)windowNibName { return @"BXDocument"; }


#pragma mark -
#pragma mark 初期化・クリーンアップ

- (id)init
{
    self = [super init];
    if (self) {
        mRootElements = [[NSMutableArray array] retain];
        
        mBackgroundGroup = [[[BXResourceGroup alloc] initWithName:@"*bg-group"] autorelease];
        mCharaGroup = [[[BXResourceGroup alloc] initWithName:@"*chara-group"] autorelease];
        mParticleGroup = [[[BXResourceGroup alloc] initWithName:@"*particle-group"] autorelease];
        mBGMGroup = [[[BXResourceGroup alloc] initWithName:@"*bgm-group"] autorelease];
        mSEGroup = [[[BXResourceGroup alloc] initWithName:@"*se-group"] autorelease];
        mStageGroup = [[[BXResourceGroup alloc] initWithName:@"*stage-group"] autorelease];
        //[mRootElements addObject:mBackgroundGroup];
        [mRootElements addObject:mCharaGroup];
        [mRootElements addObject:mParticleGroup];
        //[mRootElements addObject:mBGMGroup];
        //[mRootElements addObject:mSEGroup];
        //[mRootElements addObject:mStageGroup];
    }
    return self;
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    
    // ツールバーのセットアップ
    NSToolbar* toolbar = [[[NSToolbar alloc] initWithIdentifier:@"Main Toolbar"] autorelease];
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setAutosavesConfiguration:YES];
    [toolbar setDelegate:self];
    [oMainWindow setToolbar:toolbar];
    
    // カラーパネルの設定
    [[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
}

- (void)dealloc
{
    [mRootElements release];
    [super dealloc];
}


#pragma mark -
#pragma mark アクセッサ

- (BXCharaSpec*)selectedChara2DSpec
{
    int selectedRow = [oElementView selectedRow];
    if (selectedRow < 0) {
        return nil;
    }
    
    BXResourceElement* theElem = [oElementView itemAtRow:selectedRow];
    if ([theElem isKindOfClass:[BXCharaSpec class]]) {
        return (BXCharaSpec*)theElem;
    }
    return nil;
}

- (BXChara2DState*)selectedChara2DState
{
    int selectedRow = [oChara2DStateListView selectedRow];
    if (selectedRow < 0) {
        return nil;
    }
    
    BXCharaSpec* selectedSpec = [self selectedChara2DSpec];
    return [selectedSpec stateAtIndex:selectedRow];
}

- (BXSingleParticleSpec*)selectedSingleParticleSpec;
{
    int selectedRow = [oElementView selectedRow];
    if (selectedRow < 0) {
        return nil;
    }
    
    BXResourceElement* theElem = [oElementView itemAtRow:selectedRow];
    if ([theElem isKindOfClass:[BXSingleParticleSpec class]]) {
        return (BXSingleParticleSpec*)theElem;
    }
    return nil;
}


#pragma mark -
#pragma mark アクション

- (void)addBackground:(id)sender
{
    BXBackgroundSpec* newBGSpec = [[[BXCharaSpec alloc] initWithName:@"New BG"] autorelease];
    [mBackgroundGroup addChild:newBGSpec];
    
    [oElementView reloadData];
    [oElementView expandItem:mBackgroundGroup];
    
    int row = [oElementView rowForItem:newBGSpec];
    [oElementView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
}

- (void)addCharacter:(id)sender
{
    BXCharaSpec* newCharaSpec = [[[BXCharaSpec alloc] initWithName:@"New Chara"] autorelease];

    if ([mCharaGroup childCount] > 0) {
        int lastID = [[mCharaGroup childAtIndex:[mCharaGroup childCount]-1] resourceID];
        [newCharaSpec setResourceID:lastID+1];
    } else {
        [newCharaSpec setResourceID:1];
    }
    
    [mCharaGroup addChild:newCharaSpec];
    
    [oElementView reloadData];
    [oElementView expandItem:mCharaGroup];    

    int row = [oElementView rowForItem:newCharaSpec];
    [oElementView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
}

- (void)addParticle:(id)sender
{
    BXSingleParticleSpec* newParticleSpec = [[[BXSingleParticleSpec alloc] initWithName:@"New Particle"] autorelease];
    
    if ([mParticleGroup childCount] > 0) {
        int lastID = [[mParticleGroup childAtIndex:[mParticleGroup childCount]-1] resourceID];
        [newParticleSpec setResourceID:lastID+1];
    } else {
        [newParticleSpec setResourceID:1];
    }
    
    [mParticleGroup addChild:newParticleSpec];
    
    [oElementView reloadData];
    [oElementView expandItem:mParticleGroup];
    
    int row = [oElementView rowForItem:newParticleSpec];
    [oElementView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
}

- (void)addBGM:(id)sender
{
    BXBGMResource* newBGM = [[[BXBGMResource alloc] initWithName:@"New BGM"] autorelease];
    [mBGMGroup addChild:newBGM];
    
    [oElementView reloadData];
    [oElementView expandItem:mBGMGroup];
    
    int row = [oElementView rowForItem:newBGM];
    [oElementView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
}

- (void)addSE:(id)sender
{
    BXSEResource* newSE = [[[BXSEResource alloc] initWithName:@"New SE"] autorelease];
    [mSEGroup addChild:newSE];
    
    [oElementView reloadData];
    [oElementView expandItem:mSEGroup];
    
    int row = [oElementView rowForItem:newSE];
    [oElementView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
}

- (void)addStage:(id)sender
{
    BXStageSpec* newStage = [[[BXStageSpec alloc] initWithName:@"New Stage"] autorelease];
    [mStageGroup addChild:newStage];
    
    [oElementView reloadData];
    [oElementView expandItem:mStageGroup];
    
    int row = [oElementView rowForItem:newStage];
    [oElementView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
}


#pragma mark -
#pragma mark 2Dキャラクタの設定アクション

- (IBAction)changedChara2DResourceID:(id)sender
{
    int theID = [oChara2DResourceIDField intValue];
    
    BXCharaSpec* charaSpec = [self selectedChara2DSpec];
    [charaSpec setResourceID:theID];
    
    [oElementView reloadData];
    
    int theRow = [oElementView rowForItem:charaSpec];
    [oElementView selectRowIndexes:[NSIndexSet indexSetWithIndex:theRow] byExtendingSelection:NO];
}

- (IBAction)changedChara2DResourceName:(id)sender
{
    NSString* theName = [oChara2DResourceNameField stringValue];
    
    BXCharaSpec* charaSpec = [self selectedChara2DSpec];
    [charaSpec setResourceName:theName];
    
    [oElementView reloadData];
}

- (IBAction)addChara2DState:(id)sender
{
    BXCharaSpec* charaSpec = [self selectedChara2DSpec];
    
    int stateCount = [charaSpec stateCount];
    BXChara2DState* lastState = [charaSpec stateAtIndex:stateCount-1];
    int nextID = [lastState stateID] + 1;
    
    BXChara2DState* newState = [charaSpec addNewState];
    [newState setStateID:nextID];
    
    [oChara2DStateListView reloadData];
    
    int theRow = [oChara2DStateListView rowForItem:newState];
    [oChara2DStateListView scrollRowToVisible:theRow];
    [oChara2DStateListView selectRowIndexes:[NSIndexSet indexSetWithIndex:theRow] byExtendingSelection:NO];
}


#pragma mark-
#pragma mark 2Dキャラクタに関係する操作

- (BOOL)canRemoteChara2DState
{
    BXChara2DState* selectedState = [self selectedChara2DState];
    return (selectedState != nil)? YES: NO;
}


#pragma mark -
#pragma mark パーティクルの設定アクション

- (IBAction)changedParticleResourceID:(id)sender
{
    int theID = [oParticleResourceIDField intValue];

    BXSingleParticleSpec* particleSpec = [self selectedSingleParticleSpec];
    [particleSpec setResourceID:theID];
    
    [oElementView reloadData];
    
    int theRow = [oElementView rowForItem:particleSpec];
    [oElementView selectRowIndexes:[NSIndexSet indexSetWithIndex:theRow] byExtendingSelection:NO];
}

- (IBAction)changedParticleResourceName:(id)sender
{
    NSString* theName = [oParticleResourceNameField stringValue];
    
    BXSingleParticleSpec* particleSpec = [self selectedSingleParticleSpec];
    [particleSpec setResourceName:theName];
    
    [oElementView reloadData];
}

- (IBAction)changedParticleImage:(id)sender
{
    int tag = [oParticleImageButton selectedTag];
    
    BXSingleParticleSpec* particleSpec = [self selectedSingleParticleSpec];
    [particleSpec setImageTag:tag];
 
    [oParticleView rebuildParticleSystem];
}

- (IBAction)changedParticleLoopSetting:(id)sender
{
    BOOL doLoop = ([oParticleLoopButton state] == NSOnState);
 
    BXSingleParticleSpec* particleSpec = [self selectedSingleParticleSpec];
    [particleSpec setDoLoop:doLoop];
}

- (IBAction)changedParticleGravityX:(id)sender
{
    float gravityX = 0.0f;
    if (sender == oParticleGravitySliderX) {
        gravityX = [oParticleGravitySliderX floatValue];
    } else {
        gravityX = [oParticleGravityFieldX floatValue];
    }
    
    BXSingleParticleSpec* particleSpec = [self selectedSingleParticleSpec];
    [particleSpec setGravityX:gravityX];

    [self setupEditorUIForSingleParticle:particleSpec];
    [oParticleView rebuildParticleSystem];
}

- (IBAction)changedParticleGravityY:(id)sender
{
    float gravityY = 0.0f;
    if (sender == oParticleGravitySliderY) {
        gravityY = [oParticleGravitySliderY floatValue];
    } else {
        gravityY = [oParticleGravityFieldY floatValue];
    }
    
    BXSingleParticleSpec* particleSpec = [self selectedSingleParticleSpec];
    [particleSpec setGravityY:gravityY];

    [self setupEditorUIForSingleParticle:particleSpec];
    [oParticleView rebuildParticleSystem];
}

- (IBAction)changedParticleLife:(id)sender
{
    int life = 1;
    if (sender == oParticleLifeSlider) {
        life = [oParticleLifeSlider intValue];
    } else {
        life = [oParticleLifeField intValue];
    }
    
    BXSingleParticleSpec* particleSpec = [self selectedSingleParticleSpec];
    [particleSpec setLife:life];

    [self setupEditorUIForSingleParticle:particleSpec];
    [oParticleView rebuildParticleSystem];
}

- (IBAction)changedParticleColor:(id)sender
{
    NSColor* color = [oParticleColorWell color];
    color = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];

    float r = [color redComponent];
    float g = [color greenComponent];
    float b = [color blueComponent];
    float a = [color alphaComponent];
    
    BXSingleParticleSpec* particleSpec = [self selectedSingleParticleSpec];
    [particleSpec setColor:KRColor(r, g, b, a)];

    [oParticleView rebuildParticleSystem];
}

- (IBAction)changedParticleMinAngleV:(id)sender
{
    int degree = 0;
    if (sender == oParticleMinAngleVSlider) {
        degree = [oParticleMinAngleVSlider intValue];
    } else {
        degree = [oParticleMinAngleVField intValue];
    }
    
    BXSingleParticleSpec* particleSpec = [self selectedSingleParticleSpec];
    [particleSpec setMinAngleV:degree];
    
    [self setupEditorUIForSingleParticle:particleSpec];
    [oParticleView rebuildParticleSystem];
}

- (IBAction)changedParticleMaxAngleV:(id)sender
{
    int degree = 0;
    if (sender == oParticleMaxAngleVSlider) {
        degree = [oParticleMaxAngleVSlider intValue];
    } else {
        degree = [oParticleMaxAngleVField intValue];
    }
    
    BXSingleParticleSpec* particleSpec = [self selectedSingleParticleSpec];
    [particleSpec setMaxAngleV:degree];
    
    [self setupEditorUIForSingleParticle:particleSpec];
    [oParticleView rebuildParticleSystem];
}

- (IBAction)changedParticleBlendMode:(id)sender
{
    int blendModeTag = [oParticleBlendModeButton selectedTag];
    KRBlendMode blendMode = KRBlendModeAlpha;
    if (blendModeTag == 1) {
        blendMode = KRBlendModeAddition;
    } else if (blendModeTag == 2) {
        blendMode = KRBlendModeScreen;
    }

    BXSingleParticleSpec* particleSpec = [self selectedSingleParticleSpec];
    [particleSpec setBlendMode:blendMode];
    
    [oParticleView rebuildParticleSystem];
}

- (IBAction)changedParticleBGColor1:(id)sender
{
    NSColor* color = [oParticleBGColorWell1 color];
    color = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    
    float r = [color redComponent];
    float g = [color greenComponent];
    float b = [color blueComponent];
    float a = [color alphaComponent];
    
    BXSingleParticleSpec* particleSpec = [self selectedSingleParticleSpec];
    [particleSpec setBGColor1:KRColor(r, g, b, a)];
}

- (IBAction)changedParticleMaxVX:(id)sender
{
    float maxVX = 0.0f;
    if (sender == oParticleMaxVXSlider) {
        maxVX = [oParticleMaxVXSlider floatValue];
    } else {
        maxVX = [oParticleMaxVXField floatValue];
    }
    
    BXSingleParticleSpec* particleSpec = [self selectedSingleParticleSpec];
    [particleSpec setMaxVX:maxVX];
    
    [self setupEditorUIForSingleParticle:particleSpec];
    [oParticleView rebuildParticleSystem];    
}

- (IBAction)changedParticleMaxVY:(id)sender
{
    float maxVY = 0.0f;
    if (sender == oParticleMaxVYSlider) {
        maxVY = [oParticleMaxVYSlider floatValue];
    } else {
        maxVY = [oParticleMaxVYField floatValue];
    }
    
    BXSingleParticleSpec* particleSpec = [self selectedSingleParticleSpec];
    [particleSpec setMaxVY:maxVY];
    
    [self setupEditorUIForSingleParticle:particleSpec];
    [oParticleView rebuildParticleSystem];    
}

- (IBAction)changedParticleDeltaScale:(id)sender
{
    float scale = 0.0f;
    if (sender == oParticleDeltaScaleSlider) {
        scale = [oParticleDeltaScaleSlider floatValue];
    } else {
        scale = [oParticleDeltaScaleField floatValue];
    }
    
    BXSingleParticleSpec* particleSpec = [self selectedSingleParticleSpec];
    [particleSpec setDeltaScale:scale];
    
    [self setupEditorUIForSingleParticle:particleSpec];
    [oParticleView rebuildParticleSystem];    
}

- (IBAction)changedParticleDeltaColor:(id)sender
{
    float deltaRed = 0.0f;
    float deltaGreen = 0.0f;
    float deltaBlue = 0.0f;
    float deltaAlpha = 0.0f;
    if (sender == oParticleDeltaRedSlider) {
        deltaRed = [oParticleDeltaRedSlider floatValue];
        deltaGreen = [oParticleDeltaGreenSlider floatValue];
        deltaBlue = [oParticleDeltaBlueSlider floatValue];
        deltaAlpha = [oParticleDeltaAlphaSlider floatValue];
    }
    else if (sender == oParticleDeltaRedField) {
        deltaRed = [oParticleDeltaRedField floatValue];
        deltaGreen = [oParticleDeltaGreenSlider floatValue];
        deltaBlue = [oParticleDeltaBlueSlider floatValue];
        deltaAlpha = [oParticleDeltaAlphaSlider floatValue];
    }
    else if (sender == oParticleDeltaGreenSlider) {
        deltaRed = [oParticleDeltaRedSlider floatValue];
        deltaGreen = [oParticleDeltaGreenSlider floatValue];
        deltaBlue = [oParticleDeltaBlueSlider floatValue];
        deltaAlpha = [oParticleDeltaAlphaSlider floatValue];
    }
    else if (sender == oParticleDeltaGreenField) {
        deltaRed = [oParticleDeltaRedSlider floatValue];
        deltaGreen = [oParticleDeltaGreenField floatValue];
        deltaBlue = [oParticleDeltaBlueSlider floatValue];
        deltaAlpha = [oParticleDeltaAlphaSlider floatValue];
    }
    else if (sender == oParticleDeltaBlueSlider) {
        deltaRed = [oParticleDeltaRedSlider floatValue];
        deltaGreen = [oParticleDeltaGreenSlider floatValue];
        deltaBlue = [oParticleDeltaBlueSlider floatValue];
        deltaAlpha = [oParticleDeltaAlphaSlider floatValue];
    }
    else if (sender == oParticleDeltaBlueField) {
        deltaRed = [oParticleDeltaRedSlider floatValue];
        deltaGreen = [oParticleDeltaGreenSlider floatValue];
        deltaBlue = [oParticleDeltaBlueField floatValue];
        deltaAlpha = [oParticleDeltaAlphaSlider floatValue];
    }
    else if (sender == oParticleDeltaAlphaSlider) {
        deltaRed = [oParticleDeltaRedSlider floatValue];
        deltaGreen = [oParticleDeltaGreenSlider floatValue];
        deltaBlue = [oParticleDeltaBlueSlider floatValue];
        deltaAlpha = [oParticleDeltaAlphaSlider floatValue];
    }
    else {
        deltaRed = [oParticleDeltaRedSlider floatValue];
        deltaGreen = [oParticleDeltaGreenSlider floatValue];
        deltaBlue = [oParticleDeltaBlueSlider floatValue];
        deltaAlpha = [oParticleDeltaAlphaField floatValue];
    }    

    BXSingleParticleSpec* particleSpec = [self selectedSingleParticleSpec];
    [particleSpec setDeltaRed:deltaRed];
    [particleSpec setDeltaGreen:deltaGreen];
    [particleSpec setDeltaBlue:deltaBlue];
    [particleSpec setDeltaAlpha:deltaAlpha];
    
    [self setupEditorUIForSingleParticle:particleSpec];
    [oParticleView rebuildParticleSystem];    
}

- (IBAction)changedParticleMinVX:(id)sender
{
    float minVX = 0.0f;
    if (sender == oParticleMinVXSlider) {
        minVX = [oParticleMinVXSlider floatValue];
    } else {
        minVX = [oParticleMinVXField floatValue];
    }
    
    BXSingleParticleSpec* particleSpec = [self selectedSingleParticleSpec];
    [particleSpec setMinVX:minVX];
    
    [self setupEditorUIForSingleParticle:particleSpec];
    [oParticleView rebuildParticleSystem];    
}

- (IBAction)changedParticleMinVY:(id)sender
{
    float minVY = 0.0f;
    if (sender == oParticleMinVYSlider) {
        minVY = [oParticleMinVYSlider floatValue];
    } else {
        minVY = [oParticleMinVYField floatValue];
    }
    
    BXSingleParticleSpec* particleSpec = [self selectedSingleParticleSpec];
    [particleSpec setMinVY:minVY];
    
    [self setupEditorUIForSingleParticle:particleSpec];
    [oParticleView rebuildParticleSystem];    
}

- (IBAction)changedParticleGenerateCount:(id)sender
{
    int count = 0;
    if (sender == oParticleGenerateCountSlider) {
        count = [oParticleGenerateCountSlider intValue];
    } else {
        count = [oParticleGenerateCountField intValue];
    }
    
    BXSingleParticleSpec* particleSpec = [self selectedSingleParticleSpec];
    [particleSpec setGenerateCount:count];
    
    [self setupEditorUIForSingleParticle:particleSpec];
    [oParticleView rebuildParticleSystem];
}

- (IBAction)changedParticleMaxCount:(id)sender
{
    int count = 0;
    if (sender == oParticleMaxParticleCountSlider) {
        count = [oParticleMaxParticleCountSlider intValue];
    } else {
        count = [oParticleMaxParticleCountField intValue];
    }
    
    BXSingleParticleSpec* particleSpec = [self selectedSingleParticleSpec];
    [particleSpec setMaxParticleCount:count];
    
    [self setupEditorUIForSingleParticle:particleSpec];
    [oParticleView rebuildParticleSystem];
}


#pragma mark -
#pragma mark シリアライゼーション

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.

    if (outError != NULL) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.
    
    if (outError != NULL) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
    return YES;
}


#pragma mark -
#pragma mark UIと内部データの同期

- (void)setupEditorUIForChara2D:(BXCharaSpec*)theSpec
{
    [oChara2DResourceIDField setIntValue:[theSpec resourceID]];
    [oChara2DResourceNameField setStringValue:[theSpec resourceName]];

    [oChara2DStateListView reloadData];

    [oChara2DStateListView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
}

- (void)setupEditorUIForSingleParticle:(BXSingleParticleSpec*)theSpec
{
    [oParticleResourceIDField setIntValue:[theSpec resourceID]];
    [oParticleResourceNameField setStringValue:[theSpec resourceName]];

    [oParticleGravityFieldX setFloatValue:[theSpec gravity].x];
    [oParticleGravitySliderX setFloatValue:[theSpec gravity].x];
    
    [oParticleGravityFieldY setFloatValue:[theSpec gravity].y];
    [oParticleGravitySliderY setFloatValue:[theSpec gravity].y];
    
    [oParticleLifeField setIntValue:[theSpec life]];
    [oParticleLifeSlider setIntValue:[theSpec life]];
    
    KRColor color = [theSpec color];
    [oParticleColorWell setColor:[NSColor colorWithCalibratedRed:color.r green:color.g blue:color.b alpha:color.a]];
    
    KRColor bgColor1 = [theSpec bgColor1];
    [oParticleBGColorWell1 setColor:[NSColor colorWithCalibratedRed:bgColor1.r green:bgColor1.g blue:bgColor1.b alpha:bgColor1.a]];

    [oParticleMinAngleVField setIntValue:[theSpec minAngleV]];
    [oParticleMinAngleVSlider setIntValue:[theSpec minAngleV]];
    [oParticleMaxAngleVField setIntValue:[theSpec maxAngleV]];
    [oParticleMaxAngleVSlider setIntValue:[theSpec maxAngleV]];
    
    [oParticleMaxParticleCountField setIntValue:[theSpec maxParticleCount]];
    [oParticleMaxParticleCountSlider setIntValue:[theSpec maxParticleCount]];

    [oParticleLoopButton setState:([theSpec doLoop]? NSOnState: NSOffState)];
    
    KRBlendMode blendMode = [theSpec blendMode];
    int blendModeTag = 0;
    if (blendMode == KRBlendModeAddition) {
        blendModeTag = 1;
    } else if (blendMode == KRBlendModeScreen) {
        blendModeTag = 2;
    }
    [oParticleBlendModeButton selectItemWithTag:blendModeTag];    

    [oParticleMaxVXField setFloatValue:[theSpec maxV].x];
    [oParticleMaxVXSlider setFloatValue:[theSpec maxV].x];
    [oParticleMaxVYField setFloatValue:[theSpec maxV].y];
    [oParticleMaxVYSlider setFloatValue:[theSpec maxV].y];

    [oParticleMinVXField setFloatValue:[theSpec minV].x];
    [oParticleMinVXSlider setFloatValue:[theSpec minV].x];
    [oParticleMinVYField setFloatValue:[theSpec minV].y];
    [oParticleMinVYSlider setFloatValue:[theSpec minV].y];
    
    [oParticleDeltaScaleField setFloatValue:[theSpec deltaScale]];
    [oParticleDeltaScaleSlider setFloatValue:[theSpec deltaScale]];

    [oParticleGenerateCountField setIntValue:[theSpec generateCount]];
    [oParticleGenerateCountSlider setIntValue:[theSpec generateCount]];

    double deltaRed = [theSpec deltaRed];
    double deltaGreen = [theSpec deltaGreen];
    double deltaBlue = [theSpec deltaBlue];
    double deltaAlpha = [theSpec deltaAlpha];

    [oParticleDeltaRedField setFloatValue:deltaRed];
    [oParticleDeltaRedSlider setFloatValue:deltaRed];
    [oParticleDeltaGreenField setFloatValue:deltaGreen];
    [oParticleDeltaGreenSlider setFloatValue:deltaGreen];
    [oParticleDeltaBlueField setFloatValue:deltaBlue];
    [oParticleDeltaBlueSlider setFloatValue:deltaBlue];
    [oParticleDeltaAlphaField setFloatValue:deltaAlpha];
    [oParticleDeltaAlphaSlider setFloatValue:deltaAlpha];
}


#pragma mark -
#pragma mark NSOutlineView DataSource

- (int)outlineView:(NSOutlineView*)outlineView numberOfChildrenOfItem:(id)item
{
    if (outlineView == oElementView) {
        // Root
        if (!item) {
            return [mRootElements count];
        }
        // Otherwise
        else {
            return [item childCount];
        }
    }
    else if (outlineView == oChara2DStateListView) {
        // Root
        if (!item) {
            BXCharaSpec* selectedSpec = [self selectedChara2DSpec];
            return [selectedSpec stateCount];
        }
    }
    
    return 0;
}

- (id)outlineView:(NSOutlineView*)outlineView child:(int)index ofItem:(id)item
{
    if (outlineView == oElementView) {
        // Root
        if (!item) {
            return [mRootElements objectAtIndex:index];
        }
        // Otherwise
        else {
            return [item childAtIndex:index];
        }
    }
    else if (outlineView == oChara2DStateListView) {
        BXCharaSpec* selectedSpec = [self selectedChara2DSpec];
        return [selectedSpec stateAtIndex:index];
    }
    
    return nil;
}

- (id)outlineView:(NSOutlineView*)outlineView objectValueForTableColumn:(NSTableColumn*)tableColumn byItem:(id)item
{
    if (outlineView == oElementView) {
        return [item localizedName];
    }
    else if (outlineView == oChara2DStateListView) {
        if ([[tableColumn identifier] isEqualToString:@"id"]) {
            return [NSString stringWithFormat:@"%d", [(BXChara2DState*)item stateID]];
        } else if ([[tableColumn identifier] isEqualToString:@"name"]) {
            return [(BXChara2DState*)item name];
        }
    }

    return @"????";
}

- (BOOL)outlineView:(NSOutlineView*)outlineView isItemExpandable:(id)item
{
    if (outlineView == oElementView) {
        return [item isExpandable];
    }
    
    return NO;
}

- (BOOL)outlineView:(NSOutlineView*)outlineView isGroupItem:(id)item
{
    if (outlineView == oElementView) {
        return [item isGroupItem];
    }
    
    return NO;
}


#pragma mark -
#pragma mark NSOutlineView Delegate

- (void)outlineViewSelectionDidChange:(NSNotification*)notification
{
    NSOutlineView* outlineView = [notification object];

    if (outlineView == oElementView) {
        int selectedRow = [oElementView selectedRow];
        if (selectedRow < 0) {
            [oEditorTabView selectTabViewItemWithIdentifier:@"no-selection"];
            return;
        }

        [oParticleView releaseParticles];
        
        BXResourceElement* theElem = [oElementView itemAtRow:selectedRow];
        
        // キャラクタの編集
        if ([theElem isKindOfClass:[BXCharaSpec class]]) {
            [oEditorTabView selectTabViewItemWithIdentifier:@"chara-editor"];
            BXCharaSpec* theCharaSpec = (BXCharaSpec*)theElem;

            [self setupEditorUIForChara2D:theCharaSpec];
        }
        // パーティクルの編集
        else if ([theElem isKindOfClass:[BXSingleParticleSpec class]]) {
            BXSingleParticleSpec* theParticleSpec = (BXSingleParticleSpec*)theElem;

            [self setupEditorUIForSingleParticle:theParticleSpec];

            [oParticleView setupForParticleSpec:theParticleSpec];
            [oEditorTabView selectTabViewItemWithIdentifier:@"particle-editor"];
        }
        // 選択なし
        else {
            [oEditorTabView selectTabViewItemWithIdentifier:@"no-selection"];
        }
    }
    else if (outlineView == oChara2DStateListView) {
        [self willChangeValueForKey:@"canRemoteChara2DState"];
        [self didChangeValueForKey:@"canRemoteChara2DState"];

        NSLog(@"State Changed");
    }
}

- (void)outlineView:(NSOutlineView*)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn*)tableColumn item:(BXResourceElement*)item
{
}

- (BOOL)outlineView:(NSOutlineView*)outlineView shouldEditTableColumn:(NSTableColumn*)tableColumn item:(BXResourceElement*)item
{
    return NO;
}


#pragma mark -
#pragma mark NSToolbar delegate

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
    return [NSArray arrayWithObjects:
            //sKADocumentToolbarItemAddBackground,
            sKADocumentToolbarItemAddCharacter,
            sKADocumentToolbarItemAddParticle,
            //sKADocumentToolbarItemAddBGM,
            //sKADocumentToolbarItemAddSE,
            //sKADocumentToolbarItemAddStage,
            nil];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
    return [NSArray arrayWithObjects:
            //sKADocumentToolbarItemAddBackground,
            sKADocumentToolbarItemAddCharacter,
            sKADocumentToolbarItemAddParticle,
            //sKADocumentToolbarItemAddBGM,
            //sKADocumentToolbarItemAddSE,
            //sKADocumentToolbarItemAddStage,
            nil];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
    NSToolbarItem* ret = [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier] autorelease];
    
    [ret setLabel:NSLocalizedString(itemIdentifier, nil)];
    [ret setPaletteLabel:NSLocalizedString(itemIdentifier, nil)];
    
    if ([itemIdentifier isEqualToString:sKADocumentToolbarItemAddBackground]) {
        [ret setTarget:self];
        [ret setAction:@selector(addBackground:)];
    }
    else if ([itemIdentifier isEqualToString:sKADocumentToolbarItemAddCharacter]) {
        [ret setTarget:self];
        [ret setAction:@selector(addCharacter:)];
    }
    else if ([itemIdentifier isEqualToString:sKADocumentToolbarItemAddParticle]) {
        [ret setTarget:self];
        [ret setAction:@selector(addParticle:)];
    }
    else if ([itemIdentifier isEqualToString:sKADocumentToolbarItemAddBGM]) {
        [ret setTarget:self];
        [ret setAction:@selector(addBGM:)];
    }
    else if ([itemIdentifier isEqualToString:sKADocumentToolbarItemAddSE]) {
        [ret setTarget:self];
        [ret setAction:@selector(addSE:)];
    }
    else if ([itemIdentifier isEqualToString:sKADocumentToolbarItemAddStage]) {
        [ret setTarget:self];
        [ret setAction:@selector(addStage:)];
    }
    
    return ret;
}


#pragma mark -
#pragma mark NSWindow delegate

- (void)windowDidBecomeMain:(NSNotification*)notification
{
    [oStatusBarBGView setNeedsDisplay:YES];
}

- (void)windowDidResignMain:(NSNotification*)notification
{
    [oStatusBarBGView setNeedsDisplay:YES];
}

- (void)windowWillClose:(NSNotification*)notification
{
    [oParticleView releaseParticles];
}

@end

