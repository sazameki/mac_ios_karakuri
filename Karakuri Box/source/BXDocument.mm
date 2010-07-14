//
//  BXDocument.m
//  Karakuri Box
//
//  Created by numata on 10/02/27.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BXDocument.h"

#import "BXBackgroundSpec.h"
#import "BXChara2DSpec.h"
#import "BXParticle2DSpec.h"
#import "BXBGMResource.h"
#import "BXSEResource.h"
#import "BXStageSpec.h"
#import "NSFileHandle+BXExport.h"


static NSString*    sKADocumentToolbarItemAddBackground = @"KADocumentToolbarItemAddBackground";
static NSString*    sKADocumentToolbarItemAddChara2D    = @"KADocumentToolbarItemAddChara2D";
static NSString*    sKADocumentToolbarItemAddParticle2D = @"KADocumentToolbarItemAddParticle2D";
static NSString*    sKADocumentToolbarItemAddBGM        = @"KADocumentToolbarItemAddBGM";
static NSString*    sKADocumentToolbarItemAddSE         = @"KADocumentToolbarItemAddSE";
static NSString*    sKADocumentToolbarItemAddStage      = @"KADocumentToolbarItemAddStage";


@interface BXDocument ()

// すべてに共通のメソッド

- (void)exportAllResourcesToFileHandle:(NSFileHandle*)fileHandle;
- (void)exportSelectedResourceToFileHandle:(NSFileHandle*)fileHandle;
- (BXResourceElement*)selectedResourceElement;

// 2Dキャラクタ関係

- (void)addChara2DImageFiles:(NSArray*)filepaths;
- (void)setupChara2DHitButtons;
- (void)setupEditorUIForChara2D:(BXChara2DSpec*)theSpec;
- (void)setupEditorForChara2DImage:(BXChara2DImage*)theImage;
- (void)setupEditorForChara2DState:(BXChara2DState*)theState;
- (void)updateChara2DAtlasList;
- (void)updateChara2DAtlasListSize;
- (void)updateChara2DStateCancelKomaButtonMenu;

// 2Dパーティクル関係

- (BXSingleParticle2DSpec*)selectedSingleParticle2DSpec;
- (void)setupEditorUIForSingleParticle2D:(BXSingleParticle2DSpec*)theSpec;

@end


@implementation BXDocument

#pragma mark -
#pragma mark 基本設定

- (NSString*)windowNibName { return @"BXDocument"; }


#pragma mark -
#pragma mark 初期化・クリーンアップ

- (id)init
{
    self = [super init];
    if (self) {
        mRootElements = [[NSMutableArray array] retain];
        
        mBackgroundGroup = [[[BXResourceGroup alloc] initWithName:@"*bg-group"] autorelease];
        [mBackgroundGroup setDocument:self];

        mChara2DGroup = [[[BXResourceGroup alloc] initWithName:@"*chara2d-group"] autorelease];
        [mChara2DGroup setDocument:self];
        
        mParticle2DGroup = [[[BXResourceGroup alloc] initWithName:@"*particle2d-group"] autorelease];
        [mParticle2DGroup setDocument:self];

        mBGMGroup = [[[BXResourceGroup alloc] initWithName:@"*bgm-group"] autorelease];
        [mBGMGroup setDocument:self];

        mSEGroup = [[[BXResourceGroup alloc] initWithName:@"*se-group"] autorelease];
        [mSEGroup setDocument:self];

        mStageGroup = [[[BXResourceGroup alloc] initWithName:@"*stage-group"] autorelease];
        [mStageGroup setDocument:self];

        //[mRootElements addObject:mBackgroundGroup];
        [mRootElements addObject:mChara2DGroup];
        [mRootElements addObject:mParticle2DGroup];
        //[mRootElements addObject:mBGMGroup];
        //[mRootElements addObject:mSEGroup];
        //[mRootElements addObject:mStageGroup];
        
        mFileManager = [[BXResourceFileManager alloc] initWithDocument:self];
    }
    return self;
}

- (void)loadResourceInfos
{
    NSFileWrapper* contentsWrapper = [[mRootWrapper fileWrappers] objectForKey:@"Contents"];
    NSFileWrapper* resourcesWrapper = [[contentsWrapper fileWrappers] objectForKey:@"Resources"];
    
    if (resourcesWrapper) {
        NSFileWrapper* resouceMapWrapper = [[resourcesWrapper fileWrappers] objectForKey:@"ResourceMap.plist"];
        if (resouceMapWrapper) {
            NSData* resourceMapData = [resouceMapWrapper regularFileContents];
            [mFileManager restoreResourceMapData:resourceMapData];
        }
    }
    
    if (contentsWrapper) {
        NSFileWrapper* chara2DInfosWrapper = [[contentsWrapper fileWrappers] objectForKey:@"Chara2DInfos.plist"];
        if (chara2DInfosWrapper) {
            [mChara2DGroup readChara2DInfosData:[chara2DInfosWrapper regularFileContents] document:self];
        }

        NSFileWrapper* particle2DInfosWrapper = [[contentsWrapper fileWrappers] objectForKey:@"Particle2DInfos.plist"];
        if (particle2DInfosWrapper) {
            [mParticle2DGroup readParticle2DInfosData:[particle2DInfosWrapper regularFileContents] document:self];
        }
    }
    
    [oElementView reloadData];
    if ([mChara2DGroup childCount] > 0) {
        [oElementView expandItem:mChara2DGroup];
    }
    if ([mParticle2DGroup childCount] > 0) {
        [oElementView expandItem:mParticle2DGroup];
    }
}

- (void)windowControllerDidLoadNib:(NSWindowController*) aController
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
    
    // 2Dキャラクタ設定関係のセットアップ
    [oChara2DKomaListView registerForDraggedTypes:[NSArray arrayWithObjects:gChara2DImageAtlasDraggingPboardType, gChara2DKomaDraggingPboardType, nil]];
    [oChara2DKomaListView setDraggingSourceOperationMask:(NSDragOperationMove | NSDragOperationCopy) forLocal:YES];
    [oChara2DKomaListView setVerticalMotionCanBeginDrag:YES];
    
    NSScrollView* chara2DImageAtlasScrollView = (NSScrollView*)[[oChara2DImageAtlasView superview] superview];
    NSClipView* chara2DImageAtlasClipView = [chara2DImageAtlasScrollView contentView];
    [chara2DImageAtlasClipView setBackgroundColor:[NSColor darkGrayColor]];
    [chara2DImageAtlasClipView setNeedsDisplay:YES];
    
    [self setupEditorForChara2DState:nil];
    [self setupChara2DHitButtons];
    
    // データの読み込み
    [self loadResourceInfos];
    
    // 最後に読み込んだファイルの更新
    [[NSUserDefaults standardUserDefaults] setObject:[self fileName] forKey:@"lastOpenedFilePath"];
}

- (void)dealloc
{
    [mRootWrapper release];
    
    [mRootElements release];
    [mFileManager release];

    [super dealloc];
}


#pragma mark -
#pragma mark アクセッサ

- (BXResourceFileManager*)fileManager
{
    return mFileManager;
}

- (NSFileWrapper*)rootWrapper
{
    return mRootWrapper;
}

- (NSFileWrapper*)contentsWrapper
{
    NSFileWrapper* rootWrapper = [self rootWrapper];
    NSFileWrapper* contentsWrapper = [[rootWrapper fileWrappers] objectForKey:@"Contents"];
    return contentsWrapper;
}

- (NSFileWrapper*)resourcesWrapper
{
    NSFileWrapper* contentsWrapper = [self contentsWrapper];
    NSFileWrapper* resourcesWrapper = [[contentsWrapper fileWrappers] objectForKey:@"Resources"];
    if (!resourcesWrapper) {
        resourcesWrapper = [[[NSFileWrapper alloc] initDirectoryWithFileWrappers:nil] autorelease];
        [resourcesWrapper setPreferredFilename:@"Resources"];
        
        NSDictionary* resourceMapDict = [NSDictionary dictionary];
        NSData* resourceMapData = [NSPropertyListSerialization dataFromPropertyList:resourceMapDict format:NSPropertyListBinaryFormat_v1_0 errorDescription:nil];
        [resourcesWrapper addRegularFileWithContents:resourceMapData preferredFilename:@"ResourceMap.plist"];

        [contentsWrapper addFileWrapper:resourcesWrapper];
    }
    return resourcesWrapper;
}

- (BXResourceElement*)selectedResourceElement
{
    int selectedRow = [oElementView selectedRow];
    if (selectedRow < 0) {
        return nil;
    }
    
    return [oElementView itemAtRow:selectedRow];
}

- (BXChara2DSpec*)selectedChara2DSpec
{
    BXResourceElement* selectedElem = [self selectedResourceElement];

    if ([selectedElem isKindOfClass:[BXChara2DSpec class]]) {
        return (BXChara2DSpec*)selectedElem;
    }
    return nil;
}

- (BXChara2DState*)selectedChara2DState
{
    int selectedRow = [oChara2DStateListView selectedRow];
    if (selectedRow < 0) {
        return nil;
    }
    
    BXChara2DSpec* selectedSpec = [self selectedChara2DSpec];
    return [selectedSpec stateAtIndex:selectedRow];
}

- (BXChara2DImage*)selectedChara2DImage
{
    int selectedRow = [oChara2DImageListView selectedRow];
    if (selectedRow < 0) {
        return nil;
    }

    BXChara2DSpec* selectedSpec = [self selectedChara2DSpec];
    return [selectedSpec imageAtIndex:selectedRow];
}

- (BXChara2DKoma*)selectedChara2DKoma
{
    int selectedRow = [oChara2DKomaListView selectedRow];
    if (selectedRow < 0) {
        return nil;
    }

    BXChara2DState* selectedState = [self selectedChara2DState];
    return [selectedState komaAtIndex:selectedRow];
}

- (BXSingleParticle2DSpec*)selectedSingleParticle2DSpec;
{
    BXResourceElement* selectedElem = [self selectedResourceElement];

    if ([selectedElem isKindOfClass:[BXSingleParticle2DSpec class]]) {
        return (BXSingleParticle2DSpec*)selectedElem;
    }
    return nil;
}

- (BXResourceGroup*)chara2DGroup
{
    return mChara2DGroup;
}

- (BXResourceGroup*)particle2DGroup
{
    return mParticle2DGroup;
}


#pragma mark -
#pragma mark アクション

