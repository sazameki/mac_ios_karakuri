//
//  BXResourceFileManager.mm
//  Karakuri Box
//
//  Created by numata on 10/03/09.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BXResourceFileManager.h"
#import "BXDocument.h"


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

- (NSString*)resourceName
{
    return mResourceName;
}

- (void)setResourceName:(NSString*)name
{
    [mResourceName release];
    mResourceName = [name copy];
}

- (NSImage*)image72dpi
{
    NSFileWrapper* resourcesWrapper = [mDocument resourcesWrapper];
    NSFileWrapper* theWrapper = [[resourcesWrapper fileWrappers] objectForKey:mFileName];
    NSData *contentsData = [theWrapper regularFileContents];
    
    NSImage* theImage = [[[NSImage alloc] initWithData:contentsData] autorelease];
    return theImage;
}

@end


@interface BXResourceFileManager ()

- (int)nextImageTicket;

@end


@implementation BXResourceFileManager

- (id)initWithDocument:(BXDocument*)document
{
    self = [super init];
    if (self) {
        mDocument = document;
        
        mImageInfoMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [mImageInfoMap release];

    [super dealloc];
}

- (NSString*)imageNameForTicket:(int)ticket
{
    BXResourceFileInfo* theInfo = [mImageInfoMap objectForKey:[NSNumber numberWithInt:ticket]];
    return [theInfo resourceName];
}

- (int)nextImageTicket
{
    int ret = 0;
    BOOL found = YES;

    while ([mImageInfoMap objectForKey:[NSNumber numberWithInt:ret]]) {
        ret++;
        if (ret > 40000) {
            found = NO;
            break;
        }
    }
    
    if (!found) {
        ret = -1;
    }
    return ret;
}

- (int)storeImageFileAtPath:(NSString*)filepath
{
    int imageTicket = [self nextImageTicket];
    if (imageTicket < 0) {
        return -1;
    }

    BXResourceFileInfo* theInfo = [[[BXResourceFileInfo alloc] initWithFileAtPath:filepath document:mDocument] autorelease];
    [mImageInfoMap setObject:theInfo forKey:[NSNumber numberWithInt:imageTicket]];
    
    return imageTicket;
}

- (NSImage*)image72dpiForTicket:(int)ticket
{
    BXResourceFileInfo* theInfo = [mImageInfoMap objectForKey:[NSNumber numberWithInt:ticket]];
    return [theInfo image72dpi];
}

- (NSData*)resourceMapData
{
    NSMutableDictionary* mapInfo = [NSMutableDictionary dictionary];
    
    // 画像
    NSMutableArray* imageInfos = [NSMutableArray array];
    NSArray* tickets = [mImageInfoMap allKeys];
    for (int i = 0; i < [tickets count]; i++) {
        NSNumber* theTicketObj = [tickets objectAtIndex:i];
        BXResourceFileInfo* theFileInfo = [mImageInfoMap objectForKey:theTicketObj];

        NSMutableDictionary* theInfo = [NSMutableDictionary dictionary];
        [theInfo setObject:theTicketObj forKey:@"Ticket"];
        [theInfo setObject:[theFileInfo fileName] forKey:@"File Name"];
        [theInfo setObject:[theFileInfo resourceName] forKey:@"Resource Name"];
        [imageInfos addObject:theInfo];
    }
    [mapInfo setObject:imageInfos forKey:@"Image Infos"];
    
    return [NSPropertyListSerialization dataFromPropertyList:mapInfo format:NSPropertyListBinaryFormat_v1_0 errorDescription:nil];
}

- (void)restoreResourceMapData:(NSData*)data
{
    NSDictionary* mapInfo = [NSPropertyListSerialization propertyListFromData:data
                                                             mutabilityOption:NSPropertyListImmutable
                                                                       format:NULL
                                                             errorDescription:nil];

    // 画像
    NSArray* imageInfos = [mapInfo objectForKey:@"Image Infos"];
    for (int i = 0; i < [imageInfos count]; i++) {
        NSDictionary* anImageInfo = [imageInfos objectAtIndex:i];
        NSNumber* theTicketObj = [anImageInfo objectForKey:@"Ticket"];
        NSString* fileName = [anImageInfo objectForKey:@"File Name"];
        NSString* resourceName = [anImageInfo objectForKey:@"Resource Name"];
        
        BXResourceFileInfo* theInfo = [[[BXResourceFileInfo alloc] initWithFileName:fileName
                                                                       resourceName:resourceName
                                                                           document:mDocument] autorelease];
        [mImageInfoMap setObject:theInfo forKey:theTicketObj];
    }
}

@end

