//
//  BXResourceFileManager.mm
//  Karakuri Box
//
//  Created by numata on 10/03/09.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BXResourceFileManager.h"
#import "BXDocument.h"
#import "NSString+UUID.h"


@implementation BXResourceFileInfo

- (id)initWithFileAtPath:(NSString*)filepath document:(BXDocument*)document
{
    self = [self init];
    if (self) {
        mDocument = document;

        NSFileWrapper* resourcesWrapper = [document resourcesWrapper];
        
        NSFileWrapper* resourceFileWrapper = [[[NSFileWrapper alloc] initWithPath:filepath] autorelease];
        mFileName = [[resourcesWrapper addFileWrapper:resourceFileWrapper] copy];
        
        [self setResourceName:[filepath lastPathComponent]];
    }
    return self;
}

- (id)initWithFileName:(NSString*)fileName resourceName:(NSString*)resourceName document:(BXDocument*)document
{
    self = [self init];
    if (self) {
        mDocument = document;
        
        mFileName = [fileName copy];

        [self setResourceName:resourceName];
    }
    return self;
}

- (void)dealloc
{
    [mResourceName release];
    [mFileName release];

    [super dealloc];
}

- (NSString*)fileName
{
    return mFileName;
}

- (NSString*)path
{
    NSURL* docURL = [mDocument fileURL];
    NSString* contentsPath = [[docURL path] stringByAppendingPathComponent:@"Contents"];
    NSString* resourcesPath = [contentsPath stringByAppendingPathComponent:@"Resources"];
    
    return [resourcesPath stringByAppendingPathComponent:mFileName];
}

- (NSString*)resourceName
{
    return mResourceName;
}

- (void)setResourceName:(NSString*)name
{
    [mResourceName release];
    mResourceName = [name copy];
}

- (NSData*)fileData
{
    NSFileWrapper* resourcesWrapper = [mDocument resourcesWrapper];
    NSFileWrapper* theWrapper = [[resourcesWrapper fileWrappers] objectForKey:mFileName];
    return [theWrapper regularFileContents];
}

- (NSImage*)image72dpi
{
    NSImage* theImage = [[[NSImage alloc] initWithData:[self fileData]] autorelease];
    return theImage;
}

@end


@implementation BXResourceFileManager

- (id)initWithDocument:(BXDocument*)document
{
    self = [super init];
    if (self) {
        mDocument = document;
        
        mResourceInfoMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [mResourceInfoMap release];

    [super dealloc];
}

- (NSString*)imageNameForTicket:(NSString*)ticket
{
    BXResourceFileInfo* theInfo = [mResourceInfoMap objectForKey:ticket];
    return [theInfo resourceName];
}

- (NSString*)storeFileAtPath:(NSString*)filepath
{
    NSString* newTicket = [NSString generateUUIDString];

    BXResourceFileInfo* theInfo = [[[BXResourceFileInfo alloc] initWithFileAtPath:filepath document:mDocument] autorelease];
    [mResourceInfoMap setObject:theInfo forKey:newTicket];
    
    return newTicket;
}

- (NSImage*)image72dpiForTicket:(NSString*)ticket
{
    BXResourceFileInfo* theInfo = [mResourceInfoMap objectForKey:ticket];
    return [theInfo image72dpi];
}

- (NSString*)pathForTicket:(NSString*)ticket
{
    BXResourceFileInfo* theInfo = [mResourceInfoMap objectForKey:ticket];
    return [theInfo path];
}

- (NSString*)resourceNameForTicket:(NSString*)ticket
{
    BXResourceFileInfo* theInfo = [mResourceInfoMap objectForKey:ticket];
    return [theInfo resourceName];
}

- (NSData*)resourceMapData
{
    NSMutableDictionary* mapInfo = [NSMutableDictionary dictionary];
    
    // 画像
    NSMutableArray* resourceInfos = [NSMutableArray array];
    NSArray* tickets = [mResourceInfoMap allKeys];
    for (int i = 0; i < [tickets count]; i++) {
        NSString* theTicketObj = [tickets objectAtIndex:i];
        BXResourceFileInfo* theFileInfo = [mResourceInfoMap objectForKey:theTicketObj];

        NSMutableDictionary* theInfo = [NSMutableDictionary dictionary];
        [theInfo setObject:theTicketObj forKey:@"Ticket"];
        [theInfo setObject:[theFileInfo fileName] forKey:@"File Name"];
        [theInfo setObject:[theFileInfo resourceName] forKey:@"Resource Name"];
        [resourceInfos addObject:theInfo];
    }
    [mapInfo setObject:resourceInfos forKey:@"Resource Infos"];
    
    return [NSPropertyListSerialization dataFromPropertyList:mapInfo format:NSPropertyListBinaryFormat_v1_0 errorDescription:nil];
}

- (void)restoreResourceMapData:(NSData*)data
{
    NSDictionary* mapInfo = [NSPropertyListSerialization propertyListFromData:data
                                                             mutabilityOption:NSPropertyListImmutable
                                                                       format:NULL
                                                             errorDescription:nil];

    // 画像
    NSArray* resourceInfos = [mapInfo objectForKey:@"Resource Infos"];
    for (int i = 0; i < [resourceInfos count]; i++) {
        NSDictionary* anImageInfo = [resourceInfos objectAtIndex:i];
        NSString* theTicketObj = [anImageInfo objectForKey:@"Ticket"];
        NSString* fileName = [anImageInfo objectForKey:@"File Name"];
        NSString* resourceName = [anImageInfo objectForKey:@"Resource Name"];
        
        BXResourceFileInfo* theInfo = [[[BXResourceFileInfo alloc] initWithFileName:fileName
                                                                       resourceName:resourceName
                                                                           document:mDocument] autorelease];
        [mResourceInfoMap setObject:theInfo forKey:theTicketObj];
    }
}

@end