- (void)addBackground:(id)sender
{
    BXBackgroundSpec* newBGSpec = [[[BXBackgroundSpec alloc] initWithName:@"New BG"] autorelease];
    [mBackgroundGroup addChild:newBGSpec];
    
    [oElementView reloadData];
    [oElementView expandItem:mBackgroundGroup];
    
    int row = [oElementView rowForItem:newBGSpec];
    [oElementView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
}

- (void)addChara2D:(id)sender
{
    BXChara2DSpec* newCharaSpec = [[[BXChara2DSpec alloc] initWithName:@"New Chara" defaultState:YES] autorelease];

    if ([mChara2DGroup childCount] > 0) {
        int lastID = [[mChara2DGroup childAtIndex:[mChara2DGroup childCount]-1] resourceID];
        [newCharaSpec setResourceID:lastID+1];
    } else {
        [newCharaSpec setResourceID:1000];
    }
    
    [mChara2DGroup addChild:newCharaSpec];
    
    [oElementView reloadData];
    [oElementView expandItem:mChara2DGroup];    

    int row = [oElementView rowForItem:newCharaSpec];
    [oElementView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
    
    [self updateChangeCount:NSChangeUndone];
}

- (void)addParticle2D:(id)sender
{
    BXSingleParticle2DSpec* newParticleSpec = [[[BXSingleParticle2DSpec alloc] initWithName:@"New Particle"] autorelease];
    
    if ([mParticle2DGroup childCount] > 0) {
        int lastID = [[mParticle2DGroup childAtIndex:[mParticle2DGroup childCount]-1] resourceID];
        [newParticleSpec setResourceID:lastID+1];
    } else {
        [newParticleSpec setResourceID:1000];
    }
    
    [mParticle2DGroup addChild:newParticleSpec];
    
    [oElementView reloadData];
    [oElementView expandItem:mParticle2DGroup];
    
    int row = [oElementView rowForItem:newParticleSpec];
    [oElementView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];

    [self updateChangeCount:NSChangeUndone];
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

/*- (void)exportAllResources:(id)sender
{
    NSSavePanel* savePanel = [NSSavePanel savePanel];
    
    [savePanel setAllowedFileTypes:[NSArray arrayWithObject:@"krrs"]];
    [savePanel setAccessoryView:oExportAccessoryView];
    [oExportOptionMatrix selectCellAtRow:0 column:0];
    
    [savePanel beginSheetForDirectory:nil
                                 file:@"resource.krrs"
                       modalForWindow:oMainWindow
                        modalDelegate:self
                       didEndSelector:@selector(exportPanelDidEnd:returnCode:contextInfo:)
                          contextInfo:nil];
}*/

- (void)exportSelectedResource:(id)sender
{
    BXResourceElement* theElement = nil;

    if (!theElement) {
        BXChara2DSpec* theSpec = [self selectedChara2DSpec];
        if (theSpec) {
            theElement = theSpec;
        }
    }

    if (!theElement) {
        BXSingleParticle2DSpec* theSpec = [self selectedSingleParticle2DSpec];
        if (theSpec) {
            theElement = theSpec;
        }
    }

    NSSavePanel* savePanel = [NSSavePanel savePanel];
    
    [savePanel setAllowedFileTypes:[NSArray arrayWithObject:@"krrs"]];
    [savePanel setAccessoryView:oExportAccessoryView];
    [oExportOptionMatrix selectCellAtRow:1 column:0];
    
    [savePanel beginSheetForDirectory:nil
                                 file:[NSString stringWithFormat:@"%@.krrs", [theElement resourceName]]
                       modalForWindow:oMainWindow
                        modalDelegate:self
                       didEndSelector:@selector(exportPanelDidEnd:returnCode:contextInfo:)
                          contextInfo:nil];
}

- (void)exportPanelDidEnd:(NSSavePanel*)sheet
               returnCode:(int)returnCode
              contextInfo:(void*)contextInfo
{
    if (returnCode == NSOKButton) {
        NSString* filepath = [sheet filename];
        
        // 空データの書き出し
        [[NSData data] writeToFile:filepath atomically:NO];

        NSFileHandle* fileHandle = [NSFileHandle fileHandleForWritingAtPath:filepath];
        
        // すべてのリソースを書き出し
        if ([oExportOptionMatrix selectedRow] == 0) {
            [self exportAllResourcesToFileHandle:fileHandle];
        }
        // 選択中のリソースを書き出し
        else {
            [self exportSelectedResourceToFileHandle:fileHandle];
        }
        
        [fileHandle synchronizeFile];
        [fileHandle closeFile];
    }
}


#pragma mark -
#pragma mark リソースの書き出し

- (void)exportResourceHeaderToFileHandle:(NSFileHandle*)fileHandle
{
    int majorVersion = 1;
    int minorVersion = 0;
    
    // MAGIC
    [fileHandle writeBuffer:"KRRS" length:4];
    
    // メジャーバージョン番号
    [fileHandle writeUnsignedIntValue:majorVersion];
    
    // マイナーバージョン番号
    [fileHandle writeUnsignedIntValue:minorVersion];
}

- (void)exportResourceFooterToFileHandle:(NSFileHandle*)fileHandle
{
    [fileHandle writeBuffer:"KRED" length:4];
}

/**
 * すべてのリソースを書き出します。
 */
- (void)exportAllResourcesToFileHandle:(NSFileHandle*)fileHandle
{
    // ヘッダの書き出し
    [self exportResourceHeaderToFileHandle:fileHandle];

    // リソースの書き出し
    [mChara2DGroup exportToFileHandle:fileHandle];
    [mParticle2DGroup exportToFileHandle:fileHandle];

    // フッタの書き出し
    [self exportResourceFooterToFileHandle:fileHandle];
}

/**
 * 選択されたリソースを書き出します。
 */
- (void)exportSelectedResourceToFileHandle:(NSFileHandle*)fileHandle
{
    // ヘッダの書き出し
    [self exportResourceHeaderToFileHandle:fileHandle];
    
    // リソースの書き出し
    BXResourceElement* selectedElement = [self selectedResourceElement];
    [selectedElement exportToFileHandle:fileHandle];

    // フッタの書き出し
    [self exportResourceFooterToFileHandle:fileHandle];
}

- (void)updateExportedResources:(id)sender
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    NSString* selfPath = [[self fileURL] path];
    NSString* filepath = [[selfPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"resource.krrs"];

    // 空データの書き出し
    [[NSData data] writeToFile:filepath atomically:NO];

    // すべてのリソースを書き出し
    NSFileHandle* fileHandle = [NSFileHandle fileHandleForWritingAtPath:filepath];
    [self exportAllResourcesToFileHandle:fileHandle];

    // 完了処理
    [fileHandle synchronizeFile];
    [fileHandle closeFile];
    
    NSString* resourceDirPath = [selfPath stringByDeletingLastPathComponent];
    if (![[resourceDirPath lastPathComponent] isEqualToString:@"resource"]) {
        NSLog(@"Skipped Resource ID Exportation (1)");
        return;
    }
    
    NSString* sourceDirPath = [[resourceDirPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"source"];
    if (![fileManager fileExistsAtPath:sourceDirPath]) {
        NSLog(@"Skipped Resource ID Exportation (2)");
        return;
    }
    
    NSString* resourceIDHeaderFilePath = [sourceDirPath stringByAppendingPathComponent:@"GameResourceID.h"];
    
    NSMutableString* headerContent = [[NSMutableString alloc] initWithFormat:@"// Karakuri Box Exported Resource IDs (%@)\n\n", [NSDate date]];

    [headerContent appendString:@"// 2D Character IDs\n"];
    [headerContent appendString:@"struct CharaID {\n    enum {\n"];
    [mChara2DGroup exportIDsToString:headerContent];
    [headerContent appendString:@"    };\n};\n\n"];

    [headerContent appendString:@"// 2D Particle IDs\n"];
    [headerContent appendString:@"struct ParticleID {\n    enum {\n"];
    [mParticle2DGroup exportIDsToString:headerContent];
    [headerContent appendString:@"    };\n};\n\n"];
    
    [headerContent appendString:@"\n\n\n"];
    
    if (![headerContent writeToFile:resourceIDHeaderFilePath atomically:NO encoding:NSUTF8StringEncoding error:NULL]) {
        NSLog(@"Failed to export resource IDs...");
    }
}


#pragma mark -
#pragma mark 2Dキャラクタの設定アクション

- (IBAction)changedChara2DGroupID:(id)sender
{
    BXChara2DSpec* charaSpec = [self selectedChara2DSpec];
    if (!charaSpec) {
        return;
    }
    
    int theID = [oChara2DGroupIDField intValue];
    [charaSpec setGroupID:theID];
    
    [self updateChangeCount:NSChangeUndone];
}

- (IBAction)addChara2DImage:(id)sender
{
    BXChara2DState* charaState = [self selectedChara2DState];
    if (!charaState) {
        return;
    }
    
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setAllowsMultipleSelection:YES];
    [openPanel beginSheetForDirectory:nil
                                 file:nil
                                types:[NSImage imageFileTypes]
                       modalForWindow:oMainWindow
                        modalDelegate:self
                       didEndSelector:@selector(chara2DImageSheetDidEnd:returnCode:context:)
                          contextInfo:nil];
}

- (void)chara2DImageSheetDidEnd:(NSOpenPanel*)panel
                     returnCode:(int)returnCode
                        context:(void*)context
{
    if (returnCode == NSOKButton) {
        NSArray* filenames = [panel filenames];
        [self addChara2DImageFiles:filenames];
    }
}

- (IBAction)addChara2DState:(id)sender
{
    BXChara2DSpec* charaSpec = [self selectedChara2DSpec];
    if (!charaSpec) {
        return;
    }
    
    int stateCount = [charaSpec stateCount];
    BXChara2DState* lastState = [charaSpec stateAtIndex:stateCount-1];
    int nextID = [lastState stateID] + 1;
    
    BXChara2DState* newState = [charaSpec addNewState];
    [newState setStateID:nextID];
    
    [oChara2DStateListView reloadData];
    
    int theRow = [oChara2DStateListView rowForItem:newState];
    [oChara2DStateListView scrollRowToVisible:theRow];
    [oChara2DStateListView selectRowIndexes:[NSIndexSet indexSetWithIndex:theRow] byExtendingSelection:NO];

    [self updateChangeCount:NSChangeUndone];
}

- (IBAction)changedChara2DImageDivX:(id)sender
{
    BXChara2DImage* theImage = [self selectedChara2DImage];
    if (!theImage) {
        return;
    }
    
    [theImage setDivX:[oChara2DImageDivXField intValue]];
    
    [self updateChara2DAtlasList];

    [self updateChangeCount:NSChangeUndone];
}

- (IBAction)changedChara2DImageDivY:(id)sender
{
    BXChara2DImage* theImage = [self selectedChara2DImage];
    if (!theImage) {
        return;
    }
    
    [theImage setDivY:[oChara2DImageDivYField intValue]];

    [self updateChara2DAtlasList];

    [self updateChangeCount:NSChangeUndone];
}

- (IBAction)changedChara2DResourceID:(id)sender
{
    int theID = [oChara2DResourceIDField intValue];
    
    BXChara2DSpec* charaSpec = [self selectedChara2DSpec];
    [charaSpec setResourceID:theID];
    
    [oElementView reloadData];
    
    int theRow = [oElementView rowForItem:charaSpec];
    [oElementView selectRowIndexes:[NSIndexSet indexSetWithIndex:theRow] byExtendingSelection:NO];

    [self updateChangeCount:NSChangeUndone];
}

- (IBAction)changedChara2DResourceName:(id)sender
{
    NSString* theName = [oChara2DResourceNameField stringValue];
    
    BXChara2DSpec* charaSpec = [self selectedChara2DSpec];
    [charaSpec setResourceName:theName];
    
    [oElementView reloadData];

    [self updateChangeCount:NSChangeUndone];
}

- (IBAction)changedChara2DStateNextState:(id)sender
{
    BXChara2DState* selectedState = [self selectedChara2DState];
    if (!selectedState) {
        NSBeep();
        return;
    }
    
    int nextStateID = [oChara2DStateNextStateButton selectedTag];
    [selectedState setNextStateID:nextStateID];

    [self updateChangeCount:NSChangeUndone];
}

- (IBAction)removeChara2DState:(id)sender
{
    BXChara2DState* charaState = [self selectedChara2DState];
    if (!charaState) {
        return;
    }

    [self willChangeValueForKey:@"canRemoteChara2DState"];

    BXChara2DSpec* charaSpec = [self selectedChara2DSpec];
    [charaSpec removeState:charaState];
    
    [oChara2DStateListView reloadData];
    
    [self didChangeValueForKey:@"canRemoteChara2DState"];

    [self updateChangeCount:NSChangeUndone];
}

- (IBAction)changedChara2DKomaDefaultInterval:(id)sender
{
    BXChara2DState* charaState = [self selectedChara2DState];
    if (!charaState) {
        NSBeep();
        return;
    }
    
    int theInterval = [oChara2DKomaDefaultIntervalButton selectedTag];
    [charaState setDefaultKomaInterval:theInterval];

    [self updateChangeCount:NSChangeUndone];
}

- (IBAction)changedChara2DKomaPreviewScale:(id)sender
{
    BXChara2DSpec* selectedSpec = [self selectedChara2DSpec];
    if (!selectedSpec) {
        NSBeep();
        return;
    }
    
    int scaleInt = [oChara2DKomaPreviewScaleButton selectedTag];
    double theScale = (double)scaleInt / 100;
    [selectedSpec setKomaPreviewScale:theScale];
    
    [oChara2DKomaPreviewView updateViewSize];
    [oChara2DKomaPreviewView setNeedsDisplay:YES];

    [self updateChangeCount:NSChangeUndone];
}

- (IBAction)startChara2DSimulator:(id)sender
{
    [oChara2DSimulatorView setupForChara2DSpec:[self selectedChara2DSpec]];
    [NSApp beginSheet:oChara2DSimulatorPanel
       modalForWindow:oMainWindow
        modalDelegate:self
       didEndSelector:nil
          contextInfo:nil];
}

- (IBAction)stopChara2DSimulator:(id)sender
{
    [oChara2DSimulatorView stopAnimation:self];
    [oChara2DSimulatorView saveAnimationSettings];
    [oChara2DSimulatorPanel orderOut:self];
    [NSApp endSheet:oChara2DSimulatorPanel returnCode:NSCancelButton];

    [self updateChangeCount:NSChangeUndone];
}

- (IBAction)startChara2DKomaPreviewAnimation:(id)sender
{
    [oMainWindow makeFirstResponder:oChara2DKomaPreviewView];
}

- (IBAction)changedChara2DShowsHitInfos:(id)sender
{
    BXChara2DKoma* theKoma = [self selectedChara2DKoma];
    if (!theKoma) {
        return;
    }

    [theKoma setShowsHitInfos:![theKoma showsHitInfos]];
    if (![theKoma showsHitInfos]) {
        [oChara2DKomaPreviewView deselectHitInfo];
    } else {
        [oChara2DKomaPreviewView setNeedsDisplay:YES];
    }
    
    [self setupChara2DHitButtons];
}

- (IBAction)activateChara2DHitButton1:(id)sender
{
    BXChara2DKoma* theKoma = [self selectedChara2DKoma];
    if (!theKoma) {
        return;
    }
    
    [theKoma setCurrentHitGroupIndex:1];
    
    [self setupChara2DHitButtons];
    [oChara2DKomaPreviewView deselectHitInfo];
}

- (IBAction)activateChara2DHitButton2:(id)sender
{
    BXChara2DKoma* theKoma = [self selectedChara2DKoma];
    if (!theKoma) {
        return;
    }
    
    [theKoma setCurrentHitGroupIndex:2];
    
    [self setupChara2DHitButtons];
    [oChara2DKomaPreviewView deselectHitInfo];
}

- (IBAction)activateChara2DHitButton3:(id)sender
{
    BXChara2DKoma* theKoma = [self selectedChara2DKoma];
    if (!theKoma) {
        return;
    }
    
    [theKoma setCurrentHitGroupIndex:3];
    
    [self setupChara2DHitButtons];
    [oChara2DKomaPreviewView deselectHitInfo];
}

- (IBAction)activateChara2DHitButton4:(id)sender
{
    BXChara2DKoma* theKoma = [self selectedChara2DKoma];
    if (!theKoma) {
        return;
    }
    
    [theKoma setCurrentHitGroupIndex:4];
    
    [self setupChara2DHitButtons];
    [oChara2DKomaPreviewView deselectHitInfo];
}

- (IBAction)activateChara2DHitButton5:(id)sender
{
    BXChara2DKoma* theKoma = [self selectedChara2DKoma];
    if (!theKoma) {
        return;
    }
    
    [theKoma setCurrentHitGroupIndex:5];
    
    [self setupChara2DHitButtons];
    [oChara2DKomaPreviewView deselectHitInfo];
}

- (IBAction)activateChara2DHitButton6:(id)sender
{
    BXChara2DKoma* theKoma = [self selectedChara2DKoma];
    if (!theKoma) {
        return;
    }
    
    [theKoma setCurrentHitGroupIndex:6];
    
    [self setupChara2DHitButtons];
    [oChara2DKomaPreviewView deselectHitInfo];
}

- (IBAction)activateChara2DHitButton7:(id)sender
{
    BXChara2DKoma* theKoma = [self selectedChara2DKoma];
    if (!theKoma) {
        return;
    }
    
    [theKoma setCurrentHitGroupIndex:7];
    
    [self setupChara2DHitButtons];
    [oChara2DKomaPreviewView deselectHitInfo];
}

- (IBAction)activateChara2DHitButton8:(id)sender
{
    BXChara2DKoma* theKoma = [self selectedChara2DKoma];
    if (!theKoma) {
        return;
    }
    
    [theKoma setCurrentHitGroupIndex:8];
    
    [self setupChara2DHitButtons];
    [oChara2DKomaPreviewView deselectHitInfo];
}

- (IBAction)activateChara2DHitButton9:(id)sender
{
    BXChara2DKoma* theKoma = [self selectedChara2DKoma];
    if (!theKoma) {
        return;
    }
    
    [theKoma setCurrentHitGroupIndex:9];
    
    [self setupChara2DHitButtons];
    [oChara2DKomaPreviewView deselectHitInfo];
}

- (IBAction)activateChara2DHitButton10:(id)sender
{
    BXChara2DKoma* theKoma = [self selectedChara2DKoma];
    if (!theKoma) {
        return;
    }
    
    [theKoma setCurrentHitGroupIndex:10];
    
    [self setupChara2DHitButtons];
    [oChara2DKomaPreviewView deselectHitInfo];
}

- (IBAction)activateChara2DHitButton11:(id)sender
{
    BXChara2DKoma* theKoma = [self selectedChara2DKoma];
    if (!theKoma) {
        return;
    }
    
    [theKoma setCurrentHitGroupIndex:11];
    
    [self setupChara2DHitButtons];
    [oChara2DKomaPreviewView deselectHitInfo];
}

- (IBAction)activateChara2DHitButton12:(id)sender
{
    BXChara2DKoma* theKoma = [self selectedChara2DKoma];
    if (!theKoma) {
        return;
    }
    
    [theKoma setCurrentHitGroupIndex:12];
    
    [self setupChara2DHitButtons];
    [oChara2DKomaPreviewView deselectHitInfo];
}

- (IBAction)addChara2DHitInfoOval:(id)sender
{
    BXChara2DKoma* theKoma = [self selectedChara2DKoma];
    if (!theKoma) {
        return;
    }
    
    BXChara2DKomaHitInfo* theInfo = [theKoma addHitInfoOval];

    [oChara2DKomaPreviewView selectHitInfo:theInfo];
    [self setupChara2DHitButtons];

    [self updateChangeCount:NSChangeUndone];
}

- (IBAction)addChara2DHitInfoRect:(id)sender
{
    BXChara2DKoma* theKoma = [self selectedChara2DKoma];
    if (!theKoma) {
        return;
    }
    
    BXChara2DKomaHitInfo* theInfo = [theKoma addHitInfoRect];
    
    [oChara2DKomaPreviewView selectHitInfo:theInfo];
    [self setupChara2DHitButtons];

    [self updateChangeCount:NSChangeUndone];
}

- (IBAction)removeSelectedChara2D:(id)sender
{
    BXChara2DSpec* theSpec = [self selectedChara2DSpec];
    if (!theSpec) {
        NSBeep();
        return;
    }
    
    int ret = NSRunInformationalAlertPanel(@"リソースの削除",
                                           [NSString stringWithFormat:@"Chara2D「%d: %@」を削除してもよろしいですか？", [theSpec resourceID], [theSpec resourceName]],
                                           @"OK",
                                           @"キャンセル",
                                           nil);
    
    if (ret == NSOKButton) {
        [mChara2DGroup removeChild:theSpec];
        [oElementView reloadData];

        [self updateChangeCount:NSChangeUndone];
    }
}

- (IBAction)removeSelectedChara2DImage:(id)sender
{
    BXChara2DImage* theImage = [self selectedChara2DImage];
    if (!theImage) {
        NSBeep();
        return;
    }
    
    int ret = NSRunInformationalAlertPanel(@"画像の削除",
                                           [NSString stringWithFormat:@"画像「%@」を削除してもよろしいですか？", [theImage imageName]],
                                           @"OK",
                                           @"キャンセル",
                                           nil);
    if (ret == NSOKButton) {
        int row = [oChara2DImageListView selectedRow];
        BXChara2DSpec* theSpec = [self selectedChara2DSpec];
        [theSpec removeImageAtIndex:row];
        
        [oChara2DImageListView reloadData];
        
        [self updateChangeCount:NSChangeUndone];
    }
}


#pragma mark-
#pragma mark 2Dキャラクタに関係する操作

- (void)addChara2DWithInfo:(NSDictionary*)theInfo
{
    BXChara2DSpec* newCharaSpec = [[[BXChara2DSpec alloc] initWithName:@"New Chara" defaultState:NO] autorelease];
    [newCharaSpec restoreElementInfo:theInfo document:self];
    [mChara2DGroup addChild:newCharaSpec];
}

- (void)addChara2DImageFiles:(NSArray*)filepaths
{
    BXChara2DSpec* selectedSpec = [self selectedChara2DSpec];
    if (!selectedSpec) {
        return;
    }

    BXChara2DImage* lastAddedImage = nil;
    
    for (int i = 0; i < [filepaths count]; i++) {
        NSString* aPath = [filepaths objectAtIndex:i];
        BXChara2DImage* anImage = [selectedSpec addImageAtPath:aPath document:self];
        lastAddedImage = anImage;
    }

    if (lastAddedImage) {
        [oChara2DImageListView reloadData];
        
        int lastAddedRow = [oChara2DImageListView rowForItem:lastAddedImage];
        [oChara2DImageListView scrollRowToVisible:lastAddedRow];
        [oChara2DImageListView selectRowIndexes:[NSIndexSet indexSetWithIndex:lastAddedRow] byExtendingSelection:NO];
        
        [self saveDocument:self];
    }
}

- (BOOL)canAddChara2DImage
{
    BXChara2DSpec* selectedSpec = [self selectedChara2DSpec];

    return (selectedSpec != nil)? YES: NO;
}

- (BOOL)canRemoveChara2DImage
{
    BXChara2DImage* selectedImage = [self selectedChara2DImage];
    return (selectedImage && ![selectedImage isUsed])? YES: NO;
}

- (BOOL)canRemoveChara2DState
{
    BXChara2DSpec* selectedSpec = [self selectedChara2DSpec];
    if ([selectedSpec stateCount] <= 1) {
        return NO;
    }
    
    BXChara2DState* selectedState = [self selectedChara2DState];
    return (selectedState != nil)? YES: NO;
}

- (void)updateChara2DAtlasListSize
{
    NSSize atlasViewSize = [oChara2DImageAtlasView minSize];
    
    NSRect frame = [oChara2DImageAtlasView frame];
    frame.size = atlasViewSize;
    [oChara2DImageAtlasView setFrame:frame];
    
    [oChara2DImageAtlasView deselectAll];
    
    [oChara2DImageAtlasView setNeedsDisplay:YES];    
}

- (void)updateChara2DAtlasList
{
    BXChara2DImage* selectedImage = [self selectedChara2DImage];

    if (selectedImage) {
        [selectedImage updateAtlasImages];
    }
    
    [self updateChara2DAtlasListSize];    
}

- (BOOL)isChara2DImageSelected
{
    BXChara2DImage* selectedImage = [self selectedChara2DImage];
    return (selectedImage? YES: NO);
}

- (BOOL)isChara2DKomaSelected
{
    BXChara2DKoma* selectedKoma = [self selectedChara2DKoma];
    return (selectedKoma? YES: NO);
}

- (BOOL)isChara2DStateSelected
{
    BXChara2DState* selectedState = [self selectedChara2DState];
    return (selectedState? YES: NO);
}

- (BOOL)canChara2DStateSelectNextState
{
    BXChara2DSpec* selectedSpec = [self selectedChara2DSpec];
    BXChara2DState* selectedState = [self selectedChara2DState];

    return (selectedState && [selectedSpec stateCount] > 1);
}

- (void)removeSelectedChara2DKoma
{
    int selectedRow = [oChara2DKomaListView selectedRow];
    if (selectedRow < 0) {
        NSBeep();
        return;
    }
    
    BXChara2DState* selectedState = [self selectedChara2DState];
    BXChara2DKoma* theKoma = [selectedState komaAtIndex:selectedRow];
    
    BXChara2DKoma* cancelKoma = [selectedState targetKomaForCancel];
    if (theKoma == cancelKoma) {
        [selectedState setTargetKomaForCancel:nil];
    }
    
    BXChara2DImage* theImage = [theKoma image];
    [selectedState removeKomaAtIndex:selectedRow];

    if (theImage == [self selectedChara2DImage]) {
        [self setupEditorForChara2DImage:theImage];
    }
    
    [oChara2DKomaListView reloadData];
    
    [self updateChara2DStateCancelKomaButtonMenu];

    [self updateChangeCount:NSChangeUndone];
}

- (void)changedChara2DStateCancelKoma:(id)sender
{
    BXChara2DState* selectedState = [self selectedChara2DState];
    if (!selectedState) {
        return;
    }
    
    int komaNumber = [oChara2DStateCancelKomaNumberButton selectedTag];
    BXChara2DKoma* theKoma = [selectedState komaWithNumber:komaNumber];
    [selectedState setTargetKomaForCancel:theKoma];
    
    [self updateChangeCount:NSChangeUndone];
}

- (void)updateChara2DStateCancelKomaButtonMenu
{    
    NSMenu* theMenu = [[[NSMenu alloc] initWithTitle:@"Cancel Koma Menu"] autorelease];
    
    NSMenuItem* noneItem = [theMenu addItemWithTitle:NSLocalizedString(@"Cancel Koma Menu None Item Title", nil)
                                              action:@selector(changedChara2DStateCancelKoma:)
                                       keyEquivalent:@""];
    [noneItem setTag:0];
    [noneItem setTarget:self];
 
    BXChara2DState* selectedState = [self selectedChara2DState];
    if (selectedState) {
        for (int i = 0; i < [selectedState komaCount]; i++) {
            NSMenuItem* theItem = [theMenu addItemWithTitle:[NSString stringWithFormat:@"#%d", i+1]
                                                     action:@selector(changedChara2DStateCancelKoma:)
                                              keyEquivalent:@""];
            [theItem setTag:i+1];
            [theItem setTarget:self];
        }
    }
    
    [oChara2DStateCancelKomaNumberButton setMenu:theMenu];
    
    if (selectedState) {
        BXChara2DKoma* theKoma = [selectedState targetKomaForCancel];
        [oChara2DStateCancelKomaNumberButton selectItemWithTag:[theKoma komaNumber]];
    }    
}


#pragma mark -
#pragma mark 2Dパーティクルの設定アクション

- (IBAction)changedParticleGroupID:(id)sender
{
    BXSingleParticle2DSpec* particleSpec = [self selectedSingleParticle2DSpec];
    if (!particleSpec) {
        return;
    }
    
    int theID = [oParticleGroupIDField intValue];
    [particleSpec setGroupID:theID];
    
    [self updateChangeCount:NSChangeUndone];
}

- (IBAction)changedParticleResourceID:(id)sender
{
    int theID = [oParticleResourceIDField intValue];

    BXSingleParticle2DSpec* particleSpec = [self selectedSingleParticle2DSpec];
    [particleSpec setResourceID:theID];
    
    [oElementView reloadData];
    
    int theRow = [oElementView rowForItem:particleSpec];
    [oElementView selectRowIndexes:[NSIndexSet indexSetWithIndex:theRow] byExtendingSelection:NO];

    [self updateChangeCount:NSChangeUndone];
}

- (IBAction)changedParticleResourceName:(id)sender
{
    NSString* theName = [oParticleResourceNameField stringValue];
    
    BXSingleParticle2DSpec* particleSpec = [self selectedSingleParticle2DSpec];
    [particleSpec setResourceName:theName];
    
    [oElementView reloadData];

    [self updateChangeCount:NSChangeUndone];
}

- (void)showCustomParticle2DImageSelectSheet
{
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel beginSheetForDirectory:nil
                                 file:nil
                                types:[NSImage imageFileTypes]
                       modalForWindow:oMainWindow
                        modalDelegate:self
                       didEndSelector:@selector(customParticle2DImageSheetDidEnd:returnCode:context:)
                          contextInfo:nil];
}

- (void)customParticle2DImageSheetDidEnd:(NSOpenPanel*)panel
                              returnCode:(int)returnCode
                                 context:(void*)context
{
    BXSingleParticle2DSpec* particleSpec = [self selectedSingleParticle2DSpec];

    if (returnCode == NSOKButton) {
        NSString* filename = [panel filename];
        [particleSpec setImageAtPath:filename];
        
        [self saveDocument:self];
        
        [oParticleView rebuildParticleSystem];
    } else {
        [oParticleImageButton selectItemWithTag:[particleSpec imageTag]];
    }
}

- (IBAction)changedParticleImage:(id)sender
{
    int tag = [oParticleImageButton selectedTag];
    
    // カスタム画像
    if (tag == 999) {
        [self showCustomParticle2DImageSelectSheet];
    }
    // プリセット画像
    else {
        BXSingleParticle2DSpec* particleSpec = [self selectedSingleParticle2DSpec];
        [particleSpec setImageTag:tag];
        
        [oParticleView rebuildParticleSystem];
        
        [self updateChangeCount:NSChangeUndone];
    }    
}

- (IBAction)changedParticleLoopSetting:(id)sender
{
    BOOL doLoop = ([oParticleLoopButton state] == NSOnState);
 
    BXSingleParticle2DSpec* particleSpec = [self selectedSingleParticle2DSpec];
    [particleSpec setDoLoop:doLoop];

    [self updateChangeCount:NSChangeUndone];
}

- (IBAction)changedParticleGravityX:(id)sender
{
    float gravityX = 0.0f;
    if (sender == oParticleGravitySliderX) {
        gravityX = [oParticleGravitySliderX floatValue];
    } else {
        gravityX = [oParticleGravityFieldX floatValue];
    }
    
    BXSingleParticle2DSpec* particleSpec = [self selectedSingleParticle2DSpec];
    [particleSpec setGravityX:gravityX];

    [self setupEditorUIForSingleParticle2D:particleSpec];
    [oParticleView rebuildParticleSystem];

    [self updateChangeCount:NSChangeUndone];
}

- (IBAction)changedParticleGravityY:(id)sender
{
    float gravityY = 0.0f;
    if (sender == oParticleGravitySliderY) {
        gravityY = [oParticleGravitySliderY floatValue];
    } else {
        gravityY = [oParticleGravityFieldY floatValue];
    }
    
    BXSingleParticle2DSpec* particleSpec = [self selectedSingleParticle2DSpec];
    [particleSpec setGravityY:gravityY];

    [self setupEditorUIForSingleParticle2D:particleSpec];
    [oParticleView rebuildParticleSystem];

    [self updateChangeCount:NSChangeUndone];
}

- (IBAction)changedParticleLife:(id)sender
{
    int life = 1;
    if (sender == oParticleLifeSlider) {
        life = [oParticleLifeSlider intValue];
    } else {
        life = [oParticleLifeField intValue];
    }
    
    BXSingleParticle2DSpec* particleSpec = [self selectedSingleParticle2DSpec];
    [particleSpec setLife:life];

    [self setupEditorUIForSingleParticle2D:particleSpec];
    [oParticleView rebuildParticleSystem];

    [self updateChangeCount:NSChangeUndone];
}

- (IBAction)changedParticleColor:(id)sender
{
    NSColor* color = [oParticleColorWell color];
    color = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];

    float r = [color redComponent];
    float g = [color greenComponent];
    float b = [color blueComponent];
    float a = [color alphaComponent];
    
    BXSingleParticle2DSpec* particleSpec = [self selectedSingleParticle2DSpec];
    [particleSpec setColor:KRColor(r, g, b, a)];

    [oParticleView rebuildParticleSystem];

    [self updateChangeCount:NSChangeUndone];
}

- (IBAction)changedParticleMinAngleV:(id)sender
{
    int degree = 0;
    if (sender == oParticleMinAngleVSlider) {
        degree = [oParticleMinAngleVSlider intValue];
    } else {
        degree = [oParticleMinAngleVField intValue];
    }
    
    BXSingleParticle2DSpec* particleSpec = [self selectedSingleParticle2DSpec];
    [particleSpec setMinAngleV:degree];
    
    [self setupEditorUIForSingleParticle2D:particleSpec];
    [oParticleView rebuildParticleSystem];

    [self updateChangeCount:NSChangeUndone];
}

- (IBAction)changedParticleMaxAngleV:(id)sender
{
    int degree = 0;
    if (sender == oParticleMaxAngleVSlider) {
        degree = [oParticleMaxAngleVSlider intValue];
    } else {
        degree = [oParticleMaxAngleVField intValue];
    }
    
    BXSingleParticle2DSpec* particleSpec = [self selectedSingleParticle2DSpec];
    [particleSpec setMaxAngleV:degree];
    
    [self setupEditorUIForSingleParticle2D:particleSpec];
    [oParticleView rebuildParticleSystem];

    [self updateChangeCount:NSChangeUndone];
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

    BXSingleParticle2DSpec* particleSpec = [self selectedSingleParticle2DSpec];
    [particleSpec setBlendMode:blendMode];
    
    [oParticleView rebuildParticleSystem];

    [self updateChangeCount:NSChangeUndone];
}

- (IBAction)changedParticleBGColor1:(id)sender
{
    NSColor* color = [oParticleBGColorWell1 color];
    color = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    
    float r = [color redComponent];
    float g = [color greenComponent];
    float b = [color blueComponent];
    float a = [color alphaComponent];
    
    BXSingleParticle2DSpec* particleSpec = [self selectedSingleParticle2DSpec];
    [particleSpec setBGColor1:KRColor(r, g, b, a)];

    [self updateChangeCount:NSChangeUndone];
}

- (IBAction)changedParticleMaxVX:(id)sender
{
    float maxVX = 0.0f;
    if (sender == oParticleMaxVXSlider) {
        maxVX = [oParticleMaxVXSlider floatValue];
    } else {
        maxVX = [oParticleMaxVXField floatValue];
    }
    
    BXSingleParticle2DSpec* particleSpec = [self selectedSingleParticle2DSpec];
    [particleSpec setMaxVX:maxVX];
    
    [self setupEditorUIForSingleParticle2D:particleSpec];
    [oParticleView rebuildParticleSystem];    

    [self updateChangeCount:NSChangeUndone];
}

- (IBAction)changedParticleMaxVY:(id)sender
{
    float maxVY = 0.0f;
    if (sender == oParticleMaxVYSlider) {
        maxVY = [oParticleMaxVYSlider floatValue];
    } else {
        maxVY = [oParticleMaxVYField floatValue];
    }
    
    BXSingleParticle2DSpec* particleSpec = [self selectedSingleParticle2DSpec];
    [particleSpec setMaxVY:maxVY];
    
    [self setupEditorUIForSingleParticle2D:particleSpec];
    [oParticleView rebuildParticleSystem];    

    [self updateChangeCount:NSChangeUndone];
}

- (IBAction)changedParticleDeltaScale:(id)sender
{
    float scale = 0.0f;
    if (sender == oParticleDeltaScaleSlider) {
        scale = [oParticleDeltaScaleSlider floatValue];
    } else {
        scale = [oParticleDeltaScaleField floatValue];
    }
    
    BXSingleParticle2DSpec* particleSpec = [self selectedSingleParticle2DSpec];
    [particleSpec setDeltaScale:scale];
    
    [self setupEditorUIForSingleParticle2D:particleSpec];
    [oParticleView rebuildParticleSystem];    

    [self updateChangeCount:NSChangeUndone];
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

    BXSingleParticle2DSpec* particleSpec = [self selectedSingleParticle2DSpec];
    [particleSpec setDeltaRed:deltaRed];
    [particleSpec setDeltaGreen:deltaGreen];
    [particleSpec setDeltaBlue:deltaBlue];
    [particleSpec setDeltaAlpha:deltaAlpha];
    
    [self setupEditorUIForSingleParticle2D:particleSpec];
    [oParticleView rebuildParticleSystem];    

    [self updateChangeCount:NSChangeUndone];
}

- (IBAction)changedParticleMinVX:(id)sender
{
    float minVX = 0.0f;
    if (sender == oParticleMinVXSlider) {
        minVX = [oParticleMinVXSlider floatValue];
    } else {
        minVX = [oParticleMinVXField floatValue];
    }
    
    BXSingleParticle2DSpec* particleSpec = [self selectedSingleParticle2DSpec];
    [particleSpec setMinVX:minVX];
    
    [self setupEditorUIForSingleParticle2D:particleSpec];
    [oParticleView rebuildParticleSystem];    

    [self updateChangeCount:NSChangeUndone];
}

- (IBAction)changedParticleMinVY:(id)sender
{
    float minVY = 0.0f;
    if (sender == oParticleMinVYSlider) {
        minVY = [oParticleMinVYSlider floatValue];
    } else {
        minVY = [oParticleMinVYField floatValue];
    }
    
    BXSingleParticle2DSpec* particleSpec = [self selectedSingleParticle2DSpec];
    [particleSpec setMinVY:minVY];
    
    [self setupEditorUIForSingleParticle2D:particleSpec];
    [oParticleView rebuildParticleSystem];    

    [self updateChangeCount:NSChangeUndone];
}

- (IBAction)changedParticleGenerateCount:(id)sender
{
    int count = 0;
    if (sender == oParticleGenerateCountSlider) {
        count = [oParticleGenerateCountSlider intValue];
    } else {
        count = [oParticleGenerateCountField intValue];
    }
    
    BXSingleParticle2DSpec* particleSpec = [self selectedSingleParticle2DSpec];
    [particleSpec setGenerateCount:count];
    
    [self setupEditorUIForSingleParticle2D:particleSpec];
    [oParticleView rebuildParticleSystem];

    [self updateChangeCount:NSChangeUndone];
}

- (IBAction)changedParticleMaxCount:(id)sender
{
    int count = 0;
    if (sender == oParticleMaxParticleCountSlider) {
        count = [oParticleMaxParticleCountSlider intValue];
    } else {
        count = [oParticleMaxParticleCountField intValue];
    }
    
    BXSingleParticle2DSpec* particleSpec = [self selectedSingleParticle2DSpec];
    [particleSpec setMaxParticleCount:count];
    
    [self setupEditorUIForSingleParticle2D:particleSpec];
    [oParticleView rebuildParticleSystem];

    [self updateChangeCount:NSChangeUndone];
}

- (IBAction)removeSelectedParticle2D:(id)sender
{
    BXSingleParticle2DSpec* theSpec = [self selectedSingleParticle2DSpec];
    if (!theSpec) {
        NSBeep();
        return;
    }
    
    int ret = NSRunInformationalAlertPanel(@"リソースの削除",
                                           [NSString stringWithFormat:@"Particle2D「%d: %@」を削除してもよろしいですか？", [theSpec resourceID], [theSpec resourceName]],
                                           @"OK",
                                           @"キャンセル",
                                           nil);
    
    if (ret == NSOKButton) {
        [oParticleView setupForParticleSpec:nil];
        [oParticleView releaseParticles];
        
        [mParticle2DGroup removeChild:theSpec];
        [oElementView reloadData];
        
        [self updateChangeCount:NSChangeUndone];
    }
}


#pragma mark -
#pragma mark 2Dパーティクル設定に関するメソッド

- (void)addParticle2DWithInfo:(NSDictionary*)theInfo
{
    BXSingleParticle2DSpec* newParticleSpec = [[[BXSingleParticle2DSpec alloc] initWithName:@"New Particle"] autorelease];
    [newParticleSpec restoreElementInfo:theInfo document:self];
    [mParticle2DGroup addChild:newParticleSpec];
}


#pragma mark -
#pragma mark シリアライゼーション（読み込み）

- (BOOL)readFromURL:(NSURL*)absoluteURL ofType:(NSString*)typeName error:(NSError**)outError
{
    NSString* filepath = [absoluteURL path];
    NSString* filename = [filepath lastPathComponent];
    NSString* ext = [filename pathExtension];

    if ([ext isEqualToString:@"krbox"]) {
        NSDictionary* theInfo = [NSDictionary dictionaryWithContentsOfFile:filepath];
        NSString* projFileName = [theInfo objectForKey:@"Project File"];
        if (!projFileName || [projFileName length] == 0) {
            return NO;
        } else {
            NSString* projFilePath = [[filepath stringByDeletingLastPathComponent] stringByAppendingPathComponent:projFileName];
            NSFileWrapper* fileWrapper = [[[NSFileWrapper alloc] initWithPath:projFilePath] autorelease];
            mRootWrapper = [fileWrapper retain];
            return YES;
        }
    } else {
        NSFileWrapper* fileWrapper = [[[NSFileWrapper alloc] initWithPath:filepath] autorelease];
        return [self readFromFileWrapper:fileWrapper ofType:@"Karakuri Resource Project" error:outError];
    }
}

- (BOOL)readFromFileWrapper:(NSFileWrapper*)fileWrapper ofType:(NSString*)typeName error:(NSError**)outError
{
    mRootWrapper = [fileWrapper retain];
    
    return YES;
}


#pragma mark -
#pragma mark シリアライゼーション（保存）

- (BOOL)writeToURL:(NSURL*)absoluteURL ofType:(NSString*)typeName error:(NSError**)outError
{
    NSString* filepath = [absoluteURL path];
    NSString* filename = [filepath lastPathComponent];
    NSString* ext = [filename pathExtension];
    
    if ([ext isEqualToString:@"krbox"]) {
        NSDictionary* theInfo = [NSDictionary dictionaryWithObject:@"Game Resource.krrsproj" forKey:@"Project File"];
        NSString* error = nil;
        NSData* theData = [NSPropertyListSerialization dataFromPropertyList:theInfo format:NSPropertyListBinaryFormat_v1_0 errorDescription:&error];
        [theData writeToURL:absoluteURL atomically:NO];
        
        NSFileWrapper* fileWrapper = [self fileWrapperOfType:nil error:outError];
        NSString* selfPath = [[self fileURL] path];
        NSString* projPath = [[selfPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Game Resource.krrsproj"];
        
        [fileWrapper writeToFile:projPath atomically:NO updateFilenames:YES];
        
        return YES;
    } else {
        return [super writeToURL:absoluteURL ofType:typeName error:outError];
    }
}

- (NSFileWrapper*)fileWrapperOfType:(NSString*)typeName error:(NSError**)outError
{
    NSFileWrapper* contentsWrapper = [self contentsWrapper];    
    NSFileWrapper* resourcesWrapper = [self resourcesWrapper];
    
    NSFileWrapper* resourceMapWrapper = [[resourcesWrapper fileWrappers] objectForKey:@"ResourceMap.plist"];
    if (resourceMapWrapper) {
        [resourcesWrapper removeFileWrapper:resourceMapWrapper];
    }
    [resourcesWrapper addRegularFileWithContents:[mFileManager resourceMapData] preferredFilename:@"ResourceMap.plist"];
    
    NSFileWrapper* chara2DInfosWrapper = [[contentsWrapper fileWrappers] objectForKey:@"Chara2DInfos.plist"];
    if (chara2DInfosWrapper) {
        [contentsWrapper removeFileWrapper:chara2DInfosWrapper];
    }
    
    NSFileWrapper* particle2DInfosWrapper = [[contentsWrapper fileWrappers] objectForKey:@"Particle2DInfos.plist"];
    if (particle2DInfosWrapper) {
        [contentsWrapper removeFileWrapper:particle2DInfosWrapper];
    }
    
    [contentsWrapper addRegularFileWithContents:[mChara2DGroup groupData] preferredFilename:@"Chara2DInfos.plist"];
    [contentsWrapper addRegularFileWithContents:[mParticle2DGroup groupData] preferredFilename:@"Particle2DInfos.plist"];
    
    return mRootWrapper;
}


#pragma mark -
#pragma mark UIと内部データの同期

- (void)setupEditorUIForChara2D:(BXChara2DSpec*)theSpec
{
    [oChara2DGroupIDField setIntValue:[theSpec groupID]];
    [oChara2DResourceIDField setIntValue:[theSpec resourceID]];
    [oChara2DResourceNameField setStringValue:[theSpec resourceName]];

    [oChara2DStateListView reloadData];

    [oChara2DStateListView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
}

- (void)setupEditorForChara2DState:(BXChara2DState*)theState
{
    // 状態がない場合
    if (!theState) {
        [oChara2DKomaDefaultIntervalButton selectItemWithTag:1];
        [oChara2DStateCancelKomaNumberButton selectItemWithTag:0];

        // 次の状態メニューをクリアする
        [oChara2DStateNextStateButton removeAllItems];
    }
    // 状態がある場合
    else {
        [oChara2DKomaDefaultIntervalButton selectItemWithTag:[theState defaultKomaInterval]];
        
        // 次の状態メニューの再構築
        NSMenu* menu = [[NSMenu alloc] initWithTitle:@"Next State Menu"];
        
        NSMenuItem* noneMenuItem = [menu addItemWithTitle:@"なし" action:@selector(changedChara2DStateNextState:) keyEquivalent:@""];
        [noneMenuItem setTarget:self];
        [noneMenuItem setTag:-1];

        BXChara2DSpec* currentSpec = [self selectedChara2DSpec];
        for (int i = 0; i < [currentSpec stateCount]; i++) {
            BXChara2DState* aState = [currentSpec stateAtIndex:i];
            if (aState == theState) {
                continue;
            }
            NSString* title = [NSString stringWithFormat:@"%d: %@", [aState stateID], [aState stateName]];
            NSMenuItem* aMenuItem = [menu addItemWithTitle:title action:@selector(changedChara2DStateNextState:) keyEquivalent:@""];
            [aMenuItem setTarget:self];
            [aMenuItem setTag:[aState stateID]];
        }
        
        [oChara2DStateNextStateButton setMenu:menu];
        [oChara2DStateNextStateButton selectItemWithTag:[theState nextStateID]];
        
        int defaultKomaInterval = [theState defaultKomaInterval];
        [oChara2DKomaDefaultIntervalButton selectItemWithTag:defaultKomaInterval];
    }
}

- (void)setupEditorForChara2DImage:(BXChara2DImage*)theImage
{
    if (!theImage) {
        [oChara2DImageDivXField setStringValue:@""];
        [oChara2DImageDivYField setStringValue:@""];
    } else {
        [oChara2DImageDivXField setIntValue:[theImage divX]];
        [oChara2DImageDivYField setIntValue:[theImage divY]];
        
        if ([theImage isUsed]) {
            [oChara2DImageDivXField setEnabled:NO];
            [oChara2DImageDivYField setEnabled:NO];
        } else {
            [oChara2DImageDivXField setEnabled:YES];
            [oChara2DImageDivYField setEnabled:YES];
        }
    }
}

- (void)setupEditorUIForSingleParticle2D:(BXSingleParticle2DSpec*)theSpec
{
    [oParticleGroupIDField setIntValue:[theSpec groupID]];
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
    
    [oParticleImageButton selectItemWithTag:[theSpec imageTag]];
}

- (void)setupChara2DHitButtons
{
    BXChara2DKoma* theKoma = [self selectedChara2DKoma];
    
    [oChara2DHitButtonAddCircle setHidden:YES];

    if (theKoma) {
        [oChara2DHitButtonAll setEnabled:YES];
        
        if ([theKoma showsHitInfos]) {
            [oChara2DHitButtonAll setState:NSOnState];
            [oChara2DHitButton1 setEnabled:YES];
            [oChara2DHitButton2 setEnabled:YES];
            [oChara2DHitButton3 setEnabled:YES];
            [oChara2DHitButton4 setEnabled:YES];
            [oChara2DHitButton5 setEnabled:YES];
            [oChara2DHitButton6 setEnabled:YES];
            [oChara2DHitButton7 setEnabled:YES];
            [oChara2DHitButton8 setEnabled:YES];
            [oChara2DHitButton9 setEnabled:YES];
            [oChara2DHitButton10 setEnabled:YES];
            [oChara2DHitButton11 setEnabled:YES];
            [oChara2DHitButton12 setEnabled:YES];

            [oChara2DHitButton1 setState:([theKoma currentHitGroupIndex] == 1)? NSOnState: NSOffState];
            [oChara2DHitButton2 setState:([theKoma currentHitGroupIndex] == 2)? NSOnState: NSOffState];
            [oChara2DHitButton3 setState:([theKoma currentHitGroupIndex] == 3)? NSOnState: NSOffState];
            [oChara2DHitButton4 setState:([theKoma currentHitGroupIndex] == 4)? NSOnState: NSOffState];
            [oChara2DHitButton5 setState:([theKoma currentHitGroupIndex] == 5)? NSOnState: NSOffState];
            [oChara2DHitButton6 setState:([theKoma currentHitGroupIndex] == 6)? NSOnState: NSOffState];
            [oChara2DHitButton7 setState:([theKoma currentHitGroupIndex] == 7)? NSOnState: NSOffState];
            [oChara2DHitButton8 setState:([theKoma currentHitGroupIndex] == 8)? NSOnState: NSOffState];
            [oChara2DHitButton9 setState:([theKoma currentHitGroupIndex] == 9)? NSOnState: NSOffState];
            [oChara2DHitButton10 setState:([theKoma currentHitGroupIndex] == 10)? NSOnState: NSOffState];
            [oChara2DHitButton11 setState:([theKoma currentHitGroupIndex] == 11)? NSOnState: NSOffState];
            [oChara2DHitButton12 setState:([theKoma currentHitGroupIndex] == 12)? NSOnState: NSOffState];
            
            [oChara2DHitButtonAddRect setEnabled:YES];
            //[oChara2DHitButtonAddCircle setEnabled:YES];
        } else {
            [oChara2DHitButtonAll setState:NSOffState];
            [oChara2DHitButton1 setEnabled:NO];
            [oChara2DHitButton2 setEnabled:NO];
            [oChara2DHitButton3 setEnabled:NO];
            [oChara2DHitButton4 setEnabled:NO];
            [oChara2DHitButton5 setEnabled:NO];
            [oChara2DHitButton6 setEnabled:NO];
            [oChara2DHitButton7 setEnabled:NO];
            [oChara2DHitButton8 setEnabled:NO];
            [oChara2DHitButton9 setEnabled:NO];
            [oChara2DHitButton10 setEnabled:NO];
            [oChara2DHitButton11 setEnabled:NO];
            [oChara2DHitButton12 setEnabled:NO];
            
            [oChara2DHitButton1 setState:NSOffState];
            [oChara2DHitButton2 setState:NSOffState];
            [oChara2DHitButton3 setState:NSOffState];
            [oChara2DHitButton4 setState:NSOffState];
            [oChara2DHitButton5 setState:NSOffState];
            [oChara2DHitButton6 setState:NSOffState];
            [oChara2DHitButton7 setState:NSOffState];
            [oChara2DHitButton8 setState:NSOffState];
            [oChara2DHitButton9 setState:NSOffState];
            [oChara2DHitButton10 setState:NSOffState];
            [oChara2DHitButton11 setState:NSOffState];
            [oChara2DHitButton12 setState:NSOffState];

            [oChara2DHitButtonAddRect setEnabled:NO];
            //[oChara2DHitButtonAddCircle setEnabled:NO];
        }
        [oChara2DHitCountField setIntValue:[theKoma hitInfoCount]];
    } else {
        [oChara2DHitButtonAll setState:NSOffState];
        [oChara2DHitButtonAll setEnabled:NO];
        [oChara2DHitButton1 setEnabled:NO];
        [oChara2DHitButton2 setEnabled:NO];
        [oChara2DHitButton3 setEnabled:NO];
        [oChara2DHitButton4 setEnabled:NO];
        [oChara2DHitButton5 setEnabled:NO];
        [oChara2DHitButton6 setEnabled:NO];
        [oChara2DHitButton7 setEnabled:NO];
        [oChara2DHitButton8 setEnabled:NO];
        [oChara2DHitButton9 setEnabled:NO];
        [oChara2DHitButton10 setEnabled:NO];
        [oChara2DHitButton11 setEnabled:NO];
        [oChara2DHitButton12 setEnabled:NO];
        [oChara2DHitButton1 setState:NSOffState];
        [oChara2DHitButton2 setState:NSOffState];
        [oChara2DHitButton3 setState:NSOffState];
        [oChara2DHitButton4 setState:NSOffState];
        [oChara2DHitButton5 setState:NSOffState];
        [oChara2DHitButton6 setState:NSOffState];
        [oChara2DHitButton7 setState:NSOffState];
        [oChara2DHitButton8 setState:NSOffState];
        [oChara2DHitButton9 setState:NSOffState];
        [oChara2DHitButton10 setState:NSOffState];
        [oChara2DHitButton11 setState:NSOffState];
        [oChara2DHitButton12 setState:NSOffState];

        [oChara2DHitButtonAddRect setEnabled:NO];
        //[oChara2DHitButtonAddCircle setEnabled:NO];

        [oChara2DHitCountField setStringValue:@""];
    }
}


#pragma mark -
#pragma mark NSOutlineView DataSource

- (int)outlineView:(NSOutlineView*)outlineView numberOfChildrenOfItem:(id)item
{
    // 左の要素リスト
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
    // 2Dキャラクタの状態リスト
    else if (outlineView == oChara2DStateListView) {
        // Root
        if (!item) {
            BXChara2DSpec* selectedSpec = [self selectedChara2DSpec];
            if (!selectedSpec) {
                return 0;
            }
            return [selectedSpec stateCount];
        }
    }
    // 2Dキャラクタの画像リスト
    else if (outlineView == oChara2DImageListView) {
        // Root
        if (!item) {
            BXChara2DSpec* selectedSpec = [self selectedChara2DSpec];
            if (!selectedSpec) {
                return 0;
            }
            return [selectedSpec imageCount];
        }
    }
    // 2Dキャラクタのコマリスト
    else if (outlineView == oChara2DKomaListView) {
        // Root
        if (!item) {
            BXChara2DState* selectedState = [self selectedChara2DState];
            if (!selectedState) {
                return 0;
            }
            return [selectedState komaCount];
        }
    }

    return 0;
}

- (id)outlineView:(NSOutlineView*)outlineView child:(int)index ofItem:(id)item
{
    // 左の要素リスト
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
    // 2Dキャラクタの状態のリスト
    else if (outlineView == oChara2DStateListView) {
        BXChara2DSpec* selectedSpec = [self selectedChara2DSpec];
        return [selectedSpec stateAtIndex:index];
    }
    // 2Dキャラクタの画像リスト
    else if (outlineView == oChara2DImageListView) {
        // Root
        if (!item) {
            BXChara2DSpec* selectedSpec = [self selectedChara2DSpec];
            return [selectedSpec imageAtIndex:index];
        }
    }
    // 2Dキャラクタのコマリスト
    else if (outlineView == oChara2DKomaListView) {
        // Root
        if (!item) {
            BXChara2DState* selectedState = [self selectedChara2DState];
            return [selectedState komaAtIndex:index];
        }
    }
    
    return nil;
}

- (id)outlineView:(NSOutlineView*)outlineView objectValueForTableColumn:(NSTableColumn*)tableColumn byItem:(id)item
{
    // 左の要素リスト
    if (outlineView == oElementView) {
        return [item localizedName];
    }
    // 2Dキャラクタの状態のリスト
    else if (outlineView == oChara2DStateListView) {
        if ([[tableColumn identifier] isEqualToString:@"id"]) {
            return [NSNumber numberWithInt:[(BXChara2DState*)item stateID]];
        } else if ([[tableColumn identifier] isEqualToString:@"name"]) {
            return [(BXChara2DState*)item stateName];
        }
    }
    // 2Dキャラクタの画像リスト
    else if (outlineView == oChara2DImageListView) {
        return [(BXChara2DImage*)item imageName];
    }
    // 2Dキャラクタのコマリスト
    else if (outlineView == oChara2DKomaListView) {
        NSString* columnIdentifier = [tableColumn identifier];
        
        // コマ#
        if ([columnIdentifier isEqualToString:@"koma_number"]) {
            return [NSNumber numberWithInt:[(BXChara2DKoma*)item komaNumber]];
        }
        // コマ画像
        else if ([columnIdentifier isEqualToString:@"koma_image"]) {
            return [(BXChara2DKoma*)item nsImage];
        }
        // コマキャンセル禁止フラグ
        else if ([columnIdentifier isEqualToString:@"koma_cancel"]) {
            return [NSNumber numberWithBool:![(BXChara2DKoma*)item isCancelable]];
        }
        // コマ表示間隔
        else if ([columnIdentifier isEqualToString:@"koma_interval"]) {
            int interval = [(BXChara2DKoma*)item interval];
            int index = [oChara2DKomaIntervalButtonCell indexOfItemWithTag:interval];
            return [NSNumber numberWithInt:index];
        }
    }

    return @"????";
}

- (void)outlineView:(NSOutlineView*)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn*)tableColumn byItem:(id)item
{
    // 2Dキャラクタの状態のリスト
    if (outlineView == oChara2DStateListView) {
        NSString* columnIdentifier = [tableColumn identifier];
        
        // 状態ID
        if ([columnIdentifier isEqualToString:@"id"]) {
            int oldStateID = [(BXChara2DState*)item stateID];
            int newStateID = [object intValue];
            [(BXChara2DState*)item setStateID:newStateID];
            BXChara2DSpec* currentSpec = [self selectedChara2DSpec];
            [currentSpec changeStateIDInAllKomaFrom:oldStateID to:newStateID];
            [currentSpec sortStateList];
            [oChara2DStateListView reloadData];
            [self updateChangeCount:NSChangeUndone];
        }
        // 状態名
        else if ([columnIdentifier isEqualToString:@"name"]) {
            [(BXChara2DState*)item setStateName:object];
            [self updateChangeCount:NSChangeUndone];
        }
    }
    // 2Dキャラクタのコマリスト
    else if (outlineView == oChara2DKomaListView) {
        NSString* columnIdentifier = [tableColumn identifier];

        // コマキャンセル可能フラグ
        if ([columnIdentifier isEqualToString:@"koma_cancel"]) {
            [(BXChara2DKoma*)item setCancelable:![object boolValue]];
            [self updateChangeCount:NSChangeUndone];
        }
        // コマ表示間隔
        else if ([columnIdentifier isEqualToString:@"koma_interval"]) {
            NSMenuItem* selectedItem = [oChara2DKomaIntervalButtonCell itemAtIndex:[object intValue]];
            [(BXChara2DKoma*)item setInterval:[selectedItem tag]];
            [self updateChangeCount:NSChangeUndone];
        }
    }
}

- (BOOL)outlineView:(NSOutlineView*)outlineView isItemExpandable:(id)item
{
    // 左の要素リスト
    if (outlineView == oElementView) {
        return [item isExpandable];
    }
    
    return NO;
}

- (BOOL)outlineView:(NSOutlineView*)outlineView isGroupItem:(id)item
{
    // 左の要素リスト
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

    // 左の要素リスト
    if (outlineView == oElementView) {
        int selectedRow = [oElementView selectedRow];
        if (selectedRow < 0) {
            [oEditorTabView selectTabViewItemWithIdentifier:@"no-selection"];
            return;
        }

        [oParticleView releaseParticles];
        
        BXResourceElement* theElem = [oElementView itemAtRow:selectedRow];
        
        // キャラクタの編集
        if ([theElem isKindOfClass:[BXChara2DSpec class]]) {
            [oEditorTabView selectTabViewItemWithIdentifier:@"chara2d-editor"];
            BXChara2DSpec* theCharaSpec = (BXChara2DSpec*)theElem;

            [self setupEditorUIForChara2D:theCharaSpec];
            
            [oChara2DKomaListView reloadData];
            [oChara2DImageListView reloadData];
            [oChara2DImageAtlasView setNeedsDisplay:YES];
            
            [self setupEditorForChara2DState:[self selectedChara2DState]];
            
            [self updateChara2DStateCancelKomaButtonMenu];
            
            int theScaleTag = (int)([theCharaSpec komaPreviewScale] * 100);
            [oChara2DKomaPreviewScaleButton selectItemWithTag:theScaleTag];
            [oChara2DKomaPreviewView updateViewSize];
            [oChara2DKomaPreviewView setNeedsDisplay:YES];

            [self willChangeValueForKey:@"canChara2DStateSelectNextState"];
            [self didChangeValueForKey:@"canChara2DStateSelectNextState"];
        }
        // パーティクルの編集
        else if ([theElem isKindOfClass:[BXSingleParticle2DSpec class]]) {
            BXSingleParticle2DSpec* theParticleSpec = (BXSingleParticle2DSpec*)theElem;

            [self setupEditorUIForSingleParticle2D:theParticleSpec];

            [oParticleView setupForParticleSpec:theParticleSpec];
            [oEditorTabView selectTabViewItemWithIdentifier:@"particle2d-editor"];
        }
        // 選択なし
        else {
            [oEditorTabView selectTabViewItemWithIdentifier:@"no-selection"];
        }        
    }
    // 2Dキャラクタの状態のリスト
    else if (outlineView == oChara2DStateListView) {
        [self willChangeValueForKey:@"canChara2DStateSelectNextState"];
        [self didChangeValueForKey:@"canChara2DStateSelectNextState"];
        
        [self setupEditorForChara2DState:[self selectedChara2DState]];
        
        [oChara2DKomaListView reloadData];
        [oChara2DKomaListView deselectAll:self];
        
        [self updateChara2DStateCancelKomaButtonMenu];
        
        [self willChangeValueForKey:@"isChara2DStateSelected"];
        [self didChangeValueForKey:@"isChara2DStateSelected"];
        
        [self willChangeValueForKey:@"canRemoveChara2DState"];
        [self didChangeValueForKey:@"canRemoveChara2DState"];
    }
    // 2Dキャラクタの画像リスト
    else if (outlineView == oChara2DImageListView) {
        BXChara2DImage* theImage = [self selectedChara2DImage];
        
        [self updateChara2DAtlasListSize];

        [self setupEditorForChara2DImage:theImage];
        [oChara2DImageAtlasView deselectAll];
        [oChara2DImageAtlasView setNeedsDisplay:YES];
        
        [self willChangeValueForKey:@"canRemoveChara2DImage"];
        [self didChangeValueForKey:@"canRemoveChara2DImage"];
    }
    // 2Dキャラクタのコマリスト
    else if (outlineView == oChara2DKomaListView) {
        [oChara2DKomaPreviewView updateViewSize];
        [oChara2DKomaPreviewView deselectHitInfo];
        [self setupChara2DHitButtons];
        
        [oChara2DKomaActionCommandButton setEnabled:([self selectedChara2DKoma]? YES: NO)];

        [self willChangeValueForKey:@"isChara2DKomaSelected"];
        [self didChangeValueForKey:@"isChara2DKomaSelected"];
    }
}

- (void)changedChara2DKomaGotoTarget:(NSMenuItem*)menuItem
{
    BXChara2DState* selectedState = [self selectedChara2DState];
    BXChara2DKoma* selectedKoma = [self selectedChara2DKoma];
    
    int targetKomaNumber = [menuItem tag];
    BXChara2DKoma* targetKoma = nil;
    if (targetKomaNumber > 0) {
        targetKoma = [selectedState komaAtIndex:targetKomaNumber-1];
    }
    [selectedKoma setGotoTarget:targetKoma];
    
    [self updateChangeCount:NSChangeUndone];
}

- (void)outlineView:(NSOutlineView*)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn*)tableColumn item:(id)item
{
    // 2Dキャラクタのコマリスト
    if (outlineView == oChara2DKomaListView) {
        NSString* columnIdentifier = [tableColumn identifier];
        
        // Gotoメニュー
        if ([columnIdentifier isEqualToString:@"koma_goto"]) {
            BXChara2DState* selectedState = [self selectedChara2DState];
            NSMenu* gotoMenu = [selectedState makeKomaGotoMenuForKoma:item document:self];
            [cell setMenu:gotoMenu];
            [cell selectItemWithTag:[item gotoTargetNumber]];
        }
    }
}

- (BOOL)outlineView:(NSOutlineView*)outlineView shouldEditTableColumn:(NSTableColumn*)tableColumn item:(id)item
{
    // 2Dキャラクタの状態リスト
    if (outlineView == oChara2DStateListView) {
        return YES;
    }
    
    return NO;
}

- (BOOL)outlineView:(NSOutlineView*)outlineView writeItems:(NSArray*)items toPasteboard:(NSPasteboard*)pboard
{
    if (outlineView == oChara2DKomaListView) {
        int theRow = [oChara2DKomaListView rowForItem:[items objectAtIndex:0]];
        NSIndexSet* theIndex = [NSIndexSet indexSetWithIndex:theRow];
        NSData* indexData = [NSArchiver archivedDataWithRootObject:theIndex];
        
        [pboard declareTypes:[NSArray arrayWithObject:gChara2DKomaDraggingPboardType] owner:oChara2DKomaListView];
        [pboard setData:indexData forType:gChara2DKomaDraggingPboardType];
        return YES;
    }
    
    return NO;
}

- (BOOL)outlineView:(NSOutlineView*)outlineView acceptDrop:(id<NSDraggingInfo>)info item:(id)item childIndex:(int)index
{
    // 2Dキャラクタのコマリスト
    if (outlineView == oChara2DKomaListView) {
        if ([info draggingSource] == oChara2DKomaListView) {
            NSPasteboard *pboard = [info draggingPasteboard];
            NSData* indexData = [pboard dataForType:gChara2DKomaDraggingPboardType];
            NSIndexSet* theIndex = [NSUnarchiver unarchiveObjectWithData:indexData];
            int theRow = [theIndex firstIndex];
            
            BXChara2DState* currentState = [self selectedChara2DState];
            int newRow = [currentState moveKomaFrom:theRow to:index];

            [oChara2DKomaListView reloadData];
            [oChara2DKomaListView scrollRowToVisible:newRow];
            [oChara2DKomaListView selectRowIndexes:[NSIndexSet indexSetWithIndex:newRow] byExtendingSelection:NO];

            [self updateChara2DStateCancelKomaButtonMenu];

            [self updateChangeCount:NSChangeUndone];
        } else {
            [self willChangeValueForKey:@"canRemoveChara2DImage"];

            BXChara2DState* currentState = [self selectedChara2DState];
            BXChara2DImage* currentImage = [self selectedChara2DImage];
            
            NSPasteboard* pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
            NSData* indexesData = [pboard dataForType:gChara2DImageAtlasDraggingPboardType];
            NSIndexSet* indexes = [NSUnarchiver unarchiveObjectWithData:indexesData];
            
            BXChara2DKoma* firstKoma = nil;
            
            int indexCount = [indexes count];
            unsigned indexBuffer[indexCount];
            [indexes getIndexes:indexBuffer maxCount:indexCount inIndexRange:nil];
            for (int i = indexCount-1; i >= 0; i--) {
                BXChara2DKoma* newKoma = [currentState insertKomaAtIndex:index];
                [newKoma setImage:currentImage atlasAtIndex:indexBuffer[i]];
                firstKoma = newKoma;
            }
            
            [self setupEditorForChara2DImage:currentImage];

            [oChara2DKomaListView reloadData];
            
            int theRow = [oChara2DKomaListView rowForItem:firstKoma];
            [oChara2DKomaListView scrollRowToVisible:theRow];
            [oChara2DKomaListView selectRowIndexes:[NSIndexSet indexSetWithIndex:theRow] byExtendingSelection:NO];
            
            [self updateChara2DStateCancelKomaButtonMenu];

            [self didChangeValueForKey:@"canRemoveChara2DImage"];

            [self updateChangeCount:NSChangeUndone];
        }
    }

    return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView*)outlineView
                  validateDrop:(id<NSDraggingInfo>)info
                  proposedItem:(id)item
            proposedChildIndex:(int)index
{
    BXChara2DState* selectedState = [self selectedChara2DState];
    if (!selectedState) {
        return NSDragOperationNone;
    }
    
    if ([info draggingSource] == oChara2DKomaListView) {
        if (index < 0) {
            return NSDragOperationNone;
        }
        return NSDragOperationMove;
    } else {
        if (index < 0) {
            return NSDragOperationNone;
        }
        return NSDragOperationCopy;
    }
}

#pragma mark -
#pragma mark NSToolbar delegate

- (NSArray*)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
    return [NSArray arrayWithObjects:
            //sKADocumentToolbarItemAddBackground,
            sKADocumentToolbarItemAddChara2D,
            sKADocumentToolbarItemAddParticle2D,
            //sKADocumentToolbarItemAddBGM,
            //sKADocumentToolbarItemAddSE,
            //sKADocumentToolbarItemAddStage,
            nil];
}

- (NSArray*)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar
{
    return [NSArray arrayWithObjects:
            //sKADocumentToolbarItemAddBackground,
            sKADocumentToolbarItemAddChara2D,
            sKADocumentToolbarItemAddParticle2D,
            //sKADocumentToolbarItemAddBGM,
            //sKADocumentToolbarItemAddSE,
            //sKADocumentToolbarItemAddStage,
            nil];
}

- (NSToolbarItem*)toolbar:(NSToolbar*)toolbar itemForItemIdentifier:(NSString*)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
    NSToolbarItem* ret = [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier] autorelease];
    
    [ret setLabel:NSLocalizedString(itemIdentifier, nil)];
    [ret setPaletteLabel:NSLocalizedString(itemIdentifier, nil)];
    
    if ([itemIdentifier isEqualToString:sKADocumentToolbarItemAddBackground]) {
        [ret setTarget:self];
        [ret setAction:@selector(addBackground:)];
    }
    else if ([itemIdentifier isEqualToString:sKADocumentToolbarItemAddChara2D]) {
        [ret setTarget:self];
        [ret setAction:@selector(addChara2D:)];
        [ret setImage:[NSImage imageNamed:@"tbi_chara2d.tiff"]];
    }
    else if ([itemIdentifier isEqualToString:sKADocumentToolbarItemAddParticle2D]) {
        [ret setTarget:self];
        [ret setAction:@selector(addParticle2D:)];
        [ret setImage:[NSImage imageNamed:@"tbi_particle2d.tiff"]];
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

- (void)windowDidResize:(NSNotification*)notification
{
    [self updateChara2DAtlasListSize];
    [oChara2DKomaPreviewView updateViewSize];
}

@end

