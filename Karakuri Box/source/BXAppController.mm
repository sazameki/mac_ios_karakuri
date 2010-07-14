//
//  BXAppController.mm
//  Karakuri Box
//
//  Created by numata on 10/03/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BXAppController.h"
#import "BXDocument.h"


@implementation BXAppController

+ (void)initialize
{
    NSString* defaultsPath = [[NSBundle mainBundle] pathForResource:@"UserDefaults" 
                                                             ofType:@"plist"];
    NSDictionary* defaultsDict = [NSDictionary dictionaryWithContentsOfFile:defaultsPath];

    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsDict];
    [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:defaultsDict];
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication*)sender
{
    return NO;
}

- (void)applicationDidFinishLaunching:(NSNotification*)aNotification
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    BOOL opensLastOpenedFile = [defaults boolForKey:@"opensLastOpenedFile"];
    if (opensLastOpenedFile) {
        BOOL processed = NO;
        
        NSString* lastOpenedFilePath = [defaults stringForKey:@"lastOpenedFilePath"];
        
        if (lastOpenedFilePath && [lastOpenedFilePath length] > 0) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:lastOpenedFilePath]) {
                NSDocumentController* docController = [NSDocumentController sharedDocumentController];
                NSURL* fileURL = [NSURL fileURLWithPath:lastOpenedFilePath];
                
                NSError* error = nil;
                BXDocument* newDoc = [docController openDocumentWithContentsOfURL:fileURL display:YES error:&error];
                
                if (newDoc) {
                    processed = YES;
                }
            }
        }
        
        if (!processed) {
            [self createNewDocument:self];
        }
    }
}

- (NSData*)defaultInfoPlistDictionaryData
{
    NSMutableDictionary* theDict = [NSMutableDictionary dictionary];
    
    [theDict setObject:@"1.0" forKey:@"Karakuri Resource Project Version"];
    
    return [NSPropertyListSerialization dataFromPropertyList:theDict format:NSPropertyListBinaryFormat_v1_0 errorDescription:nil];
}

- (NSData*)emptyArrayInfoData
{
    NSArray* array = [NSArray array];
    
    return [NSPropertyListSerialization dataFromPropertyList:array format:NSPropertyListBinaryFormat_v1_0 errorDescription:nil];
}

- (BOOL)createRootPackageAtPath:(NSString*)filepath
{
    NSString* extension = [filepath pathExtension];
    if (!extension || ![extension isEqualToString:@"krrsproj"]) {
        filepath = [filepath stringByAppendingPathExtension:@"krrsproj"];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filepath]) {
        if (![[NSFileManager defaultManager] removeFileAtPath:filepath handler:nil]) {
            NSBeep();
            NSRunCriticalAlertPanel(@"Karakuri Box Error",
                                    [NSString stringWithFormat:@"Failed to remove previous package: \"%@\"", [filepath stringByAbbreviatingWithTildeInPath]],
                                    @"OK", nil, nil);
            return NO;
        }
    }
    
    NSFileWrapper* rootWrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:nil];
    NSFileWrapper* contentsWrapper = [[[NSFileWrapper alloc] initDirectoryWithFileWrappers:nil] autorelease];
    [contentsWrapper setPreferredFilename:@"Contents"];

    [contentsWrapper addRegularFileWithContents:[self defaultInfoPlistDictionaryData]
                              preferredFilename:@"Info.plist"];
    [contentsWrapper addRegularFileWithContents:[self emptyArrayInfoData]
                              preferredFilename:@"Chara2DInfos.plist"];
    [contentsWrapper addRegularFileWithContents:[self emptyArrayInfoData]
                              preferredFilename:@"Particle2DInfos.plist"];

    [rootWrapper addFileWrapper:contentsWrapper];

    [rootWrapper writeToFile:filepath atomically:NO updateFilenames:YES];
    
    [rootWrapper release];
    
    return YES;
}

- (IBAction)createNewDocument:(id)sender
{
    NSSavePanel* savePanel = [NSSavePanel savePanel];
    [savePanel setMessage:@"新規リソースプロジェクトの保存場所と名前を指定してください。"];
    [savePanel setTitle:@"新規 Karakuri リソースの作成"];
    [savePanel setPrompt:@"作成"];
    [savePanel setAllowedFileTypes:[NSArray arrayWithObject:@"krrsproj"]];
    [savePanel setExtensionHidden:YES];
    [savePanel center];
    if ([savePanel runModalForDirectory:nil file:@"New Resource"] == NSOKButton) {
        NSString* filepath = [savePanel filename];
        if ([self createRootPackageAtPath:filepath]) {
            NSDocumentController* docController = [NSDocumentController sharedDocumentController];
            NSURL* fileurl = [NSURL fileURLWithPath:filepath];
            
            NSError* error = nil;
            [docController openDocumentWithContentsOfURL:fileurl display:YES error:&error];
        }
    }
}

- (IBAction)showPreferencesWindow:(id)sender
{
    if ([oPrefWindow isVisible]) {
        return;
    }
    
    [oPrefWindow center];
    [oPrefWindow makeKeyAndOrderFront:self];
}

@end

