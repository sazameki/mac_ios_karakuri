//
//  BXDocument.m
//  Karakuri Box
//
//  Created by numata on 10/02/27.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BXDocument.h"
#import "BXResourceElement.h"
#import "BXCharaSpec.h"
#import "BXParticleSpec.h"


static NSString*    sKADocumentToolbarItemAddCharacter  = @"KADocumentToolbarItemAddCharacter";
static NSString*    sKADocumentToolbarItemAddParticle   = @"KADocumentToolbarItemAddParticle";
static NSString*    sKADocumentToolbarItemAddBGM        = @"KADocumentToolbarItemAddBGM";
static NSString*    sKADocumentToolbarItemAddSE         = @"KADocumentToolbarItemAddSE";


@interface BXDocument ()

- (BXSingleParticleSpec*)selectedSingleParticleSpec;
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
        
        mCharaGroup = [[[BXResourceGroup alloc] initWithName:@"*chara-group"] autorelease];
        mParticleGroup = [[[BXResourceGroup alloc] initWithName:@"*particle-group"] autorelease];
        mBGMGroup = [[[BXResourceGroup alloc] initWithName:@"*bgm-group"] autorelease];
        mSEGroup = [[[BXResourceGroup alloc] initWithName:@"*se-group"] autorelease];
        [mRootElements addObject:mCharaGroup];
        [mRootElements addObject:mParticleGroup];
        [mRootElements addObject:mBGMGroup];
        [mRootElements addObject:mSEGroup];
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

- (void)addCharacter:(id)sender
{
    BXCharaSpec* newCharaSpec = [[[BXCharaSpec alloc] initWithName:@"New Chara"] autorelease];
    [mCharaGroup addChild:newCharaSpec];
    
    [oElementView reloadData];
    [oElementView expandItem:mCharaGroup];

    int row = [oElementView rowForItem:newCharaSpec];
    [oElementView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
}

- (void)addParticle:(id)sender
{
    BXSingleParticleSpec* newParticleSpec = [[[BXSingleParticleSpec alloc] initWithName:@"New Particle"] autorelease];
    [mParticleGroup addChild:newParticleSpec];
    
    [oElementView reloadData];
    [oElementView expandItem:mParticleGroup];
    
    int row = [oElementView rowForItem:newParticleSpec];
    [oElementView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
}

- (void)addBGM:(id)sender
{
    // TODO: Implement addBGM:
}

- (void)addSE:(id)sender
{
    // TODO: Implement addSE:
}


#pragma mark -
#pragma mark パーティクルの設定アクション

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
    color = [color colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];

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
    color = [color colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];
    
    float r = [color redComponent];
    float g = [color greenComponent];
    float b = [color blueComponent];
    float a = [color alphaComponent];
    
    BXSingleParticleSpec* particleSpec = [self selectedSingleParticleSpec];
    [particleSpec setBGColor1:KRColor(r, g, b, a)];
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
#pragma mark ???

- (void)setupEditorUIForSingleParticle:(BXSingleParticleSpec*)theSpec
{
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
    
    [oParticleLoopButton setState:([theSpec doLoop]? NSOnState: NSOffState)];
    
    KRBlendMode blendMode = [theSpec blendMode];
    int blendModeTag = 0;
    if (blendMode == KRBlendModeAddition) {
        blendModeTag = 1;
    } else if (blendMode == KRBlendModeScreen) {
        blendModeTag = 2;
    }
    [oParticleBlendModeButton selectItemWithTag:blendModeTag];    
}


#pragma mark -
#pragma mark NSOutlineView DataSource

- (int)outlineView:(NSOutlineView*)outlineView numberOfChildrenOfItem:(BXResourceElement*)item
{
    // Root
    if (!item) {
        return [mRootElements count];
    }
    // Otherwise
    else {
        return [item childCount];
    }
}

- (id)outlineView:(NSOutlineView*)outlineView child:(int)index ofItem:(BXResourceElement*)item
{
    // Root
    if (!item) {
        return [mRootElements objectAtIndex:index];
    }
    // Otherwise
    else {
        return [item childAtIndex:index];
    }
}

- (id)outlineView:(NSOutlineView*)outlineView objectValueForTableColumn:(NSTableColumn*)tableColumn byItem:(BXResourceElement*)item
{
    return [item localizedName];
}

- (BOOL)outlineView:(NSOutlineView*)outlineView isItemExpandable:(BXResourceElement*)item
{
    return [item isExpandable];
}

- (BOOL)outlineView:(NSOutlineView*)outlineView isGroupItem:(BXResourceElement*)item
{
    return [item isGroupItem];
}


#pragma mark -
#pragma mark NSOutlineView Delegate

- (void)outlineViewSelectionDidChange:(NSNotification*)notification
{
    int selectedRow = [oElementView selectedRow];
    if (selectedRow < 0) {
        [oEditorTabView selectTabViewItemWithIdentifier:@"no-selection"];
        return;
    }

    [oParticleView releaseParticles];
    
    BXResourceElement* theElem = [oElementView itemAtRow:selectedRow];
    if ([theElem isKindOfClass:[BXCharaSpec class]]) {
        [oEditorTabView selectTabViewItemWithIdentifier:@"chara-editor"];
    } else if ([theElem isKindOfClass:[BXSingleParticleSpec class]]) {
        BXSingleParticleSpec* theParticleSpec = (BXSingleParticleSpec*)theElem;

        [self setupEditorUIForSingleParticle:theParticleSpec];


        [oParticleView setupForParticleSpec:theParticleSpec];
        [oEditorTabView selectTabViewItemWithIdentifier:@"particle-editor"];
    } else {
        [oEditorTabView selectTabViewItemWithIdentifier:@"no-selection"];
    }
}

- (void)outlineView:(NSOutlineView*)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn*)tableColumn item:(BXResourceElement*)item
{
}


#pragma mark -
#pragma mark NSToolbar delegate

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
    return [NSArray arrayWithObjects:
            sKADocumentToolbarItemAddCharacter,
            sKADocumentToolbarItemAddParticle,
            sKADocumentToolbarItemAddBGM,
            sKADocumentToolbarItemAddSE,
            nil];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
    return [NSArray arrayWithObjects:
            sKADocumentToolbarItemAddCharacter,
            sKADocumentToolbarItemAddParticle,
            sKADocumentToolbarItemAddBGM,
            sKADocumentToolbarItemAddSE,
            nil];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
    NSToolbarItem* ret = [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier] autorelease];
    
    [ret setLabel:NSLocalizedString(itemIdentifier, nil)];
    [ret setPaletteLabel:NSLocalizedString(itemIdentifier, nil)];
    
    if ([itemIdentifier isEqualToString:sKADocumentToolbarItemAddCharacter]) {
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
    
    return ret;
}


#pragma mark -
#pragma mark NSWindow delegate

- (void)windowDidBecomeMain:(NSNotification *)notification
{
    [oStatusBarBGView setNeedsDisplay:YES];
}

- (void)windowDidResignMain:(NSNotification *)notification
{
    [oStatusBarBGView setNeedsDisplay:YES];
}

@end

